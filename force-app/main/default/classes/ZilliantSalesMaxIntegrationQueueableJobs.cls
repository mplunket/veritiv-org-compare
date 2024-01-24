public with sharing class ZilliantSalesMaxIntegrationQueueableJobs implements Schedulable {

	public String zilliantAccessToken;
	public String currentResourceType;

	public List<Error_Log__c> errorLogs = new List<Error_Log__c>(); /* List of Error Log Object to be Insert at the End of Processing */
	public Integer jobCount = 0;
	public final Integer MAX_JOB_COUNT = 2;

	public List<ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper> convertedResults = new List<ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper>();

	public ZilliantSalesMaxIntegrationQueueableJobs() {
		
	}

	@future (callout=true)
	public static void runJob()
	{
		String accessToken = ZilliantSalesMaxIntegrationServices.getSalesMaxAuthorizationString();
		if( accessToken != NULL )
		{
			ZilliantSalesMaxIntegrationQueueableJobs job = new ZilliantSalesMaxIntegrationQueueableJobs();

			/* Setup Parent Date for Queued Jobs to Read From */
			job.zilliantAccessToken = accessToken;
			job.currentResourceType = ZilliantSalesMaxIntegrationServices.CUSTOMER_INSIGHT_RESOURCE_TYPE;
			job.jobCount++;

			/* Calculate the proper dates to get based on the last successful run of the batch. */
			String insightDateFilterCriteria = ''; //Date.today().Year() + '-' + Date.today().Month() + '-' + (Date.today().Day() - 1);
			if(ZilliantSalesMaxIntegrationServices.csBatchLastRun.Insights_From_Zilliant__c == NULL)
			{
				insightDateFilterCriteria = Date.today().Year() + '-' + Date.today().Month() + '-' + Date.today().addDays(-7).Day();
				System.debug('Setting Start Date to Today! ' + Date.today());
			}
			else
			{
				Date batchRunDate = ZilliantSalesMaxIntegrationServices.csBatchLastRun.Insights_From_Zilliant__c;
				insightDateFilterCriteria = batchRunDate.Year() + '-' + batchRunDate.Month() + '-' + batchRunDate.Day();
				System.debug('Setting Start Date to CS! ' + batchRunDate);
			}

			/* Start Queueable Process --> Insights First */
			ZilliantSalesMaxIntegrationQueueableJobs.BulkDataJobRequest customerInsightJob = new ZilliantSalesMaxIntegrationQueueableJobs.BulkDataJobRequest(job);
			customerInsightJob.resourceType = ZilliantSalesMaxIntegrationServices.CUSTOMER_INSIGHT_RESOURCE_TYPE;
			customerInsightJob.operationType = ZilliantSalesMaxIntegrationServices.QUERY_OPERATION_TYPE;
			customerInsightJob.queryParameters = ZilliantSalesMaxIntegrationServices.buildInsightsCriteria( insightDateFilterCriteria ); //insightDateFilterCriteria
			customerInsightJob.errors = job.errorLogs;
			System.enqueueJob(customerInsightJob);
		}
		else
		{
			System.debug('Something went wrong with the SalesMax Zilliant Insight Syncing.');
			System.debug('Issue with getting the access token.');
			// TODO : Create error record here for batch not even starting due to issue with access token.
		}
	}

	/* Starting Point from Schedulable Call */
	public void execute(SchedulableContext sc)
	{
		runJob();
	}

	/* Zilliant to Salesforce Integrations */

	/* Method for starting the Batch and getting the Batch Job Id from Zilliant. */
	public class BulkDataJobRequest implements Queueable, Database.AllowsCallouts
	{
		public ZilliantSalesMaxIntegrationQueueableJobs parent;
		public String queryParameters; 		/* String to hold the Request going to be sent. */
		public String resourceType;			/* String to hold the Object type that is being Queried for. */
		public String operationType;		/* String to hold the Operation type that is being applied. [insert, query] */
		public List<Error_Log__c> errors;

		public BulkDataJobRequest(ZilliantSalesMaxIntegrationQueueableJobs context) {
			parent = context;
		}

		public void execute(QueueableContext qc)
		{
			// Build Request for Starting the Batch with Filter/Criteria
			String batchId = ZilliantSalesMaxIntegrationServices.getSalesMax_QueryBatchId(parent.zilliantAccessToken, queryParameters, resourceType, operationType);
			System.debug('### BulkDataJobRequest ###');
			System.debug('batchId: ' + batchId);
			System.debug('resourceType: ' + resourceType );
			System.debug('queryParameters : ' + queryParameters);

			if( batchId != NULL)
			{
				ZilliantSalesMaxIntegrationQueueableJobs.StatusRequest statusJob = new ZilliantSalesMaxIntegrationQueueableJobs.StatusRequest(parent);
				statusJob.batchId = batchId;
				statusJob.errors = errors;
				System.enqueueJob(statusJob);
			}
		}

	}

	/* Method for Querying the Batch Status in Zilliant. */
	public class StatusRequest implements Queueable, Database.AllowsCallouts
	{
		public ZilliantSalesMaxIntegrationQueueableJobs parent;
		public String batchId;
		public Integer recursiveCallCount = 0;			/* Variable to hold the number of times the Recursive Status call has been fired. */
		public List<Error_Log__c> errors;

		public StatusRequest(ZilliantSalesMaxIntegrationQueueableJobs context) {
			parent = context;
		}

		public void execute(QueueableContext qc)
		{
			// TODO : Increment for each time its being called, to track for limits and possible stop after reaching a certain number.
			//recursiveCallCount++;

			// Build Request for getting the Status of the Running Batch.
			String status = ZilliantSalesMaxIntegrationServices.getSalesMax_Status(parent.zilliantAccessToken, batchId);

			System.debug('### Status Request ###');
			System.debug('status: ' + status);
			System.debug('recursiveCallCount: ' + recursiveCallCount);

			if(status != NULL)
			{
				if(status == ZilliantSalesMaxIntegrationServices.BATCH_STATUS_SUBMITTED)
				{
					System.debug('Batch submitted.');
					ZilliantSalesMaxIntegrationQueueableJobs.StatusRequest nextStatusJob = new ZilliantSalesMaxIntegrationQueueableJobs.StatusRequest(parent);
					nextStatusJob.batchId = batchId;
					nextStatusJob.recursiveCallCount = ++recursiveCallCount;
					nextStatusJob.errors = errors;
					System.enqueueJob(nextStatusJob);
				}
				else if(status == ZilliantSalesMaxIntegrationServices.BATCH_STATUS_QUEUED)
				{
					System.debug('Batch queued.');
					ZilliantSalesMaxIntegrationQueueableJobs.StatusRequest nextStatusJob = new ZilliantSalesMaxIntegrationQueueableJobs.StatusRequest(parent);
					nextStatusJob.batchId = batchId;
					nextStatusJob.recursiveCallCount = ++recursiveCallCount;
					nextStatusJob.errors = errors;
					System.enqueueJob(nextStatusJob);

				}
				else if(status == ZilliantSalesMaxIntegrationServices.BATCH_STATUS_PROCESSING)
				{
					System.debug('Batch processing.');
					ZilliantSalesMaxIntegrationQueueableJobs.StatusRequest nextStatusJob = new ZilliantSalesMaxIntegrationQueueableJobs.StatusRequest(parent);
					nextStatusJob.batchId = batchId;
					nextStatusJob.recursiveCallCount = ++recursiveCallCount;
					nextStatusJob.errors = errors;
					System.enqueueJob(nextStatusJob);
				}
				else if(status == ZilliantSalesMaxIntegrationServices.BATCH_STATUS_FAILED)
				{
					System.debug('Batch failed.');

					System.debug('Parent Current Resource Type: ' + parent.currentResourceType);

					if( parent.currentResourceType == ZilliantSalesMaxIntegrationServices.OPPORTUNITY_ACTIVITY_RESOURCE_TYPE)
					{
						System.debug('Do Opportunity Activity Resource Failure Logic!');
						/* Queue Result Table for Batch */
						ZilliantSalesMaxIntegrationQueueableJobs.ResultRequest resultJob = new ZilliantSalesMaxIntegrationQueueableJobs.ResultRequest(parent);
						resultJob.batchId = batchId;
						resultJob.errors = errors;
						System.enqueueJob(resultJob);
					}
				}
				else if(status == ZilliantSalesMaxIntegrationServices.BATCH_STATUS_COMPLETED)
				{
					System.debug('Batch completed: ' + batchId);
					System.debug('Parent Batch Job Count: ' + parent.jobCount);
					ZilliantSalesMaxIntegrationQueueableJobs.ResultRequest resultJob = new ZilliantSalesMaxIntegrationQueueableJobs.ResultRequest(parent);
					resultJob.batchId = batchId;
					resultJob.errors = errors;
					System.enqueueJob(resultJob);
				}
				else if(status == ZilliantSalesMaxIntegrationServices.BATCH_STATUS_PARTIAL)
				{
					System.debug('Batch completed: ' + batchId);
					System.debug('Parent Batch Job Count: ' + parent.jobCount);
					ZilliantSalesMaxIntegrationQueueableJobs.ResultRequest resultJob = new ZilliantSalesMaxIntegrationQueueableJobs.ResultRequest(parent);
					resultJob.batchId = batchId;
					resultJob.errors = errors;
					System.enqueueJob(resultJob);
				}
				else
				{
					System.debug('Unrecognized status.');
				}
			}
			
		}

	}

	/* Method for getting the Batch Results from Zilliant. */
	public class ResultRequest implements Queueable, Database.AllowsCallouts
	{
		public ZilliantSalesMaxIntegrationQueueableJobs parent;
		public String batchId;
		public List<Error_Log__c> errors;

		public ResultRequest(ZilliantSalesMaxIntegrationQueueableJobs context) {
			parent = context;
		}

		public void execute(QueueableContext qc)
		{
			String result = ZilliantSalesMaxIntegrationServices.getSalesMax_Result(parent.zilliantAccessToken, batchId);
			System.debug('### Result Request ###');
			System.debug('result: ' + result);

			if(result != NULL)
			{
				/* Check Results for Actual Data and if only header row is returned */
				Boolean emptyResults = ZilliantSalesMaxIntegrationServices.areResultsEmpty(result, parent.currentResourceType);
				if( emptyResults )
				{
					System.debug('Results are empty for: ' + parent.currentResourceType);
					System.debug('Quitting AQM.');
					String errorMessage = 'No Rows in Result for ' + parent.currentResourceType + ' Batch. \n Exiting Batch.';
					ZilliantSalesMaxIntegrationServices.createErrorRecord('99', errorMessage, 'No Insight Key.');
					return;
				}
				
				List<Error_Log__c> syncErrors = ZilliantSalesMaxIntegrationServices.syncZilliantResultsIntoOpportunities(parent.convertedResults, result, parent.currentResourceType);

				if(parent.jobCount == parent.MAX_JOB_COUNT)
				{
					List<Opportunity> oppsToInsert = new List<Opportunity>();
					for( ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper oppWrapper : parent.convertedResults )
					{
						// Set default fields.
						// TODO : Can Move this to a more appropriate place.
						oppWrapper.Opp.Name = 'Created By Zill';
						oppWrapper.Opp.CloseDate = Date.today().addDays(60); /* TODO : Use config to set this. */
						oppWrapper.Opp.StageName = '3- Project Identified';
						oppWrapper.Opp.CampaignId = Label.Veritiv_IQ_Campaign_ID; /* TODO : Put checks on this. */

						oppsToInsert.add( oppWrapper.Opp);
					}

					System.debug('About to Insert Opps!');

					ZilliantSalesMaxIntegrationServices.insertOpps( oppsToInsert );

					// Update Custom Setting --> /* TODO : Need to move this to a better place, in the case of no results, this still needs to run. */
					upsert new VIQ_Last_Successful_Batch_Run_Date__c( Id = ZilliantSalesMaxIntegrationServices.csBatchLastRun.Id, Insights_From_Zilliant__c = Date.Today());
				}

				if(parent.currentResourceType == ZilliantSalesMaxIntegrationServices.CUSTOMER_INSIGHT_RESOURCE_TYPE)
				{
					parent.currentResourceType = ZilliantSalesMaxIntegrationServices.PRODUCT_GROUPING_INSIGHT_RESOURCE_TYPE;
					parent.jobCount++;

					List<String> insightKeys = new List<String>();
					for(ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper iow : parent.convertedResults)
					{
						insightKeys.add( iow.insightId );
					}

					ZilliantSalesMaxIntegrationQueueableJobs.BulkDataJobRequest productGroupingJob = new ZilliantSalesMaxIntegrationQueueableJobs.BulkDataJobRequest(parent);
					productGroupingJob.resourceType = ZilliantSalesMaxIntegrationServices.PRODUCT_GROUPING_INSIGHT_RESOURCE_TYPE;
					productGroupingJob.operationType = ZilliantSalesMaxIntegrationServices.QUERY_OPERATION_TYPE;
					productGroupingJob.queryParameters = ZilliantSalesMaxIntegrationServices.buildQueryCriteria(insightKeys);
					System.enqueueJob(productGroupingJob);
					
					System.debug('Finished Processing Data for I: ' + ZilliantSalesMaxIntegrationServices.CUSTOMER_INSIGHT_RESOURCE_TYPE);
					System.debug('Results Job Count: ' + parent.jobCount);
				}
				else if(parent.currentResourceType == ZilliantSalesMaxIntegrationServices.OPPORTUNITY_ACTIVITY_RESOURCE_TYPE)
				{
					/* Finished Processing --> Update Custom Setting */
					// TODO : Improve w/ Error Handling Here
					upsert new VIQ_Last_Successful_Batch_Run_Date__c( Id = ZilliantSalesMaxIntegrationServices.csBatchLastRun.Id, Activities_To_Zilliant__c = Date.Today() );
				}
				else
				{
					System.debug('Unknown Resource Type: ' + parent.currentResourceType);
				}

				if( !syncErrors.isEmpty() )
				{
					try
					{
						insert syncErrors;
					}
					catch(Exception ex)
					{
						System.debug('Failed Inserting Sync Error: ' + ex.getMessage());
					}
				}
			}
		}

	}

}
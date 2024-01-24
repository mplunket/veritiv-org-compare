public with sharing class ZilliantSalesMaxBatchIntegration implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts {
	
	// Zilliant Access Token to be used 
	public String zilliantAccessToken 
	{
		get
		{
			if(zilliantAccessToken == NULL)
			{
				zilliantAccessToken = ZilliantSalesMaxIntegrationServices.getSalesMaxAuthorizationString();
			}
			return zilliantAccessToken;
		}

		set;
	}

	public ZilliantSalesMaxBatchIntegration() {
		
	}

	// builds dynamic query
	public Database.Querylocator start( Database.BatchableContext bc )
	{
		String queryString = ZilliantSalesMaxBatchIntegrationServices.buildQuery_RecentOpportunityActivity();

		return Database.getQuerylocator( queryString );
	}

	// performs functionality from service class
	public void execute( Database.BatchableContext BC, List<Opportunity> scope )
	{
		// Zilliant OAuth Token
		String accessToken = ZilliantSalesMaxIntegrationServices.getSalesMaxAuthorizationString();

		String convertedOpps = ZilliantSalesMaxBatchIntegrationServices.convertOppsToCSV(scope);

		/* Maybe make this part of a queueable call? */
		String batchJobId = ZilliantSalesMaxBatchIntegrationServices.makeInsertCall(convertedOpps, accessToken);

		if( String.isNotBlank(batchJobId) )
		{
			ZilliantSalesMaxIntegrationQueueableJobs parent = new ZilliantSalesMaxIntegrationQueueableJobs();
			parent.zilliantAccessToken = accessToken;
			parent.currentResourceType = ZilliantSalesMaxIntegrationServices.OPPORTUNITY_ACTIVITY_RESOURCE_TYPE;

			/* Queue up Status Call */
			ZilliantSalesMaxIntegrationQueueableJobs.StatusRequest statusJob = new ZilliantSalesMaxIntegrationQueueableJobs.StatusRequest(parent);
			statusJob.batchId = batchJobId;
			System.enqueueJob(statusJob);

			System.debug('Queued For Result!');
		}

		System.debug('Completed a Call. Starting next batch.');
	}

	// if error, build message and send email
	public void finish( Database.BatchableContext bc )
	{

	}


	// Scheduable Execute
	public void execute( SchedulableContext sc )
	{
		Database.executeBatch( new ZilliantSalesMaxBatchIntegration() );		
	}
}
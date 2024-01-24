public with sharing class ZilliantSalesMaxIntegrationServices {

	/* Resource Types used in API Calls. */
	public static final String CUSTOMER_INSIGHT_RESOURCE_TYPE = 'CustomerInsight'; // Salesforce Opportunities
	public static final String PRODUCT_GROUPING_INSIGHT_RESOURCE_TYPE = 'ProductGroupingInsight'; // Salesforce...
	public static final String PRODUCT_GROUPING_RESOURCE_TYPE = 'ProductGrouping'; // Salesforce...
	public static final String OPPORTUNITY_ACTIVITY_RESOURCE_TYPE = 'OpportunityActivity';

	/* DML Types used in API Calls. */
	public static final String INSERT_OPERATION_TYPE = 'insert';
	public static final String QUERY_OPERATION_TYPE = 'query';

	/* Response Status Code */
	public static final Integer SF_RESPONSE_STATUS_OK = 200;
	public static final Integer SF_RESPONSE_STATUS_ERROR = 400;
	public static final Integer ZIL_RESPONSE_STATUS_OK = 201;

	/* Zilliant Batch Statuses. */
	public static final String BATCH_STATUS_SUBMITTED = 'SUBMITTED';
	public static final String BATCH_STATUS_QUEUED = 'QUEUED';
	public static final String BATCH_STATUS_PROCESSING = 'PROCESSING';
	public static final String BATCH_STATUS_FAILED = 'FAILED';
	public static final String BATCH_STATUS_COMPLETED = 'COMPLETED';
	public static final String BATCH_STATUS_PARTIAL = 'PARTIAL_SUCCESS';

	public static final String AUTHORIZATION_HEADER_KEY = 'Authorization';
	public static final String AUTHORIZATION_HEADER_VALUE = 'OAuth ';
	public static final String ZILLIANT_JOB_ID_KEY = 'bulkDataJobId';
	public static final String ZILLIANT_STATUS_KEY = 'Status';

	/* Zilliant API Strings */
	public static final String STATUS_ENDPOINT = 'status';
	public static final String RESULT_ENDPOINT = 'result';

	/* Constants */
	public static final Integer ZIL_QUERY_LIMIT = 1000;

	public static VIQ_Authentication_Connection__c csZilToSFCreds
	{
		get
		{
			if(csZilToSFCreds == NULL)
			{
				csZilToSFCreds = VIQ_Authentication_Connection__c.getOrgDefaults();
			}
			return csZilToSFCreds;
		}

		set;
	}

	/* Properties for Custom Settings */
	public static VIQ_Last_Successful_Batch_Run_Date__c csBatchLastRun
	{
		get
		{
			if(csBatchLastRun == NULL)
			{
				csBatchLastRun = VIQ_Last_Successful_Batch_Run_Date__c.getOrgDefaults();
			}
			return csBatchLastRun;
		}

		set;
	}

	/* Salesforce API Authorization Strings */ // TODO : Clean Up and Put Into Named Credentials
	public static final String AUTH_URL = 'callout:SF_SalesIQ_Auth/services/oauth2/token'; //'https://test.salesforce.com/services/oauth2/token';
	public static final String API_USERNAME = '{!$Credential.Username}'; //'admin@unisource.com.salesiq';
	public static final String API_PASSWORD = '{!$Credential.Password}'; //'P@ssw0rd1';
	//public static final String API_SECURITY_TOKEN = 'Xzy2u1DY6Uzb7tKhJAF2Bk6XQ';
	public static String ZILLIANT_BASE_REQUEST_URL = csZilToSFCreds.Zilliant_URL__c; //'https://veritiv.zilliant.com/salesmax/BulkDataJob/v1';
	public static String CONSUMER_KEY = csZilToSFCreds.App_Consumer_Key__c; //'3MVG97wqanbUM37IrVAYa3ZeAtHO0PIQOmIJOQPSG3C7ZlKqV6qQ28LOLPkefh_JEfzMwrWX2JVJ.k0o6TgEr';
	public static String CONSUMER_SECRET = csZilToSFCreds.App_Consumer_Secret__c; //'5259521906564034481';


	/* Insights Table Field Mapping */
	public static Set<String> insightFieldColumns = new Set<String>{
		'CustomerInsightKey', 'CustomerInsightVersionKey', 'Amount', 'AmountNormalized', 'AmountExpansionOpportunity', 
		'AmountExpansionOpportunityNormalized', 'AmountRecoveryOpportunity', 'AmountRecoveryOpportunityNormalized', 
		'StatusSummary', 'CustomerInsightStatus', 'Username', 'AccountNumber', 'ClusterSegmentId', 'Initiative', 'InitiativeName', 
		'CustomerInsightVersionCreatedDate', 'CustomerInsightLastModifiedDate'
	};

	/* Product Grouping Insights Table Field Mapping */
	public static Set<String> productGroupingInsightFieldColumns = new Set<String> {
		'CustomerInsightKey', 'ProductGroupingKey', 'Amount', 'AmountNormalized', 'ProductGroupingInsightState', 
		'ProductGroupingInsightCreatedDate','ProductGroupingInsightLastModifiedDate', 'ProductGroupingOpportunityType'
	};

	/* Product Grouping Table Field Mapping */
	public static Set<String> productGroupingFieldColumns = new Set<String> {
		'ProductGroupingKey', 'ProductGroupingIdValue', 'ProductGroupingDescValue'
	};

	/* Opportunity Activity Field Mapping */
	public static Set<String> opportunityActivityFieldColumns = new Set<String> {
		'status', 'error', 'customer_insight_key', 'customer_insight_version_key', 'product_grouping_key', 'activity', 'user', 'notes', 'date', 'product_grouping_insight_type'
	};

	/* Map to hold Conversion Values for Opportunity Type Field. */
	public static Map<String, String> oppTypeConversionMap = new Map<String, String> {
		'Cross Sell' => 'New Opportunity', 'Lost Sales' => 'Defending Existing Business'
	};

	public static Map<String, String> prodSegmentMapping = new Map<String, String> {
		'M' => 'Facitlity Solutions', 'P' => 'Packaging', 'F' => 'Print', // These are direct mappings
		'FS' => 'Facility Solutions', 'PK' => 'Packaging', 'PR' => 'Print'			  // These are fuzzy mappings *begins with*
	};

	public static Id defaultRT
	{
		get
		{
			if(defaultRT == NULL)
			{
				defaultRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('VeritivIQ').getRecordTypeId();
			}
			return defaultRT;
		}

		set;
	}

	// Custom Metadata Type used to hold the conversion mapping for the Product Categories picklist.
	public static Map<String, List<VeritivIQ_ProductGrouping_Prod_Cat_Maps__c>> prodCatMapping
	{
		get
		{
			if(prodCatMapping == NULL)
			{
				prodCatMapping = GroupBy.Strings('ProductGroupingKey__c', [SELECT Opp_Prod_Categories__c, ProductGroupingDescValue__c, ProductGroupingKey__c FROM VeritivIQ_ProductGrouping_Prod_Cat_Maps__c]);
			}
			return prodCatMapping;
		}

		set;
	}

	public ZilliantSalesMaxIntegrationServices() {
		
	}

	/* Method called to sign into Zilliant servers. */
	public static String getSalesMaxAuthorizationString()
	{
		System.debug('### getSalesMaxAuthorizationString ###');

		if(csZilToSFCreds != NULL)
		{
			String errorMessage = 'Authentication Issue with Connected App or Zilliant Base URL, check VIQ Authentication Connection Custom Setting: \n';
			Boolean foundIssue = false;

			if(String.isBlank(CONSUMER_KEY))
			{
				errorMessage += 'Connected App Consumer Key is missing from the Custom Setting\n';
				foundIssue = true;
			}
			if(String.isBlank(CONSUMER_SECRET))
			{
				errorMessage += 'Connected App Consumer Secret is missing from the Custom Setting\n';
				foundIssue = true;
			}
			if(String.isBlank(csZilToSFCreds.Zilliant_URL__c))
			{
				errorMessage += 'Zilliant URL is missing from the Custom Setting\n';
				foundIssue = true;
			}
			if(foundIssue)
			{
				errorMessage += 'Exiting Batch!';
				createErrorRecord('99', errorMessage, 'No Insight Key');
				return NULL;
			}
		}

		String responseBody = '';
		String reqString = String.format('grant_type=password&client_id={0}&client_secret={1}&username={2}&password={3}',
		                                 new String[] {CONSUMER_KEY, CONSUMER_SECRET, API_USERNAME, API_PASSWORD});

		HttpRequest authRequest = new HttpRequest();
		authRequest.setMethod('POST');
		authRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		authRequest.setBody(reqString);
		authRequest.setEndpoint(AUTH_URL);

		HttpResponse authResponse = new HttpResponse();

		try
		{
			authResponse = new HTTP().send(authRequest);
			System.debug('authResponse.getBody(): ' + authResponse.getBody());
			if(authResponse.getStatusCode() == SF_RESPONSE_STATUS_OK)
			{
				responseBody = EncodingUtil.base64Encode(authResponse.getBodyAsBlob());
			}
			else if(authResponse.getStatusCode() == SF_RESPONSE_STATUS_ERROR) // TODO - Improve Error Handling
			{
				responseBody = NULL;
				String errorMessage = 'Error Logging Into Salesforce: ' + authResponse.getStatus() + 'Response: ' + authResponse.getBody();
				createErrorRecord('99', errorMessage, 'No Insight Key');
				System.debug('Error Logging Into Salesforce: ' + authResponse.getStatus() + 'Response: ' + authResponse.getBody());
			}
			else
			{
				responseBody = NULL;
				String errorMessage = 'Error with the Response. We received an unknown Response Code. ' + 'Status: ' + authResponse.getStatus() + ' : ' + authResponse.getBody();
				createErrorRecord('99', errorMessage, 'No Insight Key');
				System.debug('Error with the Response. We received an unknown Response Code. ' + 'Status: ' + authResponse.getStatus() + ' : ' + authResponse.getBody());
			}
		}
		catch(Exception ex) // Catch TypeCasting Error, Catch Callout Error
		{
			responseBody = NULL;
			String message = ex.getMessage() + '\n Cannot continue processing, Job is exiting.';
			createErrorRecord('99', message, 'No Insight Key');
		}
		
		System.debug('responseBody: ' + responseBody);
		return responseBody;
	}

	/* Query Method */
	public static String getSalesMax_QueryBatchId(String oAuthToken, String requestString, String resourceType, String operationType)
	{
		System.debug('### getSalesMax_QueryBatchId ###');
		System.debug('oAuthToken: ' + oAuthToken);
		System.debug('requestString: ' + requestString);
		System.debug('resourceType: ' + resourceType);
		System.debug('operationType: ' + operationType);

		String batchId;

		HttpRequest batchJobRequest = new HttpRequest();
		batchJobRequest.setMethod('POST');
		batchJobRequest.setHeader('Content-Type', 'application/json');
		batchJobRequest.setHeader(AUTHORIZATION_HEADER_KEY, AUTHORIZATION_HEADER_VALUE + oAuthToken);
		batchJobRequest.setBody(requestString);
		batchJobRequest.setEndpoint(ZILLIANT_BASE_REQUEST_URL + '?type=' + resourceType + '&operation=' + operationType);
		batchJobRequest.setTimeout(120000);

		HttpResponse batchJobResponse = new HttpResponse();

		try
		{
			batchJobResponse = new Http().send(batchJobRequest);
			System.debug('batchJobResponse.getBody(): ' + batchJobResponse.getBody());

			if(batchJobResponse.getStatusCode() == ZIL_RESPONSE_STATUS_OK)
			{
				JSONParser parser = JSON.createParser(batchJobResponse.getBody());
				while(parser.nextToken() != null)
				{
					if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == ZILLIANT_JOB_ID_KEY)
					{
						parser.nextToken();
						batchId = parser.getText();
						break;
					}
				}
			}
			else
			{
				batchId = NULL;
				String errorMessage = 'Zilliant Query Batch Job returned an unexpected Error Code: ' + batchJobResponse.getStatusCode() +  
									  '\n Cannot continue processing, Job is exiting.';
				createErrorRecord('99', errorMessage, 'No Insight Key');
			}
		}
		catch(Exception ex)
		{
			batchId = NULL;
			String errorMessage = 'Something broke in making a Zilliant Request to start a Query Batch. Error: ' + ex.getMessage() +
								  ' \n Cannot continue processing, Job is exiting.';
			createErrorRecord('99', errorMessage, 'No Insight Key');
		}

		System.debug('batchId: ' + batchId);
		return batchId;
	}

	public static String getSalesMax_Status(String oAuthToken, String batchId)
	{
		System.debug('### getSalesMax_Status ###');
		String status = '';

		HttpRequest statusRequest = new HttpRequest();
		statusRequest.setMethod('GET');
		statusRequest.setHeader('Content-Type', 'application/json');
		statusRequest.setHeader(AUTHORIZATION_HEADER_KEY, AUTHORIZATION_HEADER_VALUE + oAuthToken);
		statusRequest.setEndpoint(ZILLIANT_BASE_REQUEST_URL + '/' + batchId + '/' + STATUS_ENDPOINT);
		statusRequest.setTimeout(120000);

		HttpResponse statusResponse = new HttpResponse();

		try
		{
			statusResponse = new Http().send(statusRequest);
			System.debug('statusResponse.getBody(): ' + statusResponse.getBody());

			if(statusResponse.getStatusCode() == ZIL_RESPONSE_STATUS_OK)
			{
				JSONParser parser = JSON.createParser(statusResponse.getBody());
				while(parser.nextToken() != null)
				{
					if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == ZILLIANT_STATUS_KEY)
					{
						parser.nextToken();
						status = parser.getText();
						break;
					}
				}
			}
			else
			{
				String errorMessage = 'Zilliant Status Batch Job returned an unexpected Error Code: ' + statusResponse.getStatusCode() +  
									  '\n Cannot continue processing, Job is exiting.';
				createErrorRecord('99', errorMessage, 'No Insight Key');
			}
		}
		catch(Exception ex)
		{
			status = NULL;
			String errorMessage = 'Something broke in making a Zilliant Request to get a Batch Status. Error: ' + ex.getMessage() +
								  ' \n Cannot continue processing, Job is exiting.';
			createErrorRecord('99', errorMessage, 'No Insight Key');
		}

		System.debug('status: ' + status);

		return status;
	}

	public static String getSalesMax_Result(String oAuthToken, String jobId)
	{
		String result = '';

		HttpRequest resultRequest = new HttpRequest();
		resultRequest.setMethod('GET');
		resultRequest.setHeader('Content-Type', 'application/json');
		resultRequest.setHeader(AUTHORIZATION_HEADER_KEY, AUTHORIZATION_HEADER_VALUE + oAuthToken);
		resultRequest.setEndpoint(ZILLIANT_BASE_REQUEST_URL + '/' + jobId + '/' + RESULT_ENDPOINT);
		resultRequest.setTimeout(120000);

		try
		{
			HttpResponse resultResponse = new Http().send(resultRequest);
			result = resultResponse.getBody();
		}
		catch(Exception ex)
		{
			result = NULL;
			String errorMessage = 'Something broke in making a Zilliant Request to get a Batch Result. Error: ' + ex.getMessage() +
								  ' \n Cannot continue processing, Job is exiting.';
			createErrorRecord('99', errorMessage, 'No Insight Key');
		}

		return result;
	}

	public static String buildQueryCriteria(List<String> insightKeys)
	{
		String criteria = '{';
		criteria 		+= '"limit": ' + ZIL_QUERY_LIMIT + ',';
		criteria		+= 	'"filters": {';
		criteria		+=		'"CustomerInsightKey": ['; //Filters
		criteria 		+=		'"' + String.join(insightKeys, '", "') + '"]';
		criteria		+=	'}';
		criteria       += '}';
		System.debug('Query with Insight Keys Criteria: ' + criteria);
		return criteria;
	}

	public static String buildInsightsCriteria(String insightDateCriteria)
	{
		String criteria = '{';
		criteria 		+= '"limit": ' + ZIL_QUERY_LIMIT + ',';
		criteria		+= 	'"filters": {';
		criteria		+=		'"CustomerInsightStatus": ["PURSUING"],'; //Filters
		criteria		+=		'"CustomerInsightLastModifiedDate": ["' + insightDateCriteria + '"]';
		criteria		+=	'}';
		criteria       += '}';
		System.debug('Insights Criteria: ' + criteria);
		return criteria;
	}

	public static void insertOpps(List<Opportunity> oppsToInsert)
	{
		try
		{
			Database.SaveResult[] insertAttempt = Database.insert(oppsToInsert, false);
			List<Error_Log__c> errors = new List<Error_Log__c>();
			for(Database.SaveResult result : insertAttempt)
			{
				if(!result.isSuccess())
				{
					String errorMessage = '';
					for(Database.Error err : result.getErrors())
					{
						errorMessage += err.getStatusCode() + ': ' + err.getMessage() + '\n';
					}
					errors.add( new Error_Log__c(Error_Code__c = '10', Error_Message__c = errorMessage, VIQ_Insight_Key_Error__c = 'No insight key'));
				}
			}

			if(!errors.isEmpty())
			{
				try
				{
					insert errors;
				}
				catch(Exception ex)
				{
					// TODO : Add Error Handling
					System.debug('Got an error inserting Error Logs: ' + ex);
				}
			}
			
		}
		catch(Exception ex)
		{
			// TODO : Add Error Handling
			System.debug('Got an error inserting the Opps: ' + ex);
			createErrorRecord('99', ex.getMessage(), 'No insight key');
		}
	}

	public static void createErrorRecord(String code, String message, String insightKey)
	{
		try
		{
			insert new Error_Log__c(Error_Code__c = code, Error_Message__c = message, VIQ_Insight_Key_Error__c = insightKey);
		}
		catch(Exception dex)
		{
			System.debug('*** Error Creating an Error Log Record: ' + dex.getMessage());
		}
	}

	public static List<Map<String, String>> parseCSV(String csvData, Set<String> csvHeaders)
	{
		BW_CSVParser csvParser = new BW_CSVParser(csvData);
		List<String> currentLine = csvParser.readLine();
		List<String> columnNames = new List<String>();
		List<Map<String, String>> csvRows = new List<Map<String, String>>();

		while( currentLine != null )
		{
			if( isHeaderRow(currentLine, csvHeaders) )
			{
				columnNames = currentLine;
			}
			else
			{
				if(columnNames.size() == currentLine.size())
				{
					Map<String, String> row = new Map<String, String>();
					for(Integer i = 0; i < columnNames.size(); i++)
					{
						row.put(columnNames[i], currentLine[i].trim());
					}
					csvRows.add(row);
				}
				else
				{
					System.debug('Malformed row size');
				}
			}

			currentLine = csvParser.readLine();
		}

		return csvRows;
	}

	public static Boolean areResultsEmpty(String csvData, String resourceType)
	{
		BW_CSVParser csvParser = new BW_CSVParser(csvData);
		Set<String> headersToUse = new Set<String>();

		if( resourceType == CUSTOMER_INSIGHT_RESOURCE_TYPE)
		{
			headersToUse = insightFieldColumns;
		}
		else if( resourceType == PRODUCT_GROUPING_INSIGHT_RESOURCE_TYPE)
		{
			headersToUse = productGroupingInsightFieldColumns;
		}
		else if( resourceType == OPPORTUNITY_ACTIVITY_RESOURCE_TYPE)
		{
			headersToUse = opportunityActivityFieldColumns;
		}
		else
		{
			System.debug('Unknown Resource Type for Headers. Exiting. ' + resourceType);
			return TRUE;
		}

		Boolean foundHeader = isHeaderRow(csvParser.readLine(), headersToUse);

		if( foundHeader && csvParser.readLine() != NULL)
		{
			return FALSE;
		}
		else
		{
			return TRUE;
		}
	}

	private static Boolean isHeaderRow(List<String> row, Set<String> columnNames)
	{
		for(String field : row)
		{
			if(!columnNames.contains(field))
			{
				return false;
			}
		}

		return true;
	}

	//public static void createErrorRecord()

	public static List<Error_Log__c> syncZilliantResultsIntoOpportunities(List<InsightToOpportunityWrapper> wrappers, String resultsData, String resourceType)
	{
		List<Error_Log__c> syncErrors = new List<Error_Log__c>();

		if(resourceType == CUSTOMER_INSIGHT_RESOURCE_TYPE)
		{
			syncErrors.addAll( parse_Insights(wrappers, resultsData) );
		}
		// As of Now, not using due to Custom Metdata Data workaround.
		/*
		else if(resourceType == PRODUCT_GROUPING_RESOURCE_TYPE)
		{
			parse_ProductGroupings(wrappers, resultsData);
		}
		*/
		else if(resourceType == PRODUCT_GROUPING_INSIGHT_RESOURCE_TYPE)
		{
			syncErrors.addAll( parse_ProductGroupingInsights(wrappers, resultsData) );
		}
		else if(resourceType == OPPORTUNITY_ACTIVITY_RESOURCE_TYPE)
		{
			//syncErrors.addAll( parse_ProductGroupingInsights(wrappers, resultsData) );
		}
		else
		{
			System.debug('Invalid Resource Type of: ' + resourceType);
			String errorMessage = 'Found an Invalid Resource Type of: ' + resourceType;
			syncErrors.add( new Error_Log__c(Error_Code__c = '99', Error_Message__c = errorMessage, VIQ_Insight_Key_Error__c = 'No Inisght Key') );
		}

		return syncErrors;
	}

	public static List<Error_Log__c> parse_Insights(List<InsightToOpportunityWrapper> oppWrappers, String csvData)
	{
		List<Error_Log__c> insightSyncErrors = new List<Error_Log__c>();

		if(!oppWrappers.isEmpty())
		{
			String errorMessage = 'Something went wrong with Parsing the Insights. Wrappers are populated. Exiting batch.';
			insightSyncErrors.add( new Error_Log__c(Error_Code__c = '99', Error_Message__c = errorMessage, VIQ_Insight_Key_Error__c = 'No Insight Key') );
			return insightSyncErrors;
		}

		List<Map<String, String>> csvRows = parseCSV(csvData, insightFieldColumns);

		Set<String> networkIdsForUsers = new Set<String>(); // Set to be used to query to find the correct User
		Set<String> sysDivBillForAccounts = new Set<String>(); // Set to be used to query fo find the correct Account
		Set<String> userNameForPSRUser = new Set<String>(); // Set to be used to query to find the correct User for PSR
		Set<String> insightAccountNumberToShipTo = new Set<String>(); // Set to be used to query to find the correct ShipTo

		// Process all csv rows --> Setting up opps and making sets to query for related lookup objects.
		for(Map<String, String> row : csvRows)
		{
			InsightToOpportunityWrapper currentRowOppWrapper = new InsightToOpportunityWrapper();
			Opportunity currentRowOpp = new Opportunity(RecordTypeId = defaultRT);
			
			for(String fieldName : insightFieldColumns)
			{
				// Populate InsightId directly
				if(fieldName == 'CustomerInsightKey')
				{
					currentRowOppWrapper.insightId = row.get(fieldName);
					currentRowOpp.VIQ_Insight_Key__c = row.get(fieldName);
				}

				// Populate Version Key directly
				else if(fieldName == 'CustomerInsightVersionKey')
				{
					currentRowOpp.VIQ_Version_Key__c = row.get(fieldName);
				}

				// Populate Initiative directly
				else if(fieldName == 'Initiative')
				{
					currentRowOpp.VIQ_Initiative_Key__c = row.get(fieldName);
				}

				// Populate Initiative Name directly
				else if(fieldName == 'InitiativeName')
				{
					currentRowOpp.VIQ_Initiative__c = row.get(fieldName);
				}

				// If correct column, put into networkIdsForUsers set/map
				// If correct column, put into userNameForPSRUser set/map
				else if(fieldName == 'Username')
				{
					//String userName = row.get(fieldName);
					String userName = row.get(fieldName);
					currentRowOppWrapper.userNameForPSRUser = userName;
					currentRowOppWrapper.networkIdsForUsers = userName;

					userNameForPSRUser.add(userName.toUpperCase());
					networkIdsForUsers.add(userName.toUpperCase());
				}
				
				// If correct column, split by ('/')
				//		put into sysDivBillForAccounts set/map (On Left Side of Split)
				//		put into insightAccountNumberToShipTo set/map (On Ride Side of Split)
				else if(fieldName == 'AccountNumber')
				{
					List<String> accountNumSplit = row.get(fieldName).split('/');
					currentRowOppWrapper.insightSysDivBillForAccounts = accountNumSplit[0];
					currentRowOppWrapper.insightAccountNumberToShipTo = accountNumSplit[1];

					sysDivBillForAccounts.add(accountNumSplit[0]);
					insightAccountNumberToShipTo.add(accountNumSplit[1]);
				}

				// If correct column, ClusterSegmentId  in CustomerInsight table
				else if(fieldName == 'ClusterSegmentId')
				{
					String zillClusterSegment = row.get('ClusterSegmentId');
					String sfClusterSegment = '';

					System.debug('ZillClusterSegment: ' + zillClusterSegment);

					if(zillClusterSegment == 'M' || zillClusterSegment == 'P' || zillClusterSegment == 'F')
					{
						sfClusterSegment = prodSegmentMapping.get(zillClusterSegment);
						System.debug('MPF: ' + sfClusterSegment);
					}
					else if( zillClusterSegment.startsWith('PK') || zillClusterSegment.startsWith('FS') || zillClusterSegment.startsWith('PR') )
					{
						sfClusterSegment = prodSegmentMapping.get(zillClusterSegment.substring(0, 2));
						System.debug('PK FS: ' + sfClusterSegment);
					}
					else
					{
						String errorMessage = 'Found an unknown ClusterSegmentId. \n Insight: ' + currentRowOppWrapper.insightId + '\nClusterSegmentId: ' + zillClusterSegment;
						insightSyncErrors.add( new Error_Log__c(Error_Code__c = '99', Error_Message__c = errorMessage, VIQ_Insight_Key_Error__c = currentRowOppWrapper.insightId) );
					}

					System.debug('Actual Cluster Segment: ' + sfClusterSegment);
					currentRowOpp.Opportunity_Segment__c = sfClusterSegment;
				}
			}

			System.debug('Current Row Opp in Insight: ' + currentRowOpp);

			currentRowOppWrapper.opp = currentRowOpp;
			oppWrappers.add( currentRowOppWrapper );
		}

		// Query for related objects here.
		Map<String, List<User>> queryForOwner = GroupBy.Strings('VIQ_UPPER_NetworkId__c', [SELECT Id, Network_Id__c, VIQ_UPPER_NetworkId__c FROM User WHERE isActive = TRUE AND VIQ_UPPER_NetworkId__c IN :networkIdsForUsers]); //Network_Id__c
		Map<String, List<Account>> queryForSysDivBillToAccountWithChildShipTos = GroupBy.Strings('Account_SysDivBillTo__c', [SELECT Id, Account_SysDivBillTo__c, (SELECT Id, Ship_To_Code__c FROM Ship_Tos__r) FROM Account WHERE Account_SysDivBillTo__c IN :sysDivBillForAccounts]);
		Map<String, List<Primary_Sales_Rep__c>> queryForPSR = GroupBy.Strings('VIQ_UPPER_NetworkId_PSR__c', [SELECT Id, Network_Id__c, VIQ_UPPER_NetworkId_PSR__c FROM Primary_Sales_Rep__c WHERE VIQ_UPPER_NetworkId_PSR__c IN :userNameForPSRUser]); //Network_ID__c
		
		// Iterate through Opps and pluck from requeried values to continue to setup Opps.
		// Set defaults if values aren't contained in map.
		for(InsightToOpportunityWrapper ow : oppWrappers)
		{
			ow.opp.VIQ_Batch_Audit__c = 'Network Id: ' + ow.networkIdsForUsers + '\nBillTo: ' + ow.insightSysDivBillForAccounts + '\nShipTo: ' + ow.insightAccountNumberToShipTo;

			if(String.isNotBlank(ow.networkIdsForUsers) && queryForOwner.containsKey(ow.networkIdsForUsers.toUpperCase()))
			{
				List<User> ownerResults = queryForOwner.get(ow.networkIdsForUsers.toUpperCase());
				if( ownerResults.size() > 1 )
				{
					/* Found more than one owner. */
					insightSyncErrors.add( new Error_Log__c(Error_Code__c = '9', VIQ_Insight_Key_Error__c = ow.insightId) );
					ow.opp.OwnerId = Label.VeritivIQDefaultOwner;
				}
				else if( ownerResults.size() == 1 )
				{
					ow.opp.OwnerId = ownerResults[0].Id;
				}						
			}
			else
			{
				ow.opp.OwnerId = Label.VeritivIQDefaultOwner;
				//String errorMessage = 'No Active User found with specified Network Id. \nNetework Id: ' + ow.networkIdsForUsers;
				insightSyncErrors.add( new Error_Log__c(Error_Code__c = '5', VIQ_Insight_Key_Error__c = ow.insightId /*, Error_Message__c = errorMessage)*/ ) );
			}

			if(String.isNotBlank(ow.insightSysDivBillForAccounts) && queryForSysDivBillToAccountWithChildShipTos.containsKey(ow.insightSysDivBillForAccounts))
			{
				List<Account> accountResults = queryForSysDivBillToAccountWithChildShipTos.get(ow.insightSysDivBillForAccounts);

				if( accountResults.size() > 1 )
				{
					ow.opp.AccountId = Label.VIQ_Default_Account_Id;
					insightSyncErrors.add( new Error_Log__c(Error_Code__c = '6', VIQ_Insight_Key_Error__c = ow.insightId) );
				}

				Account relatedAccount = accountResults[0];

				/* Ship_To__c on Opportunity --> Through Relating Account's children with a match Ship_To_Code__c */
				ow.opp.AccountId = relatedAccount.Id;
				
				if( !relatedAccount.Ship_Tos__r.isEmpty() )
				{
					Integer shipToMatches = 0;
					
					for(Ship_To__c shipto : relatedAccount.Ship_Tos__r)
					{
						if( shipTo.Ship_To_Code__c == ow.insightAccountNumberToShipTo )
						{
							ow.opp.Ship_To__c = shipTo.Id;
							shipToMatches++;
						}
					}
					if(shipToMatches > 1)
					{
						insightSyncErrors.add( new Error_Log__c(Error_Code__c = '3', VIQ_Insight_Key_Error__c = ow.insightId) );
					}
					else if( shipToMatches == 0 )
					{
						insightSyncErrors.add( new Error_Log__c(Error_Code__c = '2', VIQ_Insight_Key_Error__c = ow.insightId) );
					}
				}

			}
			else
			{
				ow.opp.AccountId = Label.VIQ_Default_Account_Id;
				insightSyncErrors.add( new Error_Log__c(Error_Code__c = '1', VIQ_Insight_Key_Error__c = ow.insightId) );
			}

			if(String.isNotBlank(ow.userNameForPSRUser) && queryForPSR.containsKey(ow.userNameForPSRUser.toUpperCase()))
			{
				List<Primary_Sales_Rep__c> psrResults = queryForPSR.get(ow.userNameForPSRUser.toUpperCase());
				if( psrResults.size() > 1 )
				{
					insightSyncErrors.add( new Error_Log__c(Error_Code__c = '8', VIQ_Insight_Key_Error__c = ow.insightId) );
				}
				else
				{
					ow.opp.Primary_Sales_Rep_Name__c = psrResults[0].Id;
				}
			}
			else
			{
				insightSyncErrors.add( new Error_Log__c(Error_Code__c = '7', VIQ_Insight_Key_Error__c = ow.insightId) );
			}
		}

		return insightSyncErrors;
	}

	/*
	public static void parse_ProductGroupings(List<InsightToOpportunityWrapper> oppWrappers, String csvData)
	{
		if(oppWrappers.isEmpty())
		{
			System.debug('Wrappers should be populated inside of processing Product Groupings.');
			return;
		}

		List<Map<String, String>> csvRows = parseCSV(csvData, insightFieldColumns);
		for(Map<String, String> row : csvRows)
		{

		}
	}
	*/

	public static List<Error_Log__c> parse_ProductGroupingInsights(List<InsightToOpportunityWrapper> oppWrappers, String csvData)
	{
		List<Error_Log__c> pgiSyncErrors = new List<Error_Log__c>();

		if(oppWrappers.isEmpty())
		{
			System.debug('Wrappers should be populated inside of processing Product Grouping Insights.');
			String errorMessage = 'Something went wrong with Parsing the Product Grouping Insights. Wrappers are not populated. Exiting batch.';
			pgiSyncErrors.add( new Error_Log__c(Error_Code__c = '99', Error_Message__c = errorMessage, VIQ_Insight_Key_Error__c = 'No Insight Key') );
			return pgiSyncErrors;
		}

		Map<String, String> uniqueKeyToProdCats = new Map<String, String>();
		Map<String, Opportunity> insightKeyToOppMap = new Map<String, Opportunity>();
		for(InsightToOpportunityWrapper ow : oppWrappers)
		{
			insightKeyToOppMap.put( ow.insightId, ow.opp );
		}

		// Iterate through csv rows
		List<Map<String, String>> csvRows = parseCSV(csvData, productGroupingInsightFieldColumns);
		for(Map<String, String> row : csvRows)
		{
			String currentInsightKey = '';
			Double currentAmount = 0.0;
			String productGroupingKey = '';
			String pgOppType = '';

			for(String fieldName : productGroupingInsightFieldColumns)
			{
				// Setup InsightKey for Proccessing.
				if(fieldName == 'CustomerInsightKey')
				{
					currentInsightKey = row.get(fieldName);
				}
				// Setup up Amount for Processing.
				else if(fieldName == 'Amount')
				{
					System.debug('Amount Field: ' + row.get(fieldName));
					// TODO : Clean Up Here --> Casting Check
					currentAmount = Double.valueOf(row.get(fieldName));
				}
				// Setup ProductGroupingKey for processing.
				else if(fieldName == 'ProductGroupingKey')
				{
					// Get Value
					productGroupingKey = row.get(fieldName);
					if( !prodCatMapping.containsKey(productGroupingKey) )
					{
						System.debug('Unhandled ProductGroupingKey: ' + row.get(fieldName));
						System.debug('Skipping to next row');
						//String errorMessage = 'We found a Product Grouping Key that is not in the Custom Metadata Types, Skipping the processing of this item. ' +
						//						'\nProductGroupingKey: ' + productGroupingKey;
						pgiSyncErrors.add( new Error_Log__c(Error_Code__c = '4', VIQ_Insight_Key_Error__c = currentInsightKey /*, Error_Message__c = errorMessage*/) );
						continue;
					}
				}
				// Last column we care about, process all the values.
				else if(fieldName == 'ProductGroupingOpportunityType')
				{
					pgOppType = row.get('ProductGroupingOpportunityType');
					System.debug('Opp Type from Zill: ' + pgOppType);
				}
			}

			String uniqueKey = '';

			if( String.isNotBlank(currentInsightKey) )
			{
				 uniqueKey = currentInsightKey;
			}
			else
			{
				System.debug('Empty insight key or opportunity type\ncurrentInsightKey: ' + currentInsightKey);
				System.debug('Skipping to next row');
				String errorMessage = 'We found a Product Grouping Insight Row that is missing an Insight Key, Skipping the processing this item. ' +
									  '\nInsightKey: ' + currentInsightKey;
				pgiSyncErrors.add( new Error_Log__c(Error_Code__c = '99', VIQ_Insight_Key_Error__c = currentInsightKey, Error_Message__c = errorMessage) );
				continue;
			}

			if( String.isNotBlank(productGroupingKey) ) {

				if( uniqueKeyToProdCats.containsKey(uniqueKey) )
				{
					uniqueKeyToProdCats.put(uniqueKey, uniqueKeyToProdCats.get(uniqueKey) + '; ' + productGroupingKey);
				}
				else
				{
					uniqueKeyToProdCats.put(uniqueKey, productGroupingKey);
				}
			} 
			else 
			{
				System.debug('Product Grouping Key is blank! So we cannot put this into the map.');
			}
			
			System.debug('Unique Key Map Before Doing Opp: ' + uniqueKeyToProdCats);
			
			Opportunity relatedOpp = insightKeyToOppMap.get(currentInsightKey);

			// Setup variables that travel across multiple opps.

			/* Update Amount */
			if( relatedOpp.Amount == NULL )
			{
				relatedOpp.Amount = currentAmount;
			}
			else
			{
				relatedOpp.Amount += currentAmount;
			}

			/* Update Product Categories */
			if( prodCatMapping.containsKey(productGroupingKey) )
			{
				if( relatedOpp.Prod_Category__c == NULL )
				{
					relatedOpp.Prod_Category__c = prodCatMapping.get(productGroupingKey)[0].Opp_Prod_Categories__c;
					relatedOpp.VIQ_Return_Products__c = productGroupingKey;
				}
				else
				{
					relatedOpp.Prod_Category__c += ';' + prodCatMapping.get(productGroupingKey)[0].Opp_Prod_Categories__c;
					relatedOpp.VIQ_Return_Products__c += ',' + productGroupingKey;
				}
			}

			if( relatedOpp.Opportunity_Type__c == NULL && String.isNotBlank(pgOppType) )
			{
				relatedOpp.Opportunity_Type__c = oppTypeConversionMap.get(pgOppType);
				System.debug('Opp Type From SF: ' + oppTypeConversionMap.get(pgOppType));
			}

			if( relatedOpp.Opportunity_Type__c != NULL && relatedOpp.VIQ_Insight_Key__c != NULL )
			{
				relatedOpp.VIQ_Insight_Type_Unique__c = relatedOpp.VIQ_Insight_Key__c + relatedOpp.Opportunity_Type__c;
				System.debug('Opp Uniue From SF: ' + relatedOpp.VIQ_Insight_Type_Unique__c);
			}

			insightKeyToOppMap.put(uniqueKey, relatedOpp);

		/*
		else if(fieldName == 'ProductGroupingOpportunityType' && String.isNotBlank(currentInsightKey))
		{
			System.debug('Processing PGI, and found the ProductGroupingOpportunityType column, but the Insight Key is empty!');
		}
		*/
			/*}*/
		}

		// TODO : Have to come back and complete this (Solution)
		// Need to re-populate OppWrapper lists with updated opps.
		/// Also have to add new opps created to list.

		oppWrappers.clear();

		for(Opportunity createdOpp : insightKeyToOppMap.values())
		{
			InsightToOpportunityWrapper ow = new InsightToOpportunityWrapper();
			ow.opp = createdOpp;
			oppWrappers.add( ow );
			System.debug('Current Row Opp in PGI: ' + createdOpp);
		}

		return pgiSyncErrors;
	}

	/* TODO : May not need this any more since there looks to be a reference to the insightId on the Opportunity itself. */
	public class InsightToOpportunityWrapper {
		public String insightId;
		public Opportunity opp;
		public String networkIdsForUsers;
		public String insightSysDivBillForAccounts;
		public String userNameForPSRUser;
		public String insightAccountNumberToShipTo;

		public InsightToOpportunityWrapper() {

		}

		public InsightToOpportunityWrapper(String insightKey, Opportunity newOpp) {
			insightId = insightKey;
			opp = newOpp;
		}

	}
}
public with sharing class ZilliantSalesMaxBatchIntegrationServices {
	
	public final static List<String> OPPORTUNITY_ACTIVITY_COLUMNS = new List<String> {
		'customer_insight_key', 'customer_insight_version_key', 'product_grouping_key', 'activity', 'user', 'notes', 'date', 'product_grouping_insight_type'
	};

	public final static Map<String, String> STAGE_NAME_TO_ACTIVITY_MAPPING = new Map<String, String> {
		'8- Closed Won' => 'WON_RESPONSE', '0- Closed Lost' => 'LOST_RESPONSE'
	};

	/* Map to hold Conversion Values for Opportunity Type Field, keyed by SF Opp Type. */
	public static Map<String, String> oppTypeConversionMap_SF_Key = new Map<String, String> {
		'New Opportunity' => 'Cross Sell', 'Defending Existing Business' => 'Lost Sales'
	};

	// Custom Metadata Type used to hold the conversion mapping for the Product Categories picklist.
	/*
	public static Map<String, List<VeritivIQ_ProductGrouping_Prod_Cat_Maps__c>> prodCatMapping_SF_Key
	{
		get
		{
			if(prodCatMapping_SF_Key == NULL)
			{
				prodCatMapping_SF_Key = GroupBy.Strings('Opp_Prod_Categories__c', [SELECT Opp_Prod_Categories__c, ProductGroupingDescValue__c, ProductGroupingKey__c FROM VeritivIQ_ProductGrouping_Prod_Cat_Maps__c]);
			}
			return prodCatMapping_SF_Key;
		}

		set;
	}
	*/

	public ZilliantSalesMaxBatchIntegrationServices() {
	}

	public static String buildQuery_RecentOpportunityActivity()
	{
		String activities = String.join(new List<String>(STAGE_NAME_TO_ACTIVITY_MAPPING.keySet()), '\', \'');
		String activityFilter = '(\'' + activities + '\')';
		VIQ_Last_Successful_Batch_Run_Date__c csLastRun = ZilliantSalesMaxIntegrationServices.csBatchLastRun;
		Integer numOfDaysSinceLastSuccessfulRun = (csLastRun == NULL || csLastRun.Activities_To_Zilliant__c == NULL) 
																		? 7 
																		: csLastRun.Activities_To_Zilliant__c.daysBetween( Date.Today() );
		System.debug('Batch Number Of Days: ' + numOfDaysSinceLastSuccessfulRun);

		String query = 'SELECT' +
					' Id, VIQ_INSIGHT_KEY__C, VIQ_Batch_Audit__c, VIQ_Return_Products__c, VIQ_VERSION_KEY__C, Prod_Category__c, Opportunity_Close_Date__c, StageName, OwnerId, Owner.Network_Id__c, Description, Opportunity_Type__c' +
					' FROM Opportunity' + 
					/* ' WHERE RecordTypeId = \'' + ZilliantSalesMaxIntegrationServices.defaultRT + '\'' + */
					' WHERE StageName IN ' + activityFilter +
					' AND VIQ_Return_Products__c != NULL' + 
					' AND Opportunity_Close_Date__c = LAST_N_DAYS:' + numOfDaysSinceLastSuccessfulRun;

		return query;
	}

	public static String convertOppsToCSV(List<Opportunity> oppsToConvert)
	{
		String convertedOpps = '';
		String oppRow = '';

		for(Opportunity opp : oppsToConvert)
		{

			Integer count = 0;
			List<String> allProdCats = opp.VIQ_Return_Products__c.split(',');
			String selectedProdCat = '';

			do
			{
				selectedProdCat = allProdCats[count];
				oppRow = '';

				oppRow += opp.VIQ_Insight_Key__c != NULL ? (opp.VIQ_Insight_Key__c + ',') : ',';

				oppRow += opp.VIQ_Version_Key__c != NULL ? (opp.VIQ_Version_Key__c + ',') : ',';

				/* Build Product Categories --> Was using Mapping, now using VIQ_Return_Products__c */
				//oppRow += String.isNotBlank(selectedProdCat) && prodCatMapping_SF_Key.containsKey(selectedProdCat) ? (prodCatMapping_SF_Key.get(selectedProdCat)[0].ProductGroupingKey__c + ',') : ' ,';
				oppRow += String.isNotBlank(selectedProdCat) ? selectedProdCat + ',': ',';

				oppRow += opp.StageName != NULL ? (STAGE_NAME_TO_ACTIVITY_MAPPING.get(opp.StageName) + ',') : ',';

				oppRow += opp.Owner.Network_Id__c != NULL ? (opp.Owner.Network_Id__c + ',') : ',';

				oppRow += opp.Description != NULL ? (opp.Description.escapeCsv() + ',') : ',';

				oppRow += opp.Opportunity_Close_Date__c != NULL ? (opp.Opportunity_Close_Date__c.day() + '/' + opp.Opportunity_Close_Date__c.month() + '/' + opp.Opportunity_Close_Date__c.year() + ',') : ',';

				/* TODO : Extra Comma on the End */
				oppRow += opp.Opportunity_Type__c != NULL ? (oppTypeConversionMap_SF_Key.get(opp.Opportunity_Type__c) + ',') : ',';

				convertedOpps += oppRow + '\r\n';

				count++;
			}
			while( count < allProdCats.size() );

		}

		return convertedOpps;
	}

	public static String makeInsertCall(String csvData, String accessToken)
	{
		String bacthJobId = '';

		String csvFile =  String.join( ZilliantSalesMaxBatchIntegrationServices.OPPORTUNITY_ACTIVITY_COLUMNS, ',' );
			   csvFile += '\n';
			   csvFile += csvData;

	    Blob bodyBlob = setupRequestBody(csvFile);

		HttpRequest insertRequest = new HttpRequest();
		insertRequest.setMethod('POST');
		insertRequest.setHeader('Content-Type', 'multipart/form-data');
		insertRequest.setHeader(ZilliantSalesMaxIntegrationServices.AUTHORIZATION_HEADER_KEY, 
		                        ZilliantSalesMaxIntegrationServices.AUTHORIZATION_HEADER_VALUE + accessToken);
		insertRequest.setBodyAsBlob( bodyBlob );
		insertRequest.setEndpoint(ZilliantSalesMaxIntegrationServices.ZILLIANT_BASE_REQUEST_URL + 
		                          '?type=' + ZilliantSalesMaxIntegrationServices.OPPORTUNITY_ACTIVITY_RESOURCE_TYPE + 
		                          '&operation=' + ZilliantSalesMaxIntegrationServices.INSERT_OPERATION_TYPE);
		insertRequest.setTimeout(120000);

		HttpResponse authResponse;

		try
		{
			authResponse = new HTTP().send(insertRequest);
			System.debug(authResponse);
			System.debug( authResponse.getBody());

			if(authResponse.getStatusCode() == ZilliantSalesMaxIntegrationServices.ZIL_RESPONSE_STATUS_OK)
			{
				JSONParser parser = JSON.createParser(authResponse.getBody());
				while(parser.nextToken() != null)
				{
					if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == ZilliantSalesMaxIntegrationServices.ZILLIANT_JOB_ID_KEY)
					{
						parser.nextToken();
						bacthJobId = parser.getText();
						break;
					}
				}
			}
			else
			{
				bacthJobId = NULL;
				
			}
		}
		catch(Exception ex)
		{

		}

		return bacthJobId;
	}

	private static Blob setupRequestBody(String csvData)
	{
		// May have to set boundry in header --> boundary=:boundary
		// https://docparser.com/blog/post-file-salesforce-apex-external-http-webservices/

		String boundary = '--------------SFtoZILLIANT--------------';
		String contentDisposition = 'Content-Disposition: form-data;';
		String namePiece = 'name="file";';
		String fileName = 'filename="OpportunityAcitivty_Date.csv"';
		String contentType = 'Content-Type: multipart/form-data';

		String header = boundary + '\r\n' + contentDisposition + namePiece + fileName + contentType + '\r\n'; // added '\r's removed ';' see Tim Smith's comment
		String footer = '\r\n' + boundary;              
		String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
		while(headerEncoded.endsWith('='))
		{
		    header+=' ';
		    headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
		}
		String bodyEncoded = EncodingUtil.base64Encode(Blob.valueOf(csvData));
		String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));

		Blob bodyBlob = null;
		String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
		if(last4Bytes.endsWith('='))
		{
		    Blob decoded4Bytes = EncodingUtil.base64Decode(last4Bytes);
		    HttpRequest tmp = new HttpRequest();
		    tmp.setBodyAsBlob(decoded4Bytes);
		    String last4BytesFooter = tmp.getBody()+footer;   
		    bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded.substring(0,bodyEncoded.length()-4)+EncodingUtil.base64Encode(Blob.valueOf(last4BytesFooter)));
		}
		else
		{
		    bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
		}

		return bodyBlob;
	}
}
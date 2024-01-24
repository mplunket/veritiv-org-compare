@isTest
private class VIQOpportunityVisualizations_Test {
    
 	static testmethod void getVisualizationJSonTest() 
    {
        String testBody = '{';
        testBody        +=     '"access_token" : "Test Access Token",';
        testBody        +=     '"instance_url" : "http://test.testinstanceurl.com",';
        testBody        +=     '"id" : "test.salesforce.com/testid",';
        testBody        +=     '"token_type" : "Bearer",';
        testBody        +=     '"issued_at" : "1970-01-01",';
        testBody        +=     '"signature" : "Test Access Signature"';
        testBody        += '}';

        ZilliantSalesMaxIntegrationMockApi authResp = new ZilliantSalesMaxIntegrationMockApi();
        authResp.body = testBody;
        authResp.code = ZilliantSalesMaxIntegrationServices.SF_RESPONSE_STATUS_OK;
        Test.setMock(HttpCalloutMock.class, authResp);

		Opportunity opt = new Opportunity(Name='Behind the Cloud', viq_insight_key__c='100');   
        opt.StageName = '3- Project Identified';
        opt.CloseDate = Date.today();
        insert opt;

        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opt);
        VIQOppurtunityVisualizationsController obj = new VIQOppurtunityVisualizationsController(sc);
        //String resultStr = obj.getSalesIqVisualizations();
        //System.Debug('Result='+resultStr);

        Test.stopTest();
        
		//HttpRequest authRequest = authResp.request;
        //System.assertEquals('GET', authRequest.getMethod(), 'We expect the HTTP method to be a GET');
        //String expectedURL = 'https://veritiv.zilliant.com/salesmax/CustomerInsight/v1/100/visualizations';
        //System.assertEquals(expectedURL, authRequest.getEndpoint(), 'We expect the request to go to the proper endpoint');
    }
}
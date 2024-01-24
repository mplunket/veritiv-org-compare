@isTest
private class ZilliantSalesMaxBatchIntegrationTest {

    static void setupOpps(Integer numOfOpps)
    {
        VIQ_Last_Successful_Batch_Run_Date__c lastRunDate = new VIQ_Last_Successful_Batch_Run_Date__c(Activities_To_Zilliant__c = Date.today());
        insert lastRunDate;

        UnitTest.addData((List<Opportunity>) SObjectFactory.build(numOfOpps * 2, Opportunity.SObjectType))
                .tag('All Opps')
                .branch('Matched Opps|Unmatched Opps');

        UnitTest.get('Matched Opps')
                .property('StageName')
                .assignFrom(new List<String>(ZilliantSalesMaxBatchIntegrationServices.STAGE_NAME_TO_ACTIVITY_MAPPING.keySet()))
                .assign('VIQ_Return_Products__c', 'Test Prod')
                .assign('Lost_Date__c', Date.today())
                .assign('Lost_Reason__c', 'Test Reason')
                .assign('Opportunity_Close_Date__c', Date.today());

        UnitTest.get('All Opps').insertAll();
    }

    static void setupAPICreds()
    {
        VIQ_Authentication_Connection__c testAuthData = new VIQ_Authentication_Connection__c(App_Consumer_Key__c = 'Test Key',
        App_Consumer_Secret__c = 'Test Secret', Zilliant_URL__c = ZilliantSalesMaxIntegrationMockApi.TEST_ZILLIANT_URL);
        insert testAuthData;

        ZilliantSalesMaxIntegrationServices.csZilToSFCreds = testAuthData;
        ZilliantSalesMaxIntegrationServices.CONSUMER_KEY = testAuthData.App_Consumer_Key__c;
        ZilliantSalesMaxIntegrationServices.CONSUMER_SECRET = testAuthData.App_Consumer_Secret__c;
        ZilliantSalesMaxIntegrationServices.ZILLIANT_BASE_REQUEST_URL = testAuthData.Zilliant_URL__c;
    }
    
    static testMethod void ZilliantSalesMaxBatchIntegrationExecutionTest()
    {
        setupAPICreds();
        setupOpps(100);
        ZilliantSalesMaxIntegrationMockApi jobResponse = new ZilliantSalesMaxIntegrationMockApi();
        Test.setMock(HttpCalloutMock.class, jobResponse);

        Test.startTest();
        Database.executeBatch(new ZilliantSalesMaxBatchIntegration());
        try
        {
            Test.stopTest();
            System.assert(false, 'We expect the status job to be queued and a test error to be thrown');
        }
        catch(Exception e)
        {
        }

        List<Error_Log__c> errorLogs = [SELECT Id, Error_Code__c, Error_Message__c FROM Error_Log__c];
        System.assertEquals(0, errorLogs.size(), 'We expect no new error logs to be generated: ' + errorLogs);
    }

    static testMethod void ZilliantSalesMaxBatchIntegrationScheduableTest()
    {
        Test.startTest();
        String CRON_EXP = '0 0 0 15 10 ? ' + Date.today().addYears(1).year();
            String jobId = System.schedule('Zilliant Batch',
                       CRON_EXP, 
                       new ZilliantSalesMaxBatchIntegration());
        Test.stopTest();
    }

    static testMethod void buildQuery_RecentOpportunityActivityTest()
    {
        Integer numOfOpps = 5;
        setupOpps(numOfOpps);

        Test.startTest();
            String query = ZilliantSalesMaxBatchIntegrationServices.buildQuery_RecentOpportunityActivity();
        Test.stopTest();

        List<Opportunity> returnedOpps = Database.query(query);
        UnitTest.analyze('Matched Opps').assertEquivalence(returnedOpps, 'We expect the query to return opporutnities with the proper criteria');
    }
    
    static testMethod void convertOppsToCSVTest()
    {
        String testInsightKey = 'Test Insight Key';
        String testVerKey = 'Test Ver Key';
        String testProduct = 'Test Prod';
        String testStageName = new List<String>(ZilliantSalesMaxBatchIntegrationServices.STAGE_NAME_TO_ACTIVITY_MAPPING.keySet())[0];
        String testOwnerNId = '';
        String testDescription = 'Test Description';
        Date testCloseDate = Date.today();
        String testOppType = new List<String>(ZilliantSalesMaxBatchIntegrationServices.oppTypeConversionMap_SF_Key.keySet())[0];

        Opportunity oppToBeConverted = new Opportunity(VIQ_Return_Products__c = testProduct,
                                                       VIQ_Insight_Key__c = testInsightKey,
                                                       VIQ_Version_Key__c = testVerKey,
                                                       StageName = testStageName,
                                                       Description = testDescription,
                                                       Opportunity_Close_Date__c = testCloseDate,
                                                       Opportunity_Type__c = testOppType);
        Test.startTest();
            String csvRow = ZilliantSalesMaxBatchIntegrationServices.convertOppsToCSV(new List<Opportunity> {oppToBeConverted});
        Test.stopTest();

        List<String> rowValues = csvRow.split(',');
        for(Integer i = 0; i < ZilliantSalesMaxBatchIntegrationServices.OPPORTUNITY_ACTIVITY_COLUMNS.size(); i++)
        {
            String colName = ZilliantSalesMaxBatchIntegrationServices.OPPORTUNITY_ACTIVITY_COLUMNS[i];
            if(colName == 'customer_insight_key')
            {
                System.assertEquals(testInsightKey, rowValues[i], 'We expect the value at index ' + i + ' to be the insight key');
            }
            
            else if(colName == 'customer_insight_version_key')
            {
                System.assertEquals(testVerKey, rowValues[i], 'We expect the value at index ' + i + ' to be the version key');
            }
            
            else if(colName == 'product_grouping_key')
            {
                System.assertEquals(testProduct, rowValues[i], 'We expect the value at index ' + i + ' to be the grouping key');
            }
            
            else if(colName == 'activity')
            {
                System.assertEquals(ZilliantSalesMaxBatchIntegrationServices.STAGE_NAME_TO_ACTIVITY_MAPPING.get(testStageName), rowValues[i], 'We expect the value at index ' + i + ' to be the activity');
            }
            
            else if(colName == 'user')
            {
                System.assertEquals(testOwnerNId, rowValues[i], 'We expect the value at index ' + i + ' to be the owner network id');
            }
            
            else if(colName == 'notes')
            {
                System.assertEquals(testDescription, rowValues[i], 'We expect the value at index ' + i + ' to be the description');
            }
            
            else if(colName == 'date')
            {
                String dateString = testCloseDate.day() + '/' + testCloseDate.month() + '/' + testCloseDate.year();
                System.assertEquals(dateString, rowValues[i], 'We expect the value at index ' + i + ' to be the close date');
            }
            
            else if(colName == 'product_grouping_insight_type')
            {
                System.assertEquals(ZilliantSalesMaxBatchIntegrationServices.oppTypeConversionMap_SF_Key.get(testOppType), rowValues[i], 'We expect the value at index ' + i + ' to be the product grouping key');
            }
        }
    }


    static testMethod void makeInsertCallTest()
    {
        setupAPICreds();
        String testOAuthToken = 'Test Oauth Token';

        ZilliantSalesMaxIntegrationMockApi jobResponse = new ZilliantSalesMaxIntegrationMockApi();
        Test.setMock(HttpCalloutMock.class, jobResponse);

        Test.startTest();
            String actualBatchId = ZilliantSalesMaxBatchIntegrationServices.makeInsertCall('', testOAuthToken);
        Test.stopTest();

        HttpRequest jobRequest = jobResponse.request;
        System.assertEquals(jobRequest.getHeader('Authorization'), 'OAuth ' + testOAuthToken,
                            'We expect the authorization header to be set correctly');
        System.assertEquals(ZilliantSalesMaxIntegrationMockApi.TEST_BATCH_ID, actualBatchId, 'We expect the method to retrieve the proper batch Id');
    }
}
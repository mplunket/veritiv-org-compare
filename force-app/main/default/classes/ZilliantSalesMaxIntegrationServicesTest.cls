@isTest
private class ZilliantSalesMaxIntegrationServicesTest 
{
    static List<String> testNetworkIds = new List<String>();
    static List<String> testSysDivBilTo = new List<String>();
    static List<String> testShipToCodes = new List<String>();
    static List<String> testInsightIds = new List<String>();
    static List<String> testVersionKeys = new List<String>();
    static List<String> testClusterIds = new List<String>();

    static List<String> testAmounts = new List<String>();
    static List<String> testPgOppTypes = new List<String>();

    static void setupInsights(Integer numOfInsights)
    {
        List<String> clusterSegments = new List<String>(ZilliantSalesMaxIntegrationServices.prodSegmentMapping.keySet());

        for(Integer i = 1; i <= numOfInsights; i++)
        {
            testNetworkIds.add('nId' + i);
            testSysDivBilTo.add('Test Sys ' + i);
            testShipToCodes.add('Test ShipTo ' + i);
            testInsightIds.add('Test Insight Id ' + i);
            testVersionKeys.add('Test Version Key ' + i);
            testClusterIds.add(clusterSegments[Math.mod(i, clusterSegments.size())]);
        }
        UnitTest.addData((List<User>) SObjectFactory.build(numOfInsights, User.SObjectType))
                .tag('All Users')
                .property('Alias')
                .assignFrom(testNetworkIds)
                .property('Network_Id__c')
                .assignFrom(testNetworkIds)
                .insertAll();

        UnitTest.addData((List<Primary_Sales_Rep__c>) SObjectFactory.build(numOfInsights, Primary_Sales_Rep__c.SObjectType))
                .tag('All PSRs')
                .property('Network_Id__c')
                .assignFrom(testNetworkIds)
                .insertAll();

        UnitTest.addData((List<Account>) SObjectFactory.build(numOfInsights, Account.SObjectType))
                .tag('All Accounts')
                .property('AccountNumber')
                .assignFrom(testSysDivBilTo)
                .insertAll();

        UnitTest.addData((List<Ship_To__c>) SObjectFactory.build(numOfInsights, Ship_To__c.SObjectType, Ship_To__c.Name, 'Test ShipTo'))
                .tag('All ShipTos')
                .property('Ship_To_Code__c')
                .assignFrom(testShipToCodes)
                .property('Bill_To_Account__c')
                .assignFrom('All Accounts')
                .insertAll();

    }

    static void setupProdInsights(Integer numOfInsights)
    {
        List<String> oppTypes = new List<String>(ZilliantSalesMaxIntegrationServices.oppTypeConversionMap.keySet());
        List<VeritivIQ_ProductGrouping_Prod_Cat_Maps__c> groupingTypes = new List<VeritivIQ_ProductGrouping_Prod_Cat_Maps__c>();
        for(Integer i = 1; i <= numOfInsights; i++)
        {
            testAmounts.add(String.valueOf(i * 10));
            testInsightIds.add('Test Insight Id ' + i);
            testPgOppTypes.add(oppTypes[Math.mod(i, oppTypes.size())]);
            
            Map<String, Object> metadataFields = new Map<String, Object>{
                'ProductGroupingKey__c' => String.valueOf(i),
                'Opp_Prod_Categories__c' => 'TEST_CAT' + i,
                'ProductGroupingDescValue__c' => 'TEST CAT' + i
            };

           SObject metadataType = JSONUtils.createSObject(VeritivIQ_ProductGrouping_Prod_Cat_Maps__c.getSObjectType(), metadataFields);
           groupingTypes.add((VeritivIQ_ProductGrouping_Prod_Cat_Maps__c) metadataType);
        }
        ZilliantSalesMaxIntegrationServices.prodCatMapping = GroupBy.Strings('ProductGroupingKey__c', groupingTypes);
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

    static String buildCSV(Set<String> fieldNames, List<Map<String, String>> rows)
    {
        List<String> fieldNamesList = new List<String>(fieldNames);
        String csvData = String.join(fieldNamesList, ',');

        for(Map<String, String> row : rows)
        {
            List<String> rowValues = new List<String>();
            for(String fieldName : fieldNamesList)
            {
                if(row.containsKey(fieldName))
                {
                    rowValues.add(row.get(fieldName));
                }
                else
                {
                    rowValues.add('');
                }
            }
            csvData += '\n' + String.join(rowValues, ',');
        }

        return csvData;
    }

    static testMethod void getSalesMaxAuthorizationStringTest_Success() 
    {
        setupAPICreds();
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

        Test.startTest();
            String authorizationKey = ZilliantSalesMaxIntegrationServices.getSalesMaxAuthorizationString();
        Test.stopTest();

        List<Error_Log__c> errors = [SELECT Id, Error_Code__c, Error_Message__c FROM Error_Log__c];
        System.assertEquals(0, errors.size(), 'We expect no errors to be created: ' + errors);

        HttpRequest authRequest = authResp.request;
        System.assertEquals('POST', authRequest.getMethod(), 'We expect the HTTP method to be a POST');
        System.assertNotEquals(NULL, authRequest.getBody(), 'We expect the authRequestuest to have a payload');
        System.assertEquals(ZilliantSalesMaxIntegrationServices.AUTH_URL, authRequest.getEndpoint(), 'We expect the request to go to the proper endpoint');

        System.assertEquals(testBody, EncodingUtil.base64Decode(authorizationKey).toString(), 'We expect the returned key to decode to the test our test json');
    }
    
    static testMethod void getSalesMaxAuthorizationStringTest_Error()
    {
        String testBody  = '{';
        testBody        +=     '"error": "invalid_grant_type",';
        testBody        +=     '"message": "Authorization failure"';
        testBody        += '}';

        ZilliantSalesMaxIntegrationMockApi authResponse = new ZilliantSalesMaxIntegrationMockApi();
        authResponse.body = testBody;
        authResponse.code = ZilliantSalesMaxIntegrationServices.SF_RESPONSE_STATUS_ERROR;
        Test.setMock(HttpCalloutMock.class, authResponse);

        Test.startTest();
            String authorizationKey = ZilliantSalesMaxIntegrationServices.getSalesMaxAuthorizationString();
        Test.stopTest();

        System.assertEquals(NULL, authorizationKey, 'We expect the authorization key to be null upon auth failure'); 
    }   
    
    static testMethod void getSalesMax_QueryBatchIdTest_Success()
    {
        String testOAuthToken = 'Test Oauth Token';
        String testRequestString = 'Test Request String';
        String testResourceType = 'Test Resource Type';
        String testOperationType = 'Test Operation Type';
        String testBatchId = 'Speed Test Id';

        String testBody  = '{';
        testBody        +=     '"bulkDataJobId": "' + testBatchId + '",';
        testBody        +=     '"status": "Submitted"';
        testBody        += '}';

        ZilliantSalesMaxIntegrationMockApi jobResponse = new ZilliantSalesMaxIntegrationMockApi();
        jobResponse.body = testBody;
        jobResponse.code = ZilliantSalesMaxIntegrationServices.ZIL_RESPONSE_STATUS_OK;
        Test.setMock(HttpCalloutMock.class, jobResponse);

        Test.startTest();
            String actualBatchId = ZilliantSalesMaxIntegrationServices.getSalesMax_QueryBatchId(testOAuthToken, testRequestString, testResourceType, testOperationType);
        Test.stopTest();

        HttpRequest jobRequest = jobResponse.request;
        System.assertEquals(jobRequest.getHeader('Authorization'), 'OAuth ' + testOAuthToken,
                            'We expect the authorization header to be set correctly');
        System.assertEquals(testBatchId, actualBatchId, 'We expect the method to retrieve the proper batch Id');
    }

    static testMethod void getSalesMax_QueryBatchIdTest_FailureCode()
    {
        String testOAuthToken = 'Test Oauth Token';
        String testRequestString = 'Test Request String';
        String testResourceType = 'Test Resource Type';
        String testOperationType = 'Test Operation Type';
        String testBatchId = 'Speed Test Id';

        String testBody  = '{';
        testBody        +=     '"message": "This was a failure",';
        testBody        += '}';

        ZilliantSalesMaxIntegrationMockApi jobResponse = new ZilliantSalesMaxIntegrationMockApi();
        jobResponse.body = testBody;
        jobResponse.code = 404;
        Test.setMock(HttpCalloutMock.class, jobResponse);

        Test.startTest();
            String actualBatchId = ZilliantSalesMaxIntegrationServices.getSalesMax_QueryBatchId(testOAuthToken, testRequestString, testResourceType, testOperationType);
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Error_Log__c], 'We expect a new error log to be created');
        System.assertEquals(NULL, actualBatchId, 'We expect the method to return null');
    }

    static testMethod void getSalesMax_StatusTest_Success()
    {
        String testOAuthToken = 'Test Token';
        String testBatchId = 'Test Id';
        String testStatus = 'TEST_COMPLETED_STATUS';

        String testBody  = '{';
        testBody        +=     '"Status": "' + testStatus + '"';
        testBody        += '}';

        ZilliantSalesMaxIntegrationMockApi statusResponse = new ZilliantSalesMaxIntegrationMockApi();
        statusResponse.body = testBody;
        statusResponse.code = ZilliantSalesMaxIntegrationServices.ZIL_RESPONSE_STATUS_OK;
        Test.setMock(HttpCalloutMock.class, statusResponse);

        Test.startTest();
            String status = ZilliantSalesMaxIntegrationServices.getSalesMax_Status(testOAuthToken, testBatchId);
        Test.stopTest();

        HttpRequest statusRequest = statusResponse.request;
        System.assertEquals(statusRequest.getHeader('Authorization'), 'OAuth ' + testOAuthToken,
                            'We expect the authorization header to be set correctly');

        System.assertEquals(statusRequest.getEndpoint(), 
                            ZilliantSalesMaxIntegrationServices.ZILLIANT_BASE_REQUEST_URL + '/' + testBatchId + '/' + ZilliantSalesMaxIntegrationServices.STATUS_ENDPOINT,
                            'We expect the request endpoint to use the batchId');

        System.assertEquals(testStatus, status, 'We expect the method to retrieve the proper status');
    }

    static testMethod void getSalesMax_ResultTest_Success()
    {
        String testBody = '{ "Response": "This is a test." }';
        String testOAuthToken = 'Test Auth Token';
        String testBatchId = 'Test Job Id';

        ZilliantSalesMaxIntegrationMockApi resultResponse = new ZilliantSalesMaxIntegrationMockApi();
        resultResponse.body = testBody;
        resultResponse.code = ZilliantSalesMaxIntegrationServices.ZIL_RESPONSE_STATUS_OK;
        Test.setMock(HttpCalloutMock.class, resultResponse);

        Test.startTest();
            String results = ZilliantSalesMaxIntegrationServices.getSalesMax_Result(testOAuthToken, testBatchId);
        Test.stopTest();

        HttpRequest resultRequest = resultResponse.request;
        System.assertEquals(resultRequest.getHeader('Authorization'), 'OAuth ' + testOAuthToken,
                    'We expect the authorization header to be set correctly');

        System.assertEquals(resultRequest.getEndpoint(), 
                    ZilliantSalesMaxIntegrationServices.ZILLIANT_BASE_REQUEST_URL + '/' + testBatchId + '/' + ZilliantSalesMaxIntegrationServices.RESULT_ENDPOINT,
                    'We expect the request endpoint to use the batchId');

        System.assertEquals(testBody, results, 'We expect the method to turn the body of the request');
    }

    static testMethod void getSalesMax_ResultTest_Exception()
    {
        String testBody = '{ "Response": "This is a test." }';
        String testOAuthToken = 'Test Auth Token';
        String testBatchId = 'Test Job Id';

        ZilliantSalesMaxIntegrationMockApi resultResponse = new ZilliantSalesMaxIntegrationMockApi();
        resultResponse.throwException = true;
        resultResponse.body = testBody;
        resultResponse.code = ZilliantSalesMaxIntegrationServices.ZIL_RESPONSE_STATUS_OK;
        Test.setMock(HttpCalloutMock.class, resultResponse);

        Test.startTest();
            String results = ZilliantSalesMaxIntegrationServices.getSalesMax_Result(testOAuthToken, testBatchId);
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Error_Log__c], 'We expect an error log to be generated');
        System.assertEquals(NULL, results, 'We expect the method to return null');
    }

    static testMethod void buildQueryCriteria_Test()
    {
        List<String> testCriteria = new List<String>{ 'Test_1', 'Test_2', 'Test_3' };
        String resultCriteria = '{';
        resultCriteria      += '"limit": ' + ZilliantSalesMaxIntegrationServices.ZIL_QUERY_LIMIT + ',';
        resultCriteria      +=  '"filters": {';
        resultCriteria      +=      '"CustomerInsightKey": ["Test_1", "Test_2", "Test_3"]';
        resultCriteria      +=  '}';
        resultCriteria       += '}';

        Test.startTest();
            String queryCriteria = ZilliantSalesMaxIntegrationServices.buildQueryCriteria(testCriteria);
        Test.stopTest();

        System.assertEquals(resultCriteria, queryCriteria, 'We expect the filter options to match.');
        /*
        JSONParser parser = JSON.createParser(queryCriteria);
        while(parser.nextToken() != null)
        {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'CustomerInsightKey')
            {
                parser.nextToken();
                queryLimit = parser.getIntegerValue();
                break;
            }
        }
        */

        //TODO: WRITE BETTER ASSERTS
        //System.assertEquals(ZilliantSalesMaxIntegrationServices.ZIL_QUERY_LIMIT, queryLimit, 'We expect the limit to be set correctly through JSON');
    }

    static testMethod void buildInsightCriteria_Test()
    {
        String testCriteria = 'Test_1';
        String resultCriteria = '{';
        resultCriteria      += '"limit": ' + ZilliantSalesMaxIntegrationServices.ZIL_QUERY_LIMIT + ',';
        resultCriteria      +=  '"filters": {';
        resultCriteria      +=      '"CustomerInsightStatus": ["PURSUING"],'; //Filters
        resultCriteria      +=      '"CustomerInsightLastModifiedDate": ["Test_1"]';
        resultCriteria      +=  '}';
        resultCriteria       += '}';

        Test.startTest();
            String queryCriteria = ZilliantSalesMaxIntegrationServices.buildInsightsCriteria(testCriteria);
        Test.stopTest();

        System.assertEquals(resultCriteria, queryCriteria, 'We expect the filter options to match.');
    }

    static testMethod void parseCSV_Test()
    {
        String testColumn1 = 'Speedkicks Test 1';
        String testColumn2 = 'Speedkicks Test 2';
        String testField1 = 'Test Field 1';
        String testField2 = 'Test Field 2';

        Set<String> testColumns = new Set<String> {testColumn1, testColumn2};
        String testData = String.format('{0},{1}\n{2}, {3}', 
                                        new List<String> {testColumn1, testColumn2, testField1, testField2});

        Test.startTest();
            List<Map<String, String>> parsedCSV = ZilliantSalesMaxIntegrationServices.parseCSV(testData, testColumns);
        Test.stopTest();

        Map<String, String> actualRow = parsedCSV[0];
        System.assertEquals(testField1, actualRow.get(testColumn1), 'We expect the correct value to be retrieved by key');
        System.assertEquals(testField2, actualRow.get(testColumn2), 'We expect the value to be properly trimmed');
    }

    static testMethod void parseInsights_Test_Failure()
    {
        List<ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper> oppWrappers = new List<ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper>();
        String testData = 'Test String';

        oppWrappers.add( new ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper() );

        Test.startTest();
            ZilliantSalesMaxIntegrationServices.parse_Insights(oppWrappers, testData);
        Test.stopTest();


    }

    static testMethod void parse_InsightsTest_Success()
    {
        Integer numOfInsights = 5;
        setupInsights(numOfInsights);

        Set<String> fieldNames = ZilliantSalesMaxIntegrationServices.insightFieldColumns;
        List<Map<String, String>> rows = new List<Map<String, String>>();
        for(Integer i = 0; i < numOfInsights; i++)
        {
            Map<String, String> row = new Map<String, String>();
            row.put('CustomerInsightKey', testInsightIds[i]);
            row.put('CustomerInsightVersionKey', testVersionKeys[i]);
            row.put('Username', testNetworkIds[i]);
            row.put('AccountNumber', testSysDivBilTo[i] + '/' + testShipToCodes[i]);
            row.put('ClusterSegmentId', testClusterIds[i]);
            rows.add(row);
        }
        String testData = buildCSV(fieldNames, rows);
        
        /* Pass CSV Data to Method. */
        List<ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper> oppWrappers = new List<ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper>();
        Test.startTest();
            List<Error_Log__c> resultErrors = ZilliantSalesMaxIntegrationServices.parse_Insights(oppWrappers, testData);
        Test.stopTest();
        
        System.assertEquals(0, resultErrors.size(), 'We expect no error logs to be generated: ' + resultErrors);
        /* Validate that Opportunity on Wrapprs has pre-set data populate. */
        System.assertEquals(numOfInsights, oppWrappers.size() , 'We expect the wrapper list to be populated');

        Set<String> insightIdSet = new Set<String>(testInsightIds);
        Set<String> versionKeySet = new Set<String>(testVersionKeys);
        Map<Id, List<User>> userMap = GroupBy.Ids('Id', UnitTest.get('All Users').getList());
        Map<Id, List<Account>> accountMap = GroupBy.Ids('Id', UnitTest.get('All Accounts').getList());
        Map<Id, List<Primary_Sales_Rep__c>> psrMap = GroupBy.Ids('Id', UnitTest.get('All PSRs').getList());

        for(ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper oppWrapper : oppWrappers)
        {

            System.assert(insightIdSet.contains(oppWrapper.insightId) && insightIdSet.contains(oppWrapper.opp.VIQ_Insight_Key__c),
                          'We expect the insight key to be set properly');
            
            System.assert(versionKeySet.contains(oppWrapper.opp.VIQ_VERSION_KEY__c), 'We expect the version key to be set properly');

            User owner = userMap.get(oppWrapper.opp.OwnerId)[0];
            System.assertNotEquals(null, owner, 'We expect the OwnerId to be set correctly');
            System.assertEquals(owner.Network_Id__c, oppWrapper.networkIdsForUsers, 'We expect the networkIdsForUsers to match the Network Id');

            Account relatedAccount = accountMap.get(oppWrapper.opp.AccountId)[0];
            System.assertNotEquals(null, relatedAccount, 'We expect the AccountID to be set correctly');
            System.assertEquals(relatedAccount.AccountNumber, oppWrapper.insightSysDivBillForAccounts, 'We expect the sysDivBillForAccounts to match the AccountNumber field');

            Primary_Sales_Rep__c psr = psrMap.get(oppWrapper.opp.Primary_Sales_Rep_Name__c)[0];
            System.assertNotEquals(null, psr, 'We expect the PSR name to be set correctly');
            System.assertEquals(psr.Id, oppWrapper.opp.Primary_Sales_Rep_Name__c, 'We expect the PSR lookup on the Opportunity to be set to the PSR id');

            
        }


    }

    static testMethod void parse_ProductGroupingInsightsTest_Success()
    {
        Integer numOfInsights = 5;
        setupProdInsights(numOfInsights);

        List<ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper> oppWrappers = new List<ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper>();
        List<Map<String, String>> rows = new List<Map<String, String>>();
        List<String> prodGroupingKeys = new List<String>(ZilliantSalesMaxIntegrationServices.prodCatMapping.keySet());

        for(Integer i = 0; i < numOfInsights; i++)
        {
            Map<String, String> row = new Map<String, String>();
            row.put('CustomerInsightKey', testInsightIds[i]);
            row.put('Amount', testAmounts[i]);
            row.put('ProductGroupingKey', prodGroupingKeys[Math.mod(i, numOfInsights)]);
            row.put('ProductGroupingOpportunityType', testPgOppTypes[i]);
            rows.add(row);

            oppWrappers.add(new ZilliantSalesMaxIntegrationServices.InsightToOpportunityWrapper(testInsightIds[i], new Opportunity()));
        }

        String testData = buildCSV(ZilliantSalesMaxIntegrationServices.productGroupingInsightFieldColumns, rows);

        Test.startTest();
            List<Error_Log__c> parseErrors = ZilliantSalesMaxIntegrationServices.parse_ProductGroupingInsights(oppWrappers, testData);
        Test.stopTest();

        System.assertEquals(0, parseErrors.size(), 'We expect no errors to be generated: ' + parseErrors);

    }

    static testMethod void areResultsEmptyTest_Empty()
    {
        List<String> insightFieldColumns = new List<String>(ZilliantSalesMaxIntegrationServices.insightFieldColumns);
        List<String> prodGroupingInsightFieldColumns = new List<String>(ZilliantSalesMaxIntegrationServices.productGroupingInsightFieldColumns);
        List<String> opportunityActivityFieldColumns = new List<String>(ZilliantSalesMaxIntegrationServices.opportunityActivityFieldColumns);

        Test.startTest();
            Boolean insightsEmpty = ZilliantSalesMaxIntegrationServices.areResultsEmpty(String.join(insightFieldColumns, ','), ZilliantSalesMaxIntegrationServices.CUSTOMER_INSIGHT_RESOURCE_TYPE);
            Boolean pgEmpty = ZilliantSalesMaxIntegrationServices.areResultsEmpty(String.join(prodGroupingInsightFieldColumns, ','), ZilliantSalesMaxIntegrationServices.PRODUCT_GROUPING_INSIGHT_RESOURCE_TYPE);
            Boolean opActivityEmpty = ZilliantSalesMaxIntegrationServices.areResultsEmpty(String.join(opportunityActivityFieldColumns, ','), ZilliantSalesMaxIntegrationServices.OPPORTUNITY_ACTIVITY_RESOURCE_TYPE);
        Test.stopTest();

        System.assert(insightsEmpty, 'We expect insightsEmpty to be true');
        System.assert(pgEmpty, 'We expect pgEmpty to be true');
        System.assert(opActivityEmpty, 'We expect opActivityEmpty to be true');
    }

    static testMethod void areResultsEmptyTest_Filled()
    {
        List<String> insightFieldColumns = new List<String>(ZilliantSalesMaxIntegrationServices.insightFieldColumns);
        List<String> insightRowValues = new List<String>();
        for(String insightField : insightFieldColumns)
        {
            insightRowValues.add('Test ' + insightField);
        }

        String insightsCSV = String.join(insightFieldColumns, ',') + '\n' + String.join(insightRowValues, ',');

        Test.startTest();
            Boolean insightsEmpty = ZilliantSalesMaxIntegrationServices.areResultsEmpty(insightsCSV, ZilliantSalesMaxIntegrationServices.CUSTOMER_INSIGHT_RESOURCE_TYPE);
        Test.stopTest();

        System.assert(!insightsEmpty, 'We expect insightsEmpty to be false');
    }

    static testMethod void createErrorRecordTest_Success()
    {
        //Code 99 allows for custom message assignment
        String testCode = '99';
        String testMessage = 'This error is a test';
        String testInsightKey = 'Test Insight Key';

        Test.startTest();
            ZilliantSalesMaxIntegrationServices.createErrorRecord(testCode, testMessage, testInsightKey);
        Test.stopTest();

        List<Error_Log__c> errorLogs = [SELECT Error_Code__c, Error_Message__c, VIQ_Insight_Key_Error__c FROM Error_Log__c];
        System.assertEquals(1, errorLogs.size(), 'We expect only one error log to be created');

        Error_Log__c errorLog = errorLogs[0];
        System.assertEquals(testCode, errorLog.Error_Code__c, 'We expect the inserted code to equal the test code');
        System.assertEquals(testMessage, errorLog.Error_Message__c, 'We expect the inserted message to equal the test message');
        System.assertEquals(testInsightKey, errorLog.VIQ_Insight_Key_Error__c, 'We expect the inserted insight key to equal the test insight key');
    }

}
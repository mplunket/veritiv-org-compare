@isTest
private class SAPTokenRefreshTest {
	
    private static SAP_BI_Reports_Setting__c testSAPSetting;
    private static final String UPDATED_TOKEN = 'test New Token';
    private static final String ENCODED_TOKEN = 'test+New+Token';

    static void initSAPSetting() {
        testSAPSetting = new SAP_BI_Reports_Setting__c();

        testSAPSetting.Auth__c = 'testAuth';
        testSAPSetting.Username__c = 'testUser';
        testSAPSetting.Password__c = 'testPass';
        testSAPSetting.Document_Id__c = 'testDocId';
        testSAPSetting.Login_URL__c = 'http://testapi.com/login';
        testSAPSetting.SAP_Login_Token__c = 'testOldToken';
        testSAPSetting.SAP_Login_Token_Last_Update__c = DateTime.now();
        testSAPSetting.SAP_Report_Base_URL__c = 'http://testsapurl.com';

        insert testSAPSetting;
    }

    @isTest
    static void testRefreshJobSuccess() {
        initSAPSetting();

        Test.setMock(HttpCalloutMock.class, new RefreshResponse(200, 'test New Token'));

        Test.startTest();
            System.enqueueJob(new SAPTokenRefresh.RefreshJob());
        Test.stopTest();

        SAP_BI_Reports_Setting__c updatedSetting = [SELECT SAP_Login_Token__c, Encoded_Token__c, 
			Encoded_Token_Overflow__c FROM SAP_BI_Reports_Setting__c WHERE Id = :testSAPSetting.Id];
        
        System.assertEquals(updatedSetting.SAP_Login_Token__c, UPDATED_TOKEN, 'We expect the token to be updated');
        System.assertEquals(updatedSetting.Encoded_Token__c, ENCODED_TOKEN, 'We expect the encoded token to be updated and encoded');
        System.assert(String.isBlank(updatedSetting.Encoded_Token_Overflow__c), 
			'We expect the overflow field to not be used when encoded token does not overflow.');
    }
    
    @isTest
    static void testRefreshJobException() {
        initSAPSetting();

        String testEmail = 'test@email.com';
        User testUser = (User) SObjectFactory.create(User.SObjectType, User.Email, testEmail);

        Apex_Class_Error_Emails__c emailSetting = new Apex_Class_Error_Emails__c(Name='Test', User_ID__c=testUser.Id);
        insert emailSetting;

        RefreshResponse calloutRes = new RefreshResponse(200, 'test New Token');
        calloutRes.fail = true;

        SAPTokenRefresh.RefreshJob refreshJob = new SAPTokenRefresh.RefreshJob();
        Test.startTest();
            System.enqueueJob(refreshJob);
        Test.stopTest();

        System.assertEquals(testEmail, refreshJob.emailsForErrors[0], 'We expect the email address to be set from the custom setting');
        System.assertEquals(1, refreshJob.emailsForErrors.size(), 'We expect there to only be one email address');
    }
    
    @isTest
    static void testRefreshJobLongTokenSplitting() {
        // This token is exactly 255 characters for testing the encoding exceeding that amount
        final String LONG_TOKEN = 'AAAAAAAAAA:9999@{9&9=999999,A9&9A=AAAAAAAAAA:9999,AA&99=9999,A9&99=AAAAAAAAAAAA:AAAAAAAAAAA,'
            + 'AAA&A999=9999999999,A9&99=999,A9&AAAAA=AAAAAAAAAAAAAAAAAAAAAAAAAAA9999999999999999999999999AAAAAAAAAAAAAAAAA'
            + '999999999999999999999AAAAAAAAAAAAAAAAA9999999999999999}';
        
        initSAPSetting();

        Test.setMock(HttpCalloutMock.class, new RefreshResponse(200, LONG_TOKEN));

        Test.startTest();
            System.enqueueJob(new SAPTokenRefresh.RefreshJob());
        Test.stopTest();

        SAP_BI_Reports_Setting__c updatedSetting = [SELECT SAP_Login_Token__c, Encoded_Token__c, 
			Encoded_Token_Overflow__c FROM SAP_BI_Reports_Setting__c WHERE Id = :testSAPSetting.Id];

        System.assertEquals(updatedSetting.SAP_Login_Token__c, LONG_TOKEN, 'We expect the token to be updated');
        System.assertEquals(updatedSetting.Encoded_Token__c.length(), 255, 
			'We expect the encoded token be updated and 255 characters long.');
        System.assertEquals(updatedSetting.Encoded_Token_Overflow__c.length(), 52, 
			'We expect the overflow on the encoded token to populate this field.');
        
        String decodedToken = EncodingUtil.urlDecode(updatedSetting.Encoded_Token__c + updatedSetting.Encoded_Token_Overflow__c, 'UTF-8');
        System.assertEquals(decodedToken, LONG_TOKEN, 'The result of the decode should evaluate to the original token.');
    }

    @isTest
    static void testRefreshJobEcondedTokenOverflowReset() {        
        initSAPSetting();

        SAP_BI_Reports_Setting__c updatedSetting = [SELECT SAP_Login_Token__c, Encoded_Token__c, 
			Encoded_Token_Overflow__c FROM SAP_BI_Reports_Setting__c WHERE Id = :testSAPSetting.Id];

        updatedSetting.Encoded_Token__c = 'not+Test+New+Token';
        updatedSetting.Encoded_Token_Overflow__c = 'not+Test+New+Token+Overflow';

        update updatedSetting;

        Test.setMock(HttpCalloutMock.class, new RefreshResponse(200, 'test New Token'));

        Test.startTest();
            System.enqueueJob(new SAPTokenRefresh.RefreshJob());
        Test.stopTest();

        updatedSetting = [SELECT SAP_Login_Token__c, Encoded_Token__c, 
			Encoded_Token_Overflow__c FROM SAP_BI_Reports_Setting__c WHERE Id = :testSAPSetting.Id];

        System.assertEquals(updatedSetting.SAP_Login_Token__c, 'test New Token', 'We expect the token to be updated to a shorter token');
        System.assertEquals(updatedSetting.Encoded_Token__c, 'test+New+Token', 
			'We expect the encoded token to be updated and short.');
        System.assert(String.isEmpty(updatedSetting.Encoded_Token_Overflow__c), 'We expect the encoded token overflow to be emptied');
    }

    private class RefreshResponse implements HttpCalloutMock {
        public Boolean fail = false;
        public Integer status;
        public String token;
        
        public RefreshResponse(Integer responseStatus, String responseToken) {
            this.status = responseStatus;
            this.token = responseToken;
        }

        public HTTPResponse respond(HTTPRequest req) {
            if(fail) {
                throw new CalloutException();
            }

            HTTPResponse res = new HTTPResponse();

            Map<String, String> reqBody = (Map<String, String>) JSON.deserialize(req.getBody(), Map<String, String>.class);

            System.assertEquals(reqBody.get('userName'), testSAPSetting.Username__c, 'We expect the username to match the custom setting');
            System.assertEquals(reqBody.get('password'), testSAPSetting.Password__c, 'We expect the password to match the custom setting');
            System.assertEquals(reqBody.get('auth'), testSAPSetting.Auth__c, 'We expect the auth to match the custom setting');

            Map<String, String> resBody = new Map<String, String>();
            resBody.put('logonToken', this.token);
            res.setStatusCode(this.status);
            res.setBody(JSON.serialize(resBody));
            return res;
        }
    }
}
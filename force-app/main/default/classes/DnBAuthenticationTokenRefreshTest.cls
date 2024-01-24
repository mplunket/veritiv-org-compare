@isTest
private class DnBAuthenticationTokenRefreshTest {
	
    private static DnB_API_Settings__c testDnBSetting;
	private static final String ORIGINAL_TOKEN = 'test Token';
    private static final String UPDATED_TOKEN = 'test New Token';
    private static final String ENCODED_TOKEN = 'test+New+Token';
	private static final DateTime CURRENT_DATETIME = DateTime.now();
	private static final Integer EXPIRES_IN_SECONDS = 86400;

    static void initDnBSetting() {
        testDnBSetting = new DnB_API_Settings__c();

        testDnBSetting.Consumer_Key__c = 'testKey';
        testDnBSetting.Consumer_Secret__c = 'testSecret';
        testDnBSetting.Authentication_URL__c = 'http://testapi.com/login';
		testDnBSetting.Identity_Resolution_URL__c = 'http://testapi.com/ir';
		testDnBSetting.Company_Profile_URL__c = 'http://testapi.com/cp';
        testDnBSetting.DnB_API_Token__c = ORIGINAL_TOKEN;
        testDnBSetting.DnB_API_Token_Expiration__c = CURRENT_DATETIME;
        testDnBSetting.Account_Minimum_Confidence_Code__c = 4;
        testDnBSetting.Lead_Minimum_Confidence_Code__c = 4;

        insert testDnBSetting;
    }

    @isTest
    static void testRefreshJobSuccess() {
        initDnBSetting();

        Test.setMock(HttpCalloutMock.class, new RefreshResponse(200, 'test New Token'));

        Test.startTest();
            new DnBAuthenticationTokenRefresh().execute(null);
        Test.stopTest();

        DnB_API_Settings__c updatedSetting = [SELECT DnB_API_Token__c, DnB_API_Token_Expiration__c
			FROM DnB_API_Settings__c WHERE Id = :testDnBSetting.Id];
        
        System.assertEquals(UPDATED_TOKEN, updatedSetting.DnB_API_Token__c, 'We expect the token to be updated');
        System.assert(updatedSetting.DnB_API_Token_Expiration__c > CURRENT_DATETIME, 
			'We expect the token expiration time to be updated.');
    }

	@isTest
    static void testRefreshJobErrorResponse() {
        initDnBSetting();

        Test.setMock(HttpCalloutMock.class, new RefreshResponse(404, ' '));

        Test.startTest();
            new DnBAuthenticationTokenRefresh().execute(null);
        Test.stopTest();

		DnB_API_Settings__c updatedSetting = [SELECT DnB_API_Token__c, DnB_API_Token_Expiration__c
			FROM DnB_API_Settings__c WHERE Id = :testDnBSetting.Id];

        System.assertEquals(ORIGINAL_TOKEN, updatedSetting.DnB_API_Token__c, 'We expect the token to not be updated');
        System.debug(updatedSetting.DnB_API_Token_Expiration__c);
        System.debug(CURRENT_DATETIME);
        System.assertEquals(CURRENT_DATETIME, updatedSetting.DnB_API_Token_Expiration__c,
			'We expect the token expiration time to not be updated.');
    }
    
    @isTest
    static void testRefreshJobException() {
        initDnBSetting();

        RefreshResponse calloutRes = new RefreshResponse(200, 'test New Token');
        calloutRes.fail = true;
        Test.setMock(HttpCalloutMock.class, calloutRes);

        Test.startTest();
            new DnBAuthenticationTokenRefresh().execute(null);
        Test.stopTest();

		DnB_API_Settings__c updatedSetting = [SELECT DnB_API_Token__c, DnB_API_Token_Expiration__c
			FROM DnB_API_Settings__c WHERE Id = :testDnBSetting.Id];

        System.assertEquals(ORIGINAL_TOKEN, updatedSetting.DnB_API_Token__c, 'We expect the token to not be updated');
        System.assertEquals(CURRENT_DATETIME, updatedSetting.DnB_API_Token_Expiration__c, 
			'We expect the token expiration time to not be updated.');
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

			if (status != 200) {
				return new HttpResponse();
			}

			List<String> decodedAuthHeader = req.getHeader('Authorization').split(' ');

			System.assertEquals(2, decodedAuthHeader.size(), 'Authorization header should be of the format "Basic <Base 64 encoded key:secret>"');
			System.assertEquals('Basic', decodedAuthHeader[0], 'Authorization header should be of the format "Basic <Base 64 encoded key:secret>"');

			List<String> decodedCredentials = EncodingUtil.base64Decode(decodedAuthHeader[1]).toString().split(':');

			System.assertEquals(testDnBSetting.Consumer_Key__c, decodedCredentials[0], 'Decoded authorization header should include Customer Key');
			System.assertEquals(testDnBSetting.Consumer_Secret__c, decodedCredentials[1], 'Decoded authorization header should include Customer Secret');

            HTTPResponse res = new HTTPResponse();

            Map<String, Object> resBody = new Map<String, Object>();
            resBody.put('access_token', this.token);
			resBody.put('expiresIn', EXPIRES_IN_SECONDS);
            res.setStatusCode(this.status);
            res.setBody(JSON.serialize(resBody));
            return res;
        }
    }
}
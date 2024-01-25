@isTest
private class DnBAccountSyncQuickActionControllerTest {
	
	@isTest static void testGetAccount() {
		Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
		insert testAccount;

		Test.startTest();
			Account returnedAccount = DnBAccountSyncQuickActionController.getAccount(testAccount.Id);
		Test.stopTest();

		System.assertEquals(testAccount.Id, returnedAccount.Id, 'We expect the controller to return the correct account.');
	}
	
	@isTest static void testGetMatches() {
		Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
		insert testAccount;

		Test.setMock(HttpCalloutMock.class, new DnBCalloutMock());

		Test.startTest();
			String response = DnBAccountSyncQuickActionController.getMatches(testAccount);
		Test.stopTest();

		System.assertEquals('{"test":"test"}', response, 'We expect the correct response from the controller.');
	}

	@isTest static void testGetMatchesException() {
		Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
		insert testAccount;

		DnBCalloutMock mock = new DnBCalloutMock();
		mock.throwException = true;
		Test.setMock(HttpCalloutMock.class, mock);

		Boolean thrownException = false;

		Test.startTest();
			try {
				String response = DnBAccountSyncQuickActionController.getMatches(testAccount);
			} catch(AuraHandledException e) {
				thrownException = true;
			}
		Test.stopTest();

		System.assert(thrownException, 'We expect the controller to catch and throw an Aura Exception.');
	}

	@isTest static void testSyncAccountWithDnB() {
		Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
		insert testAccount;

		Test.setMock(HttpCalloutMock.class, new DnBCalloutMock());

		String duns = 'DUNS';
		Integer confidenceCode = 4;

		Test.startTest();
			DnBAccountSyncQuickActionController.syncAccountWithDnB(testAccount.Id, duns, confidenceCode, testAccount.Name);
		Test.stopTest();

		testAccount = [SELECT Id, D_U_N_S__c, DnB_Confidence_Code__c FROM Account WHERE Id = :testAccount.Id];

		System.assertEquals(duns, testAccount.D_U_N_S__c);
		System.assertEquals(confidenceCode, testAccount.DnB_Confidence_Code__c);
	}

	@isTest static void testSyncAccountWithDnBException() {
		Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
		insert testAccount;

		DnBCalloutMock mock = new DnBCalloutMock();
		mock.throwException = true;
		Test.setMock(HttpCalloutMock.class, mock);

		String duns = 'DUNS';
		Integer confidenceCode = 4;
		Boolean exceptionThrown = false;

		Test.startTest();
			try {
				DnBAccountSyncQuickActionController.syncAccountWithDnB(testAccount.Id, duns, confidenceCode, testAccount.Name);
			} catch(AuraHandledException e) {
				exceptionThrown = true;
			}
		Test.stopTest();

		System.assert(exceptionThrown, 'We expect and exception to be thrown from the controller.');
	}

	@isTest static void testGetUITheme() {

		Test.startTest();
			String returnedUser = DnBAccountSyncQuickActionController.getUITheme();
		Test.stopTest();

		System.assertEquals(UserInfo.getUiThemeDisplayed(), returnedUser, 'We expect the controller to return the correct UI Theme.');
	}
	
	public class DnBCalloutMock implements HttpCalloutMock {
		public Boolean throwException = false;

		public HTTPResponse respond(HTTPRequest req) {

			System.assertEquals('GET', req.getMethod());
			system.debug(throwException);

			if (throwException) {
				throw new CalloutException('DnB Error');
			}
			
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"test":"test"}');
			res.setStatusCode(200);
			return res;
    	}
	}
}
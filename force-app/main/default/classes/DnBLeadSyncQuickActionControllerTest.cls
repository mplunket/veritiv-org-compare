@isTest
private class DnBLeadSyncQuickActionControllerTest {
	
	@isTest static void testGetLead() {
		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		Test.startTest();
			Lead returnedLead = DnBLeadSyncQuickActionController.getLead(testLead.Id);
		Test.stopTest();

		System.assertEquals(testLead.Id, returnedLead.Id, 'We expect the controller to return the correct account.');
	}
	
	@isTest static void testGetMatches() {
		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		Test.setMock(HttpCalloutMock.class, new DnBCalloutMock());

		Test.startTest();
			String response = DnBLeadSyncQuickActionController.getMatches(testLead);
		Test.stopTest();

		System.assertEquals('{"test":"test"}', response, 'We expect the correct response from the controller.');
	}

	@isTest static void testGetMatchesException() {
		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		DnBCalloutMock mock = new DnBCalloutMock();
		mock.throwException = true;
		Test.setMock(HttpCalloutMock.class, mock);

		Boolean thrownException = false;

		Test.startTest();
			try {
				String response = DnBLeadSyncQuickActionController.getMatches(testLead);
			} catch(AuraHandledException e) {
				thrownException = true;
			}
		Test.stopTest();

		System.assert(thrownException, 'We expect the controller to catch and throw an Aura Exception.');
	}

	@isTest static void testSyncLeadWithDnB() {
		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		Test.setMock(HttpCalloutMock.class, new DnBCalloutMock());

		String duns = 'DUNS';
		Integer confidenceCode = 4;

		Test.startTest();
			DnBLeadSyncQuickActionController.syncLeadWithDnB(testLead.Id, duns, confidenceCode);
		Test.stopTest();

		testLead = [SELECT Id, D_U_N_S__c, DnB_Confidence_Code__c FROM Lead WHERE Id = :testLead.Id];

		System.assertEquals(duns, testLead.D_U_N_S__c);
		System.assertEquals(confidenceCode, testLead.DnB_Confidence_Code__c);
	}

	@isTest static void testSyncLeadWithDnBException() {
		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		DnBCalloutMock mock = new DnBCalloutMock();
		mock.throwException = true;
		Test.setMock(HttpCalloutMock.class, mock);

		String duns = 'DUNS';
		Integer confidenceCode = 4;
		Boolean exceptionThrown = false;

		Test.startTest();
			try {
				DnBLeadSyncQuickActionController.syncLeadWithDnB(testLead.Id, duns, confidenceCode);
			} catch(AuraHandledException e) {
				exceptionThrown = true;
			}
		Test.stopTest();

		System.assert(exceptionThrown, 'We expect and exception to be thrown from the controller.');
	}
	
	public class DnBCalloutMock implements HttpCalloutMock {
		public Boolean throwException = false;

		public HTTPResponse respond(HTTPRequest req) {

			System.assertEquals('GET', req.getMethod());

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
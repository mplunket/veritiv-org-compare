@isTest
private class DnBLeadIdentityResolutionAPITest {
	
	static void testSetup() {
		DnB_API_Settings__c apiSettings = new DnB_API_Settings__c();

		apiSettings.Account_Minimum_Confidence_Code__c = 10;
		apiSettings.Authentication_URL__c = 'www.authentication.com';
		apiSettings.Company_Profile_URL__c = 'www.companyprofile.com';
		apiSettings.Consumer_Key__c = 'Consumer Key';
		apiSettings.Consumer_Secret__c = 'Consumer Secret';
		apiSettings.Identity_Resolution_URL__c = 'www.identityresolution.com';
		apiSettings.Lead_Minimum_Confidence_Code__c = 10;

		insert apiSettings;
	}

	@isTest static void testAPISuccess() {
		testSetup();

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);

		Test.setMock(HttpCalloutMock.class, new IdentityResolutionMock(200));

		Test.startTest();
			String response = DnBLeadIdentityResolutionAPIService.dnbIdentityResolutionCallout(testLead);
		Test.stopTest();

		System.assertEquals('{"test": "test"}', response, 'We expect a success response from the callout.');
	}
	
	@isTest static void testAPIError00040() {
		testSetup();

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);

		Test.setMock(HttpCalloutMock.class, new IdentityResolutionMock(404, '00040'));

		Test.startTest();
			try {
				String response = DnBLeadIdentityResolutionAPIService.dnbIdentityResolutionCallout(testLead);
			} catch (Exception e) {
				System.assert(e.getMessage().contains(Label.DnB_API_Error_00040), 'We expect the correct error exception to be thrown from the API response.');
			}
		Test.stopTest();
	}

	@isTest static void testAPIError20502() {
		testSetup();

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);

		Test.setMock(HttpCalloutMock.class, new IdentityResolutionMock(404, '20502'));

		Test.startTest();
			try {
				String response = DnBLeadIdentityResolutionAPIService.dnbIdentityResolutionCallout(testLead);
			} catch (Exception e) {
				System.assert(e.getMessage().contains(Label.DnB_API_Error_20502), 'We expect the correct error exception to be thrown from the API response.');
			}
		Test.stopTest();
    }

	@isTest static void testAPIError20504() {
		testSetup();

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);

		Test.setMock(HttpCalloutMock.class, new IdentityResolutionMock(404, '20504'));

		Test.startTest();
			try {
				String response = DnBLeadIdentityResolutionAPIService.dnbIdentityResolutionCallout(testLead);
			} catch (Exception e) {
				System.assert(e.getMessage().contains(Label.DnB_API_Error_20504), 'We expect the correct error exception to be thrown from the API response.');
			}
		Test.stopTest();
	}

	@isTest static void testAPIError20505() {
		testSetup();

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);

		Test.setMock(HttpCalloutMock.class, new IdentityResolutionMock(404, '20505'));

		Test.startTest();
			try {
				String response = DnBLeadIdentityResolutionAPIService.dnbIdentityResolutionCallout(testLead);
			} catch (Exception e) {
				System.assert(e.getMessage().contains(Label.DnB_API_Error_20505), 'We expect the correct error exception to be thrown from the API response.');
			}
		Test.stopTest();
	}

	@isTest static void testAPIErrorUnknown() {
		testSetup();

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);

		Test.setMock(HttpCalloutMock.class, new IdentityResolutionMock(404, '99999'));

		Test.startTest();
			try {
				String response = DnBLeadIdentityResolutionAPIService.dnbIdentityResolutionCallout(testLead);
			} catch (Exception e) {
				System.assert(e.getMessage().contains('99999: DnB Error'), 'We expect the correct error exception to be thrown from the API response.');
			}
		Test.stopTest();
	}

	@isTest static void testBuildIdentityResolutionURLParams() {
		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);

		testLead.Website = 'www.google.com';
		testLead.Phone = '555-555-5555';
		testLead.Street = 'Street';
		testLead.City = 'City';
		testLead.State = 'State';
		testLead.PostalCode = '55555';
		testLead.Country = 'Country';

		Test.startTest();
			String queryString = DnBLeadIdentityResolutionAPIService.buildIdentityResolutionURLParams(testLead);
		Test.stopTest();

		System.assert(queryString.contains(testLead.Website), 'We expect the Account website to be a part of the returned paramters.');
		System.assert(queryString.contains(testLead.Phone), 'We expect the Account phone number to be a part of the returned paramters.');
		System.assert(queryString.contains(testLead.Street), 'We expect the Account billing street to be a part of the returned paramters.');
		System.assert(queryString.contains(testLead.City), 'We expect the Account billing city to be a part of the returned paramters.');
		System.assert(queryString.contains(testLead.State), 'We expect the Account billing state to be a part of the returned paramters.');
		System.assert(queryString.contains(testLead.PostalCode), 'We expect the Account postal code to be a part of the returned paramters.');
		System.assert(queryString.contains(testLead.Country), 'We expect the Account billing country to be a part of the returned paramters.');
	}

	public class IdentityResolutionMock implements HttpCalloutMock {
		private Integer statusCode;
		private String dnbErrorCode;

		public IdentityResolutionMock(Integer statusCode) {
			this.statusCode = statusCode;
		}

		public IdentityResolutionMock(Integer statusCode, String dnbErrorCode) {
			this.statusCode = statusCode;
			this.dnbErrorCode = dnbErrorCode;
		}

		public HTTPResponse respond(HTTPRequest req) {
			System.assert(req.getEndpoint().contains('www.identityresolution.com'), 'We expect to be hitting the correct API endpoint.');
			System.assertEquals('GET', req.getMethod(), 'We expect to be using the correct API mehtod.');

			HttpResponse res = new HttpResponse();			
			res.setHeader('Content-Type', 'application/json');			
			res.setStatusCode(this.statusCode);			

			if (this.statusCode == 200) {
				res.setBody('{"test": "test"}');
			} else {
				res.setBody('{"error":{"errorCode":"' + dnbErrorCode + '","errorMessage":"DnB Error"}}');
			}
			return res;
		}
	}	
}
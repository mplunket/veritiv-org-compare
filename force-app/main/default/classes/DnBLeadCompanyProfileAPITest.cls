@isTest
private class DnBLeadCompanyProfileAPITest {
	
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
		insert testLead;

		Test.setMock(HttpCalloutMock.class, new CompanyProfileMock(200));

		Test.startTest();
			DnBLeadCompanyProfileAPIService.dnbCompanyProfileCallout(testLead.Id, '000000000', 4);
		Test.stopTest();

		testLead = [SELECT Id, Phone, Is_Being_Updated_From_DnB__c FROM Lead WHERE Id = :testLead.Id];

		System.assertEquals('000-000-0000', testLead.Phone, 'We expect fields in the response to be set on the Account object.');
	}

	@isTest static void testAPIError00040() {
		testSetup();

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		Test.setMock(HttpCalloutMock.class, new CompanyProfileMock(404, '00040'));

		Test.startTest();
			try {
				DnBLeadCompanyProfileAPIService.dnbCompanyProfileCallout(testLead.Id, '000000000', 4);
			} catch (Exception e) {
				System.assert(e.getMessage().contains(Label.DnB_API_Error_00040), 'We expect the correct error exception to be thrown from the API response.');
			}
		Test.stopTest();
	}

	@isTest static void testAPIError20502() {
		testSetup();

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		Test.setMock(HttpCalloutMock.class, new CompanyProfileMock(404, '20502'));

		Test.startTest();
			try {
				DnBLeadCompanyProfileAPIService.dnbCompanyProfileCallout(testLead.Id, '000000000', 4);
			} catch (Exception e) {
				System.assert(e.getMessage().contains(Label.DnB_API_Error_20502), 'We expect the correct error exception to be thrown from the API response.');
			}
		Test.stopTest();
	}

	@isTest static void testAPIError20504() {
		testSetup();

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		Test.setMock(HttpCalloutMock.class, new CompanyProfileMock(404, '20504'));

		Test.startTest();
			try {
				DnBLeadCompanyProfileAPIService.dnbCompanyProfileCallout(testLead.Id, '000000000', 4);
			} catch (Exception e) {
				System.assert(e.getMessage().contains(Label.DnB_API_Error_20504), 'We expect the correct error exception to be thrown from the API response.');
			}
		Test.stopTest();
	}

	@isTest static void testAPIError20505() {
		testSetup();

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		Test.setMock(HttpCalloutMock.class, new CompanyProfileMock(404, '20505'));

		Test.startTest();
			try {
				DnBLeadCompanyProfileAPIService.dnbCompanyProfileCallout(testLead.Id, '000000000', 4);
			} catch (Exception e) {
				System.assert(e.getMessage().contains(Label.DnB_API_Error_20505), 'We expect the correct error exception to be thrown from the API response.');
			}
		Test.stopTest();
	}

	@isTest static void testAPIErrorUnknown() {
		testSetup();

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		Test.setMock(HttpCalloutMock.class, new CompanyProfileMock(404, '99999'));

		Test.startTest();
			try {
				DnBLeadCompanyProfileAPIService.dnbCompanyProfileCallout(testLead.Id, '000000000', 4);
			} catch (Exception e) {
				System.assert(e.getMessage().contains('99999: DnB Error'), 'We expect the correct error exception to be thrown from the API response.');
			}
		Test.stopTest();
	}

	@isTest static void testMapCompanyProfileResponseToLead() {
		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		DnBCompanyProfileResponse response = new DnBCompanyProfileResponse();

		DnBCompanyProfileResponse.Organization organization = new DnBCompanyProfileResponse.Organization();
		
			DnBCompanyProfileResponse.IndustryCodes industryCode1 = new DnBCompanyProfileResponse.IndustryCodes();
			industryCode1.code = '10000';
			industryCode1.description = 'NAICS Code';
			industryCode1.typeDescription = 'North American Industry Classification System';
			industryCode1.priority = 1;
			
			DnBCompanyProfileResponse.IndustryCodes industryCode2 = new DnBCompanyProfileResponse.IndustryCodes();
			industryCode2.code = '10000';
			industryCode2.description = 'SIC Code';
			industryCode2.typeDescription = 'D&B Standard Industry Code';
			industryCode2.priority = 1;

		organization.industryCodes = new List<DnBCompanyProfileResponse.IndustryCodes> {industryCode1, industryCode2};

			DnBCompanyProfileResponse.Financials financial = new DnBCompanyProfileResponse.Financials();
			
				DnBCompanyProfileResponse.YearlyRevenue yearlyRevenue = new DnBCompanyProfileResponse.YearlyRevenue();
				
					DnBCompanyProfileResponse.Trend trendIndustryCodes = new DnBCompanyProfileResponse.Trend();
					trendIndustryCodes.growthRate = 1.0;
				
				yearlyRevenue.trend = new List<DnBCompanyProfileResponse.Trend> {trendIndustryCodes};
			
			financial.yearlyRevenue = new List<DnBCompanyProfileResponse.YearlyRevenue> {yearlyRevenue};

		organization.financials = new List<DnBCompanyProfileResponse.Financials> {financial};

			DnBCompanyProfileResponse.CorporateLinkage corporateLinkage = new DnBCompanyProfileResponse.CorporateLinkage();
				
				DnBCompanyProfileResponse.GlobalUltimate parent = new DnBCompanyProfileResponse.GlobalUltimate();
				parent.duns = 'Parent';

				DnBCompanyProfileResponse.GlobalUltimate domesticUltimate = new DnBCompanyProfileResponse.GlobalUltimate();
				domesticUltimate.duns = 'Domestic Ultimate';

				DnBCompanyProfileResponse.GlobalUltimate globalUltimate = new DnBCompanyProfileResponse.GlobalUltimate();
				globalUltimate.duns = 'Global Ultimate';
			
				DnBCompanyProfileResponse.OperatingStatus familyTreeRolesPlayed = new DnBCompanyProfileResponse.OperatingStatus();
				familyTreeRolesPlayed.description = 'Location Type';

			corporateLinkage.parent = parent;
			corporateLinkage.domesticUltimate = domesticUltimate;
			corporateLinkage.globalUltimate = globalUltimate;
			corporateLinkage.familyTreeRolesPlayed = new List<DnBCompanyProfileResponse.OperatingStatus> {familyTreeRolesPlayed};

		organization.corporateLinkage = corporateLinkage;

			DnBCompanyProfileResponse.NumberOfEmployees numberOfEmployees1 = new DnBCompanyProfileResponse.NumberOfEmployees();
			numberOfEmployees1.informationScopeDescription = 'Consolidated';
			numberOfEmployees1.value = 3000;

				DnBCompanyProfileResponse.Trend trendNumberOfEmployees = new DnBCompanyProfileResponse.Trend();
				trendNumberOfEmployees.growthRate = 1.0;

			numberOfEmployees1.trend = new List<DnBCompanyProfileResponse.Trend> {trendNumberOfEmployees};

			DnBCompanyProfileResponse.NumberOfEmployees numberOfEmployees2 = new DnBCompanyProfileResponse.NumberOfEmployees();
			numberOfEmployees2.informationScopeDescription = 'Individual';
			numberOfEmployees2.value = 3000;

		organization.numberOfEmployees = new List<DnBCompanyProfileResponse.NumberOfEmployees> {numberOfEmployees1, numberOfEmployees2};

			DnBCompanyProfileResponse.TradeStyleNames tradeStyleNames = new DnBCompanyProfileResponse.TradeStyleNames();
			tradeStyleNames.name = 'Other Name';
			tradeStyleNames.priority = 1;

		organization.tradeStyleNames = new List<DnBCompanyProfileResponse.TradeStyleNames> {tradeStyleNames};

			DnBCompanyProfileResponse.WebsiteAddress websiteAddress = new DnBCompanyProfileResponse.WebsiteAddress();
			websiteAddress.url = 'www.company.com';

		organization.websiteAddress = new List<DnBCompanyProfileResponse.WebsiteAddress> {websiteAddress};

			DnBCompanyProfileResponse.SocioEconomicInformation socioEconomicInformation = new DnBCompanyProfileResponse.SocioEconomicInformation();
			socioEconomicInformation.isMinorityOwned = true;
			socioEconomicInformation.isSmallBusiness = true;
			socioEconomicInformation.isFemaleOwned = true;

		organization.socioEconomicInformation = socioEconomicInformation;

			DnBCompanyProfileResponse.OperatingStatus businessEntityType = new DnBCompanyProfileResponse.OperatingStatus();
			businessEntityType.description = 'Business Type';

		organization.businessEntityType = businessEntityType;

			DnBCompanyProfileResponse.PrimaryAddress primaryAddress = new DnBCompanyProfileResponse.PrimaryAddress();
			
				DnBCompanyProfileResponse.StreetAddress streetAddress = new DnBCompanyProfileResponse.StreetAddress();
				streetAddress.line1 = 'Street';

				DnBCompanyProfileResponse.ContinentalRegion addressLocality = new DnBCompanyProfileResponse.ContinentalRegion();
				addressLocality.name = 'City';

				DnBCompanyProfileResponse.AddressRegion addressRegion = new DnBCompanyProfileResponse.AddressRegion();
				addressRegion.abbreviatedName = 'Region';

				DnBCompanyProfileResponse.AddressCountry addressCountry = new DnBCompanyProfileResponse.AddressCountry();
				addressCountry.isoAlpha2Code = 'Country';

				DnBCompanyProfileResponse.PremisesArea premisesArea = new DnBCompanyProfileResponse.PremisesArea();
				premisesArea.measurement = 1.0;
				premisesArea.unitDescription = 'Unit';

			primaryAddress.streetAddress = streetAddress;
			primaryAddress.addressLocality = addressLocality;
			primaryAddress.addressRegion = addressRegion;
			primaryAddress.postalCode = '00000';
			primaryAddress.addressCountry = addressCountry;
			primaryAddress.premisesArea = premisesArea;

		organization.primaryAddress = primaryAddress;

		response.organization = organization;

		Test.startTest();
			DnBLeadCompanyProfileAPIService.mapCompanyProfileResponseToLead(response, testLead);
			update testLead;
		Test.stopTest();

		testLead = [SELECT Id, Street, Website, SIC__c, Employees_Hoovers__c FROM Lead WHERE Id = :testLead.Id];
		
		System.assertEquals('Street', testLead.Street, 'We expect the street address to be updated from the mapping.');
		System.assertEquals('www.company.com', testLead.Website, 'We expect the website to be updated from the mapping');
		System.assertEquals('10000', testLead.SIC__c, 'We expect the SIC code to be updated from the mapping.');
		System.assertEquals(3000, testLead.Employees_Hoovers__c, 'We expect the number of employees to be updated from the mapping.');
	}	

	public class CompanyProfileMock implements HttpCalloutMock {
		private Integer statusCode;
		private String dnbErrorCode;

		public CompanyProfileMock(Integer statusCode) {
			this.statusCode = statusCode;
		}

		public CompanyProfileMock(Integer statusCode, String dnbErrorCode) {
			this.statusCode = statusCode;
			this.dnbErrorCode = dnbErrorCode;
		}

		public HTTPResponse respond(HTTPRequest req) {
			System.debug(req.getEndpoint());
			System.assert(req.getEndpoint().contains('www.companyprofile.com'), 'We expect to be hitting the correct API endpoint.');
			System.assertEquals('GET', req.getMethod(), 'We expect to be using the correct API method.');

			HttpResponse res = new HttpResponse();			
			res.setHeader('Content-Type', 'application/json');			
			res.setStatusCode(this.statusCode);			

			if (this.statusCode == 200) {
				res.setBody('{"organization": {"telephone":[{"telephoneNumber": "000-000-0000"}]}}');
			} else {
				res.setBody('{"error":{"errorCode":"' + dnbErrorCode + '","errorMessage":"DnB Error"}}');
			}
			return res;
		}
	}	
	
}
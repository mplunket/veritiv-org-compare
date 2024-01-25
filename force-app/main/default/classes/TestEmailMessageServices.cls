@isTest
private class TestEmailMessageServices { 
	final static String expectedNormalPriorty = 'normal';
	final static String expectedHighPriorty = 'high';
	
	static
	{
		List<RecordType> caseRecordTypes = [Select ID From RecordType Where SObjectType='Case' And IsActive=True Limit 1];
		insert (new InactiveRecordTypes__c(Name=CaseServices.EBUSINESS_RT_NAME,Record_Type_Id__c=caseRecordTypes[0].ID));
//changed email address by sujitha
		Qualified_Email_Addresses__c qualifying1 = new Qualified_Email_Addresses__c(Name='@UNISOURCELINK.COM');
		Qualified_Email_Addresses__c qualifying2 = new Qualified_Email_Addresses__c(Name='@TestWORLDWIDE.COM');
		insert new List<Qualified_Email_Addresses__c>{qualifying1,qualifying2};
	}

	private static void setupErrorEmailRecips(Id userId){
		Apex_Class_Error_Emails__c newCs = new Apex_Class_Error_Emails__c();
		newCs.Name = 'TEST CS NAME';
		newCs.User_ID__c = userId;
		insert newCs;
	}
	
	private static void verifyRightPrioritiesReturned(String headersSample_normalPriority, String headersSample_highPriority)
	{
		Test.startTest();
			String resultForNormalPrioritySample = EmailMessageServices.getPriorityOfEmail(headersSample_normalPriority);
			String resultForHighPrioritySample = EmailMessageServices.getPriorityOfEmail(headersSample_highPriority);
		Test.stopTest();
		
		System.assertEquals(expectedNormalPriorty,resultForNormalPrioritySample,'For a headers text that has normal priority specified, getPriorityOfEmail should return normal');
		System.assertEquals(expectedHighPriorty,resultForHighPrioritySample,'For a headers text that has high priority specified, getPriorityOfEmail should return high');
	}
	
	private static testMethod void testGetPriorityOfEmailWhenPriorityIsNotLastLine(){
		final String headersSample_normalPriority='Return-Path: G.T@testworldwide.com\nFrom: <abc_2010@abcfitness.com>\nTo: <abc@unisourcelink.com>, <uwwabcfitness@testworldwide.com>\nImportance: normal\n'+EmailMessageServices.PRIORITY_KEY_PREFIX + 'normal\nX-MimeOLE: Produced By Microsoft MimeOLE V6.1.7';
		final String headersSample_highPriority='Return-Path: G.T@testworldwide.com\nFrom: <abc_2010@abcfitness.com>\nTo: <abc@unisourcelink.com>, <uwwabcfitness@testworldwide.com>\nImportance: normal\n'+EmailMessageServices.PRIORITY_KEY_PREFIX + 'high\nX-MimeOLE: Produced By Microsoft MimeOLE V6.1.7';
		
		verifyRightPrioritiesReturned(headersSample_normalPriority,headersSample_highPriority);
	}
	
	private static testMethod void testGetPriorityOfEmailWhenPriorityIsLastLine(){
		final String headersSample_normalPriority='Return-Path: G.T@testworldwide.com\nFrom: <abc_2010@abcfitness.com>\nTo: <abc@unisourcelink.com>, <uwwabcfitness@testworldwide.com>\nImportance: normal\n'+EmailMessageServices.PRIORITY_KEY_PREFIX + 'normal';
		final String headersSample_highPriority='Return-Path: G.T@testworldwide.com\nFrom: <abc_2010@abcfitness.com>\nTo: <abc@unisourcelink.com>, <uwwabcfitness@testworldwide.com>\nImportance: normal\n'+EmailMessageServices.PRIORITY_KEY_PREFIX + 'high';
	
		verifyRightPrioritiesReturned(headersSample_normalPriority,headersSample_highPriority);
	}
	
	private static testMethod void testGetPriorityOfEmailWhenPriorityIsNotSpecified(){
		final String headersSample_normalPriority='Return-Path: G.T@testworldwide.com\nFrom: <abc_2010@abcfitness.com>\nTo: <abc@unisourcelink.com>, <uwwabcfitness@testworldwide.com>\nImportance: normal';
		final String headersSample_highPriority='Return-Path: G.T@testworldwide.com\nFrom: <abc_2010@abcfitness.com>\nTo: <abc@unisourcelink.com>, <uwwabcfitness@testworldwide.com>\nImportance: normal';
		
		Test.startTest();
			String resultForNormalPrioritySample = EmailMessageServices.getPriorityOfEmail(headersSample_normalPriority);
			String resultForHighPrioritySample = EmailMessageServices.getPriorityOfEmail(headersSample_highPriority);
		Test.stopTest();
		
		System.assertEquals(null,resultForNormalPrioritySample,'For a headers text that does not have a priority specified, we expect getPriorityOfEmail to return null');
		System.assertEquals(null,resultForHighPrioritySample,'For a headers text that does not have a priority specified, we expect getPriorityOfEmail to return null');
	}
	
	private static testMethod void testPopulateEmailOriginsCustomSettingsPrioritized()
	{
		final String returnPath = 'returnpath@gmail.com';
		final List<String> emptyReturnPathHeaders = new List<String> { EmailMessageServices.RETURN_PATH_PREFIX + EmailMessageServices.EMPTY_RETURN_PATH + '\nX-Original-To: USER@SITE.com\nDelivered-To: USER@SITE.com',
																	   EmailMessageServices.RETURN_PATH_PREFIX + '   ', '\nX-Original-To: USER@SITE.com\nDelivered-To: USER@SITE.com'};
		final List<String> validReturnPathHeaders = new List<String> { EmailMessageServices.RETURN_PATH_PREFIX + returnPath,
																	   EmailMessageServices.RETURN_PATH_PREFIX + returnPath + '\nX-Original-To: USER@SITE.com\nDelivered-To: USER@SITE.com',
												   					   'From MAILER-DAEMON  Wed Dec 28 09:54:39 2005\n'+ EmailMessageServices.RETURN_PATH_PREFIX + returnPath + '\nX-Original-To: USER@SITE.com'};
		
		final List<String> normalQualifyingOrigins = new List<String> {'abc@unisourcelink.com','prIority2@unisourcelink.com','d1@testworldwide.com'};
		final List<String> normalNotQualifyingOrigins = new List<String> {'abc@unisource.com','abc1@unisource.com'};
		
		final List<String> importantOrigins = new List<String> {'a@unisource.com','abc1@testworldwide.com','PRIORITY3@unisourcelink.com'};
		
		UFreight_Groupbox__c validOriginOne = new UFreight_Groupbox__c(Name='Test', Email_Address__c = importantOrigins[0]);
		UFreight_Groupbox__c validOriginTwo = new UFreight_Groupbox__c(Name='Test2', Email_Address__c = importantOrigins[1]);
		insert new List<UFreight_Groupbox__c> {validOriginOne, validOriginTwo};
		
		Email_Origins_E2C_Search_Contact__c freightOrigin = new Email_Origins_E2C_Search_Contact__c(Name='Freight Email Address', Email__c=importantOrigins[0]);
		Email_Origins_E2C_Search_Contact__c logisticsOrigin = new Email_Origins_E2C_Search_Contact__c(Name='Logistics Email Address', Email__c=importantOrigins[2]);
		
		insert new List<Email_Origins_E2C_Search_Contact__c> {freightOrigin,logisticsOrigin};
		
		UnitTest.createTestData(TestingUtils.cases).many(50).newAttribute('*ToAddress*').assign(normalQualifyingOrigins[0] + ';\n' + normalQualifyingOrigins[1] + ';'+normalNotQualifyingOrigins[1])
														    .newAttribute('*CcAddress*').assign(normalQualifyingOrigins[0] + '\n;' + normalNotQualifyingOrigins[0])
														    .newAttribute('*Headers*').assignFrom(validReturnPathHeaders)
														    .newAttribute('*Expected Very Important Email Origin*').assign(returnPath.toUpperCase())
														    .newAttribute('*Expected Important Email Origins*').assign(new Set<String>())
														    .newAttribute('*Expected Normal Email Origins*').assign(new Set<String> {normalQualifyingOrigins[0].toUpperCase(), normalQualifyingOrigins[1].toUpperCase()});
		UnitTest.createTestData(TestingUtils.cases).many(50).newAttribute('*ToAddress*').assign(null)
															.newAttribute('*CcAddress*').assign(importantOrigins[1])
															.newAttribute('*Headers*').assignFrom(emptyReturnPathHeaders)
														    .newAttribute('*Expected Very Important Email Origin*').assign(null)
															.newAttribute('*Expected Important Email Origins*').assign(new Set<String> {importantOrigins[1].toUpperCase()})
															.newAttribute('*Expected Normal Email Origins*').assign(new Set<String>());
		UnitTest.createTestData(TestingUtils.cases).many(50).newAttribute('*ToAddress*').assign(importantOrigins[0]+';'+importantOrigins[1])
															.newAttribute('*CcAddress*').assign(null)
															.newAttribute('*Headers*').assignFrom(validReturnPathHeaders)
														    .newAttribute('*Expected Very Important Email Origin*').assign(returnPath.toUpperCase())
															.newAttribute('*Expected Important Email Origins*').assign(new Set<String> {importantOrigins[0].toUpperCase(),importantOrigins[1].toUpperCase()})
															.newAttribute('*Expected Normal Email Origins*').assign(new Set<String>());
		UnitTest.createTestData(TestingUtils.cases).many(50).newAttribute('*ToAddress*').assign(normalQualifyingOrigins[0] + ';' + normalQualifyingOrigins[1] + ';\n' + importantOrigins[0])
															.newAttribute('*CcAddress*').assign( normalQualifyingOrigins[2] + '  ;' + importantOrigins[0] + '  ;  ' + importantOrigins[1])
															.newAttribute('*Headers*').assignFrom(validReturnPathHeaders)
														    .newAttribute('*Expected Very Important Email Origin*').assign(returnPath.toUpperCase())
															.newAttribute('*Expected Important Email Origins*').assign(new Set<String> {importantOrigins[0].toUpperCase(),importantOrigins[1].toUpperCase()})
															.newAttribute('*Expected Normal Email Origins*').assign(new Set<String> {normalQualifyingOrigins[0].toUpperCase(), normalQualifyingOrigins[1].toUpperCase(),normalQualifyingOrigins[2].toUpperCase()});
		UnitTest.get(Case.SObjectType).tag('Case').insertAll();
		
		UnitTest.forEach('Case').create(1,TestingUtils.emailMessages).copyProperty('ID->ParentID')
																	.copyProperty('*ToAddress*->ToAddress')
																	.copyProperty('*CcAddress*->CcAddress')
																	.copyProperty('*Headers*->Headers');
		
		List<Case> cases = UnitTest.get(Case.SObjectType).getList();
		Test.startTest();
			EmailMessageServices.populateEmailOrigins(cases,createCaseIDToEmailMessageMap());
		Test.stopTest();
		
		
		for(Case c : cases)
		{
			Object expectedVeryImportantEmailOrigin = UnitTest.analyze('Case').selectByID(c.ID).getPropertyValue('*Expected Very Important Email Origin*');
			Set<String> expectedImportantEmailOrigins = (Set<String>) UnitTest.analyze('Case').selectByID(c.ID).getPropertyValue('*Expected Important Email Origins*');
			Set<String> expectedNormalEmailOrigins = (Set<String>) UnitTest.analyze('Case').selectByID(c.ID).getPropertyValue('*Expected Normal Email Origins*');
			
			List<String> actualOrigins = c.Email_Origin__c.split(';');
			Integer expectedEmailOrigins = expectedImportantEmailOrigins.size()+expectedNormalEmailOrigins.size()+(expectedVeryImportantEmailOrigin!=null?1:0);
			System.assertEquals(expectedEmailOrigins,actualOrigins.size(), 'We must correctly determine the email origin field, including all matching normal email addresses and all important email addresses. We got the following email origins: ' + actualOrigins);
			
			Integer indexOfVeryImportantOrigin = -1;
			if(expectedVeryImportantEmailOrigin!=null) 
			{
			 	indexOfVeryImportantOrigin = c.Email_Origin__c.indexOf((String)expectedVeryImportantEmailOrigin);
				System.assertNotEquals(-1,indexOfVeryImportantOrigin,'If there is a return path in the header of the email, it must be in the email origins for the case. The return path should be ' + expectedVeryImportantEmailOrigin + ' but it was not found in the email origin: ' + c.Email_Origin__c);
			}
			
			Integer indexOfLastImportantOrigin = -1;
			for(String expectedPrioritiyOrigin : expectedImportantEmailOrigins)
			{
				Integer index = c.Email_Origin__c.indexOf(expectedPrioritiyOrigin);
				System.assertNotEquals(-1,index,'We must correctly determine the email origin, including all email addresses that are deemed important email addresses. But did not find ' + expectedPrioritiyOrigin);
				System.assert(index>indexOfVeryImportantOrigin, 'All important origins must be included in the case email origin field only after the very important origins');
				if(index>indexOfLastImportantOrigin) indexOfLastImportantOrigin=index;
			}
			for(String normalImportantOrigin : expectedNormalEmailOrigins)
			{
				Integer index = c.Email_Origin__c.indexOf(normalImportantOrigin);
				System.assertNotEquals(-1,index,'We must correctly determine the email origin, including all email addresses that are deemed normal email addresses. But did not find ' + normalImportantOrigin);
				System.assert(index>indexOfLastImportantOrigin, 'All normal origins must be included in the case email origin field only after the important origins');
			}
		}
	}
	
	private static Map<String, List<Contact>> createMapOfEmailToContacts(Map<String, Integer> emailToHowManyContactsPerEmail, Id accountID)
	{
		Map<String,List<Contact>> expectedEmailToContacts = new Map<String, List<Contact>>();
		List<Contact> allContacts = new List<Contact>();
		for(String key : emailToHowManyContactsPerEmail.keySet())
		{
			Integer howManyContactsToCreate = emailToHowManyContactsPerEmail.get(key);
			List<Contact> contactsForThisEmail = TestingUtils.createContacts('Sample',howManyContactsToCreate,false);
			for(Contact c : contactsForThisEmail)
			{
				c.Email = key;
				c.AccountID=accountID;
			}
			allContacts.addAll(contactsForThisEmail);
			expectedEmailToContacts.put(key,contactsForThisEmail);
		}
		
		insert allContacts;
		return expectedEmailToContacts;
	}
	
	private static testMethod void findAllContactsForEmails()
	{
		Map<String,Integer> emailToHowManyContactsPerEmail = new Map<String,Integer>();
		final String emailWhereULSContactsAndOneChildContact = 'a.b.c@testworldwide.com';
		emailToHowManyContactsPerEmail.put(emailWhereULSContactsAndOneChildContact,3);
		emailToHowManyContactsPerEmail.put('g.t@testworldwide.com',2);
		emailToHowManyContactsPerEmail.put('a.t@testworldwide.com',0);
		emailToHowManyContactsPerEmail.put('t.t@testworldwide.com.test',1);
		
		Account ulsPrimaryAccount = TestingUtils.createAccount('ULS Account');
		ulsPrimaryAccount.Is_ULS_Primary_Acct__c = true;
		insert ulsPrimaryAccount;
		
		Account childAccount = TestingUtils.createAccount('Child Account');
		childAccount.Is_ULS_Primary_Acct__c = false;
		insert childAccount;
		
		Map<String,List<Contact>> expectedEmailToContacts = createMapOfEmailToContacts(emailToHowManyContactsPerEmail,ulsPrimaryAccount.ID);
		
		
		Contact contactToPutOnChildAccount = expectedEmailToContacts.get(emailWhereULSContactsAndOneChildContact)[0];
		contactToPutOnChildAccount.AccountID = childAccount.ID;
		update contactToPutOnChildAccount;
		
		Test.startTest();
			Map<String,List<Contact>> actualEmailsToULSContacts = EmailMessageServices.findAllContactsForEmails(expectedEmailToContacts.keySet());
		Test.stopTest();  
		
		for(String key : expectedEmailToContacts.keySet())
		{
			System.assert(actualEmailsToULSContacts.containsKey(key),'We expect to create a map of emails to the list of matching contacts. Every email specified must show up in our map. Did not find ' + key);
			if(key == emailWhereULSContactsAndOneChildContact)
			{
				System.assertEquals(expectedEmailToContacts.get(key).size()-1,actualEmailsToULSContacts.get(key).size(),'For each email in our map of emails to list of matching contacts, we expect to get back every matching contacts except that one which does not belong to a ULS account');
				for(Contact c : actualEmailsToULSContacts.get(key))
				{
					System.assertNotEquals(contactToPutOnChildAccount.ID,c.ID,'We cannot get back any contacts that do not belong to a ULS primary account');
					System.assert(Pluck.ids(expectedEmailToContacts.get(key)).contains(c.ID),'For each email in our map of emails to list of matching contacts, we expect to get back every matching contacts except that one which does not belong to a ULS account');
				}
			}
			else
			{
				System.assertEquals(expectedEmailToContacts.get(key).size(),actualEmailsToULSContacts.get(key).size(),'For each email in our map of emails to list of matching contacts, we expect to get back the right number of matching contacts');
				System.assert(listContainsAll(expectedEmailToContacts.get(key),actualEmailsToULSContacts.get(key)),'For each email in our map of emails to list of matching contacts, we expect to get back each and every matching contact. If there are no matching contacts we expect to get back an empty list');
			}
		}
	} 
	
	private static Boolean listContainsAll(List<SObject> listOne, List<SObject> listTwo)
	{
		return (Pluck.ids(listOne)).containsAll(Pluck.ids(listTwo));
	}
	
	private static testMethod void testFilterCasesFromFreightGroupbox()
	{
		UFreight_Groupbox__c validOriginOne = new UFreight_Groupbox__c(Name='Test', Email_Address__c = 'sample@unisourcelink.com');
		UFreight_Groupbox__c validOriginTwo = new UFreight_Groupbox__c(Name='Test2', Email_Address__c = 'SAMPLE2@UNISOURCELINK.COM');
		insert new List<UFreight_Groupbox__c> {validOriginOne, validOriginTwo};
		
		final String invalidOrigin = 'invalid@unisourcelink.com';
		
		List<Case> allCases = TestingUtils.createCases(200,false);
		UnitTest.addData(allCases).tag('All Cases').divide(2).part('Cases That Qualify').part('Cases That Do Not Qualify');
		
		List<String> qualifyingEmailOrigins = new List<String> {validOriginOne.Email_Address__c,
															  validOriginOne.Email_Address__c + ';'+ validOriginTwo.Email_Address__c,
															  invalidOrigin+';'+validOriginOne.Email_Address__c,
															  validOriginOne.Email_Address__c + ';' + invalidOrigin};
		List<String> nonQualifyingEmailOrigins = new List<String> {validOriginOne.Email_Address__c+'.test',
																 'prefix'+validOriginOne.Email_Address__c,
																 invalidOrigin, '', null};
		UnitTest.get('Cases That Qualify').property('Email_Origin__c').assignFrom(qualifyingEmailOrigins);
		UnitTest.get('Cases That Do Not Qualify').property('Email_Origin__c').assignFrom(nonQualifyingEmailOrigins);
		UnitTest.get(Case.SObjectType).dummyInsert();
		
		Test.startTest();
			List<Case> filteredCases = EmailMessageServices.filterCasesFromFreightGroupbox(allCases);
		Test.stopTest();
		
		UnitTest.analyze('Cases That Qualify').assertEquivalence(filteredCases, 'We expect to only get back those cases which have qualifying email origins');
	}
	
	private static testMethod void filterCasesToSearchForContacts()
	{
		final String sampleEmailNotInCustomSettings = 'normalemail@sample.com';
		
		Email_Origins_E2C_Search_Contact__c freightOrigin = new Email_Origins_E2C_Search_Contact__c(Name='Freight Email Address', Email__c='freight@sample.com');
		Email_Origins_E2C_Search_Contact__c logisticsOrigin = new Email_Origins_E2C_Search_Contact__c(Name='Logistics Email Address', Email__c='logistics@sample.com');
		
		insert new List<Email_Origins_E2C_Search_Contact__c> {freightOrigin,logisticsOrigin};
		
		final Integer NUM_NONQUALIFYING_EMAILS = 30;
		final Integer NUM_QUALIFYING_EMAILS = 90;
		
		List<Case> casesForNonqualifyingEmail = TestingUtils.createCases(NUM_NONQUALIFYING_EMAILS,false);
		List<Case> casesForQualifyingEmail = TestingUtils.createCases(NUM_QUALIFYING_EMAILS,false);
		
		List<Case> allCases = new List<Case>();
		allCases.addAll(casesForNonqualifyingEmail);
		allCases.addAll(casesForQualifyingEmail);
		insert allCases;
	
		
		for(Integer i = 0; i < casesForNonqualifyingEmail.size();i++)
		{	
			Integer modResult = Math.mod(i, 3);
			if(modResult==0)
			{
				casesForNonqualifyingEmail[i].Email_Origin__c = sampleEmailNotInCustomSettings;
			}
			else if(modResult==1)
			{
				casesForNonqualifyingEmail[i].Email_Origin__c = freightOrigin.Email__c+'.test';
			}
			else if(modResult==2)
			{
				casesForNonqualifyingEmail[i].Email_Origin__c = 'test'+freightOrigin.Email__c;
			}
		}
		
		for(Integer i = 0; i <casesForQualifyingEmail.size(); i++)
		{
			Integer modResult = Math.mod(i, 5);
			if(modResult==0)
			{
				casesForQualifyingEmail[i].Email_Origin__c = freightOrigin.Email__c;
			}
			else if(modResult==1)
			{
				casesForQualifyingEmail[i].Email_Origin__c = logisticsOrigin.Email__c;
			}
			else if(modResult==2)
			{
				casesForQualifyingEmail[i].Email_Origin__c = logisticsOrigin.Email__c+'; '+freightOrigin.Email__c;
			}
			else if(modResult==3)
			{
				casesForQualifyingEmail[i].Email_Origin__c = sampleEmailNotInCustomSettings+'; '+logisticsOrigin.Email__c;
			}
			else if(modResult==4)
			{
				casesForQualifyingEmail[i].Email_Origin__c = freightOrigin.Email__c+'; '+sampleEmailNotInCustomSettings;
			}
			
		} 
		
		Test.startTest(); 
			List<Case> filteredCases = EmailMessageServices.filterCasesToSearchForContacts(allCases);
		Test.stopTest();
		
		Set<ID> expectedQualifyingCases = Pluck.ids(casesForQualifyingEmail);
		Set<ID> actualQualifyingCases = Pluck.ids(filteredCases);
		System.assertEquals(NUM_QUALIFYING_EMAILS,actualQualifyingCases.size(),'We expect to get back all those cases with have qualifying email origins. An email origin is qualifying if one of the emails listed in it is listed in the \'Email Origins to Search for Contact\' custom setting');
		System.assert(expectedQualifyingCases.containsAll(actualQualifyingCases),'We expect to get each and every case that has a qualifying email origins. An email origin is qualifying if one of the emails listed in it is listed in the \'Email Origins to Search for Contact\' custom setting');
	}
	
	public static testMethod void filterCasesWithoutRoutingErrors()
	{
		Integer NUM_ERROR_CASES = 100;
		Integer NUM_WITHOUT_ERROR_CASES = 75;
		List<Case> errorCases = TestingUtils.createCases(NUM_ERROR_CASES, false);
		List<Case> noErrorCases = TestingUtils.createCases(NUM_WITHOUT_ERROR_CASES, false);
		
		for(Case c : errorCases)
		{
			c.Routing_Error_Reason__c = 'Error';
		}
		for(Case c : noErrorCases)
		{
			c.Routing_Error_Reason__c = null;
		}
		
		List<Case> allCases = new List<Case>();
		allCases.addAll(errorCases);
		allCases.addAll(noErrorCases);
		
		Test.startTest();
			List<Case> filteredCases = EmailMessageServices.filterCasesWithoutRoutingErrors(allCases);
		Test.stopTest();
		
		System.assertEquals(NUM_WITHOUT_ERROR_CASES,noErrorCases.size(),'We expect to get back each and every case that does not have a routing error');
		for(Case c : filteredCases)
		{
			System.assertEquals(null,c.Routing_Error_Reason__c, 'We expect to only get back cases that do not have routing error reasons');
		}
	}
	
	public static testMethod void testFilterCasesToAssignAMBM()
	{
		final String sampleEmailNotInCustomSettings = 'sample@sample.org';
		Email_Origins_E2C_Search_Contact__c noAssignAMBMEmailSetting = new Email_Origins_E2C_Search_Contact__c(Name='Freight Email Address', Email__c='freight@sample.com', Assign_AM_BM__c=False);
		Email_Origins_E2C_Search_Contact__c assignAMBMEmailSetting = new Email_Origins_E2C_Search_Contact__c(Name='Logistics Email Address', Email__c='logistics@sample.com', Assign_AM_BM__c=True);
		
		insert new List<Email_Origins_E2C_Search_Contact__c> {noAssignAMBMEmailSetting,assignAMBMEmailSetting};
		
		Integer NUM_AMBM_CASES = 100;
		Integer NUM_NOT_AMBM_CASES = 100;
		List<Case> casesAssignAMBM = TestingUtils.createCases(NUM_AMBM_CASES, false);
		List<Case> casesNotAssignAMBM = TestingUtils.createCases(NUM_NOT_AMBM_CASES, false);
		
		List<Case> allCases = new List<Case>();
		allCases.addAll(casesAssignAMBM);
		allCases.addAll(casesNotAssignAMBM);
		insert allCases;
		
		for(Integer i = 0; i < casesAssignAMBM.size(); i++)
		{
			Integer modResult = Math.mod(i, 3);
			if(modResult==0)
			{
				casesAssignAMBM[i].Email_Origin__c = sampleEmailNotInCustomSettings+'; '+assignAMBMEmailSetting.Email__c;
			}
			else if(modResult==1)
			{
				casesAssignAMBM[i].Email_Origin__c = noAssignAMBMEmailSetting.Email__c+'; '+assignAMBMEmailSetting.Email__c;
			}
			else if(modResult==2)
			{
				casesAssignAMBM[i].Email_Origin__c = assignAMBMEmailSetting.Email__c;
			}
		}
		
		for(Integer i = 0; i < casesNotAssignAMBM.size(); i++)
		{
			Integer modResult = Math.mod(i, 4);
			if(modResult==0)
			{
				casesNotAssignAMBM[i].Email_Origin__c = sampleEmailNotInCustomSettings;
			}
			else if(modResult==1)
			{
				casesNotAssignAMBM[i].Email_Origin__c = noAssignAMBMEmailSetting.Email__c;
			}
			else if(modResult==2)
			{
				casesNotAssignAMBM[i].Email_Origin__c = assignAMBMEmailSetting.Email__c+'.test';
			}
			else if(modResult==3)
			{
				casesNotAssignAMBM[i].Email_Origin__c = 'dont'+assignAMBMEmailSetting.Email__c;
			}
		}
	
		Test.startTest(); 
			List<Case> filteredCases = EmailMessageServices.filterCasesToAssignAMBM(allCases);
		Test.stopTest();
		
		Set<ID> expectedQualifyingCases = Pluck.ids(casesAssignAMBM);
		Set<ID> actualQualifyingCases = Pluck.ids(filteredCases);
		System.assert(actualQualifyingCases==expectedQualifyingCases,'We expect to accurately determine every case that has an email orgin containing one of the emails tagged in the custom setting as Assign AM/BM');
	}
	//Changed Email address by Sujitha from testworldwide to testworldwide
	public static testMethod void populateContactLookupsOnCases()
	{
		Map<String,Integer> emailToHowManyContactsPerEmail = new Map<String,Integer>();
		emailToHowManyContactsPerEmail.put('g.t@testworldwide.com',2);
		emailToHowManyContactsPerEmail.put('a.t@testworldwide.com',0);
		emailToHowManyContactsPerEmail.put('t.t@testworldwide.com.test',1);
		
		List<Account> testAccounts = TestingUtils.createAccounts('Test Accounts',3);
		insert testAccounts;
		
		Map<String, List<Contact>> emailToContacts = createMapOfEmailToContacts(emailToHowManyContactsPerEmail,null);
		
		// Assign each contact to an account //
		Integer accountIndex = 0;
		for(List<Contact> contactList : emailToContacts.values())
		{
			for(Integer i = 0; i < contactList.size(); i++)
			{
				contactList[i].AccountID = testAccounts[accountIndex].ID;
				accountIndex++;
			}
		}
		
		List<Case> cases = TestingUtils.createCases(emailToHowManyContactsPerEmail.keySet().size(), true);
		
		Map<ID, EmailMessage> caseIdToEmail = new Map<ID, EmailMessage>();
		Integer caseIndex = 0;
		for(String fromEmail : emailToHowManyContactsPerEmail.keySet())
		{
			EmailMessage e = TestingUtils.createEmailMessage(cases[caseIndex].ID);
			e.FromAddress = fromEmail;
			caseIndex++;
			caseIdToEmail.put(e.ParentID,e);
		}
		
		Test.startTest();
			EmailMessageServices.populateContactLookupsOnCases(emailToContacts,cases,caseIdToEmail);
		Test.stopTest();
		
		for(Case c : cases)
		{
			String fromEmail = caseIdToEmail.get(c.ID).FromAddress;
			if(emailToHowManyContactsPerEmail.get(fromEmail)==0)
			{
				System.assertEquals(null,c.AccountID,'We will not populate the account field if no contact is found that matches the email from address');
				System.assertEquals(null,c.ContactID,'We will not populate the contact field if no contact is found that matches the email from address');
				System.assertEquals(EmailMessageServices.CONTACT_NOT_FOUND,c.Routing_Error_Reason__c,'if no contact is found that matches the email from address, we will record that error on the case');
			}
			else if(emailToHowManyContactsPerEmail.get(fromEmail)==1)
			{
				System.assertEquals(emailToContacts.get(fromEmail)[0].ID,c.ContactId,'If there is just one contact that matches the from address of the email that generated the case, then we will populate the contact lookup on the case to that contact');
				System.assertEquals(emailToContacts.get(fromEmail)[0].AccountID,c.AccountID,'If there is just one contact that matches the from address of the email that generated the case, then we will populate the account lookup on the case to the account of the contact');
				System.assertEquals(null,c.Routing_Error_Reason__c, 'If there is just one contact that matches the from address of the email that generated the case, then we will not record an error on the case');
			}
			else
			{
				System.assertEquals(null,c.AccountID,'If we find multiple contacts that match the from address of the email that created the case, then we will not populate the account on the case at all');
				System.assertEquals(null,c.ContactID,'If we find multiple contacts that match the from address of the email that created the case, then we will not populate the contact on the case at all');
				System.assertEquals(EmailMessageServices.DUPLICATE_CONTACTS,c.Routing_Error_Reason__c,'If we find multiple contacts that match the from address of the email that created the case, we will record that error on the case');
			}
		}
	}
	
	private static void assignAMBMToAccounts(List<Account> accts, ID am, ID bm)
	{
		for(Account a : accts)
		{
			a.Account_Manager__c = am;
			a.Account_Manager_Backup__c = bm;
		}
	}
	
	
	private static void specifyExpectedCaseOwner(Map<ID,ID> accountIDtoPSRId, List<Account> accts, ID psrID)
	{
		for(Account a : accts)
		{
			accountIDtoPSRId.put(a.ID,psrID);
		}
	}
	
	private static testMethod void testAssignAMBM()
	{
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		
			UserService.skipSyncingPSRsToUserNetwork = true;
			List<User> inOfficeUsers = TestingUtils.createUsers('Test','Standard User',3,false);
			for(User u : inOfficeUsers)
			{
				u.Working_Status__c = 'In Office';
			}
			
			List<User> outOfOfficeUsers = TestingUtils.createUsers('Test','Standard User',2,false);
			System.runAs ( thisUser ) {
				String outOfOfficeWorkingStatus = (new List<String> (EmailMessageServices.outOfOfficeStatuses))[0];
				for(User u : outOfOfficeUsers)
				{
					u.Working_Status__c = outOfOfficeWorkingStatus;
				}
				
				User inactiveInofficeUser = inOfficeUsers[2];
				inactiveInofficeUser.isActive = false;
				inactiveInofficeUser.Date_Deactivated__c = Date.today();
				inactiveInofficeUser.Deactivation_Reason__c='testing';
				List<User> allUsers = new List<User>();
				allUsers.addAll(inOfficeUsers);
				allUsers.addAll(outOfOfficeUsers);
				insert allUsers;
			}
			
			List<Primary_Sales_Rep__c> inOfficePSRs = new List<Primary_Sales_Rep__c>();
			for(User u : inOfficeUsers)
			{
				Primary_Sales_Rep__c psr = TestingUtils.createPSRs(1, u.CommunityNickname, u.CommunityNickname, false)[0];
				psr.SF_userid__c = u.ID;
				inOfficePSRs.add(psr);
			}
			
			Primary_Sales_Rep__c inactiveInofficePSR = inOfficePSRs[2];

			
			List<Primary_Sales_Rep__c> outOfOfficePSRs = new List<Primary_Sales_Rep__c>();
			for(User u : outOfOfficeUsers)
			{
				Primary_Sales_Rep__c psr = TestingUtils.createPSRs(1, u.CommunityNickname, u.CommunityNickname, false)[0];
				psr.SF_userid__c = u.ID;
				outOfOfficePSRs.add(psr);
			}
			
			List<Primary_Sales_Rep__c> allPSRs = new List<Primary_Sales_Rep__c>();
			allPSRs.addAll(outOfOfficePSRs);
			allPSRs.addAll(inOfficePSRs);
			insert allPSRs;
			
			final Integer accountCategorySize = 10;
			
			List<Account> accts_AMInOffice_BMInoffice = TestingUtils.createAccounts('Test Account', accountCategorySize);
			List<Account> accts_AMInOfficeButInactive_BMInoffice = TestingUtils.createAccounts('Test Account', accountCategorySize);
			List<Account> accts_AMInOffice_BMOutOfOffice = TestingUtils.createAccounts('Test Account', accountCategorySize);
			List<Account> accts_AMInOffice_BMNull = TestingUtils.createAccounts('Test Account', accountCategorySize);
			List<Account> accts_AMOutOfOffice_BMInoffice = TestingUtils.createAccounts('Test Account', accountCategorySize);
			//List<Account> accts_AMOutOfOffice_BMInofficeButInactive = TestingUtils.createAccounts('Test Account', accountCategorySize);
			List<Account> accts_AMOutOfOffice_BMOutOfOffice = TestingUtils.createAccounts('Test Account', accountCategorySize);
			List<Account> accts_AMOutOfOffice_BMNull = TestingUtils.createAccounts('Test Account', accountCategorySize);
			List<Account> accts_AMNull_BMInoffice = TestingUtils.createAccounts('Test Account', accountCategorySize);
			// List<Account> accts_AMNull_BMOutOfOffice = TestingUtils.createAccounts('Test Account', accountCategorySize);
			// List<Account> accts_AMNull_BMNull = TestingUtils.createAccounts('Test Account', accountCategorySize);
			assignAMBMToAccounts(accts_AMInOffice_BMInoffice,inOfficePSRs[0].ID,inOfficePSRs[1].ID);
			assignAMBMToAccounts(accts_AMInOfficeButInactive_BMInoffice,inactiveInofficePSR.ID,inOfficePSRs[1].ID);
			assignAMBMToAccounts(accts_AMInOffice_BMOutOfOffice,inOfficePSRs[0].ID,outOfOfficePSRs[0].ID);
			assignAMBMToAccounts(accts_AMInOffice_BMNull,inOfficePSRs[0].ID,null);
			assignAMBMToAccounts(accts_AMOutOfOffice_BMInoffice,outOfOfficePSRs[0].ID,inOfficePSRs[1].ID);
			//assignAMBMToAccounts(accts_AMOutOfOffice_BMInofficeButInactive,outOfOfficePSRs[0].ID,inactiveInofficePSR.ID);
			assignAMBMToAccounts(accts_AMOutOfOffice_BMOutOfOffice,outOfOfficePSRs[0].ID,outOfOfficePSRs[1].ID);
			assignAMBMToAccounts(accts_AMOutOfOffice_BMNull,outOfOfficePSRs[0].ID,null);
			
			assignAMBMToAccounts(accts_AMNull_BMInoffice,null,inOfficePSRs[1].ID);
			Set<Account> setTestAccounts = new Set<Account>();
			setTestAccounts.addAll(accts_AMInOffice_BMInoffice);
			setTestAccounts.addAll(accts_AMInOfficeButInactive_BMInoffice);
			setTestAccounts.addAll(accts_AMInOffice_BMOutOfOffice);
			setTestAccounts.addAll(accts_AMInOffice_BMNull);
			setTestAccounts.addAll(accts_AMOutOfOffice_BMInoffice);
			setTestAccounts.addAll(accts_AMNull_BMInoffice);
			List<Account> testAccounts = new List<Account>(setTestAccounts);
			Database.insert(testAccounts, false);		

			Map<ID, ID> accountIDToExpectedCaseOwner = new Map<ID, ID>();
			specifyExpectedCaseOwner(accountIDToExpectedCaseOwner,accts_AMInOffice_BMInoffice, inOfficePSRs[0].SF_userid__c);
			specifyExpectedCaseOwner(accountIDToExpectedCaseOwner,accts_AMInOfficeButInactive_BMInoffice,inOfficePSRs[1].SF_userid__c);
			specifyExpectedCaseOwner(accountIDToExpectedCaseOwner,accts_AMInOffice_BMOutOfOffice, inOfficePSRs[0].SF_userid__c);
			specifyExpectedCaseOwner(accountIDToExpectedCaseOwner,accts_AMInOffice_BMNull, inOfficePSRs[0].SF_userid__c);
			specifyExpectedCaseOwner(accountIDToExpectedCaseOwner,accts_AMOutOfOffice_BMInoffice,inOfficePSRs[1].SF_userid__c);
			specifyExpectedCaseOwner(accountIDToExpectedCaseOwner,accts_AMNull_BMInoffice,inOfficePSRs[1].SF_userid__c);
			List<Contact> testContacts = new List<Contact>(); 
			for(Account acct : testAccounts)
			{
				Contact c = TestingUtils.createContacts('Test', 1, false)[0];
				c.AccountID = acct.ID;
				testContacts.add(c);
			}
			 insert testContacts;
			List<Case> testCases = new List<Case>();
			for(Contact contact : testContacts)
			{
				Case c = TestingUtils.createCases(1, false)[0];
				c.ContactID=contact.ID;
				c.AccountID=contact.AccountID;
				testCases.add(c);
			}
			insert testCases;
		
		Test.startTest();
			List<Case> casesToUpdate = EmailMessageServices.assignAMBM(testCases);
		Test.stopTest();
		
		System.assertEquals(accountIDToExpectedCaseOwner.size(),casesToUpdate.size(),'We expect to get back every case that has either an in-office account manager or an in-office backup manager');
		for(Case c : casesToUpdate)
		{
			System.assertEquals(accountIDToExpectedCaseOwner.get(c.AccountID),c.OwnerID,'For cases that have either an in office account manager or an in office backup manager, we expect to update the case to assign it to the right manager. Try assigning to account manager if in office. Otherwise, we must assign to the backup manager if in office');
		}
	}
	
	private static testMethod void setOwnerAssignedByCode()
	{
		final Integer NUM_CASES = 100;
		List<Case> cases = TestingUtils.createCases(NUM_CASES, false);
		for(Case c : cases)
		{
			c.Owner_Assigned_by_Code__c = false;
		}
		
		Test.startTest();
			EmailMessageServices.setOwnerAssignedByCode(cases);
		Test.stopTest();
		
		for(Case c : cases)
		{
			System.assert(c.Owner_Assigned_by_Code__c,'Every case must be marked as having its owner assigned by code');
		}
	}
	
	private static testMethod void testUpdateCasesAndReturnErrorsIfAny_WhenErrors()
	{
		Account testAccount = TestingUtils.createAccount('Test Account');
		insert testAccount;
		
		Case testCase = TestingUtils.createCases(1, true)[0];
		testCase.AccountID = testAccount.ID;
		delete testAccount;

		Test.startTest(); 
			String errorString = EmailMessageServices.updateCasesAndReturnErrorsIfAny(new Set<ID> {testCase.ID}, new List<Case> {testCase});
		Test.stopTest();
		
		System.assert(errorString.contains(testCase.ID),'We must keep track of the the case that failed to update');
	}
	
	private static testMethod void testFilterCasesToParse()
	{
		List<Case> cases = TestingUtils.createCases(200, false);
		UnitTest.addData(cases).divide(2).part('Case To Parse').part('Case To Ignore');
		UnitTest.get(Case.SObjectType).dummyInsert();
		
		UnitTest.forEach('Case To Parse').create(1,TestingUtils.emailMessages).copyProperty('ID->ParentID').tag('Email To Parse');
		UnitTest.forEach('Case To Ignore').create(1,TestingUtils.emailMessages).copyProperty('ID->ParentID').tag('Email To Ignore');
		
		/* Terminology: A Response Email is an email that has either RE or FWD */
		
		UnitTest.get('Email To Parse').divide(3).part('Response Email Without Case Ref Number')
												.part('NonResponse Email With Case Ref Number')
											    .part('NonResponse Email Without Case Ref Number');
		
		UnitTest.get('Email To Ignore').divide(2).part('Response Email With Case Ref Number').part('Email With Invalid Subject');

		List<String> bodyWithoutRef = new List<String>{'', null, 'ref:00DQ0H6OwY._500Q055mpA:ref',
													   'Hello,\n Sample email body without reference number 124141351\n\n Goodbye'};
		List<String> bodyWithRef    = new List<String>{'ref:_','ref:_00DQ0H6OwY._500Q055mpA:ref',
													   'Hello,\n Sample email body\n ref:_00DQ0H6OwY._500Q055mpA:ref\n Bye',
													   'Hello,\n Sample email body\n REF:_00DQ0H6OwY._500Q055mpA:ref\n Bye'};
		List<String> responseSubjects    = new List<String>{'RE: Subject Text', 'FWD: Subject Text', 'RE: RE: Subject Text', 'FWD: FWD: Subject Text', 
														    're: Subject Text', 'fwd: Subject Text', 're: re: Subject Text', 'fwd: fwd: Subject Text'	};
		List<String> nonresponseSubjects = new List<String>{'Reply: Subject Text', 'Forward: Subject Text', 'Subject RE:', 'Subject FWD:', 'Hello'};
		List<String> invalidSubjects = new List<String>{'', null};
		
		UnitTest.get('Response Email Without Case Ref Number').property('Subject').assignFrom(responseSubjects)
															  .property('TextBody').assignFrom(bodyWithoutRef);
		UnitTest.get('NonResponse Email With Case Ref Number').property('Subject').assignFrom(nonresponseSubjects)
															  .property('TextBody').assignFrom(bodyWithRef);
		UnitTest.get('NonResponse Email Without Case Ref Number').property('Subject').assignFrom(nonresponseSubjects)
															  .property('TextBody').assignFrom(bodyWithoutRef);
		UnitTest.get('Response Email With Case Ref Number').property('Subject').assignFrom(responseSubjects)
															  .property('TextBody').assignFrom(bodyWithRef);	
		UnitTest.get('Email With Invalid Subject').property('Subject').assignFrom(invalidSubjects)
												  .property('TextBody').assignFrom(bodyWithoutRef);
		
		Test.startTest();
			List<Case> filteredCases = EmailMessageServices.filterCasesToParse(cases,createCaseIDToEmailMessageMap());
		Test.stopTest();
		
		UnitTest.analyze('Case To Parse').assertEquivalence(filteredCases,'We will only get back cases that link to qualifying emails. An email qualifies unless the subject has "FWD:" or "RE:", as well as "ref:_" in the body');												  												  													  													  
	}
	
	private static Map<ID, EmailMessage> createCaseIDToEmailMessageMap()
	{
		Map<ID, EmailMessage> caseIDToEmailMessage = new Map<ID, EmailMessage>();
		for(EmailMessage e : (List<EmailMessage>) UnitTest.get(EmailMessage.SObjectType).getList())
		{
			caseIDToEmailMessage.put(e.ParentID, e);
		}
		return caseIDToEmailMessage;
	}
	
	private static testMethod void testParseFreightSubjects()
	{	
		UnitTest.createTestData(TestingUtils.cases).single().tag('PreExisting Master Cases').tag('Master Case for Order Number 98765').assign('Order_Number__c','98765');
		UnitTest.createTestData(TestingUtils.cases).single().tag('PreExisting Master Cases').tag('Master Case for Order Number 12345').assign('Order_Number__c','12345');
		UnitTest.get('PreExisting Master Cases').insertAll();
		UnitTest.createTestData(TestingUtils.cases).single().tag('PreExisting Child Cases').tag('Child Case for Order Number 12345').assign('Order_Number__c','12345')
																						   .property('ParentID').assignFrom('Master Case for Order Number 12345');
		UnitTest.get('PreExisting Child Cases').insertAll();
		
		UnitTest.createTestData(TestingUtils.cases).many(20).tag('Case To Parse').newAttribute('*Email Subject*').assign('TEST88376 PU Appt Required - WRIGHT\'S PRINTING - 09/13/2013 ')
																				 .newAttribute('*Expected Order#*').assign('88376')
																				 .newAttribute('*Expected Delivery Date*').assign(Date.parse('09/13/2013'))
																				 .newAttribute('*Expected Parent*').assign(null);
		
		UnitTest.createTestData(TestingUtils.cases).many(20).tag('Case To Parse').newAttribute('*Email Subject*').assign('1234567890 PU APPT REQUIRED - WRIGHTS PRINTING WRIGHTS PRINTING - 01/13/1997 ')
																				 .newAttribute('*Expected Order#*').assign('1234567890')
																				 .newAttribute('*Expected Delivery Date*').assign(Date.parse('01/13/1997'))
																				 .newAttribute('*Expected Parent*').assign(null);															 
		
		UnitTest.createTestData(TestingUtils.cases).many(20).tag('Case To Parse').newAttribute('*Email Subject*').assign('rE: RE:  TEST98765    LIFT GATE      - WRIGHTS PRINTING -     09/13/2004      ')
																				 .newAttribute('*Expected Order#*').assign('98765')
																				 .newAttribute('*Expected Delivery Date*').assign(Date.parse('09/13/2004'))
																				 .newAttribute('*Expected Parent*').assignFrom('Master Case for Order Number 98765');
		
		UnitTest.createTestData(TestingUtils.cases).many(20).tag('Case To Parse').newAttribute('*Email Subject*').assign('fwd: RE:RE: TEST12345 Lift Gate - WRIGHTS PRINTING - 09/13/2013 ')
																				 .newAttribute('*Expected Order#*').assign('12345')
																				 .newAttribute('*Expected Delivery Date*').assign(Date.parse('09/13/2013'))
																				 .newAttribute('*Expected Parent*').assignFrom('Master Case for Order Number 12345');
																				 
		UnitTest.createTestData(TestingUtils.cases).many(20).tag('Case To Parse').newAttribute('*Email Subject*').assign('Re: TEST88376 Guaranteed - WRIGHTS PRINTING -   09/13/2013 ')
																				 .newAttribute('*Expected Order#*').assign('88376')
																				 .newAttribute('*Expected Delivery Date*').assign(Date.parse('09/13/2013'))
																				 .newAttribute('*Expected Parent*').assign(null);														 																		 
		
		UnitTest.createTestData(TestingUtils.cases).many(20).tag('Case To Parse').newAttribute('*Email Subject*').assign('re: Fwd: 97542 GUARANTEED - WRIGHT PRINTING - 09/13/2013 ')
																				 .newAttribute('*Expected Order#*').assign('97542')
																				 .newAttribute('*Expected Delivery Date*').assign(Date.parse('09/13/2013'))
																				 .newAttribute('*Expected Parent*').assign(null);
		
		List<String> invalidSubjects = new List<String> {'RE: FWD: 1234 GUARANTEED - ACC1 - 09/13/2013','RE: FWD: 12345 GUARANTEED - ACC2 - 9/13/13',
													   'RE: FWD: 12345 GUARANTEED - j - 22 09/13/2013 ', 'RE: FWD: 12345 GUARANTEED - ACC1 - extratext 09/13/2013',
													   'EST12345 1234 GUARANTEED - ACC1 - 09/13/2013', 'TET12345 1234 GUARANTEED - ACC1 - 09/13/2013',
													   'RE: FWD: 12345 GUARANTEED - ACC2 - 091313', 'RE: FWD: 12345 GUARANTEED - ACC2 - 09/13/13'};
													   																			 
		UnitTest.createTestData(TestingUtils.cases).many(75).tag('Case To Not Parse').newAttribute('*Email Subject*').assignFrom(invalidSubjects); 	
			
		UnitTest.get('Case To Parse').tag('Incoming Cases');
		UnitTest.get('Case To Not Parse').tag('Incoming Cases');
		
		UnitTest.get('Incoming Cases').dummyInsert();								 																	 	
		UnitTest.forEach('Incoming Cases').create(1,TestingUtils.emailMessages).copyProperty('ID->ParentID').copyProperty('*Email Subject*->Subject');	
		
		List<Case> incomingCases = UnitTest.get('Incoming Cases').getList();
		
		Test.startTest();
			List<Case> parsedCases = EmailMessageServices.parseFreightSubjects(incomingCases,createCaseIDToEmailMessageMap());
		Test.stopTest();
		
		UnitTest.analyze('Case To Parse').assertEquivalence(parsedCases, 'We will only get back cases that have a valid subject and can consequently be parsed');						
		
		for(Case parsedCase : parsedCases)
		{
			String expectedOrderNumber = (String) UnitTest.analyze('Case To Parse').selectById(parsedCase.ID).getPropertyValue('*Expected Order#*');
			//String expectedSenderEmail = (String) UnitTest.analyze('Case To Parse').selectById(parsedCase.ID).getPropertyValue('*Expected Sender Email*');
			Date expectedDeliveryDate = (Date) UnitTest.analyze('Case To Parse').selectById(parsedCase.ID).getPropertyValue('*Expected Delivery Date*');
			Id expectedParent = (ID) UnitTest.analyze('Case To Parse').selectById(parsedCase.ID).getPropertyValue('*Expected Parent*');
			
			System.assertEquals(expectedOrderNumber, parsedCase.Order_Number__c, 'The expected order number was not found in the Order_Number__c field of the parsed Case');
			//System.assertEquals(expectedSenderEmail, parsedCase.Sender_s_Email__c, 'The expected sender\'s email was not found in the Senders Email of the pared Case' );
			System.assertEquals(expectedDeliveryDate, parsedCase.Delivery_Date__c, 'The expected delivery date was not found in the Delivery_Date__c field of the parsed Case');
			System.assertEquals(expectedParent, parsedCase.ParentID, 'For any response case with an order number that matches the order number of a preexisting case, we expect to link that case with the master parent case with the same order number');
		}
		
	}
	
	static testMethod void testFilterInternalCases(){
		
		List<Case> cases = TestingUtils.createCases(200, true);
		UnitTest.addData(cases).tag('Cases').divide(2).part('Cases with Internal Emails').part('Cases with External Emails');
		
		UnitTest.forEach('Cases with Internal Emails').create(1,TestingUtils.emailMessages).copyProperty('ID->ParentID').tag('internal email messages');
		UnitTest.forEach('Cases with External Emails').create(1,TestingUtils.emailMessages).copyProperty('ID->ParentID').tag('external email messages');
				
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702

		//List<App_Domain_Restrictions__c> appDomainRestrictions = TestingUtils.createDomainRestrictions('test.com', 2, 'USD', false);
		
		List<String> nonInternalEmails = new List<String>{'test@hotmail.com', 'test@gmail.com'};  
		
		//Set<String> internalEmailDomains = Pluck.strings('domain__c', appDomainRestrictions);
		//List<String> internalEmails = new List<String>();
		
	/*	for(String emailDomain: internalEmailDomains){
			internalEmails.add('test@' + emailDomain);
			nonInternalEmails.add('test@prefix' + emailDomain);
			nonInternalEmails.add('test@' + emailDomain + 'suffix');
		}*/
		
		//appDomainRestrictions[1].Domain__c = appDomainRestrictions[1].Domain__c.toUpperCase();
		//insert appDomainRestrictions;
		
		//UnitTest.get('internal email messages').property('FromAddress').assignFrom(internalEmails);
		UnitTest.get('external email messages').property('FromAddress').assignFrom(nonInternalEmails);
		
		Test.startTest();
			//List<Case> filteredInternalCases = EmailMessageServices.filterInternalCases(cases, createCaseIDToEmailMessageMap()); 
		Test.stopTest();
				// Commented by Sujitha all the FS Audit  related functionality Backlog #702

	//	UnitTest.analyze('Cases with Internal Emails').assertEquivalence(filteredInternalCases,'Cases that link to internal emails must be correctly identified');
	}

	static testMethod void testStampFromAddress()
	{
		String TEST_EMAIL = 'test@test.com';
		List<Case> testCases = TestingUtils.createCases(20, true);
		List<EmailMessage> testEmailMessages = TestingUtils.createEmailMessages(null, 20);

		List<Id> caseIds = new List<Id>(pluck.Ids(testCases));
		UnitTest.addData(testEmailMessages).tag('all Emails').property('parentId').assignFrom(caseIds)
				.property('FromAddress').assign(TEST_EMAIL);

		Map<Id,EmailMessage> caseIdToEmail = new Map<Id,EmailMessage>();
		for( EmailMessage emessage : testEmailMessages)
		{
			caseIdToEmail.put(emessage.parentId, emessage);
		}

		Test.startTest();
			EmailMessageServices.stampFromAddress(testCases,  caseIdToEmail);
		Test.stopTest();
		
		for(Case eachCase: testCases)
		{
			System.assertEquals(TEST_EMAIL, eachCase.From_Address_of_Originating_Email__c, 
								'the From_Address_of_Originating_Email__c of Case must be populated with the FromAddress of EmailMessage');
		}	
	}

	static testMethod void testGetCaseIDToOnlyIncomingEmailMessageMap() {
		UnitTest.createTestData(TestingUtils.cases).many(100).tag('Case').divide(2).part('Case With Incoming Email').part('Case With Outgoing Email');
		UnitTest.get('Case').dummyInsert();

		UnitTest.forEach('Case With Incoming Email')
			.create(1,TestingUtils.emailMessages)
			.tag('Email To Return').tag('Email')
			.copyProperty('ID->ParentID');
		UnitTest.get('Email To Return').property('Incoming').assign(true);
		UnitTest.forEach('Case With Outgoing Email')
			.create(1,TestingUtils.emailMessages)
			.tag('Email To Not Return').tag('Email')
			.copyProperty('ID->ParentID');
		UnitTest.get('Email To Not Return').property('Incoming').assign(false);
		UnitTest.get('Email').dummyInsert();

		Map<Id, EmailMessage> testCaseIDToEmail = createCaseIDToEmailMessageMap();

		Map<Id, EmailMessage> actual_filteredMap = 
			EmailMessageServices.getCaseIDToOnlyIncomingEmailMessageMap(testCaseIDToEmail);

		Set<Id> expectedCaseIds = UnitTest.getIds('Case With Incoming Email');
		System.assertEquals(expectedCaseIds, actual_filteredMap.keySet(), 
			'The expected list of CaseIds with Incoming emails was not returned');
		for (Id actual_caseID : actual_filteredMap.keySet()) {
			System.assertEquals(testCaseIDToEmail.get(actual_caseID).Id, actual_filteredMap.get(actual_caseID).Id,
				'The associated email was unexpectedly changed');
		}
	}

	static testMethod void testSendBatchCompletedEmail_withErrors(){
		User testUser = TestingUtils.createUser('MarkyZ', 'Sales Professional - Lightning', /*doInsert*/ false);
		testUser.Email = 'test@example.com';
		insert testUser;
		setupErrorEmailRecips(testUser.Id);

		List<String> errors = new List<String>{'A', 'B', 'C', '4', 'V'};

		Test.startTest();
			EmailMessageServices.sendBatchCompletedEmail(errors, 'TEST ERROR');
			Integer actualEmailCount = Limits.getEmailInvocations();
		Test.stopTest();
		
		System.assertEquals(1, actualEmailCount, 'We expect 1 email to be sent');
	}

	static testMethod void testSendBatchCompletedEmail_noErrors(){
		User testUser = TestingUtils.createUser('MarkyZ', 'Sales Professional - Lightning', /*doInsert*/ false);
		testUser.Email = 'test@example.com';
		insert testUser;
		setupErrorEmailRecips(testUser.Id);

		Test.startTest();
			EmailMessageServices.sendBatchCompletedEmail(new List<String>(), 'TEST NO ERROR');
			Integer actualEmailCount = Limits.getEmailInvocations();
		Test.stopTest();
		System.assertEquals(1, actualEmailCount, 'We expect 1 email to be sent');
	}
	
	static testMethod void testSendBatchCompletedEmail_MultipleUsers(){
		
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs ( thisUser ) {
			User testUser = TestingUtils.createUser('MarkyZ', 'System Administrator', /*doInsert*/ false);
			testUser.Email = 'test@example.com';
			insert testUser;
			
			Apex_Class_Error_Emails__c newCs1 = new Apex_Class_Error_Emails__c();
			newCs1.Name = 'TEST CS1 NAME';
			newCs1.User_ID__c = testUser.Id;
			
			User testUserToo = TestingUtils.createUser('ZarkyM', 'System Administrator', /*doInsert*/ false);
			testUser.Email = 'testie@example.com'; 
			insert testUserToo;
			
			Apex_Class_Error_Emails__c newCs2 = new Apex_Class_Error_Emails__c();
			newCs2.Name = 'TEST CS2 NAME';
			newCs2.User_ID__c = testUserToo.Id;
			insert new List<Apex_Class_Error_Emails__c>{ newCs1, newCs2 };
		}

		Test.startTest();
			EmailMessageServices.sendBatchCompletedEmail(new List<String>(), 'TEST NO ERROR');
			Integer actualEmailCount = Limits.getEmailInvocations();
		Test.stopTest();
		System.assertEquals(1, actualEmailCount, 'We expect 1 email call');
	}
	
	static testMethod void testSendBatchCompletedEmail_noCS(){ 

		Test.startTest();
			EmailMessageServices.sendBatchCompletedEmail(new List<String>(), 'TEST NO ERROR');
			Integer actualEmailCount = Limits.getEmailInvocations();
		Test.stopTest();
		System.assertEquals(0, actualEmailCount, 'We expect no emails to be sent');
	}

	@isTest static void processCaseFirstEmailResponseTrackingTest(){
		Integer expectedSize = 1;
		//create case
		Case testCase = (Case) new SObjectBuilder(Case.SObjectType)
			.create()
			.getRecord();
		//create an incoming email message
		EmailMessage firstEmail = (EmailMessage) new SObjectBuilder(EmailMessage.SObjectType)
			.put(EmailMessage.Incoming,true)
			.put(EmailMessage.ParentId,testCase.Id)
			.create()
			.getRecord();
		//create another email message
		EmailMessage replyEmail = (EmailMessage) new SObjectBuilder(EmailMessage.SObjectType)
			.put(EmailMessage.ReplyToEmailMessageId,firstEmail.Id)
			.put(EmailMessage.ParentId,testCase.Id)
			.build()
			.getRecord();

		Test.startTest();
			insert replyEmail;
		Test.stopTest();

		List<Case_Durations__c> durations = [
            SELECT Id, Value__c, Previous_Value__c, Type__c 
            FROM Case_Durations__c 
            WHERE Parent__c =: testCase.Id
                  AND Type__c =: CaseResponseTrackingServices.FIRST_EMAIL_RESPONSE
        ];
        //System.assertEquals(expectedSize, durations.size(), 'We expect to get back the correct number of durations');
	}
}
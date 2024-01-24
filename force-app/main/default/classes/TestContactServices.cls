@isTest
private class TestContactServices {
	static final String ULS_ACCOUNT_NAME = 'Test 3PL';
    static final Id CONTACT_VENDOR_RECORDTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor Contact').getRecordTypeId();
    static final Id ACCOUNT_VENDOR_RECORDTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();

    
    static String OLD_USER_NAME = 'tuser1';
    static String NEW_USER_NAME = 'tuser2';
    
    static String PROFILE_NAME = 'Standard User';
    static User oldContactOwner;
    public static User newContactOwner;
    
    public static String CANADIAN_CURENCY_CODE = 'CAD';
    public static String US_CURRENCY_CODE = 'USD';

    public static Boolean EXPECTED_OPT_OUT_VALUE = true;
	
	static
	{
		List<RecordType> caseRecordTypes = [Select ID From RecordType Where SObjectType='Case' And IsActive=True Limit 1];
		insert (new InactiveRecordTypes__c(Name=CaseServices.EBUSINESS_RT_NAME,Record_Type_Id__c=caseRecordTypes[0].ID));
	}

    public static void propagateTriggerSetupData() {
        oldContactOwner = TestingUtils.createUser(OLD_USER_NAME, PROFILE_NAME, false);
        oldContactOwner.DefaultCurrencyIsoCode  = US_CURRENCY_CODE;
        
        newContactOwner = TestingUtils.createUser(NEW_USER_NAME, PROFILE_NAME, false);
        newContactOwner.DefaultCurrencyIsoCode  = CANADIAN_CURENCY_CODE;
        
        System.runAs(TestingUtils.ADMIN_USER)
        {
            insert newContactOwner;
        }

        UnitTest.addData((List<Contact>) SObjectFactory.build(10, Contact.SObjectType))
                .tag('All Contacts')
                .branch('Old Contacts | New Contacts');

        UnitTest.get('Old Contacts')
            .property('Email').assign('test@test.com')
            .property('HasOptedOutOfEmail').assign(EXPECTED_OPT_OUT_VALUE);

        System.runAs(oldContactOwner) {
            insert UnitTest.get('Old Contacts').getList();
        }
    }
	
	static testMethod void testFilterContactsWithULSAccounts()
    {
        UnitTest.addData(TestingUtils.createULSAccounts(10, 'Test', false)).assign('Is_ULS_Primary_Acct__c',true).tag('ULS Accounts');
       	UnitTest.addData(TestingUtils.createAccounts('Test',20)).tag('NonULS Accounts');
       	UnitTest.get(Account.SObjectType).insertAll();
       	
       	UnitTest.addData(TestingUtils.createContacts('Contact', 200, false)).divide(3).part('ULS Contacts').part('NonULS Contacts').part('Contacts without Accounts');
       	UnitTest.get('ULS Contacts').property('AccountID').assignFrom('ULS Accounts');
       	UnitTest.get('NonULS Contacts').property('AccountID').assignFrom('NonULS Accounts');
       	UnitTest.get(Contact.SObjectType).insertAll();
       	
       	Test.startTest();
       		List<Contact> filteredContacts = ContactServices.filterContactsFromULSAccounts((List<Contact>)UnitTest.get(Contact.SObjectType).getList());
       	Test.stopTest();
       	
       	UnitTest.analyze('ULS Contacts').assertEquivalence(filteredContacts, 'Every contact we get back must be a contact that has a parent account which is a ULS account');
    }
	
	static testMethod void testFilterContactsFromPublisherAction()
	{
		UnitTest.addData(TestingUtils.createContacts('Contact', 200, false)).divide(2).part('Contacts Created By Quick Create').part('Other Contacts');
		UnitTest.get('Contacts Created By Quick Create').assign('Created_by_Quick_Create__c',true);
		UnitTest.get(Contact.SObjectType).dummyInsert();
		
		Test.startTest();
			List<Contact> contacts = ContactServices.filterContactsFromPublisherAction(UnitTest.get(Contact.SObjectType).getList()); 
		Test.stopTest();
		
		UnitTest.analyze('Contacts Created By Quick Create').assertEquivalence(contacts, 'Every contact we get back must be a contact tagged as having been created by quick create');
	}
	
	static testMethod void testGroupContactsByFromAddress()
	{
		List<String> emailAddresses = new List<String>{'abc@gmail.com','123@gmail.com','tiago5@gmail.com','tiago@gmail.com','1tiago@gmail.com','tiagoa@gmail.com'};
		UnitTest.addData(TestingUtils.createContacts('Contact', emailAddresses.size(), false)).property('Email').assignFrom(emailAddresses);
		UnitTest.get(Contact.SObjectType).dummyInsert();
		
		Test.startTest();
			Map<String, Contact> emailToContact = ContactServices.groupContactsByFromAddress(UnitTest.get(Contact.SObjectType).getList());
		Test.stopTest();
		
		System.assertEquals(new Set<String>(emailAddresses), emailToContact.keySet(), 'We must detect every single email address found in the specified list of cases');
		for(String email : emailToContact.keySet())
		{
			System.assertEquals(email,emailToContact.get(email).Email, 'The contacts must be correctly grouped by their email addresses');
		}
	}

	static testMethod void testAssociateCasesWithContact()
	{
		Integer totalCases = 200;
		
		final String emailA = 'emaila@gmail.com';
		final String emailB = 'emailb@gmail.com';
		final String emailC = 'emailc@gmail.com';
		final String emailD = 'emaild@gmail.com';
		UnitTest.createTestData(TestingUtils.cases).many(totalCases).divide(3).part('Cases for Email A').part('Cases for Email B').part('Cases for Email C');
		UnitTest.get(Case.SObjectType).dummyInsert();
		
		Map<String, List<Case>> emailToCase = new Map<String, List<Case>>();
		emailToCase.put(emailA, UnitTest.get('Cases for Email A').getList());
		emailToCase.put(emailB, UnitTest.get('Cases for Email B').getList());
		emailToCase.put(emailC, UnitTest.get('Cases for Email C').getList());
		
		UnitTest.addData(TestingUtils.createAccounts('Test Accounts', 2)).tag('Accounts').dummyInsert();
		
		List<Contact> contacts = TestingUtils.createContacts('Contact', 4, false);
		UnitTest.addData(contacts).tag('Contacts').property('AccountID').assignFrom('Accounts').dummyInsert();
		
		Map<String, Contact> emailToContact = new Map<String, Contact>();
		emailToContact.put(emailA, contacts[0]);
		emailToContact.put(emailB, contacts[1]);
		emailToContact.put(emailC, contacts[2]);
		emailToContact.put(emailD, contacts[3]);
		
		Test.startTest();
			List<Case> casesToUpdate = ContactServices.associateCasesWithContact(emailToCase,emailToContact);
		Test.stopTest();
		
		System.assertEquals(totalCases, casesToUpdate.size(), 'We expect to get back each specified case');
		for(Case c : casesToUpdate)
		{
			if(UnitTest.analyze('Cases for Email A').hasID(c.Id))
			{
				System.assertEquals(contacts[0].Id,c.ContactID, 'All cases must be associated to a contact that has a matching email address');
			}
			else if(UnitTest.analyze('Cases for Email B').hasID(c.Id))
			{
				System.assertEquals(contacts[1].Id,c.ContactID, 'All cases must be associated to a contact that has a matching email address');
			}
			else if(UnitTest.analyze('Cases for Email C').hasID(c.Id))
			{
				System.assertEquals(contacts[2].Id,c.ContactID, 'All cases must be associated to a contact that has a matching email address');
			}
			else
			{
				System.assert(false,'We cannot delete or create any new cases');
			}
			ID expectedAccountID = (ID) UnitTest.analyze('Contacts').selectByID(c.ContactID).getPropertyValue('AccountID');
			System.assertEquals(expectedAccountID,c.AccountID, 'All cases must be associated to the account of the contact that they are associated with');
		}
	}
	
	static testMethod void Test_getRelatedAccounts()
	{
		List<Account> testAccount = (List<Account>) SObjectFactory.create(100, Account.SObjectType);
		List<Contact> testContacts = (List<Contact>) SObjectFactory.build(50, Contact.SObjectType);
		UnitTest.addData(testContacts).tag('All Contacts');
		UnitTest.addData(testAccount).tag('All Accounts').divide(2).part('Accounts with Contacts').part('Accounts without Contacts');
        UnitTest.get('All Contacts').property('AccountId').assignFrom('Accounts with Contacts');
        UnitTest.get('All Contacts').insertAll();
		
		Test.startTest();
			List<Account> resultAccounts = ContactRollupOnAccount.getRelatedAccounts( UnitTest.get('All Contacts').getList() );
		Test.stopTest();
		
		UnitTest.analyze('Accounts with Contacts').assertEquivalence(resultAccounts, 'We expect the correct Accounts to be returned.');
	}
	
	static testMethod void Test_rollupContactsOnAccounts()
	{
		List<Account> testAccount = (List<Account>) SObjectFactory.create(50, Account.SObjectType);
		List<Contact> testContacts = (List<Contact>) SObjectFactory.build(50, Contact.SObjectType);
		UnitTest.addData(testContacts).tag('All Contacts');
		UnitTest.addData(testAccount).tag('All Accounts');
        UnitTest.get('All Contacts').property('AccountId').assignFrom('All Accounts');
        UnitTest.get('All Contacts').insertAll();
		
		Test.startTest();
			ContactRollupOnAccount.rollupContactsOnAccounts( UnitTest.get('All Contacts').getList() );
		Test.stopTest();
		
		List<Account> requeriedAccounts = [SELECT Id, Number_of_Contacts__c FROM Account];
		for(Account acc : requeriedAccounts)
		{
			System.assertEquals(1, acc.Number_of_Contacts__c, 'We expect each Account to have a sum of 1 contact.'); 
		}
	}
	
	static testMethod void Test_rollupContactsOnAccounts_ManyContacts()
	{
		List<Account> testAccount = (List<Account>) SObjectFactory.create(5, Account.SObjectType);
		List<Contact> testContacts = (List<Contact>) SObjectFactory.build(50, Contact.SObjectType);
		UnitTest.addData(testContacts).tag('All Contacts');
		UnitTest.addData(testAccount).tag('All Accounts');
        UnitTest.get('All Contacts').property('AccountId').assignFrom('All Accounts');
        UnitTest.get('All Contacts').insertAll();
		
		Test.startTest();
			ContactRollupOnAccount.rollupContactsOnAccounts( UnitTest.get('All Contacts').getList() );
		Test.stopTest();
		
		List<Account> requeriedAccounts = [SELECT Id, Number_of_Contacts__c FROM Account];
		for(Account acc : requeriedAccounts)
		{
			System.assertEquals(10, acc.Number_of_Contacts__c, 'We expect each Account to have a sum of 10 Contacts.');
		}
	}
	
	static testMethod void Test_rollupContactsOnAccounts_ActiveVsInactive()
	{
		List<Account> testAccount = (List<Account>) SObjectFactory.create(2, Account.SObjectType);
		List<Contact> testContacts = (List<Contact>) SObjectFactory.build(40, Contact.SObjectType);
		UnitTest.addData(testContacts).tag('All Contacts').divide(2).part('Active C').part('Inactive C');
		UnitTest.addData(testAccount).tag('All Accounts');
        UnitTest.get('All Contacts').property('AccountId').assignFrom('All Accounts');
        UnitTest.get('Active C').property('Inactive__c').assign(true);
        UnitTest.get('All Contacts').insertAll();
		
		Test.startTest();
			ContactRollupOnAccount.rollupContactsOnAccounts( UnitTest.get('All Contacts').getList() );
		Test.stopTest();
		
		List<Account> requeriedAccounts = [SELECT Id, Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account];
		for(Account acc : requeriedAccounts)
		{
			System.assertEquals(20, acc.Number_of_Contacts__c, 'We expect each Account to have a sum of 20 Total Contacts.');
			System.assertEquals(10, acc.Number_of_Active_Contacts__c, 'We expect each Account have a sum of 10 Active Contacts.');
		}
	}

    @isTest static void populateContactVendorsFlow() {
        User mixedDMLUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(mixedDMLUser) {
            UnitTest.addData((List<Vendor_Detail__c>) SObjectFactory.build(1, Vendor_Detail__c.SObjectType))
                    .tag('Test Vendor')
                    .property('Vendor_Code__c').assign('654321')
                    .property('Vendor_Client_Number__c').assign('654321');

            insert UnitTest.get('Test Vendor').getList();
        }

        UnitTest.addData((List<Account>) SObjectFactory.build(2, Account.SObjectType))
                .tag('Test Accounts')
                .branch('Old Account | New Account');
        
        UnitTest.get('New Account')
                .property('RecordTypeId').assign(ACCOUNT_VENDOR_RECORDTYPE)
                .property('Vendor_Code__c').assign('654321');

        insert UnitTest.get('Test Accounts').getList();

        UnitTest.addData((List<Contact>) SObjectFactory.build(10, Contact.SObjectType))
                .tag('Test Contacts')
                .branch('Vendor Contacts | Non Vendor Contacts')
                .property('AccountId').assignFrom('Old Account');

        insert UnitTest.get('Test Contacts').getList();

        Test.startTest();
            UnitTest.get('Vendor Contacts')
                    .property('RecordTypeId').assign(CONTACT_VENDOR_RECORDTYPE)
                    .property('AccountId').assignFrom('New Account')
                    .property('Vendor_Lookup__c').assignFrom('Test Vendor');

            update UnitTest.get('Test Contacts').getList();
        Test.stopTest();

        List<Contact> actualContacts = [SELECT Id, Vendor_Lookup__c FROM Contact WHERE Vendor_Lookup__c = :UnitTest.get('Test Vendor').getList()[0].Id];
        System.assert(!actualContacts.isEmpty(), 'We expect contacts to be returned by the query');

        UnitTest.analyze('Vendor Contacts').assertEquivalence(actualContacts, 'We expect the records returned in the query to be the exact records updated');
    }
/*
    @isTest static void propagateOptOutStatus() {
        propagateTriggerSetupData();

        UnitTest.get('New Contacts')
                .property('Email').assign('test@test.com');

        Test.startTest();
            ContactServices.processedMarketing = false;
            insert UnitTest.get('New Contacts').getList();
        Test.stopTest();

        List<Contact> actualUpdatedContacts = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id IN :UnitTest.get('New Contacts').getList()];

        System.assertEquals(UnitTest.get('New Contacts').getList().size(), actualUpdatedContacts.size(), 'We expect both lists to be the same size');

        for(Contact actualContact : actualUpdatedContacts) {
            System.assertEquals(true, actualContact.HasOptedOutOfEmail, 'We expect the HasOptedOutOfEmail to be set to true based on the Old Contact Values');
        }
    }


    @isTest static void propagateOptOutStatus_noProcessing() {
        propagateTriggerSetupData();

        UnitTest.get('New Contacts')
                .property('Email').assign('a@b.com')
                .property('HasOptedOutOfEmail').assign(false);

        Test.startTest();
            ContactServices.processedMarketing = false;
            insert UnitTest.get('New Contacts').getList();
        Test.stopTest();

        List<Contact> actualUpdatedContacts = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id IN :UnitTest.get('New Contacts').getList()];

        System.assertEquals(UnitTest.get('New Contacts').getList().size(), actualUpdatedContacts.size(), 'We expect both lists to be the same size');

        for(Contact actualContact : actualUpdatedContacts) {
            System.assertEquals(false, actualContact.HasOptedOutOfEmail, 'We expect the HasOptedOutOfEmail to be set to false based because it should skip processing');
        }
    }
	*/
}
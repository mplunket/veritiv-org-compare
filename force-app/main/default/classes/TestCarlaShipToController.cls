/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class TestCarlaShipToController {
	
	 static Account TestAccount;
	 static Quote__c TestQuote;
	 static Ship_To__c TestShipTo;

    static {
    	TestAccount = TestingUtils.createAccount('TestAccount');
    	TestAccount.AccountNumber = '123456';
    	insert TestAccount;
        	
    	TestQuote = TestingUtils.createQuote(TestAccount);
    	insert TestQuote;
        	
    	TestShipTo = TestingUtils.createShipTo(TestAccount, 'TestShipTo');
    	TestShipto.Active__c = 'Yes';
    	insert TestShipTo;
    	
    	InactiveRecordTypes__c testCustomSetting = new InactiveRecordTypes__c();
		testCustomSetting.Name = CaseServices.EBUSINESS_RT_NAME;

		System.runAs( TestingUtils.ADMIN_USER )
		{
			insert testCustomSetting;
		}
    	
    }
    static testMethod void testPageConstructor() 
    {
    	/*
    	-- 1 : Create a account
    	-- 2 : Create a quote 
    	-- 3 : Create a few shiptos
    	-- 4 : Go To Ship to page
    	*/
    	
        TestQuote = [SELECT ID, Account__r.AccountNumber FROM Quote__c WHERE ID = :TestQuote.ID];   	
    	test.setCurrentPageReference (new Pagereference (Page.ShipToSearchBox.geturl ()+'?id='+TestQuote.Id));
    	ApexPages.Standardcontroller SC = new ApexPages.Standardcontroller (TestQuote);
    	
    	
    	
    	Test.StartTest ();
    	
    	CarlaShipToController TestController = new CarlaShipToController (SC);
    	
    	
    	
    	Test.stopTest();
    	System.assert( !ApexPages.hasMessages( ApexPages.Severity.ERROR ), 'No error messages should have been created: ' + ApexPages.getMessages() );
    	system.assertequals(TestQuote.id, TestController.currentQuote.Id);
    	
    	system.assertnotequals (null, TestController.shipToMatches);
    	system.assertEquals(2, TestController.shipToMatches.size());
    	system.assertEquals ('None', TestController.shipToMatches[0].shipTo.Name);
    	system.assertEquals(testShipTo.id, TestController.shipToMatches[1].shipTo.id);
    	
    	
    }
     
    static testMethod void testFindShipTo() 
    {
    	/*
    	-- 1 : Create a account - Done on static block
    	-- 2 : Create a quote - Done on static block
    	-- 3 : Create a few shiptos - Done on static block
    	-- 3.5: Create additional shiptos
    	-- 4 : Go To Ship to page
    	-- 5 : Set search text
    	-- 5.5: Do search
    	-- 6 : Get results
    	*/
    	
    	Account TestAccount2 = TestingUtils.createAccount('TestAccount2');
    	insert TestAccount2;
    	
    	List <CarlaShipToController.ShipToWrapper> Results;
    		
    	List <Ship_To__c> DummieShipTos = TestingUtils.createShipTos(testAccount2, 'Dummie ShipTos', 5);
    	insert DummieShipTos;
    	TestQuote = [SELECT ID, Account__r.AccountNumber FROM Quote__c WHERE ID = :TestQuote.ID];
    	test.setCurrentPageReference (new Pagereference (Page.ShipToSearchBox.geturl ()+'?id='+TestQuote.Id));
    	ApexPages.Standardcontroller SC = new ApexPages.Standardcontroller (TestQuote);
    	
    	
    	
    	
    	
    	Test.startTest();
    	
    	CarlaShipToController TestController = New CarlaShipToController (SC);
    	
    	system.debug ('-->'+ TestShipTo.Name);
    	testController.setSearchText('TestShipTo0');
    	testController.doSearch();    	
    	 	
    	Results = testController.getResults();
    	
    	Test.stopTest();
    	
    	system.assertEquals(2, results.size());
    	system.assertEquals ('None', results [0].shipTo.Name);
    	system.assertEquals(testShipTo.id, results[1].shipTo.id);
  }
  
  static testMethod void testExcludeMatchingShipTo() 
    {
    	/*
    	-- 1 : Create a account - Done on static block
    	-- 2 : Create a quote - Done on static block
    	-- 3 : Create a few shiptos - Done on static block
    	-- 3.5: Create additional shiptos where ship_to_code__c matches Bill_to__c
    	-- 4 : Go To Ship to page
    	-- 5 : Set search text
    	-- 5.5: Do search
    	-- 6 : Get results
    	*/
    	
    	    	
    	List <CarlaShipToController.ShipToWrapper> Results;
    		
    	List <Ship_To__c> TestShipTos = TestingUtils.createShipTos(testAccount, 'TestShipTo2', 5);
    	for (Ship_To__c TestShipTosCreated : TestShipTos)
    		TestShipTosCreated.Ship_To_Code__c = TestAccount.AccountNumber;
    	insert TestShipTos;
    	system.debug('-->'+[SELECT Ship_To_Code__c FROM Ship_To__c WHERE Id IN : TestShipTos]);
    	
    	TestQuote = [SELECT ID, Account__r.AccountNumber FROM Quote__c WHERE ID = :TestQuote.ID];
    	test.setCurrentPageReference (new Pagereference (Page.ShipToSearchBox.geturl ()+'?id='+TestQuote.Id));
    	ApexPages.Standardcontroller SC = new ApexPages.Standardcontroller (TestQuote);
    	
    	
    	
    	
    	
    	Test.startTest();
    	
    	CarlaShipToController TestController = New CarlaShipToController (SC);
    	
    	testController.setSearchText('TestShipTo');
    	testController.doSearch();    	
    	 	
    	Results = testController.getResults();
    	
    	Test.stopTest();
    	
    	system.assertEquals(2, results.size());
    	system.assertEquals ('None', results [0].shipTo.Name);
    	system.assertEquals(testShipTo.id, results[1].shipTo.id);
  }
  static testMethod void testShipToAddressBuilder()
    	    {
    	    	
    	    	/*
    	-- 1 : Create a account - Done on static block
    	-- 2 : Create a quote - Done on static block
    	-- 3 : Create a few shiptos - Done on static block
    	-- 4 : Add address info to Ship To
    	-- 5 : Ensure address string is correct
    	
    	 	*/
    	 	
    	    	testShipTo.Address_Line1__c = '123 strat st';
    	    	testShipTo.Address_Line2__c = 'suite 100';
    	    	testShipTo.City__c = 'Weston';
    	    	testShipTo.State__c = 'FL';
    	    	testShipTo.Postal_Code__c = '33326';
    	    	testShipTo.Ship_To_Code__c = '123123456456';
    	    	
    	    	string expectedString = '456456 - TestShipTo0\n123 strat st\nsuite 100\nWeston, FL, 33326';
    	    	string actualString = '';
    	    	
    	    	carlaShipToController.shipToWrapper testWrapper = new carlaShipToController.shipToWrapper (testShipTo);
    	    
    	    	test.startTest ();
    	    	actualString = testWrapper.getAddress();
    	    	test.stopTest ();
    	    	system.assertEquals(expectedString, actualString, 'The get address message should return the correct concatenated string');
    	    }
  static testMethod void testSetNullOnShipTo()
    {
    	/*
    	-- 1 : Create a account - Done on static block
    	-- 2 : Create a quote - Done on static block
    	-- 3 : Create a few shiptos - Done on static block
    	-- 3.5: Create additional shiptos
    	-- 4 : Go To Ship to page
    	-- 5 : Choose None
    	-- 6 : Clear the ship to field on quote
    	
    	 	*/
    	
    	Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, false )[0];
    	testPSR.SF_userid__c = UserInfo.getUserId();
    	insert testPSR;

    	Id custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testAccount.RecordTypeId = custRecTypeID;
        testAccount.Primary_Sales_Rep_Name__c = testPSR.Id;
        update testAccount;

		

    	testQuote.Ship_To__c = testShipTo.Id;
		testQuote.Primary_Sales_Rep__c = null;
    	update testQuote;
	
		TestQuote = [SELECT ID, Account__r.AccountNumber FROM Quote__c WHERE ID = :TestQuote.ID];
		test.setCurrentPageReference (new Pagereference (Page.ShipToSearchBox.geturl ()+'?id='+testQuote.Id));
    	ApexPages.Standardcontroller SC = new ApexPages.Standardcontroller (testQuote);
    	
    	
    	Test.startTest();
    	
    	CarlaShipToController TestController = New CarlaShipToController (SC);
    	
    	TestController.selectedShipToId = null;
    	
    	TestController.saveShipToAddress();
    	
    

			
    	Test.stopTest();

		System.assert( !ApexPages.hasMessages( ApexPages.Severity.ERROR ), 'No error messages should have been created: ' + ApexPages.getMessages() );
    	testQuote = [ SELECT Id, Ship_To__c, Primary_Sales_Rep__c FROM Quote__c WHERE Id = :testQuote.Id LIMIT 1 ];
    	System.assertEquals( null, testQuote.Ship_To__c, 'When selecting NONE for ship to addresses, the quotes ship to should be cleared' );
    	System.assertEquals( testPSR.Id, testQuote.Primary_Sales_Rep__c, 'When setting ShipTo to null, the quote should get the PSR from its account' );
    }

  static testMethod void testSetShipToPSROnQuote()
    {
    	/*
    	-- 1 : Create a account - Done on static block
    	-- 2 : Create a quote - Done on static block
    	-- 3 : Create a few shiptos - Done on static block
    	-- 3.5: Create additional shiptos
    	-- 4 : Go To Ship to page
    	-- 5 : Choose TestShipTo
    	-- 6 : Ensure that the psr on the quote gets set as the Account Owner of the PSR
    	
    	*/
    	User testUser;
		System.runAs( TestDataGeneration.ADMIN_USER )
		{
			testUser = TestDataGeneration.createUser( 'NUser', 'Standard User', true );
		}
    	
    	testShipTo.Account_Owner__c = testUser.id;
    	update testShipTo;
    	
    	List<Primary_Sales_Rep__c> testPSRs = TestDataGeneration.createPSRs( 2, false );
    	testPSRs[0].SF_userid__c = UserInfo.getUserId();
    	testPSRs[1].SF_userid__c = testUser.id;
    	insert testPSRs;

    	Id custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testAccount.RecordTypeId = custRecTypeID;
        testAccount.Primary_Sales_Rep_Name__c = testPSRs[1].Id;
        update testAccount;

    	testQuote.Ship_To__c = testShipTo.Id;
		testQuote.Primary_Sales_Rep__c = null;
    	update testQuote;

		TestQuote = [SELECT ID, Account__r.AccountNumber FROM Quote__c WHERE ID = :TestQuote.ID];
		test.setCurrentPageReference (new Pagereference (Page.ShipToSearchBox.geturl ()+'?id='+testQuote.Id));
    	ApexPages.Standardcontroller SC = new ApexPages.Standardcontroller (testQuote);
    	
    	
    	Test.startTest();
    	
    	CarlaShipToController TestController = New CarlaShipToController (SC);
    	
    	TestController.selectedShipToWrapper.shipTo = testShipTo;
    	
    	TestController.saveShipToAddress();
    	
    

			
    	Test.stopTest();

		System.assert( !ApexPages.hasMessages( ApexPages.Severity.ERROR ), 'No error messages should have been created: ' + ApexPages.getMessages() );
    	testQuote = [ SELECT Id, Ship_To__c, Primary_Sales_Rep__c FROM Quote__c WHERE Id = :testQuote.Id LIMIT 1 ];
    	System.assertEquals( testShipTo.Id, testQuote.Ship_To__c, 'A ShipTo on the quote should be populated' );
    	System.assertEquals( testPSRs[1].Id, testQuote.Primary_Sales_Rep__c, 'When setting ShipTo to null, the quote should get the PSR from its account' );
    }

  static testMethod void testSetShipToOnContact()
    {
    	/*
    	-- 1 : Create a account - Done on static block
    	-- 2 : Create a quote - Done on static block
    	-- 3 : Create a few shiptos - Done on static block
    	-- 3.5: Create additional shiptos
    	-- 4: Create a Contact
    	-- 4.5 : Go To Ship to page
    	-- 5 : Select the test shipto
    	-- 6 : Ensure that the contact gets set with the correct shipto
    	
    	*/
		
		Contact testContact = TestingUtils.createContact('Test', 'Contact', false);
		
		testContact.AccountId = testAccount.id;
		
		insert testContact;

		PageReference testPageRef = new Pagereference (Page.ShipToSearchBoxGeneric.geturl() );
		testPageRef.getParameters().put('recordid', testContact.Id);
		testPageRef.getParameters().put('accountId', testAccount.id);
		testPageRef.getParameters().put('type', 'Contact');
		testPageRef.getParameters().put('name', testContact.Name);
		testPageRef.getParameters().put('accountNumber', testAccount.AccountNumber);
		testPageRef.getParameters().put('accountName', testAccount.Name);

		test.setCurrentPageReference ( testPageRef );
    	
    	Test.startTest();
    	
	    	CarlaShipToController TestController = New CarlaShipToController ();
	    	
	    	TestController.selectedShipToWrapper.shipTo = testShipTo;
	    	
	    	TestController.saveShipToAddress();
			
    	Test.stopTest();

		System.assert( !ApexPages.hasMessages( ApexPages.Severity.ERROR ), 'No error messages should have been created: ' + ApexPages.getMessages() );
    	testContact = [ SELECT Id, Ship_To__c FROM Contact WHERE Id = :testContact.Id LIMIT 1 ];
    	System.assertEquals( testShipTo.Id, testContact.Ship_To__c, 'A ShipTo on the contact should be populated' );
    }
 
  static testMethod void testSetShipToOnCase()
    {
    	/*
    	-- 1 : Create a account - Done on static block
    	-- 2 : Create a quote - Done on static block
    	-- 3 : Create a few shiptos - Done on static block
    	-- 3.5: Create additional shiptos
    	-- 4: Create a Case
    	-- 4.5 : Go To Ship to page
    	-- 5 : Select the test shipto
    	-- 6 : Ensure that the contact gets set with the correct shipto
    	
    	*/
		
		List<RecordType>email2CaseRTypes = [Select id from 
											RecordType where DeveloperName = :AttachmentServices.EMAIL_2_CASE_RTYPE
											and SObjectType = 'Case' 
											and IsActive = true limit 1];
		
		System.assert(email2CaseRTypes.size() > 0, 'Fax RecordType Does Not Exist');
		
		Case testCase = TestingUtils.createCase( email2CaseRTypes[0].id );
		
		testCase.AccountId = testAccount.id;
		testCase.Subject = 'Test Subj';
		
		insert testCase;

		PageReference testPageRef = new Pagereference (Page.ShipToSearchBoxGeneric.geturl() );
		testPageRef.getParameters().put('recordid', testCase.Id);
		testPageRef.getParameters().put('accountId', testAccount.id);
		testPageRef.getParameters().put('type', 'Case');
		testPageRef.getParameters().put('name', testCase.Subject);
		testPageRef.getParameters().put('accountNumber', testAccount.AccountNumber);
		testPageRef.getParameters().put('accountName', testAccount.Name);

		test.setCurrentPageReference ( testPageRef );
    	
    	Test.startTest();
    	
	    	CarlaShipToController TestController = New CarlaShipToController ();
	    	
	    	TestController.selectedShipToWrapper.shipTo = testShipTo;
	    	
	    	TestController.saveShipToAddress();
			
    	Test.stopTest();

		System.assert( !ApexPages.hasMessages( ApexPages.Severity.ERROR ), 'No error messages should have been created: ' + ApexPages.getMessages() );
    	testCase = [ SELECT Id, ShipToAccount__c FROM Case WHERE Id = :testCase.Id LIMIT 1 ];
    	System.assertEquals( testShipTo.Id, testCase.ShipToAccount__c, 'A ShipTo on the case should be populated' );
    }

}
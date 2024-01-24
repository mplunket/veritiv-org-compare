@isTest
public class QuoteTest {

	private static Account testCustAccount;
	private static Ship_To__c testShipAccount;
	private static Quote__c testQuote;
	private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0];

	private static final Integer NUM_OF_OBJs = 5;
	private static final Integer NUM_OF_ACCT_PLANS = 5;
	private static final Integer NUM_OF_QUOTES = 5;
	private static final Integer NUM_OF_USERS = 5;

	private static final Integer NUM_TO_CHANGE = 2;
	private static final Integer NUM_OF_NEW_USERS = 2;

	private static Account testAccount;
	private static Contact testContact;
	private static List<User> testUsers;
	private static List<AccountTeamMember> testATMs;

	private static Account newAccount;
	private static List<User> newUsers;
	private static List<AccountTeamMember> newATMs;

	private static void setup()
	{
		// recordtype is NEEDED for test pass
		InactiveRecordTypes__c inactiveRT = new InactiveRecordTypes__c();
		inactiveRT.Name = CaseServices.EBUSINESS_RT_NAME;
		System.runAs( TestingUtils.ADMIN_USER )
		{
			insert inactiveRT;
		}
		Id testRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get( '02. Customer Inquiry' ).getRecordTypeId();
		Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Customer' ).getRecordTypeId();

		Grant_Access_Level_ATM__c acctPlansToAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.ACCOUNT_PLANS_NAME, AccountTeamMemberServices.READ_ONLY_LEVEL, true );
		Grant_Access_Level_ATM__c quoteToAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.QUOTES_NAME, AccountTeamMemberServices.READ_WRITE_LEVEL, true );

		testAccount = TestingUtils.createAccount( 'Test Account' );
		testAccount.RecordTypeId = customerRTId;
		insert testAccount;

		testContact = TestingUtils.createContact( 'John', 'Doe', true );
		testUsers = TestingUtils.createUsers( 'JohnD', 'Standard User', NUM_OF_USERS, true );
		testATMs = new List<AccountTeamMember>();
		for( User aUser : testUsers )
		{
			testATMs.add( TestingUtils.createAccountTeamMember( testAccount.Id, aUser.Id, false ) );
		}
		insert testATMs;
	}


	private static void setupNewAccountAndATMs()
	{
		newAccount = TestingUtils.createAccount( 'Steve Jobs' );
		insert newAccount;

		newUsers = TestingUtils.createUsers('PhilC', 'Standard User', NUM_OF_NEW_USERS, true );
		newATMs = new List<AccountTeamMember>();
		for( User aUser : newUsers )
		{
			newATMs.add( TestingUtils.createAccountTeamMember( newAccount.Id, aUser.Id, false ) );
		}
		insert newATMs;
	}

	static testMethod void testGrantQuoteAccessToATMs()
	{
		setup();

		Test.startTest();

			List<Quote__c> testQuotes = TestingUtils.createQuotes( NUM_OF_QUOTES, testAccount.Id, false );
			insert testQuotes;

		Test.stopTest();

		List<Quote__Share> actualQuoteShares = [ SELECT Id, AccessLevel
													FROM Quote__Share
													WHERE ParentId IN :testQuotes
														AND UserOrGroupId IN :testUsers ];

		System.assertEquals( NUM_OF_USERS * NUM_OF_QUOTES, actualQuoteShares.size(), 'There should be a Quote Share per Quote created' );
		for( Quote__Share quoteShare : actualQuoteShares )
		{
			System.assertEquals( BatchServices.EDIT, quoteShare.AccessLevel, 'The AccessLevel should be set based on Access Level value of Custom Setting' );
		}
	}

	static testMethod void testGrantAccessForMigratedQuotes()
	{
		setup();

		List<Quote__c> testQuotes = TestingUtils.createQuotes( NUM_OF_QUOTES, testAccount.Id, true );
		Set<Id> changedQuoteIds = new Set<Id>();

		Test.startTest();

			setupNewAccountAndATMs();
			for( Integer i = 0; i < NUM_TO_CHANGE; i++ )
			{
				testQuotes[i].Account__c = newAccount.Id;
				changedQuoteIds.add( testQuotes[i].Id );
			}
			update testQuotes;

		Test.stopTest();

		List<Quote__Share> actualOldQuoteShares = [ SELECT Id, ParentId, UserOrGroupId
													FROM Quote__Share
													WHERE ParentId IN :testQuotes
														AND UserOrGroupId IN :testUsers ];

		Set<Id> newUserIds = new Set<Id>();
		for( User aUser : newUsers )
		{
			newUserIds.add( aUser.Id );
		}

		final Integer EXPECTED_OLD_SHARE_SIZE = ( NUM_OF_QUOTES - NUM_TO_CHANGE ) * NUM_OF_USERS;

		System.assertEquals( EXPECTED_OLD_SHARE_SIZE, actualOldQuoteShares.size(), 'The sharing object should be removed from old Quotes upon migration' );
		for( Quote__Share quoteShare : actualOldQuoteShares )
		{
			System.assert( !changedQuoteIds.contains( quoteShare.ParentId ), 'The Quote Share record from old Quotes should not look upto the changed Quote record' );
			System.assert( !newUserIds.contains( quoteShare.UserOrGroupId ), 'The Quote Share record from old Quotes should not look upto the new User record' );
		}

		List<Quote__Share> actualNewQuoteShares = [ SELECT Id, ParentId, UserOrGroupId
																FROM Quote__Share
																WHERE ParentId IN :testQuotes
																	AND UserOrGroupId IN :newUsers ];

		final Integer EXPECTED_NEW_SHARE_SIZE = NUM_OF_NEW_USERS * NUM_TO_CHANGE;

		System.assertEquals( EXPECTED_NEW_SHARE_SIZE, actualNewQuoteShares.size(), 'The sharing object should be added to new Quotes upon migration' );
		for( Quote__Share quoteShare : actualNewQuoteShares )
		{
			System.assert( changedQuoteIds.contains( quoteShare.ParentId ), 'The Quote Share record from new Quotes should look upto the changed Quote record' );
			System.assert( newUserIds.contains( quoteShare.UserOrGroupId ), 'The Quote Share record from new Quotes should look upto the new User record' );
		}
	}

	public static testMethod void test_update_date()
	{
		setupTest();

		Test.startTest();

		testQuote.Requested_Delivery_Date__c = System.today() + 7;
		update testQuote;

		testQuote = [select Requested_Delivery_Date__c from Quote__c where Id = :testQuote.Id];
		testQLIs = [select Projected_Delivery_Date__c from Quote_Line_Item__c where Quote__c = :testQuote.Id];

		for(Quote_Line_Item__c qli : testQLIs)
		{
			System.assertEquals(testQuote.Requested_Delivery_Date__c, qli.Projected_Delivery_Date__c);
		}
		Test.stopTest();
	}

	private static void setupTest()
	{
		Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Customer' ).getRecordTypeId();
		testCustAccount = TestingUtils.createAccount('Test Customer');
		testCustAccount.RecordTypeId = customerRTId;
		testCustAccount.AccountNumber = '123456';
		testCustAccount.Ship_To_Code__c = '000001';
		testCustAccount.Active__c = 'Yes';
		insert testCustAccount;

		testShipAccount = new Ship_To__c( Name = 'Test Customer Location 1', Ship_To_Code__c = '000002', Bill_To_Account__c = testCustAccount.Id, Active__c = 'Yes' );
		insert testShipAccount;

		testQuote = TestingUtils.createQuotes( 1, testCustAccount.Id, false )[0];
		testQuote.Shipment_Method__c = 'Warehouse';
		testQuote.Requested_Delivery_Date__c = System.today();
		insert testQuote;

		List<Vendor_Detail__c> vendorDetails = TestingUtils.createVendorDetails( 2, 'TestVendor', false );
		vendorDetails[0].Vendor_Code__c = '001';
		vendorDetails[1].Vendor_Code__c = '002';
		insert vendorDetails;

		List<Product2> products = TestDataGeneration.createProducts( 2, 'TestProduct', false );
		products[0].ProductCode = '0001';
		products[0].Description = 'Test Description 1';
		products[0].Unisource_Item_Number_U_number__c = '001';
		products[0].Vendor_Product_Code__c = vendorDetails[0].Vendor_Code__c;
		products[0].Vendor__c = vendorDetails[0].Id;
		products[0].Unit_of_Measure__c = 'EA';
		products[0].Pricing_Costing_UOM__c = 'EA';
		products[0].Conversion_Factor__c = 10.01;

		products[1].ProductCode = '0002';
		products[1].Description = 'Test Description 2';
		products[1].Unisource_Item_Number_U_number__c = '002';
		products[1].Vendor_Product_Code__c = vendorDetails[1].Vendor_Code__c;
		products[1].Vendor__c = vendorDetails[1].Id;
		products[1].Unit_of_Measure__c = 'MA';
		products[1].Pricing_Costing_UOM__c = 'MA';
		products[1].Conversion_Factor__c = 20.02;
		insert products;

		Quote_Line_Item__c qli = new Quote_Line_Item__c( Quote__c=testQuote.Id );
		qli.Product__c = products[0].Id;
		qli.Product__r = products[0];
		qli.Product_Code__c = products[0].ProductCode;
		qli.Product_Description__c = products[0].Description;
		qli.Unisource_Item__c = products[0].Unisource_Item_Number_U_number__c;
		qli.Vendor_Item__c = products[0].Vendor_Product_Code__c;
		qli.Vendor_Name__c = products[0].Vendor__c;
		qli.Qty__c = 1;
		qli.Projected_Delivery_Date__c = System.today();
		qli.Quantity_unit_of_measure__c = products[0].Unit_of_Measure__c;
		qli.Price_unit_of_measure__c = products[0].Pricing_Costing_UOM__c;
		qli.Costing_unit_of_measure__c = products[0].Pricing_Costing_UOM__c;
		qli.Quantity_Unit_Factor__c = 1;
		qli.Price_Unit_Factor__c = products[0].Conversion_Factor__c;
		qli.Cost_Unit_Factor__c = products[0].Conversion_Factor__c;
		insert qli;
		testQLIs.add(qli);

		qli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
		qli.Product__c = products[1].Id;
		qli.Product__r = products[1];
		qli.Product_Code__c = products[1].ProductCode;
		qli.Product_Description__c = products[1].Description;
		qli.Unisource_Item__c = products[1].Unisource_Item_Number_U_number__c;
		qli.Vendor_Item__c = products[1].Vendor_Product_Code__c;
		qli.Vendor_Name__c = products[1].Vendor__c;
		qli.Qty__c = 1;
		qli.Projected_Delivery_Date__c = System.today();
		qli.Quantity_unit_of_measure__c = products[1].Unit_of_Measure__c;
		qli.Price_unit_of_measure__c = products[1].Pricing_Costing_UOM__c;
		qli.Costing_unit_of_measure__c = products[1].Pricing_Costing_UOM__c;
		qli.Quantity_Unit_Factor__c = 1;
		qli.Price_Unit_Factor__c = products[1].Conversion_Factor__c;
		qli.Cost_Unit_Factor__c = products[1].Conversion_Factor__c;
		insert qli;
		testQLIs.add(qli);
	}

}
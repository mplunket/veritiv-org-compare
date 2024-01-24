@isTest
private class TestAccessLevelServices
{
	private static final Integer NUM_OF_OBJs = 3;
	private static final Integer NUM_OF_ACCT_PLANS = 5;
	private static final Integer NUM_OF_QUOTES = 7;
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
		TestingUtils.setupInactiveRecordType();
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

	static testMethod void testRetrieveAccountIds_AccountPlans()
	{
		setup();

		List<Account_Plan__c> testAcctPlans = TestingUtils.createAccountPlans( NUM_OF_ACCT_PLANS, testAccount.Id, 'Test AcctPlan', false );

		Test.startTest();

			Set<Id> actualAccountIds = AccessLevelServices.retrieveAccountIds( testAcctPlans );

		Test.stopTest();

		System.assertEquals( 1, actualAccountIds.size(), 'The AccountId that Account Plans looks upto should be returned' );
		for( Id acctId : actualAccountIds )
		{
			System.assertEquals( testAccount.Id, acctId, 'Upon retrieving the AccountIds, we should be expecting testAccount\'s Id' );
		}
	}

	static testMethod void testRetrieveAccountIds_Quotes()
	{
		setup();

		List<Quote__c> testQuotes = TestingUtils.createQuotes( NUM_OF_QUOTES, testAccount.Id, false );

		Test.startTest();

			Set<Id> actualAccountIds = AccessLevelServices.retrieveAccountIds( testQuotes );

		Test.stopTest();

		System.assertEquals( 1, actualAccountIds.size(), 'The AccountId that Quotes looks upto should be returned' );
		for( Id acctId : actualAccountIds )
		{
			System.assertEquals( testAccount.Id, acctId, 'Upon retrieving the AccountIds, we should be expecting testAccount\'s Id' );
		}
	}

	static testMethod void testGrantAccountPlanAccessToATMs()
	{
		setup();

		List<Account_Plan__c> testAcctPlans = TestingUtils.createAccountPlans( NUM_OF_ACCT_PLANS, testAccount.Id, 'Test AcctPlan', true );

		Test.startTest();

			AccessLevelServices.grantAccountPlanAccessToATMs( new Map<Id, Account_Plan__c> ( testAcctPlans ) );

		Test.stopTest();

		List<Account_Plan__Share> actualAcctPlanShares = [ SELECT Id, AccessLevel
															FROM Account_Plan__Share
															WHERE ParentId IN :testAcctPlans
																AND UserOrGroupId IN :testUsers ];

		System.assertEquals( NUM_OF_USERS * NUM_OF_ACCT_PLANS, actualAcctPlanShares.size(), 'There should be an Account Plan Share per Account Plan created' );
		for( Account_Plan__Share acctPlanShare : actualAcctPlanShares )
		{
			System.assertEquals( AccountTeamMemberServices.READ_ONLY_LEVEL, acctPlanShare.AccessLevel, 'The AccessLevel should be set based on Access Level value of Custom Setting' );
		}
	}

	static testMethod void testGrantAccessForMigratedAccountPlans()
	{
		setup();

		List<Account_Plan__c> testAcctPlans = TestingUtils.createAccountPlans( NUM_OF_ACCT_PLANS, testAccount.Id, 'Test AcctPlan', true );

		Map<Id, Account_Plan__c> oldAcctPlans = new Map<Id, Account_Plan__c>( testAcctPlans.deepClone( true ) );

		setupNewAccountAndATMs();

		for( Integer i = 0; i < NUM_TO_CHANGE; i++ )
		{
			testAcctPlans[i].Account__c = newAccount.Id;
		}

		Test.startTest();

			AccessLevelServices.grantAccessForMigratedAccountPlans( new Map<Id, Account_Plan__c> ( testAcctPlans ), oldAcctPlans );

		Test.stopTest();

		List<Account_Plan__Share> actualOldAccountPlanShares = [ SELECT Id, AccessLevel
																FROM Account_Plan__Share
																WHERE ParentId IN :testAcctPlans
																	AND UserOrGroupId IN :testUsers ];

		final Integer EXPECTED_OLD_SHARE_SIZE = ( NUM_OF_ACCT_PLANS - NUM_TO_CHANGE ) * NUM_OF_USERS;

		System.assertEquals( EXPECTED_OLD_SHARE_SIZE, actualOldAccountPlanShares.size(), 'The sharing object should be removed from old Account Plans upon migration' );
		for( Account_Plan__Share acctPlanShare : actualOldAccountPlanShares )
		{
			System.assertEquals( AccountTeamMemberServices.READ_ONLY_LEVEL, acctPlanShare.AccessLevel, 'The AccessLevel should be set based on Access Level value of Custom Setting' );
		}

		List<Account_Plan__Share> actualNewAccountPlanShares = [ SELECT Id, AccessLevel
																FROM Account_Plan__Share
																WHERE ParentId IN :testAcctPlans
																	AND UserOrGroupId IN :newUsers ];

		final Integer EXPECTED_NEW_SHARE_SIZE = NUM_OF_NEW_USERS * NUM_TO_CHANGE;

		System.assertEquals( EXPECTED_NEW_SHARE_SIZE, actualNewAccountPlanShares.size(), 'The sharing object should be added to new Account Plans upon migration' );
		for( Account_Plan__Share acctPlanShare : actualNewAccountPlanShares )
		{
			System.assertEquals( AccountTeamMemberServices.READ_ONLY_LEVEL, acctPlanShare.AccessLevel, 'The AccessLevel should be set based on Access Level value of Custom Setting' );
		}
	}

	static testMethod void testGrantQuoteAccessToATMs()
	{
		setup();

		List<Quote__c> testQuotes = TestingUtils.createQuotes( NUM_OF_QUOTES, testAccount.Id, true );

		Test.startTest();

			AccessLevelServices.grantQuoteAccessToATMs( new Map<Id, Quote__c> ( testQuotes ) );

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

	static testMethod void testRemoveAccessFromQuotesOnAccountChange()
	{
		setup();
		setupNewAccountAndATMs();
		
		List<Quote__c> testQuotes = new List<Quote__c>();

		System.RunAs( testUsers[0] )
		{
			testQuotes = TestingUtils.createQuotes( 1, testAccount.Id, true );
		}
		
		Test.startTest();

			testQuotes[0].Account__c = newAccount.Id;
			update testQuotes;

		Test.stopTest();

		
		List<Quote__Share> actualQuoteShares = [ SELECT Id, AccessLevel, UserOrGroupId
													FROM Quote__Share
													WHERE ParentId IN :testQuotes
														AND ( UserOrGroupId IN :testUsers OR UserOrGroupId IN :newUsers )];

		System.assertEquals( NUM_OF_NEW_USERS + 1, actualQuoteShares.size(), 'There should be a Quote Share for each of the new users and one for the original owner of the quote' );
		
		newUsers.add( testUsers[0] );
		for( Quote__Share foundShare : actualQuoteShares)
		{
			System.assert( new Map<Id, User> (newUsers).containsKey( foundShare.UserOrGroupId ), 'Shares should only exist for the new users or the owner' );
		}
	}
	
	static testMethod void testRemoveAccessFromAccountPlansOnAccountChange()
	{
		setup();
		setupNewAccountAndATMs();
		
		List<Account_Plan__c> testAPlans = new List<Account_Plan__c>();

		System.RunAs( testUsers[0] )
		{
			testAPlans = TestingUtils.createAccountPlans( 1, testAccount.Id, 'Test Acct Plan', true );
		}
		
		Test.startTest();

			testAPlans[0].Account__c = newAccount.Id;
			update testAPlans;

		Test.stopTest();

		
		List<Account_Plan__Share> actualAPlanShares = [ SELECT Id, AccessLevel, UserOrGroupId
													FROM Account_Plan__Share
													WHERE ParentId IN :testAPlans
														AND ( UserOrGroupId IN :testUsers OR UserOrGroupId IN :newUsers )];

		System.assertEquals( NUM_OF_NEW_USERS + 1, actualAPlanShares.size(), 'There should be an AccountPlan Share for each of the new users and one for the original owner of the AccountPlan' );
		
		newUsers.add( testUsers[0] );
		for( Account_Plan__Share foundShare : actualAPlanShares)
		{
			System.assert( new Map<Id, User> (newUsers).containsKey( foundShare.UserOrGroupId ), 'Shares should only exist for the new users or the owner' );
		}
	}

	static testMethod void testGrantAccessForMigratedQuotes()
	{
		setup();

		List<Quote__c> testQuotes = TestingUtils.createQuotes( NUM_OF_QUOTES, testAccount.Id, true );
		Map<Id, Quote__c> oldQuotesMap = new Map<Id, Quote__c>( testQuotes.deepClone( true ) );

		setupNewAccountAndATMs();

		for( Integer i = 0; i < NUM_TO_CHANGE; i++ )
		{
			testQuotes[i].Account__c = newAccount.Id;
		}

		Test.startTest();

			AccessLevelServices.grantAccessForMigratedQuotes( new Map<Id, Quote__c> ( testQuotes ), oldQuotesMap );

		Test.stopTest();

		List<Quote__Share> actualOldQuoteShares = [ SELECT Id, AccessLevel
													FROM Quote__Share
													WHERE ParentId IN :testQuotes
														AND UserOrGroupId IN :testUsers ];

		final Integer EXPECTED_OLD_SHARE_SIZE = ( NUM_OF_QUOTES - NUM_TO_CHANGE ) * NUM_OF_USERS;

		System.assertEquals( EXPECTED_OLD_SHARE_SIZE, actualOldQuoteShares.size(), 'The sharing object should be removed from old Quotes upon migration' );
		for( Quote__Share quoteShare : actualOldQuoteShares )
		{
			System.assertEquals( BatchServices.EDIT, quoteShare.AccessLevel, 'The AccessLevel should be set based on Access Level value of Custom Setting' );
		}

		List<Quote__Share> actualNewQuoteShares = [ SELECT Id, AccessLevel
																FROM Quote__Share
																WHERE ParentId IN :testQuotes
																	AND UserOrGroupId IN :newUsers ];

		final Integer EXPECTED_NEW_SHARE_SIZE = NUM_OF_NEW_USERS * NUM_TO_CHANGE;

		System.assertEquals( EXPECTED_NEW_SHARE_SIZE, actualNewQuoteShares.size(), 'The sharing object should be added to new Quotes upon migration' );
		for( Quote__Share quoteShare : actualNewQuoteShares )
		{
			System.assertEquals( BatchServices.EDIT, quoteShare.AccessLevel, 'The AccessLevel should be set based on Access Level value of Custom Setting' );
		}
	}
}
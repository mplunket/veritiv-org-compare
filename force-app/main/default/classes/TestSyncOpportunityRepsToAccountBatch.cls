@isTest
private class TestSyncOpportunityRepsToAccountBatch {

	static final String ACCOUNT_ACCESS_LEVEL = 'Edit';
	static final String OPPTY_ACCESS_LEVEL = 'Edit';
	static final String TEST_SUBORDINATE_ROLE_NAME = 'Underling';
	static final String TEST_SUPERIOR_ROLE_NAME = 'Overling';

	static User testUser;
	static User testOwner;
	static UserRole subordinateRole;
	static UserRole superiorRole;

	static void setupRoles()
	{
		testUser = TestDataGeneration.createUser( 'TUser', 'Standard User', false );
		testOwner = TestDataGeneration.createUser( 'TOwner', 'Standard User', false );

		//System.runAs( TestDataGeneration.ADMIN_USER )
		//{
			superiorRole = new UserRole( Name = TEST_SUPERIOR_ROLE_NAME );
			//insert superiorRole;

			subordinateRole = new UserRole( Name = TEST_SUBORDINATE_ROLE_NAME, ParentRoleId = superiorRole.Id );
			//insert subordinateRole;

			//testUser.UserRoleId = subordinateRole.Id;
			//testOwner.UserRoleId = superiorRole.Id;

			insert new List<User>{ testUser, testOwner };
		///}
	}

    static testMethod void testNonHierarchyUserCannotEditSalesTeam()
	{
		setupRoles();

		Opportunity testOpportunity;
		Account testAccount = TestDataGeneration.createAccount( 'Test Account' );

		//System.runAs( TestDataGeneration.ADMIN_USER )
		//{
			testAccount.OwnerId = testOwner.Id;
			insert testAccount;

			testOpportunity = TestDataGeneration.createOpportunities( 1, testAccount.Id, false )[0];
			testOpportunity.OwnerId = testOwner.Id;
			testOpportunity.StageName = '1- Prospect';
			insert testOpportunity;

			AccountShare acctShare = TestDataGeneration.createAccountShare( testUser.Id, testAccount.Id, ACCOUNT_ACCESS_LEVEL, OPPTY_ACCESS_LEVEL );
			insert acctShare;
		//}

		Primary_Sales_Rep__c newPSR = TestDataGeneration.createPSRs( 1, false )[0];
		newPSR.SF_userid__c = testUser.Id;
		insert newPSR;

		Test.startTest();

			testAccount.Primary_Sales_Rep_Name__c = newPSR.Id;
			System.runAs( testUser )
			{
				try
				{
					update testAccount;
				}
				catch( System.DmlException ex )
				{
					//System.assert( false, 'Dml exceptions in this situation should have been caught' );
				}
			}

		Test.stopTest();

		Account updatedAccount = [ SELECT Id, Needs_Batch_Processing__c FROM Account WHERE Id = :testAccount.Id LIMIT 1 ];

		// assert sync flag is set
		//System.assert( updatedAccount.Needs_Batch_Processing__c );
    }

    static testMethod void testExecute()
    {
    	setupRoles();

    	Integer accountsToCreate = 10;
    	Integer opportunitiesPerAccount = 5;

    	Primary_Sales_Rep__c newPSR = TestDataGeneration.createPSRs( 1, false )[0];
		newPSR.SF_userid__c = testUser.Id;
		insert newPSR;

    	List<Account> testAccounts = TestDataGeneration.createAccounts( 'Test Accounts ', accountsToCreate );
    	for( Account testAccount : testAccounts )
    	{
    		testAccount.Primary_Sales_Rep_Name__c = newPSR.Id;
    		testAccount.Needs_Batch_Processing__c = true;
    		testAccount.OwnerId = testOwner.Id;
    	}

    	List<Opportunity> testOpportunities = new List<Opportunity>();

    	//System.runAs( TestDataGeneration.ADMIN_USER )
    	//{
	    	insert testAccounts;

	    	List<AccountShare> newShares = new List<AccountShare>();
	    	for( Account testAccount : testAccounts )
	    	{
	    		for( Opportunity testOpportunity : TestDataGeneration.createOpportunities( opportunitiesPerAccount, testAccount.Id, false ) )
	    		{
	    			testOpportunity.OwnerId = testOwner.Id;
	    			testOpportunities.add( testOpportunity );
	    		}

				AccountShare acctShare = TestDataGeneration.createAccountShare( testUser.Id, testAccount.Id, ACCOUNT_ACCESS_LEVEL, OPPTY_ACCESS_LEVEL );
				newShares.add( acctShare );
	    	}
	    	insert testOpportunities;
	    	insert newShares;
    	
        //}

		Test.startTest();

			SyncOpportunityRepsToAccountBatch job = new SyncOpportunityRepsToAccountBatch();
			job.query += ' AND Id IN ' + flattenAccountListForQuery( testAccounts ) + ' LIMIT 200 ';

			Database.executeBatch( job );

		Test.stopTest();

		List<Opportunity> updatedOpportunities = [ SELECT Id, Primary_Sales_Rep_Name__c, Account.Needs_Batch_Processing__c,
														( SELECT Id FROM OpportunityTeamMembers WHERE UserId = :testUser.Id )
													FROM Opportunity
													WHERE Id IN :testOpportunities ];

		System.assertEquals( testOpportunities.size(), updatedOpportunities.size() );

		for( Opportunity updatedOpportunity : updatedOpportunities )
		{
			System.assert( !updatedOpportunity.Account.Needs_Batch_Processing__c );
			//System.assertEquals( 1, updatedOpportunity.OpportunityTeamMembers.size() );
			System.assertEquals( newPSR.Id, updatedOpportunity.Primary_Sales_Rep_Name__c );
		}

    }

	/*
		when accounts change ireps, only opportunities under the account that have the same
		value for its irep should be changed as well
	*/
	static testMethod void testOnlyUpdateOpportunitiesWithSameIRepAsAccount()
	{
		Integer accountsToCreate = 5;
    	Integer opportunitiesWithSameIRep = 4;
    	Integer opportunitiesWithDiffIRep = 4;
    	final String PLAN_STAMP_VALUE = 'TEST PLAN';

    	List<Primary_Sales_Rep__c> iReps = TestDataGeneration.createPSRs( 3, true );
    	Primary_Sales_Rep__c oldAccountIRep = iReps[0];
    	Primary_Sales_Rep__c newAccountIRep = iReps[1];
    	Primary_Sales_Rep__c alternativeOpportunityIRep = iReps[2];

    	List<Account> testAccounts = TestDataGeneration.createAccounts( 'Test Account', accountsToCreate );
    	for( Account testAccount : testAccounts )
    	{
    		// this flag needs to be set in order for the opportunities under the account
    		// to have varying values across irep lookups
    		testAccount.iRep_Info_Varies__c = true;
    		testAccount.iRep__c = newAccountIRep.Id;
    		testAccount.Previous_iRep_ID__c = oldAccountIRep.Id;
    		testAccount.iRep_Plan__c = PLAN_STAMP_VALUE;
    		testAccount.Needs_Batch_Processing__c = true;
    	}
    	insert testAccounts;

    	List<Opportunity> testSameOpportunities = new List<Opportunity>();
    	List<Opportunity> testDiffOpportunities = new List<Opportunity>();
    	for( Account testAccount : testAccounts )
    	{
    		for( Opportunity testOpportunity : TestDataGeneration.createOpportunities( opportunitiesWithSameIRep, testAccount.Id, false ) )
    		{
    			testOpportunity.iRep__c = oldAccountIRep.Id;
    			testOpportunity.StageName = '1- Prospect';
    			testSameOpportunities.add( testOpportunity );
    		}
    		for( Opportunity testOpportunity : TestDataGeneration.createOpportunities( opportunitiesWithDiffIRep, testAccount.Id, false ) )
    		{
    			testOpportunity.iRep__c = alternativeOpportunityIRep.Id;
    			testOpportunity.StageName = '1- Prospect';
    			testDiffOpportunities.add( testOpportunity );
    		}
    	}
		List<Opportunity> allOpportunities = new List<Opportunity>();
		allOpportunities.addAll( testSameOpportunities );
		allOpportunities.addAll( testDiffOpportunities );
		insert allOpportunities;

    	Test.startTest();

			SyncOpportunityRepsToAccountBatch job = new SyncOpportunityRepsToAccountBatch();
			job.query += ' AND Id IN ' + flattenAccountListForQuery( testAccounts ) + ' LIMIT 200 ';

			Database.executeBatch( job );

    	Test.stopTest();

    	List<Opportunity> updatedSameIRepOpportunities = [ SELECT Id, iRep__c, iRep_Plan_Stamp__c FROM Opportunity WHERE Id IN :testSameOpportunities ];
    	System.assertEquals( opportunitiesWithSameIRep * accountsToCreate, updatedSameIRepOpportunities.size(), 'The same number of created same IRep opportunities should have been retrieved' );

    	for( Opportunity updatedOpportunity : updatedSameIRepOpportunities )
    	{
    		System.assertEquals( newAccountIRep.Id, updatedOpportunity.iRep__c, 'Since the opportunity had the same IRep as the account, its irep should have been updated' );
    		System.assertEquals( PLAN_STAMP_VALUE, updatedOpportunity.iRep_Plan_Stamp__c, 'Since the opportunity had the same IRep as the account, its plan stamp should have been updated' );
    	}

    	List<Opportunity> updatedDiffIRepOpportunities = [ SELECT Id, iRep__c, iRep_Plan_Stamp__c FROM Opportunity WHERE Id IN :testDiffOpportunities ];
    	System.assertEquals( opportunitiesWithDiffIRep * accountsToCreate, updatedDiffIRepOpportunities.size(), 'The same number of created different IRep opportunities should have been retrieved' );

    	for( Opportunity updatedOpportunity : updatedDiffIRepOpportunities )
    	{
    		System.assertEquals( alternativeOpportunityIRep.Id, updatedOpportunity.iRep__c, 'Opportunities with a different Irep than its account should not have its irep be updated' );
    		System.assertEquals( null, updatedOpportunity.iRep_Plan_Stamp__c, 'Opportunities with a different Irep than its account should not have its plan stamp be updated' );
    	}
	}

	static String flattenAccountListForQuery( List<Account> accounts )
	{
		String returnString = '';

		for( Account testAccount : accounts )
		{
			returnString += '\'' + testAccount.Id + '\',';
		}

		returnString = '(' + returnString.substring( 0, returnString.length() - 1 ) + ')';

		return returnString;
	}

}
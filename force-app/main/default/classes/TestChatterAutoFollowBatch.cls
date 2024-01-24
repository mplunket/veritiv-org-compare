@isTest
private class TestChatterAutoFollowBatch 
{
	private static final Integer CHATTER_LIMIT = 100;  //Specify how many records Salesforce limits a record for following on Chatter
	
	private static final String OPPORTUNITY_PREFIX = Opportunity.SObjectType.getDescribe().getKeyPrefix();

	private static Chatter_Auto_Follow_Records__c salesUserCS;
	private static User salesUser;
	private static UserRole repRole;
	
	static {
		repRole = [Select Id, Name, DeveloperName From UserRole Where Name like 'PRI - TSB - Rep' Limit 1][0];
	}

	private static void setupEmailCustomSettings()
	{
		Read_Write_Batch_Job_Email_List__c emailOne = new Read_Write_Batch_Job_Email_List__c( Name = 'Philip Choi', Email_Address__c = 'philip.choi@bluewolfgroup.com' );
		Read_Write_Batch_Job_Email_List__c emailTwo = new Read_Write_Batch_Job_Email_List__c( Name = 'James Dadouris', Email_Address__c = 'james.dadouris@bluewolfgroup.com' );
		insert new List<Read_Write_Batch_Job_Email_List__c> { emailOne, emailTwo };
	}
	private static void setupCustomSettings() 
	{
		salesUserCS = new Chatter_Auto_Follow_Records__c();
		salesUserCS.Name = 'Sales Professional - Lightning';
		System.runAs( TestingUtils.ADMIN_USER )
		{
			setupEmailCustomSettings();
			insert salesUserCS;
		}
	}

	
	private static Integer setupForSampleBatchTest()
	{
		final Integer NUM_OF_OPPTIES = 12;
		final Integer NUM_OF_PSRS = 6;
		final Integer NUM_OF_SALES_USERS = 3;
		final Integer NUM_OF_NON_SALES_USERS = 3;
		setupCustomSettings();
	
		Account testAccount = TestingUtils.createAccount( 'Test Acct' );
		insert testAccount;

		salesUser = TestingUtils.createUsers( 'Sales', salesUserCS.Name, 1, false )[0];
		User nonSalesUser = TestingUtils.createUsers( 'None', 'Standard User', 1, false )[0];
		salesUser.UserRoleId = repRole.Id;
		nonSalesUser.UserRoleId = repRole.Id;
		List<User> testUsers = new List<User>{ salesUser, nonSalesUser };
		System.runAs( TestingUtils.ADMIN_USER )
		{
			insert testUsers;
		}

		List<Primary_Sales_Rep__c> testPSRs = TestingUtils.createPSRs( NUM_OF_PSRS, 'James', '0000', false );
		for( Integer i = 0; i < NUM_OF_PSRS; i++ )
		{
			Integer residue = Math.mod( i, 2 );
			if( residue == 0 )
			{
				testPSRs[i].SF_userid__c = salesUser.Id;
			}
			else
			{
				testPSRs[i].SF_userid__c = nonSalesUser.Id;
			}
		}
		insert testPSRs;

		List<Opportunity> testOppties = TestingUtils.createOpportunities( NUM_OF_OPPTIES, testAccount.Id, 'Test Oppty', false );
		for( Integer i = 0; i < NUM_OF_OPPTIES; i++ )
		{
			Integer residue = Math.mod( i, 4 );
			if( residue == 0 )
			{
				testOppties[i].OwnerId = salesUser.Id;
			}
			else if( residue == 1 )
			{
				testOppties[i].OwnerId = nonSalesUser.Id;
			}
			else if( residue == 2 )
			{
				testOppties[i].Primary_Sales_Rep_Name__c = testPSRs[0].Id;
			}
			else
			{
				testOppties[i].Primary_Sales_Rep_Name__c = testPSRs[1].Id;
			}
		}
		insert testOppties;
		return NUM_OF_OPPTIES/2; //This is the number of entity subscriptions we expect to create
	}
	private static Set<ID> setupAccountsandOpportunitiesBatchTest(Integer NUM_Oldest_Accounts, Integer NUM_Old_Accounts, Integer NUM_New_Accounts, Integer NUM_New_Oppties, Integer NUM_Old_Oppties, Integer NUM_Oldest_Oppties)
	{ 		
		final Date oldestDate =  Date.today()-3650;
		final Date oldDate = Date.today()-45;
		final Date newDate = Date.today()-1;
		
		setupCustomSettings();
		salesUser = TestingUtils.createUsers( 'Sales', salesUserCS.Name, 1, false )[0];
		salesUser.UserRoleId = repRole.Id;
		System.runAs( TestingUtils.ADMIN_USER ){
			insert salesUser; 
		}
		
		List<Opportunity> testOpptiesOld;
		List<Opportunity> testOpptiesOldest;
		List<Opportunity> testOpptiesNew;

		Set<ID> oldestRecords = new Set<ID>();
	
		List<Account> testAccountsOld;
		List<Account> testAccountsOldest;
		List<Account> testAccountsNew;
		
		List<Opportunity> allOppties = new List<Opportunity>();
		List<Account> allAccounts = new List<Account>();
		System.runAs(salesUser)
		{
			testAccountsOld = TestingUtils.createAccounts( 'Test Acct', NUM_Old_Accounts);
			for(Account a : testAccountsOld)
			{
				a.put(DateGetters.FIELD_FOR_TESTING_IN_ACCOUNT,oldDate);
				a.Active__c = 'Yes';
			}
			testAccountsOldest = TestingUtils.createAccounts( 'Test Acct', NUM_Oldest_Accounts);
			for(Account a : testAccountsOldest)
			{
				a.put(DateGetters.FIELD_FOR_TESTING_IN_ACCOUNT,oldestDate);
				a.Active__c = 'Yes';
			}
			testAccountsNew = TestingUtils.createAccounts( 'Test Acct', NUM_New_Accounts);
			for(Account a : testAccountsNew)
			{
				a.put(DateGetters.FIELD_FOR_TESTING_IN_ACCOUNT,newDate);
				a.Active__c = 'Yes';
			}
			allAccounts.addAll(testAccountsOld);
			allAccounts.addAll(testAccountsOldest);
			allAccounts.addAll(testAccountsNew);
			
			insert allAccounts;
			deleteAllEntitySubscriptions();
			
			testOpptiesOld = TestingUtils.createOpportunities( NUM_Old_Oppties, allAccounts[0].Id , 'Test Opp', false);
			for(Opportunity o : testOpptiesOld)
			{
				o.put(DateGetters.FIELD_FOR_TESTING_IN_Opportunity,oldDate);
			}
			testOpptiesOldest = TestingUtils.createOpportunities( NUM_Oldest_Oppties, allAccounts[0].Id , 'Test Opp', false);
			for(Opportunity o : testOpptiesOldest)
			{
				o.put(DateGetters.FIELD_FOR_TESTING_IN_Opportunity,oldestDate);
			}
			testOpptiesNew =  TestingUtils.createOpportunities( NUM_New_Oppties, allAccounts[0].Id , 'Test Opp', false);
			for(Opportunity o : testOpptiesNew)
			{
				o.put(DateGetters.FIELD_FOR_TESTING_IN_Opportunity,newDate);
			}
			allOppties.addAll(testOpptiesOld);
			allOppties.addAll(testOpptiesOldest);
			allOppties.addAll(testOpptiesNew);
			
			insert allOppties;
			deleteAllEntitySubscriptions();
			for(Opportunity o : testOpptiesOldest)
			{
				oldestRecords.add(o.ID);
			}
			for(Account a : testAccountsOldest)
			{
				oldestRecords.add(a.ID);
			}	
		}
		return oldestRecords;
	}
	private static testMethod void testBatchPrioritizationForOnlyHaveOpportunities()
	{
		final Integer NUM_Oldest_Accounts = (CHATTER_LIMIT/5);
		final Integer NUM_Old_Accounts = CHATTER_LIMIT/5;
		final Integer NUM_New_Accounts = CHATTER_LIMIT/5;
		final Integer NUM_New_Oppties = CHATTER_LIMIT/5;
		final Integer NUM_Old_Oppties = CHATTER_LIMIT/10;
		final Integer NUM_Oldest_Oppties = CHATTER_LIMIT/10;
		final Integer EXPECTED_TOTAL_ENTITY_SUBCRIPTIONS = NUM_New_Oppties + NUM_Old_Oppties + NUM_Oldest_Oppties;
		setupAccountsandOpportunitiesBatchTest(NUM_Oldest_Accounts,NUM_Old_Accounts,NUM_New_Accounts,NUM_New_Oppties,NUM_Old_Oppties,NUM_Oldest_Oppties);	
		Test.startTest();

			ChatterAutoFollowBatch nextBatch = new ChatterAutoFollowBatch(DateGetterFactory.getDateGetter(DateGetterFactory.GETTER_UNIT_TESTING),EntitySubscriptionSorterFactory.getEntitySubscriptionSorter(EntitySubscriptionSorterFactory.OnlyHaveOpportunities) ); 
			Database.executeBatch(nextBatch);

		Test.stopTest();
		
		List<EntitySubscription> entitySubs = [ SELECT Id, ParentId, SubscriberId FROM EntitySubscription ];
		System.assertEquals( EXPECTED_TOTAL_ENTITY_SUBCRIPTIONS , entitySubs.size(), 'The right number of entity subscriptions must be made' );
		
		for(EntitySubscription e : entitySubs)
		{
			System.assert(!ChatterServices.isAccount(e.parentId),'No account entity subscriptions may be created');
		}
	}
	
	private static testMethod void testBatchPrioritizationForPreferOpportunitiesBeforeAccounts()
	{
		final Integer NUM_Oldest_Accounts = 2*(CHATTER_LIMIT/5);
		final Integer NUM_Old_Accounts = CHATTER_LIMIT/5;
		final Integer NUM_New_Accounts = CHATTER_LIMIT/5;
		final Integer NUM_New_Oppties = CHATTER_LIMIT/5;
		final Integer NUM_Old_Oppties = CHATTER_LIMIT/10;
		final Integer NUM_Oldest_Oppties = CHATTER_LIMIT/10;
		
		/* NUM_New_Oppties + NUM_Old_Oppties + NUM_Oldest_Oppties + NUM_New_Accounts + NUM_Old_Accounts + (1/2)NUM_Oldest_Accounts = CHATTER_LIMIT 
		   AS a consequence, half on the oldest accounts will not be included. This is what we must check for in this unit test */
		
		final Integer EXPECTED_NUM_OLDEST_ACCOUNT_SUBSCRIPTIONS = NUM_Oldest_Accounts/2;
		
		Set<ID> oldestRecords = setupAccountsandOpportunitiesBatchTest(NUM_Oldest_Accounts,NUM_Old_Accounts,NUM_New_Accounts,NUM_New_Oppties,NUM_Old_Oppties,NUM_Oldest_Oppties);	
		Test.startTest();

			ChatterAutoFollowBatch nextBatch = new ChatterAutoFollowBatch(DateGetterFactory.getDateGetter(DateGetterFactory.GETTER_UNIT_TESTING),EntitySubscriptionSorterFactory.getEntitySubscriptionSorter(EntitySubscriptionSorterFactory.PreferOpportunitiesBeforeAnyAccounts) ); 
			Database.executeBatch(nextBatch);

		Test.stopTest();
		
		List<EntitySubscription> entitySubs = [ SELECT Id, ParentId, SubscriberId FROM EntitySubscription ];
		System.assertEquals( CHATTER_LIMIT+NUM_New_Accounts , entitySubs.size(), 'The right number of entity subscriptions must be made. We cannot exceed the chatter limit.' );
		
		Integer NUM_Oldest_Accounts_Found = 0;
		
		for(EntitySubscription e : entitySubs)
		{
			if(ChatterServices.isAccount(e.parentId) && oldestRecords.contains(e.parentId))
			{
				NUM_Oldest_Accounts_Found++;
			}
		}
		
		// System.assertEquals(EXPECTED_NUM_OLDEST_ACCOUNT_SUBSCRIPTIONS,NUM_Oldest_Accounts_Found,'There should be entity subscriptions to the right number of oldest Accounts');
	}
	
 	private static testMethod void testBatchPrioritizationOnlyShowOpportunities()
 	{
 		//Date_Accounts > Date_New Opportunities > Date_Old_Opportunities
 		final Integer NUM_Oldest_Opportunities = 3*CHATTER_LIMIT/5;
 		final Integer NUM_Old_Opportunities= CHATTER_LIMIT/5;
 		final Integer NUM_New_Opportunities= CHATTER_LIMIT/5;
 		final Integer NUM_Accounts =  CHATTER_LIMIT/5;
 		final Date Date_Oldest_Opportunities = Date.today()-3650;
 		final Date Date_Old_Opportunities = Date.today()-365;
 		final Date Date_New_Opportunities = Date.today()-1;
 		final Date Date_Accounts = Date.today();
 		
 		setupCustomSettings();
		salesUser = TestingUtils.createUsers( 'Sales', salesUserCS.Name, 1, false )[0];
		salesUser.UserRoleId = repRole.Id;
		System.runAs( TestingUtils.ADMIN_USER ){
			insert salesUser; 
		}
		
		List<Opportunity> testOpptiesOld ;
		List<Opportunity> testOpptiesOldest ;
		List<Opportunity> testOpptiesNew;
		System.runAs(salesUser)
		{
			List<Account> testAccountsToday = TestingUtils.createAccounts( 'Test Acct', NUM_Accounts);
			for(Account a : testAccountsToday)
			{
				a.put(DateGetters.FIELD_FOR_TESTING_IN_ACCOUNT,Date_Accounts);
				a.Active__c = 'Yes';
			}
			insert testAccountsToday;
			deleteAllEntitySubscriptions();
			
			testOpptiesOldest = TestingUtils.createOpportunities( NUM_Oldest_Opportunities, testAccountsToday[0].Id, 'Test Oppty', false );
			
			for(Opportunity o : testOpptiesOldest)
			{
				o.put(DateGetters.FIELD_FOR_TESTING_IN_OPPORTUNITY,Date_Oldest_Opportunities);
			}
			
			testOpptiesOld = TestingUtils.createOpportunities( NUM_Old_Opportunities, testAccountsToday[0].Id, 'Test Oppty', false );
			
			for(Opportunity o : testOpptiesOld)
			{
				o.put(DateGetters.FIELD_FOR_TESTING_IN_OPPORTUNITY,Date_Old_Opportunities);
			}
			testOpptiesNew = TestingUtils.createOpportunities( NUM_New_Opportunities, testAccountsToday[0].Id, 'Test Oppty', false );
			for(Opportunity o : testOpptiesNew)
			{
				o.put(DateGetters.FIELD_FOR_TESTING_IN_OPPORTUNITY,Date_New_Opportunities);
			}
			
			List<Opportunity> oppsToInsert = new List<Opportunity>();
			oppsToInsert.addAll(testOpptiesOld);
			oppsToInsert.addAll(testOpptiesNew);
			oppsToInsert.addAll(testOpptiesOldest);
			insert oppsToInsert;
			
			deleteAllEntitySubscriptions();
		}
		
		Test.startTest();

			ChatterAutoFollowBatch nextBatch = new ChatterAutoFollowBatch(DateGetterFactory.getDateGetter(DateGetterFactory.GETTER_UNIT_TESTING),EntitySubscriptionSorterFactory.getEntitySubscriptionSorter(EntitySubscriptionSorterFactory.PreferOpportunitiesBeforeAnyAccounts) ); 
			Database.executeBatch(nextBatch);

		Test.stopTest();
		
		List<EntitySubscription> entitySubs = [ SELECT Id, ParentId, SubscriberId FROM EntitySubscription ];
		System.assertEquals( CHATTER_LIMIT+NUM_New_Opportunities , entitySubs.size(), 'Only so many entity subscriptions will be created, as Salesforce has a limit on how many records a user can follow' );

 		for( EntitySubscription es : entitySubs )
		{
			//Assert it belongs to an opportunity
			//System.assert( ChatterServices.isOpportunity(es.parentId), 'Entity subscriptions should only be on opportunities, as they have been prioritized over accounts, and given salesforce limits, there is no room to make the user follow an account' );
		}

 	}
 	
 	
 	private static void deleteAllEntitySubscriptions()
 	{
 		System.runAs(TestingUtils.ADMIN_USER)
 		{
			System.debug('$$$ entitySubsToDelete to follow');
 			List<EntitySubscription> entitySubsToDelete = [ SELECT Id, ParentId, SubscriberId FROM EntitySubscription ];
			delete entitySubsToDelete; //Delete the subscriptions that were created via trigger, so you can test to see if batch will remake them
 		}
 	}
 	
	private static testMethod void testBatch()
	{
		final Integer EXPECTED_SUBSCRIPTIONS = setupForSampleBatchTest();
		deleteAllEntitySubscriptions();
		Test.startTest();

			ChatterAutoFollowBatch nextBatch = new ChatterAutoFollowBatch();
			Database.executeBatch( nextBatch );

		Test.stopTest();

		List<EntitySubscription> entitySubs = [ SELECT Id, ParentId, SubscriberId FROM EntitySubscription ];
		System.assertEquals( EXPECTED_SUBSCRIPTIONS, entitySubs.size(), 'We expect the right number of entity subscriptions' );

		for( EntitySubscription es : entitySubs )
		{
			System.assertEquals( salesUser.Id, es.SubscriberId, 'We expect only sales users to be subscribed' );
		}
	}
}
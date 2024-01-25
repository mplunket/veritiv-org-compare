@isTest
public with sharing class TestEntitySubscriptionSorterFactory {
	private static final String sampleText = 'sample';
	private static final Integer bulkNumber = 20;
	
	
	static testMethod void testFactoryMethodForPreferOpportunitiesBeforeAnyAccounts() 
    {
		test.startTest();
			EntitySubscriptionSorters.EntitySubscriptionSorter returnedInstance = EntitySubscriptionSorterFactory.getEntitySubscriptionSorter( EntitySubscriptionSorterFactory.PreferOpportunitiesBeforeAnyAccounts );
		test.stopTest();
		System.assert(returnedInstance InstanceOf EntitySubscriptionSorters.PreferOpportunitiesBeforeAnyAccounts,'It should have returned the right instance');
    }
    
    static testMethod void testFactoryMethodForOnlyHaveOpportunities() 
    {
		test.startTest();
			EntitySubscriptionSorters.EntitySubscriptionSorter returnedInstance = EntitySubscriptionSorterFactory.getEntitySubscriptionSorter( EntitySubscriptionSorterFactory.OnlyHaveOpportunities );
		test.stopTest();
		System.assert(returnedInstance InstanceOf EntitySubscriptionSorters.OnlyHaveOpportunities,'It should have returned the right instance');
    }
    
    static testMethod void testPreferOpportunitiesBeforeAnyAccounts()
    {
    	User testUser = TestingUtils.createUsers( sampleText, 'Standard User', 1, true )[0];
    	
    	DateGetters.DateGetter dateGetterForUnitTesting = DateGetterFactory.getDateGetter(DateGetterFactory.GETTER_UNIT_TESTING);
    	
    	
		List<Account> testAccounts = TestingUtils.createAccounts(sampleText, bulkNumber );
		
		Integer daysAdd = 0;
		
		for(Account a : testAccounts)
		{
			a.put(DateGetters.FIELD_FOR_TESTING_IN_ACCOUNT,Date.today().addDays(daysAdd));
			daysAdd++;
		}
		insert testAccounts;
		
		List<Opportunity> testOpportunities = TestingUtils.createOpportunities(bulkNumber, testAccounts[0].ID, sampleText, false);
		
		for(Opportunity o : testOpportunities)
		{
			o.put(DateGetters.FIELD_FOR_TESTING_IN_OPPORTUNITY,Date.today().addDays(daysAdd));
			daysAdd++;
		}
		
		insert testOpportunities;
		
		List<EntitySubscription> listSubscriptions = new List<EntitySubscription>();
		Map<ID,SObject> records = new Map<ID,SObject>();
		for(Account a : testAccounts)
		{
			listSubscriptions.add(TestingUtils.createEntitySubscription(a.Id,testUser.ID));
			records.put(a.Id,a);
		}
		for(Opportunity o : testOpportunities)
		{
			listSubscriptions.add(TestingUtils.createEntitySubscription(o.ID,testUser.ID));
			records.put(o.Id,o);
		}
		
		EntitySubscriptionSorters.EntitySubscriptionSorter sorter = EntitySubscriptionSorterFactory.getEntitySubscriptionSorter( EntitySubscriptionSorterFactory.PreferOpportunitiesBeforeAnyAccounts );
		
		final Integer OLD_SIZE = listSubscriptions.size();
		
		Test.startTest();
			List<EntitySubscription> sortedListSubscriptions = sorter.sortByDateGetter(listSubscriptions,records,dateGetterForUnitTesting);
		Test.stopTest();
		
		System.assertEquals(OLD_SIZE,sortedListSubscriptions.size(),'The size of the list should not change');
		Boolean accountEncountered = false;
		Integer accountIndexexpected = testAccounts.size() - 1;
		Integer oppIndexexpected = testOpportunities.size() - 1;
		
		for(EntitySubscription e : sortedListSubscriptions)
		{
			if(ChatterServices.isOpportunity(e.parentID))
			{
				if(accountEncountered)
				{
					System.assert(false,'All opportunities must be before any accounts');
				}
				else
				{
					System.assertEquals(testOpportunities[oppIndexexpected].ID,e.parentID,'The entity subscriptions on opportunities must be in descending order by date.');
					oppIndexexpected--;
				}
			}
			else if(ChatterServices.isAccount(e.parentID))
			{
				accountEncountered = true;
				System.assertEquals(testAccounts[accountIndexexpected].ID,e.parentID,'The entity subscriptions on accounts must be in descending order by date.');
				accountIndexexpected--;
			}
			else
			{
				System.assert(false,'The entity subscriptions must have either account or opportunity parentIds');
			}
		}
    } 
    
    static testMethod void testOnlyHaveOpportunities()
    {
    	User testUser = TestingUtils.createUsers( sampleText, 'Standard User', 1, true )[0];
    	
    	DateGetters.DateGetter dateGetterForUnitTesting = DateGetterFactory.getDateGetter(DateGetterFactory.GETTER_UNIT_TESTING);
    	
    	
		List<Account> testAccounts = TestingUtils.createAccounts(sampleText, bulkNumber );
		
		Integer daysAdd = 0;
		
		for(Account a : testAccounts)
		{
			a.put(DateGetters.FIELD_FOR_TESTING_IN_ACCOUNT,Date.today().addDays(daysAdd));
			daysAdd++;
		}
		insert testAccounts;
		
		List<Opportunity> testOpportunities = TestingUtils.createOpportunities(bulkNumber, testAccounts[0].ID, sampleText, false);
		
		for(Opportunity o : testOpportunities)
		{
			o.put(DateGetters.FIELD_FOR_TESTING_IN_OPPORTUNITY,Date.today().addDays(daysAdd));
			daysAdd++;
		}
		
		insert testOpportunities;
		
		List<EntitySubscription> listSubscriptions = new List<EntitySubscription>();
		Map<ID,SObject> records = new Map<ID,SObject>();
		for(Account a : testAccounts)
		{
			listSubscriptions.add(TestingUtils.createEntitySubscription(a.Id,testUser.ID));
			records.put(a.Id,a);
		}
		for(Opportunity o : testOpportunities)
		{
			listSubscriptions.add(TestingUtils.createEntitySubscription(o.ID,testUser.ID));
			records.put(o.Id,o);
		}
		
		EntitySubscriptionSorters.EntitySubscriptionSorter sorter = EntitySubscriptionSorterFactory.getEntitySubscriptionSorter( EntitySubscriptionSorterFactory.OnlyHaveOpportunities );
		
		final Integer SIZE_OPPORTUNITIES = testOpportunities.size();
		
		Test.startTest();
			List<EntitySubscription> sortedListSubscriptions = sorter.sortByDateGetter(listSubscriptions,records,dateGetterForUnitTesting);
		Test.stopTest();
		
		System.assertEquals(SIZE_OPPORTUNITIES,sortedListSubscriptions.size(),'The size of the list should decrease to only include the number of opportunities');
		Integer oppIndexexpected = testOpportunities.size() - 1;
		
		for(EntitySubscription e : sortedListSubscriptions)
		{
			System.assert(!ChatterServices.isAccount(e.parentID),'No account entity subscriptions should have been generated');
			if(ChatterServices.isOpportunity(e.parentID))
			{
				System.assertEquals(testOpportunities[oppIndexexpected].ID,e.parentID,'The entity subscriptions on opportunities must be in descending order by date.');
				oppIndexexpected--;
			}
			else
			{ 
				//Strange, not an account or an opportunity! 
				System.assert(false,'The entity subscriptions must have either account or opportunity parentIds');
			}
		} 
    } 
    
   
}
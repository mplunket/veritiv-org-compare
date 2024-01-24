@isTest
public class TestChatterDateTimeWrapper {
	private static final String sampleText = 'sample';
	private static final Integer bulkNumber = 20;
	  
	private static testMethod void testGetSortedListByDESCOrder()
	{
		User testUser = TestingUtils.createUsers( sampleText, 'Standard User', 1, true )[0];
		List<Account> testAccounts = TestingUtils.createAccounts(sampleText, bulkNumber );
		insert testAccounts;
		
		List<ChatterDateTimeWrapper> wrappers = new List<ChatterDateTimeWrapper>();
		
		//Wrappers created in ascending order
		for(Integer k = 0; k < bulkNumber; k++)
		{
			wrappers.add(new ChatterDateTimeWrapper(TestingUtils.createEntitySubscription(testUser.ID,testAccounts[k].ID),(DateTime) (Date.today().addDays(k))));
		}
		
		Test.startTest();
			List<EntitySubscription> sortedList = ChatterDateTimeWrapper.getSortedListByDESCOrder(wrappers);
		Test.stopTest();
		
		System.assertEquals(bulkNumber,sortedList.size(),'It must have the correct size');
		
		//Now check to see if it is in desc order
		Integer postNumber = bulkNumber-1;
		
		for(EntitySubscription e : sortedList)
		{
			System.assertEquals(testAccounts[postNumber].Id,e.SubscriberId,'The entity subscriptions must be arranged in descending order ');
			postNumber--;
		}
	}
}
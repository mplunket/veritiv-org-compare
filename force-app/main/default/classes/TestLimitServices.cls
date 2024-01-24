@isTest
private class TestLimitServices {
	
	static final Integer NUM_QUERY_ROWS_LEFT = 4;
	static Account testAccount;
	static Set<Id> existingGroups;
	
	/* After this function, we will only have 4 records we can query back before we expect our exception*/
	
	static{
		existingGroups = TestSafeUpdate.preexistingGroups;
	}
	
	private static void setupForQuerySObjects()
	{
		LimitServices.QUERY_ROWS_THRESHOLD = NUM_QUERY_ROWS_LEFT+1;
	}
	
	static void assertQueryRowsLimitExceptionHandling(Boolean doWeExpectException, String message)
	{
		Boolean exceptionCaught = false; 
		try
		{
			LimitServices.QUERY_ROWS_THRESHOLD += existingGroups.size();
			
			String query = 'Select ID from Group Where Id!= NULL';
			List<Group> grps = LimitServices.querySObjects( query ); 
		}
		catch (LimitServices.CloseToQueryRowsLimitException e)
		{
			exceptionCaught = true;
			message += e.getMessage();
		}
		//System.assertEquals(doWeExpectException, exceptionCaught, message);
	}
	
	private static testMethod void testQuerySObjects_RowsAlreadyAboveThreshold()
	{
		setupForQuerySObjects();
		LimitServices.QUERY_ROWS_THRESHOLD=1;
		
		List<Group> testGroups = TestSafeDML.createGroups('Test G', 1); 
		insert testGroups;
		
		Test.StartTest();
			assertQueryRowsLimitExceptionHandling(true,'We expect to get an error indicating we are close to the query rows limit because we were already above the threshold before we made our query' + LimitServices.QUERY_ROWS_THRESHOLD);
		Test.StopTest();
	}
	
	private static testMethod void testQuerySObjects_RowsLessThanThreshold()
	{
		setupForQuerySObjects();
		
		List<Group> testGroups = TestSafeDML.createGroups('Test G', NUM_QUERY_ROWS_LEFT-1);
		insert testGroups;
		
		Test.StartTest();
			assertQueryRowsLimitExceptionHandling(false,'We do not expect to get an error indicating we are close to the query rows limit when we are below the threshold');
		Test.StopTest();
	}
	
	private static testMethod void testQuerySObjects_RowsEqualToThreshold()
	{
		setupForQuerySObjects();
		
		List<Group> testGroups = TestSafeDML.createGroups('Test G', NUM_QUERY_ROWS_LEFT);
		insert testGroups;
		
		Test.StartTest();
			//assertQueryRowsLimitExceptionHandling(false,'We do not expect to get an error indicating we are close to the query rows limit when we are just at the threshold');
		Test.StopTest();	
	}
	
	private static testMethod void testQuerySObjects_RowsGreaterThanThreshold()
	{
		setupForQuerySObjects();
		
		List<Group> testGroups = TestSafeDML.createGroups('Test G', NUM_QUERY_ROWS_LEFT+1);
		insert testGroups;
		
		Test.StartTest();
			assertQueryRowsLimitExceptionHandling(true,'We expect to get an error indicating we are close to the query rows limit when we are beyond the threshold' + LimitServices.QUERY_ROWS_THRESHOLD);
		Test.StopTest();
	}
	
	private static testMethod void testCheckDMLRowsLimit()
	{
		insert TestSafeDML.createGroups('Test G', 48);
		LimitServices.DML_ROWS_THRESHOLD = 50;
		
		Test.StartTest();
		try
		{
			LimitServices.checkDMLRowsLimit( 1 );
		}
		catch(LimitServices.CloseToDMLRowsLimitException e)
		{
			System.assert(false,'We do not expect to get an error indicating we are close to the dml rows threshold when we are not');
		}
		Test.StopTest();
	}
	
	private static testMethod void testCheckDMLRowsLimit_Fail()
	{
		insert TestSafeDML.createGroups('Test G', 1);
		
		LimitServices.DML_ROWS_THRESHOLD = 50;
		
		try
		{
			LimitServices.checkDMLRowsLimit( 49 );
			System.assert(false, 'We expect an error indicating we are close to the dml rows threshold');
		}
		catch(LimitServices.CloseToDMLRowsLimitException e)
		{
			
		}
	}

}
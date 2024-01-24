@isTest
private class TestBatchServices {
	private static final Integer NUM_OF_OBJs = 5;
	
	private static testMethod void testDmlOperationTruncate()
	{
		
		List<Account> testAccounts = TestingUtils.createAccounts('TestAcct', NUM_OF_OBJs); 
		DateTime dateTimeValue = DateTime.now();
		String DML_LIMIT_ERROR = 'DML Limit Met - please re-run the batch from this date : ' + dateTimeValue.format() + '\n\n';
		String errorMessage = '';
		Integer dmlLimit = 3;
		
		Test.startTest();
				errorMessage = BatchServices.batchInsertDMLOperation( testAccounts, dmlLimit, DML_LIMIT_ERROR);			
		Test.stopTest();

		System.assertEquals(dmlLimit, testAccounts.size(), 'The Size of the list should be equal to the dmllimit' );
		System.assert(errorMessage.contains(dateTimeValue.format()), 'The error message should indicate the re-start time' );
		
	}
	
	private static testMethod void testDmlOperationNoMoreDMLsALLowed()
	{
		List<Account> testAccounts = TestingUtils.createAccounts('TestAcct', NUM_OF_OBJs); 
		DateTime dateTimeValue = DateTime.now();
		String DML_LIMIT_ERROR = 'DML Limit Met - please re-run the batch from this date : ' + dateTimeValue.format() + '\n\n';
		String errorMessage = '';
		Integer dmlLimit = 0;
		
		Test.startTest();
				errorMessage = BatchServices.batchUpsertDMLOperation( testAccounts, dmlLimit, DML_LIMIT_ERROR);			
		Test.stopTest();

		System.assert(testAccounts.isEmpty(), 'The list should be empty' );
		System.assert(errorMessage.contains(dateTimeValue.format()), 'The error message should indicate the re-start time' );
		
	}
	
	private static testMethod void testInsertDmlOperationErrorHandling()
	{
		AccountTeamMember testAMember = TestingUtils.createAccountTeamMember(null, null, false);
		DateTime dateTimeValue = DateTime.now();
		String DML_LIMIT_ERROR = 'DML Limit Met - please re-run the batch from this date : ' + dateTimeValue.format() + '\n\n';
		String errorMessage = '';
		Integer dmlLimit = 5;
		
		Test.startTest();
				errorMessage = BatchServices.batchInsertDMLOperation( new List<AccountTeamMember> {testAMember}, dmlLimit, DML_LIMIT_ERROR);			
		Test.stopTest();
		
		System.assertEquals( null, testAMember.Id, 'Since no dml occurred, the account team member should not have an Id');
        //System.assert(false,errorMessage);
        System.assert( errorMessage.contains( 'Required fields are missing:' ),errorMessage);
	}
	private static testMethod void testUpsertDmlOperationErrorHandling()
	{
		AccountTeamMember testAMember = TestingUtils.createAccountTeamMember(null, null, false);
		DateTime dateTimeValue = DateTime.now();
		String DML_LIMIT_ERROR = 'DML Limit Met - please re-run the batch from this date : ' + dateTimeValue.format() + '\n\n';
		String errorMessage = '';
		Integer dmlLimit = 5;
		
		Test.startTest();
				errorMessage = BatchServices.batchUpsertDMLOperation( new List<AccountTeamMember> {testAMember}, dmlLimit, DML_LIMIT_ERROR);			
		Test.stopTest();
		
		System.assertEquals( null, testAMember.Id, 'Since no dml occurred, the account team member should not have an Id');
        //System.assert(false,errorMessage);
        System.assert( errorMessage.contains( 'Required fields are missing:' ),errorMessage);
	}
	private static testMethod void testDeleteDmlOperationErrorHandling()
	{
		User testUser = TestingUtils.createUser( 'User', 'Standard User', true ); 
		List<Account> testAccounts = TestingUtils.createAccounts( 'Test GAccount', testUser.Id, 1 );
		testAccounts.addAll( TestingUtils.createAccounts( 'Test GAccount', testUser.Id, 1 ));
		
		DateTime dateTimeValue = DateTime.now();
		String DML_LIMIT_ERROR = 'DML Limit Met - please re-run the batch from this date : ' + dateTimeValue.format() + '\n\n';
		String errorMessage = '';
		Integer dmlLimit = 5;
		
		Test.startTest();
				errorMessage = BatchServices.batchDeleteDMLOperation( testAccounts, dmlLimit, DML_LIMIT_ERROR); 		
		Test.stopTest();
		
		List<Account> existingAccounts = [SELECT Id FROM Account];	
		System.assert( existingAccounts.isEmpty(), 'We expect no accounts to exists.');
        System.assert( String.isNotBlank( errorMessage ), 'We expect an error to occur. Message: ' + errorMessage);
	}
	private static testMethod void testDeleteDmlOperation()
	{
		User testUser = TestingUtils.createUser( 'User', 'Standard User', true ); 
		List<Account> testAccounts = TestingUtils.createAccounts( 'Test GAccount', testUser.Id, 100 );
		insert testAccounts;
		
		DateTime dateTimeValue = DateTime.now();
		String DML_LIMIT_ERROR = 'DML Limit Met - please re-run the batch from this date : ' + dateTimeValue.format() + '\n\n';
		String errorMessage = '';
		Integer dmlLimit = 500;
		
		Test.startTest();
				errorMessage = BatchServices.batchDeleteDMLOperation( testAccounts, dmlLimit, DML_LIMIT_ERROR); 			
		Test.stopTest();
		
		List<Account> existingAccounts = [SELECT Id FROM Account];		
		System.assert( existingAccounts.isEmpty(), 'We expect all the accounts to be deleted.');
        System.assert( String.isBlank(errorMessage), 'We expect there to be no errors.');
	}
}
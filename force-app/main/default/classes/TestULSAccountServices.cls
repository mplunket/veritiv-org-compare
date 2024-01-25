@isTest
private class TestULSAccountServices
{
	static final Integer NUM_OF_ULS_ACCTS = 5;
	static final Integer NUM_OF_NON_ULS_ACCTS = 7;

	static List<Account> testAccounts;
	static List<Account> nonULSAccounts;
	static List<Account> ulsAccounts;

	static void populateDummyIDs(List<Account> accts)
	{
		for( Integer i = 0; i < accts.size(); i++ )
		{
			String Id_Prefix = Account.SObjectType.getDescribe().getKeyPrefix();
			String idSuffix = String.valueOf( i ).leftPad(12);
			idSuffix = idSuffix.replace(' ', '0');
			
			accts[i].id= Id_Prefix + idSuffix;
		}
	}
	
	static testMethod void testFilterULSAccounts()
	{
		testAccounts = new List<Account>();
		ulsAccounts = TestingUtils.createULSAccounts( NUM_OF_ULS_ACCTS, 'Test 3PL', false );
		/* We also consider those accounts with a certain stratification to be ULS Accounts*/
		ulsAccounts[0].Name='Test Account';
		ulsAccounts[0].Segment__c = ULSAccountServices.ULS_STRATIFICATION; 
		
		nonULSAccounts = TestingUtils.createAccounts( 'Test Account', NUM_OF_NON_ULS_ACCTS );
		testAccounts.addAll( ulsAccounts );
		testAccounts.addAll( nonULSAccounts );
		
		populateDummyIDs(testAccounts);
		
		Set<ID> expectedULSAcctsIds = Pluck.ids(ulsAccounts);

		Test.startTest();

			List<Account> filteredAccounts = ULSAccountServices.filterULSAccounts( testAccounts );

		Test.stopTest();

		System.assertEquals( NUM_OF_ULS_ACCTS, filteredAccounts.size(), 'We expect all the ULS accounts to be returned');
		for(Account acct : filteredAccounts)
		{
			System.assert(expectedULSAcctsIds.contains(acct.ID),'Only ULS accounts should be returned');
		}
		
	} 

	static testMethod void testGroupULSAccounts()
	{
		final String ULS_ONE = 'Test 3PL';
		final String ULS_TWO = 'TestTwo 3PL';
		final String ULS_THREE = 'TestThree 3PL';

		final Integer ULS_ONE_SIZE = 3;
		final Integer ULS_TWO_SIZE = 5;
		final Integer ULS_THREE_SIZE = 7;

		testAccounts = new List<Account>();
		ulsAccounts = TestingUtils.createULSAccounts( ULS_ONE_SIZE, ULS_ONE, false );
		List<Account> ulsAccountsTwo = TestingUtils.createULSAccounts( ULS_TWO_SIZE, ULS_TWO, false );
		List<Account> ulsAccountsThree = TestingUtils.createULSAccounts( ULS_THREE_SIZE, ULS_THREE, false );
		testAccounts.addAll( ulsAccounts );
		testAccounts.addAll( ulsAccountsTwo );
		testAccounts.addAll( ulsAccountsThree );

		Test.startTest();

			Map<String, List<Account>> returnedMap = ULSAccountServices.groupULSNameToAccounts( testAccounts );

		Test.stopTest();

		Integer expectedSize = 3;
		System.assertEquals( expectedSize, returnedMap.size(), 'Every ULS accounts should be returned' );

		System.assertEquals( ULS_ONE_SIZE, returnedMap.get( ULS_ONE ).size(), 'Map with ULS ONE should return ' +  ULS_ONE_SIZE + ' accounts' );
		for( Account anAccount : returnedMap.get( ULS_ONE ) )
		{
			System.assertEquals( ULS_ONE, anAccount.Name, 'Returned list should only contain accounts with ' + ULS_ONE + ' name' );
		}

		System.assertEquals( ULS_TWO_SIZE, returnedMap.get( ULS_TWO ).size(), 'Map with ULS TWO should return ' +  ULS_TWO_SIZE + ' accounts' );
		for( Account anAccount : returnedMap.get( ULS_TWO ) )
		{
			System.assertEquals( ULS_TWO, anAccount.Name, 'Returned list should only contain accounts with ' + ULS_TWO + ' name' );
		}

		System.assertEquals( ULS_THREE_SIZE, returnedMap.get( ULS_THREE ).size(), 'Map with ULS THREE should return ' +  ULS_THREE_SIZE + ' accounts' );
		for( Account anAccount : returnedMap.get( ULS_THREE ) )
		{
			System.assertEquals( ULS_THREE, anAccount.Name, 'Returned list should only contain accounts with ' + ULS_THREE + ' name' );
		}
	}

	static testMethod void testGroupULSAccounts_SimilarName()
	{
		final String GENERALIZED_ULS_NAME = 'Test 3PL';
		final String ULS_ONE = 'Test 3PL';
		final String ULS_TWO = 'Test (3PL)';
		final String ULS_THREE = 'Test(3PL)';
		final String ULS_FOUR = 'Test-(3PL)';
		Set<String> ulsNames = new Set<String>{ ULS_ONE, ULS_TWO, ULS_THREE, ULS_FOUR };

		final Integer NUM_OF_ACCOUNTS = 3;

		testAccounts = new List<Account>();
		ulsAccounts = TestingUtils.createULSAccounts( NUM_OF_ACCOUNTS, ULS_ONE, false );
		List<Account> ulsAccountsTwo = TestingUtils.createULSAccounts( NUM_OF_ACCOUNTS, ULS_TWO, false );
		List<Account> ulsAccountsThree = TestingUtils.createULSAccounts( NUM_OF_ACCOUNTS, ULS_THREE, false );
		List<Account> ulsAccountsFour = TestingUtils.createULSAccounts( NUM_OF_ACCOUNTS, ULS_FOUR, false );
		testAccounts.addAll( ulsAccounts );
		testAccounts.addAll( ulsAccountsTwo );
		testAccounts.addAll( ulsAccountsThree );
		testAccounts.addAll( ulsAccountsFour );

		Test.startTest();

			Map<String, List<Account>> returnedMap = ULSAccountServices.groupULSNameToAccounts( testAccounts );

		Test.stopTest();

		Integer expectedSize = 1;
		System.assertEquals( expectedSize, returnedMap.size(), 'Every ULS accounts should be returned' );

		System.assertEquals( NUM_OF_ACCOUNTS * 4, returnedMap.get( GENERALIZED_ULS_NAME ).size(), 'All Accounts with similar name should be returned' );
		for( Account anAccount : returnedMap.get( GENERALIZED_ULS_NAME ) )
		{
			System.assert( ulsNames.contains( anAccount.Name ), 'Map should contain all accounts with similar names' );
		}
	}

	static testMethod void testGeneralizeAccountName()
	{
		String expectedAccountName = 'Test 3PL';

		Test.startTest();

			String ULS_NAME_ONE = 'Test 3PL';
			String actualGeneralizedAccountNameOne = ULSAccountServices.generalizeAccountName( ULS_NAME_ONE );
			System.assertEquals( expectedAccountName, actualGeneralizedAccountNameOne, 'Inputted Account name should be generalized.' );

			String ULS_NAME_TWO = 'Test (3PL)';
			String actualGeneralizedAccountNameTwo = ULSAccountServices.generalizeAccountName( ULS_NAME_TWO );
			System.assertEquals( expectedAccountName, actualGeneralizedAccountNameTwo, 'Inputted Account name should be generalized.' );

			String ULS_NAME_THREE = 'Test(3PL)';
			String actualGeneralizedAccountNameThree = ULSAccountServices.generalizeAccountName( ULS_NAME_THREE );
			System.assertEquals( expectedAccountName, actualGeneralizedAccountNameThree, 'Inputted Account name should be generalized.' );

			String ULS_NAME_FOUR = 'Test-3PL';
			String actualGeneralizedAccountNameFour = ULSAccountServices.generalizeAccountName( ULS_NAME_FOUR );
			System.assertEquals( expectedAccountName, actualGeneralizedAccountNameFour, 'Inputted Account name should be generalized.' );

			String ULS_NAME_FIVE = 'Test-(3PL)';
			String actualGeneralizedAccountNameFive = ULSAccountServices.generalizeAccountName( ULS_NAME_FIVE );
			System.assertEquals( expectedAccountName, actualGeneralizedAccountNameFive, 'Inputted Account name should be generalized.' );

			String ULS_NAME_SIX = 'Test*3PL';
			String actualGeneralizedAccountNameSix = ULSAccountServices.generalizeAccountName( ULS_NAME_SIX );
			System.assertEquals( expectedAccountName, actualGeneralizedAccountNameSix, 'Inputted Account name should be generalized.' );

			String ULS_NAME_SEVEN = 'Test*(3PL)';
			String actualGeneralizedAccountNameSeven = ULSAccountServices.generalizeAccountName( ULS_NAME_SEVEN );
			System.assertEquals( expectedAccountName, actualGeneralizedAccountNameSeven, 'Inputted Account name should be generalized.' );

		Test.stopTest();
	}
}
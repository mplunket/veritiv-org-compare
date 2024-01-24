@isTest
private class TestQuoteServices {
	private static Account testCustAccount;
	private static Quote__c testQuote;

    static testMethod void getQuote() {
    	 setQuoteServiceData();
         System.assertEquals(QuoteServices.getQuote(testQuote.Id).Id,testQuote.Id,'Ids must match');
    }

    static void setQuoteServiceData(){
    	ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001', Active__c='Yes');
        insert testCustAccount;

        testQuote = new Quote__c(Account__c=testCustAccount.Id, Account__r=testCustAccount, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;
    }

    static testMethod void testPopulatePSRAndIRepFromAccount()
    {
    	final Integer NUM_ACCOUNTS = 10;

    	List<Primary_Sales_Rep__c> testPSRs = TestDataGeneration.createPSRs( NUM_ACCOUNTS, true );
    	List<Primary_Sales_Rep__c> testIReps = TestDataGeneration.createPSRs( NUM_ACCOUNTS, true );

    	List<Account> testAccountsWithPSRs = new List<Account>();
    	for( Integer index = 0; index < NUM_ACCOUNTS; index++ )
    	{
    		Account newAccount = TestDataGeneration.createAccount( 'Test Account' + index );
    		newAccount.Primary_Sales_Rep_Name__c = testPSRs[index].Id;
    		newAccount.iRep__c = testIReps[index].Id;
    		newAccount.iRep_Plan__c = 'Plan';
    		testAccountsWithPSRs.add( newAccount );
    	}
    	insert testAccountsWithPSRs;

		List<Quote__c> testQuotes = new List<Quote__c>();
		for( Account anAccount : testAccountsWithPSRs )
		{
			Quote__c newQuote = TestDataGeneration.createQuotes( 1, 'Test Quote', anAccount.Id, false )[0];
			newQuote.Account__c = anAccount.Id;
			testQuotes.add( newQuote );
		}

    	Test.startTest();

			List<Quote__c> quotesWithReps = QuoteServices.populatePSRAndIRepFromAccount( testQuotes );

    	Test.stopTest();

    	System.assertEquals( NUM_ACCOUNTS, quotesWithReps.size(), 'The same number of quotes passed in should have been returned' );

    	Map<Id, Account> testAccountsMap = new Map<Id, Account>( testAccountsWithPSRs );
    	for( Quote__c aQuote : quotesWithReps )
    	{
    		Account targetAccount = testAccountsMap.get( aQuote.Account__c );
			System.assertEquals( targetAccount.iRep__c, aQuote.iRep__c, 'The quotes irep lookup should be the same as its account' );
			System.assertEquals( targetAccount.Primary_Sales_Rep_Name__c, aQuote.Primary_Sales_Rep__c, 'The quotes psr lookup should be the same as its account' );
    	}
    }

    static testMethod void testFilterQuotesForPSRUpdate()
    {
    	final Integer NUM_ACCOUNTS = 10;

    	List<Account> testAccounts = TestDataGeneration.createAccounts( 'Test Account', NUM_ACCOUNTS + 1 );
    	insert testAccounts;

    	List<Quote__c> testQuotes = TestDataGeneration.createQuotes( NUM_ACCOUNTS * 2, 'Test Quote', testAccounts[NUM_ACCOUNTS].Id, true );
        
        List<Quote__c> oldQuotesTempList = testQuotes.deepClone();
        insert oldQuotesTempList;
    	Map<Id, Quote__c> oldQuotes = new Map<Id, Quote__c>( oldQuotesTempList );

    	Test.startTest();

			Set<Id> expectedChangedIds = new Set<Id>();
	    	for( Integer index = 0; index < NUM_ACCOUNTS; index++ )
	    	{
	    		testQuotes[index].Account__c = testAccounts[index].Id;
	    		expectedChangedIds.add( testQuotes[index].Id );
	    	}
    		List<Quote__c> returnedQuotes = QuoteServices.filterQuotesForPSRUpdate( oldQuotes, testQuotes );

    	Test.stopTest();

    	//System.assertEquals( NUM_ACCOUNTS, returnedQuotes.size(), 'Only as many quotes got updated with accounts as there are unique accounts' );
    	for( Quote__c aQuote : returnedQuotes )
    	{
    		System.assert( expectedChangedIds.contains( aQuote.Id ), 'Each quote must have actually been modified to be returned' );
    	}
    }
}
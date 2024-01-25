@isTest
private class TestUpdateQuoteSharesOnAcctChange {

	private static final String ACCESS_ERROR_MESSAGE = 'Changing account owner to current quote owner has thrown error.';
	private static final String TEST_FAIL = ' Test failed!';
	private static final String INSUFFICIENT_ACCESS_ERROR = 'INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY';

	private static final Integer NUMBER_OF_TEST_QUOTES = 25;

	private static User acctOwnerTestUser, otherAcctOwnerTestUser, quoteOwnerTestUser;
	private static Account someTestAccount;
	
	private static List<Quote__c> genTestQuotes( Integer howMany, Id ownerId, Id accountId  ) {
		
		List<Quote__c> newTestQuotes = new List<Quote__c>();
		
		for ( Integer i = 0; i < howMany; i++ )
			newTestQuotes.add( new Quote__c( OwnerId=ownerId, Account__c=accountId ) );
			
		return newTestQuotes;
		
	}
	
	private static String getPrefix( Id anId ) {
		
		if ( anId == null )
			return '';
		
		String idString = (String)anId;
		return idString.substring(0, 3);
		
	}

	private static testMethod void changeSingleAccountOwner() {
		
		Integer futureCalls = 0;
		
		testSetup();
					
		List<Quote__c> testQuotes = genTestQuotes( NUMBER_OF_TEST_QUOTES, quoteOwnerTestUser.Id, someTestAccount.Id );
		insert testQuotes;
		
		Set<Id> quoteIds = new Set<Id>();
		for ( Quote__c quoteForId : testQuotes )
			quoteIds.add( quoteForId.Id );
		
		List<Quote__Share> relatedQuoteShares = [ SELECT Id, UserOrGroupId, parentId FROM Quote__Share WHERE parentId IN :testQuotes ]; 

		String userPrefix = getPrefix( quoteOwnerTestUser.Id );
		
		for ( Quote__Share aQuoteShare : relatedQuoteShares ) {
			
			if ( getPrefix( aQuoteShare.UserOrGroupId ) == userPrefix && aQuoteShare.UserOrGroupId != quoteOwnerTestUser.Id )
				System.AssertEquals( acctOwnerTestUser.Id, aQuoteShare.UserOrGroupId );
			
		}
			
		Test.startTest();
		
			someTestAccount.OwnerId = otherAcctOwnerTestUser.Id;
			update someTestAccount;
			futureCalls = Limits.getFutureCalls();
		
       
		Test.stopTest();

		relatedQuoteShares = [ SELECT Id, UserOrGroupId FROM Quote__Share WHERE parentId IN :testQuotes ]; 

		for ( Quote__Share aQuoteShare : relatedQuoteShares ) {
			
			if ( getPrefix( aQuoteShare.UserOrGroupId ) == userPrefix && aQuoteShare.UserOrGroupId != quoteOwnerTestUser.Id )			
				System.AssertEquals( otherAcctOwnerTestUser.Id, aQuoteShare.UserOrGroupId );			
			
		}
		//System.assertEquals(1, futureCalls, 'We expect one future call to take place.');

	}

	private static testMethod void changeFromSameOwner() {
		
		Integer futureCalls = 0;
		
		testSetup();
		
		quoteOwnerTestUser = acctOwnerTestUser;
					
		List<Quote__c> testQuotes = genTestQuotes( NUMBER_OF_TEST_QUOTES, quoteOwnerTestUser.Id, someTestAccount.Id );
		insert testQuotes;
		
		Set<Id> quoteIds = new Set<Id>();
		for ( Quote__c quoteForId : testQuotes )
			quoteIds.add( quoteForId.Id );
		
		List<Quote__Share> relatedQuoteShares = [ SELECT Id, UserOrGroupId, parentId FROM Quote__Share WHERE parentId IN :testQuotes ]; 

		String userPrefix = getPrefix( quoteOwnerTestUser.Id );
		
		for ( Quote__Share aQuoteShare : relatedQuoteShares ) {
			
			if ( getPrefix( aQuoteShare.UserOrGroupId ) == userPrefix && aQuoteShare.UserOrGroupId != quoteOwnerTestUser.Id )
				System.AssertEquals( acctOwnerTestUser.Id, aQuoteShare.UserOrGroupId );
			
		}
			
		Test.startTest();
		
			someTestAccount.OwnerId = otherAcctOwnerTestUser.Id;
			update someTestAccount;
			futureCalls = Limits.getFutureCalls();
		Test.stopTest();

		relatedQuoteShares = [ SELECT Id, UserOrGroupId FROM Quote__Share WHERE parentId IN :testQuotes ]; 

		for ( Quote__Share aQuoteShare : relatedQuoteShares ) {
			
			if ( getPrefix( aQuoteShare.UserOrGroupId ) == userPrefix && aQuoteShare.UserOrGroupId != quoteOwnerTestUser.Id )			
				System.AssertEquals( otherAcctOwnerTestUser.Id, aQuoteShare.UserOrGroupId );			
			
		}
		//System.assertEquals(1, futureCalls, 'We expect one future call to take place.');

	}
	
	private static testMethod void insufficientAccessFromAddingCurrentOwner() {
		
		testSetup();
		
		List<Quote__c> testQuotes = genTestQuotes( NUMBER_OF_TEST_QUOTES, quoteOwnerTestUser.Id, someTestAccount.Id );
		insert testQuotes;
		
		Set<Id> quoteIds = new Set<Id>();
		for ( Quote__c quoteForId : testQuotes )
			quoteIds.add( quoteForId.Id );
		
		List<Quote__Share> relatedQuoteShares = [ SELECT Id, UserOrGroupId, parentId FROM Quote__Share WHERE parentId IN :testQuotes ]; 

		String userPrefix = getPrefix( quoteOwnerTestUser.Id );
		
		for ( Quote__Share aQuoteShare : relatedQuoteShares ) {
			
			if ( getPrefix( aQuoteShare.UserOrGroupId ) == userPrefix && aQuoteShare.UserOrGroupId != quoteOwnerTestUser.Id )
				System.AssertEquals( acctOwnerTestUser.Id, aQuoteShare.UserOrGroupId );
			
		}
			
		Test.startTest();
		
			someTestAccount.OwnerId = quoteOwnerTestUser.Id;
			
			try {
				
				update someTestAccount;
				
			} catch( System.Dmlexception dmlEx ) {
				
				if ( dmlEx.getMessage().contains( INSUFFICIENT_ACCESS_ERROR ) )
					System.assert( False, ACCESS_ERROR_MESSAGE + TEST_FAIL );
				
			}
				
		Test.stopTest();

	}
	
	///////////////////////////////////////////////////
	/////		Test Data Generation Functions
	///////////////////////////////////////////////////

	private static void testSetup() {
		
		Id profId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
		
		acctOwnerTestUser = genTestUser( 'acctOwner@bluewolf.com', 'acctOwne', profId );
		quoteOwnerTestUser = genTestUser( 'quoteOwner@bluewolf.com', 'quoteOwn', profId );
		otherAcctOwnerTestUser = genTestUser( 'otherAcctOwner@bluewolf.com', 'otherAcc', profId );
		
		insert new List<User>{ acctOwnerTestUser, quoteOwnerTestUser, otherAcctOwnerTestUser };
		
		Primary_Sales_Rep__c psr = TestingUtils.createPSRs( 1, 'tst', 'n', true )[0];
		
		someTestAccount = new Account( ownerId = acctOwnerTestUser.Id, Primary_Sales_Rep_Name__c = psr.Id, Name = 'test account', CurrencyIsoCode = 'USD'  );
		insert someTestAccount;
		
	}
	
    private static User genTestUser( String userName, String alias, Id profTypeId ) {
    	
    	User testUser = new User( 	FirstName=userName, 
									LastName=userName, 
									Email=userName,
									EmailEncodingKey='ISO-8859-1',
									CommunityNickname=userName,
									LocaleSidKey='en_US',
									TimeZoneSidKey='America/Puerto_Rico',
									LanguageLocaleKey='en_US',
									Alias=alias,
									Network_Id__c=alias,
									Username=userName,
									Country='USA'   );
									
		if ( profTypeId != null )
    		testUser.ProfileId = profTypeId;
    	
    	return testUser;
    	
    }

}
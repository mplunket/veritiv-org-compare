global class QuoteShareServices {

	@future
	public static void updateUsersOnShares( List<Id> accountIds, List<Id> oldAcctOwnerId, List<Id> newAcctOwnerId ) {
		
		Map<Id, Map<Id, Id>> acct2oldOwner2newOwner = groupOldAndNewOwnersByAcct( accountIds, oldAcctOwnerId, newAcctOwnerId );
		
		List<Quote__Share> sharesToInsert = new List<Quote__Share>();
		List<Quote__Share> sharesToDelete = new List<Quote__Share>();
	
		List<Quote__c> allRelevantQuotes = [ SELECT Name, Account__c, Account__r.OwnerId, Id, OwnerId , ( SELECT UserOrGroupId, Id FROM Shares WHERE UserOrGroupId IN :oldAcctOwnerId ) FROM Quote__c WHERE Account__c IN :accountIds ];
	
		for ( Quote__c quote2BUpdated : allRelevantQuotes ) {
			
			Map<Id, Id> sharesOldOwner2NewOwner = acct2oldOwner2newOwner.get( quote2BUpdated.Account__c );
	
			for ( Quote__Share quoteShare2BUpdated : quote2BUpdated.Shares ) {
				
				Id pssblOldUserId = quoteShare2BUpdated.UserOrGroupId;
				
				if ( sharesOldOwner2NewOwner.containsKey( pssblOldUserId ) && quote2BUpdated.OwnerId != sharesOldOwner2NewOwner.get( pssblOldUserId ) ) {
					
					Quote__Share oldQuoteShare = quoteShare2BUpdated;
					Quote__Share updatedQuoteShare = quoteShare2BUpdated.clone( false, true );				
					
					updatedQuoteShare.UserOrGroupId = sharesOldOwner2NewOwner.get( pssblOldUserId );
					updatedQuoteShare.AccessLevel = 'Edit';
					
					sharesToInsert.add( updatedQuoteShare );

					if ( oldQuoteShare.UserOrGroupId != quote2BUpdated.OwnerId )
						sharesToDelete.add( oldQuoteShare );
					
					
				}
					
			}
			
		}
		
		try {
			
			System.SavePoint preInsertDBPoint = Database.setSavepoint();
			
			insert sharesToInsert;
			
			try {
				
				delete sharesToDelete;
				
			} catch( System.Dmlexception dmlEx ) {
				
				System.debug( dmlEx );
				
			 	Database.rollback( preInsertDBPoint );
			 	
			 	throw( dmlEx );
				
			}
				
		} catch( System.Dmlexception dmlEx ) {
			
			System.debug( dmlEx );
			
			throw( dmlEx );
			
		}
			
	}
	
	private static Map<Id, Map<Id, Id>> groupOldAndNewOwnersByAcct ( List<Id> accountIds, List<Id> oldAcctOwnerId, List<Id> newAcctOwnerId ) {
		
		Map<Id, Map<Id, Id>> groupedOwners = new Map<Id, Map<Id, Id>>();
		
		for ( Integer i = 0; i < accountIds.size(); i++ ) {
			
			if ( !groupedOwners.containsKey( accountIds[i] ) )
				groupedOwners.put( accountIds[i], new Map<Id, Id>() );
				
			Map<Id, Id> oldOwner2NewOwner = groupedOwners.get( accountIds[i] );
			
			oldOwner2NewOwner.put( oldAcctOwnerId[i], newAcctOwnerId[i] );
			
		}
		
		return groupedOwners;
		
	}

}
trigger updateQuoteSharesOnAcctChange on Account (after update) {

    Boolean runMe = TriggerProcessor.runTrigger( trigger.NewMap );
    
    System.debug( '** before update, should I run ? ==> ' + !runMe );    
    if( !runMe )
        return;
    
    List<Account> acctsToUpdateQuoteSharesOn = new List<Account>();
    List<Id> oldUsers = new List<Id>();

    Map<Id, Map<Id, Id>> acctId2oldOwnerId2newOwnerId = new Map<Id, Map<Id, Id>>();

    // These three lists are created "in sync" - the indexes across all three correspond to one unit of information
    List<Id> accountIds = new List<Id>();
    List<Id> oldAcctOwnerId = new List<Id>();
    List<Id> newAcctOwnerId = new List<Id>();

    for ( Account pssblChangedAcct : trigger.new ) {

        Account olderVersionOfAcct = trigger.oldMap.get( pssblChangedAcct.Id );

        if ( pssblChangedAcct.OwnerId != olderVersionOfAcct.OwnerId ) {

            acctsToUpdateQuoteSharesOn.add( pssblChangedAcct );
            oldUsers.add( olderVersionOfAcct.OwnerId );

            if ( !acctId2oldOwnerId2newOwnerId.containsKey( pssblChangedAcct.Id ) )
                acctId2oldOwnerId2newOwnerId.put( pssblChangedAcct.Id, new Map<Id, Id>() );

            Map<Id, Id> oldOwner2newOwner = acctId2oldOwnerId2newOwnerId.get( pssblChangedAcct.Id );
            oldOwner2newOwner.put( olderVersionOfAcct.OwnerId , pssblChangedAcct.OwnerId );

            accountIds.add( pssblChangedAcct.Id );
            oldAcctOwnerId.add( olderVersionOfAcct.OwnerId );
            newAcctOwnerId.add( pssblChangedAcct.OwnerId );

        }

    }

    if( !accountIds.isEmpty() )
    {
        QuoteShareServices.updateUsersOnShares( accountIds, oldAcctOwnerId, newAcctOwnerId );
    }
    
    TriggerProcessor.firstTimeStateMap.putAll((Map<Id,Sobject>)trigger.newMap);

}
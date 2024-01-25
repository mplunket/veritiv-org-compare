trigger createquotesharedmember on Quote__c (after insert, after update) {
    Integer recordcount = 0; //stores the recordcount while looping throgh the trigger.new records
    Integer delrecordcount = 0; //stored the recordcount for # of records that needs to be deleted.
    
    map<Id, Quote__Share> existingquoteshares;
        
    //create a Id variable to loop through the store existing quoteaccount ids
    set<Id> quotesaccountid = new set<Id>();
    
    //create a Id varialble to loop through and store old account id
    set<Id> quotesoldaccountid = new set<Id>();
    
    //create a Id variable to loop through and store quote ids
    set<Id> quoteids = new set<Id>();
    
    //list to store quote share data
    list<Quote__Share> quoteshares = new list<Quote__Share>();
    
    //list to store quote share data for delete
    list<Quote__Share> delquoteshares = new list<Quote__Share>();
    
    //copy all the newly created id's to the string varialble
    for (Quote__c quote : trigger.new)
    {
        quotesaccountid.add(quote.account__c);
        quoteids.add(quote.id);
    }
    
    //loop through and get all the accounts related to the above opportunities
    map<Id, Account> existingaccounts = new map<Id, Account>([Select a.Owner.IsActive, a.OwnerId, a.Name, a.Id From Account a where a.id in :quotesaccountid]);

    //loop through and get all the accountshare related to the above quotes
    
    if(!Test.isRunningTest()){ 
   existingquoteshares  = new map<Id, Quote__Share>([select q.UserOrGroupId, q.RowCause, q.ParentId, q.Id, q.AccessLevel 
                                                            from Quote__Share q where q.RowCause != 'Owner' and q.ParentId in :quoteids]);  
     
    }
    map<Id, Account> oldaccounts = new map<Id, Account>();
    
    if (trigger.isUpdate)
    {
        //copy all the old account ids 
        for (Quote__c quote : trigger.old)
        {
            quotesoldaccountid.add(quote.account__c);
        }
        
        //get all the old accounts from trigger.old     
        oldaccounts = new map<Id, Account>([Select a.Owner.IsActive, a.OwnerId, a.Name, a.Id From Account a where a.id in :quotesoldaccountid]);
                        
    }                                                           

    for (Quote__c existingquote : trigger.new)
    {
        recordcount = recordcount + 1;
        Id accountownerid = null; //stores existinct account owner id if any exists
        Id oldaccountownerid = null; 
        Boolean quoteshareownerexist = false;
        Boolean accountownerisactive = false;
        
        //loop existing accounts and get the account owner id
        for(Id existingaccount : existingaccounts.KeySet())
        {
            if(trigger.isInsert && existingaccounts.get(existingaccount).Owner.IsActive == true)
            {
                accountownerid = existingaccounts.get(existingaccount).OwnerId;
                accountownerisactive = true;
            }
            if(trigger.isUpdate)
            {
                if(existingaccounts.get(existingaccount).Id == existingquote.account__c && existingaccounts.get(existingaccount).Owner.IsActive == true)
                {
                    accountownerid = existingaccounts.get(existingaccount).OwnerId;
                    accountownerisactive = true;
                }
                else if(trigger.oldMap.get(existingquote.id).OwnerId != existingquote.OwnerId && existingaccounts.get(existingaccount).Owner.IsActive == true)
                {
                    accountownerid = existingaccounts.get(existingaccount).OwnerId;
                    accountownerisactive = true;
                }
            }
                
            if(trigger.isUpdate)
            {
                delrecordcount = delrecordcount + 1;
                if(existingquote.account__c != trigger.oldMap.get(existingquote.id).account__c && existingquoteshares!=null && existingquoteshares.values()!=null)
                {           
                    for(Id existingquoteshare : existingquoteshares.KeySet())
                    {
                        for(Id oldaccount : oldaccounts.KeySet())
                        {
                            if(oldaccounts.get(oldaccount).Id == trigger.oldMap.get(existingquote.id).account__c )
                            {
                                oldaccountownerid = oldaccounts.get(oldaccount).OwnerId;
                            }
                        }

                        if(existingquoteshares.get(existingquoteshare).UserOrGroupId == oldaccountownerid && 
                            existingquoteshares.get(existingquoteshare).ParentId == existingquote.id)
                        {
                            delquoteshares.add(existingquoteshares.get(existingquoteshare));
                        }
                    }
                }
            }
        }
        
                
        //if account owner and quote owner are not the same then add the account owner to the shared member list
        if (accountownerid != null && accountownerid != existingquote.ownerid && accountownerisactive == true )
        {
            Quote__Share quoteshare = new Quote__Share(UserOrGroupId = accountownerid, ParentId = existingquote.id, AccessLevel = 'Edit');
            quoteshares.add(quoteshare);
        }
        
        if(quoteshares.size() > 20)
        {
            if(delquoteshares.size() > 0)
            {
                delete delquoteshares;
                delquoteshares.clear(); 
            }
            insert quoteshares;
            quoteshares.clear();
        } 
        else if (quoteshares.size() < 20)
        {
            if (trigger.new.size() == recordcount)
            {
                if(delquoteshares.size() > 0)
                {
                    delete delquoteshares;
                    delquoteshares.clear(); 
                }                               
                insert quoteshares;
                quoteshares.clear();
            }
        }
    }                                                       
}
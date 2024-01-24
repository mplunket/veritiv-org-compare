trigger createcasesharedmember on Case (after insert, after update) {
/*    
    if(trigger.isUpdate || (trigger.isInsert && Case.Proactive_Case_ID__c == null) )
    {   
        Integer recordcount = 0; //stores the recordcount while looping throgh the trigger.new records
            
        //create a Id variable to loop through the store existing caseaccount ids
        set<Id> casesaccountid = new set<Id>();
        
        //create a Id varialble to loop through and store old account id
        set<Id> casesoldaccountid = new set<Id>();
        
        //create a Id variable to loop through and store case ids
        set<Id> caseids = new set<Id>();
        
        //list to store case share data
        list<CaseShare> caseshares = new list<CaseShare>();
        
        //list to store case share data for delete
        list<CaseShare> delcaseshares = new list<CaseShare>();
        
        //copy all the newly created id's to the string varialble
        for (Case mycase : trigger.new)
        {
            if(mycase.accountid != null)
                casesaccountid.add(mycase.accountid);
            caseids.add(mycase.id);
        }
        
        //loop through and get all the accounts related to the above case account id
        Map<Id, Account> existingaccounts;
        if(!casesaccountid.isEmpty()) 
            existingaccounts = new map<Id, Account>([Select a.Owner.IsActive, a.OwnerId, a.Name, a.Id From Account a where a.id in :casesaccountid]);
        else
            existingaccounts = new Map<Id, Account>();
    
        //loop through and get all the accountshare related to the above cases  
        map<Id, CaseShare> existingcaseshares = new map<Id, CaseShare>([select c.UserOrGroupId, c.RowCause, c.CaseId, c.Id
                                                                from CaseShare c where c.RowCause  != 'Owner' and c.CaseId in :caseids]);
                                                                
        //Since case teams are now active
        //share records get created when a user is added to the team
        //we don't want to add a duplicate caseshare
        
        Set<Id> ownersWithTeamCaseShares = new Set<Id>();
        
        for(CaseShare cShareFound : existingcaseshares.values())
        {
            if(cShareFound.RowCause == 'Team')
            {
                ownersWithTeamCaseShares.add(cShareFound.UserOrGroupId);
            }
        }
        
        map<Id, Account> oldaccounts = new map<Id, Account>();
        
        //create a Id varialble to loop through and store NEW account id
        set<Id> casesNewAccountid = new set<Id>();
        map<Id, Account> newAccounts = new map<Id, Account>();
        
        if (trigger.isUpdate)
        {
            //copy all the old account ids 
            for (Case mycase : trigger.old)
            {
                if(mycase.accountid != null)
                    casesoldaccountid.add(mycase.accountid);
            }
            
            //get all the old accounts from trigger.old 
            if(!casesoldaccountid.isEmpty())    
                oldaccounts = new map<Id, Account>([Select a.Owner.IsActive, a.OwnerId, a.Name, a.Id From Account a where a.id in :casesoldaccountid]);
            
            //copy all the new account ids
            for (Case newMyCase : trigger.new)
            {
                casesNewAccountid.add(newMyCase.accountid);
            }
            
            //get all the old accounts from trigger.old     
            newAccounts = new map<Id, Account>([Select a.Owner.IsActive, a.OwnerId, a.Name, a.Id From Account a where a.id in :casesNewAccountid]);
        }                                                           
    
        for (Case existingcase  : trigger.new)
        {
            recordcount = recordcount + 1;
            Id accountownerid = null; //stores existinct account owner id if any exists
            Id oldaccountownerid = null; 
            Id newAccountOwnerId = null;
            Boolean caseshareownerexist = false;
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
                    if(existingaccounts.get(existingaccount).Id == existingcase.accountid && existingaccounts.get(existingaccount).Owner.IsActive == true)
                    {
                        accountownerid = existingaccounts.get(existingaccount).OwnerId;
                        accountownerisactive = true;
                    }
                    else if(trigger.oldMap.get(existingcase.id).OwnerId != existingcase.OwnerId && existingaccounts.get(existingaccount).Owner.IsActive == true)
                    {
                        accountownerid = existingaccounts.get(existingaccount).OwnerId;
                        accountownerisactive = true;
                    }
                }
                
                if(trigger.isUpdate)
                {
                    if(existingcase.accountid != trigger.oldMap.get(existingcase.id).accountid)
                    {
                        for(Id existingcaseshare : existingcaseshares.KeySet())
                        {
                            for(Id oldaccount : oldaccounts.KeySet())
                            {
                                if(oldaccounts.get(oldaccount).Id == trigger.oldMap.get(existingcase.id).accountid )
                                {
                                    oldaccountownerid = oldaccounts.get(oldaccount).OwnerId;
                                }
                            }
                            
                            for(Id newAccount : newAccounts.KeySet())
                            {
                                if(newAccounts.get(newAccount).Id == existingcase.accountid)
                                {
                                    newAccountOwnerId = newAccounts.get(newAccount).OwnerId;
                                }
                            }
                            
                            if(oldaccountownerid != newAccountOwnerId)
                            {
                                CaseShare existingcs = existingcaseshares.get(existingcaseshare);
                                if(existingcs.UserOrGroupId == oldaccountownerid && 
                                    existingcs.CaseId == existingcase.id &&
                                    (existingcs.RowCause != 'Team' && existingcs.RowCause != 'ImplicitChild'))
                                {
                                    //CaseShare delCaseShare = new CaseShare(Id = existingcaseshare);
                                    //delcaseshares.add(delCaseShare);
                                    delcaseshares.add(existingcaseshares.get(existingcaseshare));
                                    
                                }
                            }
                        }
                    }
                }
            }
                  
            //if account owner and case owner are not the same then add the account owner to the shared member list
            if (accountownerid != null && accountownerid != existingcase.ownerid && accountownerisactive == true )
            { 
                if(!ownersWithTeamCaseShares.contains(accountownerid))
                {
                    CaseShare caseshare = new CaseShare(UserOrGroupId = accountownerid, 
                                                    CaseId = existingcase.id, CaseAccessLevel  = 'Edit');
                    caseshares.add(caseshare);
                }   
            }
            
            if(caseshares.size() > 20)
            {
                if(delcaseshares.size() > 0)
                {
                    
                    delete delcaseshares;
                    delcaseshares.clear();  
                }
                
                insert caseshares;
                caseshares.clear();
            } 
            else if (caseshares.size() < 20)
            {
                if (trigger.new.size() == recordcount)
                {
                    if(delcaseshares.size() > 0)
                    {
                        
                        delete delcaseshares;
                        delcaseshares.clear();  
                    }                               
              
                    insert caseshares;
                    caseshares.clear();
                }
            }
        }
    }
  */  
}
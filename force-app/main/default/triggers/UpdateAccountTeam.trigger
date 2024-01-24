trigger UpdateAccountTeam on Ship_To__c (after insert, after update) {
    List<Ship_To__c> updatedShiptos = new List<Ship_To__c>();
    for(Ship_To__c shipTo : trigger.new)
    {
        if(Trigger.isUpdate && shipTo.Account_Owner__c != Trigger.oldMap.get(shipTo.Id).Account_Owner__c){
            updatedShiptos.add(shipto);
        }
    }
    
    if(Trigger.isInsert || !updatedShiptos.isEmpty()){
        Set<Id> inactiveUserIds = new Set<Id>();
        for(User u : [select Id from User where IsActive = false])
        {
            inactiveUserIds.add(u.Id);
        }
        
        Map<String, AccountTeamMember> k2atm = new Map<String, AccountTeamMember>();
        List<AccountTeamMember> atms = new List<AccountTeamMember>();
        Set<Id> billingAccounts = new Set<Id>();
        
        for(Ship_To__c shipTo : trigger.new)
        {
            if(shipTo.Account_Owner__c != null && !inactiveUserIds.contains(shipTo.Account_Owner__c))
            {
                billingAccounts.add(shipTo.Bill_To_Account__c);
            }
        }
        
        for(AccountTeamMember atm : [select UserId, AccountId from AccountTeamMember where AccountId in :billingAccounts])
        {
            k2atm.put(atm.UserId + '' + atm.AccountId, atm);
        }
        
        for(Ship_To__c shipTo : trigger.new)
        {
            if(Trigger.isInsert || shipTo.Account_Owner__c != Trigger.oldMap.get(shipTo.Id).Account_Owner__c){
                
                if(shipTo.Account_Owner__c != null && !inactiveUserIds.contains(shipTo.Account_Owner__c))
                {
                    if(!k2atm.containsKey(shipTo.Account_Owner__c + '' + shipTo.Bill_To_Account__c))
                    {
                        AccountTeamMember atm = new AccountTeamMember(AccountId=shipTo.Bill_To_Account__c,
                                                                      UserId=shipTo.Account_Owner__c,
                                                                      AccountAccessLevel = 'Edit',
                                                                      TeamMemberRole='Ship To - Sales Rep');
                        
                        atms.add(atm);
                    }
                }
            }
        }
        
        insert atms;
        
    }
}
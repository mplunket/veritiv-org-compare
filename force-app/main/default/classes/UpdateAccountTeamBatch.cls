public class UpdateAccountTeamBatch implements Database.Batchable<SObject> {
    
    public static void run(Set<Id> shipToIds) {
    List<Ship_To__c> insertedShipTo = [
        SELECT Id, Account_Owner__c, Bill_To_Account__c,Active__c
        FROM Ship_To__c
        WHERE Account_Owner__c != null
        AND Id IN :shipToIds
    ];
    System.debug('****insertedShipTo****' + insertedShipTo);   
    executeHelper(insertedShipTo);
}
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Account_Owner__c, Bill_To_Account__c,Active__c
            FROM Ship_To__c
            WHERE (Account_Owner__c != null)
        ]);
        
    }
    
    public void execute(Database.BatchableContext bc, List<Ship_To__c> insertedShipTo) {
        executeHelper( insertedShipTo );
    }
   
    public static void executeHelper( List<Ship_To__c> insertedShipTo ){
        Set<Id> billingAccounts = new Set<Id>();
        Map<String, AccountTeamMember> k2atm = new Map<String, AccountTeamMember>();
        Set<Id> inactiveUserIds = new Set<Id>();
        List<AccountTeamMember> atms = new List<AccountTeamMember>();
        List<AccountTeamMember> atmsToDel = new List<AccountTeamMember>();
        Set<Id> inactiveShipToIds = new Set<Id>();
        List<AccountTeamMember> oldatms = new List<AccountTeamMember>();
        set<Id> insertedShipToOwnerIds = new set<Id>();
        
        
        
        
        for(User u : [select Id from User where IsActive = false]){        
            inactiveUserIds.add(u.Id);
        }
        
        System.debug('****inactiveUserIds****' + inactiveUserIds);  
        
        for(Ship_To__c shipTo : insertedShipTo)
        {
            if(shipTo.Account_Owner__c != null && !inactiveUserIds.contains(shipTo.Account_Owner__c)){
                billingAccounts.add(shipTo.Bill_To_Account__c);
            }      
        }
        System.debug('****billingAccounts****' + billingAccounts);  
        
        for(AccountTeamMember atm : [select UserId, AccountId 
                                     from AccountTeamMember 
                                     where AccountId in :billingAccounts])
        {
            k2atm.put(atm.UserId + '' + atm.AccountId, atm);
            oldatms.add(atm);
            
            
            
            
        }
        System.debug('Old atms' +oldatms);
        System.debug('****k2atm****' + k2atm);	
      
         
        
        for(Ship_To__c shipTo : insertedShipTo)
        {      
            if(shipTo.Account_Owner__c != null && !inactiveUserIds.contains(shipTo.Account_Owner__c) && shipTo.Active__c != 'No' )
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
        System.debug('****atms****' + insertedShipTo);  
        if(!atms.isEmpty()){
             Insert atms;
        }
        
        for(Ship_To__c shipTo : insertedShipTo){
            insertedShipToOwnerIds.add(shipTo.Account_Owner__c);
            
        }
          //Delete  Account team members
           
            for(AccountTeamMember atm: oldatms){
                if(!insertedShipToOwnerIds.contains(atm.UserId)){
                    inactiveShipToIds.add(atm.UserId);
            }
            }
        for(Ship_To__c shipTo : insertedShipTo)
        {    
             if(shipTo.Account_Owner__c != null && shipTo.Active__c == 'No')
            {
                      System.debug('Entered Delete Block 2');
                       inactiveShipToIds.add(shipTo.Account_Owner__c);             
		
            }
               
              if(shipTo.Account_Owner__c != null && shipTo.Active__c == 'Yes')
            {
                System.debug('Entered Delete Block 3');
                if(inactiveShipToIds.contains(shipTo.Account_Owner__c)){
                    inactiveShipToIds.remove(shipTo.Account_Owner__c);
                   
                }
               
           
             /*if (k2atm.containsKey(shipTo.Account_Owner__c + '' + shipTo.Bill_To_Account__c)) {
                    atmsToDel.add(k2atm.get(shipTo.Account_Owner__c + '' + shipTo.Bill_To_Account__c));
                }*/
        }
        
        }
         system.debug(inactiveShipToIds);
          system.debug('billingAccounts'+ billingAccounts);
         atmsToDel =  [Select Id from AccountTeamMember Where AccountId IN: billingAccounts AND UserId IN: inactiveShipToIds];
        
         System.debug(atmsToDel);
         if(!atmsToDel.isEmpty()){
         delete atmsToDel;
         }
    }
    
    public void finish(Database.BatchableContext bc) {
        //After logic
    }
}
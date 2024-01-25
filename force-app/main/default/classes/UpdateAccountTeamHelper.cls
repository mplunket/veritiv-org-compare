public class UpdateAccountTeamHelper{
    
    public static List<Ship_To__c> newShipTos = new List<Ship_To__c>();
    public static List<Ship_To__c> oldShipTos = new List<Ship_To__c>();
    public static Map<Id, Ship_To__c> newMapShipTos = new Map<Id, Ship_To__c>();
    public static Map<Id, Ship_To__c> oldMapShipTos = new Map<Id, Ship_To__c>();
    
    public static Boolean runTrigger = true;
    
    public static void createAccountTeamMember(){
        system.debug('Inserted ShipTos: ' + newShipTos);
        List<Ship_To__c> updatedShiptos = new List<Ship_To__c>();
        for(Ship_To__c shipTo : newShipTos){
            if(shipTo.Account_Owner__c != Null && 
               (Trigger.isInsert 
                   || (Trigger.isUpdate && shipTo.Account_Owner__c != oldMapShipTos.get(shipTo.Id).Account_Owner__c))){
                       
                updatedShiptos.add(shipto);
            }
        }
        
        if(!updatedShiptos.isEmpty()){
            System.debug('Entered - Updated ShipTos are Not Empty');
            Set<Id> inactiveUserIds = new Set<Id>();
            for(User u : [SELECT Id FROM User WHERE IsActive = false]){
                inactiveUserIds.add(u.Id);
            }
            
            Set<Id> billingAccounts = new Set<Id>();
            for(Ship_To__c shipTo : newShipTos){
                if(!inactiveUserIds.contains(shipTo.Account_Owner__c)){
                    billingAccounts.add(shipTo.Bill_To_Account__c);
                }
            }
            
            Map<String, AccountTeamMember> k2atm = new Map<String, AccountTeamMember>();
            for(AccountTeamMember atm : [SELECT UserId, AccountId 
                                         FROM AccountTeamMember
                                         WHERE AccountId IN: billingAccounts]){
                                             
                k2atm.put(atm.UserId + '' + atm.AccountId, atm);
            }
            
            List<AccountTeamMember> atms = new List<AccountTeamMember>();
            for(Ship_To__c shipTo : newShipTos){
                if(!k2atm.containsKey(shipTo.Account_Owner__c + '' + shipTo.Bill_To_Account__c)){
                        
                    AccountTeamMember atm = new AccountTeamMember(AccountId=shipTo.Bill_To_Account__c,
                                                                  UserId=shipTo.Account_Owner__c,
                                                                  AccountAccessLevel = 'Edit',
                                                                  TeamMemberRole='Ship To - Sales Rep');
                    
                    atms.add(atm);
                }
            }
            system.debug('ATMs : ' + atms);
            insert atms;
        }
        system.debug('Outside the Block of Code');
    }
    
    //Updated for Delete  on 08/21/2023 - Thunder
    public static void removeAccountTeamMembersCheckDelete(){
    	system.debug('***** Entered Delete Block of Code');
        
        
        Map<String, Ship_To__c> mapUniqueKeyToShipTo = new Map<String, Ship_To__c>();
        Set<Id> applicableAccountIds = new Set<Id>();
          for(Ship_To__c shipTo : oldShipTos){
       		mapUniqueKeyToShipTo.put(shipTo.Account_Owner__c + '' + shipTo.Bill_To_Account__c, shipTo);
            applicableAccountIds.add(shipTo.Bill_To_Account__c); 
        }
       
        List<AccountTeamMember> atmsToDelete = new List<AccountTeamMember>();
        for(AccountTeamMember atm : [SELECT UserId, AccountId 
                                     FROM AccountTeamMember
                                     WHERE AccountId IN: applicableAccountIds]){
        	if(mapUniqueKeyToShipTo.containsKey( atm.UserId + '' + atm.AccountId )  ){  
                atmsToDelete.add(atm);    
            }         
        }

        if(!atmsToDelete.isEmpty()){
            delete atmsToDelete;
        }     
    }
    
     public static void removeAccountTeamMembersCheckUpdate(){
    	system.debug('***** Entered Update Block of Code');
        
        
        Map<String, Ship_To__c> mapUniqueKeyToShipTo = new Map<String, Ship_To__c>();
        Set<Id> applicableAccountIds = new Set<Id>();
        Set<Id> shipToInactive = new Set<Id>(); 
       // List<String> shipToBillToAccounts = new List<String>();
        for(Ship_To__c shipTo : oldShipTos){
       		mapUniqueKeyToShipTo.put(shipTo.Account_Owner__c + '' + shipTo.Bill_To_Account__c, shipTo);
            applicableAccountIds.add(shipTo.Bill_To_Account__c);
            //shipToBillToAccounts.add(shipTo.Account_Owner__c);
            if (newMapShipTos.get(shipTo.Id).Active__c == 'No'){
				shipToInactive.add(shipTo.Id);                
            }
        }
        List<Id> shipToPreviousAccountOwner = new List<Id>();
        for(Id shipToId : oldMapShipTos.keySet()){
            if(oldMapShipTos.get(shipToId).Account_Owner__c != null){
            shipToPreviousAccountOwner.add(oldMapShipTos.get(shipToId).Account_Owner__c);
            }
        }
        System.debug('shipToPreviousAccountOwner'+shipToPreviousAccountOwner);

        list<Ship_To__c>  shipToActiveRecords = [Select Id,Account_Owner__c,Bill_To_Account__c,Active__c From Ship_To__c
                                                 Where Bill_To_Account__c IN : applicableAccountIds AND Active__c = 'Yes'
                                                 AND Account_Owner__c IN : shipToPreviousAccountOwner]; 
        System.debug('shipToActiveRecords'+shipToActiveRecords);
        List<AccountTeamMember> atmsToDelete = new List<AccountTeamMember>();
        for(AccountTeamMember atm : [SELECT UserId, AccountId 
                                     FROM AccountTeamMember
                                     WHERE AccountId IN: applicableAccountIds]){
        	 
            If(shipToInactive.size() > 0 && shipToActiveRecords.size() ==0){
                atmsToDelete.add(atm);              
            }  
        }

        if(!atmsToDelete.isEmpty()){
            delete atmsToDelete;
        }     
    }
}
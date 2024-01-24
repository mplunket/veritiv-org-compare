public without sharing class LegalContractServices {

    public static void updateRelatedLegalConShares(Map<Id, Account> oldAccs, Map<Id, Account> newAccs){
        Boolean boolAccnt = false;
        for(Id accId : newAccs.keyset())
        {
            if(accId == system.label.DE_Print_Orphan_Account || accId == system.label.Field_Sourcing_Orphan_Account){
                boolAccnt = true;
                break;
            }
            
        }
        
        if(boolAccnt==false)
        {
            
            Map<Account, List<Legal_Contract__c>> accountToLC = getFilteredLC(oldAccs, newAccs);
            
            if(accountToLC.isEmpty())
                return;
            
            deleteExistingLCShares(oldAccs, accountToLC );
            
            insertNewLCShares(newAccs, accountToLC );
        }
    }
    
    private static Map<Account, List<Legal_Contract__c>> getFilteredLC(Map<Id, Account> oldMap, Map<Id, Account> newMap)
    {
        Map<Account, List<Legal_Contract__c>> filteredMap = new Map<Account, List<Legal_Contract__c>>();
        if(oldMap != NULL && newMap != NULL)
        {
            Map<Id,Account> requeriedAccountsMap = new Map<Id, Account>([SELECT Id, OwnerId, Owner.IsActive, (SELECT Id, OwnerId, Owner.IsActive, CreatedById FROM Legal_Contracts__r) FROM Account WHERE Id IN :newMap.keySet() AND Owner.IsActive = TRUE]);
            
            if(requeriedAccountsMap.values().isEmpty())
            {
                return filteredMap;
            }
            
            for(Id accId : newMap.keySet())
            {
                if(oldMap.get(accId).OwnerId != newMap.get(accId).OwnerId && requeriedAccountsMap.containsKey(accId))
                {
                    if(requeriedAccountsMap.get(accId).WorkOrders != NULL && requeriedAccountsMap.get(accId).Legal_Contracts__r.size() > 0)
                    {
                        filteredMap.put(requeriedAccountsMap.get(accId), requeriedAccountsMap.get(accId).Legal_Contracts__r); 
                    }
                }
            }
        }
        
        return filteredMap;
    }
    
    private static void deleteExistingLCShares(Map<Id, Account> oldMap, Map<Account, List<Legal_Contract__c>> accToLC)
    {
        system.debug('Entered Legal contract sharing to delete ');
        system.debug('oldmap: '+oldmap);
        Set<Id> lcIds = new Set<Id>();
        Set<Id> ownerIds = Pluck.Ids('OwnerId', oldMap.values()); 
        //Set<Id> accountIds = Pluck.Ids(accIdToWorkOrders);
        system.debug('ownerIds: '+ownerIds);
        system.debug('ownerIds: '+accToLC);
        for(Account acc : accToLC.keySet())
        { 
            for(Legal_Contract__c lc : accToLC.get(acc))
            { 
                if(acc.Owner.isActive && lc.OwnerId != oldMap.get(acc.Id).OwnerId)
                {
                    lcIds.add( lc.Id );
                }
            }
        }
        
        List<Legal_Contract__Share> currentShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Legal_Contract__Share WHERE ParentId IN :lcIds AND UserOrGroupId IN :ownerIds ];
        system.debug('Legal contract sharing to delete '+ currentShares);
        try
        {
            delete new List<Legal_Contract__Share>(currentShares);
        }
        catch(DmlException ex)
        {
            system.debug('Legal contract sharing deletion exception'+ ex.getMessage());
            for(Integer i = 0; i < ex.getNumDML(); i++)
            {
                oldMap.get(ex.getDmlId( i )).addError(ex.getDmlMessage(i));
            }
        }
    }
    
    
    private static void insertNewLCShares(Map<Id, Account> newMap, Map<Account, List<Legal_Contract__c>> accToLC)
    {
        Set<Legal_Contract__Share> lcShares = new Set<Legal_Contract__Share>(); 
        //Set<Id> accountIds = Plucks.Ids(accToWorkOrders.keySet());
        System.debug('* AccIdsToLC Map: ' + accToLC);
        
        for(Account acc : accToLC.keySet())
        {
            for(Legal_Contract__c lc : accToLC.get(acc))
            {
                
                if(acc.Owner.isActive && newMap.get(acc.Id).OwnerId != lc.OwnerId) //newMap.get(acc.Id).Owner.isActive && 
                {
                    lcShares.add( new Legal_Contract__Share(AccessLevel = 'Edit', ParentId = lc.Id, UserOrGroupId = newMap.get(acc.Id).OwnerId) );
                }
            }
        }
        
        try
        {
            insert new List<Legal_Contract__Share>(lcShares);
        }
        catch(Exception ex)
        {
            System.debug('Ex: ' + ex);
            
            
        }
    }
}
public without sharing class ContactRollupOnAccount {
    
    // Contact Functionality
    public static void updateContactCounts(List<Account> relatedAccounts)
    {
        try
        {
            for(Account currAccount : relatedAccounts)
            {
                currAccount.Number_of_Contacts__c = currAccount.Contacts.size();
                
                List<Contact> currAccountChildContacts = currAccount.Contacts;
                Integer activeContacts = 0;
                for(Contact currCon : currAccountChildContacts)
                {
                    if( !currCon.Inactive__c )
                    {
                        activeContacts++;
                    }
                }
                currAccount.Number_of_Active_Contacts__c = activeContacts;
            }
            
            update relatedAccounts;
        }
        catch(DMLException dEx)
        {
            System.debug('Something went wrong in summing and updating the accounts from the contacts. Error: ' + dEx.getMessage());
        }
    }
    
    public static void rollupContactsOnAccounts(List<Contact> contactsInTrigger) 
    {
        List<Account> relatedAccounts = getRelatedAccounts(contactsInTrigger);
        if( !relatedAccounts.isEmpty() )
        {
            updateContactCounts(relatedAccounts);
        }
        
    }
    
    public static List<Account> getRelatedAccounts(List<Contact> contactsInTrigger)
    {
        List<Account> accountsToUpdate = new List<Account>();
        
        Set<Id> relatedAccountIds = Pluck.Ids('AccountId', contactsInTrigger);
        
        if( !relatedAccountIds.isEmpty() )
        {
            accountsToUpdate = [SELECT Id, (SELECT Id, Inactive__c FROM Contacts) FROM Account WHERE Id IN :relatedAccountIds];
        }
        
        return accountsToUpdate;
    }
    
    // Account Functionality
    public static void UpdateTransitionedContacts(List<Account> deletedAccounts)
    {
        Set<Id> masterAccountIds = Pluck.Ids('MasterRecordId', deletedAccounts);
        updateMasterAccounts_Future(masterAccountIds);
    }
    
    @future @TestVisible
    private static void updateMasterAccounts_Future(Set<Id> masterIds)
    {
        List<Account> masterAccounts = getMergedMasterAccounts(masterIds);
        
        updateContactCounts( masterAccounts );
    }
    
    @TestVisible
    private static List<Account> getMergedMasterAccounts(Set<Id> masterAccountIds)
    {
        List<Account> mergedMasterAccounts = new List<Account>();
        
        if( !masterAccountIds.isEmpty() )
        {
            mergedMasterAccounts = [SELECT Id, (SELECT Id, Inactive__c FROM Contacts) FROM Account WHERE Id IN :masterAccountIds];
        }
        
        return mergedMasterAccounts;
    }
    
}
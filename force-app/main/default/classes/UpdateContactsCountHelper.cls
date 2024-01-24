public without sharing class UpdateContactsCountHelper {

    public static void updateAccountFields(Set<Id> accountIdsToUpdate) {

        Map<Id, Integer> accountContactsCountMap = new Map<Id, Integer>();
        Map<Id, Integer> accountActiveContactsCountMap = new Map<Id, Integer>();

        for (AggregateResult aggResult : [
            SELECT AccountId, COUNT(Id) contactsCount
            FROM Contact
            WHERE AccountId IN :accountIdsToUpdate
            GROUP BY AccountId
        ]) {
            accountContactsCountMap.put((Id)aggResult.get('AccountId'), (Integer)aggResult.get('contactsCount'));
        }

        for (AggregateResult aggResult : [
            SELECT AccountId, COUNT(Id) activeContactsCount
            FROM Contact
            WHERE AccountId IN :accountIdsToUpdate AND Inactive__c = false
            GROUP BY AccountId
        ]) {
            accountActiveContactsCountMap.put((Id)aggResult.get('AccountId'), (Integer)aggResult.get('activeContactsCount'));
        }

        List<Account> accountsToUpdate = new List<Account>();
        
        System.debug('Counts helper');

        for (Id accountId : accountIdsToUpdate) {
            Account acc = new Account(Id = accountId);
            Integer contactsCount = accountContactsCountMap.get(accountId) != null
                ? accountContactsCountMap.get(accountId)
                : 0; // Set count to 0 if null
            Integer activeContactsCount = accountActiveContactsCountMap.get(accountId) != null
                ? accountActiveContactsCountMap.get(accountId)
                : 0; // Set count to 0 if null

            acc.Number_of_Contacts__c = contactsCount;
            acc.Number_of_Active_Contacts__c = activeContactsCount;
            accountsToUpdate.add(acc);
        }
        
        if(!accountsToUpdate.isEmpty()) {
            try {
                update accountsToUpdate; 
            } catch(DMLException e) {
                System.debug('Something went wrong in summing and updating the accounts from the contacts. Error: ' + e.getMessage());
            }
        }
    }
}
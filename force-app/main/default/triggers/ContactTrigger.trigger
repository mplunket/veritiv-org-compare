trigger ContactTrigger on Contact (after insert, after update, after delete, after undelete, before insert, before update) {
    if(Trigger.isAfter)
    {
        Set<Id> accountIdsToUpdate = new Set<Id>();
        
        if(Trigger.isInsert)
        {
            ContactServices.populateMatchingCasesWithContacts(Trigger.newMap);
            //ContactRollupOnAccount.rollupContactsOnAccounts(Trigger.new);

            for (Contact contact : Trigger.new) {
                if (contact.AccountId != null) {
                    // Calculate Contact #'s on Account when new contacts are created
                    accountIdsToUpdate.add(contact.AccountId);
                }
            }
        }
        else if(Trigger.isUpdate)
        {
            //List<Contact> allContactsInTrigger = new List<Contact>(Trigger.new);
            //allContactsInTrigger.addAll(Trigger.old); 
            //ContactRollupOnAccount.rollupContactsOnAccounts(allContactsInTrigger);
            
            for (Contact contact : Trigger.new) {
                // Add AccountId to list for update if Inactive__c is changed
                // or if AccountId is changed
                if (contact.AccountId != null && ((Trigger.oldMap != null && Trigger.oldMap.get(contact.Id).Inactive__c != contact.Inactive__c) ||
                   (Trigger.oldMap != null && Trigger.oldMap.get(contact.Id).AccountId != contact.AccountId))) {
                    accountIdsToUpdate.add(contact.AccountId);
                }
                // Add previous AccountId to list for update if AccountId is changed
                if (Trigger.oldMap != null && Trigger.oldMap.get(contact.Id).AccountId != null && Trigger.oldMap.get(contact.Id).AccountId != contact.AccountId) {
                    accountIdsToUpdate.add(Trigger.oldMap.get(contact.Id).AccountId);
                }
            }
        }
        else if(Trigger.isDelete)
        {
            //ContactRollupOnAccount.rollupContactsOnAccounts(Trigger.old);

            for (Contact contact : Trigger.old) {
                if (contact.AccountId != null) {
                    // Update Contact #'s on Account when Contact deleted
                    accountIdsToUpdate.add(contact.AccountId);
                }
            }
        }
        else if(Trigger.isUndelete)
        {
            //ContactRollupOnAccount.rollupContactsOnAccounts(Trigger.new);
            
            for (Contact contact : Trigger.new) {
                if (contact.AccountId != null) {
                    // Update Contact #'s on Account when Contact undeleted
                    accountIdsToUpdate.add(contact.AccountId);
                }
            }
        }
        
        if(!accountIdsToUpdate.isEmpty()) {
            UpdateContactsCountHelper.updateAccountFields(accountIdsToUpdate);
        }
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ContactServices.assignAccountOwner(trigger.new);
            //Converting PB logic to Trigger to add Address to Contact from Acccount  if the State is NULL in Contact 6/17/2021
         //  ContactServices.updateMaillingAddress(trigger.new);
            //End
        }
        if(trigger.isUpdate){
            ContactServices.PSRUpdateOnOwnerChange(trigger.oldmap, trigger.newmap);
        }
    }
}
trigger CredAppTrigger on Credit_Application__c (before insert, after insert, after update, before update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CredAppTriggerHandler.afterInsert(Trigger.new);
        }
        
        if(Trigger.isUpdate){
            CredAppTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
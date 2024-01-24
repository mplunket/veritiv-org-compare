trigger EmailMessageTrigger on EmailMessage (before insert, after insert, before delete) {
     
    if(Trigger.isBefore){
        //Dont allow user to delete email message
        if(trigger.isDelete){
            EmailMessageTriggerHandler.handleBeforeDelete(trigger.old);
        }
        //Endof updated code
        if(Trigger.isInsert){
            EmailMessageTriggerHandler.handleBeforeInsert(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }
    else if(Trigger.isAfter){
        if(Trigger.isInsert){
            EmailMessageTriggerHandler.handleAfterInsert(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }

}
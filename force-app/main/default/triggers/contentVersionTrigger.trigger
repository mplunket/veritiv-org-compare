trigger contentVersionTrigger on ContentVersion (after insert) {
    
    System.debug('ContentVersion trigger fired');
    if(Trigger.isInsert){
        if(Trigger.isafter){
            contentVersionTriggerHandler.processFiles(Trigger.new);
            system.debug('isafter insert');
        }
    }
}
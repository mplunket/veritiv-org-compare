trigger workOrderLineTrigger on WorkOrderLineItem (before insert, before update) {
    
    if (trigger.isBefore){
    
        if(trigger.isInsert){
            workOrderLineTriggerHandler.beforeInsert(trigger.new); 
        }
        if(trigger.isUpdate){
            workOrderLineTriggerHandler.beforeUpdate(trigger.newmap,trigger.oldmap);
        }
    
    }

}
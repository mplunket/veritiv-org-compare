trigger WorkOrder on WorkOrder (before delete, after insert, before Insert, before update) {
    
    if(Trigger.isBefore)
    {
        if(Trigger.isDelete)
        {
            WorkOrderServices.checkWorkOrderDelete(Trigger.old);
        }
        
        if(Trigger.isInsert){
            WorkOrderServices.routeToQueue(trigger.new);
        }
        
        if(Trigger.isUpdate){
            WorkOrderServices.updateStatusWhenOwnerChangedToQueue(trigger.new, trigger.oldMap);
        }
        
    }
    if(Trigger.isAfter)
    {
        
    }
    
}
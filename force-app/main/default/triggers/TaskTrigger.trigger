trigger TaskTrigger on Task (before insert, before update, after insert, after update, before delete, after delete) {

    if(Trigger.isBefore) {

        if(Trigger.isUpdate || Trigger.isInsert) {

            List<Task> tasksToProcess = new List<Task>();

            for(Task currentTask : Trigger.New) {
                if(currentTask.Type == 'Via IS Chat' && currentTask.Related_Chat__c == null)
                    tasksToProcess.add(currentTask);
            }
            
            TaskTriggerUtils.processInstantServiceTasks(tasksToProcess);
        }

    }
    
    if(trigger.isDelete && trigger.isAfter){
        
        
        System.debug('inside task trigger');
            List<Id> ldsIds = new List<Id>();
            for(task tsk : trigger.old){
                if(tsk.whoId != null && tsk.whoId.getSObjectType().getDescribe().getName() == 'Lead'){
               // if(tsk.whoId.getSObjectType().getDescribe().getName() == 'Lead'){
                    ldsIds.add(tsk.whoId);
                }
            }
            System.debug('ldsIds'+ldsIds);
            if(ldsIds.size() > 0){
                Map<id,decimal>leadIdsVsCount = new Map<Id,decimal>();
                List<task> tsks = [Select id ,whoId, status from task where status != 'Completed' and whoId in: ldsIds];
                System.debug('tskds'+tsks);
                if(tsks.size() > 0){
                for(task tk: tsks){ 
                    if(leadIdsVsCount.keyset().contains(tk.whoId)){
                        decimal tmp = leadIdsVsCount.get(tk.whoId) + 1;
                        leadIdsVsCount.put(tk.whoId,tmp);
                    }else{
                        leadIdsVsCount.put(tk.whoId,1);
                    }
                }
                }else{
                     list<Lead> ldsToUpdate = new List<Lead>();
                    for(lead l: [Select id,Open_Activities_Count__c from lead where id in: ldsIds]){
                        l.open_activities_count__c = 0;
                        ldsToUpdate.add(l);
                        
                    }
                    if(ldsToUpdate.size() > 0){
                    update ldsToUpdate;
                }
                }
                
                System.debug('leadIdsVsCount'+leadIdsVsCount);
                if(leadIdsVsCount != null){
                    list<Lead> ldsToUpdate = new List<Lead>();
                    for(lead ld: [Select id,Open_Activities_Count__c from lead where id in: leadIdsVsCount.keyset()]){
                        if(leadIdsVsCount.keyset().contains(ld.id)){
                            ld.open_activities_count__c = leadIdsVsCount.get(ld.id);
                            ldsToUpdate.add(ld);
                        }
                    }
                    
                    System.debug('ldsToUpdate'+ldsToUpdate);
                    if(ldsToUpdate.size() > 0){
                        update ldsToUpdate;
                    }
                }
                
            }
            
        }
    
     if(Trigger.isAfter) {

        if(Trigger.isInsert) {
            
            TaskTriggerUtils.reparentAttachments(Trigger.New);
        }
         
        //Logic for Open_Activities_Count__c field on lead
        if((Trigger.isInsert || Trigger.isUpdate) && trigger.isAfter){
            System.debug('inside task trigger');
            List<Id> ldsIds = new List<Id>();
            for(task tsk : trigger.new){
                if( tsk.whoId != null && tsk.whoId.getSObjectType().getDescribe().getName() == 'Lead'){
                //if( tsk.whoId.getSObjectType().getDescribe().getName() == 'Lead'){
                    ldsIds.add(tsk.whoId);
                }
            }
            System.debug('ldsIds'+ldsIds);
            if(ldsIds.size() > 0){
                Map<id,decimal>leadIdsVsCount = new Map<Id,decimal>();
                List<task> tsks = [Select id ,whoId, status from task where status != 'Completed' and whoId in: ldsIds];
                System.debug('tskds'+tsks);
                if(tsks.size() > 0){
                for(task tk: tsks){ 
                    if(leadIdsVsCount.keyset().contains(tk.whoId)){
                        decimal tmp = leadIdsVsCount.get(tk.whoId) + 1;
                        leadIdsVsCount.put(tk.whoId,tmp);
                    }else{
                        leadIdsVsCount.put(tk.whoId,1);
                    }
                }
                }else{
                     list<Lead> ldsToUpdate = new List<Lead>();
                    for(lead l: [Select id,Open_Activities_Count__c from lead where id in: ldsIds]){
                        l.open_activities_count__c = 0;
                        ldsToUpdate.add(l);
                        
                    }
                    if(ldsToUpdate.size() > 0){
                    update ldsToUpdate;
                }
                }
                
                System.debug('leadIdsVsCount'+leadIdsVsCount);
                if(leadIdsVsCount != null){
                    list<Lead> ldsToUpdate = new List<Lead>();
                    for(lead ld: [Select id,Open_Activities_Count__c from lead where id in: leadIdsVsCount.keyset()]){
                        if(leadIdsVsCount.keyset().contains(ld.id)){
                            ld.open_activities_count__c = leadIdsVsCount.get(ld.id);
                            ldsToUpdate.add(ld);
                        }
                    }
                    
                    System.debug('ldsToUpdate'+ldsToUpdate);
                    if(ldsToUpdate.size() > 0){
                        update ldsToUpdate;
                    }
                }
                
            }
            
        }

    }


}
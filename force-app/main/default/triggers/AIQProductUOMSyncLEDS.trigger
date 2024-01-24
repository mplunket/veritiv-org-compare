trigger AIQProductUOMSyncLEDS on zpl__ProductUOM__c (before insert, before update, after insert, after update, after delete) {
    
    if(Trigger.isBefore){
        for(zpl__ProductUOM__c puom : Trigger.new){
            if(!puom.Allow_For_Pricing__c){puom.zpl__Hidden__c = true;}
        }
    }
    
    if(Trigger.isAfter){
        
        Boolean hasToRun = true;
        if(!Test.isRunningTest()){ hasToRun = (Boolean) AIQZilliantConfiguration__c.getInstance().get('runUOMZCloudSync__c'); }
        
        if(hasToRun){
            zpf.GenericSynchronizedDomainObject.triggerHandler(new AIQ_SyncUOMFilter('zpl__ProductUOM__c', 'SyncDownFieldSet'), 'zpl__ProductUOMId__c');         
        }
    }
    
}
trigger AIQProductSyncLEDS on Product2 (after insert, after update, after delete) {
    
    Boolean hasToRun = true;
    
    if(!Test.isRunningTest()){ hasToRun = (Boolean) AIQZilliantConfiguration__c.getInstance().get('runProductZCloudSync__c');
    }
    
    if(hasToRun){
        zpf.GenericSynchronizedDomainObject.triggerHandler(new AIQ_SyncProductFilter('Product2', 'AIQ_SyncDownFieldSet'), 'zpl__ProductId__c');
    }
    
    
}
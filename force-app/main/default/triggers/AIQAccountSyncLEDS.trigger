trigger AIQAccountSyncLEDS on Account (after insert, after update, after delete) {
    
    Boolean hasToRun = true;
    //User runUser = new User(Id=UserInfo.getUserId());
    if(!Test.isRunningTest()){ hasToRun = (Boolean) AIQZilliantConfiguration__c.getInstance().get('runAccountZcloudSync__c'); 
        //runUser = (AIQZilliantConfiguration__c.getInstance().get('ZcloudSyncUserId__c') != null ? new User(Id=(Id) AIQZilliantConfiguration__c.getInstance().get('ZcloudSyncUserId__c')) : runUser);
    }

    if(hasToRun){
        zpf.GenericSynchronizedDomainObject.triggerHandler(new AIQ_SyncAccountFilter('Account', 'AIQ_SyncDownFieldSet'), 'zpl__CustomerId__c');   
    }    
}
public without sharing class AIQ_AccountTriggerHandler {

    public static void runSyncDown() {
        Boolean hasToRun = true;
        //User runUser = new User(Id=UserInfo.getUserId());
        if(!Test.isRunningTest()){ hasToRun = (Boolean) AIQZilliantConfiguration__c.getInstance().get(AIQ_Constants.ACCOUNT_EXTERNAL_ID);
            //runUser = (AIQZilliantConfiguration__c.getInstance().get('ZcloudSyncUserId__c') != null ? new User(Id=(Id) AIQZilliantConfiguration__c.getInstance().get('ZcloudSyncUserId__c')) : runUser);
        }

        if(hasToRun){ 
            zpf.GenericSynchronizedDomainObject.triggerHandler(new AIQ_SyncAccountFilter('Account', AIQ_Constants.ACCOUNT_SYNC_DOWN_FIELDSET_NAME), 'zpl__CustomerId__c');
        }
    }
}
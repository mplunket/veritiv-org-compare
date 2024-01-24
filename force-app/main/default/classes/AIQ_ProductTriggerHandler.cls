public without sharing class AIQ_ProductTriggerHandler {

    public static void runSyncDown() {
        Boolean hasToRun = true;

        if(!Test.isRunningTest()){ hasToRun = (Boolean) AIQZilliantConfiguration__c.getInstance().get(AIQ_Constants.PRODUCT_EXTERNAL_ID); 
        }

        if(hasToRun){
            zpf.GenericSynchronizedDomainObject.triggerHandler(new AIQ_SyncProductFilter('Product2', 'AIQ_SyncDownFieldSet'), 'zpl__ProductId__c');
        }
    }
}
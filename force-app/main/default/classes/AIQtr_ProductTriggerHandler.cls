public with sharing class AIQtr_ProductTriggerHandler extends AIQtr_TriggerHandler {

    public AIQtr_ProductTriggerHandler() {
        super();
    }
    
    protected override void afterInsert() {
        AIQ_ProductTriggerHandler.runSyncDown();
    }

    protected override void afterUpdate() {
        AIQ_ProductTriggerHandler.runSyncDown();
    }

    protected override void afterDelete() {
        AIQ_ProductTriggerHandler.runSyncDown();
    }

}
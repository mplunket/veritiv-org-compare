public with sharing class AIQtr_ProductUOMTriggerHandler extends AIQtr_TriggerHandler {

    public AIQtr_ProductUOMTriggerHandler() {
        super();
    }


    protected override void beforeInsert() {
        List<zpl__ProductUOM__c> newUoms = (List<zpl__ProductUOM__c>) Trigger.new;

        AIQ_ProductUOMTriggerHandler.updateHidden(newUoms);
    }

    protected override void afterInsert() {
        AIQ_ProductUOMTriggerHandler.runSyncDown();
    }

    protected override void beforeUpdate() {
        Map<Id, zpl__ProductUOM__c> newMap = (Map<Id, zpl__ProductUOM__c>) Trigger.newMap;

        AIQ_ProductUOMTriggerHandler.updateHidden(newMap.values());
    }

    protected override void afterUpdate() {
        AIQ_ProductUOMTriggerHandler.runSyncDown();
    }

    protected override void afterDelete() {
        AIQ_ProductUOMTriggerHandler.runSyncDown();
    }
}
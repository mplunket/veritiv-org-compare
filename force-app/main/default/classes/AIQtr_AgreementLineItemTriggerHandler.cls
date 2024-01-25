public without sharing class AIQtr_AgreementLineItemTriggerHandler extends AIQtr_TriggerHandler {
    @TestVisible
    private AIQ_AgreementLineItemTriggerHandler handler;
    public AIQtr_AgreementLineItemTriggerHandler() {
        super();
        handler = new AIQ_AgreementLineItemTriggerHandler();
    }

    protected override void beforeInsert() {
        List<zpl__ContractLineItem__c> newCLIs = (List<zpl__ContractLineItem__c>) Trigger.new;
        AIQtr_TriggerHelper.addId(newCLIs, 'zpl__ContractLineItemId__c');
        handler.setAllLineLevelsMap();
        handler.setAllPolicyTypeMap();
        handler.setDefaults(newCLIs);
        handler.syncRecordType(newCLIs);
        handler.setRepresentativeProduct(newCLIs);
        handler.updateUOMs(newCLIs);
        handler.setNationalAccountPolicyType(newCLIs);
        handler.alignLineGroupBeforePublish(newCLIs);
    }

    protected override void afterInsert() {
        handler.runSyncDown();
        Map<Id, zpl__ContractLineItem__c> newMap = (Map<Id, zpl__ContractLineItem__c>) Trigger.newMap;
        handler.alignLineGroupAfterPublish(newMap.values());
    }

    protected override void beforeUpdate() {
        Map<Id, zpl__ContractLineItem__c> newMap = (Map<Id, zpl__ContractLineItem__c>) Trigger.newMap;
        Map<Id, zpl__ContractLineItem__c> oldMap = (Map<Id, zpl__ContractLineItem__c>) Trigger.oldMap;
        handler.setAllLineLevelsMap();
        handler.setAllPolicyTypeMap();
        handler.setDefaults(newMap.values());
        handler.syncRecordType(newMap.values());
        handler.updateUOMs(newMap.values());
        handler.setNationalAccountPolicyType(newMap.values());
        handler.alignLineGroupBeforePublish(newMap.values(), oldMap);
        handler.requireReason(newMap, oldMap);
        handler.alignLineGroupAfterPublish(newMap.values(), oldMap);
    }

    protected override void afterUpdate() {
        handler.runSyncDown();
        Map<Id, zpl__ContractLineItem__c> newMap = (Map<Id, zpl__ContractLineItem__c>) Trigger.newMap;
        Map<Id, zpl__ContractLineItem__c> oldMap = (Map<Id, zpl__ContractLineItem__c>) Trigger.oldMap;
        handler.deleteDraftLines(newMap, oldMap);
        handler.alignLineGroupAfterPublish(newMap.values(), oldMap);
    }

    protected override void afterDelete() {
        handler.runSyncDown();
    }

}
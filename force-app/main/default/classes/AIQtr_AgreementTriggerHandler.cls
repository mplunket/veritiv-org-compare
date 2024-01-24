public with sharing class AIQtr_AgreementTriggerHandler extends AIQtr_TriggerHandler {

    public AIQtr_AgreementTriggerHandler() {
        super();
    }


    protected override void beforeInsert() {
        List<Contract> contracts = (List<Contract>) Trigger.new;

        AIQ_AgreementTriggerHandler.validateAccount(contracts);
    }

    protected override void afterInsert() {
        Map<Id, Contract> newContracts = (Map<Id, Contract>) Trigger.newMap;

        if (AIQ_AgreementTriggerHandler.isPricingContractRecordType(newContracts.values())) {
            AIQ_AgreementTriggerHandler.updateAccount(newContracts.values());
            AIQ_AgreementTriggerHandler.runSyncDown();
        }
    }

    protected override void beforeUpdate() {

    }

    protected override void afterUpdate() {
        Map<Id, Contract> newContracts = (Map<Id, Contract>) Trigger.newMap;
        Map<Id, Contract> oldContracts = (Map<Id, Contract>) Trigger.oldMap;

        if (AIQ_AgreementTriggerHandler.isPricingContractRecordType(newContracts.values())) {
            AIQ_AgreementTriggerHandler.runSyncDown();
        }
    }

    protected override void beforeDelete() {

    }

    protected override void afterDelete() {
        Map<Id, Contract> oldContracts = (Map<Id, Contract>) Trigger.oldMap;

        if (AIQ_AgreementTriggerHandler.isPricingContractRecordType(oldContracts.values())) {
            AIQ_AgreementTriggerHandler.updateAccount(oldContracts.values());
            AIQ_AgreementTriggerHandler.runSyncDown();
        }
    }

    protected override void afterUndelete() {

    }

}
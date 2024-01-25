public with sharing class AIQtr_AccountTriggerHandler extends AIQtr_TriggerHandler {

    private static final String ACCOUNT = 'Account';
    private static final String EXTERNAL_ID_FIELD_NAME = 'zpl__CustomerId__c';

    public AIQtr_AccountTriggerHandler() {
        super();
    }

    @TestVisible
    protected override void afterInsert() {
        zpf.GenericSynchronizedDomainObject.triggerHandler(new AIQ_SyncAccountFilter(ACCOUNT, AIQ_Constants.ACCOUNT_SYNC_DOWN_FIELDSET_NAME), EXTERNAL_ID_FIELD_NAME);
    }

    @TestVisible
    protected override void afterUpdate() {
        zpf.GenericSynchronizedDomainObject.triggerHandler(new AIQ_SyncAccountFilter(ACCOUNT, AIQ_Constants.ACCOUNT_SYNC_DOWN_FIELDSET_NAME), EXTERNAL_ID_FIELD_NAME);
    }

    @TestVisible
    protected override void afterDelete() {
        zpf.GenericSynchronizedDomainObject.triggerHandler(new AIQ_SyncAccountFilter(ACCOUNT, AIQ_Constants.ACCOUNT_SYNC_DOWN_FIELDSET_NAME), EXTERNAL_ID_FIELD_NAME);
    }

}
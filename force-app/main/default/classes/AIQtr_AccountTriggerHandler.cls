public with sharing class AIQtr_AccountTriggerHandler extends AIQtr_TriggerHandler {

    public AIQtr_AccountTriggerHandler() {
        super();
    }

    protected override void beforeInsert() {

    }

    protected override void afterInsert() {
        AIQ_AccountTriggerHandler.runSyncDown();
    }

    protected override void beforeUpdate() {

    }

    protected override void afterUpdate() {
        AIQ_AccountTriggerHandler.runSyncDown();
    }

    protected override void beforeDelete() {}

    protected override void afterDelete() {AIQ_AccountTriggerHandler.runSyncDown();}

}
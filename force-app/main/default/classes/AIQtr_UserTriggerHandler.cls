public with sharing class AIQtr_UserTriggerHandler extends AIQtr_TriggerHandler {

    public AIQtr_UserTriggerHandler() {
        super();
    }


    protected override void beforeInsert() {

    }

    protected override void afterInsert() {
        Map<Id, User> oldMap = (Map<Id, User>) Trigger.oldMap;
        Map<Id, User> newMap = (Map<Id, User>) Trigger.newMap;

        AIQsec_UserPermissionsTriggerHandler.handleUserChange(newMap.values(), oldMap);
    }

    protected override void beforeUpdate() {

    }

    protected override void afterUpdate() {
        Map<Id, User> oldMap = (Map<Id, User>) Trigger.oldMap;
        Map<Id, User> newMap = (Map<Id, User>) Trigger.newMap;

        AIQsec_UserPermissionsTriggerHandler.handleUserChange(newMap.values(), oldMap);
    }

    protected override void beforeDelete() {

    }

    protected override void afterDelete() {

    }

    protected override void afterUndelete() {

    }

}
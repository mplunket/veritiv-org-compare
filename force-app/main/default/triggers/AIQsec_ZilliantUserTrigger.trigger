trigger AIQsec_ZilliantUserTrigger on User (after insert, after update) {
    
    AIQsec_UserPermissionsTriggerHandler.handleUserChange(Trigger.new, Trigger.oldMap);

}
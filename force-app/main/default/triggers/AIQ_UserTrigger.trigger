trigger AIQ_UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AIQtr_UserTriggerHandler().run();
}
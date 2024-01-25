trigger AIQ_AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AIQtr_AccountTriggerHandler().run();
}
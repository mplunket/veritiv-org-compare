trigger AIQ_ProductTrigger on Product2 (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AIQtr_ProductTriggerHandler().run();
}
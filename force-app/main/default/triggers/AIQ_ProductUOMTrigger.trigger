trigger AIQ_ProductUOMTrigger on zpl__ProductUOM__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AIQtr_ProductUOMTriggerHandler().run();
}
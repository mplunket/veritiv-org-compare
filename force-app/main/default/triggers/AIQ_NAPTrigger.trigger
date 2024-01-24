trigger AIQ_NAPTrigger on NationalAccountsPricing__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AIQtr_NAPTriggerHandler().run();
}
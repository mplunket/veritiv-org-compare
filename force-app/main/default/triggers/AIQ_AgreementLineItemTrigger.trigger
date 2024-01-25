trigger AIQ_AgreementLineItemTrigger on zpl__ContractLineItem__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AIQtr_AgreementLineItemTriggerHandler().run();
}
trigger AIQ_AgreementTrigger on Contract (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AIQtr_AgreementTriggerHandler().run();
}
trigger UnifyNationalAccountPricingTrigger on Unify_National_Accounts_Pricing__c (after insert) {

    if(trigger.isAfter && trigger.isInsert){
        UnifyNAPricingTriggerHandler.afterInsert(trigger.New);
        
    }
}
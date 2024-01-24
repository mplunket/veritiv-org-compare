trigger UnifyNationalAccountTrigger on Unify_National_Account__c (after insert) {

    if(trigger.IsInsert && trigger.isAfter){
       UnifyNationalAccountTriggerHandler.afterInsertOperations(trigger.new);
    }
}
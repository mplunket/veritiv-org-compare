trigger ContractLineItemCreateApprovalTrigger on zpl__ContractLineItem__c (After Update, before delete) {

    if(Trigger.isAfter && Trigger.isUpdate){
        CLICreateApprovalTriggerHandler.BeforeUpdate(trigger.new, trigger.oldMap, trigger.OldMap);
    } else if(Trigger.isBefore && Trigger.isDelete){
        CLICreateApprovalTriggerHandler.BeforeDelete(trigger.old);
    }
}
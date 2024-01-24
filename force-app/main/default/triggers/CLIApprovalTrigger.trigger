trigger CLIApprovalTrigger on Contract_Line_Item_Approval__c (before update) {

    if(Trigger.isBefore){
        system.debug('##before');
        if(Trigger.isUpdate){
            system.debug('##update');
            CLIApprovalTriggerHandler.beforeUpdate(Trigger.New, Trigger.oldMap, Trigger.newMap);
        }
    }
}
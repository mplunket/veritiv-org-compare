public without sharing class CLICreateApprovalTriggerHandler {

    public static void BeforeUpdate(list<zpl__ContractLineItem__c> listContractLineItem, map<Id, zpl__ContractLineItem__c> mapOldCLI, map<Id, zpl__ContractLineItem__c> mapNewCLI){
        //converted this PB - Contract Line Item Zilliant Pending v2
        
        final String CLI_RT_INACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName()
            .get('Inactive')
            .getRecordTypeId();
        
        list<Id> listProcessCLIId = new list<Id>();
        list<Id> listAutoApprovedCLIId = new list<Id>();
        Set<Id> inactiveLineIds = new Set<Id>();
        
        system.debug('##listContractLineItem: ' + listContractLineItem);
        system.debug('##listContractLineItem: ' + listContractLineItem.size());
        for(zpl__ContractLineItem__c cli : listContractLineItem){
            
            System.debug('##Trigger: '+cli.Id +' - '+ cli.PriceDecreaseFlag__c + ' - ' + cli.StartDateDelayed__c +' - '+ cli.zpl__Status__c + ' - ' );
            
            if (cli.RecordTypeId == CLI_RT_INACTIVE_ID || cli.zpl__Status__c == 'Deleted' || cli.zpl__Status__c =='Deleted Camp' || cli.zpl__Status__c == 'Deleted By Quote'){
                inactiveLineIds.add(cli.Id);
            } else if(mapOldCLI.get(cli.id).zpl__Status__c != 'Pend Appr' && cli.zpl__Status__c == 'Pend Appr'){
                if((cli.PriceDecreaseFlag__c == true || cli.StartDateDelayed__c == true) ){
                    listProcessCLIId.add(cli.Id);
                }else if(cli.PriceDecreaseFlag__c == false && cli.StartDateDelayed__c == false ){
                    listAutoApprovedCLIId.add(cli.Id);
                }
            }
        }
        
        system.debug('##inactiveLineIds: ' + inactiveLineIds);
        system.debug('##inactiveLineIds: ' + inactiveLineIds.size());
        if (!inactiveLineIds.isEmpty()){
            if(CLIApprovalTriggerHandler.contracLineItemApprovalTriggerFlag){
        		if (!(System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())) {
            		ContractLineItemApprovalService.deleteContractLineItemApprovalsFuture(inactiveLineIds);
                }
            } else {
            	ContractLineItemApprovalService.deleteContractLineItemApprovals(inactiveLineIds);
            }
        }
        
        system.debug('##listProcessCLIId: ' + listProcessCLIId);
        system.debug('##listProcessCLIId: ' + listProcessCLIId.size());
        if(listProcessCLIId.size() > 0){
            ContractLineItemApprovalService.createContractLineItemApprovals(listProcessCLIId);
        }
        
        system.debug('##listAutoApprovedCLIId: ' + listAutoApprovedCLIId);
        system.debug('##listAutoApprovedCLIId: ' + listAutoApprovedCLIId.size());
        
        if(listAutoApprovedCLIId.size() > 0){
            AIQAgrLineApproval.approveAgrLine(listAutoApprovedCLIId);
        }
    }
    
    public static void BeforeDelete(list<zpl__ContractLineItem__c> listContractLineItem){
        Set<Id> deletedContractLineItemId = new Set<Id>();
        for(zpl__ContractLineItem__c cli : listContractLineItem){
            deletedContractLineItemId.add(cli.id);
        }

        ContractLineItemApprovalService.deleteContractLineItemApprovals(deletedContractLineItemId);
    }
}
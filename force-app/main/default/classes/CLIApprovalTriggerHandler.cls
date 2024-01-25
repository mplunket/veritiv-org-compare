public class CLIApprovalTriggerHandler {
    public static Boolean contracLineItemApprovalTriggerFlag = false; // for preventing recursion

    public static void beforeUpdate(list<Contract_Line_Item_Approval__c> listCLIA, map<Id, Contract_Line_Item_Approval__c> oldMap, map<Id, Contract_Line_Item_Approval__c> newMap) {

        contracLineItemApprovalTriggerFlag = true;
        System.debug('contracLineItemApprovalTriggerFlag' + contracLineItemApprovalTriggerFlag);
        
        list<Id> listCLIAApproved = new list<Id>();
        list<Id> listCLIARejected = new list<Id>();
        list<Id> listCLIACanceled = new list<Id>();

        list<Id> listCLIAId = new list<Id>();
        list<Id> listCLIId = new list<id>();
        for(Contract_Line_Item_Approval__c clia : listCLIA){
            if(oldMap.get(clia.Id).Status__c != newMap.get(clia.Id).Status__c){
                system.debug('##clia: ' + clia);
                system.debug('##clia.Status__c: ' + clia.Status__c);
    
                if(clia.Status__c == 'Approved'){
                    clia.Actioned_Date__c = datetime.now();
                    clia.RecordTypeId = System.label.CLIA_Closed_Record_Type_ID;
                    listCLIAId.add(clia.Id);
                    listCLIAApproved.add(clia.Id);
                }else if(clia.Status__c == 'Rejected'){
                    clia.RecordTypeId = System.label.CLIA_Closed_Record_Type_ID;
                    listCLIARejected.add(clia.Id);
                    listCLIId.add(clia.Contract_Line_Item__c);
                }else if (clia.Status__c == 'Cancelled'){
                    clia.Actioned_By__c = 'Expiration';
                    clia.Actioned_Date__c = datetime.now();
                    clia.RecordTypeId = System.label.CLIA_Closed_Record_Type_ID;
                }
            }
        }

        //Approved
        system.debug('##listCLIAApproved: ' + listCLIAApproved);
        system.debug('##listCLIAApproved: ' + listCLIAApproved.size());
        if(listCLIAApproved.size() > 0){
            ContractLineItemApprovalService.mNewCLIA = newMap;
            ContractLineItemApprovalService.createContractLineItemApprovals(listCLIAApproved);
        }

        //Rejected 
        system.debug('##Rejected listCLIId: ' + listCLIId);
        system.debug('##Rejected listCLIId: ' + listCLIId.size());
        if(listCLIId.size() > 0){
            AIQAgrLineRejection.rejectAgrLine(listCLIId);
            SendRejectedEmail(listCLIId);
        }        
    }

    public static void SendRejectedEmail (List<Id> listCLIARejected) {

        list<Messaging.SingleEmailMessage> listmail = new list<Messaging.SingleEmailMessage>();
        
        EmailTemplate et = [Select id from EmailTemplate where DeveloperName = 'Deal_Manager_Contract_Line_Item_Rejection_Notification'];

        for(zpl__ContractLineItem__c cli : [Select Id, CreatedById , Published_By__c From zpl__ContractLineItem__c Where Id IN :listCLIARejected]){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String createdBy = cli.CreatedById ;
            mail.setTargetObjectId( createdBy );
            mail.setWhatId(cli.Id);            
            mail.setTemplateId(et.Id);

            mail.setUseSignature(false);
            mail.setBccSender(false);
            //mail.setSaveAsActivity(true);

            //listmail.add(mail);
        }
        
        System.debug('Sending the email ');     
        //Messaging.sendEmail(listmail);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(listmail);
        System.debug ('##Email - ' + r );

    }

}
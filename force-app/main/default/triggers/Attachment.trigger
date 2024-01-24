trigger Attachment on Attachment (after insert, before insert) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){

            List<Attachment> filteredAttachments = AttachmentServices.filterAttachmentsAssociatedToQuotes(Trigger.new);
            
            if(filteredAttachments != null){
                List<Quote_PDF__c> newlyCreatedQuotePDFs = AttachmentServices.createQuotePDFs(filteredAttachments);
                                
                SafeDML objsToInsert = new SafeInsert();
                objsToInsert.queue(newlyCreatedQuotePDFs,new ErrorHandling.AddErrorsToTriggerNew(Trigger.newMap, 'Attachment_ID__c')); 
                objsToInsert.doDml();
            }
        }
    }
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            
            List<Attachment> filteredAttachments = new List<Attachment>(); 
            List<Attachment> filteredDraftFSAttachments = AttachmentServices.filterDraftFSAuditAttachments(Trigger.new);
            List<Attachment> filteredFinalFSAttachments = AttachmentServices.filterFinalFSAuditAttachments(Trigger.new);

            
            filteredAttachments.addAll(filteredDraftFSAttachments); 
            filteredAttachments.addAll(filteredFinalFSAttachments);
            
            Map<ID,Opportunity> OpptyIdMap = AttachmentServices.moveAttachmentsWithMATOpptys(filteredAttachments);

            if(!OpptyIdMap.isEmpty())
            {
                AttachmentServices.sendFSAuditEmailMessages(filteredDraftFSAttachments, filteredFinalFSAttachments, OpptyIdMap);
                AttachmentServices.deleteOlderVersionsOfAttachment(filteredAttachments, OpptyIdMap);
            }

            Map<Id, List<Attachment>> casesToAttachmentsMap = AttachmentServices.getCaseReparentMap(Trigger.new);
            System.debug('###casesToAttachmentsMap in Trigger: ' + casesToAttachmentsMap);
            AttachmentServices.reparentAttachments(casesToAttachmentsMap);

        }

    }
}
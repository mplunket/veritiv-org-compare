public class contentVersionTriggerHandler {
    
    public static final String EMAIL_2_CASE_RTYPE = 'Incoming_Fax';
    public static final String Vendor_Claim_Print_RTYPE = 'Vendor_Claim_Print';
    static Id email2CaseRType;
    static final String EMAIL_ID_PREFIX = Schema.SObjectType.EmailMessage.getKeyPrefix(); 
    static final String CASE_ID_PREFIX = Schema.SObjectType.Case.getKeyPrefix();
    
    static Set<Id> attachmentEmail2CaseRTypes {
        get{
            if (attachmentEmail2CaseRTypes == null){
                attachmentEmail2CaseRTypes = CaseModel.getRecordTypesIntoSet(new Set<String>{EMAIL_2_CASE_RTYPE,Vendor_Claim_Print_RTYPE });    
            }
            return attachmentEmail2CaseRTypes;
        }
        set;
    }
    
    public static void processFiles(List<contentVersion>incomingFile)
    {       
        system.debug('Inside process attachments method');
        email2CaseRType = CaseModel.getInboundCaseRT().Id;
        
        Map<Id, List<ContentDocumentLink>> emailMessageIdToContentdocumentLink = new Map<Id, List<ContentDocumentLink>>();
         Map<Id, List<ContentVersion>> contentdocumentIdToFileList = new Map<Id, List<ContentVersion>>();
        Map<Id, EmailMessage> emailIdToEmailMessage = new Map<Id, EmailMessage>();              
        Map<Id,Id>emailToCaseLookup = new Map<Id,Id>();
        Set<Id>caseIdsToCheck = new Set<Id>();
        Set<Id>validCases = new Set<Id>();
        set<id>contentDocumentIdSet =  new set<id>();
        Boolean isFromEmail =  False;
        Map<id,set<id>> existingDocumentLink = new map<id,set<id>>();
        if(email2CaseRType != null)
        {                                       
            for(contentVersion conVersion : incomingFile)
            {
                contentDocumentIdSet.add(conVersion.ContentDocumentId);
                 if(contentdocumentIdToFileList.get(conVersion.ContentDocumentId) == null)
                    contentdocumentIdToFileList.put(conVersion.ContentDocumentId, new List<ContentVersion>());
                    contentdocumentIdToFileList.get(conVersion.ContentDocumentId).add(conVersion);  
            }
            system.debug(contentDocumentIdSet);
            if(!contentDocumentIdSet.isEmpty()){
                for(contentDocumentLink conDocumentLink: [SELECT LinkedEntityId, ContentDocumentId from contentDocumentLink where ContentDocumentId =:contentDocumentIdSet ]){
                    //system.assertEquals(conDocumentLink, null);
                    system.debug('Query from contentDocumentLink' + conDocumentLink);
                    String idInQuestion = (String)conDocumentLink.LinkedEntityId;
                                       
                    if(idInQuestion.startsWith(EMAIL_ID_PREFIX ))
                    {
                        isFromEmail = true;
                        if(emailMessageIdToContentdocumentLink.get(conDocumentLink.LinkedEntityId) == null)
                            emailMessageIdToContentdocumentLink.put(conDocumentLink.LinkedEntityId, new List<contentDocumentLink>());
                        emailMessageIdToContentdocumentLink.get(conDocumentLink.LinkedEntityId).add(conDocumentLink);   
                    }      
                    
                    //map the current files connections to check later for duplicate assignment
                    if(existingDocumentLink.containskey(conDocumentLink.ContentDocumentId)==false){
                        existingDocumentLink.put(conDocumentLink.ContentDocumentId, new set<id>());    
                    }
                    existingDocumentLink.get(conDocumentLink.ContentDocumentId).add(conDocumentLink.LinkedEntityId);                    
                    
                }
            }
            
            if(!contentdocumentIdToFileList.IsEmpty())
            {
                
                //Find these emails based on the ids
                //and determine if they are attached to cases with the incomingFax Recordtype
                for(EmailMessage found : [Select id, ParentId, Subject 
                                          from EmailMessage
                                          where id in :emailMessageIdToContentdocumentLink.keySet()])
                {
                    String parId = (String)found.ParentId;
                    
                    if(parId.startsWith(CASE_ID_PREFIX)){               
                        emailToCaseLookup.put(found.id, found.ParentId);
                        caseIdsToCheck.add(found.ParentId);
                        emailIdToEmailMessage.put(found.Id, found);
                    }
                }
                //We now need to ensure these cases are of recordType incomingFax
                Id consCaseRecrdTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Console Case').getRecordTypeId();
                attachmentEmail2CaseRTypes.add(consCaseRecrdTypeId);
                
                for(Case found : [Select id from Case where Id in : caseIdsToCheck and RecordTypeId in :attachmentEmail2CaseRTypes]){
                    //restricted to F2C - Inbound Case, Vendor_Claim_Print only
                    validCases.add(found.Id);
                }
                //removed record type restriction
                //for(Case found : [Select id from Case where Id in : caseIdsToCheck])
                //    validCases.add(found.Id);
                
                
                //Iterate through the case emailattachments and edit the parent id of the 
                //attachments that are attached to emails that area attached to 
                //cases of recordtype incomingFax
                //List<attachment> attchListForCase = new List<attachment>();
                List<ContentDocumentLink > FileConnectionListForCase = new List<ContentDocumentLink >();
                set<ContentDocumentLink > emailCDL = new set<ContentDocumentLink >();
                if(!contentdocumentIdToFileList.isEmpty()){
                    for(List<ContentVersion> fileList : contentdocumentIdToFileList.values())
                    {
                        for(ContentVersion file : fileList) 
                        {       
                            for(List<contentDocumentLink> emailList : emailMessageIdToContentdocumentLink.values()){
                                
                                for(contentDocumentLink eList: emailList){
                                    //If this attachment is attached to an email that is attached to a
                                    //case of recordtype incomingFax 
                                    
                                    //add the CDL connected to email and to be deleted to remove duplicate in file related list
                                    emailCDL.add(eList); 
                                                           
                                    if(validCases.contains(emailToCaseLookup.get(eList.LinkedEntityId)))
                                    {
                                        //Update the parent id of the attachment
                                        //to be the case
                                        //attach.ParentId = emailToCaseLookup.get(attach.ParentId); 
                                        
                                        //check first if there is already a connection between the file and the case. Skip if there is already a connection
                                        system.debug('eList.ContentDocumentId = ' + eList.ContentDocumentId);
                                        system.debug('emailToCaseLookup.get(eList.LinkedEntityId) = ' + emailToCaseLookup.get(eList.LinkedEntityId) );
                                        system.debug('map = '+ existingDocumentLink.get(eList.ContentDocumentId));
                                        system.debug('contains map? = '+ existingDocumentLink.get(eList.ContentDocumentId).contains(emailToCaseLookup.get(eList.LinkedEntityId)));
                                        if(existingDocumentLink.get(eList.ContentDocumentId).contains(emailToCaseLookup.get(eList.LinkedEntityId))==false){
                                            ContentDocumentLink  cd = new ContentDocumentLink();
                                            cd.LinkedEntityId=emailToCaseLookup.get(eList.LinkedEntityId);
                                            cd.ContentDocumentId=eList.ContentDocumentId;
                                            cd.Visibility = 'AllUsers'; 
                                            FileConnectionListForCase.add(cd);
                                            
                                            if(existingDocumentLink.containskey(cd.ContentDocumentId)==false){
                                                existingDocumentLink.put(cd.ContentDocumentId, new set<id>());    
                                            }
                                            existingDocumentLink.get(cd.ContentDocumentId).add(cd.LinkedEntityId);    
                                              
                                        }
                                        //    at.Name = file.Title;
                                        // at.IsPrivate = attach.IsPrivate;
                                        //at.Body= file.VersionData;
                                        //at.Description = file.Description;
                                        // at.ContentType = file.ContentType;
                                        // at.IsPartnerShared = attach.IsPartnerShared;
                                        
                                        
                                        
                                        //at.parentId = emailToCaseLookup.get(eList.LinkedEntityId);
                                        //attchListForCase.add(at);
                                    }
                                }
                            }   
                        }
                    }
                }
                
                if(FileConnectionListForCase.size() > 0){
                    system.debug(FileConnectionListForCase);
                    insert FileConnectionListForCase;
                    /*
                    system.debug('attachmenttoinsert'+attchListForCase);
                    set<attachment> attachSet = new set<attachment>();
                    List<attachment> result = new List<attachment>();
                    attachSet.addall(attchListForCase);
                    result.addAll(attachSet);
                    system.debug('attachementfinal'+result);
                    insert result;
                    */
                }
                /*
                if(emailCDL.size()>0){
                    list<ContentDocumentLink > emailCDLDelete = new List<ContentDocumentLink >();
                    emailCDLDelete.addall(emailCDL);
                    delete emailCDLDelete;
                }
                */
            }
        }
        
    }
}
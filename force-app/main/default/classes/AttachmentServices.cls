public with sharing class AttachmentServices {

static Id email2CaseRType;


static final String EMAIL_ID_PREFIX = Schema.SObjectType.EmailMessage.getKeyPrefix(); 
static final String CASE_ID_PREFIX = Schema.SObjectType.Case.getKeyPrefix();
public static final String EMAIL_2_CASE_RTYPE = 'Incoming_Fax';


public static String createdDateField = 'createdDate';

public static String draftFSAuditAttachmentStartName = 'Draft-FacilityAssessment';
public static String finalFSAuditAttachmentStartName = 'FacilityAssessment';

public static String quoteIDPrefix = Schema.SObjectType.Quote__c.getKeyPrefix();
public static String accountPrefix = '001';

       
static Set<Id> attachmentEmail2CaseRTypes {
  get{
    if (attachmentEmail2CaseRTypes == null){
      attachmentEmail2CaseRTypes = CaseModel.getRecordTypesIntoSet(new Set<String>{EMAIL_2_CASE_RTYPE, CaseServices.ULS_CASE_IDENTIFIER});  
    }
    return attachmentEmail2CaseRTypes;
  }
  set;
}
 
  public static List<Attachment> filterAttachmentsAssociatedToQuotes(List<Attachment> incomingAttachments)
  {
    List<Attachment> retAttachments = new List<Attachment>();
    for(Attachment a : incomingAttachments)
    {
      if(((String)a.ParentID).startsWith(quoteIDPrefix))
      {
        retAttachments.add(a);
      }
    }
    return retAttachments;
  }
  
  public static Messaging.EmailFileAttachment createEmailAttachment(Attachment a)
  {
    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    efa.setFileName(a.Name);
    efa.setBody(a.Body);
    efa.setContentType(a.ContentType);
    return efa;
  }
  
  
  /* Given the list of specified attachments, create a Quote PDF for each attachment such that:
   *   1) Account__c is the account of the quote associated to the attachment
   *   2) Attachment_ID__c is the ID of the attachment 
   *   3) Quote__c is the quote associated to the attachment
   *   4) File_Name__c is the name of the attachment
   *
   * @param attachments the specified attachments
   * @precondition specified attachments must be directly associated to quotes
   */
  public static List<Quote_PDF__c> createQuotePDFs(List<Attachment> attachments)
  {
    List<Quote_PDF__c> newlyCreatedQuotePDFs = new List<Quote_PDF__c>();
    
    List<Quote__c> quotesForAttachments = [SELECT Id, Account__c FROM Quote__c WHERE ID IN: Pluck.ids('ParentId', attachments)];
    
    Map<Id, Quote__c> quoteIdToQuote = new Map<Id, Quote__c>(quotesForAttachments);
    
    for(Attachment attchmt: attachments){
      Quote_PDF__c newQuotePDF = new Quote_PDF__c();
      newQuotePDF.Account__c = quoteIdToQuote.get(attchmt.ParentId).Account__c;
      newQuotePDF.Attachment_ID__c = attchmt.Id;
      newQuotePDF.Quote__c = attchmt.ParentId;
      newQuotePDF.File_Name__c = attchmt.Name;
      
      newlyCreatedQuotePDFs.add(newQuotePDF);
    }
    
    return newlyCreatedQuotePDFs;
  }
  
  /*
   * Given the list of attachments we need to filter out attachments that are DraftFSAuditAttachments based on the following condition:
   * The name of the attachement should begin with 'DRAFT – Facility Assessment'
  */
  public static List<Attachment> filterDraftFSAuditAttachments(List<Attachment> attachments)
  {
    List<Attachment> filteredList = new List<Attachment>();
    
    for(Attachment attchmt: attachments){
      if(((String)attchmt.ParentID).startsWith(accountPrefix) && attchmt.Name.startsWith(draftFSAuditAttachmentStartName)){
        filteredList.add(attchmt);
      }
    }
    return filteredList;
  }
  
  /*
   * Given the list of attachments we need to filter out attachments that are Final FS Audit Attachments based on the following condition:
   * The name of the attachement should begin with 'Facility Assessment'
  */
  public static List<Attachment> filterFinalFSAuditAttachments(List<Attachment> attachments)
  {
    List<Attachment> filteredList = new List<Attachment>();
    
    for(Attachment attchmt: attachments){
      if(((String)attchmt.ParentID).startsWith(accountPrefix) && attchmt.Name.startsWith(finalFSAuditAttachmentStartName)){
        filteredList.add(attchmt);
      }
    }
    return filteredList;
  }
  
  
  public static void processAttachments(List<Attachment>incomingAttachments)
  {    
         email2CaseRType = CaseModel.getInboundCaseRT().Id;
    
    Map<Id, List<Attachment>> emailIdToAttachmentList = new Map<Id, List<Attachment>>();  
    Map<Id, EmailMessage> emailIdToEmailMessage = new Map<Id, EmailMessage>();        
    Map<Id,Id>emailToCaseLookup = new Map<Id,Id>();
    Set<Id>caseIdsToCheck = new Set<Id>();
    Set<Id>validCases = new Set<Id>();
    
    if(email2CaseRType != null)
    {                    
      //Grab attachments that are attached to emails
      for(Attachment incoming : incomingAttachments)
      {
        String idInQuestion = (String)incoming.ParentId;
        
        if(idInQuestion.startsWith(EMAIL_ID_PREFIX))
        {
          if(emailIdToAttachmentList.get(incoming.ParentId) == null)
            emailIdToAttachmentList.put(incoming.ParentId, new List<Attachment>());
          emailIdToAttachmentList.get(incoming.ParentId).add(incoming);        
          
        }      
      }
      
      if(!emailIdToAttachmentList.IsEmpty())
      {
          
        //Find these emails based on the ids
        //and determine if they are attached to cases with the incomingFax Recordtype
        for(EmailMessage found : [Select id, ParentId, Subject 
                      from EmailMessage
                      where id in :emailIdToAttachmentList.keySet()])
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
                
                for(Case found : [Select id from Case where Id in : caseIdsToCheck and RecordTypeId in :attachmentEmail2CaseRTypes])
          validCases.add(found.Id);
        
      
        //Iterate through the case emailattachments and edit the parent id of the 
        //attachments that are attached to emails that area attached to 
        //cases of recordtype incomingFax
        List<Attachment> attchListForCase = new List<Attachment>();
        for(List<Attachment> attachList : emailIdToAttachmentList.values())
        {
          for(Attachment attach : attachList)  
          {            
            //If this attachment is attached to an email that is attached to a
            //case of recordtype incomingFax            
            if(validCases.contains(emailToCaseLookup.get(attach.ParentId)))
            {
              //Update the parent id of the attachment
              //to be the case
              
                            attachment at = new attachment();
                            at.Name = attach.name;
                                at.Body= attach.Body;
                                at.Description = attach.Description;
                                at.ContentType = attach.ContentType;
                            at.parentId = emailToCaseLookup.get(attach.ParentId);
                            attchListForCase.add(at);
            }
          }
        }  
                
                if(attchListForCase.size() > 0){
                    insert attchListForCase;
                }
      
      }
    }
  }

  public static void deleteOlderVersionsOfAttachment(List<Attachment> newAttachments, Map<Id, Opportunity> opptyIdMap)
  {
    Set<Id> parentIdsSet = opptyIdMap.keySet();
    Set<String> descriptionOnAttachments = pluck.strings('Description', newAttachments);
    List<Attachment> attachmentsToDelete = [ SELECT Id FROM Attachment WHERE ParentId IN : parentIdsSet AND Description IN : descriptionOnAttachments];

    try
    {
      delete attachmentsToDelete;
    }
    catch( System.DmlException ex )
    {
      for( Integer index = 0; index < ex.getNumDml(); index++ )
      {
        newAttachments[ ex.getDmlIndex( index ) ].addError( ex.getDmlMessage( index ) );
      }
    }
  }

  public static Map<Id, List<Attachment>> getCaseReparentMap(List<Attachment> attachments)
  {

    Map<Id, List<Attachment>> parentIdToAttachments = GroupBy.ids('ParentId', attachments);
    System.debug('###parentIdToAttachments: ' + parentIdToAttachments);

    Map<Id, List<Task>> whatIdToTasks = GroupBy.ids('WhatId', [SELECT WhatId FROM Task WHERE Id IN :parentIdToAttachments.keySet()]);
    System.debug('###whatIdToTasks: ' + whatIdToTasks);

    List<Case> caseParents = [SELECT RecordTypeId FROM Case WHERE Id IN :whatIdToTasks.keySet()];
    System.debug('###caseParents: ' + caseParents);

    Id consoleCaseId = [SELECT Id FROM RecordType WHERE Name='Console Case'].Id;
    System.debug('###consoleCaseId: ' + consoleCaseId);

    Map<Id, List<Attachment>> caseToAttachmentsMap = new Map<Id, List<Attachment>>();
    for(Case caseParent : caseParents)
    {
      if(caseParent.RecordTypeId == consoleCaseId)
      {
        caseToAttachmentsMap.put(caseParent.Id, new List<Attachment>());
        for(Task childTask : whatIdToTasks.get(caseParent.Id))
        {
          caseToAttachmentsMap.get(caseParent.Id).addAll(parentIdToAttachments.get(childTask.Id));
        }
      }
    }

    return caseToAttachmentsMap;

  }

  public static void reparentAttachments(Map<Id, List<Attachment>> caseToAttachments)
  {
    for(Id parentCaseId : caseToAttachments.keySet())
    {
      for(Attachment att : caseToAttachments.get(parentCaseId))
      {
        att.ParentId = parentCaseId;
      }
            
    }
  }
}
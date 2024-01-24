public with sharing class AttachmentServices {

static Id email2CaseRType;


static final String EMAIL_ID_PREFIX = Schema.SObjectType.EmailMessage.getKeyPrefix(); 
static final String CASE_ID_PREFIX = Schema.SObjectType.Case.getKeyPrefix();
public static final String EMAIL_2_CASE_RTYPE = 'Incoming_Fax';
//Commenting MAT functionality 9/8/21
//public static String ERROR_MAT_OPPTY_NOT_FOUND ='There is an error: There are no opportunities in Salesforce related to the account associated with the attachment. Please contact your salesforce system administrator';
//public static String ERROR_MULTIPLE_MAT_OPPTY = 'There is an error: There are multiple opportunities in Salesforce related to the account associated with the attachment. Please contact your salesforce system administrator';

public static String createdDateField = 'createdDate';

public static String draftFSAuditAttachmentStartName = 'Draft-FacilityAssessment';
public static String finalFSAuditAttachmentStartName = 'FacilityAssessment';

public static String quoteIDPrefix = Schema.SObjectType.Quote__c.getKeyPrefix();
public static String accountPrefix = '001';

//public static String EMAIL_TEMPLATE_FOR_OWNER_DRAFT = 'FS_AUDIT_EMAIL_TO_ACCOUNT_OWNER_DRAFT';
//public static String EMAIL_TEMPLATE_FOR_OWNER_FINAL = 'FS_AUDIT_EMAIL_TO_ACCOUNT_OWNER';
//public static String EMAIL_TEMPLATE_FOR_OWNER_MANAGER = 'FS_Audit_Email_To_Account_Owner_Manager'; 
 			

static Set<Id> attachmentEmail2CaseRTypes {
	get{
		if (attachmentEmail2CaseRTypes == null){
			attachmentEmail2CaseRTypes = CaseModel.getRecordTypesIntoSet(new Set<String>{EMAIL_2_CASE_RTYPE, CaseServices.ULS_CASE_IDENTIFIER});	
		}
		return attachmentEmail2CaseRTypes;
	}
	set;
}
 			

	/*public static Map<String, EmailTemplate> devNameToEmailTemplate {
		get {
			if(devNameToEmailTemplate==null)
			{
				List<EmailTemplate> emailTemplates = [Select ID, DeveloperName From EmailTemplate Where DeveloperName IN (:EMAIL_TEMPLATE_FOR_OWNER_DRAFT,:EMAIL_TEMPLATE_FOR_OWNER_FINAL,:EMAIL_TEMPLATE_FOR_OWNER_MANAGER)];
				devNameToEmailTemplate = new Map<String, EmailTemplate>();
				for(EmailTemplate e : emailTemplates)
				{
					devNameToEmailTemplate.put(e.DeveloperName,e);
				}
			}
			return devNameToEmailTemplate;
		}
		private set;
	}*/
	/*
	 * Given the list of incoming attachments, return only those attachments that are associated to quotes 
	 *  that are in turn associated to accounts
	 */
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
	
	/*
	 * For the given attachments, send email messages to the appropriate individuals
	 * For a draft fs audit attachment, there must be an email sent to the opportunity owner
	 * For a final fs audit attachment, there must be an email sent to the opportunity owner and the opportunity owner's manager, if the manager exists
	 * @param draftFSAuditAttachments the draft FS audit attachments
	 * @precondition these attachments all have parentIDs that belong to the keyset of opptys
	 * @param finalFSAuditAttachments the final FS audit attachments
	 * @precondition these attachments all have parentIDs that belong to the keyset of opptys
	 * @param opptys the opportunities which are parents to draftFSAuditAttachments and finalFSAuditAttachments
	 * @precondition the fields OwnerID and Owner.ManagerID need to be included with each opportunity
	 * @return the sent emailmessages are returned
	*/
	/*public static List<Messaging.SingleEmailMessage> sendFSAuditEmailMessages(List<Attachment> draftFSAuditAttachments, List<Attachment> finalFSAuditAttachments, Map<ID, Opportunity> opptys)
	{
		List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

		emailMessages.addAll(getEmailMessagesForAccountOwners(EMAIL_TEMPLATE_FOR_OWNER_DRAFT,draftFSAuditAttachments, opptys));
		emailMessages.addAll(getEmailMessagesForAccountOwners(EMAIL_TEMPLATE_FOR_OWNER_FINAL,finalFSAuditAttachments, opptys));
		emailMessages.addAll(getEmailMessagesForAccountOwnersManagers(finalFSAuditAttachments, opptys));
		
		if(!emailMessages.isEmpty()) Messaging.sendEmail(emailMessages);
		return emailMessages;
	} */
	
	/* 
	 * Given a list of attachments and their opportunities, returns a list of email messages such that there is an email message for each opportunity 
	 * 		in which the opportunity owner's manager is the recepient, and all attachments related to the opportunity are attached to the email message.
	 *
	 * If any opportunity\'s owner does not have a manager, do not return an email message for that opportunity
	 *
	 * Pre-Condition: each opportunity in opportunities must include the Owner.ManagerID
	*/
	/*public static List<Messaging.Singleemailmessage> getEmailMessagesForAccountOwnersManagers(List<Attachment> attachments, Map<ID, Opportunity> opptyMap){
		return getEmailMessages('Owner.ManagerID',EMAIL_TEMPLATE_FOR_OWNER_MANAGER,attachments,opptyMap);
	}*/
	
	/* 
	 * Given a list of attachments and their opportunities, returns a list of email messages such that there is an email message for each opportunity 
	 * 		in which the opportunity owner is is the recepient, and all attachments related to the opportunity are attached to the email message.
	 *
	 * Pre-Condition: each opportunity in opportunities must include the OwnerId
	*/
/*	public static List<Messaging.Singleemailmessage> getEmailMessagesForAccountOwners(String emailTemplateToUse, List<Attachment> attachments, Map<ID, Opportunity> opptyMap){
		return getEmailMessages('OwnerID',emailTemplateToUse,attachments,opptyMap);
	}*/
	
	/* 
	 * Given a list of attachments and their opportunities, returns a list of email messages such that there 
	 * is an email message for each opportunity associated to at least one attachment such that:
	 * 		1) the recepient is the user specified in the given field
	 *		2) all attachments related to the opportunity are attached to the email message.
	 *		3) the email template of the email is emailTemplateName
	 *
	 * Pre-Condition: each opportunity in opportunities must include the specified user field.
	*/
	/*public static List<Messaging.Singleemailmessage> getEmailMessages(String userField, String emailTemplateName, List<Attachment> attachments, Map<ID, Opportunity> opptyMap)
	{
		Map<ID, Messaging.Singleemailmessage> opptyIDToEmailMessage = new Map<ID, Messaging.Singleemailmessage>();
		for(Attachment a : attachments)
		{
			Opportunity oppty = opptyMap.get(a.ParentID);
			ID recipientID = (ID) BluewolfDevUtils.getFieldValue(oppty,userField);
			if(recipientID!=null)
			{
				if(!opptyIDToEmailMessage.containsKey(a.ParentID))
				{
					Messaging.Singleemailmessage newlyCreatedEmailMsg = new Messaging.Singleemailmessage();
	 				newlyCreatedEmailMsg.setTargetObjectId(recipientID);
	 				newlyCreatedEmailMsg.setWhatId(oppty.Id);
	 				newlyCreatedEmailMsg.setTemplateID(devNameToEmailTemplate.get(emailTemplateName).ID);
	 				newlyCreatedEmailMsg.setSaveAsActivity(false);
	 				newlyCreatedEmailMsg.setFileAttachments(new List<Messaging.EmailFileAttachment>{createEmailAttachment(a)});
					opptyIDToEmailMessage.put(oppty.ID, newlyCreatedEmailMsg);
				}
				else
				{
					List<Messaging.EmailFileAttachment> efas = opptyIDToEmailMessage.get(a.ParentID).getFileAttachments();
					efas.add(createEmailAttachment(a));
					opptyIDToEmailMessage.get(a.ParentID).setFileAttachments(efas);
				}
			}
		}
		return opptyIDToEmailMessage.values();
	}*/
	
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
	//Commented MAT code 9/8/21
	/* Move the given attachments from the account to the relevant MAT Opportunity
	 *
	 * The relevant MAT Opportunity of an attachment is an opportunity such that:
	 * 1) It is on the account that matches the original ParentID of the attachment.
	 * 2) The MAT Unique ID that matches the Description field of the Attachment
	 *
	 * Exception Cases:
	 *    1) If for an attachment, there are no MAT Opportunities that meet the criteria, then
	          the error ERROR_MAT_OPPTY_NOT_FOUND will be shown for that attachment
	 *    2) If for an attachment, there are multiple MAT Opportunities that meet the critera, then
	 *		  the error ERROR_MULTIPLE_MAT_OPPTY will be shown for that attachment
	 *
	 * @param incomingAttachments the given attachments 
	 * @precondition all incomingAttachments must have a parentID that associates to an account 
	 * @return a map of those opportunities that will have attachments reassigned to them, 
	 	including the opportunity owner, and the manager of the opportunity owner.
	 	This function will return an empty map if there are errors
	 */
	/*public static Map<ID,Opportunity> moveAttachmentsWithMATOpptys(List<Attachment> incomingAttachments)
	{
		Set<Id> parentAccountIdsSet = pluck.ids('ParentId', incomingAttachments);
		Set<String> descriptionOnAttachments = pluck.strings('Description', incomingAttachments);
	
		List<Account> relatedAccounts = Database.query ('SELECT ID, (SELECT ID, MAT_Unique_ID__c, OwnerID, Owner.ManagerId FROM Opportunities WHERE MAT_Unique_ID__c IN: descriptionOnAttachments) FROM Account WHERE Id IN: parentAccountIdsSet');
		
		Map<Id, Map<String, List<Opportunity>>> accountIdToMATUniqueIdTopptys = new Map<Id, Map<String, List<Opportunity>>>();
		Map<ID, Opportunity> opptyMap = new Map<ID, Opportunity>();
		
        
		for(Account acct: relatedAccounts){
			if(acct.Opportunities != null && !acct.Opportunities.isEmpty()){
				accountIdToMATUniqueIdTopptys.put(acct.Id, groupBy.strings('MAT_Unique_ID__c', acct.Opportunities));
			}
		}
		
		for(Attachment attchmt: incomingAttachments){
			if(accountIdToMATUniqueIdTopptys.containsKey(attchmt.ParentId)){
				if(accountIdToMATUniqueIdTopptys.get(attchmt.ParentId).containsKey(attchmt.Description)){
					if(accountIdToMATUniqueIdTopptys.get(attchmt.ParentId).get(attchmt.Description).size() == 1){
						Opportunity associatedOppty = accountIdToMATUniqueIdTopptys.get(attchmt.ParentId).get(attchmt.Description)[0];
						attchmt.ParentId = associatedOppty.ID;
						opptyMap.put( associatedOppty.ID, associatedOppty);
					}else{
						attchmt.addError(ERROR_MULTIPLE_MAT_OPPTY);
						return new Map<ID,Opportunity>();
					}	
				}else{
					attchmt.addError(ERROR_MAT_OPPTY_NOT_FOUND);
					return new Map<ID,Opportunity>();
				}					
			}else{
				attchmt.addError(ERROR_MAT_OPPTY_NOT_FOUND);
				return new Map<ID,Opportunity>();
			}
		}
		
		return opptyMap;
	}
	*/
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
							//attach.ParentId = emailToCaseLookup.get(attach.ParentId);	
							
                            attachment at = new attachment();
                            at.Name = attach.name;
                               // at.IsPrivate = attach.IsPrivate;
                                at.Body= attach.Body;
                                at.Description = attach.Description;
                                at.ContentType = attach.ContentType;
                               // at.IsPartnerShared = attach.IsPartnerShared;
                            
                            
                            
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
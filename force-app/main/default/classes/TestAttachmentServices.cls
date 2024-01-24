@isTest
private class TestAttachmentServices {
	public final static String MAT_LEADSOURCE = 'Mat';
	public final static String NON_MAT_LEADSOURCE = 'nMat';
	
	public final static String MOCK_CREATEDDATE = 'BDR_Approval_Date__c'; 
	
	public static void setup()
	{
		AttachmentServices.createdDateField = MOCK_CREATEDDATE;
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        
		/*List<MAT_Opportunity_Default_Field_Values__c> customSettings = new List<MAT_Opportunity_Default_Field_Values__c>();
		customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='LeadSource',Default_Value__c=MAT_LEADSOURCE));
		customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Bid_Bond__c',Default_Value__c='false')); 
		insert customSettings;*/
	}

	public static void setupTaskCaseAttachments()
	{
		InactiveRecordTypes__c recordTypeForCaseTrigger = new InactiveRecordTypes__c(Name = 'eBusiness', Record_Type_Id__c = '012700000009YpU');
		insert recordTypeForCaseTrigger;

		Id recordTypeToReparent = [SELECT Id FROM RecordType WHERE Name='Console Case'].Id;

		UnitTest.addData(SObjectFactory.build(2, Case.sObjectType))
				.tag('All Cases')
				.branch('Case With Attachment | Case Without Attachment');

		UnitTest.get('Case With Attachment')
			.assign('RecordTypeId', recordTypeToReparent);

		UnitTest.get('All Cases').insertAll();

		UnitTest.addData(SObjectFactory.build(2, Task.sObjectType))
			.tag('All Tasks')
			.branch('Task To Reparent | Task To Not Reparent');

		UnitTest.get('Task To Reparent')
			.property('WhatId')
			.assignFrom('Case With Attachment');

		UnitTest.get('Task To Not Reparent')
			.property('WhatId')
			.assignFrom('Case Without Attachment');

		UnitTest.get('All Tasks').insertAll();

		UnitTest.addData(SObjectFactory.build(2, Attachment.sObjectType))
			.tag('All Attachments')
			.branch('Attachment To Reparent | Attachment To Not Reparent');

		UnitTest.get('Attachment To Reparent')
			.property('ParentId')
			.assignFrom('Task To Reparent')
			.assign('Name', 'reparent.txt')
			.assign('Body', Blob.valueOf('reparented'));

		UnitTest.get('Attachment To Not Reparent')
			.property('ParentId')
			.assignFrom('Task To Not Reparent')
			.assign('Name', 'test.txt')
			.assign('Body', Blob.valueOf('test'));
	}
	
	public static testMethod void testSendFSAuditEmailMessages()
	{
	//	EmailTemplate expectedEmailTemplateForOwner_DraftAttachment = [Select ID From EmailTemplate Where DeveloperName=:AttachmentServices.EMAIL_TEMPLATE_FOR_OWNER_DRAFT];
	//	EmailTemplate expectedEmailTemplateForOwner_FinalAttachment = [Select ID From EmailTemplate Where DeveloperName=:AttachmentServices.EMAIL_TEMPLATE_FOR_OWNER_FINAL];
		//EmailTemplate expectedEmailTemplateForManager_FinalAttachment = [Select ID From EmailTemplate Where DeveloperName=:AttachmentServices.EMAIL_TEMPLATE_FOR_OWNER_MANAGER];
		
		Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name =: 'Standard User' LIMIT 1]; 
		List<User> users = TestingUtils.createUsers('userName', testProfile.name, 20, false);
		UnitTest.addData(users).tag('Users').divide(2).part('Owners').part('Managers');
		UnitTest.get('Managers').insertAll();
		UnitTest.get('Owners').property('ManagerID').assignFrom('Managers');
		UnitTest.get('Owners').insertAll();
		
        system.runAs(users[0]){
            
       
		List<Account> accounts = TestingUtils.createAccounts('acctName', 10);
		UnitTest.addData(accounts).tag('Accounts').insertAll();
		
		List<Opportunity> opportunities = TestingUtils.createOpportunities(10, null, 'oppName', false);
		UnitTest.addData(opportunities).tag('All Opptys').property('AccountID').assignFrom('Accounts').divide(2)
									   .part('Opportunities For Sending Emails To Owner and Owner\'s Manager')
									   .part('Opportunities For Sending Emails To Just Owner');
		UnitTest.get('All Opptys').property('OwnerID').assignFrom('Owners').insertAll();
		
		UnitTest.forEach('Opportunities For Sending Emails To Owner and Owner\'s Manager')
				.create(2, TestingUtils.attachments).copyProperty('ID->ParentID').tag('Final FS Audit Attachments');
		UnitTest.forEach('Opportunities For Sending Emails To Just Owner')
				.create(2, TestingUtils.attachments).copyProperty('ID->ParentID').tag('Draft FS Audit Attachments');											 	
		
		Test.startTest();
			Map<ID, Opportunity> opptyMap = new Map<ID, Opportunity> ([Select ID, OwnerID, Owner.ManagerID From Opportunity Where ID IN:UnitTest.getIDs('All Opptys')]);
			List<Attachment> draftFSAuditAttachments = (List<Attachment>) UnitTest.get('Draft FS Audit Attachments').getList();
			List<Attachment> finalFSAuditAttachments = (List<Attachment>) UnitTest.get('Final FS Audit Attachments').getList();
			//List<Messaging.SingleEmailMessage> messages = AttachmentServices.sendFSAuditEmailMessages(draftFSAuditAttachments, finalFSAuditAttachments, opptyMap);
		//	System.assertEquals(1,Limits.getEmailInvocations(), 'An email must be sent');
		Test.stopTest();
		
		Map<ID, List<ID>> whatIDToEmailRecipients = new Map<ID, List<ID>>();
		/*for(Messaging.SingleEmailMessage message : messages)
		{
			System.assertNotEquals(null, message.getFileAttachments(), 'Incoming attachments must be attached to the emails that must be sent out');
			if(UnitTest.analyze('Opportunities For Sending Emails To Owner and Owner\'s Manager').hasID(message.getWhatID()))
			{
				if(UnitTest.analyze('Owners').hasId(message.getTargetObjectID()))
				{
					//System.assertEquals(expectedEmailTemplateForOwner_FinalAttachment.ID,message.getTemplateID(), 'Email messages must be sent to owners using the correct template');
				}
				else if(UnitTest.analyze('Managers').hasId(message.getTargetObjectID()))
				{
					//System.assertEquals(expectedEmailTemplateForManager_FinalAttachment.ID,message.getTemplateID(), 'Email messages must be sent to owners\'s managers using the correct template');
				}
				else
				{
					System.assert(false,'Email messages for final attachments may only be sent to owners or owners\'s managers');
				}
			}
			else
			{
				if(UnitTest.analyze('Owners').hasId(message.getTargetObjectID()))
				{
					//System.assertEquals(expectedEmailTemplateForOwner_DraftAttachment.ID,message.getTemplateID(), 'Email messages must be sent to owners using the correct template');
				}
				else
				{
					System.assert(false,'Email messages for draft attachments may only be sent to owners managers');
				}
			}
			
			Id actualWhatID = message.getWhatID();
			if(whatIDToEmailRecipients.containsKey(actualWhatID))
				whatIDToEmailRecipients.get(actualWhatID).add(message.getTargetObjectID());
			else
				whatIDToEmailRecipients.put(actualWhatID, new List<ID> {message.getTargetObjectID()});
		}
		*/
		//System.assertEquals(UnitTest.getIds('All Opptys'), whatIDToEmailRecipients.keySet(), 'Emails must only be associated to the opportunities related to the FS Audit Attachments');
		for(ID opptyID : whatIDToEmailRecipients.keySet())
		{
			if(UnitTest.analyze('Opportunities For Sending Emails To Owner and Owner\'s Manager').hasID(opptyID))
			{
				ID owner = (ID) UnitTest.analyze('All Opptys').selectByID(opptyID).getPropertyValue('OwnerID');
				ID ownerManager = (ID) UnitTest.analyze('Owners').selectByID(owner).getPropertyValue('ManagerID');
			//	System.assertEquals(2,whatIDToEmailRecipients.get(opptyID).size(), 'When an incoming final attachment is reparented to an opportunity, two emails must be sent out, one to the owner, and the other to the owner\'s manager');
				Set<ID> expectedRecipients = new Set<ID> {owner, ownerManager};
//System.assertEquals(expectedRecipients, new Set<ID> (whatIDToEmailRecipients.get(opptyID)), 'For incoming final FS audit attachment, emails must be sent to both the owner and the owner\'s manager');
			}
			else
			{
				ID owner = (ID) UnitTest.analyze('All Opptys').selectByID(opptyID).getPropertyValue('OwnerID');
				//System.assertEquals(1,whatIDToEmailRecipients.get(opptyID).size(), 'When an incoming final attachment is reparented to an opportunity, one email must be sent out to the owner');
				Set<ID> expectedRecipients = new Set<ID> {owner};
				//System.assertEquals(expectedRecipients,  new Set<ID> (whatIDToEmailRecipients.get(opptyID)), 'For incoming draft FS audit attachment, emails must be sent to just the owner');				
			}
		}
        }
	}
	
	
	public static testMethod void testGetEmailMessagesForOwners(){
		final Integer ATTACHMENTS_PER_OPP = 2;
		// Account Owner Creation:
		EmailTemplate expectedEmailTemplate = [Select DeveloperName From EmailTemplate Where DeveloperName= 'Customer_Quote_Template1'];
		Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name =: 'Standard User' LIMIT 1]; 
		List<User> users = TestingUtils.createUsers('userName', testProfile.name, 5, false);
		UnitTest.addData(users).tag('Owners');
		insert users;
        
        system.runAs(users[0]) {
            test.startTest();
		List<Account> accounts = TestingUtils.createAccounts('acctName', 10);
		UnitTest.addData(accounts).tag('All Accounts');
		insert accounts;
		
		List<Opportunity> opportunities = TestingUtils.createOpportunities(5, null, 'oppName', false);
		UnitTest.addData(opportunities).tag('All Opportunities').property('AccountId').assignFrom('All Accounts').property('OwnerID').assignFrom('Owners');
		insert opportunities;
		
		UnitTest.forEach('All Opportunities').create(ATTACHMENTS_PER_OPP, TestingUtils.attachments).copyProperty('ID->ParentID').tag('Attachments');
		
		List<Attachment> attachments = (List<Attachment>) UnitTest.get('Attachments').getList();
		Map<Object, Set<Object>> opptyIDToAttachmentNames = UnitTest.get('Attachments').extractPropertyValues('ParentID->Name');
		Map<Object, Object> attachmentNameToBlob = UnitTest.get('Attachments').extractMap('Name->Body');
		Map<Object, Object> attachmentNameToContentType = UnitTest.get('Attachments').extractMap('Name->ContentType');
		
		Map<ID, Opportunity> opptyMap = new Map<ID, Opportunity> ([SELECT Id, OwnerId From Opportunity WHERE Id IN: opportunities]);
		
		//Test.startTest();
		//	List<Messaging.Singleemailmessage> returnedEmailMessages = AttachmentServices.getEmailMessagesForAccountOwners(expectedEmailTemplate.DeveloperName,attachments,opptyMap);
		
		
		//System.assertEquals(UnitTest.get('All Opportunities').getList().size(), returnedEmailMessages.size(), 'For every opportunity associated to incoming attachments there should be an email message sent out to the opportunity owner');
		
		Set<Id> oppIds = UnitTest.getIds('All Opportunities');
		
		Set<Id> emailWhatIds = new Set<id>();
		Test.stopTest();
        }
		
		/*for(Messaging.Singleemailmessage emailMsg: returnedEmailMessages){
			 
			 emailWhatIds.add(emailMsg.getWhatId());
		}
		*/
		//System.assertEquals(emailWhatIds, oppIds, 'email messages that are being sent out should be linked to the right opportunities');
		
		
		/*for(Messaging.Singleemailmessage emailMsg: returnedEmailMessages){
			
			Id expectedRecipient = (Id) UnitTest.analyze('All Opportunities').selectById(emailMsg.getWhatID()).getPropertyValue('OwnerId');
			
			System.assertEquals(expectedRecipient, emailMsg.getTargetObjectId(), 'User who gets notified by the email should be the owner of the opportunity');
			System.assertEquals(expectedEmailTemplate.ID,emailMsg.getTemplateId(), 'Emails sent out to the opportunity owner must use the right template');
			List<Messaging.EmailFileAttachment> fileAttachments = emailMsg.getFileAttachments();
			System.assertEquals(ATTACHMENTS_PER_OPP, fileAttachments.size(), 'We must correctly the number of incoming attachments that are related to a particular opportunity for the email that gets sent to that opportunity\'s owner');
			Set<Object> encounteredAttachmentNames = new Set<Object>();
			for(Messaging.EmailFileAttachment att : fileAttachments)
			{
				encounteredAttachmentNames.add(att.getFileName());
			}
			System.assertEquals(opptyIDToAttachmentNames.get(emailMsg.getWhatId()),encounteredAttachmentNames, 'We must correctly attach incoming attachments that are related to a particular opportunity for the email that gets sent to that opportunity\'s owner');
			for(Messaging.EmailFileAttachment att : fileAttachments)
			{
				System.assertEquals(((Blob)attachmentNameToBlob.get(att.getFileName())).toString(), att.getBody().toString(), 'We must correctly attach incoming attachments that are related to a particular opportunity for the email that gets sent to that opportunity\'s owner');
				System.assertEquals(attachmentNameToContentType.get(att.getFileName()), att.getContentType(), 'We must correctly attach incoming attachments that are related to a particular opportunity for the email that gets sent to that opportunity\'s owner');
			}
		}
*/		
	}
	
	public static  testMethod void testGetEmailMessagesForOwnersManagers(){
		
		final Integer ATTACHMENTS_PER_OPP = 2;
		//ID expectedEmailTemplateID = [Select ID From EmailTemplate Where DeveloperName=:AttachmentServices.EMAIL_TEMPLATE_FOR_OWNER_MANAGER].ID;
		
		Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name =: 'Standard User' LIMIT 1]; 
		List<User> users = TestingUtils.createUsers('userName', testProfile.name, 5, false);
		UnitTest.addData(users).divide(2).part('Owners').part('Managers');
		UnitTest.get('Managers').insertAll();
		
		UnitTest.get('Owners').divide(2).part('Owners With Managers').part('Owners Without Managers');
		UnitTest.get('Owners With Managers').property('ManagerId').assignFrom('Managers');
		UnitTest.get('Owners').insertAll();
		
        system.runAs(users[0]){
            
        
        test.startTest();
		List<Account> accounts = TestingUtils.createAccounts('acctName', 5);
		UnitTest.addData(accounts).tag('All Accounts').insertAll();
		
		List<Opportunity> opportunities = TestingUtils.createOpportunities(10, null, 'oppName', false);
		UnitTest.addData(opportunities).tag('All Opportunities').property('AccountID').assignFrom('All Accounts').divide(2)
									   .part('Opportunities With Owners With Managers')
									   .part('Opportunities With Owners Without Managers');						   
									   
		UnitTest.get('Opportunities With Owners With Managers').property('OwnerId').assignFrom('Owners With Managers');
		UnitTest.get('Opportunities With Owners Without Managers').property('OwnerId').assignFrom('Owners Without Managers');
		insert opportunities;
		
		UnitTest.forEach('All Opportunities').create(ATTACHMENTS_PER_OPP, TestingUtils.attachments).copyProperty('ID->ParentID').tag('Attachments');
		
		List<Attachment> attachments = (List<Attachment>) UnitTest.get('Attachments').getList();
		Map<Object, Set<Object>> opptyIDToAttachmentNames = UnitTest.get('Attachments').extractPropertyValues('ParentID->Name');
		Map<Object, Object> attachmentNameToBlob = UnitTest.get('Attachments').extractMap('Name->Body');
		Map<Object, Object> attachmentNameToContentType = UnitTest.get('Attachments').extractMap('Name->ContentType');
		
		Map<ID, Opportunity> opptyMap = new Map<ID, Opportunity> ([SELECT Id, Owner.ManagerId From Opportunity WHERE Id IN: opportunities]);
		
		//Test.startTest();
			//List<Messaging.Singleemailmessage> returnedEmailMessages = AttachmentServices.getEmailMessagesForAccountOwnersManagers(attachments,opptyMap);
		Test.stopTest();
		
		//System.assertEquals(UnitTest.get('Opportunities With Owners With Managers').getList().size(), returnedEmailMessages.size(), 'For every opportunity there should be an email message sent out to the account owner\'s Manager');
		
		Set<Id> oppIds = UnitTest.getIds('Opportunities With Owners With Managers');
		Set<Id> emailWhatIds = new Set<id>();
        }
		/*for(Messaging.Singleemailmessage emailMsg: returnedEmailMessages){
			 
			 emailWhatIds.add(emailMsg.getWhatId());
		}*/
		
		//System.assertEquals(emailWhatIds, oppIds, 'email messages that are being sent out should be linked to the right opportunities');
		
		/*for(Messaging.Singleemailmessage emailMsg: returnedEmailMessages){
			
			Id expectedManagerId = (Id) UnitTest.analyze('All Opportunities').selectById(emailMsg.getWhatId()).traverse('OwnerId').getPropertyValue('ManagerId');
			System.assertEquals(expectedManagerId, emailMsg.getTargetObjectId(), 'User who gets notified by the email should be the corresponding owner\'s manager');
			//System.assertEquals(expectedEmailTemplateID,emailMsg.getTemplateId(), 'Emails sent out to the owner\'s manager must use the right template');
			List<Messaging.EmailFileAttachment> fileAttachments = emailMsg.getFileAttachments();
			System.assertEquals(ATTACHMENTS_PER_OPP, fileAttachments.size(), 'We must correctly the number of incoming attachments that are related to a particular opportunity for the email that gets sent to that opportunity\'s owner\'s manager');
			Set<Object> encounteredAttachmentNames = new Set<Object>();
			for(Messaging.EmailFileAttachment att : fileAttachments)
			{
				encounteredAttachmentNames.add(att.getFileName());
			}
			System.assertEquals(opptyIDToAttachmentNames.get(emailMsg.getWhatId()),encounteredAttachmentNames, 'We must correctly attach incoming attachments that are related to a particular opportunity for the email that gets sent to that opportunity\'s owner\'s manager');
			for(Messaging.EmailFileAttachment att : fileAttachments)
			{
				System.assertEquals(((Blob)attachmentNameToBlob.get(att.getFileName())).toString(), att.getBody().toString(), 'We must correctly attach incoming attachments that are related to a particular opportunity for the email that gets sent to that opportunity\'s owner\'s manager');
				System.assertEquals(attachmentNameToContentType.get(att.getFileName()), att.getContentType(), 'We must correctly attach incoming attachments that are related to a particular opportunity for the email that gets sent to that opportunity\'s owner\'s manager');
			}
		}*/
	}
	
	public static testMethod void testFilterDraftFSAuditAttachments(){
		
		List<Account> accounts = TestingUtils.createAccounts('acctName', 10);
		UnitTest.addData(accounts).tag('All Accounts');
		insert accounts;

		UnitTest.createTestData(TestingUtils.contacts).many(5).property('AccountID').assignFrom('All Accounts').tag('Contacts').insertAll();
		
		List<Attachment> attachments = (List<Attachment>) UnitTest.createTestData(testingUtils.attachments).many(10).property('ParentId').assignFrom('All Accounts').getList();
		List<String> validAttachmentNames = new List<String>{AttachmentServices.draftFSAuditAttachmentStartName + 'Test1', AttachmentServices.draftFSAuditAttachmentStartName , AttachmentServices.draftFSAuditAttachmentStartName + '   '};
		List<String> inValidAttachmentNames = new List<String>{'invalid' + AttachmentServices.draftFSAuditAttachmentStartName + 'Test1','*' +AttachmentServices.draftFSAuditAttachmentStartName , 'Test Invalid Name'};
		
		UnitTest.addData(attachments).tag('All Attachments').divide(2)
									 .part('Attachments that should pass the DraftFSAuditAttachments filter')
									 .part('Attachments that should not pass the DraftFSAuditAttachments filter');
		
		UnitTest.get('Attachments that should pass the DraftFSAuditAttachments filter').property('Name').assignFrom(validAttachmentNames).property('ParentID').assignFrom('All Accounts');

		UnitTest.get('Attachments that should not pass the DraftFSAuditAttachments filter').divide(2)
																						   .part('Attachment has valid name, but not on account')
																						   .part('Attachment is on account, but has invalid name');

		UnitTest.get('Attachment has valid name, but not on account').property('Name').assignFrom(validAttachmentNames).property('ParentID').assignFrom('Contacts');
		UnitTest.get('Attachment is on account, but has invalid name').property('Name').assignFrom(inValidAttachmentNames).property('ParentID').assignFrom('All Accounts');																			   	

		UnitTest.get('All Attachments').dummyInsert();
		
		test.startTest();
			List<Attachment> filteredAttachments = AttachmentServices.filterDraftFSAuditAttachments(attachments);
		test.stopTest();
		
		 UnitTest.analyze('Attachments that should pass the DraftFSAuditAttachments filter').assertEquivalence(filteredAttachments, 'incoming Draft FS Audit Attachments should be identified');
	}
	
	public static testMethod void testFilterFinalFSAuditAttachments(){
		
		List<Account> accounts = TestingUtils.createAccounts('acctName', 10);
		UnitTest.addData(accounts).tag('All Accounts');
		insert accounts;

		UnitTest.createTestData(TestingUtils.contacts).many(5).property('AccountID').assignFrom('All Accounts').tag('Contacts').insertAll();

		List<Attachment> attachments = (List<Attachment>) UnitTest.createTestData(testingUtils.attachments).many(10).property('ParentId').assignFrom('All Accounts').getList();
		List<String> validAttachmentNames = new List<String>{AttachmentServices.finalFSAuditAttachmentStartName + 'Test1', AttachmentServices.finalFSAuditAttachmentStartName , AttachmentServices.finalFSAuditAttachmentStartName + '   '};
		List<String> inValidAttachmentNames = new List<String>{'invalid' + AttachmentServices.finalFSAuditAttachmentStartName + 'Test1','*' +AttachmentServices.finalFSAuditAttachmentStartName , 'Test Invalid Name'};
		
		UnitTest.addData(attachments).tag('All Attachments').divide(2)
									 .part('Attachments that should pass the FinalFSAuditAttachments filter')
									 .part('Attachments that should not pass the FinalFSAuditAttachments filter');
		
		UnitTest.get('Attachments that should pass the FinalFSAuditAttachments filter').property('Name').assignFrom(validAttachmentNames).property('ParentID').assignFrom('All Accounts');
		UnitTest.get('Attachments that should not pass the FinalFSAuditAttachments filter').divide(2)
																						   .part('Attachment has valid name, but not on account')
																						   .part('Attachment is on account, but has invalid name');
		
		UnitTest.get('Attachment has valid name, but not on account').property('Name').assignFrom(validAttachmentNames).property('ParentID').assignFrom('Contacts');
		UnitTest.get('Attachment is on account, but has invalid name').property('Name').assignFrom(inValidAttachmentNames).property('ParentID').assignFrom('All Accounts');

		UnitTest.get('All Attachments').dummyInsert();
		
		test.startTest();
			List<Attachment> filteredAttachments = AttachmentServices.filterFinalFSAuditAttachments(attachments);
		test.stopTest();
		
		 UnitTest.analyze('Attachments that should pass the FinalFSAuditAttachments filter').assertEquivalence(filteredAttachments, 'incoming Final FS Audit Attachments should be identified');
	}
	/*
	public static testMethod void testMoveAttachmentsWithMATOpptys_NoOpptys()
	{
		setup();
		
		Account testAccount = TestingUtils.createAccount('A',true);
		
		Attachment att = TestingUtils.createAttachment(testAccount.ID);
		att.Description ='MATID';
		Test.startTest();
			Map<ID, Opportunity> retOpps = AttachmentServices.moveAttachmentsWithMATOpptys(new List<Attachment>{att});
		Test.stopTest();
		
		System.assert(TestingUtils.pageMessagesContains(AttachmentServices.ERROR_MAT_OPPTY_NOT_FOUND), 'Because at least one of the attachments is linked to an account that does not have a MAT Opportunity, we must get an error');
		//System.assertEquals(new Map<ID, Opportunity>(), retOpps, 'When there are errors, no opportunities are returned');
	} */
	/*If MAT_Unique_ID__c is not used this can be commented*/
	/*public static testMethod void testMoveAttachmentsWithMATOpptys_NoMatOpptysNoMatchingDescription()
	{
		setup();
		
		Account testAccount = TestingUtils.createAccount('A',true);
		List<String> MATUniqueIdsforAttachments = new List<String>{'MAT Test1', 'MAT test2'};
		List<String> MATUniqueIdsforOppty = new List<String>{'MAT Test3', 'MAT test1'};  
		
		List<Opportunity> opportunities = TestingUtils.createOpportunities(2, testAccount.Id, 'oppName', false);
		UnitTest.addData(opportunities).tag('All Opportunites').property('MAT_Unique_ID__c').assignFrom(MATUniqueIdsforOppty);
		insert opportunities;
		
		List<Attachment> attachments = TestingUtils.createAttachments(testAccount.Id, 2);
		UnitTest.addData(attachments).tag('All Attachments').property('Description').assignFrom(MATUniqueIdsforAttachments);
		
		Test.startTest();
			Map<ID, Opportunity> retOpps =  AttachmentServices.moveAttachmentsWithMATOpptys(attachments);
		Test.stopTest();
		
		//System.assert(TestingUtils.pageMessagesContains(AttachmentServices.ERROR_MAT_OPPTY_NOT_FOUND), 'Because at least one of the attachments is linked to an account that does not have a MAT Opportunity, we must get an error');
		//System.assertEquals(new Map<ID, Opportunity>(), retOpps, 'When there are errors, no opportunities are returned');
	}*/
	/* Commented MAt code 9/8/21
	public static testMethod void testMoveAttachmentsWithMATOpptys_MultipleMatches()
	{
		setup();
		
		String sampleUniqueID = 'TEST';
				
		UnitTest.addData(TestingUtils.createAccounts('Test',20)).tag('All Accounts').insertAll(); 
		UnitTest.forEach('All Accounts').create(2,TestingUtils.opportunities).copyProperty('ID->AccountID').tag('All Opportunities');
		UnitTest.get('All Opportunities').property('MAT_Unique_ID__c').assign(sampleUniqueID).insertAll();
		UnitTest.forEach('All Opportunities').create(2,TestingUtils.attachments)
											 .copyProperty('AccountID->ParentID')
											 .copyProperty('MAT_Unique_ID__c->Description')
											 .tag('Incoming Attachments');
											 
		List<Attachment> incomingAttachments = (List<Attachment>) UnitTest.get('Incoming Attachments').getList();
		
		Test.startTest();
			//Map<ID, Opportunity> retOpps = AttachmentServices.moveAttachmentsWithMATOpptys(incomingAttachments);
		Test.stopTest();
		
		//System.assert(TestingUtils.pageMessagesContains(AttachmentServices.ERROR_MULTIPLE_MAT_OPPTY), 'Because at least one of the attachments is linked to an account that has multiple MAT Opportunity with the same unique MAT ID, we must get an error');							 
		//System.assertEquals(new Map<ID, Opportunity>(), retOpps, 'When there are errors, no opportunities are returned');	
	}
*/
	/* Commented MAT code 9/8/21
	 public static testMethod void testMoveAttachmentsWithMATOpptys()
	{
		setup();
		
		Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name =: 'Standard User' LIMIT 1]; 
		List<User> users = TestingUtils.createUsers('userName', testProfile.name, 100, false);
		UnitTest.addData(users).divide(2).part('Owners').part('Managers');
		UnitTest.get('Managers').insertAll();
		
		UnitTest.get('Owners').divide(2).part('Owners With Managers').part('Owners Without Managers');
		UnitTest.get('Owners With Managers').property('ManagerId').assignFrom('Managers');
		UnitTest.get('Owners').insertAll();
				
		UnitTest.addData(TestingUtils.createAccounts('Test',20)).tag('All Accounts').insertAll(); 
		
		String MAT_UNIQUE_ID1 = 'TEST1';
		String MAT_UNIQUE_ID2 = 'TEST2';
		
		UnitTest.forEach('All Accounts').create(1,TestingUtils.opportunities).copyProperty('ID->AccountID').tag('Opptys With MAT Unique ID 1');
		UnitTest.forEach('All Accounts').create(1,TestingUtils.opportunities).copyProperty('ID->AccountID').tag('Opptys With MAT Unique ID 2');
		UnitTest.forEach('All Accounts').create(1,TestingUtils.opportunities).copyProperty('ID->AccountID').tag('Other Opptys');
				
		UnitTest.get('Opptys With MAT Unique ID 1').property('MAT_Unique_ID__c').assign(MAT_UNIQUE_ID1).tag('Opptys With MAT Unique ID');
		UnitTest.get('Opptys With MAT Unique ID 2').property('MAT_Unique_ID__c').assign(MAT_UNIQUE_ID2).tag('Opptys With MAT Unique ID');
		UnitTest.get(Opportunity.SObjectType).property('OwnerID').assignFrom('Owners').insertAll();
		
		UnitTest.forEach('Opptys With MAT Unique ID').create(2,TestingUtils.attachments)
													 .copyProperty('AccountID->ParentID')
													 .copyProperty('MAT_Unique_ID__c->Description')
													 .copyProperty('ID->*Opportunity With Matching Unique ID*')
													 .tag('Incoming Attachments');
		
		List<Attachment> incomingAttachments = (List<Attachment>) UnitTest.get('Incoming Attachments').getList();
		
		Test.startTest();
			Map<ID, Opportunity> opptyMap = AttachmentServices.moveAttachmentsWithMATOpptys(incomingAttachments);
		Test.stopTest();
		
		UnitTest.get('Incoming Attachments').dummyInsert();
		
		for(Attachment att : incomingAttachments)
		{
			ID expectedNewParentID = (ID) UnitTest.analyze('Incoming Attachments').selectByID(att.ID).getPropertyValue('*Opportunity With Matching Unique ID*');
			//System.assertEquals(expectedNewParentID,att.ParentID, 'Each attachment must be moved over to the MAT opportunity on the account that has the same MAT_Unique_ID__c as the attachment\'s description');
		}
		
		//System.assertEquals(UnitTest.getIds('Opptys With MAT Unique ID'),opptyMap.keySet(), 'All opportunities with a MAT Unique ID must be identified');
		for(Opportunity opp : opptyMap.values())
		{
			ID expectedOwner = (ID) UnitTest.analyze('Opptys With MAT Unique ID').selectByID(opp.ID).getPropertyValue('OwnerID');
			ID expectedManagerOwner = (ID) UnitTest.analyze('Opptys With MAT Unique ID').selectByID(opp.ID).traverse('OwnerID').getPropertyValue('ManagerID');
			//System.assertEquals(expectedOwner,opp.OwnerID, 'All opportunities with a MAT Unique ID must be identified along with their owners');
			//System.assertEquals(expectedManagerOwner,opp.Owner.ManagerID, 'All opportunities with a MAT Unique ID must be identified along with the managers of their owners');
		}
	}
	*/
	public static void setupAccountsAndQuotes()
	{
		ID customerRecordType = [Select ID From RecordType Where DeveloperName='Customer' And SObjectType='Account' And IsActive = True].ID;
		
		UnitTest.addData(TestingUtils.createAccounts('Test Account',10)).tag('Accounts').assign('RecordTypeID',customerRecordType).insertAll();
		UnitTest.addData(TestingUtils.createQuotes(20,null,false)).tag('All Quotes').property('Account__c').assignFrom('Accounts').insertAll();
	}
	
	public static testMethod void testFilterAttachmentsAssociatedToQuotes()
	{
		setupAccountsAndQuotes();
		
		UnitTest.createTestData(TestingUtils.attachments).many(10).tag('All Attachments').divide(2).part('Attachments Not Associated With Quotes').part('Attachments Associated With Quotes');
		UnitTest.get('Attachments Not Associated With Quotes').property('ParentID').assignFrom('Accounts');
		UnitTest.get('Attachments Associated With Quotes').property('ParentID').assignFrom('All Quotes');
		UnitTest.get('All Attachments').dummyInsert();
		
		Test.startTest();
			List<Attachment> allAttachments = (List<Attachment>) UnitTest.get('All Attachments').getList();
			List<Attachment> filteredAttachments = AttachmentServices.filterAttachmentsAssociatedToQuotes(allAttachments);
		Test.stopTest();
		
		UnitTest.analyze('Attachments Associated With Quotes').assertEquivalence(filteredAttachments, 'Only attachments associated with quotes should be selected for creating Quote PDFs');
	}
	
	public static testMethod void testCreateQuotePDFs()
	{
		setupAccountsAndQuotes();
		
		List<String> sampleAttachmentNames = new List<String> {'Sample Name 1', 'Sample Name 2','Sample Name 3','Sample Name 4','Sample Name 5','Sample Name 6'};
		UnitTest.forEach('All Quotes').create(10,TestingUtils.attachments).copyProperty('ID->ParentID').copyProperty('Account__c->*Account ID of Parent Quote*').tag('Attachment');
		UnitTest.get('Attachment').property('Name').assignFrom(sampleAttachmentNames).dummyInsert();
		
		Test.startTest();
			List<Attachment> allAttachments = (List<Attachment>) UnitTest.get('Attachment').getList();
			List<Quote_PDF__c> quotePdfs = AttachmentServices.createQuotePDFs(allAttachments);
		Test.stopTest();
		
		//System.assertEquals(quotePdfs.size(),allAttachments.size(), 'We expect to create as many Quote PDFs as there are attachments that are associated to quotes');
		//System.assertEquals(Pluck.strings('Attachment_ID__c', quotePdfs), Pluck.strings('ID', allAttachments), 'We expect to create one and only one quote pdf for every attachment that is associated to a quote');
		for(Quote_PDF__c qPDF : quotePdfs)
		{
			ID expectedAccountID = (ID) UnitTest.analyze('Attachment').selectByID(qPDF.Attachment_ID__c).getPropertyValue('*Account ID of Parent Quote*');
			ID expectedQuoteID = (ID) UnitTest.analyze('Attachment').selectByID(qPDF.Attachment_ID__c).getPropertyValue('ParentID');
			String expectedName = (String) UnitTest.analyze('Attachment').selectByID(qPDF.Attachment_ID__c).getPropertyValue('Name');
			
			//System.assertEquals(expectedAccountID,qPDF.Account__c, 'For each quote pdf, the account__c field should be populated with the account of the attachment\'s quote');
			//System.assertEquals(expectedQuoteID,qPDF.Quote__c, 'For each quote pdf, the quote__c field should be populated with the quote of the attachment');
			//System.assertEquals(expectedName,qPDF.File_Name__c, 'For each quote pdf, the File_Name__c field should be populated with the name of the attachment');
		}
	}

	private static testMethod void testFilterAttachmentsToBeParentedToCase()
	{
		setupTaskCaseAttachments();

		Test.startTest();
			Map<Id, List<Attachment>> caseIdToAttachments = AttachmentServices.getCaseReparentMap(UnitTest.get('All Attachments').getList());
		Test.stopTest();

		for(Id returnedCaseId : caseIdToAttachments.keySet())
		{
			//System.assertEquals(UnitTest.get('Case With Attachment').getList()[0].Id, returnedCaseId, 'We expect the proper case to be returned in the map');
			for(Attachment returnedAttachment : caseIdToAttachments.get(returnedCaseId))
			{
			//	System.assertEquals((Attachment) UnitTest.get('Attachment To Reparent').getList()[0], returnedAttachment, 'We expect the proper attachment to be returned in the map');
			}
		}
	}

	private static testMethod void testReparentAttachmentsToCasesMethod()
	{
		setupTaskCaseAttachments();
		Attachment attToBeReparented = (Attachment) UnitTest.get('Attachment To Reparent').getList()[0];
		Case caseToBeParent = (Case) UnitTest.get('Case With Attachment').getList()[0];

		Test.startTest();
			AttachmentServices.reparentAttachments(
				new Map<Id, List<Attachment>>{ caseToBeParent.Id => new List<Attachment>{attToBeReparented}});
		Test.stopTest();

		//System.assertEquals(caseToBeParent.Id, attToBeReparented.ParentId, 'We expect the parent id on the attachment to be changed');
	}
	
}
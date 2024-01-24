@isTest
private class TestFileAttachmentController
{
	static Account testAccount;
	static Servicing_Division__c  testServicingDivision;
	static Opportunity testOpportunity;
	static Contract existingContractForAccount;
	static String documentType;
	static final String documentTypeAbbr = 'Prefix';
	static final String fileName = 'TestFile.pdf';
	static final String expectedFileName = documentTypeAbbr + fileName;

	
	static void setup(Boolean variesByOpportunity)
	{
		documentType =  (new List<String>(ContractFileManagementCtrl.POSSIBLE_DOCUMENT_TYPES))[0];
		FAP_Specification__c aDocType = TestingUtils.createFAPSpecification(documentType, new Map<String,Object> {'Attachment_Prefix__c'=>documentTypeAbbr,'File_Varies_by_Opp__c'=>variesByOpportunity}, true);

		testServicingDivision = TestingUtils.createServicingDivision( true );
		testAccount = TestingUtils.createAccount( 'TestAccount', false );
		testAccount.Servicing_Division__c = testServicingDivision.ID;
		insert testAccount;
		testOpportunity = TestingUtils.createOpportunity( testAccount.Id, 'TestOpp', true );
	}
	
	private static testMethod void testAttachFile_NewContract_AttachToAccount()
	{
		setup(ContractFileManagementCtrl.FILE_ON_ACCOUNT);
		Blob bodyOfAttachment = Blob.valueOf( 'Some important attachment' );
		
		FileAttachmentController controller = setupControllerForNewContract(bodyOfAttachment);
		
		Test.startTest();
			controller.attachFile();
		Test.stopTest();
		
		System.assertEquals( true, ApexPages.hasMessages(), 'There should be a page messages on success: ' + ApexPages.getMessages() );
		System.assertEquals( ApexPages.Severity.CONFIRM, ApexPages.getMessages()[0].getSeverity(), 'There should be a confirm page messages on success: ' + ApexPages.getMessages() );
		
		List<Contract> newContracts = [ SELECT Opportunity__c, AccountId, Document_Type__c, Division__c, 
											( SELECT Id, ParentId, Name FROM Attachments) 
											FROM Contract];
		
		System.assertEquals( 1, newContracts.size(), 'There should be one new contract created ' );									
		System.assertEquals( testAccount.Id, newContracts[0].AccountId, 'The new contract should be linked to the right account.' );
		System.assertEquals( null, newContracts[0].Opportunity__c, 'The new contract should not be linked to an opportunity' );
		System.assertEquals( testServicingDivision.Id, newContracts[0].Division__c, 'The new contract should have the same servicing division as that of its account.' );
		System.assertEquals( documentType, newContracts[0].Document_Type__c, 'The new contract should have the specified document type' );
		
		System.assertEquals( 1, newContracts[0].Attachments.size(), 'There should be one new attachment created ' + newContracts[0].Attachments );
		
		Attachment attachedFile = [Select ID, Name, Body From Attachment WHERE ParentId=:newContracts[0].ID]; //Need to do this query seperately to get Body
		
		System.assertEquals( expectedFileName, attachedFile.Name, 'The attachment that is created should have the prefix added to its name' );	
		System.assertEquals(bodyOfAttachment.toString(), attachedFile.Body.toString(),'The attachment body should be updated to reflect the new attachment');
	}
	
	private static FileAttachmentController setupControllerForNewContract(Blob bodyOfAttachment)
	{
		FileAttachmentController controller = new FileAttachmentController();
		controller.accountId = testAccount.Id;
		controller.opportunityId = testOpportunity.Id;
		controller.divisionId = testServicingDivision.Id;
		controller.attachType = documentType;
		controller.existingContractId = null;
		controller.existingAttachmentId = null;
		
		controller.attachment.Name = fileName;
		controller.attachment.Body = bodyOfAttachment; 
		return controller;
	}
	
	private static testMethod void testAttachFile_NewContract()
	{
		setup(ContractFileManagementCtrl.FILE_ON_OPPORTUNITY);
		Blob bodyOfAttachment = Blob.valueOf( 'Some important attachment' );
		FileAttachmentController controller = setupControllerForNewContract(bodyOfAttachment);
		
		Test.startTest();
			controller.attachFile();
		Test.stopTest();
		
		System.assertEquals( true, ApexPages.hasMessages(), 'There should be a page messages on success: ' + ApexPages.getMessages() );
		System.assertEquals( ApexPages.Severity.CONFIRM, ApexPages.getMessages()[0].getSeverity(), 'There should be a confirm page messages on success: ' + ApexPages.getMessages() );
		
		List<Contract> newContracts = [ SELECT Opportunity__c, AccountId, Document_Type__c, Division__c, 
											( SELECT Id, ParentId, Name FROM Attachments) 
											FROM Contract];
		
		System.assertEquals( 1, newContracts.size(), 'There should be one new contract created ' );									
		System.assertEquals( testAccount.Id, newContracts[0].AccountId, 'The new contract should be linked to the right account.' );
		System.assertEquals( testOpportunity.Id, newContracts[0].Opportunity__c, 'The new contract should be linked to the right opportunity.' );
		System.assertEquals( testServicingDivision.Id, newContracts[0].Division__c, 'The new contract should have the same servicing division as that of its account.' );
		System.assertEquals( documentType, newContracts[0].Document_Type__c, 'The new contract should have the specified document type' );
		
		System.assertEquals( 1, newContracts[0].Attachments.size(), 'There should be one new attachment created ' + newContracts[0].Attachments );
		
		Attachment attachedFile = [Select ID, Name, Body From Attachment WHERE ParentId=:newContracts[0].ID]; //Need to do this query seperately to get Body
		
		System.assertEquals( expectedFileName, attachedFile.Name, 'The attachment that is created should have the prefix added to its name' );	
		System.assertEquals(bodyOfAttachment.toString(), attachedFile.Body.toString(),'The attachment body should be updated to reflect the new attachment');	
											
	}
	
	private static testMethod void testAttachFile_ExistingContract()
	{
		final Blob newAttachmentBody = Blob.valueOf( 'Some important attachment' );
		setup(ContractFileManagementCtrl.FILE_ON_OPPORTUNITY);
		Contract testContract = TestingUtils.createContract( testAccount.ID, testAccount.Servicing_Division__c, false );
		testContract.Document_Type__c = documentType;
		testContract.Opportunity__c = testOpportunity.Id;
		insert testContract;
		
		Attachment testOldAttachment = new Attachment();
		testOldAttachment.Name = 'TestAttachment';
		testOldAttachment.Body = blob.valueOf( 'test Attachment body' );
		testOldAttachment.ParentId = testContract.Id;
		insert testOldAttachment;
		
		FileAttachmentController controller = new FileAttachmentController();
		controller.existingContractId = testContract.Id;
		controller.existingAttachmentId = testOldAttachment.Id;
		controller.attachType = documentType;
		
		controller.attachment.Name = fileName;
		controller.attachment.Body = newAttachmentBody;
		Test.startTest();
			controller.attachFile();
		Test.stopTest();
		
		System.assertEquals( true, ApexPages.hasMessages(), 'There should be a confirm page messages on success: ' + ApexPages.getMessages() );
		System.assertEquals( ApexPages.Severity.CONFIRM, ApexPages.getMessages()[0].getSeverity(), 'There should be a confirm page messages on success: ' + ApexPages.getMessages() );
		List<Contract> contracts = [ SELECT Opportunity__c, AccountId, Document_Type__c, Division__c, 
											( SELECT Id, ParentId, Name FROM Attachments) 
											FROM Contract];
											
		
		System.assertEquals( 1, contracts.size(), 'There should be only be one contract' );									
		System.assertEquals( testContract.Id, contracts[0].Id, 'The only contract that exists is the one that existed before. No new contracts should have been created or deleted' );
		System.assertEquals( testAccount.Id, contracts[0].AccountId, 'The contract should still lookup to the right account' );
		System.assertEquals( testOpportunity.Id, contracts[0].Opportunity__c, 'The contract should still lookup to the right opportunity' );
		System.assertEquals( testServicingDivision.Id, contracts[0].Division__c, 'The contract should still lookup to the right servicing division.' );
		System.assertEquals( documentType, contracts[0].Document_Type__c, 'The contract should still have the same document type' );
		
		System.assertEquals( 1, contracts[0].Attachments.size(), 'There should only be one attachment associated to the contract ' + contracts[0].Attachments);
		
		Attachment attachedFile = [Select ID, Name, Body From Attachment WHERE ParentId=:contracts[0].ID]; //Need to do this query seperately to get Body
		
		System.assertEquals( testOldAttachment.Id, attachedFile.Id, 'The attachment id should be the same' );
		System.assertEquals( expectedFileName, attachedFile.Name, 'The attachment name should change to that of the prefix+new attachment name' );		
		System.assertEquals(newAttachmentBody.toString(), attachedFile.Body.toString(),'The attachment body should be updated to reflect the new attachment');			
	}
	
	private static testMethod void testAttachFile_ExistingContractButNoExistingAttachment() {
		final Blob newAttachmentBody = Blob.valueOf( 'Some important attachment' );
		setup(ContractFileManagementCtrl.FILE_ON_OPPORTUNITY);
		Contract testContract = TestingUtils.createContract( testAccount.ID, testAccount.Servicing_Division__c, false );
		testContract.Document_Type__c = documentType;
		testContract.Opportunity__c = testOpportunity.Id;
		insert testContract;
		
		FileAttachmentController controller = new FileAttachmentController();
		controller.existingContractId = testContract.Id;
		controller.existingAttachmentId = null;
		controller.attachType = documentType;
		
		controller.attachment.Name = fileName;
		controller.attachment.Body = newAttachmentBody;
		Test.startTest();
			controller.attachFile();
		Test.stopTest();
		
		System.assertEquals( true, ApexPages.hasMessages(), 'There should be a confirm page messages on success: ' + ApexPages.getMessages() );
		System.assertEquals( ApexPages.Severity.CONFIRM, ApexPages.getMessages()[0].getSeverity(), 'There should be a confirm page messages on success: ' + ApexPages.getMessages() );
		List<Contract> contracts = [ SELECT Opportunity__c, AccountId, Document_Type__c, Division__c, 
											( SELECT Id, ParentId, Name FROM Attachments) 
											FROM Contract];
											
		
		System.assertEquals( 1, contracts.size(), 'There should be only be one contract' );									
		System.assertEquals( testContract.Id, contracts[0].Id, 'The only contract that exists is the one that existed before. No new contracts should have been created or deleted' );
		System.assertEquals( testAccount.Id, contracts[0].AccountId, 'The contract should still lookup to the right account' );
		System.assertEquals( testOpportunity.Id, contracts[0].Opportunity__c, 'The contract should still lookup to the right opportunity' );
		System.assertEquals( testServicingDivision.Id, contracts[0].Division__c, 'The contract should still lookup to the right servicing division.' );
		System.assertEquals( documentType, contracts[0].Document_Type__c, 'The contract should still have the same document type' );
		
		System.assertEquals( 1, contracts[0].Attachments.size(), 'There should only be one attachment associated to the contract ' + contracts[0].Attachments);
		
		Attachment attachedFile = [Select ID, Name, Body From Attachment WHERE ParentId=:contracts[0].ID]; //Need to do this query seperately to get Body
		
		System.assertEquals( expectedFileName, attachedFile.Name, 'The attachment name should change to that of the prefix+new attachment name' );		
		System.assertEquals(newAttachmentBody.toString(), attachedFile.Body.toString(),'The attachment body should be updated to reflect the new attachment');	
		
	}
}
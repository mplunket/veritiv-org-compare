@isTest
private class TestAttachmentServices {
  public final static String MAT_LEADSOURCE = 'Mat';
  public final static String NON_MAT_LEADSOURCE = 'nMat';
  
  public final static String MOCK_CREATEDDATE = 'BDR_Approval_Date__c'; 
  
  public static void setup()
  {
    AttachmentServices.createdDateField = MOCK_CREATEDDATE;
     
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
       
    Test.stopTest();
    
    Map<ID, List<ID>> whatIDToEmailRecipients = new Map<ID, List<ID>>();
    
    for(ID opptyID : whatIDToEmailRecipients.keySet())
    {
      if(UnitTest.analyze('Opportunities For Sending Emails To Owner and Owner\'s Manager').hasID(opptyID))
      {
        ID owner = (ID) UnitTest.analyze('All Opptys').selectByID(opptyID).getPropertyValue('OwnerID');
        ID ownerManager = (ID) UnitTest.analyze('Owners').selectByID(owner).getPropertyValue('ManagerID');
         Set<ID> expectedRecipients = new Set<ID> {owner, ownerManager};
       }
      else
      {
        ID owner = (ID) UnitTest.analyze('All Opptys').selectByID(opptyID).getPropertyValue('OwnerID');
         Set<ID> expectedRecipients = new Set<ID> {owner};
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
    
    
    Set<Id> oppIds = UnitTest.getIds('All Opportunities');
    
    Set<Id> emailWhatIds = new Set<id>();
    Test.stopTest();
        }
    
    
  }
  
  public static  testMethod void testGetEmailMessagesForOwnersManagers(){
    
    final Integer ATTACHMENTS_PER_OPP = 2;
    
    
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
    
    
    Test.stopTest();
    
    
    
    Set<Id> oppIds = UnitTest.getIds('Opportunities With Owners With Managers');
    Set<Id> emailWhatIds = new Set<id>();
        }

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
    
   
    for(Quote_PDF__c qPDF : quotePdfs)
    {
      ID expectedAccountID = (ID) UnitTest.analyze('Attachment').selectByID(qPDF.Attachment_ID__c).getPropertyValue('*Account ID of Parent Quote*');
      ID expectedQuoteID = (ID) UnitTest.analyze('Attachment').selectByID(qPDF.Attachment_ID__c).getPropertyValue('ParentID');
      String expectedName = (String) UnitTest.analyze('Attachment').selectByID(qPDF.Attachment_ID__c).getPropertyValue('Name');
      
   
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
      for(Attachment returnedAttachment : caseIdToAttachments.get(returnedCaseId))
      {
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

  }
  
}
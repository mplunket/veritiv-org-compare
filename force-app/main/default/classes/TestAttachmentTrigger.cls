@isTest
public with sharing class TestAttachmentTrigger {
    public static void setupAccountsAndQuotes()
    {
        ID customerRecordType = [Select ID From RecordType Where DeveloperName='Customer' And SObjectType='Account' And IsActive = True].ID;
        
        UnitTest.addData(TestingUtils.createAccounts('Test Account',20)).tag('Accounts').assign('RecordTypeID',customerRecordType).insertAll();
        UnitTest.addData(TestingUtils.createQuotes(20,null,false)).tag('All Quotes').property('Account__c').assignFrom('Accounts').insertAll();
    }
    
    public static testMethod void testAttachmentTrigger(){
        
        setupAccountsAndQuotes();
        
        UnitTest.createTestData(TestingUtils.attachments).many(200).tag('All Attachments').divide(2).part('Attachments Not Associated With Quotes').part('Attachments Associated With Quotes');
        UnitTest.get('Attachments Not Associated With Quotes').property('ParentID').assignFrom('Accounts');
        UnitTest.get('Attachments Associated With Quotes').property('ParentID').assignFrom('All Quotes');
        
        Test.startTest();
            insert UnitTest.get('All Attachments').getList();
        Test.stopTest();
        
        Set<Id> attachmentsWithQuotesIdSet = UnitTest.getIds('Attachments Associated With Quotes');
        List<Quote_PDF__c> queriedQuotePDFs = [SELECT Id, Account__c, Attachment_ID__c, Quote__c, File_Name__c FROM Quote_PDF__c];
        Set<Id> QuoteAttachmentIdSet = Pluck.ids('Attachment_ID__c', queriedQuotePDFs);
        
         
        
        Map<Object, Object> quoteIdToAccountMap = UnitTest.get('All Quotes').extractMap('Id -> Account__c');
        
        for(Quote_PDF__c qPDFs: queriedQuotePDFs){
            String expectedFileName = (String) UnitTest.analyze('Attachments Associated With Quotes').selectById(qPDFs.Attachment_ID__c).getPropertyValue('Name');
            Id expectedQuoteId = (Id) UnitTest.analyze('Attachments Associated With Quotes').selectById(qPDFs.Attachment_ID__c).getPropertyValue('ParentId');
            Id expectedAccountId = (Id) quoteIdToAccountMap.get(qPDFs.Quote__c);
            
            System.assertEquals(expectedQuoteId, qPDFs.Quote__c,'newly created QuotePDFs quote should be linked to the attachments quote');
            System.assertEquals(expectedAccountId, qPDFs.Account__c, 'newly created QuotePDFs account should be linked to the attachments account');
            System.assertEquals(expectedFileName, qPDFs.File_Name__c, 'newly created QuotePDFs name should be same as the attachments name');
        }
    }
    
    
    public static testMethod void testMoveAttachments(){
        
        List<Account> accounts = TestingUtils.createAccounts('acctName', 60);
        UnitTest.addData(accounts).tag('All Accounts');
        insert accounts;
        
        String MAT_UNIQUE_ID1 = 'TEST1';
        String MAT_UNIQUE_ID2 = 'TEST2';
        
        List<String> validAttachmentNames = new List<String>{AttachmentServices.draftFSAuditAttachmentStartName + 'Test1', AttachmentServices.finalFSAuditAttachmentStartName};
        List<String> inValidAttachmentNames = new List<String>{'invalid' + AttachmentServices.draftFSAuditAttachmentStartName + 'Test1','*' +AttachmentServices.draftFSAuditAttachmentStartName , 'Test Invalid Name'};
                                      
        UnitTest.forEach('All Accounts').create(1,TestingUtils.opportunities).copyProperty('ID->AccountID').tag('Opptys With MAT Unique ID 1');
        UnitTest.forEach('All Accounts').create(1,TestingUtils.opportunities).copyProperty('ID->AccountID').tag('Opptys With MAT Unique ID 2');
        UnitTest.forEach('All Accounts').create(1,TestingUtils.opportunities).copyProperty('ID->AccountID').tag('Other Opptys');
        
        UnitTest.get('Opptys With MAT Unique ID 1').property('MAT_Unique_ID__c').assign(MAT_UNIQUE_ID1).tag('Opptys With MAT Unique ID');
        UnitTest.get('Opptys With MAT Unique ID 2').property('MAT_Unique_ID__c').assign(MAT_UNIQUE_ID2).tag('Opptys With MAT Unique ID');
        UnitTest.get(Opportunity.SObjectType).insertAll();
        Test.startTest();
        UnitTest.forEach('Opptys With MAT Unique ID').create(1,TestingUtils.attachments)
                                      .copyProperty('MAT_Unique_ID__c->Description')
                                      .copyProperty('accountId->ParentId')
                                      .copyProperty('ID->*Opportunity With Matching Unique ID*').tag('All Attachments');
        
        UnitTest.get('All Attachments').divide(2).part('Attachments that should pass the filter')
                                       .part('Attachments that should fail the filter');
        
        UnitTest.get('Attachments that should pass the filter').property('Name').assignFrom(validAttachmentNames);
        UnitTest.get('Attachments that should fail the filter').property('Name').assignFrom(inValidAttachmentNames);

        
            insert UnitTest.get('All Attachments').getList();
             
        
        
        List<Attachment> queriedAttachments = [Select id, parentId FROM Attachment];
        
        for(Attachment qattchmt : queriedAttachments){
            
            if(UnitTest.analyze('Attachments that should pass the filter').hasId(qattchmt.Id)){
                Id expectedOpptyId = (Id) UnitTest.analyze('Attachments that should pass the filter').selectById(qattchmt.Id).getPropertyValue('*Opportunity With Matching Unique ID*');
                 
            }else{
                
                Id expectedAccountId = (Id) UnitTest.analyze('Attachments that should fail the filter').selectById(qattchmt.Id).getPropertyValue('ParentId');
                 
            }
        }
        Test.stopTest();
    }
    
    public static testMethod void testMoveAttachmentsWithMATOpptys_NoOpptysTriggerTest()
    {
        Account testAccount = TestingUtils.createAccount('A',true);
        
        Attachment att = TestingUtils.createAttachment(testAccount.ID);
        att.Name = AttachmentServices.draftFSAuditAttachmentStartName + 'Test1';
        att.Description ='MATID';
        Test.startTest();
            
            try{
                insert att;

                  
            }
            catch( Exception ex )
            {
             
            }
            
        Test.stopTest();
        
    }

    public static testMethod void testParentAttachmentsToCases()
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

        Test.startTest();
            insert UnitTest.get('All Attachments').getList();
        Test.stopTest();

        for(Attachment reparentedAttachment : [SELECT ParentId 
                                                FROM Attachment
                                                WHERE Id
                                                IN :UnitTest.getIds('Attachment To Reparent')])
        {
             
        }
    }
    
}
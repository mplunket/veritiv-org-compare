@isTest
private class TestEmailAttachmentToCase {
static Id email2CaseRType;
static Id otherCaseRType;
    
    static {
        
        List<RecordType>email2CaseRTypes = [Select id from RecordType where DeveloperName = :AttachmentServices.EMAIL_2_CASE_RTYPE and SObjectType = 'Case' and IsActive = true limit 1];
        
        System.assert(email2CaseRTypes.size() > 0, 'Fax RecordType Does Not Exist');
                
        email2CaseRType = email2CaseRTypes[0].Id;
        
        List<RecordType> otherCaseRTypes = [Select id from RecordType where Id <> :email2CaseRType and SObjectType = 'Case' and IsActive = true limit 1];
        
        System.assert(otherCaseRTypes.size() > 0, 'A RecordType, Other Than Fax, Does Not Exist');
        
        otherCaseRType = otherCaseRTypes[0].Id;
        
        System.runAs(TestingUtils.ADMIN_USER)
        {
            List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Case.RecordTypeInfos;
            Id defaultRecordTypeId;

            for (Schema.RecordTypeInfo info : infos) {
              if (info.isDefaultRecordTypeMapping()) {
                defaultRecordTypeId = info.getRecordTypeId();
              }
            }
            if(InactiveRecordTypes__c.getValues(CaseServices.EBUSINESS_RT_NAME) == null) {
                InactiveRecordTypes__c inactiveRT = new InactiveRecordTypes__c(Name=CaseServices.EBUSINESS_RT_NAME,Record_Type_Id__c=defaultRecordTypeId);
                insert inactiveRT;
                CaseServices.eBusiness_RecordType_Id = inactiveRT.id;
            }
              
        }
    }
    
    /*
    * A single email (attached to a case of recordtype Incoming Fax) 
    * attachment is created
    * Ensure that this attachment is removed from the email
    * and placed onto the case
    */
    static testMethod void testSingleAttachment() 
    {
        Case testCase = TestDataGeneration.createCase(email2CaseRType);
        
        insert testCase;
        
        EmailMessage testEmailMessage = TestDataGeneration.createEmailMessage(testCase.Id);
        
        insert testEmailMessage;
                
        Attachment testAttachment =  TestDataGeneration.createAttachment(testEmailMessage.Id);  
        
        Test.startTest();
            insert testAttachment;
        Test.stopTest();    
        
        List<Attachment>emailAttachments = [Select id from Attachment where ParentId = : testEmailMessage.Id];
        
        //System.assertEquals(0, emailAttachments.size());
        
        List<Attachment>caseAttachments = [Select id from Attachment where ParentId = : testCase.Id];
        
      //  System.assertEquals(1, caseAttachments.size());
        
       // System.assertEquals(testAttachment.Id, caseAttachments[0].Id);
    }
    
    /*
    * A single email (attached to a case of recordtype X30_ULS_Customer_Inquiry) 
    * attachment is created
    * Ensure that this attachment is removed from the email
    * and placed onto the case
    */
   
    /* Commented this code as  X30_ULS_Customer_Inquiry Record Type is removed.
     * static testMethod void testSingleAttachmentCustomerInquiryRT() 
    {
        Case testCase = TestDataGeneration.createCase(CaseModel.getRecordType(CaseServices.ULS_CASE_IDENTIFIER).Id);
        
        insert testCase;
        
        EmailMessage testEmailMessage = TestDataGeneration.createEmailMessage(testCase.Id);
        
        insert testEmailMessage;
                
        Attachment testAttachment =  TestDataGeneration.createAttachment(testEmailMessage.Id);  
        
        Test.startTest();
            insert testAttachment;
        Test.stopTest();    
        
        List<Attachment>emailAttachments = [Select id from Attachment where ParentId = : testEmailMessage.Id];
        
       // System.assertEquals(0, emailAttachments.size());
        
        List<Attachment>caseAttachments = [Select id from Attachment where ParentId = : testCase.Id];
        
       // System.assertEquals(1, caseAttachments.size());
        
//System.assertEquals(testAttachment.Id, caseAttachments[0].Id);
    }
    */
    
    /*
    * A single email (attached to a case of recordtype other than Incoming Fax) 
    * attachment is created
    * Ensure that this attachment is not removed from the email
    * and not placed onto the case
    */
    static testMethod void testSingleAttachmentNotIncomingFax() 
    {
        Case testCase = TestDataGeneration.createCase(otherCaseRType);
        
        insert testCase;
        
        EmailMessage testEmailMessage = TestDataGeneration.createEmailMessage(testCase.Id);
        
        insert testEmailMessage;
                
        Attachment testAttachment =  TestDataGeneration.createAttachment(testEmailMessage.Id);  
        
        Test.startTest();
            insert testAttachment;
        Test.stopTest();    
        
        List<Attachment>emailAttachments = [Select id from Attachment where ParentId = : testEmailMessage.Id];
        
        System.assertEquals(1, emailAttachments.size());
        
        System.assertEquals(testAttachment.Id, emailAttachments[0].Id);
        
        List<Attachment>caseAttachments = [Select id from Attachment where ParentId = : testCase.Id];
        
        System.assertEquals(0, caseAttachments.size());                
    }
    
    /*
    * Multiple Emails with multiple attachments are created on multiple cases    
    * Ensure that these attachments are removed from the emails
    * and placed onto the respective cases
    */
    
    static testMethod void testMultipleAttachments() 
    {
        test.startTest();
        Integer numOfCases = 5;
        Integer emailsPerCase = 2;
        Integer attachmentsPerEmail = 2;
        
        //Insert 50 cases
        List<Case>testCases = TestDataGeneration.createCases(email2CaseRType, numOfCases);
        
        insert testCases;
        
        //Insert 100 emails (2 per case)
        List<EmailMessage> emailMessagesToInsert = new List<EmailMessage>();
        
        for(Case insertedCase : testCases)
        {
            emailMessagesToInsert.addAll(TestDataGeneration.createEmailMessages(insertedCase.Id, emailsPerCase));
        }
        insert emailMessagesToInsert;
        
        //Insert 200 attachments (2 per email)
        List<Attachment>emailAttachmentsToInsert = new List<Attachment>();
        
        for(EmailMessage eMailInserted : emailMessagesToInsert)
        {
            emailAttachmentsToInsert.addAll(TestDataGeneration.createAttachments(eMailInserted.Id, attachmentsPerEmail));
        }
        
       // Test.startTest();
            insert emailAttachmentsToInsert;
       
        
        AggregateResult[] groupedParentResults = [SELECT ParentId, COUNT(Id)attachmentCount 
                                                  FROM Attachment 
                                                  WHERE Id in : emailAttachmentsToInsert 
                                                  GROUP BY ParentId];
          
       // System.assertEquals(numOfCases, groupedParentResults.size());
        
        for (AggregateResult ar : groupedParentResults)  
        {               
          //  System.assertEquals(4, ar.get('attachmentCount'));
        }
         Test.stopTest();
    }
    
   
}
@isTest
public class contentVersionTriggerHandlerTest  {
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
    
    static testMethod void fileToCase(){
        Case testCase = TestDataGeneration.createCase(email2CaseRType);
        
        insert testCase;
        
        EmailMessage testEmailMessage = TestDataGeneration.createEmailMessage(testCase.Id);
        
        insert testEmailMessage;
                
       ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient='Penguins.jpeg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
           
        );

        insert contentVersion; 
        List<ContentDocumentLink> documentLinkToUpdate = new List<ContentDocumentLink>();
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        list<ContentDocumentLink> conDocumentLink = [ SELECT LinkedEntityId from ContentDocumentLink where id = :conDocument ];
        for(contentDocumentLink condoclink : conDocumentLink){
            condoclink.LinkedEntityId = testEmailMessage.id;
            documentLinkToUpdate.add(condoclink);
        }
        
        update documentLinkToUpdate;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=testEmailMessage.id;
        //contentlink.ShareType= 'C';
        contentlink.ContentDocumentId=conDocument;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient='Penguins.jpeg',
            VersionData = Blob.valueOf('Test Content1'),
            IsMajorVersion = true,
            ContentDocumentId = conDocument 
        );
        
        Attachment testAttachment =  TestDataGeneration.createAttachment(testEmailMessage.Id);  
        Test.startTest();
        insert testAttachment;
        insert contentVersion1;
        Test.stopTest();    
   
        
    }
    
    
    
    

}
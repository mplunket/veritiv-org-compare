@isTest
private class TestCaseNotification
{
    static RecordType inboundCaseRT;
    static Account account;
    static Contact contact;
    static User newOwner;
    
    private static void setup()
    {
        //inboundCaseRT  = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Inbound Case'];
        
        inboundCaseRT  = CaseModel.getInboundCaseRT();
        
        account = new Account(Name='test');
        insert account;
        
        contact = TestDataGeneration.generateTestContact( 'Jones', account.Id, 'jones@domain.com', true, '', true );
        
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        System.runAs(adminUser)
        {           
            newOwner  = TestDataGeneration.getTestUser('new' + DateTime.now().getTime(), 'CSP with Create Order');
            
            insert newOwner; 
        }
    }
    
    static testMethod void testSendOwnerChangedEmail()
    {
        setup();
        
        // create a Case
        Case aCase = new Case( Subject = 'Test Subject',
                               Status = 'New',
                               Priority = 'Medium',
                               ContactId = contact.Id,
                               Case_Type__c = 'POD',
                               OwnerId = newOwner.Id,
                               RecordTypeId = inboundCaseRT.Id );

        insert aCase;       
        
        Test.startTest();
        
            Boolean sendSuccess = CaseNotification.sendOwnerChangedEmail( new List<Case>{ aCase } );
        
        Test.stopTest();
        
       // System.assert( sendSuccess );
    }
    
    static testMethod void testSendOwnerChangedEmailBulk()
    {
        setup();
        
        List<Case> cases = new List<Case>();
        for(Integer i = 0; i < 3; i++)
        {
            // create a Case
            Case aCase = new Case( Subject = 'Test Subject',
                                   Status = 'New',
                                   Priority = 'Medium',
                            //     ContactId = contact.Id,
                                   Case_Type__c = 'POD',
                                   Is_Primary__c = 'TRUE',
                                   OwnerId = newOwner.Id,
                                   Email_Origin__c = contact.Email,
                                   RecordTypeId = inboundCaseRT.Id );
            cases.add(aCase);
        }

        insert cases;
                
        Test.startTest();
        
            System.debug(System.loggingLevel.ERROR, 'STARTING TEST');
            
            Boolean sendSuccess = CaseNotification.sendOwnerChangedEmail( cases );
        
        Test.stopTest();
        
      //System.assert( sendSuccess );
    }

    static testMethod void testGenerateTempContacts()
    {
        setup();
        
        // create a Case
        Case aCase = new Case( Subject = 'Test Subject',
                               Status = 'New',
                               Priority = 'Medium',
                               ContactId = contact.Id,
                               Case_Type__c = 'POD',
                               OwnerId = newOwner.Id,
                               RecordTypeId = inboundCaseRT.Id );

        insert aCase;       
        
        Test.startTest();
        
            Map<Id, Contact> caseId2Contact = CaseNotification.generateTempContacts( new List<Case>{ aCase } );
        
        Test.stopTest();
        
        if(caseId2Contact.keyset().contains(aCase.Id)){
            System.assert(caseId2Contact.containsKey(aCase.Id));
        }
        
        
        System.assertEquals(newOwner.Email, caseId2Contact.get(aCase.Id).Email);
        
    }
}
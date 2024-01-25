@isTest
private class TestCaseVacationEmailService {

    static Case aCase;
    static Group originalOwner;
    static User newOwner;

    static void setup() {

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

        System.runAs(adminUser)
        {
            originalOwner = new Group(Type='queue', Email = 'queue@uww.com', Name='caseQueue');

            newOwner  = TestDataGeneration.getTestUser('new' + DateTime.now().getTime(), 'CSP with Create Order');

            insert originalOwner;
            insert newOwner;

            QueueSObject qSObject = new QueueSObject(SObjectType = 'Case', QueueId = originalOwner.Id);
            insert qSObject;
        }

        // create a Case
        aCase = new Case( Subject = 'Test Subject',
                        Status = 'New',
                        Priority = 'Medium',
                        Case_Type__c = 'POD',
                        OwnerId = originalOwner.Id,
                        Email_Origin__c = originalOwner.Email );
    }

    static testMethod void testHandleInboundEmailForInboundRecordType() {

        setup();

        RecordType inboundCaseRT  = CaseModel.getInboundCaseRT();
        System.assertNotEquals( null, inboundCaseRT, 'The Inbound Case Record Type does not exist' );

        aCase.RecordTypeId = inboundCaseRT.Id;
        insert aCase;

        // set the Case's owner to the new owner
        aCase.OwnerId = newOwner.Id;
        aCase.Previous_Owner_ID__c = originalOwner.Id;
        aCase.Previous_Case_Owner_Name__c = originalOwner.Name;
        aCase.Previous_Case_Owner_ID__c = originalOwner.Id;

        CaseNotification.caseTriggerAfterIsRunning = false;
        // update the Case
        update aCase;

        aCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :aCase.Id];

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        String caseNumber = aCase.CaseNumber;
        String validSubject = 'Out of  Office: re: Case: ' + caseNumber + ' has been assigned to you';

        email.subject = validSubject;

        Test.startTest();

            CaseNotification.caseTriggerAfterIsRunning = false;

            // give the email to the service
            CaseVacationEmailService handler = new CaseVacationEmailService();
            Messaging.InboundEmailResult result = handler.handleInboundEmail( email, envelope );

        Test.stopTest();

        // query for the updated case
        Case updatedCase = [ SELECT OwnerId, Previous_Case_Owner_Name__c, Previous_Case_Owner_ID__c
                            FROM Case
                            WHERE Id = :aCase.Id ];

        // query for newOwner for full name
        newOwner = [ SELECT Id, Name, Working_Status__c FROM User WHERE Id = :newOwner.Id ];

        // make sure that the service set the owner back to the original
        System.assert( result.success );
        System.assertEquals( originalOwner.Id, updatedCase.OwnerId );
        System.assertEquals( newOwner.Name, updatedCase.Previous_Case_Owner_Name__c );
        System.assertEquals( newOwner.Id, updatedCase.Previous_Case_Owner_ID__c );
        // make sure the out of office status for the owner was set
        System.assertEquals( CaseServices.RECEIVED_CASE_WHILE_OUT_STATUS, newOwner.Working_Status__c );
    }

    static testMethod void testHandleInboundEmailForWebRecordType() {

        setup();

       // Id webCaseRT  = CaseServices.eBusiness_RecordType_Id;
        //System.assertNotEquals( null, webCaseRT, 'The eWeb Case Record Type does not exist' );

        //aCase.RecordTypeId = webCaseRT;
        //insert aCase;

      //  aCase = [Select Id,OwnerId FROM Case WHERE RecordTypeId = : CaseServices.eBusiness_RecordType_Id limit 1];

        // set the Case's owner to the new owner
      //  aCase.OwnerId = newOwner.Id;

        CaseNotification.caseTriggerAfterIsRunning = false;
        // update the Case
       // update aCase;

       // aCase = [ SELECT Id, CaseNumber FROM Case WHERE Id = :aCase.Id ];

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'test';
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        String caseNumber = aCase.CaseNumber;
        String validSubject = 'Out of  Office: re: Case: ' + caseNumber + ' has been assigned to you';

        email.subject = validSubject;

        Test.startTest();

            CaseNotification.caseTriggerAfterIsRunning = false;

            // give the email to the service
            CaseVacationEmailService handler = new CaseVacationEmailService();
            Messaging.InboundEmailResult result = handler.handleInboundEmail( email, envelope );

        Test.stopTest();

        // query for the updated case
       // Case updatedCase = [ SELECT OwnerId
                   //         FROM Case
                      //      WHERE Id = :aCase.Id ];

        // query for newOwner for full name
        newOwner = [ SELECT Id, Name, Working_Status__c FROM User WHERE Id = :newOwner.Id ];

        // make sure that the case has been reassigned to the designated new owner
       // System.assert( result.success );
      //  System.assertEquals( newOwner.Id, updatedCase.OwnerId );
        // make sure the out of office status for the owner was set
       // System.assertEquals( CaseServices.RECEIVED_CASE_WHILE_OUT_STATUS, newOwner.Working_Status__c );
    }

    static testMethod void testParseCaseNumberFromSubject()
    {
        String caseNum = '00099114';
        String caseNum2 = '000123123123';
        String caseNum3 = '321321321352';
        String validSubject = 'Re: Force.com Sandbox: Case: ' + caseNum + ' has been assigned to you';
        String validSubject2 = 'Case: ' + caseNum2 + ' has been assigned to you';
        String validSubject3 = 'Out of  Office until 11/21/10 - Case: ' + caseNum3 + ' has been assigned to you';

        Test.startTest();

            String parsed = CaseVacationEmailService.parseCaseNumberFromSubject( validSubject );
            String parsed2 = CaseVacationEmailService.parseCaseNumberFromSubject( validSubject2 );
            String parsed3 = CaseVacationEmailService.parseCaseNumberFromSubject( validSubject3 );

        Test.stopTest();

        System.assertEquals( caseNum, parsed );
        System.assertEquals( caseNum2, parsed2 );
        System.assertEquals( caseNum3, parsed3 );
    }

    static testMethod void testParseCaseNumberFromInvalidSubject()
    {
        String invalidSubject = 'Out of  Office: re: Case: 001 has been assigned to you';
        String invalidSubject2 = 'Case: abc123defgh has been assigned to you';
        String invalidSubject3 = '';

        Test.startTest();

            String parsed = CaseVacationEmailService.parseCaseNumberFromSubject( invalidSubject );
            String parsed2 = CaseVacationEmailService.parseCaseNumberFromSubject( invalidSubject2 );
            String parsed3 = CaseVacationEmailService.parseCaseNumberFromSubject( invalidSubject3 );

        Test.stopTest();

        System.assertEquals( '', parsed );
        System.assertEquals( '', parsed2 );
        System.assertEquals( '', parsed3 );
    }

    static testMethod void testHandleInboundEmailWithAutoReplyOverride() {

        setup();

        insert aCase;

        // set the Case's owner to the new owner and set it to override the outlook auto response
        aCase.OwnerId = newOwner.Id;
        aCase.Override_Outlook_Auto_Response__c = true;

        CaseNotification.caseTriggerAfterIsRunning = false;
        // update the Case
        update aCase;

        aCase = [ SELECT Id, CaseNumber FROM Case WHERE Id = :aCase.Id ];

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        String caseNumber = aCase.CaseNumber;
        String validSubject = 'Out of  Office: re: Case: ' + caseNumber + ' has been assigned to you';

        email.subject = validSubject;

        Test.startTest();

            CaseNotification.caseTriggerAfterIsRunning = false;

            // give the email to the service
            CaseVacationEmailService handler = new CaseVacationEmailService();
            Messaging.InboundEmailResult result = handler.handleInboundEmail( email, envelope );

        Test.stopTest();

        Case updatedCase = [ SELECT Id, OwnerId, Override_Outlook_Auto_Response__c
                            FROM Case
                            WHERE Id = :aCase.Id ];

        newOwner = [ SELECT Id, Name, Working_Status__c FROM User WHERE Id = :newOwner.Id ];

        // make sure that the case has been reassigned to the designated new owner
        System.assert( result.success, 'the email should have been successfully processed' );
        System.assertEquals( newOwner.Id, updatedCase.OwnerId, 'the override should have forced the case to get the new owner' );
        // make sure the out of office status for the owner was set
        System.assertEquals( CaseServices.RECEIVED_CASE_WHILE_OUT_STATUS, newOwner.Working_Status__c, 'the new owner should have been flagged as getting a case while out' );

        System.assert(!updatedCase.Override_Outlook_Auto_Response__c, 'The case should have had the override reset');
    }

    static testMethod void testHandleInboundEmailWithNoStatusOverride() {

        final String OOO_STATUS = 'End of Day';

        setup();

        insert aCase;

        System.Runas( TestingUtils.ADMIN_USER)
        {
            newOwner.Working_Status__c = OOO_STATUS;
            update newOwner;
        }

        // set the Case's owner to the new owner and set it to override the outlook auto response
        aCase.OwnerId = newOwner.Id;


        aCase.Override_Outlook_Auto_Response__c = true;

        CaseNotification.caseTriggerAfterIsRunning = false;
        // update the Case
        update aCase;

        aCase = [ SELECT Id, CaseNumber FROM Case WHERE Id = :aCase.Id ];

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        String caseNumber = aCase.CaseNumber;
        String validSubject = 'Out of  Office: re: Case: ' + caseNumber + ' has been assigned to you';

        email.subject = validSubject;

        CaseVacationEmailService.sendErrorNotification(email,'error');
        Test.startTest();

            CaseNotification.caseTriggerAfterIsRunning = false;

            // give the email to the service
            CaseVacationEmailService handler = new CaseVacationEmailService();
            Messaging.InboundEmailResult result = handler.handleInboundEmail( email, envelope );

        Test.stopTest();

        Case updatedCase = [ SELECT Id, OwnerId, Override_Outlook_Auto_Response__c
                            FROM Case
                            WHERE Id = :aCase.Id ];

        newOwner = [ SELECT Id, Name, Working_Status__c FROM User WHERE Id = :newOwner.Id ];

        // make sure that the case has been reassigned to the designated new owner
        System.assert( result.success, 'the email should have been successfully processed' );
        System.assertEquals( newOwner.Id, updatedCase.OwnerId, 'the override should have forced the case to get the new owner' );
        // make sure the out of office status for the owner was set
        System.assertEquals( OOO_STATUS, newOwner.Working_Status__c, 'the new owner should have been flagged as getting a case while out, but their status should not be overidden' );

        System.assert(!updatedCase.Override_Outlook_Auto_Response__c, 'The case should have had the override reset');
    }
}
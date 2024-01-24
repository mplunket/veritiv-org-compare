@isTest
private class TestCaseTrigger
{
    static final Integer NUM_OF_CASES = 10;
    static final String TEAM_LEAD_NAME = 'John Doe';
    static final String TEAM_LEAD_EMAIL = 'johndoe@email.com';

    static User oldUser;
    static User newUser;
    static User defaultUser;
    static RecordType testRecordType;
    static Account testAccount;
    static Contact testContact;
    static Group testQueue;
    static List<Case> newCases;

    static
    {
        InactiveRecordTypes__c testCustomSetting = new InactiveRecordTypes__c();
        testCustomSetting.Name = CaseServices.EBUSINESS_RT_NAME;

        System.runAs( TestingUtils.ADMIN_USER )
        {
            insert testCustomSetting;
            defaultUser = TestingUtils.createUser( 'JohnDoe', 'Standard User', true );
            oldUser = TestingUtils.createUser( 'OldUser', 'Standard User', true );
            newUser = TestingUtils.createUser( 'NewUser', 'CSP with Create Order', true );
        }

        testRecordType = [ SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Incoming_Fax' AND SObjectType = 'Case' ];

        testAccount = TestingUtils.createAccount( 'TestAccount' );
        insert testAccount;

        testContact = TestingUtils.createContact( 'John', 'Doe', true );
    }

    static void setupQueue()
    {
        testQueue = TestingUtils.createGroup( 'TestQueue1', 'Queue', true );

        QueueSobject queueAndCaseJunction = new QueueSobject( QueueId = testQueue.Id, SobjectType = 'Case' );
        QueueSobject queueAndCaseQueueAssignmentJunction = new QueueSobject( QueueId = testQueue.Id, SobjectType = 'Fax_To_Case_Queue_Assignment__c' );

        System.runAs( TestingUtils.ADMIN_USER )
        {
            insert new List<QueueSobject> { queueAndCaseJunction, queueAndCaseQueueAssignmentJunction };
        }

        Fax_To_Case_Queue_Assignment__c queueAssignment = TestingUtils.createQueueAssignment( 1, TEAM_LEAD_NAME, TEAM_LEAD_EMAIL, false )[0];
        queueAssignment.OwnerId = testQueue.Id;
        insert queueAssignment;

        newCases = TestingUtils.generateCases( NUM_OF_CASES, testAccount.Id, testContact.Id, testRecordType.Id, false );
    }

    static testMethod void testCopyOwnerIdToUserLookUp_onInsert_CaseWithUser()
    {
        List<Case> testCases = TestingUtils.generateCases( NUM_OF_CASES, testAccount.Id, testContact.Id, testRecordType.Id, false );
        for( Case testCase : testCases )
        {
            testCase.OwnerId = defaultUser.Id;
        }

        Test.startTest();

            System.runAs( TestingUtils.ADMIN_USER )
            {
                insert testCases;
            }

        Test.stopTest();

        List<Case> resultCases = [ SELECT Id, OwnerId, Owner_Clone__c FROM Case WHERE Id IN :testCases ];

        System.assertEquals( NUM_OF_CASES, resultCases.size(), 'All Cases should be returned' );

        for( Case resultCase : resultCases )
        {
            //System.assertEquals( defaultUser.Id, resultCase.Owner_Clone__c, 'Owner Clone lookup field should be copied with proper Case Owner lookup' );
        }
    }

    static testMethod void testCopyOwnerIdToUserLookUp_onInsert_CaseWithQueue_NonClosedStatus()
    {
        setupQueue();

        for( Case aCase : newCases )
        {
            aCase.OwnerId = testQueue.Id;
            aCase.Status = 'TestStatus';
        }

        Test.startTest();

            System.runAs( TestingUtils.ADMIN_USER ) { insert newCases; }

        Test.stopTest();

        List<Case> resultCases = [ SELECT Id, Owner_Clone__c, Team_Lead_Name__c, Team_Lead_Email__c FROM Case ];

        //System.assertEquals( NUM_OF_CASES, resultCases.size(), 'All Cases should be returned' );
        for( Case aCase : resultCases )
        {
           // System.assertEquals( null, aCase.Owner_Clone__c, 'Owner Clone field should not be copied over from OwnerId for Queue owned Cases' );
            //System.assertEquals( TEAM_LEAD_NAME, aCase.Team_Lead_Name__c, 'Team Lead Name should be set properly for Queue owned Cases' );
           // System.assertEquals( TEAM_LEAD_EMAIL, aCase.Team_Lead_Email__c, 'Team Lead Email should be set properly for Queue owned Cases' );
        }
    }

    static testMethod void testCopyOwnerIdToUserLookUp_onInsert_CaseWithQueue_ClosedStatus()
    {
        setupQueue();

        for( Case aCase : newCases )
        {
            aCase.OwnerId = testQueue.Id;
            aCase.Status = CaseServices.CLOSED_STATUS;
        }

        Test.startTest();

            System.runAs( TestingUtils.ADMIN_USER ) { insert newCases; }

        Test.stopTest();

        List<Case> resultCases = [ SELECT Id, Owner_Clone__c, Team_Lead_Name__c, Team_Lead_Email__c FROM Case ];

        System.assertEquals( NUM_OF_CASES, resultCases.size(), 'All Cases should be returned' );
        for( Case aCase : resultCases )
        {
            System.assertEquals( null, aCase.Owner_Clone__c, 'Owner Clone field should not be copied over from OwnerId for Queue owned Cases' );
            //System.assertEquals( null, aCase.Team_Lead_Name__c, 'Team Lead Name should not be set for Closed Status Queue Cases' );
            System.assertEquals( null, aCase.Team_Lead_Email__c, 'Team Lead Email should not be set for Closed Status Queue Cases' );
        }
    }

    static testMethod void testCopyOwnerIdToUserLookUp_onUpdate_NonClosedStatus()
    {
        setupQueue();

        for( Case aCase : newCases )
        {
            aCase.OwnerId = testQueue.Id;
            aCase.Status = 'TestStatus';
        }

        System.runAs( TestingUtils.ADMIN_USER ) { insert newCases; }

        for( Integer i = 0; i < NUM_OF_CASES; i+=2 )
        {
            newCases[i].OwnerId = newUser.Id;
        }

        Test.startTest();

            System.runAs( TestingUtils.ADMIN_USER ) { update newCases; }

        Test.stopTest();

        List<Case> resultCases = [ SELECT Id, OwnerId, Owner_Clone__c, Team_Lead_Name__c, Team_Lead_Email__c FROM Case ];

        System.assertEquals( NUM_OF_CASES, resultCases.size(), 'All Cases should be returned' );
        for( Case aCase : resultCases )
        {
            if( aCase.OwnerId == newUser.Id )
            {
                //System.assertEquals( aCase.OwnerId, aCase.Owner_Clone__c, 'Owner Clone field should be copied over from OwnerId for User owned Cases' );
                //System.assertEquals( null, aCase.Team_Lead_Name__c, 'Team Lead Name should not be set for User owned Cases' );
                //System.assertEquals( null, aCase.Team_Lead_Email__c, 'Team Lead Email should not be set for User owned Cases' );
            }
            else
            {
                System.assertEquals( null, aCase.Owner_Clone__c, 'Owner Clone field should not be copied over from OwnerId for Queue owned Cases' );
               // System.assertEquals( TEAM_LEAD_NAME, aCase.Team_Lead_Name__c, 'Team Lead Name should be set properly for Queue owned Cases' );
              //  System.assertEquals( TEAM_LEAD_EMAIL, aCase.Team_Lead_Email__c, 'Team Lead Email should be set properly for Queue owned Cases' );
            }
        }
    }

    static testMethod void testCopyOwnerIdToUserLookUp_onUpdate_ClosedStatus()
    {
        setupQueue();

        for( Case aCase : newCases )
        {
            aCase.OwnerId = testQueue.Id;
            aCase.Status = CaseServices.CLOSED_STATUS;
        }

        System.runAs( TestingUtils.ADMIN_USER ) { insert newCases; }

        for( Integer i = 0; i < NUM_OF_CASES; i++ )
        {
            newCases[i].OwnerId = newUser.Id;
        }

        Test.startTest();

            System.runAs( TestingUtils.ADMIN_USER ) { update newCases; }

        Test.stopTest();

        List<Case> resultCases = [ SELECT Id, OwnerId, Owner_Clone__c, Team_Lead_Name__c, Team_Lead_Email__c FROM Case ];

        System.assertEquals( NUM_OF_CASES, resultCases.size(), 'All Cases should be returned' );
        for( Case aCase : resultCases )
        {
            //System.assertEquals( aCase.OwnerId, aCase.Owner_Clone__c, 'Owner Clone field should be copied over from OwnerId for User owned Cases' );
            //System.assertEquals( null, aCase.Team_Lead_Name__c, 'Team Lead Name should not be set for User owned Cases' );
            System.assertEquals( null, aCase.Team_Lead_Email__c, 'Team Lead Email should not be set for User owned Cases' );
        }
    }
}
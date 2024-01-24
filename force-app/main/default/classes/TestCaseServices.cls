@isTest
private class TestCaseServices
{
	static final Integer NUM_OF_CASES = 10;
	static final String TEAM_LEAD_NAME = 'John Doe';
	static final String TEAM_LEAD_EMAIL = 'johndoe@email.com';

	static User oldUser;
	static User newUser;
	static RecordType testRecordType;
	static Account testAccount;
	static Contact testContact;

	static
	{
		InactiveRecordTypes__c testCustomSetting = new InactiveRecordTypes__c();
		testCustomSetting.Name = CaseServices.EBUSINESS_RT_NAME;

		System.runAs( TestingUtils.ADMIN_USER )
		{
			insert testCustomSetting;
			oldUser = TestingUtils.createUser( 'OldUser', 'Standard User', true );
			newUser = TestingUtils.createUser( 'NewUser', 'Standard User', true );
		}

		testRecordType = [ SELECT Id, Name FROM RecordType WHERE DeveloperName = 'x06CustomerComplaint' AND SObjectType = 'Case' ];

		testAccount = TestingUtils.createAccount( 'TestAccount' );
		insert testAccount;

		testContact = TestingUtils.createContact( 'John', 'Doe', true );
	}
	
	static testMethod void buildCaseTeamMemberForPreviousOwnerTest(){
	    
		QueueSobject testQueueObj; Group  testQueue; 
	    
	    List<User> testUsers = new List<User>();
	    System.runAs(TestingUtils.ADMIN_USER) {
	        testUsers = TestingUtils.createUsers('testname', 'Sales Admin - Lightning', 6, false);
	        testQueue = TestingUtils.createGroup( 'TestQueue1', 'Queue', true );
	        testQueueObj = new QueueSObject(QueueId = testQueue.Id, SobjectType = 'Case');
			//insert testUsers;
			insert testQueueObj;
	    }
       
        List<Case> oldCases = TestingUtils.createCases(4, true);
        test.startTest();
        System.runAs(testUsers[0]) {
            oldCases[0].OwnerId = testUsers[0].Id;
	        update oldCases[0];
	    }
	    System.runAs(testUsers[1]) {
			oldCases[1].OwnerId = testUsers[1].Id;
            update oldCases[1];
        }
       // System.runAs(testUsers[2]) {
		//	oldCases[2].OwnerId = testUsers[2].Id;
          //  update oldCases[2];
       // }

	    oldCases = [Select Id, ownerID from Case where id IN : oldCases];
	    
	    List<Case> newCases = oldCases.deepclone(true);
	    newCases.remove(2);
	    newCases[0].OwnerId = testUsers[3].id;
	    newCases[1].OwnerId = testUsers[4].id;
	    newCases[2].OwnerId = testUsers[5].id;


		CaseTeamMember member1 = new CaseTeamMember (parentID = oldCases[0].id,
	                                                 memberID = testUsers[0].id,
	                                                 teamRoleID = CaseServices.previousOwnerRole.id);
	    insert member1;
	    
	    CaseTeamMember member2 = new CaseTeamMember (parentID = oldCases[1].id, 
                                                     memberID = testUsers[1].id,
                                                     teamRoleID = CaseServices.previousOwnerRole.id);
		insert member2;
	    Set<CaseTeamMember> expectedCaseTeamMembers = new Set<CaseTeamMember>{member1, member2};
            
            Map<Id, Case> oldCasesMap = new Map<Id, Case>(oldCases);
        
        //test.stopTest();                                                      
        List<CaseTeamMember> actualCaseTeamMembers = new List<CaseTeamMember>();
        
	   // Test.startTest();
	       actualCaseTeamMembers = CaseServices.buildCaseTeamMemberForPreviousOwner(newCases, oldCasesMap);
	    Test.stopTest();

	    
	    System.AssertEquals(2, actualCaseTeamMembers.size(), 'An incorrect number of case team members have been returned');
	    System.AssertEquals(expectedCaseTeamMembers, new Set<CaseTeamMember>(actualCaseTeamMembers), 'An incorrect case team member has been returned');
	   // test.stopTest();
	}
	
	static testMethod void buildCaseTeamMemberForCurrentUserTest(){
		test.startTest();
		
		List<User> testUsers = new List<User>();
        CaseTeamRole notPreviousRole = new CaseTeamRole (Name = 'Role that is not the previous role', AccessLevel = 'Edit');
        System.runAs(TestingUtils.ADMIN_USER) {
           testUsers = TestingUtils.createUsers('testname', 'Standard User', 6, false);
           insert notPreviousRole;
        }
        
        List<Case> cases = TestingUtils.createCases(3, true);
       
        CaseTeamMember member1 = new CaseTeamMember (parentID = cases[0].id, 
                                                     memberID = UserInfo.getUserId(),
                                                     teamRoleID = notPreviousRole.ID );
        insert member1;
        member1.teamRoleId = CaseServices.previousOwnerRole.id;
        
        CaseTeamMember member2 = new CaseTeamMember (parentID = cases[1].id, 
                                                     memberID = UserInfo.getUserId(),
                                                     teamRoleID = CaseServices.previousOwnerRole.id);
        CaseTeamMember member3 = new CaseTeamMember (parentID = cases[2].id, 
                                                     memberID = UserInfo.getUserId(),
                                                     teamRoleID = CaseServices.previousOwnerRole.id);

        Set<CaseTeamMember> expectedCaseTeamMembers = new Set<CaseTeamMember>{member1, member2, member3};
        
		List<CaseTeamMember> actualCaseTeamMembers = new List<CaseTeamMember>();
		
		//Test.startTest();
		    actualCaseTeamMembers = CaseServices.buildCaseTeamMemberForCurrentUser(cases);
		//Test.stopTest();
		
		System.AssertEquals(3, actualCaseTeamMembers.size(), 'An incorrect number of case team members have been returned');
        System.AssertEquals(expectedCaseTeamMembers, new Set<CaseTeamMember>(actualCaseTeamMembers), 'An incorrect case team member has been returned');
		test.stopTest();
	}

	static testMethod void testFilterUpdatedCaseOwner_DifferentUsers()
	{
        test.startTest();
		List<Case> oldCases = TestingUtils.generateCases( NUM_OF_CASES, testAccount.Id, testContact.Id, testRecordType.Id, false );
		Map<Id, Case> oldCaseMap = new Map<Id, Case>();
		for( Case aCase : oldCases )
		{
			aCase.OwnerId = oldUser.Id;
			oldCaseMap.put( aCase.Id, aCase );
		}

		List<Case> newCases = TestingUtils.generateCases( NUM_OF_CASES, testAccount.Id, testContact.Id, testRecordType.Id, false );
		for( Integer i = 0; i < NUM_OF_CASES; i+=2)
		{
			newCases[i].OwnerId = oldUser.Id;
		}
		for( Integer i = 1; i < NUM_OF_CASES; i+=2)
		{
			newCases[i].OwnerId = newUser.Id;
		}

		//Test.startTest();

			List<Case> resultCases = CaseServices.filterUpdatedCaseOwner( oldCaseMap, newCases );

		//Test.stopTest();

		System.assertEquals( NUM_OF_CASES / 2, resultCases.size(), 'There should be half number of Cases that OwnerId have changed' );
		for( Case aCase : resultCases )
		{
			System.assertEquals( newUser.Id, aCase.OwnerId, 'Only Cases with OwnerId change should be returned' );
		}
        test.stopTest();
	}

	static testMethod void testPopulateCaseFieldsUponOwnerChange_UserAsOwner()
	{
        Test.startTest();
		List<Case> newCases = TestingUtils.generateCases( NUM_OF_CASES, testAccount.Id, testContact.Id, testRecordType.Id, false );
		for( Case aCase : newCases )
		{
			aCase.OwnerId = newUser.Id;
		}

		

			List<Case> resultCases = CaseServices.populateCaseFieldsUponOwnerChange( newCases );

		

		System.assertEquals( NUM_OF_CASES, resultCases.size(), 'All Cases should be returned' );
		for( Case aCase : resultCases )
		{
			System.assertEquals( aCase.OwnerId, aCase.Owner_Clone__c, 'Owner Clone field should be copied over from OwnerId' );
		}
        Test.stopTest();
	}

	static testMethod void testPopulateCaseFieldsUponOwnerChange_QueueAsOwner_NonClosedStatus()
	{
        Test.startTest();
		Group testQueue = TestingUtils.createGroup( 'TestQueue1', 'Queue', true );

		QueueSobject queueAndCaseJunction = new QueueSobject( QueueId = testQueue.Id, SobjectType = 'Case' );
		QueueSobject queueAndCaseQueueAssignmentJunction = new QueueSobject( QueueId = testQueue.Id, SobjectType = 'Fax_To_Case_Queue_Assignment__c' );

		System.runAs( TestingUtils.ADMIN_USER )
		{
			insert new List<QueueSobject> { queueAndCaseJunction, queueAndCaseQueueAssignmentJunction };
		}

		Fax_To_Case_Queue_Assignment__c queueAssignment = TestingUtils.createQueueAssignment( 1, TEAM_LEAD_NAME, TEAM_LEAD_EMAIL, false )[0];
		queueAssignment.OwnerId = testQueue.Id;
		insert queueAssignment;

		List<Case> newCases = TestingUtils.generateCases( NUM_OF_CASES, testAccount.Id, testContact.Id, testRecordType.Id, false );
		for( Case aCase : newCases )
		{
			aCase.OwnerId = testQueue.Id;
			aCase.Status = 'TestStatus';
		}

		//Test.startTest();

			List<Case> resultCases = CaseServices.populateCaseFieldsUponOwnerChange( newCases );

		//Test.stopTest();

		System.assertEquals( NUM_OF_CASES, resultCases.size(), 'All Cases should be returned' );
		for( Case aCase : resultCases )
		{
			System.assertEquals( null, aCase.Owner_Clone__c, 'Owner Clone field should not be copied over from OwnerId for Queue owned Cases' );
			System.assertEquals( TEAM_LEAD_NAME, aCase.Team_Lead_Name__c, 'Team Lead Name should be set properly for Queue owned Cases' );
			System.assertEquals( TEAM_LEAD_EMAIL, aCase.Team_Lead_Email__c, 'Team Lead Name should be set properly for Queue owned Cases' );
		}
        Test.stopTest();
	}

	static testMethod void testPopulateCaseFieldsUponOwnerChange_QueueAsOwner_ClosedStatus()
	{
        test.startTest();
		Group testQueue = TestingUtils.createGroup( 'TestQueue1', 'Queue', true );

		QueueSobject queueAndCaseJunction = new QueueSobject( QueueId = testQueue.Id, SobjectType = 'Case' );
		QueueSobject queueAndCaseQueueAssignmentJunction = new QueueSobject( QueueId = testQueue.Id, SobjectType = 'Fax_To_Case_Queue_Assignment__c' );

		System.runAs( TestingUtils.ADMIN_USER )
		{
			insert new List<QueueSobject> { queueAndCaseJunction, queueAndCaseQueueAssignmentJunction };
		}

		Fax_To_Case_Queue_Assignment__c queueAssignment = TestingUtils.createQueueAssignment( 1, TEAM_LEAD_NAME, TEAM_LEAD_EMAIL, false )[0];
		queueAssignment.OwnerId = testQueue.Id;
		insert queueAssignment;

		List<Case> newCases = TestingUtils.generateCases( NUM_OF_CASES, testAccount.Id, testContact.Id, testRecordType.Id, false );
		for( Case aCase : newCases )
		{
			aCase.OwnerId = testQueue.Id;
			aCase.Status = CaseServices.CLOSED_STATUS;
		}

		//Test.startTest();

			List<Case> resultCases = CaseServices.populateCaseFieldsUponOwnerChange( newCases );

		//Test.stopTest();

		System.assert( resultCases.isEmpty(), 'None of the Cases should be returned' );
        Test.stopTest();
	}
}
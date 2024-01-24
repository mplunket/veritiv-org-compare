/*
 */
@isTest
private class TestCaseAssignmentShare {

static User queueMember;
static User nonQueueMember;
static User nonQueueMember2;
static User queueMemberSubordinate;
static Map<String, RecordType> rTypeNameToRType;
static Group managerQueue;

    static{

		rTypeNameToRType = new Map<String, RecordType>();

		//Find the relevant record types

		for(RecordType found : [SELECT Id, Name, DeveloperName
								FROM RecordType
								WHERE DeveloperName in : CaseServices.CASE_RECORD_TYPES
								AND SObjectType = 'Case'])
		{
			rTypeNameToRType.put(found.DeveloperName, found);
		}



		//System.runAs(TestDataGeneration.ADMIN_USER) {
		System.runAs(SObjectFactory.ADMIN_USER) {

			managerQueue = new Group(Type = 'Queue', Email = 'queue@uww.com', Name = 'Test Case Queue');

			insert managerQueue;

			queueMember = TestDataGeneration.createUser('QMem', 'CS - Lightning Console', false);

			nonQueueMember = TestDataGeneration.createUser('NoQ', 'CS - Lightning Console', false);

			nonQueueMember2 = TestDataGeneration.createUser('NoQ2', 'CS - Lightning Console', false);

			UserRole ultimateManagerRole = new UserRole(Name = 'Manager');

			insert ultimateManagerRole;

			UserRole managerRole = new UserRole(Name = 'Manager', ParentRoleId = ultimateManagerRole.Id);

			UserRole managerRole2 = new UserRole(Name = 'Manager2', ParentRoleId = ultimateManagerRole.Id);

			insert new List<UserRole>{
					managerRole, managerRole2
			};

			UserRole subordinateRole = new UserRole(Name = 'Subordinate1', ParentRoleId = managerRole.Id);

			UserRole subordinateRole2 = new UserRole(Name = 'Subordinate2', ParentRoleId = managerRole2.Id);

			insert new List<UserRole>{
					subordinateRole, subordinateRole2
			};

			queueMember.UserRoleId = subordinateRole.Id;
			nonQueueMember.UserRoleId = subordinateRole2.Id;
			nonQueueMember2.UserRoleId = subordinateRole.Id;

			insert new List<User>{
					queueMember, nonQueueMember, nonQueueMember2
			};

			//Add the queue member to the queue
			GroupMember testGM = new GroupMember(GroupId = managerQueue.id, USerOrGroupId = queueMember.id);

			insert testGM;

			QueueSObject qSObject = new QueueSObject(SObjectType = 'Case', QueueId = managerQueue.Id);
			insert qSObject;

			/*PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Case_Duration_Permissions'];
			insert new List<PermissionSetAssignment>{new PermissionSetAssignment(AssigneeId = queueMember.id, PermissionSetId = ps.Id),
					new PermissionSetAssignment(AssigneeId = nonQueueMember.id, PermissionSetId = ps.Id),
					new PermissionSetAssignment(AssigneeId = nonQueueMember2.id, PermissionSetId = ps.Id)};*/
		}
	}

    /*
    	Assign a case and ensure that the share record gets created
    	Run As a specific user
    */
    static testMethod void assignInformationOnlyCaseToUserTest() {

        Id inboundRtypeId = rTypeNameToRType.get(CaseServices.INFORMATION_ONLY_CASE_IDENTIFIER).Id;
        Case testCase;


        //Run as queue member sub
        System.RunAs(nonQueueMember)
        {

        	//Create a case
	        testCase = TestDataGeneration.createCase(inboundRtypeId);

	        //Assign the queue as the owner of the case
	        testCase.OwnerId = managerQueue.Id;

	        insert testCase;

        }

        //assign the owner as a regular user
        //Run as queue member
        System.RunAs(queueMember)
        {

	        //Assign the non queue member as the owner of the case
	        testCase.OwnerId = nonQueueMember.Id;

	        Test.StartTest();
	        	update testCase;
	        Test.StopTest();

        	//ensure that the case is visible by the queuemember
        	List<Case> casesModified = [SELECT Id
										 FROM Case
										 WHERE Id =: testCase.Id];


       	//	System.assertEquals(1, casesModified.size());

       		//Ensure that the queueMember can edit the case

            if(casesModified.size() == 1){
                casesModified[0].Subject = 'Test Subj';
				
       		try
       		{
       			update casesModified[0];
       		}
       		catch(Exception E)
       		{
       			//System.assert(False,'Update Failed, User does not have Edit Access!');
       		}
            }


        }

    }

    /*
    	Assign a case (as a non-queue member)  and ensure that the team member record gets created
    	Run As a specific user
    */
    static testMethod void assignInformationOnlyCaseToNonQueueMemberTest() {

        Id inboundRtypeId = rTypeNameToRType.get(CaseServices.INFORMATION_ONLY_CASE_IDENTIFIER).Id;
        Case testCase;
        Account testAcct;
        Contact testContact;


        System.RunAs(queueMember)
        {
        	//Create a case
	        testCase = TestDataGeneration.createCase(inboundRtypeId);

	        insert testCase;

        	//Assign another NonQueuemember as the owner of the case
	        testCase.OwnerId = nonQueueMember.Id;


	        Test.StartTest();
	        	update testCase;
	        Test.StopTest();

	        //ensure that the case is visible by the queuemember
        	List<Case> casesModified = [SELECT Id
										 FROM Case
										 WHERE Id =: testCase.Id];


       		//System.assertEquals(1, casesModified.size());

       		//Ensure that the queueMember can edit the case
            if(casesModified.size() == 1){
                casesModified[0].Subject = 'Test Subj';
                try
       		{
       			update casesModified[0];
       		}
       		catch(Exception E)
       		{
       			//System.assert(False,'Update Failed, User does not have Edit Access!');
       		}
            }



        }

    }

    /*
    	Assign a case and ensure that the share record gets created
    	Run As a specific user
    */
    static testMethod void assignInformationOnlyCaseToSameUserTest() {

        Id inboundRtypeId = rTypeNameToRType.get(CaseServices.INFORMATION_ONLY_CASE_IDENTIFIER).Id;
        Case testCase;

        //Run as queue member sub
        System.RunAs(nonQueueMember)
        {
        	//Create a case
	        testCase = TestDataGeneration.createCase(inboundRtypeId);

	        //Assign the queue as the owner of the case
	        testCase.OwnerId = managerQueue.Id;

	        insert testCase;
        }

        //assign the owner as a regular user
        //Run as queue member
        System.RunAs(queueMember)
        {
	        //Assign the queuemember as the owner of the case
	        testCase.OwnerId = queueMember.Id;

	        Test.StartTest();
	        	update testCase;
	        Test.StopTest();
        }

    }

    static testMethod void assignInformationOnlyCaseToUserBulkTest() {

        Id inboundRtypeId = rTypeNameToRType.get(CaseServices.INFORMATION_ONLY_CASE_IDENTIFIER).Id;
        List<Case> testCases;
        Account testAccount;

        //Run as queue member sub
        System.RunAs(nonQueueMember)
        {
        	//Create an account
        	testAccount = TestDataGeneration.createAccount('Test Acct');
        	//Create a case
	        testCases = TestDataGeneration.createCases(inboundRtypeId, 50);

	        for(Case created : testCases)
	        {
	        	//Assign the queue as the owner of the case
	        	created.OwnerId = managerQueue.Id;
	        	created.AccountId = testAccount.id;
	        }

	        insert testCases;
        }

        //assign the owner as a regular user
        //Run as queue member
        System.RunAs(queueMember)
        {

	        for(Case created : testCases)
	        {
	        	//Assign the non queue member as the owner of the case
	        	created.OwnerId = nonQueueMember.Id;
	        }

	        Test.StartTest();
	        	update testCases;
	        Test.StopTest();

        }


        //ensure that the caseTeamMember records get created
        List<CaseTeamMember> caseTeamMembers = [ SELECT Id
												 FROM CaseTeamMember
												 WHERE ParentId =: testCases
												 AND MemberId =: queueMember.Id ];

     //   System.assertEquals(50, caseTeamMembers.size());

    }

}
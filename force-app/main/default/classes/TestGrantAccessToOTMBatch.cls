@isTest
private class TestGrantAccessToOTMBatch
{
	private static final Integer NUM_OF_OBJs = 5;

	private static Opportunity testOppty;
	private static OpportunityTeamMember testOTM;
	private static User testUser;
	private static List<User> specificUsers;

	private static void setup()
	{
		// recordtype is NEEDED for test pass
		InactiveRecordTypes__c inactiveRT = new InactiveRecordTypes__c();
		inactiveRT.Name = CaseServices.EBUSINESS_RT_NAME;
		System.runAs( TestingUtils.ADMIN_USER )
		{
			insert inactiveRT;
		}
		Id testRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get( '02. Customer Inquiry' ).getRecordTypeId();
		Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Customer' ).getRecordTypeId();

		testUser = TestingUtils.createUser( 'User', 'Standard User', true );
		testOppty = TestingUtils.createOpportunities( 1, null, 'Test Oppty', true )[0];
		testOTM = TestingUtils.createOpportunityTeamMember( testOppty.Id, testUser.Id, true );
	}

	private static void setupEmailCustomSettings()
	{
		Read_Write_Batch_Job_Email_List__c emailOne = new Read_Write_Batch_Job_Email_List__c( Name = 'Philip Choi', Email_Address__c = 'philip.choi@bluewolfgroup.com' );
		Read_Write_Batch_Job_Email_List__c emailTwo = new Read_Write_Batch_Job_Email_List__c( Name = 'James Dadouris', Email_Address__c = 'james.dadouris@bluewolfgroup.com' );
		{
			insert new List<Read_Write_Batch_Job_Email_List__c> { emailOne, emailTwo };
		}
	}

	private static void setupSpecificUserCustomSettings()
	{
		Sales_Team_Batch_Specific_Users__c specificUser1 = new Sales_Team_Batch_Specific_Users__c( Name = 'John Doe', UserID__c = testUser.Id );
		System.runAs( TestingUtils.ADMIN_USER )
		{
			insert specificUser1;
		}
	}

	private static testMethod void testBatch()
	{ 
		setup();
		//TestOpportunityTeamMemberServices.setupRelationMap();
		setupEmailCustomSettings();
		
		//List<OpportunityTeamMember> otms_Before = UnitTest.get('All OTMs').getList();

		Test.startTest();

			GrantAccessToOTMBatch nextBatch = new GrantAccessToOTMBatch();
			Database.executeBatch( nextBatch );

		Test.stopTest();

		String expectedQuery = 'SELECT Id, OpportunityId, TeamMemberRole, UserId, CreatedDate, LastModifiedDate FROM OpportunityTeamMember';
		System.assertEquals( expectedQuery, GrantAccessToOTMBatch.query, 'Without Specific User Custom Setting, query string should not include filter for getting specific users' );

		List<OpportunityShare> actualOpptyShares = [ SELECT Id, OpportunityAccessLevel FROM OpportunityShare WHERE OpportunityId = :testOppty.Id AND UserOrGroupId = :testOTM.UserId ];

		System.assertEquals( 1, actualOpptyShares.size(), 'There should be one Opportunity Shares per Opportunity Team Member' );
		System.assertEquals( BatchServices.EDIT, actualOpptyShares[0].OpportunityAccessLevel, 'The Opportunity Access Level for Opportunity Share should have Read/Write access' );
		
		List<OpportunityTeamMember> otms_After = [SELECT Id, TeamMemberRole, OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :testOppty.Id];
		
		System.assertEquals(1, otms_After.size(), 'We expect back OTMs for each Account with Open Opps.');
	}


	private static testMethod void testBatch_OppClosed()
	{ 
		//setup();
		TestOpportunityTeamMemberServices.setupRelationMap();
		UnitTest.get('Opp Acc 1').property('StageName').assign('8- Closed Won');
		UnitTest.get('Opp Acc 1').updateAll();
		
		UnitTest.get('All Otms').deleteAll();
		setupEmailCustomSettings();

		Test.startTest();

			GrantAccessToOTMBatch nextBatch = new GrantAccessToOTMBatch();
			Database.executeBatch( nextBatch );

		Test.stopTest();
		//System.assert(false, UnitTest.get('Parent Accounts').getList() + ' CHILDS: ' + UnitTest.get('Child Accounts').getList());
		
		List<OpportunityTeamMember> otms_After = [SELECT Id, TeamMemberRole, OpportunityId, UserId FROM OpportunityTeamMember /*WHERE Id IN :otms_Before*/];
		
		System.assertEquals(/*otms_Before.size() / 2*/ 2, otms_After.size(), 'We expect back OTMs for each Account with Open Opps.');
		
		Set<Id> acctOwners = Pluck.ids(UnitTest.get('User Two').getList());
		System.assertEquals(acctOwners, Pluck.ids('UserId', otms_After), 'We expect back the correct OTMs for each Account with Open Opps');
		System.assert(otms_After[0].UserId == UnitTest.get('User Two').getList()[0].Id, 'We expect the correct OTM to be returned.');
	}
	
	private static testMethod void testBatch_ChangedParentOwner()
	{ 
		User userOne = TestingUtils.createUser( 'User', 'Standard User', true );
		UnitTest.addData( new List<User>{ userOne } ).tag('User One').tag('All Users');
		User userTwo = TestingUtils.createUser( 'User', 'Standard User', true ); 
		UnitTest.addData( new List<User>{ userTwo } ).tag('User Two').tag('All Users'); 
		
		List<Account> parentAccounts = TestingUtils.createAccounts( 'Test Parent Account', null, 1 );
		UnitTest.addData( parentAccounts ).tag('Parent Account').tag('All Accounts');
		UnitTest.get('Parent Account').property('OwnerId').assign(userOne.Id);
		UnitTest.get('Parent Account').property('National_Account__c').assign(true);
		//UnitTest.get('Parent Acct Owner 2').property('OwnerId').assign(userTwo.Id);
		UnitTest.get('Parent Account').insertAll();
		
		List<Account> childAccounts = TestingUtils.createAccounts( 'Test Child Account', null, 1 );
		UnitTest.addData( childAccounts ).tag('Child Account').tag('All Accounts');
		UnitTest.get('Child Account').property('ParentId').assign(parentAccounts[0].Id);
		UnitTest.get('Child Account').insertAll();
		
		Opportunity opp = TestingUtils.createOpportunity(UnitTest.get('Child Account').getList()[0].Id, 'Test Opp', true); 
		
		OpportunityTeamMember otm = TestingUtils.createOpportunityTeamMember( opp.Id, userOne.Id, false );
		otm.TeamMemberRole = OpportunityTeamMemberServices.NATIONAL_ACCOUNT_MANAGER_ROLE;
		insert otm;

		parentAccounts[0].OwnerId = userTwo.Id;
		update parentAccounts[0];
				
		setupEmailCustomSettings();

		Test.startTest();

			GrantAccessToOTMBatch nextBatch = new GrantAccessToOTMBatch();
			Database.executeBatch( nextBatch );

		Test.stopTest();

		List<OpportunityTeamMember> otms_After = [SELECT Id, TeamMemberRole, OpportunityId, UserId FROM OpportunityTeamMember];
		
		System.assertEquals(1, otms_After.size(), 'We expect back OTMs for each Account with Open Opps.');
		
		System.assert(otms_After[0].UserId == userTwo.Id, 'We expect the correct OTM to be returned.');
	}
	
	private static testMethod void testBatch_OTMCreation()
	{ 
		setupEmailCustomSettings();

		Test.startTest();

			GrantAccessToOTMBatch nextBatch = new GrantAccessToOTMBatch();
			Database.executeBatch( nextBatch );

		Test.stopTest();

	}

	private static testMethod void testBatch_WithSpecificUserCustomSetting()
	{
		setup();
		setupEmailCustomSettings();
		setupSpecificUserCustomSettings();

		Test.startTest();

			GrantAccessToOTMBatch nextBatch = new GrantAccessToOTMBatch();
			Database.executeBatch( nextBatch );

		Test.stopTest();

		String filterString = BatchServices.generateFilterQueryString( BatchServices.userIdsFromOTMCS );
		String expectedQuery = 'SELECT Id, OpportunityId, TeamMemberRole, UserId, CreatedDate, LastModifiedDate FROM OpportunityTeamMember WHERE UserId IN ' + filterString;
		System.assertEquals( expectedQuery, GrantAccessToOTMBatch.query, 'With Specific User Custom Setting, query string should include filter for getting specific users' );

		List<OpportunityShare> actualOpptyShares = [ SELECT Id, OpportunityAccessLevel FROM OpportunityShare WHERE OpportunityId = :testOppty.Id AND UserOrGroupId = :testOTM.UserId ];

		System.assertEquals( 1, actualOpptyShares.size(), 'There should be one Opportunity Share per Opportunity Team Member' );
		System.assertEquals( BatchServices.EDIT, actualOpptyShares[0].OpportunityAccessLevel, 'The Opportunity Access Level for Opportunity Share should have Read/Write access' );
	}
}
@isTest
private class OpportunityServicesTest {

    static void setupUsersAndCampaigns()
    {
        List<String> userAliasNetwork = new List<String>{'tstAl1', 'tstAl2', 'tstAl3'};
        
        UnitTest.addData( (List<User>) SObjectFactory.build(3, User.sObjectType) )
            .property('UserPermissionsMarketingUser').assign(true)
            .property('Alias').assignFrom(userAliasNetwork)
            .property('Network_Id__c').assignFrom(userAliasNetwork)
            .tag('Campaign Users')
            .branch('Owner 1|Owner 2|Owner 3').insertAll();
            
        User owner1 = (User)UnitTest.get('Owner 1').getList()[0];
        
        UnitTest.addData( (List<Campaign>) SObjectFactory.build(50, Campaign.SObjectType, Campaign.IsActive, true) ).tag('All Campaigns');
        
        System.runAs( owner1 )
        {
            UnitTest.get('All Campaigns').insertAll();
        }
        
        UnitTest.addData( (List<Opportunity>) SObjectFactory.build(100, Opportunity.SObjectType) ).tag('All Opportunities')
            .property('CampaignId').assignFrom('All Campaigns');

        
        /*System.runAs( owner1 )
        {
            UnitTest.get('All Opportunities').insertAll();
        }*/
        
    }
    
    /* Test for Campaign Opportunity Team Member */
    private static testMethod void Test_filterOnCampaignChange()
    {
        setupUsersAndCampaigns();
        
        UnitTest.get('All Opportunities').branch('Changed Opportunities|UnChanged Opportunities');
        
        System.runAs( (User) UnitTest.get('Owner 2').getList()[0] )
        {
            UnitTest.get('All Opportunities').insertAll();
        }
        
        Map<Id, Opportunity> oldOppsMap = new Map<Id, Opportunity>( ((List<Opportunity>) UnitTest.get('All Opportunities').getList()).deepClone(true) );
        
        UnitTest.get('Changed Opportunities')
            .property('CampaignId').assign('7013kd03jd390ga');
            
        List<Opportunity> newOpps = new List<Opportunity>( (List<Opportunity>) UnitTest.get('All Opportunities').getList() );
        
        Test.startTest();
            List<Opportunity> filteredOpps = OpportunityServices.filterOnCampaignChange(oldOppsMap, newOpps);
        Test.stopTest();
        
        UnitTest.analyze('Changed Opportunities').assertEquivalence(filteredOpps, 'We expect the correct Opportunities back.');
    }

    static testMethod void Test_CreateOTMFromCampaigns()
    {
        setupUsersAndCampaigns();
        
        User ownerOne = (User) UnitTest.get('Owner 1').getList()[0];
        
        System.runAs( (User) UnitTest.get('Owner 1').getList()[0] )
        {
            UnitTest.get('All Opportunities').insertAll();
        }
        
        Test.startTest();
            List<OpportunityTeamMember> otms = OpportunityServices.CreateOTMFromCampaigns( (List<Opportunity>) UnitTest.get('All Opportunities').getList());
        Test.stopTest();
        
        for(OpportunityTeamMember otm : otms)
        {
            System.assertEquals(otm.OpportunityAccessLevel, CampaignServices.READ_ACCESS_LEVEL, 'We expect the correct access level.');
            System.assertEquals(otm.UserId, ownerOne.Id, 'We expect the correct User on the OTM.');
        }
    }
    
    static testMethod void Test_InsertOTMs_Success()
    {
        setupUsersAndCampaigns();
        
        Id ownerTwoId = UnitTest.get('Owner 2').getList()[0].Id;
        
        System.runAs( (User) UnitTest.get('Owner 2').getList()[0] )
        {
            UnitTest.get('All Opportunities').insertAll();
        }
        
        List<Opportunity> opps = (List<Opportunity>) UnitTest.get('All Opportunities').getList();
        
        Test.startTest();
            List<OpportunityTeamMember> otms = OpportunityServices.createOTMFromCampaigns(opps);
            OpportunityServices.insertOTMs(otms, opps);
        Test.stopTest();
        
        List<OpportunityTeamMember> allOTMs = [SELECT Id, UserId, OpportunityAccessLevel FROM OpportunityTeamMember];
        
        System.assertEquals(UnitTest.get('All Opportunities').getList().size(), allOTMs.size(), 'We expect the correct number of OTMs.');
    }
    
    static testMethod void Test_InsertOTMs_Fail()
    {
        setupUsersAndCampaigns();
        
        Id ownerTwoId = UnitTest.get('Owner 2').getList()[0].Id;
        
        System.runAs( (User) UnitTest.get('Owner 2').getList()[0] )
        {
            UnitTest.get('All Opportunities').insertAll();
        }
        
        OpportunityServices.OPP_ACCESS_LEVEL = 'BadLevel';
        
        UnitTest.addData( (List<Opportunity>) SObjectFactory.create(1, Opportunity.SObjectType) ).tag('Related Opp');
        UnitTest.addData( (List<OpportunityTeamMember>) SObjectFactory.build(1, OpportunityTeamMember.SObjectType) ).tag('OTM')
                 .property('OpportunityId').assignFrom('Related Opp');
        
        System.runAs( (User) UnitTest.get('Owner 2').getList()[0] )
        {
	        Test.startTest();
	            OpportunityServices.insertOTMs((List<OpportunityTeamMember>)UnitTest.get('OTM').getList(), (List<Opportunity>)UnitTest.get('Related Opp').getList());
	        Test.stopTest();
	        
	        List<OpportunityTeamMember> allOTMs = [SELECT Id, UserId, OpportunityAccessLevel FROM OpportunityTeamMember WHERE UserId =: OwnerTwoId];
	        System.assertEquals(0, allOTMs.size(), 'We expect the correct number of OTMs.');
        }
    }
    
    /* Trigger Test Methods */
    static testMethod void Test_CampaignOwnerOTM_Insert()
    {
        setupUsersAndCampaigns();
        
        User owner1 = (User)UnitTest.get('Owner 1').getList()[0];
        
        Id ownerOneId = UnitTest.get('Owner 1').getList()[0].Id;
        
	    /*Test.startTest();
	        UnitTest.get('All Opportunities').insertAll();
	    Test.stopTest();
		*/
        
        System.runAs( owner1 )
        {
            Test.startTest();
	        	UnitTest.get('All Opportunities').insertAll();
	    	Test.stopTest();
        }
    
        List<OpportunityTeamMember> allOTMs = [SELECT Id, UserId, OpportunityAccessLevel FROM OpportunityTeamMember WHERE UserId =: ownerOneId];
        
        //System.assertEquals(UnitTest.get('All Opportunities').getList().size(), allOTMs.size(), 'We expect the correct number of OTMs.');
        
        for(OpportunityTeamMember otm : allOTMs)
        {
            System.assertEquals(otm.OpportunityAccessLevel, CampaignServices.READ_ACCESS_LEVEL, 'We expect the correct access level.');
            System.assertEquals(otm.UserId, ownerOneId, 'We expect the correct User on the OTM.');
        }
    }
    
    static testMethod void Test_CampaignOwnerOTM_Update()
    {
        setupUsersAndCampaigns();
        
        System.runAs( (User) UnitTest.get('Owner 1').getList()[0] )
        {
            UnitTest.get('All Opportunities').insertAll();
        }
        
        UnitTest.addData( (List<Campaign>) SObjectFactory.build(1, Campaign.SObjectType, Campaign.IsActive, True) ).tag('New Campaign');
        System.runAs( (User) UnitTest.get('Owner 3').getList()[0] )
        {
            UnitTest.get('New Campaign').insertAll();
        }
        
        User owner3 = (User)UnitTest.get('Owner 3').getList()[0];
        
        Id ownerThreeId = UnitTest.get('Owner 3').getList()[0].Id;
        
        Test.startTest();
            UnitTest.get('All Opportunities')
                .property('CampaignId').assignFrom('New Campaign').updateAll();
        Test.stopTest();
        
        List<OpportunityTeamMember> allOTMs = [SELECT Id, UserId, TeamMemberRole, OpportunityAccessLevel FROM OpportunityTeamMember WHERE UserId =: ownerThreeId];
        
        System.assertEquals(UnitTest.get('All Opportunities').getList().size(), allOTMs.size(), 'We expect the correct number of OTMs.');
        
        for(OpportunityTeamMember otm : allOTMs)
        {
            System.assertEquals(otm.OpportunityAccessLevel, OpportunityServices.READ_ACCESS_LEVEL, 'We expect the correct access level.');
            System.assertEquals(otm.UserId, ownerThreeId, 'We expect the correct User on the OTM.');
            System.assertEquals(OpportunityServices.OPP_TEAM_MEMBER_ROLE, otm.TeamMemberRole, 'We expect the correct Team Member Role.');
        }
        
    }
}
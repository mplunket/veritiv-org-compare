@isTest
private class CampaignServicesTest {

    private static List<String> userAliasNetwork = new List<String>{'tstAl1', 'tstAl2'};

    static void setupUsersAndCampaigns()
    {
        UnitTest.addData( (List<User>) SObjectFactory.build(2, User.sObjectType) )
            .property('UserPermissionsMarketingUser').assign(true)
            .property('Alias').assignFrom(userAliasNetwork)
            .property('Network_Id__c').assignFrom(userAliasNetwork)
            .tag('Campaign Users')
            .branch('Owner 1|Owner 2').insertAll();
            
        User owner1 = (User)UnitTest.get('Owner 1').getList()[0];
        
        UnitTest.addData( (List<Campaign>) SObjectFactory.build(50, Campaign.SObjectType, Campaign.IsActive, true) ).tag('All Campaigns');
        
        System.runAs( owner1 )
        {
            UnitTest.get('All Campaigns').insertAll();
        }
        
        UnitTest.addData( (List<Opportunity>) SObjectFactory.build(100, Opportunity.SObjectType) ).tag('All Opportunities')
            .property('CampaignId').assignFrom('All Campaigns');

        System.runAs( owner1 )
        {
            UnitTest.get('All Opportunities').insertAll();
        }
        
    }

    static testMethod void Test_filterCampaignOwnerChange_Update() 
    {
        setupUsersAndCampaigns();
        
        UnitTest.get('All Campaigns').branch('Changed Owner|UnChanged Owner');
        
        Map<Id, Campaign> oldCams = new Map<Id, Campaign>( ((List<Campaign>) UnitTest.get('All Campaigns').getList()).deepClone(true) );
        
        UnitTest.get('Changed Owner')
            .property('OwnerId').assign('Owner 2');
            
        Map<Id, Campaign> newCams = new Map<Id, Campaign>( (List<Campaign>) UnitTest.get('All Campaigns').getList() );
        
        Test.startTest(); 
            List<Campaign> results = CampaignServices.filterCampaignOwnerChange(oldCams, newCams);
        Test.stopTest();
        
        UnitTest.analyze('Changed Owner').assertEquivalence(results, 'We expect the list of returned campaigns to match.');
    }
    
    /* Insert Case is Never Possible */
    /*
    static testMethod void Test_filterCampaignOwnerChange_Insert() 
    {
        setupUsersAndCampaigns();
        
        Map<Id, Campaign> newCams = new Map<Id, Campaign>( ((List<Campaign>) UnitTest.get('All Campaigns').getList()).deepClone(true) );
        
        Test.startTest(); 
            List<Campaign> results = CampaignServices.filterCampaignOwnerChange(NULL, newCams);
        Test.stopTest();
        
        UnitTest.analyze('All Campaigns').assertEquivalence(results, 'We expect the list of returned campaigns to match.');
    }
    */
    
    static testMethod void Test_CreateOTMFromCampaigns()
    {
        setupUsersAndCampaigns();
        
        Id ownerTwoId = UnitTest.get('Owner 2').getList()[0].Id;
        
        UnitTest.get('All Campaigns')
            .property('OwnerId').assign(ownerTwoId);
        
        List<Campaign> campaigns = (List<Campaign>) UnitTest.get('All Campaigns').getList();
        
        Test.startTest();
            CampaignServices.createOTMFromCampaigns( campaigns );
        Test.stopTest();
        
        List<OpportunityTeamMember> allOTMs = [SELECT Id, UserId, OpportunityAccessLevel FROM OpportunityTeamMember WHERE UserId =: OwnerTwoId];
        
        System.assertEquals(UnitTest.get('All Opportunities').getList().size(), allOTMs.size(), 'We expect the correct number of OTMs.');
        
        for(OpportunityTeamMember otm : allOTMs)
        {
            System.assertEquals(otm.OpportunityAccessLevel, CampaignServices.READ_ACCESS_LEVEL, 'We expect the correct access level.');
            System.assertEquals(otm.UserId, ownerTwoId, 'We expect the correct User on the OTM.');
        }
    }
    
    static testMethod void Test_CreateOTMFromCampaigns_ErrorHandling()
    {
        setupUsersAndCampaigns();
        
        Id ownerTwoId = UnitTest.get('Owner 2').getList()[0].Id;
        
        UnitTest.get('All Campaigns')
            .property('OwnerId').assign(ownerTwoId);
        
        List<Campaign> campaigns = (List<Campaign>) UnitTest.get('All Campaigns').getList();
        
        CampaignServices.OPP_ACCESS_LEVEL = 'BadLevel';  
        
        Test.startTest();
                CampaignServices.createOTMFromCampaigns( campaigns );
        Test.stopTest();
        
        List<OpportunityTeamMember> allOTMs = [SELECT Id, UserId, OpportunityAccessLevel FROM OpportunityTeamMember WHERE UserId =: OwnerTwoId];
        
        System.assertEquals(0, allOTMs.size(), 'We expect the correct number of OTMs.');
    }
    
    static testMethod void Test_OTMCreationFlow_Trigger()
    {
        setupUsersAndCampaigns();
        
        Id ownerTwoId = UnitTest.get('Owner 2').getList()[0].Id;
        
        UnitTest.get('All Campaigns').branch('Changed Owner|UnChanged Owner');
        
        UnitTest.get('Changed Owner')
            .property('OwnerId').assign(ownerTwoId);
            
        Map<Id, Campaign> newCams = new Map<Id, Campaign>( (List<Campaign>) UnitTest.get('All Campaigns').getList() );
        
        Test.startTest();
            update newCams.values(); 
        Test.stopTest();
        
        List<OpportunityTeamMember> allOTMs = [SELECT Id, UserId, TeamMemberRole, OpportunityAccessLevel FROM OpportunityTeamMember WHERE UserId =: OwnerTwoId];
        
        System.assertEquals(UnitTest.get('Changed Owner').getList().size() * 2, allOTMs.size(), 'We expect the correct number of OTMs.');
        
        for(OpportunityTeamMember otm : allOTMs)
        {
            System.assertEquals(otm.OpportunityAccessLevel, CampaignServices.READ_ACCESS_LEVEL, 'We expect the correct access level.');
            System.assertEquals(otm.UserId, ownerTwoId, 'We expect the correct User on the OTM.');
            System.assertEquals(CampaignServices.ROLE_PROMO_OWNER, otm.TeamMemberRole, 'We expect the correct Team Member Role.');
        }
    }
    
    /*
    static testMethod void Test_OTMCreationFlow()
    {
        setupUsersAndCampaigns();
        
        Id ownerTwoId = UnitTest.get('Owner 2').getList()[0].Id;
        
        UnitTest.get('All Campaigns').branch('Changed Owner|UnChanged Owner');
        
        Map<Id, Campaign> oldCams = new Map<Id, Campaign>( ((List<Campaign>) UnitTest.get('All Campaigns').getList()).deepClone(true) );
        
        UnitTest.get('Changed Owner')
            .property('OwnerId').assign('Owner 2');
            
        Map<Id, Campaign> newCams = new Map<Id, Campaign>( (List<Campaign>) UnitTest.get('All Campaigns').getList() );
        
        Test.startTest();
            CampaignServices.OTMCreationFlow(oldCams, newCams); 
        Test.stopTest();
        
        List<OpportunityTeamMember> allOTMs = [SELECT Id, UserId, OpportunityAccessLevel FROM OpportunityTeamMember WHERE UserId =: OwnerTwoId];
        
        System.assertEquals(UnitTest.get('All Opportunities').getList().size(), allOTMs.size(), 'We expect the correct number of OTMs.');
        
        for(OpportunityTeamMember otm : allOTMs)
        {
            System.assertEquals(otm.OpportunityAccessLevel, CampaignServices.READ_ACCESS_LEVEL, 'We expect the correct access level.');
            System.assertEquals(otm.UserId, ownerTwoId, 'We expect the correct User on the OTM.');
        }
    }
    */
        
}
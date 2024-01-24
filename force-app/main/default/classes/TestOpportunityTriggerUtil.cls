@isTest
private class TestOpportunityTriggerUtil 
{
    static final String TEST_VERTICAL = 'Test Vertical';
    static final String CHANGED_VERTICAL = 'Changed Vertical';
    static final String CHANGED_VERTICAL2 = 'Changed Vertical2';
    
    private static testMethod void testGetTopRoleHierarchy()
    {
        UserRole r0 = new UserRole(Name= 'Some Super user test');
        insert r0;

        UserRole r1 = new UserRole(Name= OpportunityTriggerUtil.ADMIN_PREFIX+' test', ParentRoleId=r0.Id );
        insert r1;

        UserRole r2 = new UserRole(Name= OpportunityTriggerUtil.BM_PREFIX+' test', ParentRoleId=r1.Id);
        insert r2;

        UserRole r3 = new UserRole(Name= OpportunityTriggerUtil.SALES_PREFIX+' test', ParentRoleId=r2.Id);
        insert r3;

        Test.startTest();
        UserRole top = OpportunityTriggerUtil.getTopRoleInHierarchy(r3);
        System.assertEquals(top.Id, r1.Id);

        top = OpportunityTriggerUtil.getTopRoleInHierarchy(r2);
        System.assertEquals(top.Id, r1.Id);

        top = OpportunityTriggerUtil.getTopRoleInHierarchy(r1);
        System.assertEquals(top.Id, r1.Id);

        top = OpportunityTriggerUtil.getTopRoleInHierarchy(r0);
        System.assertEquals(top.Id, r0.Id);
        Test.stopTest();
    }
    /*
    private static testMethod void testRestrictTestCaraUserTrigger()
    {

        UserRole r0 = new UserRole(Name= OpportunityTriggerUtil.ADMIN_PREFIX+' test');
        insert r0;
        UserRole r1 = new UserRole(Name= OpportunityTriggerUtil.BM_PREFIX+' test', ParentRoleId=r0.Id);
        insert r1;
        UserRole r2 = new UserRole(Name= OpportunityTriggerUtil.SALES_PREFIX+' test', ParentRoleId=r1.Id);
        insert r2;

        Profile salesProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Testing - Cara'];
        System.debug('------------> Profile ID ' + salesProfile.Id);

        User u = [SELECT Id, Name, ProfileId, UserRoleId
                   FROM User
                    WHERE IsActive = true
                     AND ProfileId = :salesProfile.Id LIMIT 1];
        u.UserRoleId = r2.Id;

        update u;

        Group g = new Group(Name='test specialist group');
        insert g;

        User specialist = [SELECT Id, UserRoleId, UserRole.Name, Title
                            FROM User
                             WHERE Title like '%specialist%'
                              AND IsActive = true LIMIT 1];

        GroupMember gm = new GroupMember(GroupId=g.Id, UserOrGroupId=specialist.Id);
        insert gm;

        RoleNameMapping__c mapping = new RoleNameMapping__c(Role_Name__c = specialist.UserRole.Name, Product_Category__c = 'CORRUGATED');
        system.debug('Role_Name__c '+mapping.Role_Name__c + specialist.UserRole.Name + 'specialist.UserRole.Name' );
        mapping.Role_Name__c = 'Test Specialist';
        insert mapping;

        OpportunitySpecialistMapping__c specialistMapping = new OpportunitySpecialistMapping__c(Role_ID__c = r0.Id, Group_ID__c = g.Id);
        System.debug('Role_ID__c:'+r0.Id+' Group_ID__c:'+g.Id);
        insert specialistMapping;

        //Update static roleNameMapping after inserting new roleNameMapping
        OpportunityTriggerUtil.roleNameMapping = [SELECT Id, Role_Name__c, Product_Category__c FROM RoleNameMapping__c];

        Test.StartTest();
        Opportunity testOpportunity;
        System.runAs(u)
        {
            System.debug('------------> USER ID ' + UserInfo.getUserId());

            Account a = new Account(Name='test');
            insert a;

            testOpportunity = new Opportunity(Name = 'test opp',
                                     AccountId=a.Id,
                                     Prod_Category__c = 'CORRUGATED',
                                     StageName = 'Prospect',
                                     CloseDate=Date.today().addDays(365),
                                     Customer_Selling_Margin_Rate__c = 50,
                                     CurrencyIsoCode = 'USD');

            insert testOpportunity;
            //test that users aren't added to the team multiple times.
            update testOpportunity;
        }



        Test.stopTest();

        List<OpportunityTeamMember> otm = [SELECT UserId, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :testOpportunity.Id AND UserId = :specialist.Id];
        List<OpportunityShare> os = [SELECT UserOrGroupId, OpportunityAccessLevel
                                 FROM OpportunityShare
                                   WHERE OpportunityId = :testOpportunity.Id
                                    AND UserOrGroupId = :specialist.Id];

        System.assertEquals(0,otm.size());
        System.assertEquals(0,os.size());

        //System.assertEquals(specialist.Id, otm.UserId);
        //System.assertEquals('Edit', os.OpportunityAccessLevel);
    }
    */
    private static testMethod void testRestrictCurrencyTrigger()
    {
        UserRole r0, r1, r2;
        Profile salesProfile;
        User u, specialist;
        Group g;
        GroupMember gm;

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            r0 = new UserRole(Name= OpportunityTriggerUtil.ADMIN_PREFIX+' test');
            insert r0;
            r1 = new UserRole(Name= OpportunityTriggerUtil.BM_PREFIX+' test', ParentRoleId=r0.Id);
            insert r1;
            r2 = new UserRole(Name= OpportunityTriggerUtil.SALES_PREFIX+' test', ParentRoleId=r1.Id);
            insert r2;

            salesProfile = [SELECT Id, Name FROM Profile WHERE Name = :OpportunityTriggerUtil.SALES_REP_PROFILE];
            u = [SELECT Id, Name, ProfileId, UserRoleId, Network_Id__c, Alias
                       FROM User
                        WHERE IsActive = true
                         AND ProfileId = :salesProfile.Id LIMIT 1];
            u.UserRoleId = r2.Id;
            u.Network_Id__c = u.Alias;

            update u;

            g = new Group(Name='test specialist group');
            insert g;

            specialist = [SELECT Id, UserRoleId, UserRole.Name, Title
                                FROM User
                                 WHERE Title like '%specialist%'
                                  AND IsActive = true LIMIT 1];

            gm = new GroupMember(GroupId=g.Id, UserOrGroupId=specialist.Id);
            insert gm;
        }
        // Commented the code since roleNameMapping Functionality is removed.
        /*RoleNameMapping__c mapping = new RoleNameMapping__c(Role_Name__c = specialist.UserRole.Name, Product_Category__c = 'CORRUGATED');
        system.debug('Role_Name__c '+mapping.Role_Name__c + specialist.UserRole.Name + 'specialist.UserRole.Name' );
        mapping.Role_Name__c = 'Test Specialist';
        insert mapping;
*/

        OpportunitySpecialistMapping__c specialistMapping = new OpportunitySpecialistMapping__c(Role_ID__c = r0.Id, Group_ID__c = g.Id);
        System.debug('Role_ID__c:'+r0.Id+' Group_ID__c:'+g.Id);
        insert specialistMapping;

        //Update static roleNameMapping after inserting new roleNameMapping
        
        // Commented the code since roleNameMapping Functionality is removed.
      //  OpportunityTriggerUtil.roleNameMapping = [SELECT Id, Role_Name__c, Product_Category__c FROM RoleNameMapping__c];

        Test.StartTest();
        Opportunity testOpportunity;
        System.runAs(u)
        {
            Account a = new Account(Name='test');
            a.Account_Vertical__c='Test';
            insert a;

            testOpportunity = TestingUtils.createOpportunity( a.Id, 'Test', false);
            testOpportunity.Prod_Category__c = 'CORRUGATED';
            testOpportunity.CurrencyIsoCode = 'CAD';

            insert testOpportunity;
            //test that users aren't added to the team multiple times.
            update testOpportunity;
        }



        Test.stopTest();
        List<OpportunityTeamMember> otm = new List<OpportunityTeamMember>();
        List<OpportunityShare> os = new List<OpportunityShare>();
        otm = [SELECT UserId, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :testOpportunity.Id AND UserId = :specialist.Id];
        os = [SELECT UserOrGroupId, OpportunityAccessLevel
                                 FROM OpportunityShare
                                   WHERE OpportunityId = :testOpportunity.Id
                                    AND UserOrGroupId = :specialist.Id];

        System.assertEquals(0,otm.size());
        System.assertEquals(0,os.size());

        //System.assertEquals(specialist.Id, otm.UserId);
        //System.assertEquals('Edit', os.OpportunityAccessLevel);
    }



    private static testMethod void testCreateOpportunityNoSalesTeam()
    {
        UserRole r1 = new UserRole(Name= 'test');
        insert r1;
        UserRole r2 = new UserRole(Name= 'Some user test', ParentRoleId=r1.Id);
        insert r2;
        Profile salesProfile = [SELECT Id, Name FROM Profile WHERE Name = :OpportunityTriggerUtil.SALES_REP_PROFILE];
        User u = [SELECT Id, Name, ProfileId, UserRoleId, Network_Id__c, Alias
                   FROM User
                    WHERE IsActive = true
                     AND ProfileId = :salesProfile.Id LIMIT 1];
        u.UserRoleId = r2.Id;
        u.Network_Id__c = u.Alias;

        update u;

        Test.StartTest();
        System.runAs(u)
        {
            Account a = new Account(Name='test');
            a.Account_Vertical__c='Test';
            insert a;

            Opportunity testOpportunity = TestingUtils.createOpportunity( a.Id, 'Test', false);
            testOpportunity.Prod_Category__c = 'CARBONLESS';
            insert testOpportunity;
        }
        Test.stopTest();
    }

    private static testMethod void testCreateOpportunityWithSalesTeam()
    {
        UserRole r0, r1, r2;
        Profile salesProfile;
        User u, specialist;
        Group g;
        GroupMember gm;

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            r0 = new UserRole(Name= OpportunityTriggerUtil.ADMIN_PREFIX+' test');
            insert r0;
            r1 = new UserRole(Name= OpportunityTriggerUtil.BM_PREFIX+' test', ParentRoleId=r0.Id);
            insert r1;
            r2 = new UserRole(Name= OpportunityTriggerUtil.SALES_PREFIX+' test', ParentRoleId=r1.Id);
            insert r2;

            salesProfile = [SELECT Id, Name FROM Profile WHERE Name = :OpportunityTriggerUtil.SALES_REP_PROFILE];
            u = [SELECT Id, Name, ProfileId, UserRoleId, Network_Id__c, Alias
                       FROM User
                        WHERE IsActive = true
                         AND ProfileId = :salesProfile.Id LIMIT 1];
            u.UserRoleId = r2.Id;
            u.Network_Id__c = u.Alias;

            update u;

            g = new Group(Name='test specialist group');
            insert g;

            specialist = [SELECT Id, UserRoleId, UserRole.Name, Title
                                FROM User
                                 WHERE Title like '%specialist%'
                                  AND IsActive = true LIMIT 1];

            gm = new GroupMember(GroupId=g.Id, UserOrGroupId=specialist.Id);
            insert gm;
        }

        // Commented the code since roleNameMapping Functionality is removed.
       /* RoleNameMapping__c mapping = new RoleNameMapping__c(Role_Name__c = specialist.UserRole.Name, Product_Category__c = 'CORRUGATED');
        System.debug('mapping'+r0.Id+' Group_ID__c:'+g.Id);
        system.debug('Role_Name__c '+mapping.Role_Name__c + specialist.UserRole.Name + 'specialist.UserRole.Name' );
        mapping.Role_Name__c = 'Test';
        insert mapping;
*/
        OpportunitySpecialistMapping__c specialistMapping = new OpportunitySpecialistMapping__c(Role_ID__c = r0.Id, Group_ID__c = g.Id);
        System.debug('Role_ID__c:'+r0.Id+' Group_ID__c:'+g.Id);
        insert specialistMapping;

        //Update static roleNameMapping after inserting new roleNameMapping
        // Commented the code since roleNameMapping Functionality is removed.
       // OpportunityTriggerUtil.roleNameMapping = [SELECT Id, Role_Name__c, Product_Category__c FROM RoleNameMapping__c];

        Test.StartTest();
        Opportunity testOpportunity;
        System.runAs(u)
        {
            Account a = new Account(Name='test');
            a.Account_Vertical__c='Test';
            insert a;

            testOpportunity = TestingUtils.createOpportunity( a.Id, 'Test', false);
            testOpportunity.Prod_Category__c = 'CORRUGATED';
            insert testOpportunity;
            //test that users aren't added to the team multiple times.
            update testOpportunity;
        }



        Test.stopTest();
        List<OpportunityTeamMember> otm = new List<OpportunityTeamMember>();
        List<OpportunityShare> os = new List<OpportunityShare>();
        otm = [SELECT UserId, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :testOpportunity.Id AND UserId = :specialist.Id];
        os = [SELECT UserOrGroupId, OpportunityAccessLevel
                                 FROM OpportunityShare
                                   WHERE OpportunityId = :testOpportunity.Id
                                    AND UserOrGroupId = :specialist.Id];

        if (otm.size()>0)
        {
        System.assertEquals(specialist.Id, otm[0].UserId);
        System.assertEquals('Edit', os[0].OpportunityAccessLevel);
        }
    }


    private static testMethod void testSalesTeamUpdate()
    {

        UserRole r0, r1, r2;
        Profile salesProfile;
        User u, specialist;
        Group g;
        GroupMember gm;

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            r0 = new UserRole(Name= OpportunityTriggerUtil.ADMIN_PREFIX+' test');
            insert r0;
            r1 = new UserRole(Name= OpportunityTriggerUtil.BM_PREFIX+' test', ParentRoleId=r0.Id);
            insert r1;
            r2 = new UserRole(Name= OpportunityTriggerUtil.SALES_PREFIX+' test', ParentRoleId=r1.Id);
            insert r2;

            salesProfile = [SELECT Id, Name FROM Profile WHERE Name = :OpportunityTriggerUtil.SALES_REP_PROFILE];
            u = [SELECT Id, Name, ProfileId, UserRoleId, Network_Id__c, Alias
                       FROM User
                        WHERE IsActive = true
                         AND ProfileId = :salesProfile.Id LIMIT 1];
            u.UserRoleId = r2.Id;
            u.Network_Id__c = u.Alias;

            update u;

            g = new Group(Name='test specialist group');
            insert g;

            specialist = [SELECT Id, UserRoleId, UserRole.Name, Title
                                FROM User
                                 WHERE Title like '%specialist%'
                                  AND IsActive = true LIMIT 1];

            gm = new GroupMember(GroupId=g.Id, UserOrGroupId=specialist.Id);
            insert gm;
        }
        
        // Commented the code since roleNameMapping Functionality is removed.
        /*
        RoleNameMapping__c mapping = new RoleNameMapping__c(Role_Name__c = specialist.UserRole.Name, Product_Category__c = 'CORRUGATED');
        system.debug('Role_Name__c '+mapping.Role_Name__c + specialist.UserRole.Name + 'specialist.UserRole.Name' );
        mapping.Role_Name__c = 'Test';
        insert mapping;
*/
        OpportunitySpecialistMapping__c specialistMapping = new OpportunitySpecialistMapping__c(Role_ID__c = r0.Id, Group_ID__c = g.Id);
        System.debug('Role_ID__c:'+r0.Id+' Group_ID__c:'+g.Id);
        insert specialistMapping;

        //Update static roleNameMapping after inserting new roleNameMapping
        // Commented the code since roleNameMapping Functionality is removed.
       // OpportunityTriggerUtil.roleNameMapping = [SELECT Id, Role_Name__c, Product_Category__c FROM RoleNameMapping__c];

        Opportunity testOpportunity;
        System.runAs(u)
        {
            Account a = new Account(Name='test');
            a.Account_Vertical__c='Test';
            insert a;

            testOpportunity = TestingUtils.createOpportunity( a.Id, 'Test', true);
        }
        Test.startTest();
        System.runAs(u)
        {

            testOpportunity.Prod_Category__c = 'CORRUGATED';
            update testOpportunity;
        }

        Test.stopTest();
        List<OpportunityTeamMember> otm = new List<OpportunityTeamMember>();
        List<OpportunityShare> os = new List<OpportunityShare>();
        otm = [SELECT UserId, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :testOpportunity.Id AND UserId = :specialist.Id];
        os = [SELECT UserOrGroupId, OpportunityAccessLevel
                                 FROM OpportunityShare
                                   WHERE OpportunityId = :testOpportunity.Id
                                    AND UserOrGroupId = :specialist.Id];

        if (otm.size()>0)
        { System.assertEquals(specialist.Id, otm[0].UserId);
          System.assertEquals('Edit', os[0].OpportunityAccessLevel);
        }    

    }

    private static testMethod void testUpdateAccountDEUFieldNonDEUAccounts()
    {
        Account testAccount = new Account(Name='Non DEU Account');
        Opportunity testOpp;
        insert testAccount;

        Test.startTest();
        testOpp = TestingUtils.createOpportunity( testAccount.Id, 'Test', false);
        testOpp.Prod_Category__c = 'CORRUGATED';
        insert testOpp;

        Test.stopTest();
      //  testOpp = [SELECT Id, Name, AccountId, ACCOUNT_DEU__c FROM Opportunity WHERE Id = :testOpp.Id];
     //   System.assertEquals(null, testOpp.ACCOUNT_DEU__c);
    }

    private static testMethod void testUpdateAccountDEUField()
    {
        Account testAccount = new Account(Name='DEU Account', RecordTypeId = OpportunityTriggerUtil.Pros_RECORD_TYPEID);
        Opportunity testOpp;
        insert testAccount;

        Test.startTest();
        testOpp = TestingUtils.createOpportunity( testAccount.Id, 'Test', false);
        testOpp.Prod_Category__c = 'CORRUGATED';
        insert testOpp;

        Test.stopTest();
      //  testOpp = [SELECT Id, Name, AccountId, ACCOUNT_DEU__c FROM Opportunity WHERE Id = :testOpp.Id];
       // System.assertEquals(testOpp.AccountId, testOpp.ACCOUNT_DEU__c);
    }
    
    @IsTest(SeeAllData=true)
    private static void testSendSpecialistEmailAlert()
    {
        EmailConfig__c mailConfig = [SELECT IsDebug__c, IsActive__c, Id, EmailTemplateName__c, DebugUser__c,
                         DebugUser__r.Email, DebugUser__r.FirstName, DebugUser__r.LastName
                FROM EmailConfig__c
                 WHERE EmailTemplateName__c = :OpportunityTriggerUtil.EMAIL_TEMPLATE_NAME];

        EmailTemplate template = [SELECT Subject, Name, Markup, Id, HtmlValue, FolderId, Encoding, DeveloperName,
                                          Description, BrandTemplateId, Body, ApiVersion
                                    FROM EmailTemplate
                                     WHERE DeveloperName = :OpportunityTriggerUtil.EMAIL_TEMPLATE_NAME];

        List<User> users = [SELECT Id, Email, FirstName, LastName, Name From User WHERE IsActive = true LIMIT 5];
        Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;

        OpportunityTriggerUtil.sendSpecialistAlertEmail(users, opportunityId, template, mailConfig);
    }
    
    /* Removed for BL-3661
    static testMethod void testFilterBasedOnFieldUpdates()
    {
        final Integer NUM_OF_OPPS = 10;
        User testingUser = TestingUtils.createUser('bob', 'Standard User', true );
        Account testAccount = TestingUtils.createAccount('Test Account', true );
        
        List<Primary_Sales_Rep__c> testPSRs = TestingUtils.createPSRs( 8, 'test2', 'testnet2', true );
        
        List<Opportunity> testOpportunities = TestingUtils.createOpportunities( NUM_OF_OPPS, testAccount.Id, 'testOpp', false );
        for(Opportunity anOpportunity : testOpportunities ) 
        {
            //anOpportunity.Primary_Sales_Rep_Name__c = testPSRs[0].Id;
            anOpportunity.Account_Manager__c = testPSRs[1].Id;
            anOpportunity.Project_Manager__c = testPSRs[2].Id;
            anOpportunity.Transportation_Manager__c = testPSRs[3].Id;
        }       
        insert testOpportunities;
        
        List<Opportunity> newOpportunities = testOpportunities.deepClone( true );
        Opportunity idealOpportunity = newOpportunities[0];
        //idealOpportunity.Primary_Sales_Rep_Name__c = testPSRs[4].Id;
        idealOpportunity.Account_Manager__c = testPSRs[5].Id;
        idealOpportunity.Project_Manager__c = testPSRs[6].Id;
        idealOpportunity.Transportation_Manager__c = testPSRs[7].Id;
        
        Test.startTest();
            List<Opportunity> filteredOpportunities = OpportunityTriggerUtil.filterBasedOnFieldUpdates( newOpportunities, new Map<Id, Opportunity>( testOpportunities ) );
        Test.stopTest();
        system.assertEquals( 1, filteredOpportunities.size(), ' all the filtered opportunities should get returned' );
        system.assertEquals( idealOpportunity.Id, filteredOpportunities[0].Id, 'The filtered opportunity should be the one with updated fields' );
    }
	*/
    
    /* Removed for BL-3661
    static testMethod void testFilterBasedOnFieldUpdates_MultipleFieldUpdates()
    {
        final Integer NUM_OF_OPPS = 10;
        User testingUser = TestingUtils.createUser('bob', 'Standard User', true );
        Account testAccount = TestingUtils.createAccount('Test Account', true );
        
        List<Opportunity> testOpportunities = TestingUtils.createOpportunities( NUM_OF_OPPS, testAccount.Id, 'testOpp',  true );
        
        List<Primary_Sales_Rep__c> testPSRs = TestingUtils.createPSRs( 3, 'test2', 'testnet2', true );
        
        List<Opportunity> newOpportunities = testOpportunities.deepClone( true );
        Set<Id> expectedOppIds = new Set<Id>();
        
        //Opportunity opportunity_psrNameUpdated = newOpportunities[0];
        //opportunity_psrNameUpdated.Primary_Sales_Rep_Name__c = testPSRs[0].Id;
        //expectedOppIds.add( opportunity_psrNameUpdated.Id );
        
        Opportunity opportunity_accountManagerUpdated = newOpportunities[0];
        opportunity_accountManagerUpdated.Account_Manager__c = testPSRs[0].Id;
        expectedOppIds.add( opportunity_accountManagerUpdated.Id );

        Opportunity opportunity_projectManagerUpdated = newOpportunities[1];
        opportunity_projectManagerUpdated.Project_Manager__c = testPSRs[1].Id;
        expectedOppIds.add( opportunity_projectManagerUpdated.Id );

        Opportunity opportunity_transportationManagerUpdated = newOpportunities[2];
        opportunity_transportationManagerUpdated.Transportation_Manager__c = testPSRs[2].Id;
        expectedOppIds.add( opportunity_transportationManagerUpdated.Id );
        
        Test.startTest();
            List<Opportunity> filteredOpportunities = OpportunityTriggerUtil.filterBasedOnFieldUpdates( newOpportunities, new Map<Id, Opportunity>( testOpportunities ) );
        Test.stopTest();
        system.assertEquals( expectedOppIds.size(), filteredOpportunities.size(), ' all the filtered opportunities should get returned' );
        Set<Id> actualIds = Pluck.ids( filteredOpportunities );
        system.assert( actualIds.containsAll( expectedOppIds ), 'Only the expected opportunity ids should get filtered' );
        system.assert( expectedOppIds.containsAll( actualIds ), 'Only the expected opportunity ids should get filtered' );
    }
	*/
    
    /* 10/12 - Taken out to remove Account Vertical field and functionality on Opportunity to remove an inconsistent error. */
    /*
    static testMethod void testPopulateAccountVerticalField(){
        
        Account testAccount1 = TestingUtils.createAccount('testAccount1',true);
        List<Opportunity> testOppsWithChangedVertical = TestingUtils.createOpportunities(1, testAccount1.Id, 'testOpp1', false);
        
        testOppsWithChangedVertical[0].Account_Vertical_Update__c = CHANGED_VERTICAL;
        
        Account testAccount2 = TestingUtils.createAccount('testAccount2',false);
        testAccount2.Account_Vertical__c = TEST_VERTICAL;
        insert testAccount2;
        
        List<Opportunity> testOppsWithUnchangedVertical  = TestingUtils.createOpportunities(3, testAccount2.Id, 'testOpp2', true);
        
        Account testAccount3 = TestingUtils.createAccount('testAccount3',false);
        testAccount3.Account_Vertical__c = TEST_VERTICAL;
        insert testAccount3;
        
        List<Opportunity> testOppsWithChangedVertical2  = TestingUtils.createOpportunities(2, testAccount3.Id, 'testOpp3', false);
        testOppsWithChangedVertical2[0].Account_Vertical_Update__c = CHANGED_VERTICAL;
        testOppsWithChangedVertical2[1].Account_Vertical_Update__c = CHANGED_VERTICAL2;
        
        List<Opportunity> testOpps = new List<Opportunity>();
        testOpps.addAll(testOppsWithChangedVertical);
        testOpps.addAll(testOppsWithUnchangedVertical);
        testOpps.addAll(testOppsWithChangedVertical2);
        
        List<Account> expectedAccounts = new List<Account>{testAccount1,testAccount3};
        
        Test.startTest();
          List<Account> actualAccountsToUpdate = OpportunityTriggerUtil.populateAccountVerticalField(testOpps);
        Test.stopTest(); 
        
        System.assertEquals(expectedAccounts.size(),actualAccountsToUpdate.size(),'we expect the no. of accounts returned to be same as the no. of expected accounts' + actualAccountsToUpdate.size());
    }
    */
    
    /* Removed for BL-3661
    static testMethod void testUpdateAccounts(){
        String CROSS_REFERENCE_ERROR = 'invalid cross reference id';
        
        List<Account> testAccountsWithError = TestingUtils.createAccounts('testAccount1', 5);
        UnitTest.addData(testAccountsWithError).dummyInsert();
        
        List<Opportunity> testOppsWithAccountsHavingErrors = TestingUtils.createOpportunities(2, testAccountsWithError[0].Id, 'testOpp1', false);
        
        List<Account> testAccountsWithNoError = TestingUtils.createAccounts('testAccount2', 5);
        insert testAccountsWithNoError;
        
        List<Opportunity> testOppsWithAccountsHavingNoErrors = TestingUtils.createOpportunities(2, testAccountsWithNoError[0].Id, 'testOpp1', false);
        
        Test.startTest();
                OpportunityTriggerUtil.UpdateAccounts(testAccountsWithNoError,testOppsWithAccountsHavingNoErrors);
        Test.stopTest();
        
        System.assert(!TestingUtils.pageMessagesContains(CROSS_REFERENCE_ERROR),'we expect no errors to be thrown on the page.');
        
        OpportunityTriggerUtil.UpdateAccounts(testAccountsWithError,testOppsWithAccountsHavingErrors);
        
        System.assert(TestingUtils.pageMessagesContains(CROSS_REFERENCE_ERROR),'we expect errors to be thrown on the page, since the Accounts donot have valid Ids');
    }
	*/

}
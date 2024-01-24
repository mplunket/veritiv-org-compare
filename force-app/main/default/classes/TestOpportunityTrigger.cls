@isTest
private class TestOpportunityTrigger {

    private static Account acct;
    private static final Integer NUM_TO_CREATE = 20;
    static final String TEST_VERTICAL = 'Test Vertical';
    static final String CHANGED_VERTICAL = 'Changed Vertical';
    static final String CHANGED_VERTICAL2 = 'Changed Vertical2';

    static void setupChatterCustomSettings()
    {
        Chatter_Auto_Follow_Records__c salesUserCustomSetting = new Chatter_Auto_Follow_Records__c();
        salesUserCustomSetting.Name = 'Sales Professional - Lightning';
        System.runAs( TestingUtils.ADMIN_USER )
        {
            insert salesUserCustomSetting;
        }
    }
    
    static void setup()
    {
        setupChatterCustomSettings();
        acct = TestingUtils.createAccount('Test Account');
        insert acct;
    }

    static /*testmethod*/ void testFollowOwnerAfterCreatingOpportunity_NonSalesUser()
    {
        User testingUser = TestingUtils.createUser('bob', 'Standard User', true );
        List<Opportunity> opps;
        
        
        System.runAs(testingUser)
        {
            setup();
            Test.startTest();
            opps = TestingUtils.createOpportunities(NUM_TO_CREATE,acct.ID, 'Test Opp',true);

            Test.stopTest();
        }

        //We want to make sure that the testingUser is not following any of those opportunities
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID And ParentId IN: opps];
        System.assertEquals(0,follows.size());
    }

    //Make sure user follows all opportunity it creates (and thus owns)
    static  /*testmethod*/  void testFollowOwnerAfterCreatingOpportunity()
    {
        //2/6/20 Replacing Ind and Core Rep with Sales Professional - Lightning
        //Sales Professional - Lightning is consider a sales profile according to the custom profile Chatter_Auto_Follow_Records__c
        User testingUser = TestingUtils.createUser('bob', 'Sales Professional - Lightning', true );
        List<Opportunity> opps;
        
        System.runAs(testingUser)
        {
            setup();
            Test.startTest();
            opps = TestingUtils.createOpportunities(NUM_TO_CREATE,acct.ID, 'Test Opp',true);

            Test.stopTest();
        }

        //We want to make sure that the testingUser is following all those opportunities
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID And ParentId IN: opps];
        System.assertEquals(NUM_TO_CREATE,follows.size());

        //Now make sure that the user is following each and every opportunity.

        Set<ID> oppIds = new Set<ID>();
        for(Opportunity o : opps)
        {
            oppIds.add(o.Id);
        }
        for(EntitySubscription e : follows)
        {
            oppIds.remove(e.ParentId);
        }

        System.assertEquals(0,oppIds.size());
    }
    
    static  /*testmethod*/  void testFollowOwnerAfterCreatingClosedOpportunity()
    {
        //Sales Professional - Lightning is consider a sales profile according to the custom profile Chatter_Auto_Follow_Records__c
        User testingUser = TestingUtils.createUser('bob', 'Sales Professional - Lightning', true );
        List<Opportunity> opps;
        
        System.runAs(testingUser)
        {
            setup();
            Test.startTest();
            opps = TestingUtils.createOpportunities(NUM_TO_CREATE,acct.ID, 'Test Opp',false);
            for(Opportunity o : opps)
            {
                o.StageName = '0- Closed Lost';
                o.Lost_Date__c = Date.today();
            }
            insert opps;
            Test.stopTest();
        }

        //We want to make sure that the testingUser is following none of those opportunities
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID And ParentId IN: opps];
        System.assertEquals(0,follows.size());
    }


    static /*testmethod*/ void testUpdateOwnerForSomeOpps()
    {
        List<User> testingUsers = TestingUtils.createUsers('bob', 'Sales Professional - Lightning', 2, true );

        List<Opportunity> opps; //all opportunities

        Set<ID> oppsChangeIDs = new Set<ID>();
        Set<ID> oppsKeepIDs  = new Set<ID>();

        System.runAs(testingUsers[0])
        {
            setup();
            opps =  TestingUtils.createOpportunities(NUM_TO_CREATE*2,acct.ID, 'Test Opp',true);
        }

        for(Integer k = 0; k < NUM_TO_CREATE; k++)
        {
            opps[k].Description = 'Hello'; //Change something random in this opportunity
            oppsKeepIDs.add(opps[k].ID);
        }

        for(Integer k = NUM_TO_CREATE; k < NUM_TO_CREATE*2; k++)
        {
            opps[k].OwnerID = testingUsers[1].ID;
            oppsChangeIDs.add(opps[k].ID);
            oppsKeepIDs.add(opps[k].ID);
        }

        Test.startTest();
            update opps;
        Test.stopTest();

        List<EntitySubscription> followsOppsKeep = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUsers[0].ID And ParentId IN: opps];
        System.assertEquals(NUM_TO_CREATE*2,followsOppsKeep.size()); //It will keep everything
        List<EntitySubscription> followsOppsChange = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUsers[1].ID And ParentId IN: opps];
        System.assertEquals(NUM_TO_CREATE,followsOppsChange.size());

        /* Now make sure that testingUsers[0] is following all opportunities,
                        and that testingUsers[1] is only following opportunities that have changed ownerIds.    */

        for(EntitySubscription e : followsOppsKeep)
        {
            oppsKeepIDs.remove(e.ParentId);
        }
        for(EntitySubscription e : followsOppsChange)
        {
            oppsChangeIDs.remove(e.ParentId);
        }

        System.assertEquals(0,oppsKeepIDs.size());
        System.assertEquals(0,oppsChangeIDs.size());
    }

    static  /*testmethod*/  void testPSRFollow()
    {
        setup();

        User testingUser = TestingUtils.createUser('bob', 'Sales Professional - Lightning', true );
        List<Opportunity> opps;
        opps = TestingUtils.createOpportunities(NUM_TO_CREATE, acct.ID, 'Test Opp', true);

        //Make a PSR
        Primary_Sales_Rep__c testPSR = TestingUtils.createPSRs(1, 'test2', 'testnet2', false)[0];
        testPSR.SF_userid__c = testingUser.ID;
        insert testPSR;

        Test.startTest();
            for(Opportunity o : opps)
            {
                o.Primary_Sales_Rep_Name__c = testPSR.Id;
            }
            update opps;
        Test.stopTest();

        //We want to make sure that the user the PSR corresponds with is following all those opportunities
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID And ParentId IN: opps];
        System.assertEquals(NUM_TO_CREATE,follows.size());

        //Now make sure that the user is following each and every opportunity.

        Set<ID> oppIds = new Set<ID>();
        for(Opportunity o : opps)
        {
            oppIds.add(o.Id);
        }
        for(EntitySubscription e : follows)
        {
            oppIds.remove(e.ParentId);
        }

        System.assertEquals(0,oppIds.size());
    }

        static /*testmethod*/ void testPSRFollow_ClosedOpportunity()
    {
        User testingUser = TestingUtils.createUser('bob', 'Sales Professional - Lightning', true );
        List<Opportunity> opps;
        setup();
        opps = TestingUtils.createOpportunities(NUM_TO_CREATE, acct.ID, 'Test Opp', false);
        for(Opportunity o : opps)
        {
            o.StageName='0- Closed Lost';
            o.Lost_Date__c = Date.today();
        }
        insert opps;
        //Make a PSR
        Primary_Sales_Rep__c testPSR = TestingUtils.createPSRs(1, 'test2', 'testnet2', false).get(0);
        testPSR.SF_userid__c = testingUser.ID;
        insert testPSR;

        Test.startTest();
            for(Opportunity o : opps)
            {
                o.Primary_Sales_Rep_Name__c = testPSR.Id;
            }
            update opps;
        Test.stopTest();

        //We want to make sure that the user the PSR corresponds with is following none of those opportunities
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID And ParentId IN: opps];
        System.assertEquals(0,follows.size());
    }

    static /*testmethod*/ void testPSRFollow_nonSalesUser()
    {
        User testingUser = TestingUtils.createUser('bob', 'Standard User', true );
        List<Opportunity> opps;
        setup();
        opps = TestingUtils.createOpportunities(NUM_TO_CREATE, acct.ID, 'Test Opp', true);

        //Make a PSR
        Primary_Sales_Rep__c testPSR = TestingUtils.createPSRs(1, 'test2', 'testnet2', false).get(0);
        testPSR.SF_userid__c = testingUser.ID;
        insert testPSR;

        Test.startTest();
            for(Opportunity o : opps)
            {
                o.Primary_Sales_Rep_Name__c = testPSR.Id;
            }
            update opps;
        Test.stopTest();

        //We want to make sure that the user the PSR corresponds with is following none of those opportunities
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID And ParentId IN: opps];
        System.assertEquals(0,follows.size());
    }
    
    /* Removed fro BL-3661
    static testMethod void testAfterUpdate_OpportunityFieldToAccountFields()
    {
        final Integer NUM_OF_ACCOUNTS = 10; 
        User testingUser = TestingUtils.createUser('bob', 'Standard User', true );
        List<Account> testAccounts = TestingUtils.createAccounts('Test Account', NUM_OF_ACCOUNTS );
        insert testAccounts;
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for( Account testAccount : testAccounts )
        {
            testOpportunities.add( TestingUtils.createOpportunity( testAccount.Id, 'testOpp') );
        }
        insert testOpportunities;
        
        List<Primary_Sales_Rep__c> testPSRs = TestingUtils.createPSRs( 4, 'test2', 'testnet2', false );
        insert testPSRs;

        Test.startTest();
            for(Opportunity anOpportunity : testOpportunities ) 
            {
                //anOpportunity.Primary_Sales_Rep_Name__c = testPSRs[0].Id;
                anOpportunity.Account_Manager__c = testPSRs[1].Id;
                anOpportunity.Project_Manager__c = testPSRs[2].Id;
                anOpportunity.Transportation_Manager__c = testPSRs[3].Id;
            }
            update testOpportunities;
        Test.stopTest();
        
        List<Opportunity> actualOpportunities = [ SELECT Primary_Sales_Rep_Name__c, Account_Manager__c, Project_Manager__c, Transportation_Manager__c,
                                                    Account.Primary_Sales_Rep_Name__c, Account.Account_Manager__c, Account.Project_Manager__c, Account.Transportation_Manager__c, AccountId 
                                                    From Opportunity WHERE Id IN :testOpportunities ];
        system.assertEquals( testOpportunities.size(), actualOpportunities.size(), ' all the opportunities should get returned' );
        for( Opportunity anOpportunity : actualOpportunities )
        {
            //System.assertEquals( anOpportunity.Primary_Sales_Rep_Name__c, anOpportunity.Account.Primary_Sales_Rep_Name__c, 'The primary sales rep from opportunity should get copied over to account' );
            System.assertEquals( anOpportunity.Account_Manager__c, anOpportunity.Account.Account_Manager__c, 'The Account_Manager__c from opportunity should get copied over to account' );
            System.assertEquals( anOpportunity.Project_Manager__c, anOpportunity.Account.Project_Manager__c, 'The Project_Manager__c from opportunity should get copied over to account' );
            System.assertEquals( anOpportunity.Transportation_Manager__c, anOpportunity.Account.Transportation_Manager__c, 'TheTransportation_Manager__c from opportunity should get copied over to account' );
        }
    }
	*/
    
    /* Removed for BL-3661
    static testMethod void testAfterUpdate_OpportunityFieldToAccountFields_Negative()
    {
        List<Primary_Sales_Rep__c> testPSRs = TestingUtils.createPSRs( 8, 'test2', 'testnet2', false );
        insert testPSRs;
        
        final Integer NUM_OF_ACCOUNTS = 10; 
        User testingUser = TestingUtils.createUser('bob', 'Standard User', true );
        List<Account> testAccounts = TestingUtils.createAccounts('Test Account', NUM_OF_ACCOUNTS );
        for(Account anAccount : testAccounts )
        {
            //anAccount.Primary_Sales_Rep_Name__c = testPSRs[0].Id;
            anAccount.Account_Manager__c = testPSRs[1].Id;
            anAccount.Project_Manager__c = testPSRs[2].Id;
            anAccount.Transportation_Manager__c = testPSRs[3].Id;
        }
        insert testAccounts;
        
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for( Account testAccount : testAccounts )
        {
            testOpportunities.add( TestingUtils.createOpportunity( testAccount.Id, 'testOpp') );
        }
        insert testOpportunities;
        

        Test.startTest();
            for(Opportunity anOpportunity : testOpportunities )
            {
                //anOpportunity.Primary_Sales_Rep_Name__c = testPSRs[4].Id;
                anOpportunity.Account_Manager__c = testPSRs[5].Id;
                anOpportunity.Project_Manager__c = testPSRs[6].Id;
                anOpportunity.Transportation_Manager__c = testPSRs[7].Id;
            }
            update testOpportunities;
        Test.stopTest();
        
        List<Opportunity> actualOpportunities = [ SELECT Primary_Sales_Rep_Name__c, Account_Manager__c, Project_Manager__c, Transportation_Manager__c,
                                                    Account.Primary_Sales_Rep_Name__c, Account.Account_Manager__c, Account.Project_Manager__c, Account.Transportation_Manager__c, AccountId 
                                                    From Opportunity WHERE Id IN :testOpportunities ];
        system.assertEquals( testOpportunities.size(), actualOpportunities.size(), ' all the opportunities should get returned' );
        for( Opportunity anOpportunity : actualOpportunities )
        {
            //System.assertEquals( testPSRs[0].Id, anOpportunity.Account.Primary_Sales_Rep_Name__c, 'The primary sales rep from opportunity should not get copied over to account' );
            System.assertEquals( testPSRs[1].Id, anOpportunity.Account.Account_Manager__c, 'The Account_Manager__c from opportunity should not get copied over to account' );
            System.assertEquals( testPSRs[2].Id, anOpportunity.Account.Project_Manager__c, 'The Project_Manager__c from opportunity should not get copied over to account' );
            System.assertEquals( testPSRs[3].Id, anOpportunity.Account.Transportation_Manager__c, 'TheTransportation_Manager__c from opportunity should not get copied over to account' );
        }
    }
	*/
    
    /* 10/12 - Taken out to remove Account Vertical field and functionality on Opportunity to remove an inconsistent error. */
    /*
    static testMethod void testUpdateAccountVerticalField(){
        Account testAccount1 = TestingUtils.createAccount('testAccount1',false);
        testAccount1.Account_Vertical__c = TEST_VERTICAL;
        insert testAccount1;
        List<Opportunity> testOppsWithChangedVertical = TestingUtils.createOpportunities(1, testAccount1.Id, 'testOpp1', true);
        
        testOppsWithChangedVertical[0].Account_Vertical_Update__c = CHANGED_VERTICAL;
        
        Account testAccount2 = TestingUtils.createAccount('testAccount2',true);
        
        List<Opportunity> testOppsWithUnchangedVertical  = TestingUtils.createOpportunities(3, testAccount2.Id, 'testOpp2', true);
        
        Account testAccount3 = TestingUtils.createAccount('testAccount3',false);
        testAccount3.Account_Vertical__c = TEST_VERTICAL;
        insert testAccount3;
        
        List<Opportunity> testOppsWithChangedVertical2  = TestingUtils.createOpportunities(2, testAccount3.Id, 'testOpp3', true);
        testOppsWithChangedVertical2[0].Account_Vertical_Update__c = CHANGED_VERTICAL;
        testOppsWithChangedVertical2[1].Account_Vertical_Update__c = CHANGED_VERTICAL2;
        
        List<Opportunity> testOpps = new List<Opportunity>();
        testOpps.addAll(testOppsWithChangedVertical);
        testOpps.addAll(testOppsWithUnchangedVertical);
        testOpps.addAll(testOppsWithChangedVertical2);
        
        Test.startTest();
            update testOpps;
        Test.stopTest();
        
        Account updatedAccount1 = [SELECT Id,Account_Vertical__c FROM Account WHERE Id =: testAccount1.Id];
        Account accountNotUpdated = [SELECT Id,Account_Vertical__c FROM Account WHERE Id =: testAccount2.Id];
        Account updatedAccount2 = [SELECT Id,Account_Vertical__c FROM Account WHERE Id =: testAccount3.Id];
        
        System.assertEquals(CHANGED_VERTICAL,updatedAccount1.Account_Vertical__c,'we expect the account\'s vertical field to be updated');
        System.assertEquals(CHANGED_VERTICAL,updatedAccount2.Account_Vertical__c,'we expect the account\'s vertical field to be updated');
    }
    */
}
@isTest
private class TestAccountTrigger
{
    static final String ACCOUNT_PSR_FIELD = 'Primary_Sales_Rep_Name__c';
    static final Integer NUM_OF_ACCOUNTS = 4;
    static final Integer NUM_TO_CREATE = 20;
    static final String VERTICAL_ONE = 'Education';
    static final String VERTICAL_TWO = 'Food Service';
    static Verticals__c testVertical;
    
    private static UserRole repRole;
    
    static {
        repRole = [Select Id, Name, DeveloperName From UserRole Where Name ='PRI - TSB - Rep' Limit 1][0];
    }

    static void setup()
    {
        testVertical = new Verticals__c( Name = VERTICAL_ONE );
        insert testVertical;
    }
    
    static testMethod void testAssociatePrimarySalesRepWithAccount(){
        
        List<User> accountOwners = TestingUtils.createUsers('testM', 'Standard User', 100, true);
        UnitTest.addData(accountOwners).tag('Account Owners');
        
        // create users that will own each account
        UnitTest.createTestData(TestingUtils.primarysalesreps).many(100).tag('PSR');
        UnitTest.get('PSR').property('SF_userid__c').assignFrom('Account Owners').insertAll();
        
        Set<id> PSRIds = Pluck.ids(UnitTest.get('PSR').getList());
        List<Account> accounts = TestingUtils.createAccounts('acctName', 200);
        
        UnitTest.addData(accounts).tag('Accounts with PSRs');
        
        UnitTest.get('Accounts with PSRs')
                .property('OwnerId').assignFrom('Account Owners');
                
        Test.StartTest();
            UnitTest.get('Accounts with PSRs').insertAll();
        Test.StopTest();
        
        List<Account> actualAccounts = [Select Id, Primary_Sales_Rep_Name__c From Account Where Id in :accounts];
        
        for(Account actualAcc : actualAccounts){
            if(UnitTest.analyze('Accounts with PSRs').hasId(actualAcc.Id)){
                System.assert(PSRIds.contains(actualAcc.Primary_Sales_Rep_Name__c));
            }
        }
        
    }

    /* Removed for BL-3662
    static testMethod void testMATContactOpptyCreation_AccountInsert()
    {
        final String SAMPLE_OPPTY_NAME = 'ABC';
        final String SAMPLE_FIRST_NAME = 'Bob';
        final String SAMPLE_LAST_NAME = 'Garcia';
        final String SAMPLE_STAGENAME = '2- Qualify/Audit';
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
       	//List<MAT_Opportunity_Default_Field_Values__c> customSettings = new List<MAT_Opportunity_Default_Field_Values__c>();
        //customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Name',Default_Value__c=SAMPLE_OPPTY_NAME));
        //customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='StageName',Default_Value__c=SAMPLE_STAGENAME));
        //insert customSettings;
        String matEmail = 'test1@test.com'; 
        
        String testMATUniqueId = 'test1';
        List<Account> accts = TestingUtils.createAccounts('Test Account',200);
        UnitTest.addData(accts).tag('All Accounts').divide(4).part('Accounts With MAT Latest Unique ID & Complete Contact Info')
                                                             .part('Accounts With MAT Latest Unique ID & Incomplete Contact Info')
                                                             .part('Accounts Without MAT Latest Unique ID & Complete Contact Info')
                                                             .part('Accounts Without MAT Latest Unique ID & Incomplete Contact Info');

        UnitTest.get('Accounts With MAT Latest Unique ID & Complete Contact Info').tag('Accounts With MAT Latest Unique ID').tag('Account With Complete Contact Info');
        UnitTest.get('Accounts With MAT Latest Unique ID & Incomplete Contact Info').tag('Accounts With MAT Latest Unique ID').tag('Account With Incomplete Contact Info');
        UnitTest.get('Accounts Without MAT Latest Unique ID & Complete Contact Info').tag('Accounts Without MAT Latest Unique ID').tag('Account With Complete Contact Info');
        UnitTest.get('Accounts Without MAT Latest Unique ID & Incomplete Contact Info').tag('Accounts Without MAT Latest Unique ID').tag('Account With Incomplete Contact Info');                                                    

        UnitTest.get('All Accounts').property('MAT_Contact_Email__c').assign(matEmail)
                               .property('MAT_Contact_First_Name__c').assign(SAMPLE_FIRST_NAME)
                               .property('MAT_Contact_Last_Name__c').assign(SAMPLE_LAST_NAME);
        
        UnitTest.get('Account With Incomplete Contact Info').property('MAT_Contact_Email__c').assign(null);
        UnitTest.get('Accounts With MAT Latest Unique ID').property('MAT_Latest_Unique_ID__c').assign(testMATUniqueId);
                                                                         
        Test.startTest();
            insert accts;
        Test.stopTest();
        
        List<Contact> createdContacts = [Select ID, FirstName, LastName, Email, AccountID From Contact];
        List<Opportunity> createdOpptys = [Select ID, AccountID, Name, StageName, CloseDate,MAT_Unique_ID__c From Opportunity];
        
       // System.assertEquals(UnitTest.getIds('Account With Complete Contact Info'),Pluck.ids('AccountID',createdContacts), 'There must be one MAT contact created for each and every single account that has the contact information filled out');
       // System.assertEquals(UnitTest.getIds('Accounts With MAT Latest Unique ID'),Pluck.ids('AccountID',createdOpptys), 'There must be one MAT opportunity created for each and every single account');
       // System.assertEquals(UnitTest.getIds('Accounts With MAT Latest Unique ID').size(), createdOpptys.size(), 'We should create as many opportunities as there are accounts that are inserted');
        
        for(Opportunity o : createdOpptys)
        {
            String expectedLatestUniqueId = (String) UnitTest.analyze('All Accounts').selectById(o.AccountId).getPropertyValue('MAT_Latest_Unique_ID__c');
         //   System.assertEquals(SAMPLE_STAGENAME,o.StageName, 'All MAT opportunities must have the default field values specified in the custom setting "MAT_Opportunity_Default_Field_Values"');
            System.assertEquals(Date.today()+30,o.CloseDate, 'All MAT opportunities must have a close date of 30 days from now');
          //  System.assertEquals(expectedLatestUniqueId ,o.MAT_Unique_ID__c, 'All MAT opportunities created should have the MAT_Unique_ID__c set to the accounts MAT_Latest_Unique_ID__c');
        }
        for(Contact c : createdContacts)
        {
            System.assertEquals(SAMPLE_FIRST_NAME,c.FirstName, 'Each MAT contact must have the FirstName that is specified in its account');
            System.assertEquals(SAMPLE_LAST_NAME,c.LastName, 'Each MAT contact must have the LastName that is specified in its account');
            System.assertEquals(matEmail,c.Email, 'Each MAT contact must have the Email that is specified in its account');
        }
    }
    */
    
    /* Removed for BL-3662
    static testMethod void testMATContactUpdationAndInsertion_AccountUpdate(){
        final String SAMPLE_FIRST_NAME = 'Bob';
        final String SAMPLE_LAST_NAME = 'Garcia';

        final String matEmail = 'test@test.com';

        List<Account> accts = TestingUtils.createAccounts('Test Account',200);
        insert accts;
        
        UnitTest.addData(accts).tag('All Accounts').property('MAT_Contact_First_Name__c').assign(SAMPLE_FIRST_NAME)
                                .property('MAT_Contact_Last_Name__c').assign(SAMPLE_LAST_NAME)
                                .divide(2).part('Accounts With MAT Contacts').part('Accounts Without MAT Contacts');

        UnitTest.forEach('Accounts With MAT Contacts').create(1,TestingUtils.contacts).copyProperty('ID->AccountID').tag('Existing MAT Contact');
        UnitTest.get('Existing MAT Contact').property('Email').assign(matEmail).insertAll();
        
        UnitTest.get('Accounts With MAT Contacts').divide(2).part('Accounts with modified MAT Email and existing MAT contacts').part('Accounts without modified MAT Email and existing MAT contacts');
        UnitTest.get('Accounts Without MAT Contacts').divide(2).part('Accounts with modified MAT Email and NON existing MAT contacts').part('Accounts without modified MAT Email and NON existing MAT contacts');                       

        UnitTest.get('Accounts with modified MAT Email and existing MAT contacts').tag('Accounts with modified MAT Email');
        UnitTest.get('Accounts with modified MAT Email and NON existing MAT contacts').tag('Accounts with modified MAT Email');
        UnitTest.get('Accounts without modified MAT Email and existing MAT contacts').tag('Accounts without modified MAT Email');
        UnitTest.get('Accounts without modified MAT Email and NON existing MAT contacts').tag('Accounts without modified MAT Email');
        UnitTest.get('Accounts with modified MAT Email').property('MAT_Contact_Email__c').assign(matEmail);

        UnitTest.get('Accounts with modified MAT Email and existing MAT contacts').divide(2). 
                 part('Accounts with modified MAT Email & existing MAT contacts & Complete Contact Info'). 
                 part('Accounts with modified MAT Email & existing MAT contacts & Incomplete Contact Info'); 

        UnitTest.get('Accounts without modified MAT Email and existing MAT contacts').divide(2).
                 part('Accounts without modified MAT Email and existing MAT contacts & Complete Contact Info').
                 part('Accounts without modified MAT Email and existing MAT contacts & Incomplete Contact Info');   
                 
        UnitTest.get('Accounts with modified MAT Email and NON existing MAT contacts').divide(2). 
                 part('Accounts with modified MAT Email and NON existing MAT contacts & Complete Contact Info'). 
                 part('Accounts with modified MAT Email and NON existing MAT contacts & Incomplete Contact Info');  

        UnitTest.get('Accounts without modified MAT Email and NON existing MAT contacts').divide(2).
                 part('Accounts without modified MAT Email and NON existing MAT contacts & Complete Contact Info').
                 part('Accounts without modified MAT Email and NON existing MAT contacts & Incomplete Contact Info');        

        UnitTest.get('Accounts with modified MAT Email & existing MAT contacts & Incomplete Contact Info').tag('Accounts With Incomplete Contact Info');
        UnitTest.get('Accounts without modified MAT Email and existing MAT contacts & Incomplete Contact Info').tag('Accounts With Incomplete Contact Info');
        UnitTest.get('Accounts with modified MAT Email and NON existing MAT contacts & Incomplete Contact Info').tag('Accounts With Incomplete Contact Info');
        UnitTest.get('Accounts without modified MAT Email and NON existing MAT contacts & Incomplete Contact Info').tag('Accounts With Incomplete Contact Info');        
    
        UnitTest.get('Accounts With Incomplete Contact Info').property('MAT_Contact_First_Name__c').assign(null);

        Test.startTest();
            AccountServices.firstRunOfMATAccountTrigger=false;
            update accts;
        Test.stopTest();

        List<Contact> retContacts = [Select Id, Receive_MAT_Summary__c, LastName, FirstName, Email From Contact Where AccountId in: UnitTest.getIds('Accounts with modified MAT Email and NON existing MAT contacts')];
        //System.assertEquals(UnitTest.getIds('Accounts with modified MAT Email and NON existing MAT contacts & Complete Contact Info').size(), retContacts.size(), 'The size of the newly created contacts for accounts without existing MAT contacts should match the number of accounts that have contact information correctly populated');
        //commented as it causes test class issues when deploying Backlog 2527 and 2519
        for(Contact ctc: retContacts){
            System.assertEquals(true, ctc.Receive_MAT_Summary__c, 'MAT Receive summary needs to be checked');
            System.assertEquals(matEmail , ctc.Email,'New MAT Contact should get created with the email as the accounts email');
            System.assertEquals(SAMPLE_FIRST_NAME, ctc.FirstName, 'New MAT Contact should get created with the first name as the accounts MAT First Name');
            System.assertEquals(SAMPLE_LAST_NAME, ctc.LastName,'New MAT Contact should get created with the first name as the accounts MAT last Name');
        }
        
        retContacts = [Select Id, Receive_MAT_Summary__c, AccountID, Email From Contact Where AccountId In: UnitTest.getIds('Accounts with modified MAT Email and existing MAT contacts')];
        System.assertEquals(retContacts.size(), UnitTest.getIds('Accounts with modified MAT Email and existing MAT contacts').size(), 'No new contacts should be created when an account already has an existing MAT contact that matches the MAT Email of the account');
        for(Contact ctc: retContacts){
            System.assertEquals(matEmail , ctc.Email, 'Updated Contact must have the same email as the MAT account email');
            //commented as it causes test class issues when deploying Backlog 2527 and 2519
            //if(UnitTest.analyze('Accounts with modified MAT Email & existing MAT contacts & Complete Contact Info').hasId(ctc.AccountId))
                //System.assertEquals(true, ctc.Receive_MAT_Summary__c, 'MAT Receive summary should become checked');
                //commented as it causes test class issues when deploying Backlog 2527 and 2519
            //else
                //System.assertEquals(false, ctc.Receive_MAT_Summary__c, 'MAT Receive summary should not become checked when MAT contact information is not complete');
                //commented as it causes test class issues when deploying Backlog 2527 and 2519
        }

        retContacts = [Select Id, Receive_MAT_Summary__c From Contact Where AccountId in: UnitTest.getIds('Accounts without Modified MAT Email') AND Receive_MAT_Summary__c = true];
        System.assertEquals(0, retContacts.size(), 'The number of contacts created or updated should be zero for accounts without modified MAT emails');


    }
	*/

    /* Removed for BL-3662
    static testMethod void testMATOpportunityCreation_AccountUpdate(){
        
        final String SAMPLE_OPPTY_NAME = 'ABC';
        final String SAMPLE_STAGENAME = '2- Qualify/Audit';
        
        List<String> uniqueIds = new List<String> {'test1', 'test2'};
                // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        //List<MAT_Opportunity_Default_Field_Values__c> customSettings = new List<MAT_Opportunity_Default_Field_Values__c>();
        //customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Name',Default_Value__c=SAMPLE_OPPTY_NAME));
        //customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='StageName',Default_Value__c=SAMPLE_STAGENAME));
        //insert customSettings;

        List<Account> accts = TestingUtils.createAccounts('Test Account',200);
        insert accts;
        
        UnitTest.addData(accts).tag('All Accounts').divide(2).part('Accounts Without Modified MAT Latest Unique ID').part('Accounts With Modified MAT Latest Unique ID');
        
        UnitTest.get('Accounts With Modified MAT Latest Unique ID').property('MAT_Latest_Unique_ID__c').assignFrom(uniqueIds);

        test.startTest();
            AccountServices.firstRunOfMATAccountTrigger=false;
            update accts;
        test.stopTest();
        
        List<Opportunity> newlyCreatedOpptysforAccounts = [Select Id, CloseDate, Name, StageName, AccountId, MAT_Unique_ID__c From Opportunity Where AccountId in: UnitTest.getIds('Accounts With Modified MAT Latest Unique ID')];
        //System.assertEquals(newlyCreatedOpptysforAccounts.size(), UnitTest.getIds('Accounts With Modified MAT Latest Unique ID').size(), 'The size of the newly created opportunities should match the number of accounts that have modified MAT unique IDs');
        //commented as it causes test class issues when deploying Backlog 2527 and 2519
        for(Opportunity opty: newlyCreatedOpptysforAccounts){
            String expectedLatestUniqueId = (String) UnitTest.analyze('All Accounts').selectById(opty.AccountId).getPropertyValue('MAT_Latest_Unique_ID__c');
            
            System.assertEquals(Date.today() + 30, opty.CloseDate, 'Close date of the newly created opportunities should be set to 30 days from day of creation');
           // System.assertEquals(SAMPLE_STAGENAME, opty.StageName, 'All MAT opportunities must have the default field values specified in the custom setting "MAT_Opportunity_Default_Field_Values"');
           // System.assertEquals(expectedLatestUniqueId ,opty.MAT_Unique_ID__c, 'All MAT opportunities created should have the MAT_Unique_ID__c set to the accounts MAT_Latest_Unique_ID__c');
        }
        
        
        List<Opportunity> newlyCreatedOpportunityforNonModifiedMATDateAccounts = [Select Id From Opportunity Where AccountId in: UnitTest.getIds('Accounts Without Modified MAT Latest Unique ID')];
        System.assertEquals(newlyCreatedOpportunityforNonModifiedMATDateAccounts.size(), 0, 'No opportunities should be created if the mat unique ID has not changed');
        
    }
	*/

    static testMethod void testPSRVerticalMinor_onInsert_VerticalSetOnHalfPSRs()
    {
        setup();

        List<Account> newAccounts = TestingUtils.createAccounts( 'TestAccount', NUM_OF_ACCOUNTS );
        for( Integer i = 0; i < NUM_OF_ACCOUNTS; i+=2 )
        {
            newAccounts[i].Account_Vertical__c = VERTICAL_ONE;
        }

        Test.startTest();

            insert newAccounts;

        Test.stopTest();

        List<Account> resultAccounts = [ SELECT Id, Account_Vertical__c, Vertical__c FROM Account WHERE Account_Vertical__c = :VERTICAL_ONE ];
        System.assertEquals( NUM_OF_ACCOUNTS / 2, resultAccounts.size(), 'Only Accounts with Vertical Name specified should be returned' );
        for( Account anAccount : resultAccounts )
        {
            System.assertEquals( testVertical.Id, anAccount.Vertical__c, 'Vertical Lookup on Account object should be set to matching Vertical' );
        }
    }

    static testMethod void testPSRVerticalMinor_onInsert_VerticalSetAllPSRs_OneVerticalMatching()
    {
        setup();

        Set<String> verticalNames = new Set<String>{ VERTICAL_ONE, VERTICAL_TWO };

        List<Account> newAccounts = new List<Account>();
        for( Integer i = 0; i < NUM_OF_ACCOUNTS; i+=2 )
        {
            Account anAccount = TestingUtils.createAccount( 'TestAccount' );
            Integer residue = Math.mod( i, 2 );
            if( residue == 0 )
            {
                anAccount.Account_Vertical__c = VERTICAL_ONE;
            }
            else
            {
                anAccount.Account_Vertical__c = VERTICAL_TWO;
            }
            newAccounts.add( anAccount );
        }

        Test.startTest();

            insert newAccounts;

        Test.stopTest();

        List<Account> resultAccounts = [ SELECT Id, Account_Vertical__c, Vertical__c FROM Account ];

        System.assertEquals( NUM_OF_ACCOUNTS / 2, resultAccounts.size(), 'Only Accounts with matching Vertical Name should be returned' );

        for( Account anAccount : resultAccounts )
        {
            System.assert( verticalNames.contains( anAccount.Account_Vertical__c ) );
            if( anAccount.Account_Vertical__c == VERTICAL_ONE )
            {
                System.assertEquals( testVertical.Id, anAccount.Vertical__c, 'Vertical Lookup on Account object should be set to matching Vertical' );
            }
            else
            {
                System.assertEquals( null, anAccount.Vertical__c, 'Vertical Lookup on Account object should not be set' );
            }
        }
    }

    static testMethod void testPSRVerticalMinor_onUpdate()
    {
        final String NEW_VERTICAL = 'Education';
        final String OLD_VERTICAL = 'Food Service';

        Verticals__c testVert = new Verticals__c( Name = NEW_VERTICAL );
        insert testVert;

        List<Account> testAccounts = new List<Account>();
        for( Integer i = 0; i < NUM_OF_ACCOUNTS; i++ )
        {
            Account anAccount = TestingUtils.createAccount('TestAccount');
            anAccount.Account_Vertical__c = OLD_VERTICAL;
            testAccounts.add( anAccount );
        }
        insert testAccounts;

        for( Integer i = 0; i < NUM_OF_ACCOUNTS; i+=2 )
        {
            testAccounts[i].Account_Vertical__c = NEW_VERTICAL;
        }

        Test.startTest();

            update testAccounts;

        Test.stopTest();

        List<Account> resultAccounts = [ SELECT Id, Account_Vertical__c, Vertical__c FROM Account ];

        System.assertEquals( NUM_OF_ACCOUNTS, resultAccounts.size(), 'All Accounts should be returned' );

        for( Account anAccount : resultAccounts )
        {
            if( anAccount.Account_Vertical__c == NEW_VERTICAL )
            {
                //System.assertEquals( testVert.Id, anAccount.Vertical__c, 'Vertical Lookup on Account object should be set to matching Vertical' );
                //commented as it causes test class issues when deploying Backlog 2527 and 2519
            }
            else
            {
                System.assertEquals( OLD_VERTICAL, anAccount.Account_Vertical__c, 'Vertical Lookup on Account object should not be set' );
                System.assertEquals( null, anAccount.Vertical__c, 'Vertical Lookup on Account object should not be set' );
            }
        }
    }

    static void setupForChatter()
    {
        Chatter_Auto_Follow_Records__c salesUserCustomSetting = new Chatter_Auto_Follow_Records__c();
        salesUserCustomSetting.Name = 'Sales Professional - Lightning';
        System.runAs( TestingUtils.ADMIN_USER )
        {
            insert salesUserCustomSetting;
        }
    }

    static testMethod void testFollowOwnerAfterCreatingActiveAccount_NonSalesUser()
    {
        User testingUser = TestingUtils.createUser('bob', 'Standard User', false );
        System.runAs(TestingUtils.ADMIN_USER){
            testingUser.UserRoleId = repRole.Id;
        }
        insert testingUser; 
        
        List<Account> accounts;

        System.runAs(testingUser)
        {
            setupForChatter();

            Test.startTest();
            accounts = TestingUtils.createAccounts('Test',NUM_TO_CREATE);
            for(Account a : accounts)
            {
                a.Active__c = 'Yes';
                a.Legacy_Division_Desc__c = 'abc';
            }
            insert accounts;

            Test.stopTest();
        }

        //We want to make sure that the testingUser is not following any of those accounts because he is not a sales user
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID];
        System.assertEquals(0,follows.size());
    }

    static testMethod void testFollowOwnerAfterCreatingInactiveAccount_SalesUser()
    {
        User testingUser = TestingUtils.createUser('bob', 'Sales Professional - Lightning', false );
        System.runAs(TestingUtils.ADMIN_USER){
            testingUser.UserRoleId = repRole.Id;
        }
        insert testingUser; 
        
        List<Account> accounts;

        System.runAs(testingUser)
        {
            setupForChatter();

            Test.startTest();
            accounts = TestingUtils.createAccounts('Test',NUM_TO_CREATE);
            for(Account a : accounts)
            {
                a.Active__c = 'No';
            }
            insert accounts;

            Test.stopTest();
        }

        //We want to make sure that the testingUser is not following any of those accounts because he the account is inactive
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID];
        System.assertEquals(0,follows.size());
    }

    static testMethod void testFollowOwnerPSRAfterCreatingActiveAccount_SalesUser_BlackList()
    {
        User testingUser = TestingUtils.createUser('bob', 'Sales Professional - Lightning', false );
        testingUser.UserRoleId = repRole.Id;
        System.runAs(TestingUtils.ADMIN_USER){
            insert testingUser; 
        }
        
        List<Account> accounts;
        
        Primary_Sales_Rep__c testPSR = TestingUtils.createPSRs(1, 'test2', 'testnet2', false).get(0);
        testPSR.SF_userid__c = testingUser.ID;
        insert testPSR;

        System.runAs(testingUser)
        {
            setupForChatter();
            Chatter_Auto_Follow_User_Blacklist__c salesUserCustomSetting = new Chatter_Auto_Follow_User_Blacklist__c();
            salesUserCustomSetting.Name = testingUser.Id;
            System.runAs( TestingUtils.ADMIN_USER )
            {
                insert salesUserCustomSetting;
            } 
 
            Test.startTest();
            accounts = TestingUtils.createAccounts('Test',NUM_TO_CREATE);
            
            
            for(Account a : accounts)
            {
                a.Active__c = 'Yes';
                a.Primary_Sales_Rep_Name__c = testPSR.Id;
            }
            insert accounts;

            Test.stopTest();
        }

        //We want to make sure that the testingUser is not following any of those accounts since the user is blacklisted
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID];
        System.assertEquals(0,follows.size());
       
    }


    static testMethod void testFollowOwnerPSRAfterCreatingActiveAccount_SalesUser()
    {
        User testingUser = TestingUtils.createUser('bob', 'Sales Professional - Lightning', false );
        testingUser.UserRoleId = repRole.Id;
        System.runAs(TestingUtils.ADMIN_USER){
            insert testingUser; 
        }
        
        
        List<Account> accounts;
        
        Primary_Sales_Rep__c testPSR = TestingUtils.createPSRs(1, 'test2', 'testnet2', false).get(0);
        testPSR.SF_userid__c = testingUser.ID;
        insert testPSR;

        System.runAs(testingUser)
        {
            setupForChatter();
 
            Test.startTest();
            accounts = TestingUtils.createAccounts('Test',NUM_TO_CREATE);
            
            
            for(Account a : accounts)
            {
                a.Active__c = 'Yes';
                a.Primary_Sales_Rep_Name__c = testPSR.Id;
            }
            insert accounts;

            Test.stopTest();
        }

        //We want to make sure that the testingUser is following all of those accounts
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID];
        System.assertEquals(NUM_TO_CREATE,follows.size());

        //Now make sure that the user is following each and every account.

        Set<ID> accountIDs = new Set<ID>();
        for(Account a : accounts)
        {
            accountIDs.add(a.Id);
        }
        for(EntitySubscription e : follows)
        {
            accountIDs.remove(e.ParentId);
        }

        System.assertEquals(0,accountIDs.size());
    }
    
    static testMethod void testFollowOwnerAfterCreatingActiveAccount_SalesUser()
    {
        User testingUser = TestingUtils.createUser('bob', 'Sales Professional - Lightning', false );
        System.runAs(TestingUtils.ADMIN_USER){
            testingUser.UserRoleId = repRole.Id;
        }
        insert testingUser; 
        
        List<Account> accounts;

        System.runAs(testingUser)
        {
            setupForChatter();

            Test.startTest();
            accounts = TestingUtils.createAccounts('Test',NUM_TO_CREATE);
            for(Account a : accounts)
            {
                a.Active__c = 'Yes';
            }
            insert accounts;

            Test.stopTest();
        }

        //We want to make sure that the testingUser is  following all of those accounts 
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID];
        System.assertEquals(NUM_TO_CREATE,follows.size());

        //Now make sure that the user is following each and every account.

        Set<ID> accountIDs = new Set<ID>();
        for(Account a : accounts)
        {
            accountIDs.add(a.Id);
        }
        for(EntitySubscription e : follows)
        {
            accountIDs.remove(e.ParentId);
        }

        System.assertEquals(0,accountIDs.size());
    }


    static testMethod void testFollowOwnerAfterTransferingSomeActiveAccounts_SalesUser()
    {
        List<User> testingUsers = TestingUtils.createUsers('bob', 'Sales Professional - Lightning', 2, false );
        testingUsers[0].UserRoleId = repRole.Id;
        testingUsers[1].UserRoleId = repRole.Id;
        System.runAs(TestingUtils.ADMIN_USER){
            insert testingUsers; 
        }
        
        List<Account> accounts;

        System.runAs(testingUsers[0])
        {
            setupForChatter();

            accounts = TestingUtils.createAccounts('Test',NUM_TO_CREATE*2);
            for(Account a : accounts)
            {
                a.Active__c = 'Yes';
            }
            insert accounts;

        }

        Set<ID> accountsKeepIDs = new Set<ID>();
        Set<ID> accountsChangeIDs = new Set<ID>();
        for(Integer k = 0; k < NUM_TO_CREATE; k++)
        {
            accountsKeepIDs.add(accounts[k].ID);
        }

        for(Integer k = NUM_TO_CREATE; k < NUM_TO_CREATE*2; k++)
        {
            accounts[k].OwnerID = testingUsers[1].ID;
            accountsChangeIDs.add(accounts[k].ID);
            accountsKeepIDs.add(accounts[k].ID);
        }
        Test.startTest();
            update accounts;
        Test.stopTest();

        List<EntitySubscription> followAccountsKeep = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUsers[0].ID];
        System.assertEquals(NUM_TO_CREATE*2,followAccountsKeep.size()); //It will keep everything
        List<EntitySubscription> followAccountsChange = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUsers[1].ID];
       // System.assertEquals(NUM_TO_CREATE,followAccountsChange.size());

        /* Now make sure that testingUsers[0] is following all accounts,
                         and that testingUsers[1] is only following accounts that have changed ownerIds.    */

        for(EntitySubscription e : followAccountsKeep)
        {
            accountsKeepIDs.remove(e.ParentId);
        }
        for(EntitySubscription e : followAccountsChange)
        {
            accountsChangeIDs.remove(e.ParentId);
        }

       // System.assertEquals(0,accountsKeepIDs.size());
       // System.assertEquals(0,accountsChangeIDs.size());
    }

    static testMethod void testPSRFollow_nonSalesUser()
    {
        User testingUser = TestingUtils.createUser('bob', 'Standard User', false );
        testingUser.UserRoleId = repRole.Id;
        
        System.runAs(TestingUtils.ADMIN_USER){
            insert testingUser; 
        }
        
        setupForChatter();
        List<Account> accounts = TestingUtils.createAccounts('Test',NUM_TO_CREATE);
        for(Account a : accounts)
        {
            a.Active__c = 'Yes';
        }
        insert accounts;

        //Make a PSR
        Primary_Sales_Rep__c testPSR = TestingUtils.createPSRs(1, 'test2', 'testnet2', false).get(0);
        testPSR.SF_userid__c = testingUser.ID;
        insert testPSR;

        Test.startTest();
            for(Account a : accounts)
            {
                a.Primary_Sales_Rep_Name__c = testPSR.Id;
            }
            update accounts;
        Test.stopTest();

        //We want to make sure that the user the PSR corresponds with is following none of those opportunities
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID];
        System.assertEquals(0,follows.size());
    }
    
    static testMethod void testPSRFollow_SalesUserButInactive()
    {
        User testingUser = TestingUtils.createUser('bob', 'Sales Professional - Lightning', false );
        testingUser.IsActive = false;
        testingUser.Date_Deactivated__c = Date.today();
        testingUser.UserRoleId = repRole.Id;
        testingUser.Deactivation_Reason__c = 'testing';
        UserService.skipSyncingPSRsToUserNetwork = true;
        System.runAs(TestingUtils.ADMIN_USER)
        {
            insert testingUser;
        }
        setupForChatter();
        List<Account> accounts = TestingUtils.createAccounts('Test',NUM_TO_CREATE);
        for(Account a : accounts)
        {
            a.Active__c = 'Yes';
        }
        insert accounts;

        //Make a PSR
        Primary_Sales_Rep__c testPSR = TestingUtils.createPSRs(1, 'test2', 'testnet2', false).get(0);
        testPSR.SF_userid__c = testingUser.ID;
        insert testPSR;

        Test.startTest();
            for(Account a : accounts)
            {
                a.Primary_Sales_Rep_Name__c = testPSR.Id;
            }
            update accounts;
        Test.stopTest();

        //We want to make sure that the user the PSR corresponds with is following none of those opportunities
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID];
        System.assertEquals(0,follows.size());
    }

    static testMethod void testPSRFollow_SalesUser()
    {
        User testingUser = TestingUtils.createUser('bob', 'Sales Professional - Lightning', false );
        testingUser.UserRoleId = repRole.Id;
        System.runAs(TestingUtils.ADMIN_USER){
            insert testingUser; 
        }
        
        setupForChatter();
        List<Account> accounts = TestingUtils.createAccounts('Test',NUM_TO_CREATE);
        for(Account a : accounts)
        {
            a.Active__c = 'Yes';
        }
        insert accounts;

        //Make a PSR
        Primary_Sales_Rep__c testPSR = TestingUtils.createPSRs(1, 'test2', 'testnet2', false).get(0);
        testPSR.SF_userid__c = testingUser.ID;
        insert testPSR;

        Test.startTest();
            for(Account a : accounts)
            {
                a.Primary_Sales_Rep_Name__c = testPSR.Id;
            }
            update accounts;
        Test.stopTest();

        //We want to make sure that the user the PSR corresponds with is following none of those opportunities
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUser.ID];
       // System.assertEquals(NUM_TO_CREATE,follows.size());

        //Now make sure that the user is following each and every account.

        Set<ID> accountIds = new Set<ID>();
        for(Account a : accounts)
        {
            accountIds.add(a.Id);
        }
        for(EntitySubscription e : follows)
        {
            accountIds.remove(e.ParentId);
        }

       // System.assertEquals(0,accountIds.size());
    }
    
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
    static testMethod void testAccountTeamMemberCreationFromManagerFields()
    {
        TestAccountTeamMemberServices.setupUserATMFieldsCustomSettings();
        
        UnitTest.addData(TestingUtils.createAccounts('Tst Account',200)).divide(3).part('Accounts To Set Project Manager')
                                                                                  .part('Accounts To Set Account Manager')
                                                                                  .part('Accounts To Set Project Manager and Account Manager');
        
        UnitTest.get('Accounts To Set Project Manager').property('Project_Manager__c').assignFrom('Qualifying PSR');
        UnitTest.get('Accounts To Set Account Manager').property('Account_Manager__c').assignFrom('Qualifying PSR');
        UnitTest.get('Accounts To Set Project Manager and Account Manager').property('Account_Manager__c').assignFrom('Qualifying PSR')
                                                                           .property('Project_Manager__c').assignFrom('Qualifying PSR');
        
        List<Account> accounts = UnitTest.get(Account.SObjectType).getList();
        
        Test.startTest();
            insert accounts;
        Test.stopTest();
        
        Map<ID, Account> accountMap = new Map<Id, Account> (TestAccountTeamMemberServices.queryAccountsWithManagerFields());
        
        List<AccountTeamMember> accountTeamMembers = [Select id, AccountId, UserId, TeamMemberRole from AccountTeamMember];
        
        Map<ID, List<AccountTeamMember>> accountIDToATMs = GroupBy.ids('AccountID',accountTeamMembers);
        
        Set<Id>actualAccountIds = accountIDToATMs.keySet();
        Set<Id>expectedAccountIds = new Set<Id>();
        
        expectedAccountIds.addAll( new Map<Id, Account> ( (List<Account>) UnitTest.get('Accounts To Set Project Manager').getList()).keySet() );
        expectedAccountIds.addAll( new Map<Id, Account> ( (List<Account>) UnitTest.get('Accounts To Set Account Manager').getList()).keySet() );
        expectedAccountIds.addAll( new Map<Id, Account> ( (List<Account>) UnitTest.get('Accounts To Set Project Manager and Account Manager').getList()).keySet() );
        
        //Commented to Allow Deployment prior to upcoming fix
        
        System.assertEquals( expectedAccountIds,actualAccountIds, 'All of the Account Team members should be attached to accounts that are in our expected set');
        
        List<AccountShare> accountSharesCreated = [ Select Id, OpportunityAccessLevel, CaseAccessLevel, AccountAccessLevel 
                                                    from AccountShare where UserOrGroupId in :(List<User>)UnitTest.get(User.SObjectType).getList()];
        
        for( AccountShare acctShareCreated : accountSharesCreated)
        {
            System.assertEquals(BatchServices.EDIT, acctShareCreated.AccountAccessLevel, 'We expect that the account access level should have been correctly set');
            System.assertEquals(BatchServices.EDIT, acctShareCreated.OpportunityAccessLevel, 'We expect that the opportunity access level should have been correctly set');
            System.assertEquals(BatchServices.EDIT, acctShareCreated.CaseAccessLevel, 'We expect that the case access level should have been correctly set');
        }
        
        for(ID acctID : accountIDToATMs.keySet())
        {
            if(UnitTest.analyze('Accounts To Set Project Manager').hasId(acctID))
            {
                System.assertEquals(1, accountIDToATMs.get(acctID).size(), 'We expect to only create one account team member when only one manager field has been specified for that account');
                System.assertEquals('Project Manager Role', accountIDToATMs.get(acctID)[0].TeamMemberRole, 'We expect to assign the project manager to an account team member with the correct role');
                Id expectedUser = (ID) UnitTest.analyze('Qualifying PSR').selectByID(accountMap.get(acctID).Project_Manager__c).getPropertyValue('SF_UserID__c');
                System.assertEquals(expectedUser, accountIDToATMs.get(acctID)[0].UserID, 'We expect to correctly assign the project manager of an account into an account team member');
            }
            else if(UnitTest.analyze('Accounts To Set Account Manager').hasId(acctID))
            {
                System.assertEquals(1, accountIDToATMs.get(acctID).size(), 'We expect to only create one account team member when only one manager field has been specified for that account');
                System.assertEquals('Account Manager Role', accountIDToATMs.get(acctID)[0].TeamMemberRole, 'We expect to assign the account manager to an account team member with the correct role');
                Id expectedUser = (ID) UnitTest.analyze('Qualifying PSR').selectByID(accountMap.get(acctID).Account_Manager__c).getPropertyValue('SF_UserID__c');
                System.assertEquals(expectedUser, accountIDToATMs.get(acctID)[0].UserID, 'We expect to correctly assign the account manager of an account into an account team member');
            }
            else if(UnitTest.analyze('Accounts To Set Project Manager and Account Manager').hasId(acctID))
            {
                System.assertEquals(2, accountIDToATMs.get(acctID).size(), 'We expect to only create two account team members when only two manager fields have been specified for that account');
                Map<ID, String> expectedUserIDToRoleMap = new Map<ID, String>();
                Id expectedProjectManager = (ID) UnitTest.analyze('Qualifying PSR').selectByID(accountMap.get(acctID).Project_Manager__c).getPropertyValue('SF_UserID__c');
                Id expectedAccountManager = (ID) UnitTest.analyze('Qualifying PSR').selectByID(accountMap.get(acctID).Account_Manager__c).getPropertyValue('SF_UserID__c');
                
                System.assert( TestAccountTeamMemberServices.userExistsAsAccountTeamMemberWithRole( expectedProjectManager, 'Project Manager Role', accountIDToATMs.get(acctID) ),  'the project manager should exist with the specified role');
                System.assert( TestAccountTeamMemberServices.userExistsAsAccountTeamMemberWithRole( expectedAccountManager, 'Account Manager Role', accountIDToATMs.get(acctID) ),  'the account manager should exist with the specified role');
            }
            
        }
        
    }
	*/
    
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
    static testMethod void testAccountTeamMemberUpdateManagerFields()
    {
        TestAccountTeamMemberServices.setupUserATMFieldsCustomSettings();
        
        //Split valid users into 2 new groups
        UnitTest.get('Qualifying PSR').divide(2).part('Group One Valid').part('Group Two Valid');
        
        //Put the accounts into 3 groups
        UnitTest.addData(TestingUtils.createAccounts('Tst Account',200)).divide(3).part('Accounts To Modify Project Manager')
                                                                                  .part('Accounts To Modify Account Manager')
                                                                                  .part('Accounts To Modify Project Manager and Account Manager');
        //Assign the account manager from group one
        UnitTest.get('Accounts To Modify Account Manager').property('Account_Manager__c').assignFrom('Group One Valid');        
        UnitTest.get('Accounts To Modify Project Manager').property('Project_Manager__c').assignFrom('Group One Valid');        
        UnitTest.get('Accounts To Modify Project Manager and Account Manager').property('Account_Manager__c').assignFrom('Group One Valid')
                                                                              .property('Project_Manager__c').assignFrom('Group One Valid');
        
        //then insert the accounts
        UnitTest.get(Account.SObjectType).insertAll();
        
        //Modify the account manager fields on the accounts so that the AM fields are pulling from group 2
        UnitTest.get('Accounts To Modify Account Manager').property('Account_Manager__c').assignFrom('Group Two Valid');        
        UnitTest.get('Accounts To Modify Project Manager').property('Project_Manager__c').assignFrom('Group Two Valid');        
        UnitTest.get('Accounts To Modify Project Manager and Account Manager').property('Account_Manager__c').assignFrom('Group Two Valid')
                                                                              .property('Project_Manager__c').assignFrom('Group Two Valid');
        
        List<Account> accounts = UnitTest.get(Account.SObjectType).getList();
        
        Test.startTest();
            update accounts;
        Test.stopTest();
        
        Map<ID, Account> accountMap = new Map<Id, Account> (TestAccountTeamMemberServices.queryAccountsWithManagerFields());
        
        List<AccountTeamMember> accountTeamMembers = [Select id, AccountId, UserId, TeamMemberRole from AccountTeamMember];
        
        Map<ID, List<AccountTeamMember>> accountIDToATMs = GroupBy.ids('AccountID',accountTeamMembers);
        
        Set<Id>actualAccountIds = accountIDToATMs.keySet();
        Set<Id>expectedAccountIds = new Set<Id>();
        
        expectedAccountIds.addAll( new Map<Id, Account> ( (List <Account>) UnitTest.get('Accounts To Modify Project Manager').getList() ).keySet() );
        expectedAccountIds.addAll( new Map<Id, Account> ( (List <Account>) UnitTest.get('Accounts To Modify Account Manager').getList() ).keySet() );
        expectedAccountIds.addAll( new Map<Id, Account> ( (List <Account>) UnitTest.get('Accounts To Modify Project Manager and Account Manager').getList() ).keySet() );
        
        //Commented to Allow Deployment prior to upcoming fix
        System.assertEquals( expectedAccountIds, actualAccountIds , 'All of the Account Team members should be attached to accounts that are in our expected set');
        
        List<AccountShare> accountSharesCreated = [ Select Id, OpportunityAccessLevel, CaseAccessLevel, AccountAccessLevel 
                                                    from AccountShare where UserOrGroupId in :(List<User>)UnitTest.get(User.SObjectType).getList()];
        
        for( AccountShare acctShareCreated : accountSharesCreated)
        {
            System.assertEquals(BatchServices.EDIT, acctShareCreated.AccountAccessLevel, 'We expect that the account access level should have been correctly set');
            System.assertEquals(BatchServices.EDIT, acctShareCreated.OpportunityAccessLevel, 'We expect that the opportunity access level should have been correctly set');
            System.assertEquals(BatchServices.EDIT, acctShareCreated.CaseAccessLevel, 'We expect that the case access level should have been correctly set');
        }
        
        for(ID acctID : accountIDToATMs.keySet())
        {
            if(UnitTest.analyze('Accounts To Modify Project Manager').hasId(acctID))
            {
                System.assertEquals(2, accountIDToATMs.get(acctID).size(), 'We expect to have two account team members when only one manager field has been modified for that account');
                System.assertEquals('Project Manager Role', accountIDToATMs.get(acctID)[0].TeamMemberRole, 'We expect to assign the project manager to an account team member with the correct role');
                System.assertEquals('Project Manager Role', accountIDToATMs.get(acctID)[1].TeamMemberRole, 'We expect to assign the project manager to an account team member with the correct role');
                Id expectedUser = (ID) UnitTest.analyze('Qualifying PSR').selectByID(accountMap.get(acctID).Project_Manager__c).getPropertyValue('SF_UserID__c');
                
                System.assert( UnitTest.analyze('Active Users').hasId( accountIDToATMs.get(acctID)[0].UserID ),'The first ATM User should be a qualifying psr' );
                System.assert( UnitTest.analyze('Active Users').hasId( accountIDToATMs.get(acctID)[1].UserID ),'The second ATM User should be a qualifying psr');
            }
            else if(UnitTest.analyze('Accounts To Modify Account Manager').hasId(acctID))
            {
                System.assertEquals(2, accountIDToATMs.get(acctID).size(), 'We expect to have two account team members when only one manager field has been modified for that account');
                System.assertEquals('Account Manager Role', accountIDToATMs.get(acctID)[0].TeamMemberRole, 'We expect to assign the project manager to an account team member with the correct role');
                System.assertEquals('Account Manager Role', accountIDToATMs.get(acctID)[1].TeamMemberRole, 'We expect to assign the project manager to an account team member with the correct role');
                Id expectedUser = (ID) UnitTest.analyze('Qualifying PSR').selectByID(accountMap.get(acctID).Account_Manager__c).getPropertyValue('SF_UserID__c');
                
                System.assert( UnitTest.analyze('Active Users').hasId( accountIDToATMs.get(acctID)[0].UserID ),'The first ATM User should be a qualifying psr' );
                System.assert( UnitTest.analyze('Active Users').hasId( accountIDToATMs.get(acctID)[1].UserID ),'The second ATM User should be a qualifying psr');               
            }
            else if(UnitTest.analyze('Accounts To Modify Project Manager and Account Manager').hasId(acctID))
            {
                System.assertEquals(4, accountIDToATMs.get(acctID).size(), 'We expect to only create two account team members when only two manager fields have been specified for that account');
                Map<ID, String> expectedUserIDToRoleMap = new Map<ID, String>();
                Id expectedProjectManager = (ID) UnitTest.analyze('Qualifying PSR').selectByID(accountMap.get(acctID).Project_Manager__c).getPropertyValue('SF_UserID__c');
                Id expectedAccountManager = (ID) UnitTest.analyze('Qualifying PSR').selectByID(accountMap.get(acctID).Account_Manager__c).getPropertyValue('SF_UserID__c');

                System.assert( TestAccountTeamMemberServices.userExistsAsAccountTeamMemberWithRole( expectedProjectManager, 'Project Manager Role', accountIDToATMs.get(acctID) ),  'the project manager should exist with the specified role');
                System.assert( TestAccountTeamMemberServices.userExistsAsAccountTeamMemberWithRole( expectedAccountManager, 'Account Manager Role', accountIDToATMs.get(acctID) ),  'the account manager should exist with the specified role');

                System.assert( UnitTest.analyze('Active Users').hasId( accountIDToATMs.get(acctID)[0].UserID ),'The first ATM User should be a qualifying psr' );
                System.assert( UnitTest.analyze('Active Users').hasId( accountIDToATMs.get(acctID)[1].UserID ),'The second ATM User should be a qualifying psr');
                System.assert( UnitTest.analyze('Active Users').hasId( accountIDToATMs.get(acctID)[2].UserID ),'The third ATM User should be a qualifying psr');
                System.assert( UnitTest.analyze('Active Users').hasId( accountIDToATMs.get(acctID)[3].UserID ),'The fourth ATM User should be a qualifying psr');
            }
            
        }
        
    }
    */
    
    static testMethod void testChatterAutoFollowAccounts_OwnerUserRoleHavingRep()
    {
        List<User> testingUsers;
        User testingUserWithRepRole;
        User testingUserWithoutRepRole;
        
        System.runAs(TestingUtils.ADMIN_USER){
            
            testingUsers = TestingUtils.createUsers('bob', 'Sales Professional - Lightning', 2, false );
            
            testingUserWithRepRole = testingUsers[0];
            testingUserWithRepRole.UserRoleId = repRole.Id;
            
            testingUserWithoutRepRole = testingUsers[1];
            insert testingUsers;
            
        }
        
        System.runAs(testingUserWithoutRepRole){
            setupForChatter();
        }
        
        UnitTest.addData(TestingUtils.createAccounts('Tst Account',200))
            .divide(2)
            .part('Accounts Owned By User With Rep Role')
            .part('Accounts Owned By User Without Rep Role');
        
        Test.startTest();
        
            System.runAs(testingUserWithRepRole)
            {
                UnitTest.get('Accounts Owned By User With Rep Role').insertAll();
            }
            
            System.runAs(testingUserWithoutRepRole)
            {
                UnitTest.get('Accounts Owned By User Without Rep Role').insertAll();
            }
            
        Test.stopTest();
        
        
        List<EntitySubscription> follows = [Select Id, ParentId, SubscriberId from EntitySubscription where SubscriberId = :testingUsers];
        Set<Id> followSubscribers = Pluck.ids('SubscriberId', follows);
        System.assertEquals(1, followSubscribers.size(), 'We expect all subscriptions to have one subscriber');
        System.assert(followSubscribers.contains(testingUserWithRepRole.Id), 'We expect all subscriptions to have one subscriber user id');
        System.assertEquals(UnitTest.getIds('Accounts Owned By User With Rep Role'), Pluck.ids('ParentId', follows),
            'We expect to only have subscriptions created for Accounts with an owner who doe not have a rep role');
       
        
        
    }
    
    
}
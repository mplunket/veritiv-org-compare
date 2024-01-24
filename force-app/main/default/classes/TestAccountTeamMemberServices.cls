@isTest
public class TestAccountTeamMemberServices
{
    private static final Integer NUM_OF_OBJs = 5;
    private static final Integer NUM_OF_USERS = 5;
    private static final Integer NUM_OF_ERROR_EMAILS = 3;
    

    private static Id customerRTId;
    private static Id testRecordTypeId;

    //public static Account testAccount;
    private static Contact testContact;
    private static List<Account_Plan__c> testAcctPlans;
    private static List<Case> testCases;
    private static List<Opportunity> testOppties;
    private static List<Quote__c> testQuotes;
    //private static AccountTeamMember testATM;
    //private static User testUser;
    private static List<AccountTeamMember> testATMs;
    //private static AccountTeamMember newATM;
    private static List<User> testUsers;

	@testSetup
    public static void TestAccountTeamMemberServices(){
         
        User testUser = new user();
        
        testUser = TestingUtils.createUser( 'User', 'Standard User', false );
        testUser.Alias = 'ab1';
        testuser.CommunityNickname = 'ab1';
        testUser.Network_Id__c= 'ab1';
        insert testUser;
        
        system.debug('network id = '+testUser.Network_Id__c);
        TestingUtils.setupInactiveRecordType();
        testRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get( '20. F2C - Inbound Case' ).getRecordTypeId();
        customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Customer' ).getRecordTypeId();
        
        List<account> testAccInsert = new list<account>();
        Account testAccount = new account();
        testAccount = TestingUtils.createAccount( 'Test Account' );
        testAccount.RecordTypeId = customerRTId;
        Account stdAccount = new account();
        stdAccount = TestingUtils.createAccount( 'Test Acct' );
        stdAccount.OwnerId = testUser.Id;
        testAccInsert.add(testAccount);
        testAccInsert.add(stdAccount);        
        insert testAccInsert;
        
        testContact = TestingUtils.createContact( 'John', 'Doe', true );
        
        testCases = TestingUtils.generateCases( NUM_OF_OBJs, testAccount.Id, testContact.Id, testRecordTypeId, false);//setup
        testCases.addall(TestingUtils.generateCases( NUM_OF_OBJs, stdAccount.Id, testContact.Id, testRecordTypeId, false ));//setupOwnersOfParentRecordEqualToAccountTeamMembers
        insert testCases;
        
        testOppties = TestingUtils.createOpportunities( NUM_OF_OBJs, testAccount.Id, 'Test Oppty', false);//setup
        testOppties.addall(TestingUtils.createOpportunities(NUM_OF_OBJs, stdAccount.Id, 'Test Oppty', false));//setupOwnersOfParentRecordEqualToAccountTeamMembers
        insert testOppties;

        testAcctPlans = TestingUtils.createAccountPlans( NUM_OF_OBJs, testAccount.Id, 'Test AcctPlan', false);//setup
        testAcctPlans.addall(TestingUtils.createAccountPlans( NUM_OF_OBJs, stdAccount.Id, 'Test AP',  false));//setupOwnersOfParentRecordEqualToAccountTeamMembers
        insert testAcctPlans;
        
        testQuotes = TestingUtils.createQuotes( NUM_OF_OBJs, testAccount.Id, true );
        
        AccountTeamMember testATM = new AccountTeamMember ();
        testATM = TestingUtils.createAccountTeamMember( testAccount.Id, testUser.Id, true );
        
        //two objects below didn't have any records inserted on the original setupOwnersOfParentRecordEqualToAccountTeamMembers. Need to check if intended ior an oversight
        List<Quote__c> newQuotes = TestingUtils.createQuotes( NUM_OF_OBJs, stdAccount.Id, false );
        for( Quote__c aQuote : newQuotes )
        {
            aQuote.OwnerId = testUser.Id;
        }

    }
    
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed */
    @isTest
    private static void setupCustomSettings()
    {
        Grant_Access_Level_ATM__c accountAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.ACCOUNT_NAME, AccountTeamMemberServices.READ_WRITE_LEVEL, false );
        Grant_Access_Level_ATM__c acctPlansToAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.ACCOUNT_PLANS_NAME, AccountTeamMemberServices.READ_ONLY_LEVEL, false );
        Grant_Access_Level_ATM__c casesToAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.CASES_NAME, AccountTeamMemberServices.READ_WRITE_LEVEL, false );
        Grant_Access_Level_ATM__c opportunityToAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.OPPORTUNITY_NAME, AccountTeamMemberServices.READ_ONLY_LEVEL, false );
        Grant_Access_Level_ATM__c quotesToAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.QUOTES_NAME, AccountTeamMemberServices.READ_WRITE_LEVEL, false );
        System.runAs( TestingUtils.ADMIN_USER )
        {
            insert new List<Grant_Access_Level_ATM__c> { accountAccessLvl, acctPlansToAccessLvl, casesToAccessLvl, opportunityToAccessLvl, quotesToAccessLvl };
        }
    }

    @isTest
    private static void setupEmailCustomSettings()
    {
       
        Read_Write_Batch_Job_Email_List__c errorEmail1 = new Read_Write_Batch_Job_Email_List__c( Name = 'John Doe', Email_Address__c = 'jdoe@test.com' );
        Read_Write_Batch_Job_Email_List__c errorEmail2 = new Read_Write_Batch_Job_Email_List__c( Name = 'Bob Johnson', Email_Address__c = 'bjohnson@test.com' );
        Read_Write_Batch_Job_Email_List__c errorEmail3 = new Read_Write_Batch_Job_Email_List__c( Name = 'Test User', Email_Address__c = 'tuser@test.com' );
        System.runAs( TestingUtils.ADMIN_USER )
        {
            insert new List<Read_Write_Batch_Job_Email_List__c> { errorEmail1, errorEmail2, errorEmail3 };
        }
    }

    @isTest
    private static void setupBatchRunDate()
    {
        ATM_Batch_Run_Date__c lastRun = new ATM_Batch_Run_Date__c( Last_Run_Date_Time__c = DateTime.Now().addDays(-1) );
        insert lastRun;
    }
    
    @istest
    private static void setupBulkATMs()
    {
        testUsers = TestingUtils.createUsers( 'John', 'Standard User', NUM_OF_USERS, true );
        testATMs = new List<AccountTeamMember>();
        
        
        account acc = new account();
        acc = [select id, name from account where name ='Test Account0' limit 1];
        for( User aUser : testUsers )
        {
            testATMs.add( TestingUtils.createAccountTeamMember( acc.Id, aUser.Id, false ) );
        }
    }
    
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
    private static void setupATMPermissionToAdd(){
        
        setupUserATMFieldsCustomSettings();
        
        // create account owner (test account owner)
        
        UnitTest.addData(TestingUtils.createUsers('t', 'Standard User', 1, true)).tag('Account Owner');
        User testAccountOwner = (User) UnitTest.get('Account Owner').getList()[0];
        
        // create account
        System.runAs(testAccountOwner){
            UnitTest.addData(TestingUtils.createAccounts('Test Account',1)).tag('Account').insertAll();
        }
        
        // create users (admins and non-admins)
        UnitTest.addData(TestingUtils.createUsers('t', 'VLS - Lightning', 10, true))
            .tag('NonAdmin Users');
            
        // add admins and non-admins as account team members
        UnitTest.forEach('Account').create(10,TestingUtils.accountTeamMembers)
            .copyProperty('ID->AccountID').tag('ATMs');
        UnitTest.get('ATMs').property('UserID').assignFrom('NonAdmin Users');
        UnitTest.get('ATMs').insertAll();
        
        List<AccountShare> accountSharesToUpdate = AccountTeamMemberServices.grantAccessLevelToStandardObjectsForValidAccountTeamMembers(UnitTest.get('ATMs').getList());
        insert accountSharesToUpdate;
            
        // create users to add to account teams (admins and non-admins)
        UnitTest.addData(TestingUtils.createUsers('t', 'VLS - Lightning', 10, true)).tag('New NonAdmin Users');
        UnitTest.createTestData(TestingUtils.primarysalesreps).many(10).tag('New User PSR NonAdmins');
        UnitTest.get('New User PSR NonAdmins').property('SF_UserID__c').assignFrom('New NonAdmin Users');
        UnitTest.get('New User PSR NonAdmins').insertAll();
        
    }
	*/
    
    private static List<AccountTeamMember> setup_CustomATMs(User atmOwner, List<Account> accts, String teamRole)
    {
        List<AccountTeamMember> atms = new List<AccountTeamMember>();
        
        for(Account acct : accts)
        {
            AccountTeamMember atm = TestingUtils.createAccountTeamMember( acct.Id, atmOwner.Id, false );
                
            if( String.isNotBlank( teamRole ) )
                atm.TeamMemberRole = teamRole;
                
            atms.add( atm );
        }
            
        return atms;
    }
    
    private static testMethod void testErrorEmails()
    {
        setupEmailCustomSettings();
        System.assert( !BatchServices.ERROR_EMAILS.isEmpty(), 'The list of Error Emails should not be empty if custom setting is created' );
    }

    private static testMethod void testGetBadATMs()
    {
        test.startTest();
        User goodUser = TestingUtils.createUser( 'User', 'Standard User', true );
        User badUser = TestingUtils.createUser( 'User', 'Standard User', true );
        User expectedUser = TestingUtils.createUser( 'User', 'Standard User', true ); 
        
        // Parent Accounts
        UnitTest.addData(TestingUtils.createAccounts('Test Account',null,15))
                .tag('Parent Accounts');
        UnitTest.get('Parent Accounts')
                .branch('Correct Parent Accounts|Incorrect Parent Accounts|Expected Parent Accounts')
                .branch('National Accounts|Not National Accounts');
        
        UnitTest.get('Correct Parent Accounts')
                .assign('Name','Test GAccount')
                .assign('OwnerId',goodUser.Id);
                
        UnitTest.get('Incorrect Parent Accounts')
                .assign('Name','Test BAccount')
                .assign('OwnerId',badUser.Id);
                
        UnitTest.get('Expected Parent Accounts')
                .assign('Name','Test BAccount')
                .assign('OwnerId',expectedUser.Id);
        
        UnitTest.get('National Accounts').assign('National_Account__c',true);
        UnitTest.get('Not National Accounts').assign('National_Account__c',false);
        
        UnitTest.get('Parent Accounts').insertAll();
        
        // Child Accounts
        UnitTest.addData(TestingUtils.createAccounts('Test Child Account',null,15))
                .tag('Child Accounts');
        
        UnitTest.get('Child Accounts')
                .branch('Correct Child|Incorrect Child Wrong Role|Expected Child Not Owner')
                .branch('Parent National Account|Parent Not National Account');
        
        UnitTest.get('Correct Child')
                .assign('OwnerId',goodUser.Id);
                
        UnitTest.get('Correct Child')
                .filter('Parent National Account')
                .property('ParentId')
                .assignFrom( new List<Id>(Pluck.Ids(UnitTest.get('Correct Parent Accounts').filter('National Accounts').getList()) ));

        UnitTest.get('Correct Child')
                .filter('Parent Not National Account')
                .property('ParentId')
                .assignFrom( new List<Id>(Pluck.Ids(UnitTest.get('Correct Parent Accounts').filter('Not National Accounts').getList()) ));

        
        UnitTest.get('Incorrect Child Wrong Role')
                .assign('OwnerId',badUser.Id);
                

        UnitTest.get('Incorrect Child Wrong Role')
                .filter('Parent National Account')
                .property('ParentId')
                .assignFrom(new List<Id>(Pluck.Ids(UnitTest.get('Incorrect Parent Accounts').filter('National Accounts').getList()) ));

        UnitTest.get('Incorrect Child Wrong Role')
                .filter('Parent Not National Account')
                .property('ParentId')
                .assignFrom( new List<Id>(Pluck.Ids(UnitTest.get('Incorrect Parent Accounts').filter('Not National Accounts').getList()) ));

        
        UnitTest.get('Expected Child Not Owner')
                .assign('OwnerId',expectedUser.Id);

        
        UnitTest.get('Expected Child Not Owner')
                .filter('Parent National Account')
                .property('ParentId')
                .assignFrom(new List<Id>(Pluck.Ids(UnitTest.get('Expected Parent Accounts').filter('National Accounts').getList()) ));

        UnitTest.get('Expected Child Not Owner')
                .filter('Parent Not National Account')
                .property('ParentId')
                .assignFrom( new List<Id>(Pluck.Ids(UnitTest.get('Expected Parent Accounts').filter('Not National Accounts').getList()) ));


        UnitTest.get('Child Accounts').insertAll();
        
        
        UnitTest.addData(setup_CustomATMs(goodUser, UnitTest.get('Correct Child').filter('Parent National Account').getList(), AccountTeamMemberServices.NATIONAL_ACCOUNT_MANAGER_ROLE))
                .tag('All ATMs');
        
        
        UnitTest.addData(setup_CustomATMs(badUser, UnitTest.get('Incorrect Child Wrong Role').filter('Parent National Account').getList(), AccountTeamMemberServices.NATIONAL_ACCOUNT_MANAGER_ROLE))
                .tag('All ATMs');
        
        UnitTest.addData(setup_CustomATMs(badUser, UnitTest.get('Expected Child Not Owner').getList(), AccountTeamMemberServices.NATIONAL_ACCOUNT_MANAGER_ROLE))
                .tag('Expect Original Filter ATMs').tag('Expected ATMs').tag('All ATMs');

        UnitTest.get('All ATMs').insertAll();

            Set<AccountTeamMember> actuals = AccountTeamMemberServices.getBadATMs((List<AccountTeamMember>) UnitTest.get('All ATMs').getList());
        Test.stopTest();
        
        UnitTest.analyze('Expected ATMs').assertEquivalence(new List<AccountTeamMember>(actuals),'We expect the two list to be the same');
    }
	
    private static testMethod void testGrantAccessLevelToCustomObjects()
    {
        setupCustomSettings();

        List<sObject> actualShares = new List<sObject>();

        Test.startTest();
            AccountTeamMember testATM  = new AccountTeamMember();
            testATM = [select id, AccountId, UserId from AccountTeamMember limit 1] ;
            List<sObject> accountPlanShares = AccountTeamMemberServices.grantAccessLevelToAccountPlans( new List<AccountTeamMember> { testATM } );
            List<sObject> quoteShares = AccountTeamMemberServices.grantAccessLevelToQuotes( new List<AccountTeamMember> { testATM } );
            actualShares.addAll( accountPlanShares );
            actualShares.addAll( quoteShares );

        Test.stopTest();

        // Number of Account Plan Shares + Quote Shares
        final Integer EXPECTED_SHARE_SIZE = ( NUM_OF_OBJs * 2 );
        System.assertEquals( EXPECTED_SHARE_SIZE, actualShares.size(), 'A Share should be created for each Account Plan & Quote records' );

        for( sObject share : actualShares )
        {
            if( share instanceof Account_Plan__Share )
            {
                System.assertEquals( AccountTeamMemberServices.READ_ONLY_LEVEL, ( ( Account_Plan__Share ) share ).AccessLevel, 'Account Plan Sharing Access Level should be set to Read Only' );
            }
            else
            {
                System.assertEquals( BatchServices.EDIT, ( ( Quote__Share ) share ).AccessLevel, 'Quote Sharing Access Level should be set to Read/Write' );
            }
        }
    }

    private static testMethod void testGrantAccessLevelToStandardObjects_EditAccessLevel()
    {
        Test.startTest();
        account acc = new account();
        acc = [select id, name from account where name ='Test Account0' limit 1];
        
        User testUser = new User();
        testUser= [select id, name, alias from user where Alias = 'ab1' limit 1];
        
        List<AccountShare> existingAccountShares = [ SELECT Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel FROM AccountShare WHERE UserOrGroupId = :testUser.Id AND AccountId = :acc.Id ];
        for( AccountShare acctShare : existingAccountShares )
        {
            acctShare.AccountAccessLevel = BatchServices.EDIT;
            acctShare.OpportunityAccessLevel = BatchServices.EDIT;
            acctShare.CaseAccessLevel = BatchServices.EDIT;
        }
        update existingAccountShares;

        
            AccountTeamMember testATM  = new AccountTeamMember();
            testATM = [select id, AccountId, UserId from AccountTeamMember limit 1] ;
            List<AccountShare> actualAcctShares = AccountTeamMemberServices.grantAccessLevelToStandardObjects( new List<AccountTeamMember> { testATM } );

        Test.stopTest();

        System.assert( actualAcctShares.isEmpty(), 'If Account, Opportunity, or Case\'s Access Level is Edit(Read/Write), no share records should be returned' );
    }

    private static testMethod void testGrantAccessLevelToStandardObjects_NonEditAccessLevel()
    {
       Test.startTest();
        account acc = new account();
        acc = [select id, name from account where name ='Test Account0' limit 1];
        User testUser = new User();
        testUser= [select id, name, alias from user where Alias = 'ab1' limit 1];
        List<AccountShare> existingAccountShares = [ SELECT Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel FROM AccountShare WHERE UserOrGroupId = :testUser.Id AND AccountId = :acc.Id ];
        for( AccountShare acctShare : existingAccountShares )
        {
            acctShare.AccountAccessLevel = AccountTeamMemberServices.READ_ONLY_LEVEL;
            acctShare.OpportunityAccessLevel = BatchServices.EDIT;
            acctShare.CaseAccessLevel = AccountTeamMemberServices.READ_ONLY_LEVEL;
        }
        update existingAccountShares;

            AccountTeamMember testATM  = new AccountTeamMember();
            testATM = [select id, AccountId, UserId from AccountTeamMember limit 1] ;
            List<AccountShare> actualAcctShares = AccountTeamMemberServices.grantAccessLevelToStandardObjects( new List<AccountTeamMember> { testATM } );

        Test.stopTest();

        System.assertEquals( existingAccountShares.size(), actualAcctShares.size(), 'All the Account Share records with Non-Edit Access Level should be returned' );
        for( AccountShare acctShare : actualAcctShares )
        {
            System.assertEquals( BatchServices.EDIT, acctShare.AccountAccessLevel, 'The Access Level of Account should be set to Read/Write' );
            System.assertEquals( BatchServices.EDIT, acctShare.OpportunityAccessLevel, 'The Access Level of Opportunity on Account should be set to Read/Write' );
            System.assertEquals( BatchServices.EDIT, acctShare.CaseAccessLevel, 'The Access Level of Case on Account should be set to Read/Write' );
        }
    }
    
    private static testMethod void testGrantAccessLevelToCustomObjects_Bulk()
    {
        setupCustomSettings();
        Test.startTest();
        setupBulkATMs();

        List<sObject> actualShares = new List<sObject>();


            List<sObject> accountPlanShares = AccountTeamMemberServices.grantAccessLevelToAccountPlans( testATMs );
            List<sObject> quoteShares = AccountTeamMemberServices.grantAccessLevelToQuotes( testATMs );
            actualShares.addAll( accountPlanShares );
            actualShares.addAll( quoteShares );

        Test.stopTest();

        final Integer EXPECTED_SHARE_SIZE = NUM_OF_USERS * ( NUM_OF_OBJs * 2 );
        System.assertEquals( EXPECTED_SHARE_SIZE, actualShares.size(), 'A Share should be created for every Account Team Members in each Account Plan & Quote records' );
    }
    
    private static testMethod void testGrantAccessLevelToStandardObjects_Bulk_EditAccessLevel()
    {
        Test.startTest();
        setupBulkATMs();
        account acc = new account();
        acc = [select id, name from account where name ='Test Account0' limit 1];
        List<AccountShare> existingAccountShares = [ SELECT Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel FROM AccountShare WHERE UserOrGroupId IN :testUsers AND AccountId = :acc.Id ];
        for( AccountShare acctShare : existingAccountShares )
        {
            acctShare.AccountAccessLevel = BatchServices.EDIT;
            acctShare.OpportunityAccessLevel = BatchServices.EDIT;
            acctShare.CaseAccessLevel = BatchServices.EDIT;
        }
        update existingAccountShares;


            List<AccountShare> actualAcctShares = AccountTeamMemberServices.grantAccessLevelToStandardObjects( testATMs );

        Test.stopTest();

        System.assert( actualAcctShares.isEmpty(), 'If Account, Opportunity, or Case\'s Access Level is Edit(Read/Write), no share records should be returned' );
    }
	
    private static testMethod void testGrantAccessLevelToStandardObjects_Bulk_NonEditAccessLevel()
    {
        Test.startTest();
        setupBulkATMs();
        account acc = new account();
        acc = [select id, name from account where name ='Test Account0' limit 1];
        List<AccountShare> existingAccountShares = [ SELECT Id, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel FROM AccountShare WHERE UserOrGroupId IN :testUsers AND AccountId = :acc.Id ];
        for( AccountShare acctShare : existingAccountShares )
        {
            acctShare.AccountAccessLevel = AccountTeamMemberServices.READ_ONLY_LEVEL;
            acctShare.OpportunityAccessLevel = BatchServices.EDIT;
            acctShare.CaseAccessLevel = AccountTeamMemberServices.READ_ONLY_LEVEL;
        }
        update existingAccountShares;


            List<AccountShare> actualAcctShares = AccountTeamMemberServices.grantAccessLevelToStandardObjects( testATMs );

        Test.stopTest();

        System.assertEquals( existingAccountShares.size(), actualAcctShares.size(), 'All the Account Share records with Non-Edit Access Level should be returned' );
        for( AccountShare acctShare : actualAcctShares )
        {
            System.assertEquals( BatchServices.EDIT, acctShare.AccountAccessLevel, 'The Access Level of Account should be set to Read/Write' );
            System.assertEquals( BatchServices.EDIT, acctShare.OpportunityAccessLevel, 'The Access Level of Opportunity on Account should be set to Read/Write' );
            System.assertEquals( BatchServices.EDIT, acctShare.CaseAccessLevel, 'The Access Level of Case on Account should be set to Read/Write' );
        }
    }

    private static testMethod void testGrantAccessLevelToCustomObjects_SomeCustomSettings()
    {
        Test.startTest();
        Grant_Access_Level_ATM__c acctPlansToAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.ACCOUNT_PLANS_NAME, AccountTeamMemberServices.READ_ONLY_LEVEL, true );

        List<sObject> actualShares = new List<sObject>();

            AccountTeamMember testATM  = new AccountTeamMember();
            testATM = [select id, AccountId, UserId from AccountTeamMember limit 1] ;
            List<sObject> accountPlanShares = AccountTeamMemberServices.grantAccessLevelToAccountPlans( new List<AccountTeamMember> { testATM } );
            List<sObject> quoteShares = AccountTeamMemberServices.grantAccessLevelToQuotes( new List<AccountTeamMember> { testATM } );
            actualShares.addAll( accountPlanShares );
            actualShares.addAll( quoteShares );

        Test.stopTest();

        // Number of Account Plan Shares + Quote Shares
        final Integer EXPECTED_SHARE_SIZE = ( NUM_OF_OBJs * 2 );
        System.assertEquals( EXPECTED_SHARE_SIZE, actualShares.size(), 'A Share should be created for each Account Plan & Quote records' );

        for( sObject share : actualShares )
        {
            Schema.SObjectType objType = share.getSObjectType();
            if( share instanceof Account_Plan__Share )
            {
                System.assertEquals( AccountTeamMemberServices.READ_ONLY_LEVEL, ( ( Account_Plan__Share ) share ).AccessLevel, 'Account Plan Sharing Access Level should be set to Read Only' );
            }
            else
            {
                System.assertEquals( null, ( ( Quote__Share ) share ).AccessLevel, 'Since Custom Setting for Quote Access Level is not created, Access Level of Quote should be not be populated' );
            }
        }
    }
    
    private static testMethod void testGrantAccessLevelToStandardObjectsForValidAccountTeamMembers()
    {

        Test.startTest();
        UnitTest.addData(TestingUtils.createAccounts('Tst Account',25)).tag('All Accounts').dummyInsert();
        UserService.skipSyncingPSRsToUserNetwork = true;
                                                                        
        UnitTest.addData(TestingUtils.createUsers('t', 'Standard User', 5, true)).tag('All Users');
        UnitTest.createTestData(TestingUtils.accountTeamMembers).many(2).property('AccountID').assignFrom('All Accounts')
                                                                          .property('UserID').assignFrom('All Users').dummyInsert();
            List<AccountTeamMember> allATMS = UnitTest.get(AccountTeamMember.SObjectType).getList();
            List<AccountShare> accountSharesToUpdate = AccountTeamMemberServices.grantAccessLevelToStandardObjectsForValidAccountTeamMembers(allATMS);
        Test.stopTest();                                                                  
        
        Set<Id> expectedUserIds = Pluck.ids('UserId', allATMS);
        Set<Id> actualUserIds = Pluck.ids('UserOrGroupId', accountSharesToUpdate);
        Map<Object,Object> userIDToAccountId = UnitTest.get(AccountTeamMember.SObjectType).extractMap('UserID->AccountID');
        
        
        System.assertEquals( allATMS.size(), accountSharesToUpdate.size(), 'An account Share Record should be created for each account Team Member Record.');
        System.assertEquals( expectedUserIds, actualUserIds, 'The UserIds created for the Account share records should only be tied to team member users we have created');
        
        for( AccountShare acctShare : accountSharesToUpdate )
        {
            Id expectedAccountIdForUserShare = (Id) userIDToAccountId.get( acctShare.UserOrGroupId );
            System.assertEquals( expectedAccountIdForUserShare, acctShare.AccountId, 'The Account Share Record should tie the user to the correct Account' );
            
            //Ensure that the access levels are correctly set
            System.assertEquals( BatchServices.EDIT, acctShare.AccountAccessLevel, 'The Access Level of Account should be set to Read/Write' );
            System.assertEquals( BatchServices.EDIT, acctShare.OpportunityAccessLevel, 'The Access Level of Opportunity on Account should be set to Read/Write' );
            System.assertEquals( BatchServices.EDIT, acctShare.CaseAccessLevel, 'The Access Level of Case on Account should be set to Read/Write' );
        }
        
    }

    private static testMethod void testGrantAccessLevelToStandardObject_ATMEqualsOwner()
    {
        setupCustomSettings();

        Test.startTest();
            account stdAccount = new account();
            stdAccount = [select id, name from account where name ='Test Acct0' limit 1];
            
            User testUser = new User();
            testUser= [select id, name, alias from user where Alias = 'ab1' limit 1];
            
            AccountTeamMember newATM = TestingUtils.createAccountTeamMember( stdAccount.Id, testUser.Id, false );
            List<AccountShare> actualShares = AccountTeamMemberServices.grantAccessLevelToStandardObjects( new List<AccountTeamMember> { newATM } );

        Test.stopTest();

        System.assert( actualShares.isEmpty(), 'If Account Owner is a Member of Account Team Member, share object should not be created' );
    }
    
    private static testMethod void testGrantAccessLevelToCustomObjects_ATMEqualsOwner()
    {
        setupCustomSettings();

        List<sObject> actualShares = new List<sObject>();

        Test.startTest();
            account stdAccount = new account();
            stdAccount = [select id, name from account where name ='Test Acct0' limit 1];
            
            User testUser = new User();
            testUser= [select id, name, alias from user where Alias = 'ab1' limit 1];
            
            AccountTeamMember newATM = TestingUtils.createAccountTeamMember( stdAccount.Id, testUser.Id, false );
            List<sObject> accountPlanShares = AccountTeamMemberServices.grantAccessLevelToAccountPlans( new List<AccountTeamMember> { newATM } );
            List<sObject> quoteShares = AccountTeamMemberServices.grantAccessLevelToQuotes( new List<AccountTeamMember> { newATM } );
            actualShares.addAll( accountPlanShares );
            actualShares.addAll( quoteShares );

        Test.stopTest();
        
    }
    
    private static testMethod void testGrantAccessLevelToCustomObjects_NoCustomSettings()
    {

        List<sObject> actualShares = new List<sObject>();

        Test.startTest();
            AccountTeamMember testATM  = new AccountTeamMember();
            testATM = [select id, AccountId, UserId from AccountTeamMember limit 1] ;
            List<sObject> accountPlanShares = AccountTeamMemberServices.grantAccessLevelToAccountPlans( new List<AccountTeamMember> { testATM } );
            List<sObject> quoteShares = AccountTeamMemberServices.grantAccessLevelToQuotes( new List<AccountTeamMember> { testATM } );
            actualShares.addAll( accountPlanShares );
            actualShares.addAll( quoteShares );

        Test.stopTest();

        System.assert( actualShares.isEmpty(), 'Without any Custom Settings, Custom Share Records should not be created' );
    }
    
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
    @TestVisible private static void setupUserATMFieldsCustomSettings()
    {
        
        List<ATM_with_Roles__c> customSettings = new List<ATM_with_Roles__c>();
        customSettings.add(new ATM_with_Roles__c(Name = 'Project_Manager__c', Team_Role__c = 'Project Manager Role'));
        customSettings.add(new ATM_with_Roles__c(Name = 'Account_Manager__c', Team_Role__c = 'Account Manager Role'));
        customSettings.add(new ATM_with_Roles__c(Name = 'Account_Manager_Backup__c', Team_Role__c = 'Account Backup Manager Role'));
        insert customSettings;
        
        final Integer BULK_NUMBER = 50; 
        UserService.skipSyncingPSRsToUserNetwork = true;
        
        UnitTest.addData(TestingUtils.createUsers('t', 'Standard User', BULK_NUMBER, false)).divide(2).part('Inactive Users').part('Active Users');
        UnitTest.get('Inactive Users').assign('IsActive',false).assign('Date_Deactivated__c',Date.today()).assign('Deactivation_Reason__c', 'Unused');
        UnitTest.get('Active Users').assign('IsActive',true);
        UnitTest.get(User.SObjectType).insertAll();
        
        UnitTest.createTestData(TestingUtils.primarysalesreps).many(BULK_NUMBER).tag('All PSRs').divide(2).part('Qualifying PSR').part('Non Qualifying PSR');
        UnitTest.get('Non Qualifying PSR').divide(3).part('Owner PSR').part('Inactive User PSR').part('No User PSR');
        
        UnitTest.get('Qualifying PSR').property('SF_UserID__c').assignFrom('Active Users')
                                      .divide(2).part('Group One').part('Group Two');
        UnitTest.get('Inactive User PSR').property('SF_UserID__c').assignFrom('Inactive Users')
                                      .divide(2).part('Group One').part('Group Two');
        UnitTest.get('No User PSR').divide(2).part('Group One').part('Group Two');
                                      
        UnitTest.get('Owner PSR').assign('SF_UserID__c', UserInfo.getUserId()).tag('Group Two');
        UnitTest.get(Primary_Sales_Rep__c.SObjectType).insertAll();
        
    }
	*/
    
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
    @TestVisible private static List<Account> queryAccountsWithManagerFields()
    {
        return [Select ID, OwnerId, Project_Manager__c, Project_Manager__r.SF_UserID__c, Project_Manager__r.SF_UserID__r.isActive,
                                          Account_Manager__c, Account_Manager__r.SF_UserID__c, Account_Manager__r.SF_UserID__r.isActive,
                                          Account_Manager_Backup__c, Account_Manager_Backup__r.SF_UserID__c, Account_Manager_Backup__r.SF_UserID__r.isActive FROM Account];
    }
	*/
    
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
    @TestVisible private static void setupAccountsForInsert()
    {
        setupUserATMFieldsCustomSettings();
        UnitTest.addData(TestingUtils.createAccounts('Tst Account',5)).divide(4).part('Accounts To Set Project Manager')
                                                                                  .part('Accounts To Set Account Manager')
                                                                                  .part('Accounts To Set Project Manager and Account Manager')
                                                                                  .part('Accounts To Set No Manager Fields');
        
        UnitTest.get('Accounts To Set Project Manager').property('Project_Manager__c').assignFrom('All PSRs');
        UnitTest.get('Accounts To Set Account Manager').property('Account_Manager__c').assignFrom('All PSRs');
        UnitTest.get('Accounts To Set Project Manager and Account Manager').property('Account_Manager__c').assignFrom('All PSRs')
                                                                           .property('Project_Manager__c').assignFrom('All PSRs');
    }
	*/
    
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
    private static testMethod void testQueryAccountManagerInformationFromAccounts()
    {
        setupAccountsForInsert();
        
        List<Account> accounts = UnitTest.get(Account.SObjectType).getList();
        insert accounts;
        
        Map<ID,Account> accountsExpected =  new Map<ID, Account> ([Select ID, OwnerId, Project_Manager__c, Project_Manager__r.SF_UserID__c, Project_Manager__r.SF_UserID__r.isActive,
                                          Account_Manager__c, Account_Manager__r.SF_UserID__c, Account_Manager__r.SF_UserID__r.isActive,
                                          Account_Manager_Backup__c, Account_Manager_Backup__r.SF_UserID__c, Account_Manager_Backup__r.SF_UserID__r.isActive FROM Account]);
        
        Test.startTest(); 
            Map<ID, Account> actualAccounts = new Map<ID, Account> (AccountTeamMemberServices.queryAccountManagerInformationFromAccounts(accounts));
        Test.stopTest();
        
    }
	*/
    
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
    @TestVisible 
    private static boolean userExistsAsAccountTeamMemberWithRole( Id userId, String role, List<AccountTeamMember> atms )
    {
        Boolean exists = false;
        
        for( AccountTeamMember atm : atms )
        {
            if( userId == atm.UserId && role == atm.TeamMemberRole)
            {
                exists = true;
                break;
            }
        }
        return exists;
    }
	*/
	
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
    private static Map<ID, Set<String>> getAccountToFieldsMap(String tag, Set<String> fieldsToAssociate)
    {
        Map<ID, Set<String>> accountToFields = new Map<ID, Set<String>>();
        for(Account a : (List<Account>) UnitTest.get(tag).getList())
        {
            accountToFields.put(a.ID, fieldsToAssociate);
        }   
        return accountToFields;
    }
	*/
    
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
    private static testMethod void testGetAtmsToInsert()
    {
        UserService.skipSyncingPSRsToUserNetwork = true;
        Integer NUM_USERS = 5;
        UnitTest.addData(TestingUtils.createUsers('t', 'Standard User', NUM_USERS, false)).tag('Users').dummyInsert();
        UnitTest.addData(TestingUtils.createAccounts('Tst Account',5)).tag('Accounts').dummyInsert();
        
        UnitTest.forEach('Accounts').create(NUM_USERS*2,TestingUtils.accountTeamMembers).copyProperty('ID->AccountID').tag('ATMs');
        UnitTest.get('ATMs').property('UserID').assignFrom('Users');
        
        Test.startTest();
            List<AccountTeamMember> atmsToInsert = AccountTeamMemberServices.getAtmsToInsert(UnitTest.get('ATMs').getList());
        Test.stopTest();
        
        Map<Object, Set<Object>> accountToUniqueUsers = UnitTest.get('ATMS').extractPropertyValues('AccountID->UserID');
        Map<ID, List<ID>> accountToATMUsers = new Map<ID, List<ID>>();
        
        for(AccountTeamMember a : atmsToInsert)
        {
            if(!accountToATMUsers.containsKey(a.AccountID))
            {
                accountToATMUsers.put(a.AccountID,new List<ID>());
            }
            accountToATMUsers.get(a.AccountID).add(a.UserID);
        }
        
        System.assertEquals(Pluck.ids(UnitTest.get('Accounts').getList()),accountToATMUsers.keySet(), 'We expect to get an account team member for each account');
        for(ID acctID : accountToATMUsers.keySet())
        {
            System.assertEquals(accountToUniqueUsers.get(acctID).size(),accountToATMUsers.get(acctID).size(),'We expect to return only one account team member for each user for each account');
            for(ID id : accountToATMUsers.get(acctID))
            {
                System.assert(accountToUniqueUsers.get(acctID).contains(id),'We expect to return only one account team member for each user for each account');
            }
        }
        
    }
	*/
     
    
}
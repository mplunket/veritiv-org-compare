@isTest
private class TestGrantAccessToATMBatch
{
  private static final Integer NUM_OF_OBJs = 5;

  private static Account testAccount;
  private static Contact testContact;
  private static List<Account_Plan__c> testAcctPlans;
  private static List<Case> testCases;
  private static List<Opportunity> testOppties;
  private static List<Quote__c> testQuotes;
  private static AccountTeamMember testATM;
  private static User testUser;
  private static User accountOwnerUser;  
  private static User accountOwnerChangeUser;  
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
    Id testRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get( '20. F2C - Inbound Case' ).getRecordTypeId();
    Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Customer' ).getRecordTypeId();

    accountOwnerUser = TestingUtils.createUser( 'User2', 'Standard User', true );

    testAccount = TestingUtils.createAccount( 'Test Account' );
    testAccount.OwnerId = accountOwnerUser.Id;
    testAccount.RecordTypeId = customerRTId;
    insert testAccount;

    testContact = TestingUtils.createContact( 'John', 'Doe', true );
    testUser = TestingUtils.createUser( 'User', 'Standard User', true );
    accountOwnerChangeUser = TestingUtils.createUser( 'User3', 'Standard User', true );
    testAcctPlans = TestingUtils.createAccountPlans( NUM_OF_OBJs, testAccount.Id, 'Test AcctPlan', true );
    testQuotes = TestingUtils.createQuotes( NUM_OF_OBJs, testAccount.Id, true );
    testCases = TestingUtils.generateCases( NUM_OF_OBJs, testAccount.Id, testContact.Id, testRecordTypeId, true );
    testOppties = TestingUtils.createOpportunities( NUM_OF_OBJs, testAccount.Id, 'Test Oppty', true );
    testATM = TestingUtils.createAccountTeamMember( testAccount.Id, testUser.Id, true );  
  }

  private static void setupCustomSettings()
  {
    Grant_Access_Level_ATM__c acctAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.ACCOUNT_NAME, AccountTeamMemberServices.READ_WRITE_LEVEL, false );
    Grant_Access_Level_ATM__c acctPlansToAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.ACCOUNT_PLANS_NAME, AccountTeamMemberServices.READ_ONLY_LEVEL, false );
    Grant_Access_Level_ATM__c casesToAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.CASES_NAME, AccountTeamMemberServices.READ_WRITE_LEVEL, false );
    Grant_Access_Level_ATM__c opportunityToAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.OPPORTUNITY_NAME, AccountTeamMemberServices.READ_ONLY_LEVEL, false );
    Grant_Access_Level_ATM__c quotesToAccessLvl = TestingUtils.createRelationshipToAccessLevelCS( AccountTeamMemberServices.QUOTES_NAME, AccountTeamMemberServices.READ_WRITE_LEVEL, false );
    System.runAs( TestingUtils.ADMIN_USER )
    {
      insert new List<Grant_Access_Level_ATM__c> { acctAccessLvl, acctPlansToAccessLvl, casesToAccessLvl, opportunityToAccessLvl, quotesToAccessLvl };
    }
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
    ATM_Batch_Specific_Users__c specificUser1 = new ATM_Batch_Specific_Users__c( Name = 'John Doe', UserID__c = testUser.Id );
    System.runAs( TestingUtils.ADMIN_USER )
    {
      insert specificUser1;
    }
  }

  private static testMethod void testBatch()
  {
    setup();
    setupCustomSettings();
    setupEmailCustomSettings();

    Test.startTest();

      GrantAccessToATMBatch nextBatch = new GrantAccessToATMBatch();
      Database.executeBatch( nextBatch );

    Test.stopTest();

    String expectedQuery = 'SELECT Id, AccountId, TeamMemberRole, UserId, CreatedDate, LastModifiedDate FROM AccountTeamMember';
    System.assertEquals( expectedQuery, GrantAccessToATMBatch.query, 'Without Specific User Custom Setting, query string should not include filter for getting specific users' );

    List<AccountShare> actualAccountShares = [ SELECT Id, AccountAccessLevel, CaseAccessLevel, OpportunityAccessLevel FROM AccountShare WHERE AccountId = :testAccount.Id AND UserOrGroupId = :testATM.UserId ];
    List<Account_Plan__Share> actualAccountPlanShares = [ SELECT Id, AccessLevel FROM Account_Plan__Share WHERE UserOrGroupId = :testATM.UserId ];
    List<Quote__Share> actualQuoteShares = [ SELECT Id, AccessLevel FROM Quote__Share WHERE UserOrGroupId = :testATM.UserId ];

    System.assertEquals( 1, actualAccountShares.size(), 'There should be one Account Shares per Account Team Member' );
    System.assertEquals( BatchServices.EDIT, actualAccountShares[0].AccountAccessLevel,'The Account Access Level for Account Share should have Read/Write access' );
    System.assertEquals( BatchServices.EDIT, actualAccountShares[0].CaseAccessLevel,'The Case Access Level for Account Share should have Read/Write access' );
    System.assertEquals( BatchServices.EDIT, actualAccountShares[0].OpportunityAccessLevel, 'The Opportunity Access Level for Account Share should have Read/Write access' );

    System.assertEquals( NUM_OF_OBJs, actualAccountPlanShares.size(), 'Account Plan Share should be created for each Account Plans' );
    for( Account_Plan__Share acctPlanShare : actualAccountPlanShares )
    {
      System.assertEquals( AccountTeamMemberServices.READ_ONLY_LEVEL, acctPlanShare.AccessLevel, 'The Access Level for Account Plan Share should have Read Only access' );
    }

    System.assertEquals( NUM_OF_OBJs, actualQuoteShares.size(), 'Quote Plan Share should be created for each Quotes' );
    for( Quote__Share quoteShare : actualQuoteShares )
    {
      System.assertEquals( BatchServices.EDIT, quoteShare.AccessLevel, 'The Access Level for Quote Share should have Read/Write access' );
    }
  }
  
  private static testMethod void testBatch_DeleteATM()
  {
    setupEmailCustomSettings();
    
    accountOwnerUser = TestingUtils.createUser( 'User2', 'Standard User', true );
    testUser = TestingUtils.createUser( 'User', 'Standard User', true );


    Account childAccount = TestingUtils.createAccount('Child Test Account');
    
    testAccount = TestingUtils.createAccount( 'Test Account' );
    testAccount.OwnerId = accountOwnerUser.Id;
    testAccount.National_Account__c = true;
    insert testAccount;
    
    childAccount.ParentId = testAccount.Id;
    insert childAccount;

    AccountTeamMember testATM_Owner = TestingUtils.createAccountTeamMember( childAccount.Id, accountOwnerUser.Id, AccountTeamMemberServices.NATIONAL_ACCOUNT_MANAGER_ROLE, true );
    AccountTeamMember testATM_NonOwner = TestingUtils.createAccountTeamMember( childAccount.Id, testUser.Id, AccountTeamMemberServices.NATIONAL_ACCOUNT_MANAGER_ROLE, true );
    
    Test.startTest();

      GrantAccessToATMBatch nextBatch = new GrantAccessToATMBatch();
      Database.executeBatch( nextBatch );

    Test.stopTest();

    List<AccountTeamMember> resultATMs = [SELECT Id, UserId FROM AccountTeamMember];
    
    System.assertEquals(1, resultATMs.size(), 'We expect only one ATM to be returned.');
    System.assertEquals(accountOwnerUser.Id, resultATMs[0].UserId, 'We expect the correct ATM to be returned.');
  }

  private static testMethod void testBatch_AccountOwnerChange()
  {
    setup();
    setupCustomSettings();
    setupEmailCustomSettings();
    
    GrantAccessToATMBatch nextBatch = new GrantAccessToATMBatch();
    Database.executeBatch( nextBatch );

    Test.startTest();
      
      testAccount.OwnerId = accountOwnerChangeUser.Id;
      update testAccount;
      
      GrantAccessToATMBatch reRunBatch = new GrantAccessToATMBatch();
      Database.executeBatch( reRunBatch );   

    Test.stopTest();

    String expectedQuery = 'SELECT Id, AccountId, TeamMemberRole, UserId, CreatedDate, LastModifiedDate FROM AccountTeamMember';
    System.assertEquals( expectedQuery, GrantAccessToATMBatch.query, 'Without Specific User Custom Setting, query string should not include filter for getting specific users' );

    List<AccountShare> actualAccountShares = [ SELECT Id, AccountAccessLevel, CaseAccessLevel, OpportunityAccessLevel, UserOrGroupId FROM AccountShare WHERE AccountId = :testAccount.Id AND UserOrGroupId = :testATM.UserId ];
    List<Account_Plan__Share> actualAccountPlanShares = [ SELECT Id, AccessLevel FROM Account_Plan__Share WHERE UserOrGroupId = :testATM.UserId ];
    List<Quote__Share> actualQuoteShares = [ SELECT Id, AccessLevel FROM Quote__Share WHERE UserOrGroupId = :testATM.UserId ];
     

    
    for( Account_Plan__Share acctPlanShare : actualAccountPlanShares )
    {
      System.assertEquals( AccountTeamMemberServices.READ_ONLY_LEVEL, acctPlanShare.AccessLevel, 'The Access Level for Account Plan Share should have Read Only access' );
    }

    
    for( Quote__Share quoteShare : actualQuoteShares )
    {
      System.assertEquals( BatchServices.EDIT, quoteShare.AccessLevel, 'The Access Level for Quote Share should have Read/Write access' );
    }
  }

  private static testMethod void testBatch_WithSpecificUserCustomSetting()
  {
    setup();
    setupCustomSettings();
    setupEmailCustomSettings();
    setupSpecificUserCustomSettings();

    Test.startTest();

      GrantAccessToATMBatch nextBatch = new GrantAccessToATMBatch();
      Database.executeBatch( nextBatch );

    Test.stopTest();

    String filterString = BatchServices.generateFilterQueryString( BatchServices.userIdsFromATMCS );
    String expectedQuery = 'SELECT Id, AccountId, TeamMemberRole, UserId, CreatedDate, LastModifiedDate FROM AccountTeamMember WHERE UserId IN ' + filterString;
    System.assertEquals( expectedQuery, GrantAccessToATMBatch.query, 'With Specific User Custom Setting, query string should include filter for getting specific users' );

    List<AccountShare> actualAccountShares = [ SELECT Id, AccountAccessLevel, CaseAccessLevel, OpportunityAccessLevel FROM AccountShare WHERE AccountId = :testAccount.Id AND UserOrGroupId = :testATM.UserId ];
    List<Account_Plan__Share> actualAccountPlanShares = [ SELECT Id, AccessLevel FROM Account_Plan__Share WHERE UserOrGroupId = :testATM.UserId ];
    List<Quote__Share> actualQuoteShares = [ SELECT Id, AccessLevel FROM Quote__Share WHERE UserOrGroupId = :testATM.UserId ];

    System.assertEquals( 1, actualAccountShares.size(), 'There should be one Account Shares per Account Team Member' );
    System.assertEquals( BatchServices.EDIT, actualAccountShares[0].AccountAccessLevel,'The Account Access Level for Account Share should have Read/Write access' );
    System.assertEquals( BatchServices.EDIT, actualAccountShares[0].CaseAccessLevel,'The Case Access Level for Account Share should have Read/Write access' );
    System.assertEquals( BatchServices.EDIT, actualAccountShares[0].OpportunityAccessLevel, 'The Opportunity Access Level for Account Share should have Read/Write access' );

    System.assertEquals( NUM_OF_OBJs, actualAccountPlanShares.size(), 'Account Plan Share should be created for each Account Plans' );
    for( Account_Plan__Share acctPlanShare : actualAccountPlanShares )
    {
      System.assertEquals( AccountTeamMemberServices.READ_ONLY_LEVEL, acctPlanShare.AccessLevel, 'The Access Level for Account Plan Share should have Read Only access' );
    }

    System.assertEquals( NUM_OF_OBJs, actualQuoteShares.size(), 'Quote Plan Share should be created for each Quotes' );
    for( Quote__Share quoteShare : actualQuoteShares )
    {
      System.assertEquals( BatchServices.EDIT, quoteShare.AccessLevel, 'The Access Level for Quote Share should have Read/Write access' );
    }
  }
}
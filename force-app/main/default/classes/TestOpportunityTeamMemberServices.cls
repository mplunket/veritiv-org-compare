@isTest
@TestVisible
private class TestOpportunityTeamMemberServices
{
  private static final Integer NUM_OF_OBJs = 5;
  private static final Integer NUM_OF_USERS = 5;
  private static final Integer NUM_OF_ERROR_EMAILS = 3;

  private static Id customerRTId;
  private static Id testRecordTypeId;

  private static Opportunity testOppty;
  private static OpportunityTeamMember testOTM;
  private static User testUser;
  private static List<OpportunityTeamMember> testOTMs;
  private static OpportunityTeamMember newOTM;
  private static List<User> testUsers;
  
  private static void setup()
  {
    TestingUtils.setupInactiveRecordType();
    testRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get( '02. Customer Inquiry' ).getRecordTypeId();
    customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Customer' ).getRecordTypeId();

    testUser = TestingUtils.createUser( 'User', 'Standard User', true );
    testOppty = TestingUtils.createOpportunities( 1, null, 'Test Oppty', true )[0];
    testOTM = TestingUtils.createOpportunityTeamMember( testOppty.Id, testUser.Id, true );
  }

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
  
  private static void setupBatchRunDate()
  {
    Sales_Team_Batch_Run_Date__c lastRun = new Sales_Team_Batch_Run_Date__c( Sales_Team_Last_Run_Date_Time__c = DateTime.Now().addDays(-1) );
    insert lastRun;
  }
  
  public static void setupRelationMap()
  {
    User userOne = TestingUtils.createUser( 'User', 'Standard User', true );
    UnitTest.addData( new List<User>{ userOne } ).tag('User One').tag('All Users');
    User userTwo = TestingUtils.createUser( 'User', 'Standard User', true ); 
    UnitTest.addData( new List<User>{ userTwo } ).tag('User Two').tag('All Users'); 
    
    List<Account> parentAccounts = TestingUtils.createAccounts( 'Test Parent Account', null, 4 );
    
    UnitTest.addData( parentAccounts ).tag( 'Parent Accounts').tag( 'All Accounts');
    
    UnitTest.get( 'Parent Accounts').divide(3).part('Parent Acct Owner 1').part('Parent Acct Owner 2').part('Additional Non National Parents');
    
    UnitTest.get('Parent Acct Owner 1')
        .property('National_Account__c').assign(true)
        .property('OwnerId').assign(userOne.Id);
        
    UnitTest.get('Parent Acct Owner 2')
        .property('National_Account__c').assign(true)
        .property('OwnerId').assign(userTwo.Id);

    UnitTest.get('Additional Non National Parents')
        .property('National_Account__c').assign(true)
        .property('OwnerId').assign(userTwo.Id);
        
    UnitTest.get('All Accounts').insertAll();
    
    List<Account> childAccounts = TestingUtils.createAccounts( 'Test Child Account', null, 3 );
    UnitTest.addData( childAccounts ).tag('Child Accounts').tag('All Accounts');
    UnitTest.get('Child Accounts').divide(3).part('Child Acct 1').part('Child Acct 2').part('Additional Child Non National');
    UnitTest.get('Child Acct 1').property('ParentId').assignFrom('Parent Acct Owner 1');
    UnitTest.get('Child Acct 2').property('ParentId').assignFrom('Parent Acct Owner 2');
    UnitTest.get('Additional Child Non National').property('ParentId').assignFrom('Additional Non National Parents');
    UnitTest.get('Child Accounts').insertAll();
    
    UnitTest.forEach('Child Accounts').create(1, new TestingUtils.OpportunityDG() )
                      .copyProperty('Id->AccountId')
                        .tag('All Opps'); 
    for(Opportunity opp : (List<Opportunity>) UnitTest.get('All Opps').getList())
    {
      if(opp.AccountId == UnitTest.get('Child Acct 1').getList()[0].Id)
      {
        UnitTest.addData(new List<Opportunity>{ opp } ).property('StageName').assign('1- Prospect').tag('Opp Acc 1');
      }
      else if(opp.AccountId == UnitTest.get('Child Acct 2').getList()[0].Id)
      {
        UnitTest.addData(new List<Opportunity>{ opp } ).property('StageName').assign('1- Prospect').tag('Opp Acc 2');
      }
      else
      {
        UnitTest.addData(new List<Opportunity>{ opp } ).property('StageName').assign('1- Prospect').tag('Opp Non Natl Acc');
      }
    }
    UnitTest.get('All Opps').insertAll();                    
    
    UnitTest.forEach('Opp Acc 1').create(1, new TestingUtils.OpportunityTeamMemberDG() )
                      .copyProperty('Id->OpportunityId')
                        .tag('OTM Opp Acc 1').tag('Expected OTMs').tag('All OTMs');

    UnitTest.forEach('Opp Acc 2').create(1, new TestingUtils.OpportunityTeamMemberDG() )
                      .copyProperty('Id->OpportunityId')
                        .tag('OTM Opp Acc 2').tag('All OTMs');

    UnitTest.forEach('Opp Non Natl Acc').create(1, new TestingUtils.OpportunityTeamMemberDG() )
                      .copyProperty('Id->OpportunityId')
                        .tag('OTM Opp Non Natl Acc').tag('All OTMs');

    UnitTest.get('All OTMs').property('UserId').assign(userTwo.Id);
    UnitTest.get('All OTMs').property('TeamMemberRole').assign(OpportunityTeamMemberServices.NATIONAL_ACCOUNT_MANAGER_ROLE);
    UnitTest.get('All OTMs').insertAll();
  }

  private static testMethod void testErrorEmails()
  {
    setupEmailCustomSettings();

    Test.startTest();

      System.assert( !BatchServices.ERROR_EMAILS.isEmpty(), 'The list of Error Emails should not be empty if custom setting is created' );

    Test.stopTest();
  }
  
  private static testMethod void testRelateOppToAcc()
  {
    User testingUser = TestingUtils.createUser( 'User', 'Standard User', true );
    UnitTest.addData( new List<User>{ testingUser } ).tag('Test User');
    
    List<Account> parentAccounts = TestingUtils.createAccounts( 'Test Parent Account', null, 2 );
    UnitTest.addData( parentAccounts ).tag('Parent Accounts').tag('All Accounts');
    UnitTest.get( 'Parent Accounts').divide(2).part('Parent Acct Owner 1').part('Parent Acct Owner 2');
    UnitTest.get('Parent Acct Owner 1').property('OwnerId').assign(testingUser.Id);
    
    UnitTest.get('Parent Accounts').insertAll();
    
    List<Account> childAccounts = TestingUtils.createAccounts( 'Test Child Account', testingUser.Id, 2 );
    UnitTest.addData( childAccounts ).tag('Child Accounts').tag('All Accounts');
    UnitTest.get('Child Accounts').divide(2).part('Child Acct 1').part('Child Acct 2');
    UnitTest.get('Child Acct 1').property('ParentId').assignFrom('Parent Acct Owner 1');
    UnitTest.get('Child Acct 2').property('ParentId').assignFrom('Parent Acct Owner 2');
    
    UnitTest.get('Child Accounts').insertAll();
    
    UnitTest.forEach('Child Accounts').create(1, new TestingUtils.OpportunityDG() )
                      .copyProperty('ID->AccountID')
                        .tag('All Opps');
    for(Opportunity opp : (List<Opportunity>) UnitTest.get('All Opps').getList())
    {
      if(opp.AccountId == UnitTest.get('Child Acct 1').getList()[0].Id){
        UnitTest.addData(new List<Opportunity>{ opp }).tag('Opp 1');
        UnitTest.get('Opp 1').property('StageName').assign('8- Closed Won');
      }
    } 
    UnitTest.get('All Opps').insertAll();                    
              
    
    UnitTest.forEach('All Opps').create(1, new TestingUtils.OpportunityTeamMemberDG() )
                      .copyProperty('Id->OpportunityId')
                        .tag('All OTMs');
    UnitTest.get('All OTMs').property('UserId').assign(testingUser.Id);
    UnitTest.get('All OTMs').insertAll();
    
    Test.startTest();
      Map<Opportunity, Account> actualResults = OpportunityTeamMemberServices.relateOppToAcc( UnitTest.get('All OTMs').getList());
    Test.stopTest();
    
    System.assertEquals(1, actualResults.size(), 'We expect a map of Opportunity to Account for the current OTMs');
    
    Map<Opportunity, Account> expectedResults = new Map<Opportunity, Account>();
    for(Opportunity opp : actualResults.keySet()){
      
       
        System.assertEquals(UnitTest.get('Parent Acct Owner 2').getList()[0].Id, actualResults.get(opp).Id);
       
        
       
    }
  }
  
  private static testMethod void testGetBadOTMs()
  {
    setupRelationMap();
    Map<Opportunity, Account> oppToAccMap = OpportunityTeamMemberServices.relateOppToAcc( UnitTest.get('All OTMs').getList());
    
    Test.startTest();
      Set<OpportunityTeamMember> actuals = OpportunityTeamMemberServices.getBadOTMs( UnitTest.get('All OTMs').getList(), oppToAccMap );
    Test.stopTest();
    
    UnitTest.analyze( 'Expected OTMs' ).assertEquivalence( new List<OpportunityTeamMember>(actuals) , 'The correct OTMs should be filtered');
  }
  
  private static testMethod void testUpdateOldOTMs_NoExistingOTMs()
  {
    setupRelationMap();
    
    UnitTest.get('Opp Acc 1').property('StageName').assign('8- Closed Won');
    update UnitTest.get('Opp Acc 1').getList();
    
    delete UnitTest.get('All OTMs').getList();
    
    Test.startTest();
      List<OpportunityTeamMember> updatedOTMs = OpportunityTeamMemberServices.updateOldOTMs();
    Test.stopTest();
    
    System.assertEquals(2, updatedOTMs.size(), 'We expect the correct number of OTMs to be created.');
    
    Set<Id> validUserIds = Pluck.Ids(UnitTest.get('User Two').getList());
    
    for(OpportunityTeamMember otm : updatedOTMs)
    {
      System.assert(validUserIds.contains( otm.UserId ), 'We expect the otms to be owned by the proper users.');
      System.assertEquals(OpportunityTeamMemberServices.NATIONAL_ACCOUNT_MANAGER_ROLE, otm.TeamMemberRole , 'We expect the otms role to be accurate.');
    }
    
  }
  
  private static testMethod void testUpdateOldOTMs_ExistingOTMs()
  {
    setupRelationMap();
    
    // Fails if we don't change the TeamMemberRole. Should it be?
    UnitTest.get('All OTMs').property('TeamMemberRole').assign('Buyer - Corrugated');
    update UnitTest.get('All OTMs').getList();
    
    Test.startTest();
      List<OpportunityTeamMember> updatedOTMs = OpportunityTeamMemberServices.updateOldOTMs();
    Test.stopTest();
        
    System.assertEquals(UnitTest.get('All OTMs').getList().size(), updatedOTMs.size(), 'We expect OTMs to be created since there are none in the National Account Manager role on the Opps');
  }
  
  private static testMethod void testFilterOTMsOnDate_LastRun()
  {
    setupEmailCustomSettings();
    
    Integer numToCreate = 5;
    
    User testingUser = TestingUtils.createUser( 'User', 'Standard User', true ); 
    UnitTest.addData(new List<User>{ testingUser }).tag('User');
    
    Account testAcc = TestingUtils.createAccounts( 'Test Account', testingUser.Id, 1 )[0];
    UnitTest.addData(new List<Account>{ testAcc }).tag('Account');
    insert testAcc;
    
    Opportunity opp_Before = TestingUtils.createOpportunity(testAcc.Id, 'Parent Opp Before', false); 
    UnitTest.addData(new List<Opportunity>{ opp_Before }).tag('PO Before').tag('All Parent Opps');
    Opportunity opp_After = TestingUtils.createOpportunity(testAcc.Id, 'Parent Opp After', false);
    UnitTest.addData(new List<Opportunity>{ opp_After }).tag('PO After').tag('All Parent Opps'); 
    UnitTest.get('All Parent Opps').insertAll();
    
    Map<String, Object> otm1ExpFields = new Map<String, Object>{
      'OpportunityId' => opp_Before.Id,
      'CreatedDate' =>  DateTime.Now().addDays(-2).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')
    };
    
    List<OpportunityTeamMember> otms_Before = (List<OpportunityTeamMember> ) JSONUtils.createSObjects(numToCreate , OpportunityTeamMember.getSobjectType(), otm1ExpFields);
    UnitTest.addData( otms_Before ).tag('OTM Before').tag('All OTMs');
    
    Test.startTest();
      GrantAccessToOTMBatch nextBatch = new GrantAccessToOTMBatch();
      Database.executeBatch( nextBatch );
    Test.stopTest();
    
    Map<String, Object> otm2ExpFields = new Map<String, Object>{
      'OpportunityId' => opp_After.Id,
      'CreatedDate' =>  DateTime.Now().addDays(2).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')
    };
    
    List<OpportunityTeamMember> otms_After = (List<OpportunityTeamMember> ) JSONUtils.createSObjects(numToCreate , OpportunityTeamMember.getSobjectType(), otm2ExpFields);
    UnitTest.addData( otms_After ).tag('OTM After').tag('All OTMs');
    
    List<OpportunityTeamMember> otmsToFilter = [SELECT Id, LastModifiedDate, TeamMemberRole, opportunityId, CreatedDate FROM OpportunityTeamMember];
    
    List<OpportunityTeamMember> resultRecords = OpportunityTeamMemberServices.filterOTMsOnDate( UnitTest.get('All OTMs').getList() ); //UnitTest.get('All ATMs').getList()
    
    Id apexClassId = [ SELECT Id FROM ApexClass WHERE Name = 'GrantAccessToOTMBatch' ][0].Id; 
    List<AsyncApexJob> previousBatchJobs = BatchServices.lastSuccessfulBatch( apexClassId );
    
    System.assert( !previousBatchJobs.isEmpty(), 'We expect a previous batch job to exists.');
    System.assertEquals( otms_After.size(), resultRecords.size(), 'We expect the size of the records returned to be accurate.');
    System.assert( new Set<OpportunityTeamMember>( otms_After ).equals( new Set<OpportunityTeamMember>( resultRecords )), 'We expect the records to be the same. RR: ' + resultRecords + ' Exp: ' + otms_After);
  }
  
  private static testMethod void testFilterOTMsOnDate_CustomSetting()
  {
    setupEmailCustomSettings();
    
    Integer numToCreate = 5;
    
    User testingUser = TestingUtils.createUser( 'User', 'Standard User', true ); 
    UnitTest.addData(new List<User>{ testingUser }).tag('User');
    
    Account testAcc = TestingUtils.createAccounts( 'Test Account', testingUser.Id, 1 )[0];
    UnitTest.addData(new List<Account>{ testAcc }).tag('Account');
    insert testAcc;
    
    Opportunity opp_Before = TestingUtils.createOpportunity(testAcc.Id, 'Parent Opp Before', false); 
    UnitTest.addData(new List<Opportunity>{ opp_Before }).tag('PO Before').tag('All Parent Opps');
    Opportunity opp_After = TestingUtils.createOpportunity(testAcc.Id, 'Parent Opp After', false);
    UnitTest.addData(new List<Opportunity>{ opp_After }).tag('PO After').tag('All Parent Opps'); 
    UnitTest.get('All Parent Opps').insertAll();
    
    Map<String, Object> otm1ExpFields = new Map<String, Object>{
      'OpportunityId' => opp_Before.Id,
      'CreatedDate' =>  DateTime.Now().addDays(-2).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')
    };
    
    List<OpportunityTeamMember> otms_Before = (List<OpportunityTeamMember> ) JSONUtils.createSObjects(numToCreate , OpportunityTeamMember.getSobjectType(), otm1ExpFields);
    UnitTest.addData( otms_Before ).tag('OTM Before').tag('All OTMs');
    
    setupBatchRunDate();
    
    Map<String, Object> otm2ExpFields = new Map<String, Object>{
      'OpportunityId' => opp_After.Id,
      'CreatedDate' =>  DateTime.Now().addDays(2).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')
    };
    
    List<OpportunityTeamMember> otms_After = (List<OpportunityTeamMember> ) JSONUtils.createSObjects(numToCreate , OpportunityTeamMember.getSobjectType(), otm2ExpFields);
    UnitTest.addData( otms_After ).tag('OTM After').tag('All OTMs');
    
    List<OpportunityTeamMember> otmsToFilter = [SELECT Id, LastModifiedDate, TeamMemberRole, opportunityId, CreatedDate FROM OpportunityTeamMember];
    
    Test.startTest();
      List<OpportunityTeamMember> resultRecords = OpportunityTeamMemberServices.filterOTMsOnDate( UnitTest.get('All OTMs').getList() ); //UnitTest.get('All ATMs').getList()
    Test.stopTest();
    
    Id apexClassId = [ SELECT Id FROM ApexClass WHERE Name = 'GrantAccessToOTMBatch' ][0].Id; 
    List<AsyncApexJob> previousBatchJobs = BatchServices.lastSuccessfulBatch( apexClassId );
    
    List<OpportunityTeamMember> allOTMs = UnitTest.get('All OTMs').getList();
    
    System.assert( previousBatchJobs.isEmpty(), 'We expect no previous batch job to exists.');
    System.assertEquals( allOTMs.size(), resultRecords.size(), 'We expect the size of the records returned to be accurate.');
    System.assert( new Set<OpportunityTeamMember>( allOTMs ).equals( new Set<OpportunityTeamMember>( resultRecords )), 'We expect the records to be the same. RR: ' + resultRecords + ' Exp: ' + otms_After);
  }

  private static testMethod void testGrantEditAccessLevelToOpportunityTeamMembers_EditAccessLevel()
  {
    setup();
    List<OpportunityShare> existingOpptyShares = [ SELECT Id, OpportunityAccessLevel FROM OpportunityShare WHERE UserOrGroupId = :testUser.Id AND OpportunityId = :testOppty.Id ];
    for( OpportunityShare opptyShare : existingOpptyShares )
    {
      opptyShare.OpportunityAccessLevel = BatchServices.EDIT;
    }
    update existingOpptyShares;

    Test.startTest();

      List<OpportunityShare> actualAcctShares = OpportunityTeamMemberServices.grantEditAccessLevelToOpportunityTeamMembers( new List<OpportunityTeamMember> { testOTM } );

    Test.stopTest();

    System.assert( actualAcctShares.isEmpty(), 'If Opportunity\'s Access Level is Edit(Read/Write), no share records should be returned' );
  }

  private static testMethod void testGrantEditAccessLevelToOpportunityTeamMembers_NonEditAccessLevel()
  {
    setup();
    List<OpportunityShare> existingOpptyShares = [ SELECT Id, OpportunityAccessLevel FROM OpportunityShare WHERE UserOrGroupId = :testUser.Id AND OpportunityId = :testOppty.Id ];
    for( OpportunityShare opptyShare : existingOpptyShares )
    {
      opptyShare.OpportunityAccessLevel = 'Read';
    }
    update existingOpptyShares;

    Test.startTest();

      List<OpportunityShare> actualOpptyShares = OpportunityTeamMemberServices.grantEditAccessLevelToOpportunityTeamMembers( new List<OpportunityTeamMember> { testOTM } );

    Test.stopTest();

    System.assertEquals( existingOpptyShares.size(), actualOpptyShares.size(), 'All the Opportunity Share records with Non-Edit Access Level should be returned' );
    for( OpportunityShare opptyShare : actualOpptyShares )
    {
      System.assertEquals( BatchServices.EDIT, opptyShare.OpportunityAccessLevel, 'The Access Level of Opportunity on Opportunity Team Member should be set to Read/Write' );
    }
  }

  private static void setupBulkOTMs()
  {
    testUsers = TestingUtils.createUsers( 'John', 'Standard User', NUM_OF_USERS, true );
    testOTMs = new List<OpportunityTeamMember>();
    for( User aUser : testUsers )
    {
      testOTMs.add( TestingUtils.createOpportunityTeamMember( testOppty.Id, aUser.Id, false ) );
    }
  }

  private static testMethod void testGrantEditAccessLevelToOpportunityTeamMembers_Bulk_EditAccessLevel()
  {
    setup();
    setupBulkOTMs();

    List<OpportunityShare> existingOpptyShares = [ SELECT Id, OpportunityAccessLevel FROM OpportunityShare WHERE UserOrGroupId = :testUsers AND OpportunityId = :testOppty.Id ];
    for( OpportunityShare opptyShare : existingOpptyShares )
    {
      opptyShare.OpportunityAccessLevel = BatchServices.EDIT;
    }
    update existingOpptyShares;

    Test.startTest();

      List<OpportunityShare> actualOpptyShares = OpportunityTeamMemberServices.grantEditAccessLevelToOpportunityTeamMembers( testOTMs );

    Test.stopTest();

    System.assert( actualOpptyShares.isEmpty(), 'If Opportunity\'s Access Level is Edit(Read/Write), no share records should be returned' );
  }

  private static testMethod void testGrantEditAccessLevelToOpportunityTeamMembers_Bulk_NonEditAccessLevel()
  {
    setup();
    setupBulkOTMs();

    List<OpportunityShare> existingOpptyShares = [ SELECT Id, OpportunityAccessLevel FROM OpportunityShare WHERE UserOrGroupId = :testUsers AND OpportunityId = :testOppty.Id ];
    for( OpportunityShare opptyShare : existingOpptyShares )
    {
      opptyShare.OpportunityAccessLevel = 'Read';
    }
    update existingOpptyShares;

    Test.startTest();

      List<OpportunityShare> actualOpptyShares = OpportunityTeamMemberServices.grantEditAccessLevelToOpportunityTeamMembers( testOTMs );

    Test.stopTest();

    System.assertEquals( existingOpptyShares.size(), actualOpptyShares.size(), 'All the Opportunity Share records with Non-Edit Access Level should be returned' );
    for( OpportunityShare opptyShare : actualOpptyShares )
    {
      System.assertEquals( BatchServices.EDIT, opptyShare.OpportunityAccessLevel, 'The Access Level of Opportunity on Opportunity Team Member should be set to Read/Write' );
    }
  }

  /**
  * Sets up new records where Owner of Parent record is equal to one of the Member in Opportunity Team Members
  */
  private static void setupOwnersOfParentRecordEqualToOpportunityTeamMembers()
  {
    Opportunity newOppty = TestingUtils.createOpportunities( 1, null, 'Test Oppty', false )[0];
    newOppty.OwnerId = testUser.Id;
    insert newOppty;

    newOTM = TestingUtils.createOpportunityTeamMember( newOppty.Id, testUser.Id, false );
  }

  private static testMethod void testGrantEditAccessLevelToOpportunityTeamMembers_OTMEqualsOwner()
  {
    setup();
    setupOwnersOfParentRecordEqualToOpportunityTeamMembers();

    Test.startTest();

      List<OpportunityShare> actualOpptyShares = OpportunityTeamMemberServices.grantEditAccessLevelToOpportunityTeamMembers( new List<OpportunityTeamMember> { newOTM } );

    Test.stopTest();

    System.assert( actualOpptyShares.isEmpty(), 'If Opportunity\'s Owner is a Member of Opportunity Team Member, share object should not be created' );
  }
  
  private static testMethod void testfilterOutOwnerOpportunityShares()
  {
    UserService.skipSyncingPSRsToUserNetwork = true;
    final Integer NUM_USERS = 10;
    final Integer NUM_OPPS = 2;
    
    List<User> testingUsers = TestingUtils.createUsers('zyx', 'Standard User', NUM_USERS, true);
    User owner = testingUsers[0];
    
    List<Opportunity> opps;
    List<OpportunityShare> oppShares;
    System.runAs(owner) 
    {
      Account testAccount = TestingUtils.createAccount('Test Account', true);
      opps = TestingUtils.createOpportunities(NUM_OPPS, testAccount.ID, 'Test Opportunity', true);
      oppShares = new List<OpportunityShare>();
      for(Opportunity opp : opps)
      {
        //Create an opportunity share for every user except the owner
        for(Integer i = 1; i < NUM_USERS; i++)
        {
          OpportunityShare newShare = new OpportunityShare();
          newShare.OpportunityAccessLevel = 'Edit';
          newShare.OpportunityId = opp.ID;
          newShare.UserOrGroupId = testingUsers[i].ID; 
          oppShares.add(newShare);
        }
      }
      insert oppShares;
    }
      //Set the ownerid to the second user
      for(Opportunity opp : opps)
      {
        opp.OwnerID = testingUsers[1].ID;
      }  
      update opps;
      
      List<OpportunityShare> clonedShares = new List<OpportunityShare>();
      
      for(OpportunityShare oppShare : oppShares)
      {
        OpportunityShare clonedShare = new OpportunityShare();
        clonedShare.OpportunityAccessLevel = oppShare.OpportunityAccessLevel;
        clonedShare.OpportunityId = oppShare.OpportunityId;
        clonedShare.UserOrGroupId = oppShare.UserOrGroupId;
        clonedShares.add(clonedShare);
      }
      
      Test.startTest();
        List<OpportunityShare> filteredShares;
        try
        {
          filteredShares = OpportunityTeamMemberServices.filterOutOwnerOpportunityShares(clonedShares); //ABLE TO REPRODUCE THE ERROR HERE OF INSERTING THE SAME OPP
          insert filteredShares;
        }
        catch(DMLException d)
        {
          System.assertNotEquals(StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY,d.getDmlType(0),'We should not get the insufficient access on cross reference error as opportunity shares on current owners should have been filtered out');
          System.assert(false,'There was an unexpected DML exception trying to insert the opportunity shares: ' + d.getMessage());
        }
      Test.stopTest();
      
      final Integer NUM_USERS_IN_CLONEDSHARES = NUM_USERS-1;
      final Integer EXPECTED_FILTERED_SHARES = (NUM_USERS_IN_CLONEDSHARES-1)*NUM_OPPS; //Filter out the new owner
      
      System.assertEquals(EXPECTED_FILTERED_SHARES,filteredShares.size(),'We expect to get an opportunity share for every combination of opportunity and non owner user');
      
      for(OpportunityShare ops : filteredShares)
      {
        System.assertNotEquals(testingUsers[1].ID,ops.UserOrGroupId,'We expect opportunity shares for the owners of opportunities to be filtered out');
      }
    
    
  }
    
    private static testMethod void testCalculateActiveTeamMembers()
    {
        List<String> teamRoles = OpportunityTeamMemberServices.getPicklistValues(Opportunity.Active_Sales_Team_Roles__c);
        if(teamRoles.size() > 0) {
        	String teamRole = teamRoles[0];
            
            Test.startTest();
            
            // Create User
            User u = TestingUtils.createUser( 'User', 'Standard User', true );
            
        	// Create Account
        	Account a = new Account(Name='Test Account');
            insert a;
            
            // Create Opportunity
			Opportunity o = new Opportunity(Name='Test Opp', AccountId = a.Id, StageName='1- Research', Amount=1, CloseDate=System.today());
            insert o;
            
            // Create Opportunity Team Member
            OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId=o.Id, UserId=u.Id, TeamMemberRole=teamRole);
            insert otm;
            
            Test.stopTest();
            // Test to see if role is now populated on Active Sales Team Roles field
            o = [SELECT Id, Name, Active_Sales_Team_Roles__c FROM Opportunity WHERE Id =: o.Id];
            
            System.assert(o.Active_Sales_Team_Roles__c.contains(teamRole), true);
        }
    }
    
    private static testMethod void testCalculateActiveTeamMembersDelete()
    {
        List<String> teamRoles = OpportunityTeamMemberServices.getPicklistValues(Opportunity.Active_Sales_Team_Roles__c);
        if(teamRoles.size() > 0) {
        	String teamRole = teamRoles[0];
            
            Test.startTest();
            
            // Create User
            User u = TestingUtils.createUser( 'User', 'Standard User', true );
            
        	// Create Account
        	Account a = new Account(Name='Test Account');
            insert a;
            
            // Create Opportunity
			Opportunity o = new Opportunity(Name='Test Opp', AccountId = a.Id, StageName='1- Research', Amount=1, CloseDate=System.today());
            insert o;
            
            // Create Opportunity Team Member
            OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId=o.Id, UserId=u.Id, TeamMemberRole=teamRole);
            insert otm;
            
            // Delete Team Member and check that it was removed from Active Sales Team Roles field
            delete otm;
            
            Test.stopTest();
            
            o = [SELECT Id, Name, Active_Sales_Team_Roles__c FROM Opportunity WHERE Id =: o.Id];
            
            System.assertEquals(o.Active_Sales_Team_Roles__c, null);
        }
    }
  
}
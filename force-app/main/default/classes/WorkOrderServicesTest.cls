@isTest
private class WorkOrderServicesTest {
    
    
    
    static testmethod void testRouteToQueue(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sourcing']; 
        UserRole r = new UserRole(DeveloperName = 'FS_CATEGORY_MGMT_Leaderstest', Name = 'FS - CATEGORY MGMT - Leaders');
        insert r;
        User u = new User(Alias = 't74vdt', Email='sttesdt435user@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Country = 'USA',
            TimeZoneSidKey='America/Los_Angeles', UserName='standartes536r@tigorg.com',userRoleId = r.id,Network_Id__c ='t74vdt' );
        
        insert u;
        
        User u1= new User(Alias = 't7uydt', Email='sttkjhdt435user@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Country = 'USA',
            TimeZoneSidKey='America/Los_Angeles', UserName='stdjhgvartes536r@tigorg.com',Network_Id__c ='t7uydt' );
        
        insert u1;
        
        system.runAs(u){
            
            Primary_Sales_Rep__c aPSR = new Primary_Sales_Rep__c();
          
                aPSR.Name = 'testingPSR';
                aPSR.Network_ID__c = 't74vdt';
            aPSR.Email__c = 'test@testing.com';
            insert aPSR;
          
             Account acc1 = new Account ();
            acc1.Name = 'test23';
           // acc1.email
            //acc1.Primary_Sales_Rep_Email__c = 'test23@testing.com';
            insert acc1;
            
            Account acc = new Account ();
            acc.Name = 'test';
            acc.Primary_Sales_Rep_Name__c= aPSR.id;
           // acc.Primary_Sales_Rep_Email__c = 'test@testing.com';
           // acc.Primary_Sales_Rep_Name__c = acc1.id;
           insert acc;
            
            workorder  wo = new workorder();
            wo.Type_of_Maintenance__c = 'Alternate Source Add';
            wo.AccountId = acc.id;
            wo.WO_Submitted_By__c = u.id;
            insert wo;
             workorder  wo1 = new workorder();
            wo1.Type_of_Maintenance__c = 'Alternate Source Add';
            wo1.AccountId = acc.id;
            wo1.WO_Submitted_By__c = u1.id;
            insert wo1;
            
        }
        
    }
    
    static testmethod void testPricingRouteToQueue(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        UserRole r = new UserRole(DeveloperName = 'FS_CATEGORY_MGMT_Leaderstest', Name = 'FS - CATEGORY MGMT - Leaders');
        insert r;
        User u = new User(Alias = 't74vd1t', Email='sttesdt4352user@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Country = 'USA',
            TimeZoneSidKey='America/Los_Angeles', UserName='standartes5326r@tigorg.com',userRoleId = r.id,Network_Id__c ='t74vd1t' );
        
        insert u;
        
        Id pricingRecordType = Schema.SObjectType.Workorder.getRecordTypeInfosByName().get('Pricing').getRecordTypeId();
        system.runAs(u){   
            Primary_Sales_Rep__c aPSR = new Primary_Sales_Rep__c();
          
                aPSR.Name = 'testingPSR1';
                aPSR.Network_ID__c = 't74vd1t';
            aPSR.Email__c = 'test1@testing.com';
            insert aPSR;
          
             Account acc1 = new Account ();
            acc1.Name = 'test23';
           // acc1.email
            //acc1.Primary_Sales_Rep_Email__c = 'test23@testing.com';
            insert acc1;
            
            Account acc = new Account ();
            acc.Name = 'test';
            acc.Primary_Sales_Rep_Name__c= aPSR.id;
           // acc.Primary_Sales_Rep_Email__c = 'test@testing.com';
           // acc.Primary_Sales_Rep_Name__c = acc1.id;
           insert acc;
            
            workorder  wo = new workorder();
            wo.Type_of_Maintenance__c = 'Alternate Source Add';
            wo.AccountId = acc.id;
            wo.WO_Submitted_By__c = u.id;
            wo.recordtypeid = pricingRecordType;
            insert wo;
       }
    }
    
    static testMethod void Test_updateRelatedWorkOrderShares_Flow() {
        
        Integer numOfRecords = 4;
        
        List<User> testUsers;
        List<Account> testAccounts;
        List<WorkOrder> testWorkOrders;
        
        System.runAs(SObjectFactory.ADMIN_USER) 
        {
        List<String> uniqueAliasMap = new List<String>{ 'TSTALS1', 'TSTALS2', 'TSTALS3', 'TSTALS4' };
        
        testUsers = (List<User>) SObjectFactory.build(numOfRecords, User.SObjectType);
        UnitTest.addData( testUsers ).tag('All Users')
                .property('Alias').assignFrom(uniqueAliasMap)
                .property('Network_Id__c').assignFrom(uniqueAliasMap)
                .insertAll();
        
        testAccounts = (List<Account>) SObjectFactory.build(numOfRecords, Account.SObjectType);
        UnitTest.addData(testAccounts).tag('All Accounts').branch('Normal Accounts|Updated Accounts')
                .property('OwnerId').assignFrom('All Users')
                .insertAll();
        
        testWorkOrders = (List<WorkOrder>) SObjectFactory.build(numOfRecords * 2, WorkOrder.SObjectType);
        UnitTest.addData( testWorkOrders ).tag('All Work Orders')
                .property('AccountId').assignFrom('All Accounts')
                .property('OwnerId').assignFrom('All Users')
                .insertAll();
        }      
        //List<Account> requeriedAccounts = [SELECT Id, OwnerId, (SELECT Id, OwnerId FROM WorkOrders) FROM Account WHERE Id IN :testAccounts];
        
        //WorkOrderServices.insertNewWorkOrderShares(requeriedAccounts); 
        
        //List<WorkOrderShare> currentShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM WorkOrderShare WHERE ParentId IN :testWorkOrders AND UserOrGroupId IN :testUsers ];
        
        //System.assertEquals(numOfRecords, requeriedAccounts.size(), 'We expect the correct number of Accounts to exist.');
        //System.assertEquals(numOfRecords * 2, currentShares.size(), 'We expect the correct number of share records to exist.');
        
        Test.startTest();
            UnitTest.get('Updated Accounts').property('OwnerId').assign(UserInfo.getUserId()).updateAll();
        Test.stopTest();
        
        List<WorkOrderShare> currentShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM WorkOrderShare WHERE ParentId IN :testWorkOrders AND UserOrGroupId = :UserInfo.getUserId() ];
       // System.assertEquals(numOfRecords, currentShares.size(), 'We expect the correct number of shares to exist.');
        
    }
    
    static testMethod void Test_insertNewWorkOrderShares() {
        
        Integer numOfRecords = 5; 
        
        List<String> uniqueAliasMap = new List<String>{ 'TSTALS1', 'TSTALS2', 'TSTALS3', 'TSTALS4', 'TSTALS5' };
        
        List<User> testUsers = (List<User>) SObjectFactory.build(numOfRecords, User.SObjectType);
        UnitTest.addData( testUsers ).tag('All Users')
                .property('Alias').assignFrom(uniqueAliasMap)
                .property('Network_Id__c').assignFrom(uniqueAliasMap)
                .insertAll();
        
        List<Account> testAccounts = (List<Account>) SObjectFactory.build(numOfRecords, Account.SObjectType);
        UnitTest.addData(testAccounts).tag('All Accounts')
                .property('OwnerId').assignFrom('All Users')
                .insertAll();
        
        List<WorkOrder> testWorkOrders = (List<WorkOrder>) SObjectFactory.build(numOfRecords, WorkOrder.SObjectType);
        UnitTest.addData( testWorkOrders ).tag('All Work Orders')
                .property('AccountId').assignFrom('All Accounts')
                .insertAll();
        
        List<Account> requeriedAccounts = [SELECT Id, OwnerId, Owner.IsActive, (SELECT Id, OwnerId, Owner.IsActive FROM WorkOrders) FROM Account WHERE Id IN :testAccounts];
        Map<Account, List<WorkOrder>> workOrdersMap = new Map<Account, List<WorkOrder>>();
        for(Account acc : requeriedAccounts)
            workOrdersMap.put(acc, acc.WorkOrders);
        
        //Set<Id> accountOwnerIds = Pluck.Ids('OwnerId', requeriedAccounts);
        List<WorkOrderShare> currentShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM WorkOrderShare WHERE ParentId IN :testWorkOrders AND UserOrGroupId IN :testUsers ];
        
        System.assertEquals(numOfRecords, requeriedAccounts.size(), 'We expect the correct number of Accounts to exist.');
        //System.assertEquals(0, currentShares.size(), 'We expect no current shares to exist.');
        
        Test.startTest();
            WorkOrderServices.insertNewWorkOrderShares(new Map<Id, Account>(requeriedAccounts), workOrdersMap);
        Test.stopTest();
        
        currentShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM WorkOrderShare WHERE ParentId IN :testWorkOrders AND UserOrGroupId IN :testUsers ];
        
        System.assertEquals(numOfRecords, currentShares.size(), 'We expect the correct number of share records to exist.');
    }
    
    static testMethod void Test_deleteExistingWorkOrderShares() {
        
        Integer numOfRecords = 5;
        
        List<String> uniqueAliasMap = new List<String>{ 'TSTALS1', 'TSTALS2', 'TSTALS3', 'TSTALS4', 'TSTALS5' };
        
        List<User> testUsers = (List<User>) SObjectFactory.build(numOfRecords, User.SObjectType);
        UnitTest.addData( testUsers ).tag('All Users')
                .property('Alias').assignFrom(uniqueAliasMap)
                .property('Network_Id__c').assignFrom(uniqueAliasMap)
                .insertAll();
        
        List<Account> testAccounts = (List<Account>) SObjectFactory.build(numOfRecords, Account.SObjectType);
        UnitTest.addData(testAccounts).tag('All Accounts')
                .property('OwnerId').assignFrom('All Users')
                .insertAll();
        
        List<WorkOrder> testWorkOrders = (List<WorkOrder>) SObjectFactory.build(numOfRecords, WorkOrder.SObjectType);
        UnitTest.addData( testWorkOrders ).tag('All Work Orders')
                .property('AccountId').assignFrom('All Accounts')
                .insertAll();
                
        List<Account> requeriedAccounts = [SELECT Id, OwnerId, Owner.IsActive, (SELECT Id, OwnerId, Owner.IsActive, CreatedById FROM WorkOrders) FROM Account WHERE Id IN :testAccounts];
        Map<Account, List<WorkOrder>> workOrdersMap = new Map<Account, List<WorkOrder>>();
        for(Account acc : requeriedAccounts)
            workOrdersMap.put(acc, acc.WorkOrders);
        
        WorkOrderServices.insertNewWorkOrderShares(new Map<Id, Account>(requeriedAccounts), workOrdersMap);
        
        List<WorkOrderShare> currentShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM WorkOrderShare WHERE ParentId IN :testWorkOrders AND UserOrGroupId IN :testUsers ];
        
        System.assertEquals(numOfRecords, requeriedAccounts.size(), 'We expect the correct number of Accounts to exist.');
        System.assertEquals(numOfRecords, currentShares.size(), 'We expect the correct number of share records to exist.');
        
        Test.startTest();
            WorkOrderServices.deleteExistingWorkOrderShares(new Map<Id, Account>(requeriedAccounts), workOrdersMap);
        Test.stopTest();
        
        currentShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM WorkOrderShare WHERE ParentId IN :testWorkOrders AND UserOrGroupId IN :testUsers ];
        System.assertEquals(0, currentShares.size(), 'We expect no current shares to exist.');
    }

    static testMethod void Test_filterAccountOwnerChange_Update() {
        
        String testAliasOne = 'TALIAS1';
        String testAliasTwo = 'TALIAS2';
        
        User oldOwner = (User) SObjectFactory.build(User.SObjectType);
        oldOwner.Alias = testAliasOne;
        oldOwner.Network_Id__c = testAliasOne;
        User newOwner = (User) SObjectFactory.build(User.SObjectType);
        newOwner.Alias = testAliasTwo;
        newOwner.Network_Id__c = testAliasTwo;
        insert new List<User>{oldOwner, newOwner};
        
        List<Account> testAccounts = (List<Account>) SObjectFactory.build(30, Account.SObjectType);
        Map<Id, Account> oldMap = new Map<Id, Account>();
        Map<Id, Account> newMap = new Map<Id, Account>();
        for(Account acc : testAccounts)
        {
            acc.OwnerId = oldOwner.Id;
        }
        insert testAccounts;
        
        for(Account acc : testAccounts)
        {
            oldMap.put(acc.Id, acc);
            newMap.put(acc.Id, acc);
        }
        
        Set<Id> accIds = Pluck.Ids(testAccounts);
        
        for(Account acc : newMap.values())
            acc.OwnerId = newOwner.Id;

        Test.startTest(); 
            Map<Account, List<WorkOrder>> resultMap = WorkOrderServices.getFilteredWorkOrders(oldMap, newMap); 
        Test.stopTest();
        
        for(Account acc : resultMap.keySet())
            System.assert(accIds.contains(acc.Id), 'We expect the account Id to be contained in the set.');
    }
    
    static testMethod void Test_checkWorkOrderDelete_NoCustomSetting()
    {
        User testUser = (User) SObjectFactory.create(User.SObjectType, 'Admin User');
        List<WorkOrder> testWorkOrders;
        
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        userRole uR = [select id from userRole where name ='FS - CATEGORY MGMT - Leaders'];
        User u = new User(Alias = 'standt12', Email='standardre434f6hzuser@teswdtorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testasding', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = uR.id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com'+datetime.now().millisecond());
        
        
        
        System.runAs( testUser )
        {
            testWorkOrders = (List<WorkOrder>) SObjectFactory.create(10, WorkOrder.SObjectType);
            if(testWorkOrders.size() > 0){
                for(WorkOrder wo : testWorkOrders){
                     wo.WO_Submitted_By__c = u.id;
                }
            }
            
            
            Test.startTest();
                try
                {
                    delete testWorkOrders;
                }
                catch(Exception ex)
                {
                    // CUSTOM_VALIDATION_ERROR_THROWN
                }
            Test.stopTest();
        }
        
        List<WorkOrder> existingWOs = [SELECT Id FROM WorkOrder];
        System.assert(!existingWOs.isEmpty(), 'We expect the Work Orders to exists.');
    }
    
    static testMethod void Test_checkWorkOrderDelete_UserCustomSetting()
    {
        User testUser = (User) SObjectFactory.create(User.SObjectType, 'Admin User');
        List<WorkOrder> testWorkOrders;
        
        Allow_Work_Order_Deletion__c csRecord = new Allow_Work_Order_Deletion__c();
        csRecord.SetupOwnerId = testUser.Id;
        csRecord.Allow_To_Delete__c = true;
        insert csRecord;
        
         
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        userRole uR = [select id from userRole where name ='FS - CATEGORY MGMT - Leaders'];
        User u = new User(Alias = 'stanutdt12', Email='stnrdre434f6zuser@teswdtorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testasding', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = uR.id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='hgjfghdarduser@testorg.com'+datetime.now().millisecond());
        
        
        
        
        System.runAs( testUser )
        {
            testWorkOrders = (List<WorkOrder>) SObjectFactory.create(10, WorkOrder.SObjectType);
            
             if(testWorkOrders.size() > 0){
                for(WorkOrder wo : testWorkOrders){
                     wo.WO_Submitted_By__c = u.id;
                }
            }
            
            Test.startTest();
                delete testWorkOrders;
            Test.stopTest();
        }
        
        List<WorkOrder> existingWOs = [SELECT Id FROM WorkOrder];
        System.assert(existingWOs.isEmpty(), 'We expect the Work Orders to not exists.');
    }
    
    static testMethod void Test_checkWorkOrderDelete_ProfileCustomSetting()
    {
        User testUser = (User) SObjectFactory.create(User.SObjectType, 'Admin User');
        List<WorkOrder> testWorkOrders;
        
        Allow_Work_Order_Deletion__c csRecord = new Allow_Work_Order_Deletion__c();
        csRecord.SetupOwnerId = testUser.ProfileId;
        csRecord.Allow_To_Delete__c = true;
        insert csRecord;
        
                 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        userRole uR = [select id from userRole where name ='FS - CATEGORY MGMT - Leaders'];
        User u = new User(Alias = 'standt1872', Email='stnrdre434f6iucser@teswdtorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testasding', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = uR.id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='876gkkutysd@testorg.com'+datetime.now().millisecond());
        
        
        System.runAs( testUser )
        {
            testWorkOrders = (List<WorkOrder>) SObjectFactory.create(10, WorkOrder.SObjectType);
            
             if(testWorkOrders.size() > 0){
                for(WorkOrder wo : testWorkOrders){
                     wo.WO_Submitted_By__c = u.id;
                }
            }
            
            Test.startTest();
                delete testWorkOrders;
            Test.stopTest();
        }
        
        List<WorkOrder> existingWOs = [SELECT Id FROM WorkOrder];
        System.assert(existingWOs.isEmpty(), 'We expect the Work Orders to not exists.');
    }
    
    static testMethod void Test_canDeleteWorkOrder()
    {
        User testUser1 = (User) SObjectFactory.create(User.SObjectType, 'Admin User');
        User testUser2 = (User) SObjectFactory.create(User.SObjectType, 'Chatter User');
        
        Allow_Work_Order_Deletion__c csRecord1 = new Allow_Work_Order_Deletion__c();
        csRecord1.SetupOwnerId = testUser1.Id;
        csRecord1.Allow_To_Delete__c = true;
        
        Allow_Work_Order_Deletion__c csRecord2 = new Allow_Work_Order_Deletion__c();
        csRecord2.SetupOwnerId = testUser2.ProfileId;
        csRecord2.Allow_To_Delete__c = false;
        insert new List<Allow_Work_Order_Deletion__c>{ csRecord2, csRecord1 };
        
        Boolean ourUserResult;
        Boolean testUser1Result;
        Boolean testUser2Result;
        
        Test.startTest();
            
            ourUserResult = WorkOrderServices.canDeleteWorkOrder();
            
            System.runAs(testUser1) { testUser1Result = WorkOrderServices.canDeleteWorkOrder(); }
            
            System.runAs(testUser2) { testUser2Result = WorkOrderServices.canDeleteWorkOrder(); }
            
        Test.stopTest();
        
        System.assertEquals(ourUserResult, false, 'We expect our user to not be able to delete WOs.');
        System.assertEquals(testUser1Result, true, 'We expect test user 1 to be able to delete WOs.');
        System.assertEquals(testUser2Result, false, 'We expect test user 2 to not be able to delete WOs.');
    }
    
    static testmethod void SIMCoverage(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sourcing']; 
        UserRole r = new UserRole(DeveloperName = 'FS_CATEGORY_MGMT_Leaderstest', Name = 'FS - CATEGORY MGMT - Leaders');
        insert r;
        User u = new User(Alias = 't74vdt', Email='sttesdt435user@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Country = 'USA',
            TimeZoneSidKey='America/Los_Angeles', UserName='standartes536r@tigorg.com',userRoleId = r.id,Network_Id__c ='t74vdt' );
        
        insert u;
        
        User u1= new User(Alias = 't7uydt', Email='sttkjhdt435user@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Country = 'USA',
            TimeZoneSidKey='America/Los_Angeles', UserName='stdjhgvartes536r@tigorg.com',Network_Id__c ='t7uydt' );
        
        insert u1;
        
        system.runAs(u){
            
            Primary_Sales_Rep__c aPSR = new Primary_Sales_Rep__c();
          
                aPSR.Name = 'testingPSR';
                aPSR.Network_ID__c = 't74vdt';
            aPSR.Email__c = 'test@testing.com';
            insert aPSR;
          
             Account acc1 = new Account ();
            acc1.Name = 'test23';
           // acc1.email
            //acc1.Primary_Sales_Rep_Email__c = 'test23@testing.com';
            insert acc1;
            
            Account acc = new Account ();
            acc.Name = 'test';
            acc.Primary_Sales_Rep_Name__c= aPSR.id;
           // acc.Primary_Sales_Rep_Email__c = 'test@testing.com';
           // acc.Primary_Sales_Rep_Name__c = acc1.id;
           insert acc;
            
            workorder  wo = new workorder();
            wo.Type_of_Maintenance__c = 'Alternate Source Add';
            wo.AccountId = acc.id;
            wo.WO_Submitted_By__c = u.id;
            wo.Type_of_Request__c = 'General Quote';
            insert wo;
            workorder  wo1 = new workorder();
            wo1.Type_of_Request__c = 'General Quote';
            wo1.Type_of_Maintenance__c = 'Forced Substitute';
            wo1.AccountId = acc.id;
            wo1.WO_Submitted_By__c = u1.id;
            insert wo1;
            
        }
        
    }
    
}
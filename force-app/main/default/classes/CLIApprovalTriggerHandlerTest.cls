/*
    AUTHOR: FLopez, Simplus
    Date: 09.10.20
    Description: Test class for CLIApprovalTriggerHandler a
*/

@IsTest
public class CLIApprovalTriggerHandlerTest {
    @testSetup
    public static void prepareConfig(){
        //setConfig(); // 2023-08-21 
        AIQTestSetup.setConfig(); // 2023-08-21 Zilliant deleting AIQTestSetup as it is deprecated; re-enabled until permanent fix can be put in place
        //8-17-21 Added SetupOwnerId = UserInfo.getUserId() to fix 
        // 2023-09-11 Adding a null check for UserInfo.getUserId() as this does not return a valid user when uninstalling managed packages, for instance

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];     
 
        User mgr = new User(
            Username = 'apexManager20230913@zilliant.com',
            LastName = 'Manager', 
            email='manager@zilliant.com', 
            Country='USA', 
            Alias='zm23913', 
            Network_Id__c = 'zm23913', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            localeSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.id, 
            LanguageLocaleKey = 'en_US');
        insert mgr;
        
        User usr = new User(
            Username = 'apexTest20230913@zilliant.com',
            LastName = 'Test', 
            email='test@zilliant.com', 
            Country='USA', 
            Alias='zt23913', 
            Network_Id__c = 'zt23913', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            localeSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.id,
            ManagerId = mgr.id,
            LanguageLocaleKey = 'en_US');
        insert usr;

        // DUPLICATE_VALUE, duplicate value found: SetupOwnerId
        Zilliant_Approval_Variables__c zilliantAV = new Zilliant_Approval_Variables__c(SetupOwnerId = usr.Id, Agreement_Line_Score_Threshold__c = -1, Agreement_Score_Threshold__c = 30,  Approval_Reminder_Pricing_Team_User_ID__c = '2F00539000003Xx7NA', GM_Timeframe__c = 1000, SM_Timeframe_2__c = 1000);
        insert zilliantAV;
    }
    
    private static List<Contract_Line_Item_Approval__c> clias;
    private static Contract_Line_Item_Approval__c lastClia;
    private static Integer cliasCount;
    
    private static void AfterAction(String status) {
        clias = [
                SELECT Id, Status__c, Owner.LastName, Approval_Sequence__c
                FROM Contract_Line_Item_Approval__c
                ORDER BY Name DESC
        ]; // todo: is sorting by name reliable

        system.debug('##clias: ' + clias);
        system.debug('##clias: ' + clias.size());
        cliasCount = clias.size();
        if (cliasCount>0) {
            lastClia = clias[0];
            lastClia.Status__c = status;
        }
        
    }
    
    private static zpl__ContractLineItem__c agmntLinePendAppr {
        get {
            zpl__ContractLineItem__c agmntLinePendAppr= [
                SELECT Id, RecordType.Name , zpl__Initiative__c, zpl__Status__c, zpl__Contract__c, Published_By__c, Publish_Date__c, PublishedScore__c, CurrentScore__c, Line_Item_Name__c
                FROM zpl__ContractLineItem__c 
                WHERE Name = 'testPendApprLine' LIMIT 1 FOR UPDATE];
            return agmntLinePendAppr;
        } }
    
  private static zpl__ContractLineItem__c agmntLineInactive {
        get {
            zpl__ContractLineItem__c agmntLineInactive= [
                SELECT Id, RecordType.Name , zpl__Initiative__c, zpl__Status__c, zpl__Contract__c, Published_By__c, Publish_Date__c, PublishedScore__c, CurrentScore__c, Line_Item_Name__c
                FROM zpl__ContractLineItem__c 
                WHERE Name = 'testInactiveLine' LIMIT 1 FOR UPDATE];
            return agmntLineInactive;
        } }
    
    /*
    static testMethod void testApproveAgrLineListSuccess()
    {

        zpl__ContractLineItem__c cli = [
                SELECT Id, PriceDecreaseFlag__c, StartDateDelayed__c, zpl__status__c 
                FROM zpl__ContractLineItem__c
                WHERE Name = 'testPendApprLine' Limit 1][0];
            System.debug('##testclass approved before: '+cli.Id +' - '+cli.PriceDecreaseFlag__c+' - '+cli.StartDateDelayed__c+' - '+cli.zpl__status__c + ' - ' );
            cli.zpl__Status__c = 'Pend Appr';
            cli.PriceDecreaseFlag__c = false;
            cli.Published_By__c = UserInfo.getUserId();
            System.debug('##testclass after'+cli.Id +' - '+cli.PriceDecreaseFlag__c+' - '+cli.StartDateDelayed__c+' - '+cli.zpl__status__c + ' - ' );
            
            update cli;
            
        System.debug('## CLIA TEST CLASS - ' + [Select id, ownerid, owner.name from Contract_Line_Item_Approval__c]);

        AfterAction('Approved');
        
        Test.startTest();
        if(lastClia != null){
            lastClia.Status__c = 'Approved';
            update lastClia;
        }
        Test.stopTest();
    }
    */
    static testMethod void testDelete_DeleteEvent(){
        zpl__ContractLineItem__c cli = [
                SELECT Id, PriceDecreaseFlag__c, StartDateDelayed__c, zpl__status__c 
                FROM zpl__ContractLineItem__c
                WHERE Name = 'testDraftLine' Limit 1][0]; 

        Contract_Line_Item_Approval__c cliApp = new Contract_Line_Item_Approval__c();
        cliApp.Contract_Line_Item__c = cli.id;
        insert cliApp;

        //--------------------------------------------------------------------------
        // ACT 3: set status of clia to approved
        Test.startTest();
            delete cli;
        Test.stopTest();
        List<Contract_Line_Item_Approval__c> lCLIA = [SELECT Id FROM Contract_Line_Item_Approval__c WHERE Contract_Line_Item__c = :cli.id ];
        System.assertEquals(0, lCLIA.size());
    }

    static testMethod void testDelete_DeletePicklistValue(){
        zpl__ContractLineItem__c cli = [
                SELECT Id, PriceDecreaseFlag__c, StartDateDelayed__c, zpl__status__c 
                FROM zpl__ContractLineItem__c
                WHERE Name = 'testDraftLine' Limit 1][0]; 

        Contract_Line_Item_Approval__c cliApp = new Contract_Line_Item_Approval__c();
        cliApp.Contract_Line_Item__c = cli.id;
        insert cliApp;

        //--------------------------------------------------------------------------
        // ACT 3: set status of clia to approved
        Test.startTest();
            cli.zpl__Status__c = 'Deleted';
            update cli;
        Test.stopTest();
        List<Contract_Line_Item_Approval__c> lCLIA = [SELECT Id FROM Contract_Line_Item_Approval__c WHERE Contract_Line_Item__c = :cli.id ];
        System.assertEquals(0, lCLIA.size());
    }
    
    
    static testMethod void testApprove(){
        Zilliant_Approval_Variables__c zilliantAV = [SELECT SetupOwnerId FROM Zilliant_Approval_Variables__c LIMIT 1];
        
    	Test.startTest();
        zpl__ContractLineItem__c cli = [
                SELECT Id, PriceDecreaseFlag__c, StartDateDelayed__c, zpl__status__c 
                FROM zpl__ContractLineItem__c
                WHERE Name = 'testDraftLine' Limit 1][0];
        System.debug('##'+cli.Id +' - '+cli.PriceDecreaseFlag__c+' - '+cli.StartDateDelayed__c+' - '+cli.zpl__status__c + ' - ' );
        cli.zpl__Status__c = 'Pend Appr';
        cli.PriceDecreaseFlag__c = true;
        cli.Published_By__c = zilliantAV.SetupOwnerId;
        System.debug('##'+cli.Id +' - '+cli.PriceDecreaseFlag__c+' - '+cli.StartDateDelayed__c+' - '+cli.zpl__status__c + ' - ' );
        
        //Test.startTest();
        update cli;
        
        
        

        System.debug('## CLIA TEST CLASS - ' + [Select id, ownerid, owner.name from Contract_Line_Item_Approval__c]);
        // ASSERT 2: ONE clia is inserted after setting cli to 'Pend Appr'
        AfterAction('Approved');
        System.debug('##After CLIA TEST CLASS - ' + [Select id, ownerid, owner.name from Contract_Line_Item_Approval__c]);
       // System.assertEquals(cliasCount, cliasInitially + 1);
       // System.assertEquals('Pending', lastClia.Status__c);
       // System.assertEquals('Test', lastClia.Owner.LastName);
       // System.assertEquals(1, lastClia.Approval_Sequence__c);

        //--------------------------------------------------------------------------
        // ACT 3: set status of clia to approved
        
        if(lastClia != null){
            lastClia.Status__c = 'Approved';
            update lastClia;
        }
        Test.stopTest();
    }
    
    static testMethod void testReject(){
    
        zpl__ContractLineItem__c cli = [
                SELECT Id, PriceDecreaseFlag__c, StartDateDelayed__c, zpl__status__c 
                FROM zpl__ContractLineItem__c
                WHERE Name = 'testInactiveLine' Limit 1][0];
                
        Contract_Line_Item_Approval__c cliApp = new Contract_Line_Item_Approval__c();
        cliApp.Contract_Line_Item__c = cli.id;
        insert cliApp;
        
        Test.startTest();
            cliApp.Status__c = 'Rejected';
            update cliApp;
        Test.stopTest();
    }
    
    static testMethod void testCancel(){
    
        zpl__ContractLineItem__c cli = [
                SELECT Id, PriceDecreaseFlag__c, StartDateDelayed__c, zpl__status__c 
                FROM zpl__ContractLineItem__c
                WHERE Name = 'testPendApprLine' Limit 1][0];
                
        Contract_Line_Item_Approval__c cliApp = new Contract_Line_Item_Approval__c();
        cliApp.Contract_Line_Item__c = cli.id;
        insert cliApp;
        
        Test.startTest();
            cliApp.Status__c = 'Cancelled';
            update cliApp;
        Test.stopTest();
    }
    /*
    static testMethod void testReject1AgrLineError()
    {
            List<AIQApproveRejectLineResponse> result = AIQAgrLineRejection.rejectAgrLine(new List<Id>{agmntLineInactive.id});
            //system.assertEquals('1', result.get(0).getResponseCode());
            
            zpl__ContractLineItem__c cli = [
                SELECT Id, PriceDecreaseFlag__c, StartDateDelayed__c, zpl__status__c 
                FROM zpl__ContractLineItem__c
                WHERE Name = 'testInactiveLine' Limit 1][0];
            System.debug('##testclass approved before: '+cli.Id +' - '+cli.PriceDecreaseFlag__c+' - '+cli.StartDateDelayed__c+' - '+cli.zpl__status__c + ' - ' );
            cli.zpl__Status__c = 'Pend Appr';
            cli.PriceDecreaseFlag__c = false;
            cli.Published_By__c = UserInfo.getUserId();
            System.debug('##testclass after'+cli.Id +' - '+cli.PriceDecreaseFlag__c+' - '+cli.StartDateDelayed__c+' - '+cli.zpl__status__c + ' - ' );
            
            update cli;
            
            System.debug('## CLIA TEST CLASS - ' + [Select id, ownerid, owner.name from Contract_Line_Item_Approval__c]);

        AfterAction('Rejected');
    }
    */
    
    static testMethod void testApproveAgrLineSuccess()
    {
        Test.startTest();    
        List<AIQApproveRejectLineResponse> result = AIQService.approveAgrLine(agmntLinePendAppr.id);
        //system.assertEquals('0', result.get(0).getResponseCode());
        system.assertNotEquals(null, result.get(0).getLineId());
        system.assertNotEquals(null, result.get(0).getMessage());
        Test.stopTest();
    }
    
    /*
    static testMethod void testRejectAgrLineError()
    {
        
        zpl__ContractLineItem__c cli = [
                SELECT Id, PriceDecreaseFlag__c, StartDateDelayed__c, zpl__status__c 
                FROM zpl__ContractLineItem__c
                WHERE Name = 'testPendApprLine2' Limit 1][0];
        System.debug('##testclass reject before'+cli.Id +' - '+cli.PriceDecreaseFlag__c+' - '+cli.StartDateDelayed__c+' - '+cli.zpl__status__c + ' - ' );
        cli.zpl__Status__c = 'Pend Appr';
        cli.PriceDecreaseFlag__c = false;
        cli.Published_By__c = UserInfo.getUserId();
        System.debug('##testclass after'+ cli.Id +' - '+cli.PriceDecreaseFlag__c+' - '+cli.StartDateDelayed__c+' - '+cli.zpl__status__c + ' - ' );
        
        update cli;
        
        List<AIQApproveRejectLineResponse> result = AIQAgrLineRejection.rejectAgrLine(new List<Id>{agmntLineInactive.id});
        //system.assertEquals('1', result.get(0).getResponseCode());

        System.debug('## CLIA TEST CLASS - ' + [Select id, ownerid, owner.name from Contract_Line_Item_Approval__c]);

        Test.startTest();
                list<Contract_Line_Item_Approval__c> clias = [
                        SELECT Id, Status__c, Owner.LastName, Approval_Sequence__c
                        FROM Contract_Line_Item_Approval__c
                        ORDER BY Name DESC
                ];

                clias.get(0).Status__c = 'Rejected';
                update clias;
        Test.stopTest();
    }
    */
    static testMethod void testApproveAgrLineError()
    {
        Test.startTest();
        List<AIQApproveRejectLineResponse> result = AIQAgrLineApproval.approveAgrLine(new List<Id>{agmntLineInactive.id});
        //system.assertEquals('1', result.get(0).getResponseCode());
        Test.stopTest();
    }
    /*
    static testMethod void testApproveAgrLineException()
    {
        Test.startTest();
        User usr = [SELECT id, username FROM User WHERE username = 'apexTest@zilliant.com' LIMIT 1];
        zpl__ContractLineItem__c testLine = [
                SELECT Id, RecordType.Name , zpl__Initiative__c, zpl__Status__c, zpl__Contract__c, Published_By__c, Publish_Date__c, PublishedScore__c, CurrentScore__c, Line_Item_Name__c
                FROM zpl__ContractLineItem__c 
                WHERE Name = 'testPendApprLine' LIMIT 1 FOR UPDATE];
        //testLine = agmntLinePendAppr;
        system.debug('testLine: '+testLine);
        system.debug('usr: '+usr);
        System.runAs(usr){
            List<AIQApproveRejectLineResponse> result = AIQAgrLineApproval.approveAgrLine(new List<Id>{testLine.id});
          //system.assertEquals('1', result.get(0).getResponseCode());
          system.debug(result);
        }
        
        Test.stopTest();
    }

    static testMethod void testApprvTrue()
    {
        Test.startTest();
        User usr = [SELECT id, username FROM User WHERE username = 'apexTest@zilliant.com' LIMIT 1];
        zpl__ContractLineItem__c testLine = [
                SELECT Id, RecordType.Name , zpl__Initiative__c, zpl__Status__c, zpl__Contract__c, Published_By__c, Publish_Date__c, PublishedScore__c, CurrentScore__c, Line_Item_Name__c
                FROM zpl__ContractLineItem__c 
                WHERE Name = 'testPendApprLine1' LIMIT 1 FOR UPDATE];
        //testLine = agmntLinePendAppr;
        system.debug('testLine: '+testLine);
        system.debug('usr: '+usr);
        System.runAs(usr){
            List<AIQApproveRejectLineResponse> result = AIQAgrLineApproval.approveAgrLine(new List<Id>{testLine.id});
          //system.assertEquals('1', result.get(0).getResponseCode());
          system.debug(result);
        }
        
        Test.stopTest();
    }
    */

    public static void setConfig(){
        //AIQZilliantConnector__c connector = new AIQZilliantConnector__c(Name = 'api.zpm', grantType__c = 'password', clientId__c = 'xxxxxxx', clientSecret__c= 'xxxxxxx', username__c='test', password__c= 'xxxxxxx');
        //upsert connector;
        zpf__ZMicroServicesConfiguration__c zApiConfig = new zpf__ZMicroServicesConfiguration__c (  zpf__ZMicroServicesHost__c = 'https://testAPIVetitiv.com');
        upsert zApiConfig;
        AIQZilliantConfiguration__c customConfig = new  AIQZilliantConfiguration__c (GetPriceDataFormula__c='f_getAPIContractLineData'
                                                                                    , GetRecommendationsFormula__c='testFormula'
                                                                                    , ManagersPermissionSet__c = 'TestPermSet'
                                                                                    , SalesAdminProfiles__c='System Administrator'
                                                                                    , BatchJobSize__c = 200
                                                                                    , EffectiveDateHorizon__c = 180
                                                                                    , LineScoreThreshold__c = 101
                                                                                    , FESEnabledLineLevel__c='Item\nSet\nSubset'
                                                                                    , FESRequestSize__c = 20
                                                                                    , NotificationGroup__c = 'andriy.sukh@zilliant.com \n andriy.sukh@zilliant.com'
                                                                                    , GetPriceDataFormulaEE__c = 'f_getAPIContractLineData'
                                                                                    , FESThreads__c = 1
                                                                                    , runZcloudSync__c = true
                                                                                    , runCLIZcloudSync__c = true
                                                                                    , runContractZcloudSync__c = true
                                                                                    , LineSourceSyncExclusions__c = 'C'
                                                                                    , UserSyncExclusions__c = 'andriy.sukh@zilliant.com'
                                                                                    );
        upsert customConfig;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];     
        
        User usr = new User(
            Username = 'apexTest@zilliant.com',
            LastName = 'Test', 
            email='test@zilliant.com', 
            Country='USA', 
            Alias='ztest', 
            Network_Id__c = 'ztest', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            localeSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.id, 
            LanguageLocaleKey = 'en_US');
        
        User usr2 = new User(
            Username = 'apexTest2@zilliant.com',
            LastName = 'Test2', 
            email='test2@zilliant.com', 
            Country='USA', 
            Alias='ztest2', 
            Network_Id__c = 'ztest2', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            localeSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.id, 
            LanguageLocaleKey = 'en_US');
        
        List<User> usrs = new List<User>{usr, usr2};
        insert usrs;
        
        
        
        Servicing_Division__c div = new Servicing_Division__c(name='TestDiv', Division_Code__c = '01', Division_Composite_Key__c='0301');
        upsert div;
        
        Account cAcct = new Account(Name='ZilliantTestChainAcct', Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='AI', zpl__CustomerId__c = 'SW000003', AccountNumber='000003', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, Regional_Acct_Group_ID__c = 'testCA'
                                   , RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Chain_Account').getRecordTypeId()
                                   , BillingStateInitial__c='01');
        
        Account cAcctWoContract = new Account(Name='ZilliantTestChainAcctWoContract', Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='AI', zpl__CustomerId__c = 'SW000005', AccountNumber='000005', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, Regional_Acct_Group_ID__c = 'testCA'
                                   , RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Chain_Account').getRecordTypeId()
                                   , BillingStateInitial__c='01'
                                   , Representative_Customer__c = 'SW000001'
                                   , Representative_Division__c = '0301');
        
        Account acct = new Account(Name='ZilliantTestAcct', OwnerId = usr.id, Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='AI', zpl__CustomerId__c = 'SW000001', AccountNumber='000001', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, Natl_Acct_Group_ID__c='testNA', Regional_Acct_Group_ID__c = 'testCA', Chain_Account_Code__c = '000003', Chain_Account__c = cAcct.Id, BillingStateInitial__c='01'
                                  , RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId());
        Account acctWoContract = new Account(Name='ZilliantTestAcctWoContract', OwnerId = usr.id, Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='AI', zpl__CustomerId__c = 'SW000002', AccountNumber='000002', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, BillingStateInitial__c='01'
                                  , RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId());
        Account acctInactive = new Account(Name='ZilliantTestInactiveAcct', Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='Y', zpl__CustomerId__c = 'SW000004', AccountNumber='000004', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, BillingStateInitial__c='01'
                                  , RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId());        
        list<Account> accts = new List<Account>{acct, acctWoContract, acctInactive, cAcct, cAcctWoContract};
        upsert accts;
        /*
        Ship_To__c shipTo = new Ship_To__c(Bill_To_Account__c = acct.id, Account_Owner__c= usr.Id);
        upsert shipTo;
        */
        Contract agmnt = new Contract(AccountId = acct.id
                                      ,zpl__ContractId__c = 'ContractExternalId1'
                                      ,OwnerId = usr.id
                                      , Name = 'ZilliantTestAgreement'
                                      , Status= 'Draft'
                                      , RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PricingContract').getRecordTypeId()
                                      , Division__c = div.Id
                                     );
        
        Contract cAgmnt = new Contract(AccountId = cAcct.id
                                       , zpl__ContractId__c = 'ContractExternalId2'
                                       , Name = 'ZilliantTestChainAgreement'
                                       , Status= 'Draft'
                                       , RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PricingContract').getRecordTypeId()
                                       , Division__c = div.Id
                                      );
        List<Contract> agrmnts = new List<Contract>{agmnt, cAgmnt}; 
            upsert agrmnts;
        
        
        NationalAccountsPricing__c na = new NationalAccountsPricing__c (NationalAccountGroupID__c = 'testNA', Class__c = 'A', Price__c=1, Name='00000003', CompositeKey__c='SWtestNA');
        NationalAccountsPricing__c na2 = new NationalAccountsPricing__c (NationalAccountGroupID__c = 'testNA', Class__c = 'B', Price__c=0, Name='00000004', CompositeKey__c='SWtestNA');
        List<NationalAccountsPricing__c> NAs = new List<NationalAccountsPricing__c>{na, na2};
        upsert NAs;
        
        zsx__Initiative2__c camp = new zsx__Initiative2__c (Name = 'TestCamp');
        upsert camp;
        
        Product2 prdct = new Product2 (Name = 'ZilliantTestProduct', System_id__c= '03', ProductCode='00000001', isActive = True, Division_Code__c='01', List_Price__c=1.0, Pricing_Costing_UOM__c= 'SH');
        upsert prdct;
        Product2 prdct2 = new Product2 (Name = 'ZilliantTesReptProduct', System_id__c= '03', ProductCode='00000001', isActive = True, Division_Code__c='01', List_Price__c=1.0, Pricing_Costing_UOM__c= 'SH');
        upsert prdct2;

        AIQ_CWTItem__c cwtItem = new AIQ_CWTItem__c(CBSSKey__c = 'SW010101010001', Product__c= prdct2.Id);
        AIQ_CWTItem__c cwtItem2 = new AIQ_CWTItem__c(CBSSKey__c = 'SW0101010100010001', Product__c= prdct2.Id);
        upsert  new List<AIQ_CWTItem__c>{cwtItem, cwtItem2};

        zpl__PolicyType__c maintGTMType = new zpl__PolicyType__c(zpl__PolicyTypeId__c='maintainGTM');
        zpl__PolicyType__c natAcctType = new zpl__PolicyType__c(zpl__PolicyTypeId__c='nationalAccount');
        List<zpl__PolicyType__c> policyTypes = new List<zpl__PolicyType__c>{maintGTMType, natAcctType};
        upsert policyTypes;
        
        zpl__ProductSelectorConfiguration__c testPSconfig = new zpl__ProductSelectorConfiguration__c(zpl__TargetObject__c='Contract', name = 'Add Contract Products', zpl__UniqueNickname__c = 'DefaultContract');
        upsert testPSconfig;
        zpl__LineLevel__c item = new zpl__LineLevel__c(zpl__LineLevelId__c = 'Item', Name = 'Item', zpl__Position__c=1, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c subSet = new zpl__LineLevel__c(zpl__LineLevelId__c = 'Subset', Name = 'Subset', zpl__Position__c=2, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c setLevel = new zpl__LineLevel__c(zpl__LineLevelId__c = 'Set', Name = 'Set', zpl__Position__c=3, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c brand = new zpl__LineLevel__c(zpl__LineLevelId__c = 'Brand', Name = 'Brand', zpl__Position__c=4, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c classLevel = new zpl__LineLevel__c(zpl__LineLevelId__c = 'Class', Name = 'Class', zpl__Position__c=5, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c brandVendor = new zpl__LineLevel__c(zpl__LineLevelId__c = 'BrandVendor', Name = 'BrandVendor', zpl__Position__c=6, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c classVendor = new zpl__LineLevel__c(zpl__LineLevelId__c = 'ClassVendor', Name = 'ClassVendor', zpl__Position__c=7, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        List<zpl__LineLevel__c> levels = new List<zpl__LineLevel__c>{item,subSet,setLevel,brand,classLevel,brandVendor,classVendor};
        upsert levels;

        insert getTestLineLevelProductMaps(levels);
        
        zpl__ProductUOM__c uomA = new zpl__ProductUOM__c(zpl__ProductUOMId__c = 'SW0100000001SH', zpl__ConversionFactor__c=1, Name='SH', zpl__Product__c = prdct.Id);
        zpl__ProductUOM__c uomB = new zpl__ProductUOM__c(zpl__ProductUOMId__c = 'SW0100000001M', zpl__ConversionFactor__c=1, Name='M', zpl__Product__c = prdct.Id);
        List<zpl__ProductUOM__c> uoms = new List<zpl__ProductUOM__c>{uomA, uomB};
            upsert uoms;    
        
        zpl__ContractLineItem__c draftAgrmntLine = new zpl__ContractLineItem__c(Name='testDraftLine'
                                                                                , zpl__ContractLineItemId__c = 'testExternalId1'
                                                                                , zpl__Contract__c = agmnt.id
                                                                                , zpl__Status__c = 'Draft'
                                                                                , zpl__LineLevel__c = item.Id
                                                                                , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId()
                                                                                , zpl__EffectiveDate__c=null
                                                                                , zpl__Initiative__c = null
                                                                                , zpl__Product__c = prdct.id
                                                                                , PublishedScore__c = 0
                                                                                , Approved_By__c = null
                                                                                , Approved_Date__c = null
                                                                                , Published_By__c = null
                                                                                , Publish_Date__c = null
                                                                                , Rejected_By__c = null
                                                                                , Rejected_Date__c = null
                                                                                , Inactivated_By__c = null
                                                                                , Inactivated_Date__c = null
                                                                                , SKU__c='00000001'
                                                                                , System__c='SW'
                                                                                , zpl__PolicyValue__c=0
                                                                                , Class__c='01'
                                                                                , Brand__c='0101'
                                                                                , Set__c='0001'
                                                                                , Subset__c='0001'
                                                                                , zpl__PolicyType__c = maintGTMType.id
                                                                                , zpl__UOM__c = uomA.id
                                                                                , Segment__c = 'PR'
                                                                                , Division_Code2__c = '01'
                                                                                , VendorCode__c = '01'
                                                                                , isCurrent__c = True
                                                                                , SupersededDate__c = null
                                                                                , ExternalCostDeviationDate__c = Date.today()
                                                                                , DisallowCampaignsThroughDate__c = Date.today()
                                                                                , CampaignAppealedLine__r = new zpl__ContractLineItem__c(zpl__ContractLineItemId__c = 'testExternalId12')
                                                                                , IsCampaignAppealed__c = true
                                                                                //, Reason_Code__c = 'A - Competitive Reason'
                                                                               );
        
        zpl__ContractLineItem__c draftCampAgrmntLine = new zpl__ContractLineItem__c(Name='testDraftCampLine'
                                                                                    , zpl__ContractLineItemId__c = 'testExternalId2'
                                                                                    , zpl__Contract__c = agmnt.id
                                                                                    , zpl__Status__c = 'Draft'
                                                                                    , zpl__LineLevel__c = classLevel.Id
                                                                                    , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId()
                                                                                    , zpl__EffectiveDate__c=date.today()
                                                                                    , zpl__Initiative__c = camp.Id
                                                                                    , zpl__Product__c = prdct.id
                                                                                    , PublishedScore__c = 0
                                                                                    , Approved_By__c = null
                                                                                    , Approved_Date__c = null
                                                                                    , Published_By__c = null
                                                                                    , Publish_Date__c = null
                                                                                    , Rejected_By__c = null
                                                                                    , Rejected_Date__c = null
                                                                                    , Inactivated_By__c = null
                                                                                    , Inactivated_Date__c = null
                                                                                    , SKU__c='00000001'
                                                                                    , System__c='SW'
                                                                                    , zpl__PolicyValue__c=0
                                                                                    , Class__c='01'
                                                                                    , Brand__c='0101'
                                                                                    , Set__c='0001'
                                                                                    , Subset__c='0001'
                                                                                    , zpl__PolicyType__c = maintGTMType.id
                                                                                    , zpl__UOM__c = uomA.id
                                                                                    , Segment__c = 'PR'
                                                                                    , Division_Code2__c = '01'
                                                                                    , VendorCode__c = '01'
                                                                                    , isCurrent__c = True
                                                                                    , SupersededDate__c = null
                                                                                    , ExternalCostDeviationDate__c = Date.today()
                                                                                    , DisallowCampaignsThroughDate__c = Date.today()
                                                                                    , Reason_Code__c = 'J - New Item'
                                                                                   );
        
        zpl__ContractLineItem__c activeAgrmntLine = new zpl__ContractLineItem__c(Name='testActiveLine'
                                                                                 , zpl__ContractLineItemId__c = 'testExternalId3'
                                                                                 , zpl__Contract__c = agmnt.id
                                                                                 , zpl__LineLevel__c = subSet.Id
                                                                                 , CampaignAppealedLine__r = new zpl__ContractLineItem__c(zpl__ContractLineItemId__c = 'testExternalId12')
                                                                                 , zpl__Status__c = 'Published'
                                                                                 , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId()
                                                                                 , zpl__EffectiveDate__c=date.today()-1
                                                                                 , zpl__Initiative__c = null
                                                                                 , zpl__Product__c = prdct.id
                                                                                 , PublishedScore__c = 0
                                                                                 , Approved_By__c = UserInfo.getUserId()
                                                                                 , Approved_Date__c = DateTime.now()
                                                                                 , Published_By__c = UserInfo.getUserId()
                                                                                 , Publish_Date__c = DateTime.now()
                                                                                 , Rejected_By__c = null
                                                                                 , Rejected_Date__c = null
                                                                                 , Inactivated_By__c = null
                                                                                 , Inactivated_Date__c = null
                                                                                 , SKU__c='00000001'
                                                                                 , System__c='SW'
                                                                                 , zpl__PolicyValue__c=0
                                                                                 , Class__c='01'
                                                                                 , Brand__c='0101'
                                                                                 , Set__c='0001'
                                                                                 , Subset__c='0001'
                                                                                 , zpl__PolicyType__c = maintGTMType.id
                                                                                 , zpl__UOM__c = uomA.id
                                                                                 , Segment__c = 'PR'
                                                                                 , Division_Code2__c = '01'
                                                                                 , VendorCode__c = '01'
                                                                                 , isCurrent__c = True
                                                                                 , SupersededDate__c = null
                                                                                 , ExternalCostDeviationDate__c = Date.today()
                                                                                 , DisallowCampaignsThroughDate__c = Date.today()
                                                                                 , Net_Price__c = 100.00
                                                                                 , zpl__Error__c = 'Api callout error'
                                                                                 , IsCampaignAppealed__c = true
                                                                                 , Reason_Code__c = 'A - Competitive Reason'
                                                                                );
        
        zpl__ContractLineItem__c activeCampAgrmntLine = new zpl__ContractLineItem__c(Name='testActiveCampLine'
                                                                                     , zpl__ContractLineItemId__c = 'testExternalId4'
                                                                                     , zpl__Contract__c = agmnt.id
                                                                                     , zpl__Status__c = 'Published'
                                                                                     , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId()
                                                                                     , zpl__EffectiveDate__c=date.today()-2
                                                                                     , zpl__Initiative__c = camp.Id
                                                                                     , zpl__Product__c = prdct.id
                                                                                     , PublishedScore__c = 0
                                                                                     , Approved_By__c = UserInfo.getUserId()
                                                                                     , Approved_Date__c = DateTime.now()
                                                                                     , Published_By__c = UserInfo.getUserId()
                                                                                     , Publish_Date__c = DateTime.now()
                                                                                     , Rejected_By__c = null
                                                                                     , Rejected_Date__c = null
                                                                                     , Inactivated_By__c = null
                                                                                     , Inactivated_Date__c = null
                                                                                     , SKU__c='00000001'
                                                                                     , System__c='SW'
                                                                                     , zpl__PolicyValue__c=0
                                                                                     , Class__c='01'
                                                                                     , Brand__c='0101'
                                                                                     , Set__c='0001'
                                                                                     , Subset__c='0001'
                                                                                     , zpl__PolicyType__c = maintGTMType.id
                                                                                     , zpl__UOM__c = uomA.id
                                                                                     , Segment__c = 'PR'
                                                                                     , Division_Code2__c = '01'
                                                                                     , VendorCode__c = '01'
                                                                                     , isCurrent__c = True
                                                                                     , SupersededDate__c = null
                                                                                     , ExternalCostDeviationDate__c = Date.today()
                                                                                     , DisallowCampaignsThroughDate__c = Date.today()
                                                                                     , Net_Price__c = 100.00
                                                                                     ,zpl__Error__c = 'Api callout error'
                                                                                     , Reason_Code__c = 'J - New Item'
                                                                                    );
        
        zpl__ContractLineItem__c inactiveAgrmntLine = new zpl__ContractLineItem__c(Name='testInactiveLine'
                                                                                   , zpl__ContractLineItemId__c = 'testExternalId5'
                                                                                   , zpl__Contract__c = agmnt.id
                                                                                   , zpl__Status__c = 'Deleted'
                                                                                   , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Inactive').getRecordTypeId()
                                                                                   , zpl__EffectiveDate__c=date.today()
                                                                                   , zpl__Initiative__c = null
                                                                                   , zpl__Product__c = prdct.id
                                                                                   , PublishedScore__c = 0
                                                                                   , Approved_By__c = UserInfo.getUserId()
                                                                                   , Approved_Date__c = DateTime.now()
                                                                                   , Published_By__c = UserInfo.getUserId()
                                                                                   , Publish_Date__c = DateTime.now()
                                                                                   , Rejected_By__c = null
                                                                                   , Rejected_Date__c = null
                                                                                   , Inactivated_By__c = UserInfo.getUserId()
                                                                                   , Inactivated_Date__c = DateTime.now()
                                                                                   , SKU__c='00000001'
                                                                                   , System__c='SW'
                                                                                   , zpl__PolicyValue__c=0
                                                                                   , Class__c='01'
                                                                                   , Brand__c='0101'
                                                                                   , Set__c='0001'
                                                                                   , Subset__c='0001'
                                                                                   , zpl__PolicyType__c = maintGTMType.id
                                                                                   , zpl__UOM__c = uomA.id
                                                                                   , Segment__c = 'PR'
                                                                                   , Division_Code2__c = '01'
                                                                                   , VendorCode__c = '01'
                                                                                   , isCurrent__c = False
                                                                                   , SupersededDate__c = null
                                                                                   , ExternalCostDeviationDate__c = Date.today()
                                                                                   , DisallowCampaignsThroughDate__c = Date.today()
                                                                                   , Reason_Code__c = 'J - New Item'
                                                                                  );
        
        zpl__ContractLineItem__c pendApprAgrmntLine = new zpl__ContractLineItem__c(Name='testPendApprLine'
                                                                                   , zpl__ContractLineItemId__c = 'testExternalId6'
                                                                                   , zpl__Contract__c = agmnt.id
                                                                                   , zpl__Status__c = 'Pend Appr'
                                                                                   , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId()
                                                                                   , zpl__EffectiveDate__c=date.today()
                                                                                   , zpl__Initiative__c = null
                                                                                   , zpl__Product__c = prdct.id
                                                                                   , PublishedScore__c = 0
                                                                                   , Approved_By__c = null
                                                                                   , Approved_Date__c = null
                                                                                   , Published_By__c = UserInfo.getUserId()
                                                                                   , Publish_Date__c = DateTime.now()
                                                                                   , Rejected_By__c = null
                                                                                   , Rejected_Date__c = null
                                                                                   , Inactivated_By__c = null
                                                                                   , Inactivated_Date__c = null
                                                                                   , SKU__c='00000001'
                                                                                   , System__c='SW'
                                                                                   , zpl__PolicyValue__c=0
                                                                                   , Class__c='01'
                                                                                   , Brand__c='0101'
                                                                                   , Set__c='0001'
                                                                                   , Subset__c='0001'
                                                                                   , zpl__PolicyType__c = maintGTMType.id
                                                                                   , zpl__UOM__c = uomA.id
                                                                                   , Segment__c = 'PR'
                                                                                   , Division_Code2__c = '01'
                                                                                   , VendorCode__c = '01'
                                                                                   , isCurrent__c = True
                                                                                   , SupersededDate__c = null
                                                                                   , ExternalCostDeviationDate__c = Date.today()
                                                                                   , DisallowCampaignsThroughDate__c = Date.today()
                                                                                   , Reason_Code__c = 'J - New Item'
                                                                                  );
        
        zpl__ContractLineItem__c activeFutureAgrmntLine = new zpl__ContractLineItem__c(Name='testActiveFutureLine'
                                                                                       , zpl__ContractLineItemId__c = 'testExternalId7'
                                                                                       , zpl__Contract__c = agmnt.id
                                                                                       , zpl__Status__c = 'Published'
                                                                                       , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId()
                                                                                       , zpl__EffectiveDate__c=date.today()+1
                                                                                       , zpl__Initiative__c = null
                                                                                       , zpl__Product__c = prdct.id
                                                                                       , PublishedScore__c = 0
                                                                                       , Approved_By__c = UserInfo.getUserId()
                                                                                       , Approved_Date__c = DateTime.now()
                                                                                       , Published_By__c = UserInfo.getUserId()
                                                                                       , Publish_Date__c = DateTime.now()
                                                                                       , Rejected_By__c = null
                                                                                       , Rejected_Date__c = null
                                                                                       , Inactivated_By__c = null
                                                                                       , Inactivated_Date__c = null
                                                                                       , SKU__c='00000002'
                                                                                       , System__c='SW'
                                                                                       , zpl__PolicyValue__c=0
                                                                                       , Class__c='01'
                                                                                       , Brand__c='0101'
                                                                                       , Set__c='0001'
                                                                                       , Subset__c='0001'
                                                                                       , zpl__PolicyType__c = maintGTMType.id
                                                                                       , zpl__UOM__c = uomA.id
                                                                                       , Segment__c = 'PR'
                                                                                       , Division_Code2__c = '01'
                                                                                       , VendorCode__c = '01'
                                                                                       , isCurrent__c = True
                                                                                       , SupersededDate__c = null
                                                                                       , ExternalCostDeviationDate__c = Date.today()
                                                                                       , DisallowCampaignsThroughDate__c = Date.today()
                                                                                       , Net_Price__c = 10.00
                                                                                       , zpl__Error__c = 'API error occured'
                                                                                       , Reason_Code__c = 'J - New Item'
                                                                                      );
        
        zpl__ContractLineItem__c activeDuplicateAgrmntLine = new zpl__ContractLineItem__c(Name='testActiveDuplicateLine'
                                                                                          , zpl__ContractLineItemId__c = 'testExternalId8'
                                                                                          , zpl__Contract__c = agmnt.id
                                                                                          , zpl__Status__c = 'Published'
                                                                                          , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId()
                                                                                          , zpl__EffectiveDate__c=date.today()
                                                                                          , zpl__Initiative__c = null
                                                                                          , zpl__Product__c = prdct.id
                                                                                          , PublishedScore__c = 0
                                                                                          , Approved_By__c = UserInfo.getUserId()
                                                                                          , Approved_Date__c = DateTime.now()
                                                                                          , Published_By__c = UserInfo.getUserId()
                                                                                          , Publish_Date__c = DateTime.now()
                                                                                          , Rejected_By__c = null
                                                                                          , Rejected_Date__c = null
                                                                                          , Inactivated_By__c = null
                                                                                          , Inactivated_Date__c = null
                                                                                          , SKU__c='00000001'
                                                                                          , System__c='SW'
                                                                                          , zpl__PolicyValue__c=0
                                                                                          , Class__c='01'
                                                                                          , Brand__c='0101'
                                                                                          , Set__c='0001'
                                                                                          , Subset__c='0001'
                                                                                          , zpl__PolicyType__c = maintGTMType.id
                                                                                          , zpl__UOM__c = uomA.id
                                                                                          , Segment__c = 'PR'
                                                                                          , Division_Code2__c = '01'
                                                                                          , VendorCode__c = '01'
                                                                                          , isCurrent__c = True
                                                                                          , SupersededDate__c = null
                                                                                          , ExternalCostDeviationDate__c = Date.today()
                                                                                          , DisallowCampaignsThroughDate__c = Date.today()
                                                                                          , zpl__Error__c = 'API error occured'
                                                                                          , Reason_Code__c = 'J - New Item'
                                                                                         );
        
        zpl__ContractLineItem__c chainAgrmntLineA = new zpl__ContractLineItem__c(Name='testChainLineA'
                                                                                 , zpl__ContractLineItemId__c = 'testExternalId9'
                                                                                 , zpl__Contract__c = cAgmnt.id
                                                                                 , zpl__Status__c = 'Published'
                                                                                 , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId()
                                                                                 , zpl__EffectiveDate__c=date.today()-1
                                                                                 , zpl__Initiative__c = null
                                                                                 , zpl__Product__c = prdct.id
                                                                                 , PublishedScore__c = 0
                                                                                 , Approved_By__c = UserInfo.getUserId()
                                                                                 , Approved_Date__c = DateTime.now()
                                                                                 , Published_By__c = UserInfo.getUserId()
                                                                                 , Publish_Date__c = DateTime.now()
                                                                                 , Rejected_By__c = null
                                                                                 , Rejected_Date__c = null
                                                                                 , Inactivated_By__c = null
                                                                                 , Inactivated_Date__c = null
                                                                                 , SKU__c='00000001'
                                                                                 , System__c='SW'
                                                                                 , zpl__PolicyValue__c=0
                                                                                 , Class__c='01'
                                                                                 , Brand__c='0101'
                                                                                 , Set__c='0001'
                                                                                 , Subset__c='0001'
                                                                                 , zpl__PolicyType__c = maintGTMType.id
                                                                                 , zpl__UOM__c = uomA.id
                                                                                 , Segment__c = 'PR'
                                                                                 , Division_Code2__c = '01'
                                                                                 , VendorCode__c = '01'
                                                                                 , isCurrent__c = True
                                                                                 , SupersededDate__c = null
                                                                                 , ExternalCostDeviationDate__c = Date.today()
                                                                                 , DisallowCampaignsThroughDate__c = Date.today()
                                                                                 , zpl__Error__c = 'API error occured'
                                                                                 , Reason_Code__c = 'J - New Item'
                                                                                );
        
        zpl__ContractLineItem__c chainAgrmntLineB = new zpl__ContractLineItem__c(Name='testChainLineB'
                                                                                 , zpl__ContractLineItemId__c = 'testExternalId10'
                                                                                 , zpl__Contract__c = cAgmnt.id
                                                                                 , zpl__Status__c = 'Draft'
                                                                                 , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId()
                                                                                 , zpl__EffectiveDate__c=date.today()-1
                                                                                 , zpl__Initiative__c = null
                                                                                 , zpl__Product__c = prdct.id
                                                                                 , PublishedScore__c = 0
                                                                                 , Approved_By__c = UserInfo.getUserId()
                                                                                 , Approved_Date__c = DateTime.now()
                                                                                 , Published_By__c = UserInfo.getUserId()
                                                                                 , Publish_Date__c = DateTime.now()
                                                                                 , Rejected_By__c = null
                                                                                 , Rejected_Date__c = null
                                                                                 , Inactivated_By__c = null
                                                                                 , Inactivated_Date__c = null
                                                                                 , SKU__c='00000002'
                                                                                 , System__c='SW'
                                                                                 , zpl__PolicyValue__c=0
                                                                                 , Class__c='01'
                                                                                 , Brand__c='0101'
                                                                                 , Set__c='0001'
                                                                                 , Subset__c='0001'
                                                                                 , zpl__PolicyType__c = maintGTMType.id
                                                                                 , zpl__UOM__c = uomA.id
                                                                                 , Segment__c = 'PR'
                                                                                 , Division_Code2__c = '01'
                                                                                 , VendorCode__c = '01'
                                                                                 , isCurrent__c = True
                                                                                 , SupersededDate__c = null
                                                                                 , ExternalCostDeviationDate__c = Date.today()
                                                                                 , DisallowCampaignsThroughDate__c = Date.today()
                                                                                 , zpl__Error__c = 'API error occured'
                                                                                 , Reason_Code__c = 'J - New Item'
                                                                                );
        
        zpl__ContractLineItem__c purgeAgrmntLine = new zpl__ContractLineItem__c(Name='testPurgeLine'
                                                                                , zpl__ContractLineItemId__c = 'testExternalId11'
                                                                                , zpl__Contract__c = agmnt.id
                                                                                , zpl__Status__c = 'Deleted'
                                                                                , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Inactive').getRecordTypeId()
                                                                                , zpl__EffectiveDate__c=date.today().addYears(-7)-1
                                                                                , zpl__Initiative__c = null
                                                                                , zpl__Product__c = prdct.id
                                                                                , PublishedScore__c = 0
                                                                                , Approved_By__c = UserInfo.getUserId()
                                                                                , Approved_Date__c = DateTime.now()
                                                                                , Published_By__c = UserInfo.getUserId()
                                                                                , Publish_Date__c = DateTime.now()
                                                                                , Rejected_By__c = null
                                                                                , Rejected_Date__c = null
                                                                                , Inactivated_By__c = UserInfo.getUserId()
                                                                                , Inactivated_Date__c = DateTime.now()
                                                                                , SKU__c='00000001'
                                                                                , System__c='SW'
                                                                                , zpl__PolicyValue__c=0
                                                                                , Class__c='01'
                                                                                , Brand__c='0101'
                                                                                , Set__c='0001'
                                                                                , Subset__c='0001'
                                                                                , zpl__PolicyType__c = maintGTMType.id
                                                                                , zpl__UOM__c = uomA.id
                                                                                , Segment__c = 'PR'
                                                                                , Division_Code2__c = '01'
                                                                                , VendorCode__c = '01'
                                                                                , isCurrent__c = False
                                                                                , SupersededDate__c = date.today().addYears(-7)
                                                                                , ExternalCostDeviationDate__c = Date.today()
                                                                                , DisallowCampaignsThroughDate__c = Date.today()
                                                                                , zpl__Error__c = 'API error occured'
                                                                                , Reason_Code__c = 'J - New Item'
                                                                               );
        
        zpl__ContractLineItem__c campaignLineA = new zpl__ContractLineItem__c(Name='testCampaignLineA'
                                                                                , InitiativeActionId__c = 1000
                                                                                 , zpl__ContractLineItemId__c = 'testExternalId12'
                                                                                 , zpl__Contract__c = cAgmnt.id
                                                                                 , zpl__Status__c = 'Published'
                                                                                 , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId()
                                                                                 , zpl__EffectiveDate__c=date.today()-1
                                                                                 , zpl__Initiative__c =  camp.Id
                                                                                 , zpl__Product__c = null
                                                                                 , PublishedScore__c = 0
                                                                                 , Approved_By__c = UserInfo.getUserId()
                                                                                 , Approved_Date__c = DateTime.now()
                                                                                 , Published_By__c = UserInfo.getUserId()
                                                                                 , Publish_Date__c = DateTime.now()
                                                                                 , Rejected_By__c = null
                                                                                 , Rejected_Date__c = null
                                                                                 , Inactivated_By__c = null
                                                                                 , Inactivated_Date__c = null
                                                                                 , SKU__c='00000001'
                                                                                 , System__c='SW'
                                                                                 , zpl__PolicyValue__c=0
                                                                                 , Class__c='01'
                                                                                 , Brand__c='0101'
                                                                                 , Set__c='0001'
                                                                                 , Subset__c='0001'
                                                                                 , zpl__PolicyType__c = maintGTMType.id
                                                                                 , zpl__UOM__c = uomA.id
                                                                                 , Segment__c = 'PR'
                                                                                 , Division_Code2__c = '01'
                                                                                 , VendorCode__c = '01'
                                                                                 , isCurrent__c = True
                                                                                 , SupersededDate__c = null
                                                                                 , ExternalCostDeviationDate__c = Date.today()
                                                                                 , DisallowCampaignsThroughDate__c = Date.today()
                                                                                 , zpl__Error__c = 'API error occured'
                                                                                 , Reason_Code__c = 'J - New Item'
                                                                                );
        insert campaignLineA;
        
        zpl__ContractLineItem__c naAgrmntLineA = new zpl__ContractLineItem__c(Name='testNaAgrmntLineA'
                                                                                , zpl__ContractLineItemId__c = 'testExternalIdNaAgrmntLineA'
                                                                                , zpl__LineLevel__c = item.Id
                                                                                , zpl__Contract__c = agmnt.Id
                                                                                , zpl__Status__c = 'Draft'
                                                                                , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId()
                                                                                , zpl__EffectiveDate__c=null
                                                                                , zpl__Product__c = prdct.Id
                                                                                , SKU__c='00000003'
                                                                                , System__c='SW'
                                                                                , zpl__PolicyValue__c=0
                                                                                , Class__c='01'
                                                                                , Brand__c='0101'
                                                                                , Set__c='0001'
                                                                                , Subset__c='0001'
                                                                                , zpl__PolicyType__c = maintGTMType.id
                                                                                , Segment__c = 'PR'
                                                                                , Division_Code2__c = '01'
                                                                                , VendorCode__c = '01'
                                                                                , IsNAPriced__c = false
                                                                                , LineSource__c = 'C'
                                                                                );
        
        zpl__ContractLineItem__c naAgrmntLineB = new zpl__ContractLineItem__c(Name='testNaAgrmntLineB'
                                                                                , zpl__ContractLineItemId__c = 'testExternalIdNaAgrmntLineB'
                                                                                , zpl__LineLevel__c = item.Id
                                                                                , zpl__Contract__c = agmnt.Id
                                                                                , zpl__Status__c = 'Draft'
                                                                                , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId()
                                                                                , zpl__EffectiveDate__c=null
                                                                                , zpl__Product__c = prdct.Id
                                                                                , SKU__c='00000004'
                                                                                , System__c='SW'
                                                                                , zpl__PolicyValue__c=0
                                                                                , Class__c='01'
                                                                                , Brand__c='0101'
                                                                                , Set__c='0001'
                                                                                , Subset__c='0001'
                                                                                , zpl__PolicyType__c = maintGTMType.id
                                                                                , Segment__c = 'PR'
                                                                                , Division_Code2__c = '01'
                                                                                , VendorCode__c = '01'
                                                                                , IsNAPriced__c = false
                                                                                , LineSource__c = 'C'
                                                                                );

        zpl__ContractLineItem__c pendApprAgrmntLine1 = new zpl__ContractLineItem__c(Name='testPendApprLine1'
                                                                                , zpl__ContractLineItemId__c = 'testExternalIdABC'
                                                                                , zpl__Contract__c = agmnt.id
                                                                                , zpl__Status__c = 'Pend Appr'
                                                                                , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId()
                                                                                , zpl__EffectiveDate__c=date.today().addYears(1)
                                                                                , zpl__Initiative__c = null
                                                                                , zpl__Product__c = prdct.id
                                                                                , PublishedScore__c = 0
                                                                                , Approved_By__c = null
                                                                                , Approved_Date__c = null
                                                                                , Published_By__c = UserInfo.getUserId()
                                                                                , Publish_Date__c = DateTime.now()
                                                                                , Rejected_By__c = null
                                                                                , Rejected_Date__c = null
                                                                                , Inactivated_By__c = null
                                                                                , Inactivated_Date__c = null
                                                                                , SKU__c='00000001'
                                                                                , System__c='SW'
                                                                                , zpl__PolicyValue__c=0
                                                                                , Class__c='01'
                                                                                , Brand__c='0101'
                                                                                , Set__c='0001'
                                                                                , Subset__c='0001'
                                                                                , zpl__PolicyType__c = maintGTMType.id
                                                                                , zpl__UOM__c = uomA.id
                                                                                , Segment__c = 'PR'
                                                                                , Division_Code2__c = '01'
                                                                                , VendorCode__c = '01'
                                                                                , isCurrent__c = True
                                                                                , SupersededDate__c = null
                                                                                , ExternalCostDeviationDate__c = Date.today()
                                                                                , DisallowCampaignsThroughDate__c = Date.today()
                                                                                , Reason_Code__c = 'J - New Item'
                                                                                , PriceDecreaseFlag__c = true
                                                                                , CampaignAppealedLine__c = campaignLineA.Id
                                                                                );

        zpl__ContractLineItem__c pendApprAgrmntLine2 = new zpl__ContractLineItem__c(Name='testPendApprLine2'
                                                                                , zpl__ContractLineItemId__c = 'testExternalIdABCD'
                                                                                , zpl__Contract__c = agmnt.id
                                                                                , zpl__Status__c = 'Pend Appr'
                                                                                , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId()
                                                                                , zpl__EffectiveDate__c=date.today()
                                                                                , zpl__Initiative__c = null
                                                                                , zpl__Product__c = prdct.id
                                                                                , PublishedScore__c = 0
                                                                                , Approved_By__c = null
                                                                                , Approved_Date__c = null
                                                                                , Published_By__c = UserInfo.getUserId()
                                                                                , Publish_Date__c = DateTime.now()
                                                                                , Rejected_By__c = null
                                                                                , Rejected_Date__c = null
                                                                                , Inactivated_By__c = null
                                                                                , Inactivated_Date__c = null
                                                                                , SKU__c='00000001'
                                                                                , System__c='SW'
                                                                                , zpl__PolicyValue__c=0
                                                                                , Class__c='01'
                                                                                , Brand__c='0101'
                                                                                , Set__c='0001'
                                                                                , Subset__c='0001'
                                                                                , zpl__PolicyType__c = maintGTMType.id
                                                                                , zpl__UOM__c = uomA.id
                                                                                , Segment__c = 'PR'
                                                                                , Division_Code2__c = '01'
                                                                                , VendorCode__c = '01'
                                                                                , isCurrent__c = True
                                                                                , SupersededDate__c = null
                                                                                , ExternalCostDeviationDate__c = Date.today()
                                                                                , DisallowCampaignsThroughDate__c = Date.today()
                                                                                , Reason_Code__c = 'J - New Item'
                                                                                , PriceDecreaseFlag__c = false
                                                                                );

        List<zpl__ContractLineItem__c> agrmntLines = new List<zpl__ContractLineItem__c>{draftAgrmntLine, draftCampAgrmntLine, activeAgrmntLine, activeCampAgrmntLine, inactiveAgrmntLine, pendApprAgrmntLine, pendApprAgrmntLine1, pendApprAgrmntLine2, activeFutureAgrmntLine, activeDuplicateAgrmntLine, chainAgrmntLineA, chainAgrmntLineB, purgeAgrmntLine, naAgrmntLineA, naAgrmntLineB};
        upsert agrmntLines;
        
        zpl__IQAnywhereConfiguration__c iqAnywhere = new zpl__IQAnywhereConfiguration__c(Name = 'f_getAPIContractLineData', zpl__ErrorFieldName__c = 'zpl__Error__c', zpl__SourceObject__c = 'zpl__ContractLineItem__c', zpl__EnableLogging__c = false);
        upsert iqAnywhere;
        
    }
    
    private static List<zpl__LineLevelProductMap__c> getTestLineLevelProductMaps(List<zpl__LineLevel__c> levels) {
        List<zpl__LineLevelProductMap__c> result = new List<zpl__LineLevelProductMap__c>();

        for (zpl__LineLevel__c level : levels) {
            if (TEST_LINE_LEVEL_PRODUCT_MAPS_BY_LEVEL_NAME.containsKey(level.Name)) {
                for (zpl__LineLevelProductMap__c lineLevelProductMap : TEST_LINE_LEVEL_PRODUCT_MAPS_BY_LEVEL_NAME.get(level.Name)) {
                    lineLevelProductMap.zpl__LineLevel__c = level.Id;
                    result.add(lineLevelProductMap);
                }
            }
        }

        return result;
    }

    private static final Map<String, List<zpl__LineLevelProductMap__c>> TEST_LINE_LEVEL_PRODUCT_MAPS_BY_LEVEL_NAME = new Map<String, List<zpl__LineLevelProductMap__c>>{
            'Item' => new List<zpl__LineLevelProductMap__c> {
                    new zpl__LineLevelProductMap__c(Name = 'AL_ItemName__c', zpl__LineField__c = 'Name'),
                    new zpl__LineLevelProductMap__c(Name = 'AL_ShortSegment__c', zpl__LineField__c = 'Segment__c')
            },
            'Subset' => new List<zpl__LineLevelProductMap__c> {
                    new zpl__LineLevelProductMap__c(Name = 'AL_SubsetName__c', zpl__LineField__c = 'Name'),
                    new zpl__LineLevelProductMap__c(Name = 'AL_Subset__c', zpl__LineField__c = 'Subset__c')
            }
    };

}
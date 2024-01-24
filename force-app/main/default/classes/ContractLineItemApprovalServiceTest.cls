/***
 * Created by haydarhadi on 2019-08-18.
 */
@IsTest 
    public class ContractLineItemApprovalServiceTest {
    /*
  * This method prepares the test data of this class.
  */

    private static Id userId1; // 1st tier approver
    private static Id userId2; // 2nd tier approver
    private static Id userId3; // delegate

    private static List<Contract_Line_Item_Approval__c> clias;
    private static Contract_Line_Item_Approval__c lastClia;
    private static Integer cliasCount;
    private static void AfterAction() {
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
        }
        
    }

    @TestSetup
    public static void prepareConfig(){
            
        setConfig();

        

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        insert new User(
                Username = 'test3@zilliant2trxf43.com',
                LastName = 'Test3',
                Email='test3@zilliant.com',
                Country='USA',
                Alias='ztest3',
                Network_Id__c = 'ztest3',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = p.Id,
                LanguageLocaleKey = 'en_US');

        //List<User> users = new List<User>();
        
        
        Map<String, User> mapNameToUser = new Map<String, User>();
        for(User user : [SELECT Id, Name, LastName, Email FROM User WHERE name IN ('TestPSR','Test', 'Test2', 'Test3')]) {
            System.debug('######' + user.LastName + ' - Email:' + user.Email);
            mapNameToUser.put(user.LastName, user);
            
           
            //usr2.managerId = usr.Id;

            user.ZM_SM_Email__c = 'testx@zilliant.com';
            user.Dir_Email__c   = 'test2x@zilliant.com';

            if (user.LastName == 'Test' ) userId1 = user.Id;
            if (user.LastName == 'Test2') userId2 = user.Id;
            if (user.LastName == 'Test3') userId3 = user.Id;
        }

    // Set managers (Approvers) to users        
        for(User user : mapNameToUser.values() ){
            if (user.LastName == 'TestPSR' ) user.ManagerId = mapNameToUser.get('Test').id;
            if (user.LastName == 'Test') user.ManagerId = mapNameToUser.get('Test2').id;
        }
        
        
        update mapNameToUser.values();
        
        User runningUser = [Select Id, Lastname From User Where LastName = 'TestUserSysAd' Limit 1];
        
        System.runAs(runningUser){
        
        Zilliant_Approval_Variables__c variable = new Zilliant_Approval_Variables__c();
        variable.SM_Timeframe_2__c = 2;
        variable.Approval_Reminder_Pricing_Team_User_ID__c = [SELECT Id FROM User WHERE IsActive=TRUE LIMIT 1][0].Id;
        insert variable;
        
        Contract agmnt= [SELECT Id FROM Contract WHERE Name = 'ZilliantTestAgreement' LIMIT 1];

        zpl__ContractLineItem__c cli = new zpl__ContractLineItem__c(Name='testDraftLine'
                , zpl__ContractLineItemId__c = 'testExternalIdDraftLine'
                , zpl__Contract__c = agmnt.Id
                , zpl__Status__c = 'Draft'
                , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId()
                , zpl__EffectiveDate__c=null
        );
        insert cli;

        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'ZilliantTestAcct' LIMIT 1][0];

        Primary_Sales_Rep__c testPSR = TestingUtils.createPSRs(1, 'ztestpsr', 'ztestpsr', true).get(0);
        testPSR.SF_userid__c = mapNameToUser.get('TestPSR').Id;
        update testPSR;

        acc.Primary_Sales_Rep_Name__c = testPSR.Id;
        update acc;
        }
    }

    static testMethod void testApprovalTiers()
    {
        //System.runAs(runningUser){
            FullTest(false);
       // }
    }

    static testMethod void testDelegation()
    {
        User runningUser = [Select Id, Lastname From User Where LastName = 'Test3' Limit 1];
        
        //System.runAs(runningUser){
            FullTest(true);
        //}
    }

    private static void PrepareUserData(Boolean hasDelegate) {
        for(User user : [SELECT Id, Name, LastName, Email FROM User WHERE Name IN ('TestPSR', 'Test', 'Test2', 'Test3')]) {
            if (user.LastName == 'Test' ) userId1 = user.Id;
            if (user.LastName == 'Test2') userId2 = user.Id;
            if (user.LastName == 'Test3') userId3 = user.Id;
        }
        
        //system.debug('@@@@ ' + [SELECT Id, Name, LastName, managerid, manager.managerid, Email FROM User WHERE LastName IN ('TestPSR', 'Test', 'Test2', 'Test3')] );
        system.debug('@@@@ ' + [SELECT Id, Name, LastName, managerid, manager.managerid, Email FROM User ] );
        User user2 = [SELECT Id, LastName FROM User WHERE LastName = 'Test2' limit 1];
        user2.Pricing_Delegated_Approver__c = userId3; 
        user2.Delegation_Start_Date__c = Date.newInstance(1999, 1, 1);
        user2.Delegation_End_Date__c = Date.newInstance(1999, 1, 3);
        ContractLineItemApprovalService.current_date =
                hasDelegate
                        ? Date.newInstance(1999, 1, 2)  // inside the range
                        : Date.newInstance(1999, 1, 4); // outside the range
        update user2;
    }

    static void FullTest(Boolean hasDelegate) {
        Test.startTest();
        //--------------------------------------------------------------------------
        // Init
        PrepareUserData(hasDelegate);
        AfterAction();
        Integer cliasInitially = cliasCount;

        //--------------------------------------------------------------------------
        // ACT 2: Setting a darft cli to "Pend Appr"
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        insert new User(
                Username = 'test41@zilliant2trxf43.com',
                LastName = 'Test41',
                Email='test41@zilliant.com',
                Country='USA',
                Alias='ztest41',
                Network_Id__c = 'ztest41',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = p.Id,
                LanguageLocaleKey = 'en_US');
                
        User runningUser = [Select Id, Lastname From User Where LastName = 'TestPSR' Limit 1];
        
        zpl__ContractLineItem__c cli = [
                SELECT Id, PriceDecreaseFlag__c, StartDateDelayed__c, zpl__status__c 
                FROM zpl__ContractLineItem__c
                WHERE Name = 'testDraftLine' Limit 1][0];
        System.debug('##'+cli.Id +' - '+cli.PriceDecreaseFlag__c+' - '+cli.StartDateDelayed__c+' - '+cli.zpl__status__c + ' - ' );
        cli.zpl__Status__c = 'Pend Appr';
        cli.PriceDecreaseFlag__c = true;
        cli.Published_By__c = runningUser.Id != null ? runningUser.Id : UserInfo.getUserId();
        System.debug('##'+cli.Id +' - '+cli.PriceDecreaseFlag__c+' - '+cli.StartDateDelayed__c+' - '+cli.zpl__status__c + ' - ' );
        
        //Test.startTest();
        update cli;
        
        
        

        System.debug('## CLIA TEST CLASS - ' + [Select id, ownerid, owner.name from Contract_Line_Item_Approval__c]);
        // ASSERT 2: ONE clia is inserted after setting cli to 'Pend Appr'
        AfterAction();
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
        

        // ASSERT 3:
        String SecondOwnerName = hasDelegate ? 'Test3' : 'Test2';
        AfterAction();
       // System.assertEquals(cliasCount, cliasInitially + 2);
       // System.assertEquals('Pending', lastClia.Status__c);
       // System.assertEquals(SecondOwnerName, lastClia.Owner.LastName);
       // System.assertEquals(2, lastClia.Approval_Sequence__c);

        //--------------------------------------------------------------------------
        // ACT 4: set status to approved
        if(lastClia != null){
            lastClia.Status__c = 'Approved';
        update lastClia;
        }
        
        AfterAction();
        Test.stopTest();
        // ASSERT 4: no new clia is created.
       // System.assertEquals(cliasCount, cliasInitially + 2); // no new clia was created
       // System.assertEquals('Approved', lastClia.Status__c);
       // System.assertEquals(SecondOwnerName, lastClia.Owner.LastName);
       // System.assertEquals(2, lastClia.Approval_Sequence__c);

        

    }

    public static void setConfig(){
        //AIQZilliantConnector__c connector = new AIQZilliantConnector__c(Name = 'api.zpm', grantType__c = 'password', clientId__c = 'xxxxxxx', clientSecret__c= 'xxxxxxx', username__c='test', password__c= 'xxxxxxx');
        //upsert connector;
        

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        
        User usrPsr = new User(
            Username = 'testpsrx@zilliant.com',
            LastName = 'TestPSR',
            email='testpsrx@zilliant.com',
            Country='USA',
            Alias='ztestpsr',
            Network_Id__c = 'ztestpsr',
            TimeZoneSidKey = 'America/Los_Angeles',
            localeSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.id,
            LanguageLocaleKey = 'en_US');


        User usr = new User(
                Username = 'testx@zilliant.com',
                LastName = 'Test',
                email='testx@zilliant.com',
                Country='USA',
                Alias='ztest',
                Network_Id__c = 'ztest',
                TimeZoneSidKey = 'America/Los_Angeles',
                localeSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = p.id,
                LanguageLocaleKey = 'en_US');

        User usr2 = new User(
                Username = 'test2x@zilliant.com',
                LastName = 'Test2',
                email='test2x@zilliant.com',
                Country='USA',
                Alias='ztest2',
                Network_Id__c = 'ztest2',
                TimeZoneSidKey = 'America/Los_Angeles',
                localeSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = p.id,
                LanguageLocaleKey = 'en_US');
                
        Profile pSysAd = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User UserSysAd = new User(
                Username = 'testUserSysAd@zilliant2trxf43.com',
                LastName = 'TestUserSysAd',
                Email='testUserSysAd@zilliant.com',
                Country='USA',
                Alias='ztest4',
                Network_Id__c = 'ztest4',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = pSysAd.Id,
                LanguageLocaleKey = 'en_US');        

        List<User> usrs = new List<User>{usrPsr, usr, usr2,UserSysAd};
        insert usrs;
        
        
        system.runAs(UserSysAd){
        
        zpf__ZMicroServicesConfiguration__c zApiConfig = new zpf__ZMicroServicesConfiguration__c (  zpf__ZMicroServicesHost__c = 'https://testAPIVetitiv.com');
        upsert zApiConfig;
        AIQZilliantConfiguration__c customConfig = new  AIQZilliantConfiguration__c (GetPriceDataFormula__c='f_getAPIContractLineData'
                , GetRecommendationsFormula__c='testFormula'
                , ManagersPermissionSet__c = 'TestPermSet'
                , SalesAdminProfiles__c='System Administrator'
                , BatchJobSize__c = 200
                , EffectiveDateHorizon__c = 180
                , LineScoreThreshold__c = 101
        );
        upsert customConfig;

        Servicing_Division__c div = new Servicing_Division__c(name='TestDiv', Division_Code__c = '01');
        upsert div;

        Account acct = new Account(Name='ZilliantTestAcct', OwnerId = usrPsr.id, Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='AI', zpl__CustomerId__c = 'SW000001', AccountNumber='000001', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, Natl_Acct_Group_ID__c='testNA', Regional_Acct_Group_ID__c = 'testCA', Chain_Account_Code__c = '000003', BillingStateInitial__c='01');
        Account acctWoContract = new Account(Name='ZilliantTestAcctWoContract', OwnerId = usrPsr.id, Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='AI', zpl__CustomerId__c = 'SW000002', AccountNumber='000002', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, BillingStateInitial__c='01');
        Account cAcct = new Account(Name='ZilliantTestChainAcct', OwnerId = usrPsr.id, Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='AI', zpl__CustomerId__c = 'SW000003', AccountNumber='000003', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, Regional_Acct_Group_ID__c = 'testCA'
                , RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Chain_Account').getRecordTypeId()
                , BillingStateInitial__c='01');
        Account acctInactive = new Account(Name='ZilliantTestInactiveAcct', OwnerId = usrPsr.id, Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='Y', zpl__CustomerId__c = 'SW000004', AccountNumber='000004', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, BillingStateInitial__c='01');
        list<Account> accts = new List<Account>{acct, acctWoContract, cAcct, acctInactive};
        upsert accts;
        /*
        Ship_To__c shipTo = new Ship_To__c(Bill_To_Account__c = acct.id, Account_Owner__c= usr.Id);
        upsert shipTo;
        */
        Contract agmnt = new Contract(AccountId = acct.id
                ,zpl__ContractId__c = 'ContractExternalId1'
                ,OwnerId = usrPsr.id
                , Name = 'ZilliantTestAgreement'
                , Status= 'Draft'
                , RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PricingContract').getRecordTypeId()
                , Division__c = div.Id
        );

        Contract cAgmnt = new Contract(AccountId = cAcct.id
                , zpl__ContractId__c = 'ContractExternalId2'
                , OwnerId = usrPsr.id
                , Name = 'ZilliantTestChainAgreement'
                , Status= 'Draft'
                , RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PricingContract').getRecordTypeId()
                , Division__c = div.Id
        );
        List<Contract> agrmnts = new List<Contract>{agmnt, cAgmnt};
        upsert agrmnts;


        NationalAccountsPricing__c na = new NationalAccountsPricing__c (NationalAccountGroupID__c = 'testNA', Class__c = 'A', Price__c=1, Name='00000003');
        NationalAccountsPricing__c na2 = new NationalAccountsPricing__c (NationalAccountGroupID__c = 'testNA', Class__c = 'B', Price__c=0, Name='00000004');
        List<NationalAccountsPricing__c> NAs = new List<NationalAccountsPricing__c>{na, na2};
        upsert NAs;

        zsx__Initiative2__c camp = new zsx__Initiative2__c (Name = 'TestCamp');
        upsert camp;

        Product2 prdct = new Product2 (Name = 'ZilliantTestProduct', System_id__c= '03', ProductCode='00000001', isActive = True, Division_Code__c='01', List_Price__c=1.0, Pricing_Costing_UOM__c= 'SH');
        upsert prdct;

        zpl__PolicyType__c maintGTMType = new zpl__PolicyType__c(zpl__PolicyTypeId__c='maintainGTM');
        zpl__PolicyType__c natAcctType = new zpl__PolicyType__c(zpl__PolicyTypeId__c='nationalAccount');
        zpl__PolicyType__c fixedPriceType = new zpl__PolicyType__c(zpl__PolicyTypeId__c='fixedPrice');
        List<zpl__PolicyType__c> policyTypes = new List<zpl__PolicyType__c>{maintGTMType, natAcctType};
        upsert policyTypes;

        zpl__ProductSelectorConfiguration__c testPSconfig = new zpl__ProductSelectorConfiguration__c(zpl__TargetObject__c='Contract', name = 'Add Contract Products', zpl__UniqueNickname__c = 'DefaultContract');
        upsert testPSconfig;
        zpl__LineLevel__c item = new zpl__LineLevel__c(zpl__LineLevelId__c = 'Item', zpl__Position__c=1, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c subSet = new zpl__LineLevel__c(zpl__LineLevelId__c = 'Subset', zpl__Position__c=2, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c setLevel = new zpl__LineLevel__c(zpl__LineLevelId__c = 'Set', zpl__Position__c=3, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c brand = new zpl__LineLevel__c(zpl__LineLevelId__c = 'Brand', zpl__Position__c=4, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c classLevel = new zpl__LineLevel__c(zpl__LineLevelId__c = 'Class', zpl__Position__c=5, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c brandVendor = new zpl__LineLevel__c(zpl__LineLevelId__c = 'BrandVendor', zpl__Position__c=6, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        zpl__LineLevel__c classVendor = new zpl__LineLevel__c(zpl__LineLevelId__c = 'ClassVendor', zpl__Position__c=7, zpl__ProductSelectorConfiguration__c = testPSconfig.Id);
        List<zpl__LineLevel__c> levels = new List<zpl__LineLevel__c>{item,subSet,setLevel,brand,classLevel,brandVendor,classVendor};
        upsert levels;






        zpl__ProductUOM__c uomA = new zpl__ProductUOM__c(zpl__ProductUOMId__c = 'SW0100000001SH', zpl__ConversionFactor__c=1, Name='SH', zpl__Product__c = prdct.Id);
        zpl__ProductUOM__c uomB = new zpl__ProductUOM__c(zpl__ProductUOMId__c = 'SW0100000001M', zpl__ConversionFactor__c=1, Name='M', zpl__Product__c = prdct.Id);
        List<zpl__ProductUOM__c> uoms = new List<zpl__ProductUOM__c>{uomA, uomB};
        upsert uoms;
        system.debug('RODNEY DEBUG USERS@@@ ' + [SELECT Id, Name, LastName, managerid, manager.managerid, Email FROM User ] );
        
        zpl__ContractLineItem__c draftAgrmntLine = new zpl__ContractLineItem__c(Name='testDraftLine'
                , zpl__ContractLineItemId__c = 'testExternalId1'
                , zpl__Contract__c = agmnt.id
                , zpl__Status__c = 'Draft'
                , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId()
                , zpl__EffectiveDate__c=null
                , zpl__Initiative__c = null
                , zpl__Product__c = prdct.id
                , PublishedScore__c = 0
                , Approved_By__c = null
                , Approved_Date__c = null
                //, Published_By__c = UserInfo.getUserId()
                , Published_By__c = UserSysAd.id != null ? UserSysAd.id : UserInfo.getUserId()
                , Publish_Date__c = DateTime.now()
                , Rejected_By__c = null
                , Rejected_Date__c = null
                , Inactivated_By__c = null
                , Inactivated_Date__c = null
                , SKU__c='00000001'
                , System__c='SW'
                , zpl__PolicyValue__c=0.25
                , Class__c='01'
                , Brand__c='0101'
                , Set__c='0001'
                , Subset__c='0001'
                , zpl__PolicyType__c = fixedPriceType.id
                , zpl__UOM__c = uomA.id
                , Segment__c = 'PR'
                , Division_Code2__c = '01'
                , VendorCode__c = '01'
                , isCurrent__c = True
                , SupersededDate__c = null
                , ExternalCostDeviationDate__c = Date.today()
                , DisallowCampaignsThroughDate__c = Date.today()
        );

        zpl__ContractLineItem__c draftCampAgrmntLine = new zpl__ContractLineItem__c(Name='testDraftCampLine'
                , zpl__ContractLineItemId__c = 'testExternalId2'
                , zpl__Contract__c = agmnt.id
                , zpl__Status__c = 'Draft'
                , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId()
                , zpl__EffectiveDate__c=date.today()
                , zpl__Initiative__c = camp.Id
                , zpl__Product__c = prdct.id
                , PublishedScore__c = 0
                , Approved_By__c = null
                , Approved_Date__c = null
                , Published_By__c = UserSysAd.id
                //, Published_By__c = UserInfo.getUserId()
                , Publish_Date__c = DateTime.now()
                , Rejected_By__c = null
                , Rejected_Date__c = null
                , Inactivated_By__c = null
                , Inactivated_Date__c = null
                , SKU__c='00000001'
                , System__c='SW'
                , zpl__PolicyValue__c=0.25
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
                , Start_Price__c = 120.00
        );

        zpl__ContractLineItem__c activeAgrmntLine = new zpl__ContractLineItem__c(Name='testActiveLine'
                , zpl__ContractLineItemId__c = 'testExternalId3'
                , zpl__Contract__c = agmnt.id
                , zpl__Status__c = 'Published'
                , RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId()
                , zpl__EffectiveDate__c=date.today()-1
                , zpl__Initiative__c = null
                , zpl__Product__c = prdct.id
                , PublishedScore__c = 0
                , Approved_By__c = UserInfo.getUserId()
                , Approved_Date__c = DateTime.now()
                , Published_By__c = UserSysAd.id
                //, Published_By__c = UserInfo.getUserId()
                , Publish_Date__c = DateTime.now()
                , Rejected_By__c = null
                , Rejected_Date__c = null
                , Inactivated_By__c = null
                , Inactivated_Date__c = null
                , SKU__c='00000001'
                , System__c='SW'
                , zpl__PolicyValue__c=0.25
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
                , Start_Price__c = 120.00
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
                , Published_By__c = UserSysAd.id
                , Approved_By__c = UserInfo.getUserId()
                , Approved_Date__c = DateTime.now()
                //, Published_By__c = UserInfo.getUserId()
                , Publish_Date__c = DateTime.now()
                , Rejected_By__c = null
                , Rejected_Date__c = null
                , Inactivated_By__c = null
                , Inactivated_Date__c = null
                , SKU__c='00000001'
                , System__c='SW'
                , zpl__PolicyValue__c=0.25
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
                , Published_By__c = UserSysAd.id
                //, Published_By__c = UserInfo.getUserId()
                , Publish_Date__c = DateTime.now()
                , Rejected_By__c = null
                , Rejected_Date__c = null
                , Inactivated_By__c = UserInfo.getUserId()
                , Inactivated_Date__c = DateTime.now()
                , SKU__c='00000001'
                , System__c='SW'
                , zpl__PolicyValue__c=0.25
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
                , Net_Price__c = 100.00
                , Start_Price__c = 120.00
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
                , Published_By__c = UserSysAd.id
                //, Published_By__c = UserInfo.getUserId()
                , Publish_Date__c = DateTime.now()
                , Rejected_By__c = null
                , Rejected_Date__c = null
                , Inactivated_By__c = null
                , Inactivated_Date__c = null
                , SKU__c='00000001'
                , System__c='SW'
                , zpl__PolicyValue__c=0.25
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
                , Start_Price__c = 120.00
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
                , Published_By__c = UserSysAd.id
                //, Published_By__c = UserInfo.getUserId()
                , Publish_Date__c = DateTime.now()
                , Rejected_By__c = null
                , Rejected_Date__c = null
                , Inactivated_By__c = null
                , Inactivated_Date__c = null
                , SKU__c='00000002'
                , System__c='SW'
                , zpl__PolicyValue__c=0.25
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
                , Start_Price__c = 120.00
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
                , Published_By__c = UserSysAd.id
                //, Published_By__c = UserInfo.getUserId()
                , Publish_Date__c = DateTime.now()
                , Rejected_By__c = null
                , Rejected_Date__c = null
                , Inactivated_By__c = null
                , Inactivated_Date__c = null
                , SKU__c='00000001'
                , System__c='SW'
                , zpl__PolicyValue__c=0.25
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
                , Start_Price__c = 120.00
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
                , Published_By__c = UserSysAd.id
                //, Published_By__c = UserInfo.getUserId()
                , Publish_Date__c = DateTime.now()
                , Rejected_By__c = null
                , Rejected_Date__c = null
                , Inactivated_By__c = null
                , Inactivated_Date__c = null
                , SKU__c='00000001'
                , System__c='SW'
                , zpl__PolicyValue__c=0.25
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
                , Start_Price__c = 120.00
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
                , Published_By__c = UserSysAd.id
                //, Published_By__c = UserInfo.getUserId()
                , Publish_Date__c = DateTime.now()
                , Rejected_By__c = null
                , Rejected_Date__c = null
                , Inactivated_By__c = null
                , Inactivated_Date__c = null
                , SKU__c='00000002'
                , System__c='SW'
                , zpl__PolicyValue__c=0.25
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
                , Start_Price__c = 120.00
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
                , Published_By__c = UserSysAd.id
                //, Published_By__c = UserInfo.getUserId()
                , Publish_Date__c = DateTime.now()
                , Rejected_By__c = null
                , Rejected_Date__c = null
                , Inactivated_By__c = UserInfo.getUserId()
                , Inactivated_Date__c = DateTime.now()
                , SKU__c='00000001'
                , System__c='SW'
                , zpl__PolicyValue__c=0.25
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
                , Net_Price__c = 10.00
                , Start_Price__c = 120.00
        );

        List<zpl__ContractLineItem__c> agrmntLines = new List<zpl__ContractLineItem__c>{draftAgrmntLine, draftCampAgrmntLine, activeAgrmntLine, activeCampAgrmntLine, inactiveAgrmntLine, pendApprAgrmntLine, activeFutureAgrmntLine, activeDuplicateAgrmntLine, chainAgrmntLineA, chainAgrmntLineB, purgeAgrmntLine};
        upsert agrmntLines;

        zpl__IQAnywhereConfiguration__c iqAnywhere = new zpl__IQAnywhereConfiguration__c(Name = 'f_getAPIContractLineData', zpl__ErrorFieldName__c = 'zpl__Error__c', zpl__SourceObject__c = 'zpl__ContractLineItem__c');
        upsert iqAnywhere;
        system.debug('RODNEY DEBUG zpl__ContractLineItem__c@@@ ' + [SELECT Id, Name, Published_By__c  FROM zpl__ContractLineItem__c] );
        }
    }


}
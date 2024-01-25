@isTest
public class calcDurationsCLIAtest {

    @isTest
    
    
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
        );
        upsert customConfig;

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

        List<User> usrs = new List<User>{usrPsr, usr, usr2};
        insert usrs;
        

        Servicing_Division__c div = new Servicing_Division__c(name='TestDiv', Division_Code__c = '01');
        upsert div;

        Account acct = new Account(Name='ZilliantTestAcct', OwnerId = usrPsr.id, Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='AI', zpl__CustomerId__c = 'SW000001', AccountNumber='000001', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, Natl_Acct_Group_ID__c='testNA', Regional_Acct_Group_ID__c = 'testCA', Chain_Account_Code__c = '000003', BillingStateInitial__c='01');
        Account acctWoContract = new Account(Name='ZilliantTestAcctWoContract', OwnerId = usrPsr.id, Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='AI', zpl__CustomerId__c = 'SW000002', AccountNumber='000002', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, BillingStateInitial__c='01');
        Account cAcct = new Account(Name='ZilliantTestChainAcct', Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='AI', zpl__CustomerId__c = 'SW000003', AccountNumber='000003', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, Regional_Acct_Group_ID__c = 'testCA'
                , RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Chain_Account').getRecordTypeId()
                , BillingStateInitial__c='01');
        Account acctInactive = new Account(Name='ZilliantTestInactiveAcct', Active__c='Yes', Suspect__c='2. Prospect', Zilliant_Active__c='Y', zpl__CustomerId__c = 'SW000004', AccountNumber='000004', Legacy_System_Cd__c='03', Legacy_Division_Cd__c='01', Servicing_Division__c=div.Id, BillingStateInitial__c='01');
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
        );

        List<zpl__ContractLineItem__c> agrmntLines = new List<zpl__ContractLineItem__c>{draftAgrmntLine, draftCampAgrmntLine, activeAgrmntLine, activeCampAgrmntLine, inactiveAgrmntLine, pendApprAgrmntLine, activeFutureAgrmntLine, activeDuplicateAgrmntLine, chainAgrmntLineA, chainAgrmntLineB, purgeAgrmntLine};
        upsert agrmntLines;

        zpl__IQAnywhereConfiguration__c iqAnywhere = new zpl__IQAnywhereConfiguration__c(Name = 'f_getAPIContractLineData', zpl__ErrorFieldName__c = 'zpl__Error__c', zpl__SourceObject__c = 'zpl__ContractLineItem__c');
        upsert iqAnywhere;

        Contract_Line_Item_Approval__c cliApp = new Contract_Line_Item_Approval__c();
        cliApp.Contract_Line_Item__c = agrmntLines[0].id;
        insert cliApp;
        
        update cliApp;
        
       CLIA_Durations__c cliDur = new CLIA_Durations__c();
        cliDur.Parent__c = cliApp.id;
        insert cliDur;
        
        
    }
    
    @isTest()
    public static void testCalcDurations(){
        calcDurationsCLIAtest.setConfig();
       
        
    }
}
@IsTest
private class AIQ_AgreementLineItemTriggerHandlerTest {
    private static final String CONTRACT_RT_PRICING_ID = Schema.SObjectType.Contract
            .getRecordTypeInfosByDeveloperName()
            .get('PricingContract')
            .getRecordTypeId();
    private static final String CLI_RT_DRAFT_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName()
            .get('Draft')
            .getRecordTypeId();
    private static final String CLI_RT_ACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName()
            .get('Active')
            .getRecordTypeId();
    private static final String CLI_RT_INACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName()
            .get('Inactive')
            .getRecordTypeId();
    private static final String CLI_STATUS_DRAFT = 'Draft';
    private static final String CLI_STATUS_PUBLISHED = 'Published';
    private static final String CBSSI_GROUPING_KEY = 'SW000001 (Item):0000001';
    private static zpl__ProductSelectorConfiguration__c productSelectorConfig;
    private static List<Account> accounts;
    private static List<Servicing_Division__c> divisions;
    private static List<Contract> contracts;
    private static zpl__LineLevel__c lineLevelItem;
    private static zpl__LineLevel__c lineLevelClass;
    private static zpl__LineLevel__c lineLevelSet;
    private static zpl__PolicyType__c policyType;
    private static zpl__PolicyType__c policyType2;
    private static zpl__PolicyType__c policyType3;
    private static zpl__PolicyType__c policyType4;
    private static zpl__PolicyType__c policyType5;
    private static zpl__ProductUOM__c uom;
    private static List<AIQ_CWTItem__c> cwtItems;
    private static List<Product2> products;
    private static List<zpl__ContractLineItem__c> contractLinesDraft;
    private static List<zpl__ContractLineItem__c> contractLinesDraftSet;
    private static List<zpl__ContractLineItem__c> contractLinesActive;
    private static List<zpl__ContractLineItem__c> contractLinesInactive;
    private static List<zpl__ContractLineItem__c> contractLinesDraftCampaign;
    private static List<zpl__ContractLineItem__c> contractLinesActiveCampaign;

    static {
        AIQ_TestDataFactory.initializeZilliantConfiguration();
        AIQ_TestDataFactory.initializeIQAnywhereConfig(null, true);
        productSelectorConfig = AIQ_TestDataFactory.initializeProductSelectorConfiguration(null, true);
        accounts = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'Test Account',
                        Active__c = 'Yes',
                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                .get('Customer')
                                .getRecordTypeId(),
                        Natl_Acct_Group_ID__c = 'testNA'
                ),
                1,
                true
        );
        divisions = AIQ_TestDataFactory.initializeDivisions(
                new Servicing_Division__c(
                        Name = 'TestDiv2',
                        Division_Code__c = '70',
                        Division_Composite_Key__c = '0370'
                ),
                1,
                true
        );
        contracts = AIQ_TestDataFactory.initializeContracts(
                new Contract(
                        Name = 'TestContract',
                        RecordTypeId = CONTRACT_RT_PRICING_ID,
                        AccountId = accounts[0].Id,
                        Division__c = divisions[0].Id
                ),
                1,
                true
        );
        lineLevelItem = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'Item',
                        Name = 'Item',
                        zpl__Position__c = 1,
                        zpl__ProductSelectorConfiguration__r = productSelectorConfig
                ),
                true
        );
        lineLevelSet = AIQ_TestDataFactory.initializeLineLevel(
            new zpl__LineLevel__c(
                    zpl__LineLevelId__c = 'Set',
                    Name = 'Set',
                    zpl__Position__c = 2,
                    zpl__ProductSelectorConfiguration__r = productSelectorConfig
            ),
            true
        );
        lineLevelClass = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'Class',
                        Name = 'Class',
                        zpl__Position__c = 3,
                        zpl__ProductSelectorConfiguration__r = productSelectorConfig
                ),
                true
        );
        cwtItems = AIQ_TestDataFactory.initializeCWTItems(
            new AIQ_CWTItem__c(
                Name ='MA0000000007',
                CBSSKey__c = 'SW010101010001'
            ),
            1,
            true
        );
        policyType = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'fixedPrice'
                ),
                true
        );
        policyType2 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'nationalAccount'
                ),
                true
        );
        policyType3 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'cwtFixed'
                ),
                true
        );
        policyType4 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'listDown'
                ),
                true
        );
        policyType5 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'maintainGTM'
                ),
                true
        );
        products = AIQ_TestDataFactory.initializeProduct2s(null, 1, true);
        uom = AIQ_TestDataFactory.initializeProductUOM(
                new zpl__ProductUOM__c(
                        Name = 'M',
                        zpl__ConversionFactor__c = 1,
                        zpl__Product__c = products[0].Id,
                        zpl__Product__r = products[0]
                ),
                true
        );
        contractLinesDraft = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Contract Line Draft',
                        zpl__Contract__r = contracts[0],
                        zpl__Status__c = CLI_STATUS_DRAFT,
                        RecordTypeId = CLI_RT_DRAFT_ID,
                        zpl__EffectiveDate__c = System.today(),
                        CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
                        zpl__PolicyType__c = policyType.Id,
                        zpl__PolicyType__r = policyType,
                        zpl__UOM__r = uom,
                        zpl__Product__c = products[0].Id,
                        zpl__Product__r = products[0],
                        zpl__LineLevel__c = lineLevelClass.Id,
                        zpl__LineLevel__r = lineLevelClass,
                        SKU__c = '00000001',
                        zpl__UOM__c = uom.Id
                ),
                1,
                true,
                false
        );
        contractLinesDraftSet = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                    Name = '2Contract Line Draft set',
                    zpl__Contract__r = contracts[0],
                    zpl__Status__c = CLI_STATUS_DRAFT,
                    RecordTypeId = CLI_RT_DRAFT_ID,
                    CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
                    zpl__PolicyType__c = policyType.Id,
                    zpl__PolicyType__r = policyType,
                    zpl__UOM__c = uom.Id,
                    zpl__Product__c = products[0].Id,
                    zpl__Product__r = products[0],
                    zpl__LineLevel__c = lineLevelSet.Id,
                    zpl__LineLevel__r = lineLevelSet,
                    SKU__c = '00000001',
                    System__c = 'SW',
                    Division_Code2__c = '01',
                    Class__c = '01',
                    Brand__c = '0101',
                    Set__c = '0001',
                    LineSource__c = 'U'
            ),
            1,
            true,
            false
        );
        contractLinesActive = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Contract Line Active',
                        zpl__Status__c = CLI_STATUS_PUBLISHED,
                        zpl__Contract__r = contracts[0],
                        RecordTypeId = CLI_RT_ACTIVE_ID,
                        LineSource__c = 'U',
                        CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
                        zpl__EffectiveDate__c = System.today().addDays(-1),
                        zpl__PolicyType__c = policyType.Id,
                        zpl__PolicyType__r = policyType,
                        zpl__UOM__r = uom,
                        zpl__Product__c = products[0].Id,
                        zpl__Product__r = products[0],
                        zpl__LineLevel__c = lineLevelItem.Id,
                        zpl__LineLevel__r = lineLevelItem,
                        Approved_By__c = UserInfo.getUserId(),
                        Approved_Date__c = System.today(),
                        Published_By__c = UserInfo.getUserId(),
                        Publish_Date__c = System.today(),
                        Reason_Code__c = 'J - New Item',
                        SKU__c = '00000001'
                ),
                1,
                true,
                false
        ));
        contractLinesInactive = (AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                    Name = 'Contract Line Active',
                    zpl__Status__c = CLI_STATUS_PUBLISHED,
                    zpl__Contract__r = contracts[0],
                    RecordTypeId = CLI_RT_INACTIVE_ID,
                    LineSource__c = 'U',
                    CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
                    zpl__EffectiveDate__c = System.today().addDays(-1),
                    zpl__PolicyType__c = policyType.Id,
                    zpl__PolicyType__r = policyType,
                    zpl__UOM__r = uom,
                    zpl__Product__c = products[0].Id,
                    zpl__Product__r = products[0],
                    zpl__LineLevel__c = lineLevelItem.Id,
                    zpl__LineLevel__r = lineLevelItem,
                    Approved_By__c = UserInfo.getUserId(),
                    Approved_Date__c = System.today(),
                    Published_By__c = UserInfo.getUserId(),
                    Publish_Date__c = System.today(),
                    Reason_Code__c = 'J - New Item',
                    SKU__c = '00000001',
                    CampaignAppealedLine__c = contractLinesActive[0].Id
            ),
            1,
            true,
            false
        ));
        contractLinesActiveCampaign = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Contract Line Active Camp',
                        zpl__Status__c = CLI_STATUS_PUBLISHED,
                        zpl__Contract__c = contracts[0].Id,
                        RecordTypeId = CLI_RT_ACTIVE_ID,
                        LineSource__c = 'C',
                        CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
                        zpl__EffectiveDate__c = System.today().addDays(-11),
                        zpl__PolicyType__c = policyType.Id,
                        zpl__PolicyType__r = policyType,
                        zpl__UOM__r = uom,
                        zpl__Product__c = products[0].Id,
                        zpl__Product__r = products[0],
                        zpl__LineLevel__c = lineLevelItem.Id,
                        zpl__LineLevel__r = lineLevelItem,
                        isCurrent__c = false,
                        Approved_Date__c = System.today().addDays(-1),
                        Publish_Date__c = System.today().addDays(-1),
                        InitiativeActionId__c = 1000,
                        DisallowCampaignsThroughDate__c = System.today(),
                        SKU__c = '00000001'
                ),
                1,
                true,
                false
        ));
        contractLinesDraftCampaign = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Contract Line Draft Camp',
                        zpl__Status__c = CLI_STATUS_DRAFT,
                        zpl__Contract__c = contracts[0].Id,
                        zpl__Contract__r = contracts[0],
                        RecordTypeId = CLI_RT_DRAFT_ID,
                        CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
                        LineSource__c = 'U',
                        zpl__EffectiveDate__c = System.today().addDays(1),
                        zpl__PolicyType__c = policyType.Id,
                        zpl__PolicyType__r = policyType,
                        zpl__UOM__r = uom,
                        zpl__Product__c = products[0].Id,
                        zpl__Product__r = products[0],
                        zpl__LineLevel__c = lineLevelItem.Id,
                        zpl__LineLevel__r = lineLevelItem,
                        CampaignAppealedLine__c = contractLinesActiveCampaign[0].Id,
                        CampaignAppealedLine__r = contractLinesActiveCampaign[0],
                        IsCampaignAppealed__c = true,
                        SKU__c = '00000001',
                        System__c = 'SW'
                ),
                1,
                true,
                false
        ));
    }

    @IsTest
    private static void testSetDefaults() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.setAllLineLevelsMap();
            handler.setDefaults(contractLinesDraft);
        Test.stopTest();
        Assert.areEqual(null, contractLinesDraft[0].OrderQtyUOM__c, 'Should be equal to null by default');
    }

    @IsTest
    private static void testsSyncRecordType() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        List<zpl__ContractLineItem__c> contractLineItems = contractLinesDraft;
        Test.startTest();
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = 'Pend Appr';
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = 'Pend Publ';
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = 'Published';
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = 'Pend Cancel';
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = 'Deleted';
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = 'Cancelled Camp';
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = 'NA Conflict';
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = 'Deleted Camp';
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = 'Deleted By Quote';
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = 'User Vacated';
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = 'Camp Vacated';
                handler.syncRecordType(contractLineItems);
            contractLineItems[0].zpl__Status__c = null;
                handler.syncRecordType(contractLineItems);
        Test.stopTest();
        Assert.areEqual('Draft', contractLinesDraft[0].zpl__Status__c, 'Should be equal to Draft');
    }

    @IsTest
    private static void testSetRepresentativeProduct() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.setAllLineLevelsMap();
            handler.setRepresentativeProduct(contractLinesDraftSet);
        Test.stopTest();
        Assert.areEqual(true, contractLinesDraftSet[0].zpl__Product__c == null, 'Should not be equal to null');
    }

    @IsTest
    private static void testUpdateUOMs() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.setAllLineLevelsMap();
            handler.setAllPolicyTypeMap();
            handler.updateUOMs(contractLinesDraft);
        Test.stopTest();
        Assert.areNotEqual(null, contractLinesDraft, 'Should not be equal to null');
    }

    @IsTest
    private static void testSetNationalAccountPolicyType() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.setAllLineLevelsMap();
            handler.setAllPolicyTypeMap();
            handler.setNationalAccountPolicyType(contractLinesDraftCampaign);
        Test.stopTest();
        Assert.areNotEqual(null, contractLinesDraftCampaign, 'Should not be equal to null');
    }

    @IsTest
    private static void testAlignLineGroupBeforePublish() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.setAllLineLevelsMap();
            handler.setAllPolicyTypeMap();
            handler.alignLineGroupBeforePublish(contractLinesDraft);
        Test.stopTest();
        Assert.areNotEqual(null, contractLinesDraft, 'Should not be equal to null');
    }

    @IsTest
    private static void testAlignLineGroupBeforePublishCase2() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.setAllLineLevelsMap();
            handler.setAllPolicyTypeMap();
            handler.alignLineGroupBeforePublish(contractLinesActive, new Map<Id, zpl__ContractLineItem__c>(contractLinesDraft));
        Test.stopTest();
        Assert.areNotEqual(null, contractLinesActive, 'Should not be equal to null');
    }

    @IsTest
    private static void testAlignLineGroupAfterPublish() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.setAllLineLevelsMap();
            handler.setAllPolicyTypeMap();
            handler.alignLineGroupAfterPublish(contractLinesActive, new Map<Id, zpl__ContractLineItem__c>(contractLinesDraft));
        Test.stopTest();
        Assert.areNotEqual(null, contractLinesActive, 'Should not be equal to null');
    }

    @IsTest
    private static void testAlignLineGroupAfterPublishCase2() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.setAllLineLevelsMap();
            handler.setAllPolicyTypeMap();
            handler.alignLineGroupAfterPublish(contractLinesActive);
        Test.stopTest();
        Assert.areNotEqual(null, contractLinesActive, 'Should not be equal to null');
    }

    @IsTest
    private static void testAlineLineGroupPostApproval() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.setAllLineLevelsMap();
            handler.setAllPolicyTypeMap();
        Test.stopTest();
        Assert.areNotEqual(null, contractLinesActive, 'Should not be equal to null');
    }

    @IsTest
    private static void testRequireReason() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.setAllLineLevelsMap();
            handler.setAllPolicyTypeMap();
            handler.requireReason(
                    new Map<Id, zpl__ContractLineItem__c>(contractLinesDraftCampaign),
                    new Map<Id, zpl__ContractLineItem__c>(contractLinesDraftCampaign)
            );
        Test.stopTest();
        Assert.areNotEqual(null, contractLinesDraftCampaign, 'Should not be equal to null');
    }

    @IsTest
    private static void testRunSyncDown() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.runSyncDown();
        Test.stopTest();
        Assert.areNotEqual(null, handler, 'Should not be equal to null');
    }

    @IsTest
    private static void testDeleteDraftLines() {
        AIQ_AgreementLineItemTriggerHandler handler = mockDependencies();
        Test.startTest();
            handler.setAllLineLevelsMap();
            handler.setAllPolicyTypeMap();
            handler.deleteDraftLines(
                    new Map<Id, zpl__ContractLineItem__c>{contractLinesInactive[0].Id => contractLinesInactive[0]},
                    new Map<Id, zpl__ContractLineItem__c>{contractLinesInactive[0].Id => contractLinesDraftCampaign[0]}
            );
        Test.stopTest();
        Assert.areNotEqual(null, contractLinesInactive, 'Should not be equal to null');
    }

    private static AIQ_AgreementLineItemTriggerHandler mockDependencies() {
        AIQ_AgreementLineItemTriggerHandler handler = new AIQ_AgreementLineItemTriggerHandler();
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQ_ContractLineSelector lineSelector = (AIQ_ContractLineSelector) mocks.mock(AIQ_ContractLineSelector.class);
        AIQ_GenericSelector genericSelector = (AIQ_GenericSelector) mocks.mock(AIQ_GenericSelector.class);
        AIQco_DatabaseUtil databaseUtil = (AIQco_DatabaseUtil) mocks.mock(AIQco_DatabaseUtil.class);

        mocks.startStubbing();
        mocks.when(lineSelector.queryContractLinesById(new Set<Id>())).thenReturnForAny(contractLinesActive);
        mocks.when(lineSelector.queryContractLinesById(new List<Id>())).thenReturnForAny(contractLinesActive);
        mocks.when(lineSelector.queryContractLinesById(new List<String>(), new List<Id>())).thenReturnForAny(contractLinesDraftCampaign);
        mocks.when(lineSelector.queryContractLinesByCondition(new List<String>(), new zal.AndCondition())).thenReturnForAny(contractLinesDraft);

        mocks.when(genericSelector.queryAllLineLevels()).thenReturnForAny(new List <zpl__LineLevel__c>{lineLevelItem, lineLevelClass, lineLevelSet});
        mocks.when(genericSelector.queryAllPolicyType()).thenReturnForAny(new List <zpl__PolicyType__c>{policyType, policyType2, policyType3, policyType4, policyType5});
        mocks.when(genericSelector.queryUOMMapByCondition(new List<String>(), new zal.OrCondition())).thenReturnForAny(new Map<Id, zpl__ProductUOM__c>{uom.Id => uom});
        mocks.when(genericSelector.queryCWTItemByCBSSIKey(new List<String>(), new Set<String>())).thenReturnForAny(cwtItems);
        mocks.when(genericSelector.queryPolicyTypeByIds(new Set<Id>())).thenReturnForAny(new List <zpl__PolicyType__c>{policyType, policyType2, policyType3, policyType4, policyType5});
        mocks.when(genericSelector.queryUOMByIds(new Set<Id>())).thenReturnForAny(new List<zpl__ProductUOM__c>{uom});

        mocks.when(databaseUtil.updateRecords(contractLinesDraft)).thenReturnForAny(contractLinesDraft);
        mocks.when(databaseUtil.deleteRecords(contractLinesActive)).thenReturnForAny(contractLinesActive);
        mocks.stopStubbing();

        handler.genericSelector = genericSelector;
        handler.contractLineSelector = lineSelector;
        handler.databaseUtil = databaseUtil;

        return handler;
    }
}
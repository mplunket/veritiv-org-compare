@IsTest
private class AIQ_AgreementLineManipulatorTest {
        private static final String ACCOUNT_RT_PROSPECT_ID = Schema.SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('Prospect')
        .getRecordTypeId();
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
    private static final String CLI_STATUS_DRAFT = 'Draft';
    private static final String CLI_STATUS_PUBLISHED = 'Published';
    private static final String CBSSI_GROUPING_KEY = 'SW000001 (Item):0000001';
    private static zpl__ProductSelectorConfiguration__c productSelectorConfig;
    private static List<Servicing_Division__c> divisions;
    private static List<Account> accounts;
    private static List<Ship_To__c> shipTos;
    private static List<Contract> contracts;
    private static zpl__LineLevel__c lineLevelItem;
    private static zpl__PolicyType__c policyType;
    private static zpl__ProductUOM__c uom;
    private static List<Product2> products;
    private static List<zpl__ContractLineItem__c> contractLinesActive;
    private static List<zpl__ContractLineItem__c> contractLinesActiveCampaign;

    static {
        AIQ_TestDataFactory.initializeZilliantConfiguration();
        AIQ_TestDataFactory.initializeIQAnywhereConfig(null, false);
        productSelectorConfig = AIQ_TestDataFactory.initializeProductSelectorConfiguration(null, false);
        divisions = AIQ_TestDataFactory.initializeDivisions(
                new Servicing_Division__c(
                        Name = 'TestDiv2',
                        Division_Code__c = '70',
                        Division_Composite_Key__c = '0370'
                ),
                1,
                false
        );
        accounts = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'Test Account',
                        Active__c = 'Yes',
                        Suspect__c = '2. Prospect',
                        Zilliant_Active__c = 'AI',
                        RecordTypeId = ACCOUNT_RT_PROSPECT_ID,
                        OwnerId = UserInfo.getUserId(),
                        Servicing_Division__c = divisions[0].Id
                ),
                1,
                false
        );
        shipTos = AIQ_TestDataFactory.initializeShipTo(
                new Ship_To__c(
                        Name = 'Test Ship',
                        Bill_To_Account__c = accounts[0].Id,
                        Account_Owner__c = accounts[0].OwnerId
                ),
                1,
                false
        );
        contracts = AIQ_TestDataFactory.initializeContracts(
                new Contract(
                        Name = 'TestContract',
                        RecordTypeId = CONTRACT_RT_PRICING_ID,
                        AccountId = accounts[0].Id,
                        Division__c = divisions[0].Id,
                        OwnerId = UserInfo.getUserId()
                ),
                1,
                false
        );
        lineLevelItem = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'Item',
                        Name = 'Item',
                        zpl__Position__c = 1,
                        zpl__ProductSelectorConfiguration__c = productSelectorConfig.Id
                ),
                false
        );
        policyType = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'fixedPrice'
                ),
                false
        );
        uom = AIQ_TestDataFactory.initializeProductUOM(
                new zpl__ProductUOM__c(
                        Name = 'M',
                        zpl__ConversionFactor__c = 1
                ),
                false
        );
        products = AIQ_TestDataFactory.initializeProduct2s(null, 1, false);
        contractLinesActive = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Contract Line Active',
                        zpl__Status__c = CLI_STATUS_PUBLISHED,
                        zpl__Contract__c = contracts[0].Id,
                        RecordTypeId = CLI_RT_ACTIVE_ID,
                        LineSource__c = 'U',
                        zpl__EffectiveDate__c = System.today().addDays(2),
                        zpl__PolicyType__c = policyType.Id,
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id,
                        zpl__LineLevel__c = lineLevelItem.Id
                ),
                1,
                false,
                false
        ));
        contractLinesActiveCampaign = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Contract Line Active Camp',
                        zpl__Status__c = CLI_STATUS_PUBLISHED,
                        zpl__Contract__c = contracts[0].Id,
                        RecordTypeId = CLI_RT_ACTIVE_ID,
                        LineSource__c = 'C',
                        zpl__EffectiveDate__c = System.today().addDays(-11),
                        zpl__PolicyType__c = policyType.Id,
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id,
                        zpl__LineLevel__c = lineLevelItem.Id,
                        isCurrent__c = false,
                        Approved_Date__c = System.today().addDays(-1),
                        Publish_Date__c = System.today().addDays(-1),
                        InitiativeActionId__c = 1000,
                        DisallowCampaignsThroughDate__c = System.today()
                ),
                1,
                false,
                false
        ));
    }
    @IsTest
    private static void testStripLine() {
        Test.startTest();
            AIQ_AgreementLineManipulator.stripAgreementLine(new List<zpl__ContractLineItem__c>{contractLinesActive[0]});
        Test.stopTest();
        Assert.areEqual('Draft', contractLinesActive[0].zpl__Status__c, 'The status should be equal to Draft');
    }

    @IsTest
    private static void testStripCampLine() {
        Test.startTest();
            AIQ_AgreementLineManipulator.stripAgreementLine(new List<zpl__ContractLineItem__c>{contractLinesActiveCampaign[0]});
        Test.stopTest();
        Assert.areEqual('Draft', contractLinesActiveCampaign[0].zpl__Status__c, 'The status should be equal to Draft');
    }
}
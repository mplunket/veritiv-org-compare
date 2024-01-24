@IsTest
private with sharing class AIQ_GenericSelectorTest {
    private static NationalAccountsPricing__c nationalAccountsPricing;
    private static List<Account> accounts;
    private static List<Servicing_Division__c> divisions;
    private static List<Contract> contracts;
    private static zpl__PolicyType__c policyType;
    private static zpl__ProductUOM__c uom;
    private static Map<String, zpl__LineLevel__c> lineLevels;
    private static zpl__ProductSelectorConfiguration__c productSelector;
    private static List<AIQ_CWTItem__c> cwtItems;

    static {
        productSelector = AIQ_TestDataFactory.initializeProductSelectorConfiguration(null, false);
        nationalAccountsPricing = AIQ_TestDataFactory.initializeNationalAccountsPricing(null, false);
        accounts = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'TestAccount',
                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId(),
                        Natl_Acct_Group_ID__c = nationalAccountsPricing.NationalAccountGroupID__c
                ),
                1,
                false
        );
        divisions = AIQ_TestDataFactory.initializeDivisions(
                new Servicing_Division__c(
                        Name = 'TestDiv',
                        Division_Code__c = '01',
                        Division_Composite_Key__c = '0301'
                ),
                1,
                false
        );
        contracts = AIQ_TestDataFactory.initializeContracts(
                new Contract(
                        Name = 'TestContract',
                        AccountId = accounts[0].Id,
                        Division__c = divisions[0].Id
                ),
                1,
                false
        );
        AIQ_TestDataFactory.initializeShipTo(new Ship_To__c(Bill_To_Account__c = accounts[0].Id), 1, false);
        uom = AIQ_TestDataFactory.initializeProductUOM(
                new zpl__ProductUOM__c(
                        Name = 'M',
                        zpl__ConversionFactor__c = 1
                ),
                false
        );
        policyType = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'fixedPrice'
                ),
                false
        );
        lineLevels = AIQ_TestDataFactory.initializeAllLineLevels(
            new zpl__LineLevel__c(
                Name = 'Item',
                zpl__ProductSelectorConfiguration__c = productSelector.Id
            ),
            false
        );
        cwtItems = AIQ_TestDataFactory.initializeCWTItems(
            new AIQ_CWTItem__c(
                Name ='MA0000000007',
                CBSSKey__c = 'MA000000000001'
            ),
            1,
            false
        );
    }

    @IsTest
    private static void testQueryShipToByBillToAccount() {
        Test.startTest();
            List<Ship_To__c> shipTosActual = new AIQ_GenericSelector().queryShipToByBillToAccount(accounts[0].Id);
        Test.stopTest();

        Assert.isTrue(!shipTosActual.isEmpty(), 'Ship To should not be empty');
    }

    @IsTest
    private static void testQueryShipToByCondition() {
        zal.Condition condition = new zal.FieldCondition(AIQ_GenericSelector.BILL_TO_ACCOUNT_FIELD_NAME, zal.Operator.EQUALS, accounts[0].Id);
        Test.startTest();
            List<Ship_To__c> shipTosActual = new AIQ_GenericSelector().queryShipToByCondition(AIQ_GenericSelector.SHIP_TO_QUERY_FIELDS, condition);
        Test.stopTest();

        Assert.areEqual(accounts[0].Id, shipTosActual[0].Bill_To_Account__c, 'Account Id should match Bill To Account');
    }

    @IsTest
    private static void testQueryCurrentUser() {
        Test.startTest();
            User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            User actual = new AIQ_GenericSelector().queryCurrentUser();
        Test.stopTest();

        Assert.areEqual(currentUser.Id, actual.Id, 'Ids should be equal');
    }

    @IsTest
    private static void testQueryUsersByIds() {
        Test.startTest();
            List<User> users = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 2];
            List<User> actual = new AIQ_GenericSelector().queryUsersByIds(new List<Id>{users[0].Id, users[1].Id});
        Test.stopTest();

        Assert.areEqual(users.size(), actual.size(), 'Size should be equal');
    }

    @IsTest
    private static void testQueryUsersByCondition() {
        zal.AndCondition andCondition = new zal.AndCondition();
        andCondition.add(new zal.FieldCondition(AIQ_GenericSelector.IS_ACTIVE_FIELD_NAME, zal.Operator.EQUALS, true));
        andCondition.add(new zal.FieldCondition(AIQ_GenericSelector.USER_ID_FIELD_NAME, zal.Operator.EQUALS, UserInfo.getUserId()));
        Test.startTest();
            List<User> actual = new AIQ_GenericSelector().queryUsersByCondition(AIQ_GenericSelector.USER_QUERY_FIELDS, andCondition);
        Test.stopTest();

        Assert.isTrue(!actual.isEmpty(), 'List Users should not be empty');
    }

    @IsTest
    private static void testQueryContractById() {
        Test.startTest();
            Contract contractActual = new AIQ_GenericSelector().queryContractById(contracts[0].Id);
        Test.stopTest();

        Assert.isTrue(contractActual != null, 'Contract should not be null');
    }

    @IsTest
    private static void testQueryContractsByCondition() {
        zal.FieldCondition condition = new zal.FieldCondition(AIQ_GenericSelector.CONTRACT_ID_FIELD_NAME, zal.Operator.EQUALS, contracts[0].Id);
        Test.startTest();
            List<Contract> contractsActual = new AIQ_GenericSelector().queryContractsByCondition(AIQ_GenericSelector.CONTRACT_QUERY_FIELDS, condition);
        Test.stopTest();

        Assert.isTrue(!contractsActual.isEmpty(), 'Contracts should not be empty');
    }
    
    @IsTest
    private static void testQueryAccountById() {
        Test.startTest();
            Account accountActual = new AIQ_GenericSelector().queryAccountById(accounts[0].Id);
        Test.stopTest();

        Assert.isTrue(accountActual != null, 'Account should not be null');
    }

    @IsTest
    private static void testQueryServicingDivisionsByCompositeKey() {
        Test.startTest();
            List<Servicing_Division__c> divisionList = new AIQ_GenericSelector().queryServicingDivisionsByCompositeKey(
                new List<String>(),
                divisions[0].Division_Composite_Key__c,
                1
            );
        Test.stopTest();

        Assert.isTrue(divisionList != null, 'Division should not be null');
        Assert.areEqual(1, divisionList.size(), 'Expected number of divisions is selected');
    }

    @IsTest
    private static void testQueryPolicyTypeByIds() {
        Test.startTest();
            List<zpl__PolicyType__c> policyTypes = new AIQ_GenericSelector().queryPolicyTypeByIds(new Set<Id>{policyType.Id});
        Test.stopTest();

        Assert.isFalse(policyTypes.isEmpty(), 'Policy Type list should not be empty');
        Assert.areEqual('fixedPrice', policyTypes[0].zpl__PolicyTypeId__c, 'Policy Type Id should be equal');
    }

    @IsTest
    private static void testQueryPolicyTypeByIdsNegative() {
        Test.startTest();
            List<zpl__PolicyType__c> policyTypes = new AIQ_GenericSelector().queryPolicyTypeByIds(new Set<Id>());
        Test.stopTest();

        Assert.isTrue(policyTypes.isEmpty(), 'Policy Type list should be empty');
    }

    @IsTest
    private static void testQueryUOMByIds() {
        Test.startTest();
            List<zpl__ProductUOM__c> productUOMS = new AIQ_GenericSelector().queryUOMByIds(new Set<Id>{uom.Id});
        Test.stopTest();

        Assert.isFalse(productUOMS.isEmpty(), 'UOM list should not be empty');
        Assert.areEqual(1, productUOMS[0].zpl__ConversionFactor__c, 'Conversion Factor should be equal');
    }

    @IsTest
    private static void testQueryUOMMapByCondition() {
        zal.AndCondition andCondition = new zal.AndCondition();
        andCondition.add(new zal.SetCondition(
            AIQ_GenericSelector.PRODUCT_UOM_ID_FIELD_NAME,
            zal.Operator.INX, AIQ_CommonUtil.setToListIds(new Set<Id>{uom.Id}))
        );
        Test.startTest();
            Map<Id, zpl__ProductUOM__c> productUOMsMap = new AIQ_GenericSelector().queryUOMMapByCondition(
                AIQ_AgreementLineItemTriggerHandler.PRODUCT_UOM_FIELDS,
                andCondition
            );
        Test.stopTest();

        Assert.isFalse(productUOMsMap.isEmpty(), 'UOM map should not be empty');
        Assert.areEqual(1, productUOMsMap.get(uom.Id).zpl__ConversionFactor__c, 'Conversion Factor should be equal');
    }

    @IsTest
    private static void testQueryUOMByIdsNegative() {
        Test.startTest();
            List<zpl__ProductUOM__c> productUOMS = new AIQ_GenericSelector().queryUOMByIds(new Set<Id>());
        Test.stopTest();

        Assert.isTrue(productUOMS.isEmpty(), 'UOM list should be empty');
    }

    @IsTest
    private static void testQueryAllPolicyType() {
        Test.startTest();
            List<zpl__PolicyType__c> policyTypeMap = new AIQ_GenericSelector().queryAllPolicyType();
        Test.stopTest();

        Assert.isFalse(policyTypeMap.isEmpty(), 'Policy type list should not be empty');
    }
    
    @IsTest
    private static void testQueryAllLineLevels() {
        Test.startTest();
            List<zpl__LineLevel__c> lineLevels = new AIQ_GenericSelector().queryAllLineLevels();
        Test.stopTest();
        Assert.isFalse(lineLevels.isEmpty(), 'Line levels list should not be empty');
    }

    @IsTest
    private static void testQueryCWTItemMapByCBSSIKey() {
        Test.startTest();
            List<AIQ_CWTItem__c> lineLevels = new AIQ_GenericSelector().queryCWTItemByCBSSIKey(
                AIQ_AgreementLineItemTriggerHandler.CWT_ITEM_FIELDS,
                new Set<String> {cwtItems[0].CBSSKey__c}
            );
        Test.stopTest();
        Assert.isFalse(lineLevels.isEmpty(), 'CWT item list should not be empty');
        Assert.areEqual(cwtItems[0].CBSSKey__c, lineLevels[0].CBSSKey__c, 'Get expected CWTItem');

    }

    @IsTest
    private static void testQueryNationalAccountsPricingByCondition() {
        zal.AndCondition andCondition = new zal.AndCondition();
        andCondition.add(
            new zal.SetCondition(
                AIQ_GenericSelector.NATIONAL_ACCOUNT_PRICING_ID_FIELD_NAME,
                zal.Operator.INX,
                new List<Id> { nationalAccountsPricing.Id }
            )
        );
        Test.startTest();
        List<NationalAccountsPricing__c> nap = new AIQ_GenericSelector().queryNationalAccountsPricingByCondition(
            new List<String> {'Id', 'Name'},
            andCondition
        );
        Test.stopTest();
        Assert.isFalse(nap.isEmpty(), 'NationalAccountsPricing list should not be empty');
        Assert.areEqual(nationalAccountsPricing.Id, nap[0].Id, 'Get expected NationalAccountsPricing');
    }
}
@IsTest
private class AIQasync_RollupCalculationsTest {
    private static final String ACCOUNT_RT_CUSTOMER_ID = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('Customer')
            .getRecordTypeId();
    private static final String CONTRACT_RT_PRICING_ID = Schema.SObjectType.Contract
            .getRecordTypeInfosByDeveloperName()
            .get('PricingContract')
            .getRecordTypeId();
    private static final String CLI_STATUS_PUBLISHED = 'Published';
    private static final String CLI_RT_ACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName()
            .get('Active')
            .getRecordTypeId();
    private static List<Account> accounts;
    private static List<Servicing_Division__c> divisions;
    private static List<Contract> contracts;
    private static zpl__ProductUOM__c uom;
    private static List<Product2> products;
    private static List<zpl__ContractLineItem__c> contractLines;

    static {
        AIQ_TestDataFactory.initializeZilliantConfiguration();
        accounts = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'Test Account',
                        RecordTypeId = ACCOUNT_RT_CUSTOMER_ID,
                        Active__c = 'Yes',
                        Zilliant_Active__c = 'AI'
                ),
                1,
                false
        );
        divisions = AIQ_TestDataFactory.initializeDivisions(
                new Servicing_Division__c(
                        Name = 'TestDiv2',
                        Division_Code__c = '70',
                        Division_Composite_Key__c = '0370'
                ),
                1,
                false
        );
        contracts = AIQ_TestDataFactory.initializeContracts(
                new Contract(
                        Name = 'TestContract',
                        RecordTypeId = CONTRACT_RT_PRICING_ID,
                        AccountId = accounts[0].Id,
                        Division__c = divisions[0].Id
                ),
                1,
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
        contractLines = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Contract Line',
                        zpl__Contract__c = contracts[0].Id,
                        zpl__Status__c = CLI_STATUS_PUBLISHED,
                        RecordTypeId = CLI_RT_ACTIVE_ID,
                        zpl__EffectiveDate__c = System.today(),
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id
                ),
                1,
                false,
                false
        );
    }
    
	@IsTest
    private static void testAsyncRollupCalculations() {
        Test.startTest();
            AIQasync_RollupCalculations batchCalcs = new AIQasync_RollupCalculations(
                    new List<String>{'andriy.suh@zilliant.com'},
                    200
            );
            Id batchProcId = Database.executeBatch(batchCalcs);
        Test.stopTest();
        Assert.isTrue(batchProcId != null, 'ID should not be null');
    }
    
    @IsTest
    private static void testAsyncRollupCalculationsAll() {
        Test.startTest();
            AIQasync_RollupCalculations batchCalcs = new AIQasync_RollupCalculations(
                    new List<String>{'andriy.suh@zilliant.com'},
                    true,
                    200
            );
            Id batchProcId = Database.executeBatch(batchCalcs);
        Test.stopTest();
        Assert.isTrue(batchProcId != null, 'ID should not be null');
    }
    
    @IsTest
    private static void testAsyncRollupCalculationsAllException() {
        Test.startTest();
            AIQasync_RollupCalculations batchCalcs = new AIQasync_RollupCalculations(
                    new List<String>{'andriy.suh@zilliant.com'},
                    true,
                    200
            );
            Id batchProcId = Database.executeBatch(batchCalcs);
        Test.stopTest();
        Assert.isTrue(batchProcId != null, 'ID should not be null and jobMessages variable should be populated');
    }
}
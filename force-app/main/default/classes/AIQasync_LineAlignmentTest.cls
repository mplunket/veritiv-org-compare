@IsTest
private class AIQasync_LineAlignmentTest {
    private static final String CLI_STATUS_PUBLISHED = 'Published';
    private static final String CLI_RT_ACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId();
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
                        Name = 'Test Account'
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
    private static void testAsyncLineAlignment() {
        Test.startTest();
            AIQasync_LineAlignment batchCalcs = new AIQasync_LineAlignment(
                    new List<String>{'andriy.suh@zilliant.com'},
                    200
            );
            Id batchProcId = Database.executeBatch(batchCalcs);
        Test.stopTest();
        Assert.isTrue(batchProcId != null, 'ID should not be null');
    }
    
    @IsTest
    private static void testAsyncLineAlignmentAll() {
        String scopeQuery = 'SELECT ' +'Id, ' + 'Name ' + 'FROM zpl__ContractLineItem__c ' + 'WHERE RecordType.Name in (\'Active\')';
        Test.startTest();
            AIQasync_LineAlignment batchCalcs = new AIQasync_LineAlignment(
                    new List<String>{'andriy.suh@zilliant.com'},
                    true,
                    scopeQuery,
                    200
            );
            Id batchProcId = Database.executeBatch(batchCalcs);
        Test.stopTest();
        Assert.isTrue(batchProcId != null, 'ID should not be null');
    }
    
    @IsTest
    private static void testLineAlignmentAllException() {
        Test.startTest();
            AIQasync_LineAlignment batchCalcs = new AIQasync_LineAlignment(
                    new List<String>{'andriy.suh@zilliant.com'},
                    true,
                    '',
                    200
            );
            Id batchProcId = Database.executeBatch(batchCalcs);
        Test.stopTest();
        Assert.isTrue(batchProcId != null, 'ID should not be null and jobMessages variable should be populated');
    }
}
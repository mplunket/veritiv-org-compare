@IsTest
private class AIQasync_FESBatchProcessorTest {
    private static final String CLI_STATUS_DRAFT = 'Draft';
    private static final String CLI_RT_DRAFT_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName()
            .get('Draft')
            .getRecordTypeId();
    private static List<Account> accounts;
    private static List<Servicing_Division__c> divisions;
    private static List<Contract> contracts;
    private static zpl__ProductUOM__c uom;
    private static List<Product2> products;
    private static List<zpl__ContractLineItem__c> contractLinesDraft;

    static {
        AIQ_TestDataFactory.initializeZilliantConfiguration();
        AIQ_TestDataFactory.initializeIQAnywhereConfig(null, false);
        accounts = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'Test Account',
                        Active__c = 'Yes'
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
        contractLinesDraft = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine1',
                        zpl__Contract__c = contracts[0].Id,
                        zpl__Status__c = CLI_STATUS_DRAFT,
                        RecordTypeId = CLI_RT_DRAFT_ID,
                        LineSource__c = 'U',
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id
                ),
                1,
                false,
                false
        );
    }

    @IsTest
    private static void testFESBatchProcessor() {
        Test.startTest();
            String queryStr = 'SELECT Id, zpl__LineLevel__c FROM zpl__ContractLineItem__c';
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQasync_FESBatchProcessor batchProcess = new AIQasync_FESBatchProcessor(
                    accounts[0],
                    'f_getAPIContractLineData',
                    zpl__ContractLineItem__c.getSObjectType(),
                    queryStr
            );
            ID batchProcId = Database.executeBatch(batchProcess);
        Test.stopTest();
        Assert.isTrue(batchProcId != null, 'ID should not be null');
    }

    @IsTest
    private static void testFESBatchProcessorNegative() {
        Test.startTest();
            String queryStr = 'SELECT Id, zpl__LineLevel__c FROM zpl__ContractLineItem__c';
            try {
                Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
                AIQasync_FESBatchProcessor batchProcess = new AIQasync_FESBatchProcessor(
                        new Account(),
                        'f_getAPIContractLineData',
                        zpl__ContractLineItem__c.getSObjectType(),
                        queryStr
                );
                ID batchProcId = Database.executeBatch(batchProcess);
            } catch(Exception e) {
                Assert.areNotEqual(null, e, 'Should not be equal to null');
            }
        Test.stopTest();
    }
}
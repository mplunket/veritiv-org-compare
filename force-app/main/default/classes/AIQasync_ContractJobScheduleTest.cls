@IsTest
private class AIQasync_ContractJobScheduleTest {
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
    private static void testContractJobScheduleOneTime() {
        Test.startTest();
            AIQasync_ContractJobSchedule.scheduleOneTimeJob();
            CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'AIQ Contract Line/Contract - One Time Job - test job'];
            Assert.areNotEqual(null, ct, 'Should not be equal to null');
        Test.stopTest();
    }

    @IsTest
    private static void testContractJobScheduleOneTimeScoped() {
        Test.startTest();
            String scopeQuery = 'SELECT Id, zpl__Contract__c, CBSSItemGroupingKey__c FROM zpl__ContractLineItem__c';
            AIQasync_ContractJobSchedule.scheduleOneTimeJob(scopeQuery);
            CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'AIQ Contract Line/Contract - One Time Job - test job'];
            Assert.areNotEqual(null, ct, 'Should not be equal to null');
        Test.stopTest();
    }
    
    @IsTest
    private static void testContractJobScheduleRecurring() {
        Test.startTest();
            AIQasync_ContractJobSchedule.scheduleRecurringJob('0 0 2 * * ? *');
            CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'AIQ Contract Line/Contract - Nightly Job - test job'];
            Assert.areNotEqual(null, ct, 'Should not be equal to null');
        Test.stopTest();
    }
}
@IsTest
private class AIQasync_AgrmntLinePurgeTest {
    private static List<Account> accounts;
    private static List<Contract> contracts;
    private static List<zpl__ContractLineItem__c> contractLines;
    private static List<Servicing_Division__c> divisions;
    private static AIQZilliantConfiguration__c configuration;
    private static zpl__ProductUOM__c productUOM;
    private static List<Product2> products;

    static {
        configuration = AIQ_TestDataFactory.initializeZilliantConfiguration(null, false);
        accounts = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'TestAccount',
                        Active__c = 'Yes'
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
        productUOM =  AIQ_TestDataFactory.initializeProductUOM(
            new zpl__ProductUOM__c(
                Name = 'M',
                zpl__ConversionFactor__c = 1
            ),
            false
        );
        products = AIQ_TestDataFactory.initializeProduct2s(
            new Product2(
                Name = 'Product ',
                System_id__c = '03',
                ProductCode = '00000001',
                isActive = true,
                Division_Code__c = '01',
                List_Price__c = 1.0,
                Pricing_Costing_UOM__c= 'SH',
                WMS_UOM__c = 'SH'
            ),
            1, 
            false
        );
        contracts = AIQ_TestDataFactory.initializeContracts(
            new Contract(
                Name = 'TestContract',
                AccountId = accounts[0].Id,
                Division__c = divisions[0].Id,
                zpl__ContractId__c = 'SWBT107495'
            ),
            1,
            false
        );
        contractLines = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                Name = 'TestContractLine',
                zpl__Contract__c = contracts[0].Id,
                isCurrent__c = true,
                zpl__UOM__c = productUOM.Id,
                zpl__Product__c = products[0].Id,
                SupersededDate__c = System.today(),
                zpl__EffectiveDate__c = System.today().addYears(-8),
                RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId()
            ),
            1,
            false
        );
    }

    @IsTest
    private static void testAIQAgrmntLinePurging() {
        Test.startTest();
            AIQasync_AgrmntLinePurgeSch.scheduleJob('0 0 2 * * ? *');
            CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'AIQ Contract Line Purging Job - test job'];
            Assert.areNotEqual(null, ct, 'Should not be equal to null');
        Test.stopTest();
    }
}
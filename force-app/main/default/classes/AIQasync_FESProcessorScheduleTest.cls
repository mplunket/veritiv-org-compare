@IsTest
private class AIQasync_FESProcessorScheduleTest {
    private static final String CLI_STATUS_PUBLISHED = 'Published';
    private static final String CLI_RT_ACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName()
            .get('Active')
            .getRecordTypeId();
    private static zpl__ProductSelectorConfiguration__c productSelectorConfig;
    private static List<Account> accounts;
    private static List<Servicing_Division__c> divisions;
    private static List<Contract> contracts;
    private static zpl__LineLevel__c lineLevelItem;
    private static zpl__ProductUOM__c uom;
    private static List<Product2> products;
    private static List<zpl__ContractLineItem__c> contractLinesDraft;

    static {
        AIQ_TestDataFactory.initializeZilliantConfiguration();
        AIQ_TestDataFactory.initializeIQAnywhereConfig(null, false);
        productSelectorConfig = AIQ_TestDataFactory.initializeProductSelectorConfiguration(null, false);
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
        lineLevelItem = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'Item',
                        Name = 'Item',
                        zpl__Position__c = 1,
                        zpl__ProductSelectorConfiguration__c = productSelectorConfig.Id
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
        contractLinesDraft = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine1',
                        zpl__Contract__c = contracts[0].Id,
                        zpl__Status__c = CLI_STATUS_PUBLISHED,
                        RecordTypeId = CLI_RT_ACTIVE_ID,
                        LineSource__c = 'U',
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id,
                        zpl__LineLevel__c = lineLevelItem.Id
                ),
                1,
                false,
                false
        );
    }
    
    @IsTest
    private static void testFESProcessorScheduleOneTime() {
        Test.startTest();
            AIQasync_FESProcessorSchedule.scheduleJob(soqlBuilder, whereAndConditions);
            CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'AIQ FES Processor - One Time Job - test job'];
        Test.stopTest();
        Assert.areNotEqual(null, ct, 'Should not be equal to null');
    }

    @IsTest
    private static void testFESProcessorScheduleRecurring() {
        Test.startTest();
            AIQasync_FESProcessorSchedule.scheduleJob('0 0 2 * * ? *', soqlBuilder, whereAndConditions);
            CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'AIQ FES Processor - Recurring Job - test job'];
        Test.stopTest();
        Assert.areNotEqual(null, ct, 'Should not be equal to null');
    }

    private static zal.AndCondition whereAndConditions {
        get {
            List<String> fesLineLevels = new List<String>{'Item', 'Set', 'Subset'};
            zal.AndCondition whereAndConditions = new zal.AndCondition();
            whereAndConditions.add(new zal.FieldCondition('RecordType.Name', zal.Operator.EQUALS, 'Active'));
            whereAndConditions.add(new zal.SetCondition('zpl__LineLevel__r.Name', zal.Operator.INX, fesLineLevels));
            whereAndConditions.add(new zal.FieldCondition('zpl__Product__c', zal.Operator.NOT_EQUALS, null));
            whereAndConditions.add(new zal.FieldCondition('zpl__UOM__c', zal.Operator.NOT_EQUALS, null));
            return whereAndConditions;
        }
    }

    private static zal.SoqlBuilder soqlBuilder {
        get {
            zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                    .selectx('Id, zpl__Contract__c, zpl__LineLevel__r.Name')
                    .fromx('zpl__ContractLineItem__c');
            return soqlBuilder;
        }
    }
}
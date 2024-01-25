@isTest
private class AIQasync_NAConflictResolverTest {
    private static NationalAccountsPricing__c nationalAccountsPricing;
    private static zpl__ProductSelectorConfiguration__c productSelectorConfig;
    private static zpl__LineLevel__c lineLevelItem;
    private static List<Account> accounts;
    private static List<Servicing_Division__c> divisions;
    private static List<Contract> contracts;
    private static List<zpl__ContractLineItem__c> contractLines;
    private static zpl__ProductUOM__c productUOM;
    private static List<Product2> products;

    /*
	* This static constructor prepares the test data of this class.
	*/
    static {
        AIQ_TestDataFactory.initializeZilliantConfiguration();
        nationalAccountsPricing = AIQ_TestDataFactory.initializeNationalAccountsPricing(null, false);
        productSelectorConfig = AIQ_TestDataFactory.initializeProductSelectorConfiguration(null, false);
        lineLevelItem = AIQ_TestDataFactory.initializeLineLevel(
            new zpl__LineLevel__c(
                zpl__LineLevelId__c = 'Item',
                Name = 'Item',
                zpl__Position__c = 1,
                zpl__ProductSelectorConfiguration__c = productSelectorConfig.Id
            ),
            false
        );
        accounts = AIQ_TestDataFactory.initializeAccounts(
            new Account(
                Name = 'TestAccount',
                Active__c = 'Yes',
                Suspect__c = '2. Prospect',
                Zilliant_Active__c = 'AI',
                AccountNumber = '000003',
                Legacy_System_Cd__c = '03',
                Legacy_Division_Cd__c = '01',
                Regional_Acct_Group_ID__c = 'testCA',
                zpl__CustomerId__c = 'SW000003',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Chain_Account').getRecordTypeId(),
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
                zpl__ContractId__c = 'SWBT107495',
                RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PricingContract').getRecordTypeId()
            ),
            1,
            false
        );
        contractLines = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                Name = 'TestContractLine',
                zpl__Contract__c = contracts[0].Id,
                LineSource__c = 'U',
                zpl__Status__c = 'Draft',
                zpl__LineLevel__c = lineLevelItem.Id,
                RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId(),
                SKU__c = '00000001',
                zpl__UOM__c = productUOM.Id,
                zpl__Product__c = products[0].Id
            ),
            1,
            false
        );
    }

    @isTest
    private static void testAsyncNAConflictResolver() {
        Test.startTest();
        AIQasync_NAConflictResolver batchCalcs = new AIQasync_NAConflictResolver(new List<String>{'andriy.suh@zilliant.com'}, 200);
        Id batchProcId = Database.executeBatch(batchCalcs);
        Test.stopTest();
        System.assert(batchProcId != null, 'batchProcId is not null');
    }
}
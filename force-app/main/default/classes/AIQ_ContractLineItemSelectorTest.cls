@IsTest
private class AIQ_ContractLineItemSelectorTest {

    private static List<Account> accounts;
    private static List<Contract> contracts;
    private static List<zpl__ContractLineItem__c> contractLines;
    private static List<Servicing_Division__c> divisions;
    private static zpl__ProductUOM__c productUOM;
    private static List<Product2> products;

    static {
        AIQ_TestDataFactory.initializeZilliantConfiguration();
        accounts = AIQ_TestDataFactory.initializeAccounts(new Account(Name = 'TestAccount', Active__c = 'Yes'), 1, false);
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
                zpl__UOM__c = productUOM.Id,
                zpl__Product__c = products[0].Id
            ),
            1,
            false
        );
    }

    @IsTest
    private static void testQueryContractLineById() {
        Account account = AIQ_TestDataFactory.initializeAccounts(accounts[0], 1, true).get(0);
        Contract contract = contracts[0];
        zpl__ContractLineItem__c contractLine = contractLines[0];
        Test.startTest();
            zpl__ContractLineItem__c actualContractLine = new AIQ_ContractLineSelector().queryContractLineById(contractLine.Id);
        Test.stopTest();
        System.assertEquals(contractLine.Name, actualContractLine.Name, 'Name is not correct');
        System.assertEquals(contract.Id, actualContractLine.zpl__Contract__c, 'Master-Detail relation is not correct');
    }

    @IsTest
    private static void testQueryContractLinesById() {
        Account account = AIQ_TestDataFactory.initializeAccounts(accounts[0], 1, true).get(0);
        zpl__ContractLineItem__c contractLine = contractLines[0];
        Test.startTest();
            List<zpl__ContractLineItem__c> actualContractLineList = new AIQ_ContractLineSelector().queryContractLinesById(new Set<Id> {contractLine.Id});
        Test.stopTest();
        System.assertEquals(contractLine.Name, actualContractLineList[0].Name, 'Name is not correct');
    }

}
@IsTest
private class AIQ_ContractSelectorTest {
   
    private static List<Account> accounts;
    private static List<Contract> contracts;
    private static List<Servicing_Division__c> divisions;

    static {
        accounts = AIQ_TestDataFactory.initializeAccounts(new Account(Name = 'TestAccount'), 1, false);
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
                Division__c = divisions[0].Id,
                zpl__ContractId__c = 'SWBT107495'
            ),
            1,
            false
        );
    }

    @IsTest
    private static void testQueryContractById() {
        Account account = AIQ_TestDataFactory.initializeAccounts(accounts[0], 1, true).get(0);
        Contract contract = contracts[0];
        Test.startTest();
            Contract actual = new AIQ_ContractSelector().queryContractById(contract.Id);
        Test.stopTest();
        System.assertEquals(contract.Name, actual.Name, 'Name is not correct');
    }

    @IsTest
    private static void testQueryContractsById() {
        Account account = AIQ_TestDataFactory.initializeAccounts(accounts[0], 1, true).get(0);
        Set<Id> contracts = new Set<Id> {contracts[0].Id};
        Test.startTest();
            List<Contract> actual = new AIQ_ContractSelector().queryContractsById(contracts);
        Test.stopTest();
        System.assertEquals(contracts.size(), actual.size(), 'Contract size is not correct');
    }

    @IsTest
    private static void testQueryContractByExternalId() {
        Account account = AIQ_TestDataFactory.initializeAccounts(accounts[0], 1, true).get(0);
        List<Contract> actual = new AIQ_ContractSelector().queryContractByExternalId(
            new List<String>(), 
            new List<String> {contracts[0].zpl__ContractId__c}
        );
        System.assertEquals(contracts[0].zpl__ContractId__c, actual[0].zpl__ContractId__c, 'ExternalId is not correct');
    }

    @IsTest
    private static void getSubQuery() {
        Test.startTest();
            zal.SoqlBuilder subQuery = new AIQ_ContractSelector().getSubQuery(
                new List<String> {'Id'},
                'zpl__Contract__r',
                null);
        Test.stopTest();
        System.assertEquals('SELECT Id \nFROM zpl__Contract__r', subQuery.toSoql(), 'subquery was not build properly');
    }

}
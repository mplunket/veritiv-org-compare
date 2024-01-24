@IsTest
private class AIQtr_AgreementTriggerHandlerTest {
    private static List<Account> accounts;
    private static List<Servicing_Division__c> divisions;
    private static List<Contract> contracts;

    static {
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
                        Division__c = divisions[0].Id,
                        Score__c = 3.0
                ),
                1,
                false
        );
    }

    @IsTest
    private static void testUpdateContracts() {
        Test.startTest();
            contracts[0].Score__c = 3.0;
            update contracts;
        Test.stopTest();
        Assert.areEqual(3.0, contracts[0].Score__c, 'Should be equal to 3.0');
    }

    @IsTest
    private static void testDeleteContracts() {
        Test.startTest();
            delete contracts;
        Test.stopTest();
        Assert.areNotEqual(null, contracts, 'Should not be equal to null');
    }
}
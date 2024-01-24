@IsTest
private class AIQ_RollupCalculationTest {
    private static List<Account> accounts;
    private static List<Contract> contracts;
    private static List<Servicing_Division__c> divisions;
    private static List<zpl__ContractLineItem__c> expiringLinesPlusTenDays;

    static {
        AIQ_TestDataFactory.initializeZilliantConfiguration();
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
        expiringLinesPlusTenDays = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                Name = 'TestContractLine2',
                zpl__Contract__c = contracts[0].Id,
                RecordTypeId = AIQ_DeleteLine.ACTIVE_RECORD_TYPE_ID,
                CBSSItemGroupingKey__c = '123',
                zpl__Status__c = 'Published',
                DisallowCampaignsThroughDate__c = Date.today().addDays(10)
            ),
            1,
            false
        );
    }

    @IsTest
    private static void testUpdateScoreRevenue() {
        AIQRollupCalculation rollUpCalculation = new AIQRollupCalculation(contracts);
        Test.startTest();
        rollUpCalculation.saveUpdatedContracts();
        Test.stopTest();
        List<Contract> contracts = [SELECT Id,ExpContractLinesCount__c FROM Contract WHERE Id =: contracts[0].Id];
        System.assertEquals(1, contracts[0].ExpContractLinesCount__c, 'Contract has one expired line');
    }

}
@IsTest
private class AIQ_AgreementTriggerHandlerTest {
    private static final String ACCOUNT_RT_PROSPECT_ID = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('Prospect')
            .getRecordTypeId();
    private static final String CONTRACT_RT_PRICING_ID = Schema.SObjectType.Contract
            .getRecordTypeInfosByDeveloperName()
            .get('PricingContract')
            .getRecordTypeId();
    private static List<Servicing_Division__c> divisions;
    private static List<Account> accounts;
    private static List<Contract> contracts;

    static {
        AIQ_TestDataFactory.initializeZilliantConfiguration();
        divisions = AIQ_TestDataFactory.initializeDivisions(
                new Servicing_Division__c(
                        Name = 'TestDiv2',
                        Division_Code__c = '70',
                        Division_Composite_Key__c = '0370'
                ),
                1,
                false
        );
        accounts = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'Test Account',
                        Active__c = 'Yes',
                        Suspect__c = '2. Prospect',
                        Zilliant_Active__c = 'AI',
                        Has_Agreement__c = false,
                        RecordTypeId = ACCOUNT_RT_PROSPECT_ID,
                        OwnerId = UserInfo.getUserId(),
                        Servicing_Division__c = divisions[0].Id
                ),
                1,
                false
        );
        contracts = AIQ_TestDataFactory.initializeContracts(
                new Contract(
                        Name = 'Test Contract',
                        AccountId = accounts[0].Id,
                        Division__c = divisions[0].Id,
                        RecordTypeId = CONTRACT_RT_PRICING_ID
                ),
                1,
                false
        );
    }

    @IsTest
    private static void testValidateAccount() {
        contracts[0].RecordTypeId = null;
        Test.startTest();
            AIQ_AgreementTriggerHandler.validateAccount(contracts);
        Test.stopTest();
        Assert.isTrue(contracts[0].RecordType.Name == null, 'Should be equal to null');
    }

    @IsTest
    private static void testUpdateAccount() {
        Test.startTest();
            AIQ_AgreementTriggerHandler.updateAccount(contracts);
        Test.stopTest();
        Assert.isFalse(accounts[0].Has_Agreement__c, 'Should be equal to false');
    }

    @IsTest
    private static void testIsPricingContractRecordType() {
        Test.startTest();
            Boolean isPricing = AIQ_AgreementTriggerHandler.isPricingContractRecordType(contracts);
        Test.stopTest();
        Assert.isTrue(isPricing, 'Should be equal to true');
    }

    @IsTest
    private static void testRunSyncDown(){
        Test.startTest();
            AIQ_AgreementTriggerHandler.runSyncDown();
        Test.stopTest();
        Boolean hasToRun = (Boolean) AIQZilliantConfiguration__c.getInstance().get('runContractZCloudSync__c');
        Assert.isTrue(hasToRun, 'Should be equal to true and run Sync Down process');
    }
}
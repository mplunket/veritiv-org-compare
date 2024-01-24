@isTest
private class AIQ_ChainAccountLinesFilterTest {
    private static final Id CONTRACT_ID = AIQts_ApexMocks.generateId(new Contract().getSObjectType());
    private static final Id CHAIN_ACCOUNT_ID = AIQts_ApexMocks.generateId(new Account().getSObjectType());
    private static Account account;
    private static Contract contract;
    private static List<zpl__ContractLineItem__c> contractLines;

    static {
        account = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'Test Acc',
                        Chain_Account__c = CHAIN_ACCOUNT_ID
                ),
                1,
                true
        )[0];
        contract = AIQ_TestDataFactory.initializeContracts(
                new Contract(
                        Name = 'TestContract',
                        AccountId = account.Id
                ),
                1,
                true
        )[0];
        contractLines = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'TestContractLine',
                        zpl__Contract__r = contract,
                        RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId(),
                        isCurrent__c = true
                ),
                1,
                true,
                false
        );
    }

    @isTest
    private static void testGetFilterCondition() {
        Test.startTest();
            zal.Condition condition = new AIQ_ChainAccountLinesFilter().getFilterCondition(null);
        Test.stopTest();

        Assert.areEqual(null, condition, 'The returned value should be null');
    }

    @isTest
    private static void testGetScopedFilterCondition() {
        Map<String,Object> scope = new Map<String,Object>{'contractId' => CONTRACT_ID};
        AIQ_ChainAccountLinesFilter chainAccountLinesFilter = initMocks(scope);

        zal.AndCondition expectedCondition = new zal.AndCondition();
        expectedCondition.add(new zal.FieldCondition(
                AIQ_ChainAccountLinesFilter.RECORD_TYPE_ID_FIELD,
                zal.Operator.EQUALS,
                AIQ_ChainAccountLinesFilter.CLI_RT_ACTIVE_ID)
        );
        expectedCondition.add(new zal.FieldCondition(AIQ_ChainAccountLinesFilter.IS_CURRENT_FIELD, zal.Operator.EQUALS, true));
        expectedCondition.add(new zal.FieldCondition(
                AIQ_ChainAccountLinesFilter.CONTRACT_ACCOUNT_ID_FIELD,
                zal.Operator.EQUALS,
                null)
        );
        Test.startTest();
            zal.Condition actualCondition = chainaccountlinesfilter.getScopedFilterCondition(null, scope);
        Test.stopTest();

        Assert.areEqual(expectedCondition.toSoql(), actualCondition.toSoql(), 'The result should be equal');
    }

    private static AIQ_ChainAccountLinesFilter initMocks(Map<String,Object> scope) {
        String contractId = (String) scope.get('contractId');
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQ_GenericSelector genericSelector = (AIQ_GenericSelector) mocks.mock(AIQ_GenericSelector.class);
        mocks.startStubbing();
            mocks.when(genericSelector.queryContractById(contractId)).thenReturn(contract);
        mocks.stopStubbing();
        AIQ_ChainAccountLinesFilter chainaccountlinesfilter = new AIQ_ChainAccountLinesFilter();
        chainaccountlinesfilter.genericSelector = genericSelector;

        return chainaccountlinesfilter;
    }
}
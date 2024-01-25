@isTest
private class AIQ_ContractLineItemFilterTest {
    private static final Id CONTRACT_ID = AIQts_ApexMocks.generateId(new Contract().getSObjectType());

    @isTest
    private static void testGetFilterCondition() {
        zal.AndCondition expectedCondition = new zal.AndCondition();
        expectedCondition.add(new zal.FieldCondition(
                AIQ_ContractLineItemFilter.RECORD_TYPE_ID_FIELD,
                zal.Operator.NOT_EQUALS,
                AIQ_ContractLineItemFilter.CLI_RT_INACTIVE_ID)
        );

        zal.OrCondition secondCondition = new zal.OrCondition();
        secondCondition.add(new zal.FieldCondition(
                AIQ_ContractLineItemFilter.IS_CURRENT_FIELD,
                zal.Operator.EQUALS,
                true)
        );
        secondCondition.add(new zal.FieldCondition(
                AIQ_ContractLineItemFilter.SUPERSEDED_DATE_FIELD,
                zal.Operator.EQUALS,
                null)
        );
        secondCondition.add(new zal.FieldCondition(
                AIQ_ContractLineItemFilter.SUPERSEDED_DATE_FIELD,
                zal.Operator.LESS_THAN,
                DateTime.newInstance(1900, 2, 1, 0, 0, 0))
        );

        zal.AndCondition dateCondition = new zal.AndCondition();
        dateCondition.add(new zal.FieldCondition(
                AIQ_ContractLineItemFilter.SUPERSEDED_DATE_FIELD,
                zal.Operator.LESS_THAN_OR_EQUAL_TO,
                System.now())
        );
        dateCondition.add(new zal.FieldCondition(
                AIQ_ContractLineItemFilter.SUPERSEDED_DATE_FIELD,
                zal.Operator.GREATER_THAN_OR_EQUAL_TO,
                System.now().addDays(-7))
        );
        secondCondition.add(dateCondition);
        expectedCondition.add(secondCondition);

        Test.startTest();
            AIQ_ContractLineItemFilter contractlineitemfilter = new AIQ_ContractLineItemFilter();
            zal.Condition actualCondition = contractlineitemfilter.getFilterCondition(CONTRACT_ID);
        Test.stopTest();

        Assert.areEqual(expectedCondition.toSoql(), actualCondition.toSoql(), 'The result should be equal');
    }
}
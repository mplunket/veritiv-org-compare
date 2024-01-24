@isTest
private class AIQ_AuditTrailLinesFilterTest {
    private static final Id CONTRACT_ID = AIQts_ApexMocks.generateId(new Contract().getSObjectType());

    @isTest
    private static void testGetFilterCondition() {
        zal.AndCondition expectedCondition = new zal.AndCondition();
        expectedCondition.add(new zal.FieldCondition(
                AIQ_AuditTrailLinesFilter.STATUS_FIELD,
                zal.Operator.NOT_EQUALS,
                AIQ_AuditTrailLinesFilter.CLI_STATUS_DRAFT)
        );
        zal.OrCondition supersededDayCondition = new zal.OrCondition();
        supersededDayCondition.add(new zal.FieldCondition(
                AIQ_AuditTrailLinesFilter.SUPERSEDED_DATE_FIELD,
                zal.Operator.GREATER_THAN,
                System.now().addDays(-365))
        );
        supersededDayCondition.add(new zal.FieldCondition(
                AIQ_AuditTrailLinesFilter.SUPERSEDED_DATE_FIELD,
                zal.Operator.EQUALS,
                null)
        );
        expectedCondition.add(supersededDayCondition);

        Test.startTest();
            AIQ_AuditTrailLinesFilter audittraillinesfilter = new AIQ_AuditTrailLinesFilter();
            zal.Condition actualCondition = audittraillinesfilter.getFilterCondition(CONTRACT_ID);
        Test.stopTest();

        Assert.areEqual(expectedCondition.toSoql(), actualCondition.toSoql(), 'The result should be equal');
    }
}
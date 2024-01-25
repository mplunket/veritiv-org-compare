@IsTest
private class AIQ_CampaignLinesFilterTest {
    private static final Id CONTRACT_ID = AIQts_ApexMocks.generateId(new Contract().getSObjectType());

    @isTest
    private static void testGetFilterCondition() {
        zal.AndCondition expectedCondition = new zal.AndCondition();
        expectedCondition.add(new zal.FieldCondition(
                AIQ_CampaignLinesFilter.IS_CAMPAIGN_FIELD,
                zal.Operator.EQUALS,
                true)
        );
        expectedCondition.add(new zal.FieldCondition(
                AIQ_CampaignLinesFilter.STATUS_FIELD,
                zal.Operator.EQUALS,
                AIQ_CampaignLinesFilter.CLI_STATUS_PUBLISHED)
        );
        expectedCondition.add(new zal.FieldCondition(
                AIQ_CampaignLinesFilter.EFFECTIVE_DATE_FIELD,
                zal.Operator.GREATER_THAN_OR_EQUAL_TO,
                System.today().adddays(AIQ_CampaignLinesFilter.INTERVAL))
        );
        Test.startTest();
            AIQ_CampaignLinesFilter campaignlinesfilter = new AIQ_CampaignLinesFilter();
            zal.Condition actualCondition = campaignlinesfilter.getFilterCondition(CONTRACT_ID);
        Test.stopTest();

        System.assertEquals(expectedCondition.toSoql(), actualCondition.toSoql(), 'The result should be equal');
    }
}
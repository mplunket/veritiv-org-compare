@IsTest
private class AIQ_PriceRecommendationTest {
    private static final String RECOMMENDATION_ID = 'testId';
    private static final Decimal START_MARKUP = 30.1;
    private static final Decimal TARGAT_MARKUP = 20.1;
    private static final Decimal FLOOR_MARKUP = 10.1;
    private static final String STATUS = 'testStatus';

    @IsTest
    private static void testGetSTART_MARKUP() {
        AIQPriceRecommendation priceRecommendation = getPriceRecommendationInstance();
        Test.startTest();
            Assert.areEqual(START_MARKUP, priceRecommendation.getStartMarkup());
        Test.stopTest();
    }

    @IsTest
    private static void testGetTARGAT_MARKUP() {
        AIQPriceRecommendation priceRecommendation = getPriceRecommendationInstance();
        Test.startTest();
            Assert.areEqual(TARGAT_MARKUP, priceRecommendation.getTargetMarkup());
        Test.stopTest();
    }

    @IsTest
    private static void testGetFLOOR_MARKUP() {
        AIQPriceRecommendation priceRecommendation = getPriceRecommendationInstance();
        Test.startTest();
            Assert.areEqual(FLOOR_MARKUP, priceRecommendation.getFloorMarkup());
        Test.stopTest();
    }

    @IsTest
    private static void testGetRecommendationId() {
        AIQPriceRecommendation priceRecommendation = getPriceRecommendationInstance();
        Test.startTest();
            Assert.areEqual(RECOMMENDATION_ID, priceRecommendation.getRecommendationId());
        Test.stopTest();
    }

    @IsTest
    private static void testGetStatus() {
        AIQPriceRecommendation priceRecommendation = getPriceRecommendationInstance();
        Test.startTest();
            Assert.areEqual(STATUS, priceRecommendation.getStatus());
        Test.stopTest();
    }
    
    private static AIQPriceRecommendation getPriceRecommendationInstance() {
        return new AIQPriceRecommendation(
            'testId',
            30.1,
            20.1,
            10.1,
            'testStatus'
        );
    }
}
@IsTest
private class AIQ_ProductTriggerHandlerTest {
    private static AIQZilliantConfiguration__c zilliantConfiguration;

    static {
        zilliantConfiguration = AIQ_TestDataFactory.initializeZilliantConfiguration(null, true);
    }

    @IsTest
    private static void testRunSyncDown() {
        Test.startTest();
            AIQ_ProductTriggerHandler.runSyncDown();
        Test.stopTest();

        Assert.isTrue(zilliantConfiguration.runProductZCloudSync__c, 'The flag should be true for the sync down process to work');
    }
}
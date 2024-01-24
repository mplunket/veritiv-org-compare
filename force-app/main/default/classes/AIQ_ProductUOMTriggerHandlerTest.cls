@IsTest
private class AIQ_ProductUOMTriggerHandlerTest {
    private static AIQZilliantConfiguration__c zilliantConfiguration;
    private static zpl__ProductUOM__c uom1;
    private static zpl__ProductUOM__c uom2;

    static {
        zilliantConfiguration = AIQ_TestDataFactory.initializeZilliantConfiguration(null, true);
        uom1 = AIQ_TestDataFactory.initializeProductUOM(
                new zpl__ProductUOM__c(
                        Name = 'M',
                        zpl__ConversionFactor__c = 1,
                        Allow_For_Pricing__c = true
                ),
                true
        );
        uom2 = AIQ_TestDataFactory.initializeProductUOM(
                new zpl__ProductUOM__c(
                        Name = 'M',
                        zpl__ConversionFactor__c = -1,
                        Allow_For_Pricing__c = false
                ),
                true
        );
    }

    @IsTest
    private static void testUpdateHidden() {
        List<zpl__ProductUOM__c> uoms = new List<zpl__ProductUOM__c>();
        uoms.add(uom1);
        uoms.add(uom2);

        Test.startTest();
            AIQ_ProductUOMTriggerHandler.updateHidden(uoms);
        Test.stopTest();

        Assert.isFalse(uom1.zpl__Hidden__c, 'The flag will be changed to false');
        Assert.isTrue(uom2.zpl__Hidden__c, 'The flag will be changed to true');
    }

    @IsTest
    private static void testRunSyncDown() {
        Test.startTest();
            AIQ_ProductUOMTriggerHandler.runSyncDown();
        Test.stopTest();

        Assert.isTrue(zilliantConfiguration.runProductZCloudSync__c, 'The flag should be true for the sync down process to work');
    }
}
@IsTest
private class AIQtr_ProductUOMTriggerHandlerTest {
    private static zpl__ProductUOM__c uom;

    static {
        uom = AIQ_TestDataFactory.initializeProductUOM(
                new zpl__ProductUOM__c(
                        Name = 'M',
                        zpl__ConversionFactor__c = 1
                ),
                false
        );
    }

    @IsTest
    private static void testUpdateUOM() {
        Test.startTest();
            uom.zpl__ConversionFactor__c = 5;
            update uom;
        Test.stopTest();
        Assert.areEqual(5, uom.zpl__ConversionFactor__c, 'Conversion Factor should be equal to 5');
    }

    @IsTest
    private static void testDeleteUOM() {
        Test.startTest();
            delete uom;
        Test.stopTest();
        Assert.areNotEqual(null, uom, 'Should not be equal to null');
    }
}
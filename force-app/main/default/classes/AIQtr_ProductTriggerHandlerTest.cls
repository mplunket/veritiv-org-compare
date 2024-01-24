@IsTest
private class AIQtr_ProductTriggerHandlerTest {
    private static List<Product2> products;

    static {
        products = AIQ_TestDataFactory.initializeProduct2s(null, 1, false);
    }

    @IsTest
    private static void testUpdateProducts() {
        Test.startTest();
            products[0].List_Price__c = 4.0;
            update products;
        Test.stopTest();
        Assert.areEqual(4.0, products[0].List_Price__c, 'Should be equal to 4.0');
    }

    @IsTest
    private static void testDeleteProducts() {
        Test.startTest();
            delete products;
        Test.stopTest();
        Assert.areNotEqual(null, products, 'Should not be equal to null');
    }
}
@IsTest
public class AIQ_SyncProductFilterTest {

    @IsTest
    static void testUOMSyncFilterPositive(){
        Product2 record1 = new Product2(Name='product1', zpl__ProductId__c = 'externalIdProduct1', ProductCode = '000001');
        Product2 record2 = new Product2(Name='product1', zpl__ProductId__c = 'externalIdProduct1', ProductCode = '0000001');
        AIQ_SyncProductFilter filter = new AIQ_SyncProductFilter('Product2', 'AIQ_SyncDownFieldSet');
        Boolean result = filter.include(record1, record2);
        system.assertEquals(true, result);
    }
    
    @IsTest
    static void testUOMSyncFilterNegative(){
        Product2 record1 = new Product2(Name='product1', ProductCode = '000001');
        Product2 record2 = new Product2(Name='product1', zpl__ProductId__c = 'externalIdProduct1', ProductCode = '0000001');
        AIQ_SyncProductFilter filter = new AIQ_SyncProductFilter('Product2', 'AIQ_SyncDownFieldSet');
        Boolean result = filter.include(record1, record2);
        system.assertEquals(false, result);
    }
    
}
@IsTest
public class AIQ_SyncUOMFilterTest {

    @IsTest
    static void testUOMSyncFilterPositive(){
        zpl__ProductUOM__c record1 = new zpl__ProductUOM__c(Name='uom1', zpl__ProductUOMId__c = 'externalIdLine1', zpl__ConversionFactor__c = 1.0);
        zpl__ProductUOM__c record2 = new zpl__ProductUOM__c(Name='uom1', zpl__ProductUOMId__c = 'externalIdLine1', zpl__ConversionFactor__c = 2.0);
        AIQ_SyncUOMFilter filter = new AIQ_SyncUOMFilter('zpl__ProductUOM__c', 'SyncDownFieldSet');
        Boolean result = filter.include(record1, record2);
        system.assertEquals(true, result);
    }
    
    @IsTest
    static void testUOMSyncFilterNegative(){
        zpl__ProductUOM__c record1 = new zpl__ProductUOM__c(Name='uom1', zpl__ConversionFactor__c = 1.0);
        zpl__ProductUOM__c record2 = new zpl__ProductUOM__c(Name='uom1', zpl__ConversionFactor__c = 2.0);
        AIQ_SyncUOMFilter filter = new AIQ_SyncUOMFilter('zpl__ProductUOM__c', 'SyncDownFieldSet');
        Boolean result = filter.include(record1, record2);
        system.assertEquals(false, result);
    }
    
}
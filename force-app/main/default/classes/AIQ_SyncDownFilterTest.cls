@IsTest
public class AIQ_SyncDownFilterTest {
    
    @IsTest
    static void tesSyncDownFilterNegative(){
        Test.startTest();
        zpl__ProductUOM__c uom = new zpl__ProductUOM__c(name='Box', zpl__ConversionFactor__c = 1, zpl__ProductUOMId__c = 'Box1');
        AIQ_SyncDownFilter filter = new AIQ_SyncDownFilter('zpl__ProductUOM__c', 'SyncDownFieldSet');
        Boolean result = filter.include(uom, uom);
        system.assertEquals(false, result);
        Test.stopTest();
    }
    
    @IsTest
    static void tesSyncDownFilterPositive(){
        Test.startTest();
        zpl__ProductUOM__c uom1 = new zpl__ProductUOM__c(name='Box', zpl__ConversionFactor__c = 1, zpl__ProductUOMId__c = 'Box1');
        zpl__ProductUOM__c uom2 = new zpl__ProductUOM__c(name='Box', zpl__ConversionFactor__c = 2, zpl__ProductUOMId__c = 'Box1');
        AIQ_SyncDownFilter filter = new AIQ_SyncDownFilter('zpl__ProductUOM__c', 'SyncDownFieldSet');
        Boolean result = filter.include(uom1, uom2);
        system.assertEquals(true, result);
        Test.stopTest();
    }
    
    @IsTest
    static void tesSyncDownFilterNull(){
        Test.startTest();
        AIQ_SyncDownFilter filter = new AIQ_SyncDownFilter('zpl__ProductUOM__c', 'SyncDownFieldSet');
        Boolean result = filter.include(null, null);
        system.assertEquals(true, result);
        Test.stopTest();
    }
    
    @IsTest
    static void tesSyncDownFilterNoFieldSet(){
        Test.startTest();
        zpl__ProductUOM__c uom1 = new zpl__ProductUOM__c(name='Box', zpl__ConversionFactor__c = 1, zpl__ProductUOMId__c = 'Box1');
        zpl__ProductUOM__c uom2 = new zpl__ProductUOM__c(name='Box', zpl__ConversionFactor__c = 2, zpl__ProductUOMId__c = 'Box1');
        AIQ_SyncDownFilter filter = new AIQ_SyncDownFilter('zpl__ProductUOM__c', '');
        Boolean result = filter.include(uom1, uom2);
        system.assertEquals(true, result);
        Test.stopTest();
    }
    
    @IsTest
    static void tesSyncDownFilterForTypePositive(){
        Test.startTest();
        zpl__ProductUOM__c uom1 = new zpl__ProductUOM__c(name='Box', zpl__ConversionFactor__c = 1, zpl__ProductUOMId__c = 'Box1');
        zpl__ProductUOM__c uom2 = new zpl__ProductUOM__c(name='Box', zpl__ConversionFactor__c = 2, zpl__ProductUOMId__c = 'Box1');
        AIQ_SyncDownFilter filter = new AIQ_SyncDownFilter('zpl__ProductUOM__c');
        Boolean result = filter.include(uom1, uom2);
        system.assertEquals(true, result);
        Test.stopTest();
    }
    
     @IsTest
    static void tesSyncDownFilterForTypeNegative(){
        Test.startTest();
        zpl__ProductUOM__c uom1 = new zpl__ProductUOM__c(name='Box', zpl__ConversionFactor__c = 1, zpl__ProductUOMId__c = 'Box1');
        zpl__ProductUOM__c uom2 = new zpl__ProductUOM__c(name='Box', zpl__ConversionFactor__c = 2, zpl__ProductUOMId__c = 'Box1');
        AIQ_SyncDownFilter filter = new AIQ_SyncDownFilter('Product2');
        Boolean result = filter.include(uom1, uom2);
        system.assertEquals(false, result);
        Test.stopTest();
    }

}
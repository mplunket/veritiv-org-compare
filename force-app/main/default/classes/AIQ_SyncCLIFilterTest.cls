@IsTest
public class AIQ_SyncCLIFilterTest {
    
    @IsTest
    static void testCLISyncFilterPositive(){
        zpl__ContractLineItem__c line1 = new zpl__ContractLineItem__c(Name='line1', zpl__ContractLineItemId__c = 'externalIdLine1', zpl__ContractPrice__c = 1.0);
        zpl__ContractLineItem__c line2 = new zpl__ContractLineItem__c(Name='line1', zpl__ContractLineItemId__c = 'externalIdLine1', zpl__ContractPrice__c = 2.0);
        AIQ_SyncCLIFilter filter = new AIQ_SyncCLIFilter('zpl__ContractLineItem__c');
        Boolean result = filter.include(line1, line2);
        system.assertEquals(true, result);
    }
    
     @IsTest
    static void testCLISyncFilterNegative(){
        zpl__ContractLineItem__c line1 = new zpl__ContractLineItem__c(Name='line1', zpl__ContractPrice__c = 1.0);
        AIQ_SyncCLIFilter filter = new AIQ_SyncCLIFilter('zpl__ContractLineItem__c');
        Boolean result = filter.include(line1, line1);
        system.assertEquals(false, result);
    }

}
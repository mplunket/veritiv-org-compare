@IsTest
public class AIQ_SyncAccountFilterTest {
    
    @IsTest
    static void testAccountSyncFilterPositive(){
        Account record1 = new Account(Name='account1', zpl__CustomerId__c = 'externalIdAccount1', Zilliant_Active__c = 'AI');
        Account record2 = new Account(Name='account1', zpl__CustomerId__c = 'externalIdAccount1', Zilliant_Active__c = 'Y');
        AIQ_SyncAccountFilter filter = new AIQ_SyncAccountFilter('Account', 'AIQ_SyncDownFieldSet');
        Boolean result = filter.include(record1, record2);
        system.assertEquals(true, result);
    }
    
    @IsTest
    static void testAccountSyncFilterPositive2(){
        Account record1 = new Account(Name='account1', zpl__CustomerId__c = 'externalIdAccount1', Zilliant_Active__c = 'Y');
        Account record2 = new Account(Name='account1', zpl__CustomerId__c = 'externalIdAccount1', Zilliant_Active__c = 'AI');
        AIQ_SyncAccountFilter filter = new AIQ_SyncAccountFilter('Account', 'AIQ_SyncDownFieldSet');
        Boolean result = filter.include(record1, record2);
        system.assertEquals(true, result);
    }
    
    @IsTest
    static void testAccountSyncFilterNegative(){
        Account record1 = new Account(Name='account1', zpl__CustomerId__c = 'externalIdAccount1', Zilliant_Active__c = 'Y');
        Account record2 = new Account(Name='account2', zpl__CustomerId__c = 'externalIdAccount1', Zilliant_Active__c = 'Y');
        AIQ_SyncAccountFilter filter = new AIQ_SyncAccountFilter('Account', 'AIQ_SyncDownFieldSet');
        Boolean result = filter.include(record1, record2);
        system.assertEquals(false, result);
    }

}
@isTest
private class DeleteUnifyPricingRecordsSchedulerTest {
    @isTest static void testDeleteUnifyPricingRecordsScheduler() {
        
        // Create test data
        Unify_National_Accounts_Pricing__c testRecord1 = new Unify_National_Accounts_Pricing__c(Name='Test',CreatedDate=Datetime.now()-45,LastModifiedDate=Datetime.now()-45);
        insert testRecord1;
        
        Unify_National_Accounts_Pricing__c testRecord2 = new Unify_National_Accounts_Pricing__c(Name='Test',CreatedDate=Datetime.now()-5,LastModifiedDate=Datetime.now()-5);
        insert testRecord2;        
                
        // Execute the DeleteUnifyPricingRecordsScheduler immediately
        Test.startTest();
        DeleteUnifyPricingRecordsScheduler scheduler = new DeleteUnifyPricingRecordsScheduler();
        scheduler.execute(null);
        Test.stopTest();
        
        // Verify that the record was deleted
        List<Unify_National_Accounts_Pricing__c> records = [SELECT Id FROM Unify_National_Accounts_Pricing__c WHERE Id in (:testRecord1.Id,:testRecord2.Id)];
        System.assertEquals(1, records.size());
    }
}
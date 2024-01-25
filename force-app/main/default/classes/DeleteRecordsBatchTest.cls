@isTest
private class DeleteRecordsBatchTest {
    @isTest static void testDeleteRecordsBatch() {
        // Create test data
        List<Unify_National_Accounts_Pricing__c> records = new List<Unify_National_Accounts_Pricing__c>();
        for (Integer i = 0; i < 10; i++) {
            records.add(new Unify_National_Accounts_Pricing__c(Name = 'Test ' + i));
        }
        insert records;

        // Run the batch job
        Test.startTest();
        String query = 'SELECT Id FROM Unify_National_Accounts_Pricing__c';
        DeleteRecordsBatch batch = new DeleteRecordsBatch(query);
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify that the records were deleted
        List<Unify_National_Accounts_Pricing__c> remainingRecords = [SELECT Id FROM Unify_National_Accounts_Pricing__c];
        System.assertEquals(0, remainingRecords.size());
    }
}
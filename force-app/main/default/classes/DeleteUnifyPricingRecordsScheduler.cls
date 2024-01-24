global class DeleteUnifyPricingRecordsScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        String query = 'SELECT Id FROM Unify_National_Accounts_Pricing__c WHERE LastModifiedDate < LAST_N_DAYS:30 Limit 5000000';
        DeleteRecordsBatch batch = new DeleteRecordsBatch(query);
        Database.executeBatch(batch);        
    }
}
global class DeleteRecordsBatch implements Database.Batchable<sObject>, Database.Stateful {
    private String query;

    global DeleteRecordsBatch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {
        // Optional: send email or do other post-processing here
    }
}
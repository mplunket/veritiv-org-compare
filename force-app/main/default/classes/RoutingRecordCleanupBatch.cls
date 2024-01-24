//Batch for deleting Routing Records that have been inactive for more than 60 days
public class RoutingRecordCleanupBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {

    public void execute(SchedulableContext context) {
        Database.executeBatch(this, 200);
    }

    public List<ANI_Routing_Record__c> start(Database.BatchableContext bc) {
        return
            [SELECT Inactive_Date__c
            FROM ANI_Routing_Record__c
            WHERE Inactive_Date__c != TODAY AND Inactive_Date__c != null];
    }

    public void execute(Database.BatchableContext bc, List<ANI_Routing_Record__c> oldInactiveRoutingRecords) {
        delete oldInactiveRoutingRecords;
    }

    public void finish(Database.BatchableContext bc) {}
}
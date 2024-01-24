trigger calcDurations on WorkOrder(after update) {
    try {
            list<Work_Order_Durations__c> durations = new list<Work_Order_Durations__c>();
            set<string> trackedFields = new set<string> {'OwnerId', 'Status'}; //add more fields here
            STOWD.API.CalculateDurations(durations, trackedFields, 'WorkOrderHistory', 'WorkOrderId'); 
            database.insert(durations, false);
    }
    catch (exception e) {}
}
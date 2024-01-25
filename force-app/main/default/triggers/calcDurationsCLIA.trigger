trigger calcDurationsCLIA on Contract_Line_Item_Approval__c(after update) {
    try {
            list<CLIA_Durations__c> durations = new list<CLIA_Durations__c>();
            set<string> trackedFields = new set<string> {'OwnerId', 'Status__c'}; //add more fields here
            STOWD.API.CalculateDurations(durations, trackedFields, 'Contract_Line_Item_Approval__History', 'ParentId'); 
            database.insert(durations, false);
    }
    catch (exception e) {}
    }
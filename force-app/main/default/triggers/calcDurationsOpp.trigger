trigger calcDurationsOpp on Opportunity(after update) {
        try {
            list<Opportunity_Durations__c> durations = new list<Opportunity_Durations__c>();
            set<string> trackedFields = new set<string> {'OwnerId', 'StageName'}; //add more fields here
            STOWD.API.CalculateDurations(durations, trackedFields, 'OpportunityFieldHistory','OpportunityId'); 
            database.insert(durations, false);
        }
        catch (exception e) {}
    }
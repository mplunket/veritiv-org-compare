trigger OpportunityDurations on Opportunity_Durations__c (before insert, before update) {
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            STOWD.API.ValidateDurations();
        }

        if(Trigger.isUpdate)
        {
            STOWD.API.ValidateDurations();
        }
    }

}
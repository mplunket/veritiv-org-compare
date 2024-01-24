trigger Campaign on Campaign (after insert, after update) {
    
    if(Trigger.isBefore)
    {
        
    }
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {

        }
        if(Trigger.isUpdate)
        {
            CampaignServices.OTMCreationFlow(Trigger.oldMap, Trigger.newMap);
        }
    }
    
}
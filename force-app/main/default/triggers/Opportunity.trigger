trigger Opportunity on Opportunity (before insert, after insert, before update, after update) {
     //Updated line 3-6 on 08/21/2023 - Thunder
    OpportunityServices.newOpportunity = trigger.new;
    OpportunityServices.oldOpportunity = trigger.old;
    OpportunityServices.newMapOpportunity = trigger.newMap;
    OpportunityServices.oldMapOpportunity = trigger.oldMap;

     
    
    Set<String> specialistProductCategories = new Set<String>();
    Boolean addSpecialistsToSalesTeam = false;
    //Commented on 22/08/2018 as per request we removed since it is not used anymore
    /*
    for(RoleNameMapping__c rnm : OpportunityTriggerUtil.roleNameMapping)
    {
        specialistProductCategories.add(rnm.Product_Category__c);
    }
    */
    //As per Request, Testing - Cara profiled is removed and we don't need to check below condition.
/*
    Id testingCaraId = [select Id from Profile where Name = 'Testing - Cara'].Id;
    System.debug('Testing Cara Id: ' + testingCaraId);
    System.debug(UserInfo.getProfileId());
    if ( UserInfo.getProfileId() !=  testingCaraId )
*/
    
        
        System.debug('inside my profile');
        if(Trigger.isInsert)
        {
            if(Trigger.IsBefore)
            {
                
                //Code added for IMAP Lead soure autopopulate promocode
                List<Campaign> camp = [Select id from campaign where name = 'IMAP Market Potential' limit 1];
                Id campaignId;
                if(camp.size() > 0){
                    campaignId = camp[0].id;
                }
                for(opportunity op : trigger.new){
                    if(op.LeadSource == 'IMAP'){
                        op.CampaignId = campaignId;
                    }                    
                }
                
                //End of code changes
                
                
                //Commented below line on 22/08/2018 as per request we removed since it is not used anymore
                //OpportunityTriggerUtil.updateAccountDEUField(Trigger.new);
                OpportunityServices.updatePrimarySalesRepFromOwnerId(Trigger.new);
                /* 10/12 - Taken out to remove Account Vertical field and functionality on Opportunity to remove an inconsistent error. */
                /*
                List<Account> populatedAccounts = OpportunityTriggerUtil.populateAccountVerticalField(trigger.new);
                if(! populatedAccounts.isEmpty()){
                    OpportunityTriggerUtil.updateAccounts(populatedAccounts, trigger.new);
                }
                */
            }
            else
            {
                //Commented on 22/08/2018 as per request we removed since it is not used anymore
                /*
                for(Opportunity o : Trigger.new)
                {
                    if( o.Prod_Category__c != null )
                    {
                        for(String category : o.Prod_Category__c.split(';'))
                        {
                            if(specialistProductCategories.contains(category))
                            {
                                addSpecialistsToSalesTeam = true;
                                break;
                            }
                        }
                    }
                }
                if(addSpecialistsToSalesTeam )
                {
                    OpportunityTriggerUtil.updateExistingOpportunitiesSalesTeam(Trigger.new);
                }
                */
            }
        }
    
    
    
    
        else if(Trigger.isUpdate && trigger.isAfter)
        {
            /*Only update opportunity sales team if new product categories that
            map to specialists are added*/

            Set<String> oldProductCategories = new Set<String>();
            Set<String> newProductCategories = new Set<String>();


            for(Opportunity o : Trigger.old)
            {
                if(o.Prod_Category__c != null )
                {
                    for(String category : o.Prod_Category__c.split(';'))
                    {
                        oldProductCategories.add(category);
                    }
                }
            }

            for(Opportunity o : Trigger.new)
            {
                if(o.Prod_Category__c != null  )
                {
                    for(String category : o.Prod_Category__c.split(';'))
                    {
                        //Commented below line and add new oneon 22/08/2018 as per request we removed since it is not used anymore
                        //if(specialistProductCategories.contains(category) && !oldProductCategories.contains(category))
                            if(!oldProductCategories.contains(category))
                        {
                            newProductCategories.add(category);
                        }
                    }
                }
            }
            Boolean ownerHasChanged = false;
            for(Opportunity o : Trigger.new)
            {
                if(trigger.oldMap.get(o.Id).OwnerId != o.ownerId )
                    ownerHasChanged = true;
            }


            if(ownerHasChanged || !newProductCategories.isEmpty())
                OpportunityTriggerUtil.updateExistingOpportunitiesSalesTeam(Trigger.new);
        }
    

    if( trigger.isBefore && trigger.isUpdate )
    {
        /* 10/12 - Taken out to remove Account Vertical field and functionality on Opportunity to remove an inconsistent error. */
        /*
        List<Account> populatedAccounts = OpportunityTriggerUtil.populateAccountVerticalField(trigger.new);
        if(! populatedAccounts.isEmpty()){
            OpportunityTriggerUtil.updateAccounts(populatedAccounts, trigger.new);
        }
        */
        OpportunityTriggerUtil.carryOverSalesTeamOnOwnerChange( trigger.newMap, trigger.oldMap );
        OpportunityTriggerUtil.updateRepFieldsOnAccountFieldChange( trigger.newMap, trigger.oldMap );
        OpportunityServices.updatePrimarySalesRepFromOwnerId(Trigger.oldMap, Trigger.newMap);
        
    }
    else if( trigger.isAfter && trigger.isInsert )
    {
        
//        System.debug('vary first loop');
        OpportunityTriggerUtil.insertSalesTeamForPSRAndIRep( trigger.newMap );

        List<Opportunity> openOpportunities = ChatterServices.filterOpenOpportunities( trigger.new );

        ChatterServices.subscribePSRandOwnerToSObject( openOpportunities, new Map<ID,Opportunity>());
        
        //Commented this line to create another method on 08/21/2023 - Thunder
        //OpportunityServices.OTMCreationFlow(NULL, Trigger.New);
    } 
    else if( trigger.isAfter && trigger.isUpdate )
    {
        
      //  System.debug('number of times in after update');
        
        
        OpportunityTriggerUtil.createTeamMembersAfterTriggerFires( trigger.newMap );
        OpportunityTriggerUtil.updateSalesTeamForPSRAndIRep( trigger.newMap, trigger.oldMap );

        List<Opportunity> openOpportunities = ChatterServices.filterOpenOpportunities( trigger.new );
        ChatterServices.subscribePSRandOwnerToSObject(openOpportunities, trigger.oldMap);
        
        OpportunityServices.OTMCreationFlow(Trigger.OldMap, Trigger.New);
    }
    
    /* Removed for BL-3661 -- Remove VLS logic from org
    if( trigger.isAfter && trigger.isUpdate  )
    {
        List<Opportunity> filteredOpportunities = OpportunityTriggerUtil.filterBasedOnFieldUpdates( trigger.new, trigger.oldMap);
        if( !filteredOpportunities.isEmpty() )
        {
            List<Account> accountsToBeUpdated = OpportunityTriggerUtil.updateAccountFields( filteredOpportunities );
            OpportunityTriggerUtil.updateAccounts(accountsToBeUpdated, trigger.new);
        }
        
    }
	*/
}
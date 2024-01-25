trigger PrimarySalesRep on Primary_Sales_Rep__c (before insert, before update, after insert, after update)
{
    if(trigger.isBefore)
    {
        Set<Id> referencedUserIds = new Set<Id>();
        Set<String> sfUserIdSet = new Set<String>();
        Set<String> referencedNetworkIds = new Set<String>();
        Map<String, User> networkIdToUser = new Map<String, User>();
        Map<String,Primary_Sales_Rep__c> mapStringPrimarySalesRep = new Map<String,Primary_Sales_Rep__c>();
        List<Primary_Sales_Rep__c> psrsToUpdate = new List<Primary_Sales_Rep__c>();

        for(Primary_Sales_Rep__c psr : trigger.new)
        {
            Boolean hasChanged = (trigger.isInsert) ? true : (trigger.oldMap.get(psr.Id).SF_userid__c != psr.SF_userid__c);
            Boolean nidHasChanged = (trigger.isInsert) ? true : ( !trigger.oldMap.get(psr.Id).Network_ID__c.equals( psr.Network_ID__c ) );

            if(psr.SF_userid__c != null && hasChanged)
            {
                referencedUserIds.add(psr.SF_userid__c);
                psrsToUpdate.add(psr);
            }

            if(psr.Network_ID__c != null && nidHasChanged)
            {
                referencedNetworkIds.add(psr.Network_ID__c);
                psrsToUpdate.add(psr);
            }

        }

        if(referencedNetworkIds.size() > 0) {
            for ( User u : [SELECT Id, Network_Id__c FROM User WHERE Network_Id__c in :referencedNetworkIds] )
            {
                    networkIdToUser.put(u.Network_Id__c.toLowerCase(), u);
                    referencedUserIds.add(u.Id);
            }
        }

        if(!psrsToUpdate.isEmpty())
        {
            Map<Id, User> userMap =  new Map<Id, User>([SELECT Id, BDM_RVP_Email__c, Dir_Email__c, Email_DMD__c,
                                                        GSM_Email__c, Pres_Email__c, TL_Email__c, Vice_President_Email__c,
                                                        ZM_SM_Email__c, name_bdm_rvp__c,
                                                        name_dir__c, name_dmd__c, name_gsm__c, name_pres__c,
                                                        name_team_lead__c, name_vp__c, name_zm_sm__c,
                                                        City, State, Country, Title, Phone, IsActive, Department,
                                                        Name, Email,Manager.Name, ManagerId,Manager.Network_Id__c
                                                        FROM User
                                                        WHERE Id IN :referencedUserIds]);

           
      // Sujitha - Changed the logic in best practice to prevent from governor limit exception.     
            for(Primary_Sales_Rep__c psr : psrsToUpdate)
            {
                if(psr.Network_Id__c != null && networkIdToUser.containskey(psr.Network_ID__c.toLowerCase()))
                {
                    psr.SF_userid__c = networkIdToUser.get(psr.Network_ID__c.toLowerCase()).Id;
                }


                if(userMap.containsKey(psr.SF_userid__c) && userMap.get(psr.SF_userid__c) != null) {
                    
                       UserService.copyUserEmailFieldsToPSR(psr, userMap.get(psr.SF_userid__c));
                       UserService.copyUserNameFieldsToPSR(psr, userMap.get(psr.SF_userid__c));
                       UserService.copyUserOtherFieldsToPSR(psr, userMap.get(psr.SF_userid__c));
                       sfUserIdSet.add(userMap.get(psr.SF_userid__c).Manager.Name);
                }
          }

          

          if(sfUserIdSet!=null && sfUserIdSet.size()>0)
            {
          for(Primary_Sales_Rep__c primarySalesRepRecd : [Select Id,Name from Primary_Sales_Rep__c where Name IN : sfUserIdSet])
            {
                mapStringPrimarySalesRep.put(primarySalesRepRecd.Name,primarySalesRepRecd);

            }
          }


         for(Primary_Sales_Rep__c psr : psrsToUpdate)
           {
            
               if(userMap!=null && userMap.containsKey(psr.SF_userid__c) && userMap.get(psr.SF_userid__c) != null && mapStringPrimarySalesRep!=null && mapStringPrimarySalesRep.containsKey(userMap.get(psr.SF_userid__c).Manager.Name))
                    {
                        
                        Primary_Sales_Rep__c primarySalesRepRecord =  mapStringPrimarySalesRep.get(userMap.get(psr.SF_userid__c).Manager.Name);
                        psr.Reports_To__c = primarySalesRepRecord.id;

                    }


                if(userMap!=null && userMap.containsKey(psr.SF_userid__c) && userMap.get(psr.SF_userid__c) != null) 
                       psr.Reports_To_Network_ID_Text__c = userMap.get(psr.SF_userid__c).Manager.Network_Id__c;
        }


           
                }
            }
      
    
    
    
        if(trigger.isUpdate && trigger.isAfter)
        {
    //    if(!System.isBatch())
        //  {
                List<Primary_Sales_Rep__c> psrsWithUpdatedEmailFields = new List<Primary_Sales_Rep__c>();
                for(Primary_Sales_Rep__c psr : trigger.new)
                {
                    Primary_Sales_Rep__c oldPsr = trigger.oldMap.get( psr.Id );
        
                    if( oldPsr.email_zm_sm__c != psr.email_zm_sm__c
                        || oldPsr.email_vp__c != psr.email_vp__c
                        || oldPsr.email_pres__c != psr.email_pres__c
                        || oldPsr.email_dir__c != psr.email_dir__c
                        || oldPsr.email_bdm_rvp__c != psr.email_bdm_rvp__c
                        || oldPsr.GSM_Email__c != psr.GSM_Email__c
                        || oldPsr.Email_TL__c != psr.Email_TL__c
                        || oldPsr.Email_DMD__c != psr.Email_DMD__c
                        )
                    {
                        psrsWithUpdatedEmailFields.add(psr);
                    }
            }
            
                PrimarySalesRepServices.updateOpportunityEmailFieldsFromPSRs(psrsWithUpdatedEmailFields);
        //}
        
    }

    if( trigger.isAfter && ( trigger.isInsert || trigger.isUpdate ) )
    {
        PrimarySalesRepServices.setPrimarySalesRepVerticalMajor(PrimarySalesRepServices.filterPrimarySalesRepWithChangeVerticals (Trigger.New, Trigger.oldMap));
        PrimarySalesRepServices.setPrimarySalesRepVerticalMinors(PrimarySalesRepServices.filterPrimarySalesRepWithChangedMinorVerticals (Trigger.New, Trigger.oldMap));
    }
}
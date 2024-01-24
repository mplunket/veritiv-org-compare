trigger Account on Account (before update, before insert, before delete, after insert, after update, after delete)
{
    if( Trigger.isBefore )
    {
        // Added by Sujitha- Auotmate to add/update ServicingDivision when division is changed
        //Set<String> serviceDivisionName = new set<String>(); // Commented out per BL-3680
        //Map<String,Servicing_Division__c> mapNameToServicingDivision = new Map<string,Servicing_Division__c>(); // Commented out per BL-3680
        if ( Trigger.isInsert )
        {
            //AccountServices.updateDivisions( Trigger.new ); // Commented out per BL-3680
            AccountServices.backupDnBQueryFields(Trigger.new);
            ULSAccountServices.setOneAccountToParentAccount( Trigger.new );
            // 
           /*SD 08/24/2021 This code is commented since this code already exists in  Account services  Divison Update
            for(Account acc : Trigger.new)
            {
                if(acc.Legacy_Division_Desc__c!=null)
                {
                    String servicingDivision = acc.Legacy_Division_Desc__c.toUpperCase();
                    serviceDivisionName.add(acc.Legacy_Division_Desc__c);
                }
                
            }
            
            List<Servicing_Division__c> servicingDivisionList = new List<Servicing_Division__c>([Select Id,Name from Servicing_Division__c where (Name!=null OR Name IN : serviceDivisionName) and Active__c = : True]);
            
            if(servicingDivisionList!=null && !servicingDivisionList.isEmpty())
            {
                for(Servicing_Division__c servicingDivisionRecd : servicingDivisionList)
                {
                    String servicingDivisionRecord = servicingDivisionRecd.Name.toUpperCase();
                    mapNameToServicingDivision.put(servicingDivisionRecord,servicingDivisionRecd);
                }
            }
            
            for(Account acc : Trigger.new)
            {
                String LegacyDivision = '';
                
                if(acc.Legacy_Division_Desc__c!=null)
                    LegacyDivision = acc.Legacy_Division_Desc__c.toUpperCase();
                
                if(acc.Legacy_Division_Desc__c!=null && mapNameToServicingDivision.containskey(LegacyDivision))
                {
                    acc.Servicing_Division__c = mapNameToServicingDivision.get(LegacyDivision).id;
                }
                
                
            }
            */
            
        }
        else if (Trigger.isUpdate)
        {
            /* // Commented out per BL-3680
       		for(Account acc : Trigger.new)
            {
                if(acc.Legacy_Division_Desc__c!=null && Trigger.oldMap.get(acc.id).Legacy_Division_Desc__c!=acc.Legacy_Division_Desc__c){
                    String servicingDivision = acc.Legacy_Division_Desc__c.toUpperCase();
                    serviceDivisionName.add(servicingDivision);
                }
                
            }
            
            List<Servicing_Division__c> servicingDivisionList = new List<Servicing_Division__c>([Select Id,Name from Servicing_Division__c where (Name!=null OR Name IN : serviceDivisionName) and Active__c = : True]);
            
            if(servicingDivisionList!=null && !servicingDivisionList.isEmpty())
            {
                for(Servicing_Division__c servicingDivisionRecd : servicingDivisionList)
                {
                    string servicingDivisionRecord = servicingDivisionRecd.Name.toUpperCase();
                    mapNameToServicingDivision.put(servicingDivisionRecord,servicingDivisionRecd);
                }
            }
            
            for(Account acc : Trigger.new)
            {
                
                String LegacyDivision = '';
                if(acc.Legacy_Division_Desc__c!=null && Trigger.oldMap.get(acc.id).Legacy_Division_Desc__c!=acc.Legacy_Division_Desc__c)
                    LegacyDivision = acc.Legacy_Division_Desc__c.toUpperCase();
                
                if(acc.Legacy_Division_Desc__c!=null && Trigger.oldMap.get(acc.id).Legacy_Division_Desc__c!=acc.Legacy_Division_Desc__c && mapNameToServicingDivision.containskey(LegacyDivision))
                    
                {
                    acc.Servicing_Division__c = mapNameToServicingDivision.get(LegacyDivision).id;
                }
                
                
            }
			*/
            
           // if(!Test.isRunningTest()){
            AccountServices.updatePrimarySalesRepFromOwnerId (Trigger.oldMap, Trigger.newMap);
            //AccountServices.updateDivisions( Trigger.oldMap, Trigger.newMap ); // Commented out per BL-3680
            AccountServices.backupAndRestoreDnBQueryFields(Trigger.oldMap, Trigger.newMap);
            WorkOrderServices.updateRelatedWorkOrderShares(Trigger.OldMap, Trigger.NewMap);
            LegalContractServices.updateRelatedLegalConShares(Trigger.OldMap, Trigger.NewMap);
           // }
            //Backlog Item-2623
            AccountServices.AddPSRToAccountTeam(Trigger.oldMap, Trigger.newMap);      
        }
        if( Trigger.isDelete ){
            AccountServices.deleteValidation(Trigger.OldMap);    
        }
            
        
    }
    else if( Trigger.isAfter )
    {
        
        if ( Trigger.isInsert )
        {
            AccountServices.setAccountVerticals( AccountServices.filterAccountsWithChangedVerticals( Trigger.new, Trigger.oldMap ) );
            List<Account> activeAccounts = AccountServices.filterOutInactiveAccounts( Trigger.new );
            
            /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed */
            // AccountTeamMemberServices.createAccountTeamMembersOnInsert( Trigger.new );
            
            ChatterServices.subscribePSRandOwnerToSObject( activeAccounts, new Map<ID,Opportunity>() );
            // Parent/Child ULS Account Association
            List<Account> ulsAccounts = ULSAccountServices.filterULSAccounts( Trigger.new );
            Map<String, List<Account>> accountNameToAccountsMap = ULSAccountServices.groupULSNameToAccounts( ulsAccounts );
             /* Commented based on Account analysis 7/28/2021
            /* ULSAccountServices.associateParentAccountToChildAccounts( accountNameToAccountsMap );
            
           /* Commented based on Account analysis 7/28/2021 also commented the method in Accountservices
             if(!AccountServices.firstRunOfMATAccountTrigger)
            {
                AccountServices.doMATActionsOnInsert(Trigger.newMap);
            }*/
            
        }
        else if ( Trigger.isUpdate )
        {
            
            //below code is for quote sharing 5/3/2021
            //Backlog Item- 2697-Quote - Visibility to quotes created by previous PS
            AccountServices.logicForQuoteSharing(trigger.oldMap, trigger.newMap, trigger.new);
                //end of quote sharing code
            AccountServices.setAccountVerticals( AccountServices.filterAccountsWithChangedVerticals( Trigger.new, Trigger.oldMap ) );
            List<Account> activeAccounts = AccountServices.filterOutInactiveAccounts( Trigger.new );
            
            // Rep update
            Map<Id, Account> accountsWithChangedFields = AccountServices.getAccountsWithUpdatedRepsOrPlan( Trigger.newMap, Trigger.oldMap );
            if( !accountsWithChangedFields.isEmpty() )
            {
                List<Opportunity> relatedOpportunitiesToUpdate = AccountServices.getRelatedOpenOpportunities( accountsWithChangedFields, Trigger.oldMap );
                if( !relatedOpportunitiesToUpdate.isEmpty() )
                {
                    AccountServices.updateOpportunities( relatedOpportunitiesToUpdate, Trigger.newMap );
                }
            }
            if(!Test.isRunningTest()){
                /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed */
                // AccountTeamMemberServices.createAccountTeamMembersOnUpdate( Trigger.new, Trigger.OldMap );
            	ChatterServices.subscribePSRandOwnerToSObject( activeAccounts, Trigger.oldMap );  
            }
            /* Commented out based on BL-3662 -- MAT no longer used
            if(!AccountServices.firstRunOfMATAccountTrigger) {
                AccountServices.doMATActionsOnUpdate(Trigger.oldMap,Trigger.newMap);
            } 
			*/
            
            //backlog Item-2260 
            AccountServices.contactOwnerAndPSRUpdate(Trigger.oldMap,Trigger.newMap);
            //Backlog Item-2623 moved to before update
            //AccountServices.AddPSRToAccountTeam(Trigger.oldMap, Trigger.newMap);  
            
        }
        
        if (Trigger.isUpdate || Trigger.isInsert){
            if (AccountServices.firstRunOfAccountPSRLinkTrigger){
                AccountServices.firstRunOfAccountPSRLinkTrigger = false;
                List<Account> accountsToUpdatePSR = AccountServices.linkPrimarySalesReps(Trigger.new);
                AccountServices.updatePrimarySalesReps(accountsToUpdatePSR);
            }
        }
    }
}
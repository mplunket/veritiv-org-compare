trigger CaseTrigger on Case (before insert,after insert, before update, after update) {


    if (trigger.isBefore)
    {
        
        
        if(trigger.isUpdate){
            
            //added recursion check for backlog 2791
            if(CaseTriggerHandler.isFirstTimeCaseTriggerBUpdate){ 
                CaseTriggerHandler.isFirstTimeCaseTriggerBUpdate = false;
                //Added by Simplus
                //remove error checking per 3188
                CaseTriggerHandler.validateCase(Trigger.oldMap, Trigger.newMap);
                //Block Cases for Inactive Acounts
                List<Case> csList = new List<Case>();
               
                for(case cs : trigger.new){ 
                    //Updated code to display data in custom description
                    if(trigger.oldMap.get(cs.id).customDescription__c != cs.customDescription__c && cs.description != null ){
                        cs.description = string.valueof(cs.description.replace('\n',''));
                    }
                }
                system.debug('Trigger.newMap ='+Trigger.newMap);
                system.debug('Trigger.oldMap ='+Trigger.oldMap);
                
                
                set<String> queueSetNames = new Set<String>();
                set<Id> ownrIds = new Set<Id>();
                system.debug('inside update');
                string userPrefix = Schema.SObjectType.User.getKeyPrefix();
                string quePrefix = Schema.SObjectType.Group.getKeyPrefix();
                for(Case cs : trigger.New){
                    if( string.valueOf(cs.ownerId).startsWith(userPrefix)){
                        ownrIds.add(cs.ownerId);
                    }else{
                        queueSetNames.add(cs.Original_Queue_Name__c);
                    }
                       csList.add(cs);
                }
            
                if(queueSetNames.size() > 0){
                    List<Fax_To_Case_Queue_Assignment__c> qList = [SELECT Id,name,Team_Lead_Email__c, Team_Lead_Name__c FROM Fax_To_Case_Queue_Assignment__c where Name in: queueSetNames];
                    if(qList.size() > 0 ){
                        Map<string, Fax_To_Case_Queue_Assignment__c> nameVsAsssignment = new Map<string,Fax_To_Case_Queue_Assignment__c>();
                        for(Fax_To_Case_Queue_Assignment__c que : qList){
                            nameVsAsssignment.put(que.name, que);
                        } 
                        
                        for(case csNew : trigger.new){
                            if(nameVsAsssignment.containsKey(csNew.Original_Queue_Name__c)){
                                csNew.Team_Lead_Name__c = nameVsAsssignment.get(csNew.Original_Queue_Name__c).Team_Lead_Name__c;
                                csNew.Team_Lead_Email__c = nameVsAsssignment.get(csNew.Original_Queue_Name__c).Team_Lead_Email__c;
                            }
                        }
                    }
                    
                }
            
                if(ownrIds.size() > 0){
                   List<User> usrList = [ Select id, name_team_lead__c, TL_Email__c from user where id in: ownrIds];
                    if(usrList.size() > 0){
                        for(case cs : trigger.new){
                            for(user us : usrList){
                                if(us.id == cs.ownerId){
                                    cs.Team_Lead_Name__c = us.name_team_lead__c;
                                    cs.Team_Lead_Email__c = us.TL_Email__c;
                                }
                            }
                        }
                    }
                }
                
                
                system.debug('Trigger.newMap ='+Trigger.newMap);
                system.debug('Trigger.oldMap ='+Trigger.oldMap);
                // Copying Owner into another User Lookup
                List<Case> filteredCases = CaseServices.filterUpdatedCaseOwner( trigger.oldMap, trigger.new );
                if( !filteredCases.isEmpty() )
                {
                    CaseServices.populateCaseFieldsUponOwnerChange( filteredCases );
                }
                if(test.isRunningTest()){}else{
                    CaseServices.createCaseTeamMembersForOldOwners(trigger.new, trigger.OldMap);
                }
                CaseNotification.caseTriggerBeforeIsRunning = true;
                RecordType inboundCaseType = CaseModel.getInboundCaseRT();
                Map<Id, List<Id>> ownerId2Cases = new Map<Id, List<Id>>();
                Map<Id, Fax_To_Case_Queue_Assignment__c> ownerId2Setting = new Map<Id, Fax_To_Case_Queue_Assignment__c>();
                system.debug('Trigger.newMap ='+Trigger.newMap);
                system.debug('Trigger.oldMap ='+Trigger.oldMap);
                for(Case c : trigger.new)
                {
                    if(c.RecordTypeId == inboundCaseType.Id && c.Is_Primary__c == null)
                    {
                        if(!ownerId2Cases.containsKey(c.OwnerId))
                            ownerId2Cases.put(c.OwnerId, new List<Id>());
    
                        List<Id> thisOwnersCases = ownerId2Cases.get(c.OwnerId);
                        thisOwnersCases.add(c.Id);
                        ownerId2Cases.put(c.OwnerId, thisOwnersCases);
                    }
                }
                    
                system.debug('Trigger.newMap ='+Trigger.newMap);
                system.debug('Trigger.oldMap ='+Trigger.oldMap);
    
                if(!ownerId2Cases.isEmpty())
                {
                    for(Fax_To_Case_Queue_Assignment__c queue : [select OwnerId, Group_Inbox_Address__c, Owner.Name, Active__c, Team_Lead_Name__c
                    from Fax_To_Case_Queue_Assignment__c
                    where OwnerId IN :ownerId2Cases.keySet()])
                    {
                        ownerId2Setting.put(queue.OwnerId, queue);
                    }
    
                    for(Id ownerId : ownerId2Cases.keySet())
                    {
                        for(Id caseId : ownerId2Cases.get(ownerId))
                        {
                            Case case2update = trigger.newMap.get(caseId);
    
                            if ( ownerId2Setting.containsKey(ownerId) )
                            {
    
                                if(ownerId2Setting.get(ownerId).Active__c)
                                    case2update.Is_Primary__c = 'TRUE';
                                else if( !ownerId2Setting.get(ownerId).Active__c)
                                    case2update.Is_Primary__c = 'FALSE';
    
                                case2update.Team_lead_name__c = ownerId2Setting.get(ownerId).Team_Lead_Name__c;
    
                                case2update.Group_Inbox_Address__c = ownerId2Setting.get(ownerId).Group_Inbox_Address__c;
    
                            }
                        }
                    }
                    system.debug('Trigger.newMap ='+Trigger.newMap);
                    system.debug('Trigger.oldMap ='+Trigger.oldMap);
                }
            } //added recursion check for backlog 2791
            
            
        }
        
        if(Trigger.isInsert)
        {
            CaseTriggerHandler.newCase = true;
            CaseTriggerHandler.caseStatusDetailBlank(Trigger.new);
            
            
            
            set<String> setEmail = new Set<string>();
            Map<String,contact> mapContactbyEmail = new Map<String,Contact>();
            for(Case caseRecd : Trigger.new)
            {
                if(caseRecd.AccountId==null && caseRecd.contactId==null && caseRecd.SuppliedEmail!=null)
                    setEmail.add(caseRecd.SuppliedEmail);
            }
            for(Contact contctRecd : [Select Id,Email,AccountId from Contact where Email IN : setEmail and Account.IsVos__c = true])
            {
                mapContactbyEmail.put(contctRecd.Email,contctRecd);
            }
            for(Case caseRecd : Trigger.new)
            {
                if(caseRecd.ContactId==null && caseRecd.SuppliedEmail!=null){
                    {
                        if(mapContactbyEmail.containsKey(caseRecd.SuppliedEmail))
                        {
                            
                        }
                    }
                }
            }
            
            CaseServices.populateCaseFieldsUponOwnerChange( trigger.new );

        }
        
    }
    
    if( trigger.isAfter )
    {    
        if(trigger.isinsert){
            //Item-3188
            //input VHQ account name
            Set<String> VHQAccName = new Set<String>{'Veritiv Headquarters'};
            //Get id of account(s)
            Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Name IN : VHQAccName]);
            list<id> caseVHQId = new list<id>();
            for (Case c: Trigger.new){
            //check if account is accountMap
                if(accountMap.containskey(c.accountid)){
                    caseVHQId.add(c.id); 
                }     
            }            
            if(caseVHQId.size()>0){
                CaseTriggerHandler.caseClearVHQOnCreate(caseVHQId);
            }
            //3188 end
        }
        if(Trigger.isUpdate){
            //test for 2791. Remove when resolved
            for(case ca:trigger.new){
                system.debug('Case Owner = '+ca.ownerid);
                system.debug('Case Status = '+ca.status);
            }
            if(CaseTriggerHandler.isFirstTimeCaseTriggerAUpdate){ //added recursion check for backlog 2791
                CaseTriggerHandler.isFirstTimeCaseTriggerAUpdate = false;
                system.debug('Trigger.newMap ='+Trigger.newMap);
                system.debug('Trigger.oldMap ='+Trigger.oldMap);
                CaseResponseTrackingServices.processCaseDurations(Trigger.newMap, Trigger.oldMap);
            }//added recursion check for backlog 2791
            
            
        }
        
        if ( !CaseNotification.caseTriggerAfterIsRunning ) {
           
        }
    }
}
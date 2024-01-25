global with sharing class UpdateCaseOwners implements Schedulable {

    global void execute(SchedulableContext context) {
    
        Set<Id> personsTakingOffIds = new Set<Id>();
        Datetime earliestOOODate = null;
        List<Out_Of_Office_Log__c> OOOAgents = [SELECT Id, Person_taking_time_off__c, Backup_Person__c, CreatedDate
                                                FROM Out_Of_Office_Log__c
                                                WHERE Start_Date_Time__c <= :system.NOW() 
                                                AND End_Date_Time__c >= :system.NOW()
                                                ORDER BY CreatedDate ASC];
        for (Out_Of_Office_Log__c OOOAgent : OOOAgents) 
        {
            personsTakingOffIds.add(OOOAgent.Person_taking_time_off__c);
            if (earliestOOODate == null || OOOAgent.CreatedDate < earliestOOODate) {
                earliestOOODate = OOOAgent.CreatedDate;
            }
        }
        System.debug('personsTakingOffIds...'+personsTakingOffIds);
        if(personsTakingOffIds.size() > 0){
            Map<Id, List<Case>> ownerToCaseMap = new Map<Id, List<Case>>();
            for (Case currentCase : [SELECT OwnerId, Id, CreatedDate, Auto_Assign_Method__c 
                                       FROM Case 
                                       WHERE OwnerId IN :personsTakingOffIds
                                       AND IsClosed = false
                                       AND CreatedDate >= :earliestOOODate]) 
            {   
                if(ownerToCaseMap.containsKey(currentCase.OwnerId)){
                  ownerToCaseMap.get(currentCase.OwnerId).add(currentCase);
                }
                else{
                  ownerToCaseMap.put(currentCase.OwnerId, new List<Case> {currentCase});	       
                }
            }
            System.debug('ownerToCaseMap...'+ownerToCaseMap);
            List<Case> casesToUpdate = new List<Case>();
            List<FeedItem> feedItemsToInsert = new List<FeedItem>();
            
            for (Out_Of_Office_Log__c OOOAgent : OOOAgents) 
            {
                
                if (OOOAgent.Backup_Person__c != null) {
                    List<Case> allCases = new List<Case>();
					if (OOOAgent.Person_taking_time_off__c != null 
                        && ownerToCaseMap.containsKey(OOOAgent.Person_taking_time_off__c)) 
                    {
                    	 allCases = ownerToCaseMap.get(OOOAgent.Person_taking_time_off__c);
                    }
                    
                    if(allCases.size() > 0){
                        System.debug('allCases...'+allCases);
                        System.debug('allCases size...'+allCases.size());
                        for (Case c : allCases) {
                            if (c.CreatedDate >= OOOAgent.CreatedDate) {
                                c.OwnerId = OOOAgent.Backup_Person__c;
                                c.Auto_Assign_Method__c = 'Out of Office Log Backup';             
                                casesToUpdate.add(c);
                                
                                FeedItem fi = new FeedItem(
                                    ParentId = c.Id, 
                                    Body='Re-assigned because owner had an active Out Of Office Log at the time the Case was open', 
                                    Type = 'TextPost'
                                );              
                                feedItemsToInsert.add(fi);
                            }
                        }
                    }
                }
            }
            System.debug('casesToUpdate...'+casesToUpdate);
            System.debug('casesToUpdate size...'+casesToUpdate.size());
            System.debug('feedItemsToInsert...'+feedItemsToInsert);
            System.debug('feedItemsToInsert.size()...'+feedItemsToInsert.size());
            if(casesToUpdate.size() > 0){
				update casesToUpdate;
            }
            if(feedItemsToInsert.size() > 0){
				insert feedItemsToInsert;   
            }
        }
    }
    
    public static void scheduleUpdateCaseOwners() {
        
        System.schedule('Case Ownership Hourly Update', '0 0 * * * ?', new UpdateCaseOwners());
    
    }

}
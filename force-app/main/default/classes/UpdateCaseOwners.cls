global with sharing class UpdateCaseOwners implements Schedulable {

    global void execute(SchedulableContext context) {
    
        List<Out_Of_Office_Log__c> OOOAgents = [SELECT Person_taking_time_off__c, Backup_Person__c, CreatedDate
            FROM Out_Of_Office_Log__c
            WHERE Start_Date_Time__c <= :system.NOW() AND 
                End_Date_Time__c >= :system.NOW()];
                
        for (Out_Of_Office_Log__c OOOAgent : OOOAgents) {
        
            if (OOOAgent.Backup_Person__c != null) {
            
                List<Case> allCases = [SELECT OwnerId, Id 
                                        FROM Case 
                                        WHERE OwnerId = :OOOAgent.Person_taking_time_off__c
                                            AND IsClosed = false
                                            AND CreatedDate >= :OOOAgent.CreatedDate];
            
                for (Case c : allCases) {
            
                    c.OwnerId = OOOAgent.Backup_Person__c;
                    c.Auto_Assign_Method__c = 'Out of Office Log Backup';
                                    
                    if (Schema.sObjectType.Case.isUpdateable()) {
                        update c;
                    }
                    
                    FeedItem fi = new FeedItem(ParentId = c.Id, 
                                        Body='Re-assigned because owner had an active Out Of Office Log at the time the Case was open', 
                                        Type = 'TextPost');
                                        
                    if (Schema.sObjectType.FeedItem.isCreateable()) {
                        insert fi;
                    }
            
                }
            }
            
        
            
            
        }
        
    
    }
    
    public static void scheduleUpdateCaseOwners() {
        
        System.schedule('Case Ownership Hourly Update', '0 0 * * * ?', new UpdateCaseOwners());
    
    }

}
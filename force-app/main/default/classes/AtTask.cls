/**
 *  @Author: Naveen Hiremath
 *  @Company: Bluewolf
 *  @Purpose: Represents core logic for AtTask Project integration 
*/


public class AtTask {
    
    public final Id oppId {
        get;
        private set;
    }
    
    public final AtTaskColumnModel columnModel {
        get;
        private set;
    }
    
    public AtTask(Id oppId) {
        this.oppId = oppId;
        
        final List<Engineered_Package_Project__c> oppProjectsAndTasks = this.lookupEngineeredPackageProjectsAndItsTasks();
        
        if(!oppProjectsAndTasks.isEmpty()) {
            this.columnModel = new AtTaskColumnModel(oppProjectsAndTasks);
        }
    }
    /* Sujitha Damidi Backlog#803
    Add 3 new fields to the VF page for Engineered Package Project object 

Billable_Project__c
Box_com_URL__c
Ship_Tracking_Number__c
*/
    
    private List<Engineered_Package_Project__c> lookupEngineeredPackageProjectsAndItsTasks() {      
        return [
            Select
                Id, 
                Name,
                Opportunity__c,
                Project_Stage__c,
                UWW_Part_Number__c,
                Planned_Completion_Date__c,
                Total_Project_Hours__c,
                Billable_Project__c,
                Box_com_URL__c,
                Ship_Tracking_Number__c,
            
                (Select 
                    Name,
                    Primary_Material__c, 
                    Planned_Completion_Date__c, 
                    Comments__c, 
                    Status__c 
                From Project_Tasks__r ORDER BY Planned_Completion_Date__c DESC) 
             From Engineered_Package_Project__c 
             Where Opportunity__c = :this.oppId
             Order By CreatedDate ASC
        ];      
    }
}
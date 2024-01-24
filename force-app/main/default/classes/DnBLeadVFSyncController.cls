public class DnBLeadVFSyncController {
    public Lead lead {get; set;}
    
    public DnBLeadVFSyncController() {
        lead = [SELECT Id, Company, Phone, Website, Street, City, 
                   State, PostalCode, Country 
                   FROM Lead 
                   WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        
    }
}
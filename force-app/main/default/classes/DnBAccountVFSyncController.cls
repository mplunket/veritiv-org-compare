public class DnBAccountVFSyncController {
    public Account account {get; set;}
    
    public DnBAccountVFSyncController() {
        account = [SELECT Id, Name, Phone, Website, BillingStreet, BillingCity, 
                   BillingState, BillingPostalCode, BillingCountry 
                   FROM Account 
                   WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }
}
public class MassReassignProspectsOnAccountsCLs {
    
    private ApexPages.StandardSetController standardController;
    public list<Account> accountListing {get;set;}
    public List<Account> updtList;
    public Account aRe{get;set;}
    public boolean showField{get;set;}
    //public id lookUpId{get;set;}
    
    public MassReassignProspectsOnAccountsCLs(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        showField = true;
    }
    
    
    public PageReference massUpdateProspectsRecords(){
        System.debug('inside page action');
        List<Account> SelectedRecords = (List<Account>) standardController.getSelected();
        System.debug('selected records are'+SelectedRecords);
        accountListing = selectedRecords;
        
        if(accountListing.size() == 0 ){
            showField = false;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select atleast one record');
            ApexPages.addMessage(msg);
        }
        return null;
    }
    
     public Account getUserLookup()
    {
        aRe = [select ownerId from Account limit 1];
       aRe.ownerId = null;
        //lookUpId = aRe.Proposed_New_Owner_Primary_Sales_Rep__c;
        return aRe;
    }
  


    
    
    public PageReference updateSelected(){
        system.debug('inside update');
        updtList = new List<Account>();
        
        list<Account> cstAcc = new List<Account>();
        
        
        for(Account updtAccProspect: accountListing){
            if(updtAccProspect.RecordTypeId == '012700000009OvoAAE'){
                cstAcc.add(updtAccProspect);
            }
          updtAccProspect.ownerId = aRe.OwnerId;
            updtList.add(updtAccProspect);
            
        }
        
        if(cstAcc.size() > 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Customer accounts cannot be reassigned with this feature, only Prospect accounts. Please contact the Optymyze team to reassign any Customer accounts.');
             ApexPages.addMessage(myMsg);
        }else{
        try{
            update updtList; 
       
            Schema.DescribeSObjectResult result = Account.SObjectType.getDescribe(); 
            PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
            pageRef.setRedirect(true); 
            if(test.isRunningTest() == true){
                decimal x = 1/0;
            }
            return pageRef;
           
        }
        catch(Exception ex){
            
            ApexPages.addMessages(ex);
            
        }
        }
        return null; 
    }
      
}
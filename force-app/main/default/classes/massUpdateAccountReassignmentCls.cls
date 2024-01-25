public with sharing class massUpdateAccountReassignmentCls {
    
    private ApexPages.StandardSetController standardController;
    public list<Account_Reassignment__c> aRListing {get;set;}
    public string NoReassignmentNeededExplanation{get;set;}
    public string ReassignmentNotes{get;set;}
    public List<Account_Reassignment__c> updtList;
    public string selectedStage{get;set;}
    //public id lookUpId{get;set;}
    public Account_Reassignment__c aRe{get;set;}
    
    public massUpdateAccountReassignmentCls(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
    }
    
    public PageReference massUpdateRecords(){
        List<Account_Reassignment__c> SelectedRecords = (List<Account_Reassignment__c>) standardController.getSelected();
        System.debug('selected records are'+SelectedRecords);
        loadAccountReassignment(SelectedRecords);
        return null;
    }
    
    private void loadAccountReassignment(List<Account_Reassignment__C> aRIds) {
        this.aRListing = [Select Id,Proposed_New_Owner_Primary_Sales_Rep__c,Reassignment_Stage__c,Reassignment_Notes__c,No_Reassignment_Needed_Explanation__c FROM Account_Reassignment__c where    
                          Id in : aRIds];  
        
    }
    public Account_Reassignment__c getproposedLookup()
    {
        aRe = [select Proposed_New_Owner_Primary_Sales_Rep__c from Account_Reassignment__c limit 1];
        //lookUpId = aRe.Proposed_New_Owner_Primary_Sales_Rep__c;
        return aRe;
    }
    
    public List<SelectOption> reassignmentStages
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Account_Reassignment__c.Reassignment_Stage__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry f : ple)
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            return options;
        }
    }
    
    
    public PageReference updateSelected(){
        system.debug('inside update');
        updtList = new List<Account_Reassignment__c>();
        for(Account_Reassignment__c updtaR: aRListing){
            updtaR.Proposed_New_Owner_Primary_Sales_Rep__c = aRe.Proposed_New_Owner_Primary_Sales_Rep__c;
            updtaR.Reassignment_Notes__c = ReassignmentNotes;
            updtaR.No_Reassignment_Needed_Explanation__c = NoReassignmentNeededExplanation;
            updtaR.Reassignment_Stage__c = selectedStage;
            updtList.add(updtaR);
            
        }
        
        try{
            update updtList; 
       
            Schema.DescribeSObjectResult result = Account_Reassignment__c.SObjectType.getDescribe(); 
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
        return null; 
    }
      
}
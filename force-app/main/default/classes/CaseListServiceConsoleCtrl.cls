public class CaseListServiceConsoleCtrl {

  public CaseListServiceConsoleCtrl() {
    if (!caseExistingViews.isEmpty()) 
      CaseFilter = caseExistingViews[0].getValue();
  }

  private String baseQuery = 'Select ID, Critical__c, CaseNumber, Status, Account.Name, AccountID, LastModifiedDate, ContactID, Contact.Name, OwnerID, Owner.Name, Specifics__c, Subject FROM Case';
   
  public String CaseFilter {get; set;}
  @TestVisible private static Integer pageSize = 10;
  @TestVisible private static Integer listViewLimit = 200;
  
  public Boolean areThereCases {
  	get {
  		return !getCases().isEmpty();
  	}
  }
  
  public static List<SelectOption> caseExistingViews {
    get {
     if (caseExistingViews == null) {
      List<Case_Custom_List_Views__c> listViews = [Select SOQL_Filter__c, Display_Name__c FROM Case_Custom_List_Views__c Order By Display_Name__c];
      caseExistingViews = new List<SelectOption>();
      for (Case_Custom_List_Views__c cs : listViews) 
        caseExistingViews.add(new SelectOption(evaluateFormulaFields(cs.SOQL_Filter__c)  + ' LIMIT ' + CaseListServiceConsoleCtrl.listViewLimit, cs.Display_Name__c));
      }
      return caseExistingViews;
    } set;
  }
  
  public static String evaluateFormulaFields(String str)
  {
  	 return str.replace('$User.ID', '\'' + UserInfo.getUserID() + '\'');
  }

  public ApexPages.StandardSetController CaseSetController {
    get{
      if(CaseSetController == null){
        if (CaseFilter != null)  {
          System.debug(LoggingLevel.INFO, 'The running query is : ' + baseQuery + ' ' + CaseFilter);
          CaseSetController = new ApexPages.StandardSetController(Database.getQueryLocator(baseQuery + ' ' + CaseFilter)); 
        }  
        else
        { 
          CaseSetController = new ApexPages.StandardSetController(new List<Case>{});
        }
        CaseSetController.setPageSize(pageSize);
      }
      return CaseSetController;
    }set;

  }

  public CaseListServiceConsoleCtrl (ApexPages.StandardSetController c) {   }

  public List<Case> getCases() {
    return (List<Case>)CaseSetController.getRecords();
  }

  public PageReference resetFilter() {
   CaseSetController = null;
   return null;
  }
}
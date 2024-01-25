public with sharing class PrimarySalesRepModel {
   
    
    public Primary_Sales_Rep__c record  {  get  {   if(record == null)  record = new Primary_Sales_Rep__c();   return record;  } set;}
    
  /*  public PrimarySalesRepModel()
    {
        
    }*/
    
    /*
    ** Get direct reports based on a single PSR record and order by Name
    ** Currently used in the Budget Allocations application
    ** *SegmentBudgetsController.cls
    */
    public static List<Primary_Sales_Rep__c> getDirectReports(Primary_Sales_Rep__c reportsTo)
    {
        System.debug(reportsTo);
        try
        {
            return [select Id, Name, Reports_To__c, SF_userid__c, SF_userid__r.IsActive from Primary_Sales_Rep__c where Reports_To__c = :reportsTo.Id
                    and (user_profile__c like 'Sales Professional - Lightning%' 
                            or user_profile__c like 'Specialist - Lightning%'
                            or Include_in_Reporting_Hierarchy__c = true)
                    and deactivated_user__c != true];
            
            
        }
        catch(Exception e) {  return new List<Primary_Sales_Rep__c>(); }
    }
    
    /*
    ** Get direct reports based on a list of PSRs
    ** Currently used in the Direct Report rollup batch job
    ** * Batch_CalculateDirectReports.cls
    */
    public static List<Primary_Sales_Rep__c> getDirectReports(Set<Id> reportsToIds)
    {
       // System.debug(reportsToIds.size());
        //System.debug(reportsToIds);
        try
        {
            List<Primary_Sales_Rep__c> drpsrs = [SELECT Id, Name, Reports_To__c, User_Profile__c, SF_UserId__c, SF_UserId__r.isActive
                                                 FROM Primary_Sales_Rep__c
                                                 WHERE Reports_To__c IN :reportsToIds];
          //  System.debug(drpsrs);
            List<Primary_Sales_Rep__c> psrs = [select Id, Name, Reports_To__c, user_Profile__c, SF_userid__c, SF_userid__r.IsActive 
                        from Primary_Sales_Rep__c 
                        where Reports_To__c in :reportsToIds AND 
                        (
                            (
                                (NOT user_profile__c LIKE '%admin%')
                                AND (NOT user_profile__c = '')
                                AND (NOT user_profile__c = null)
                            )
                            OR (Include_in_Reporting_Hierarchy__c = true)
                        )
                            AND (deactivated_user__c != true)];
            System.debug(psrs);
            return psrs;
        }
        catch(Exception e) { return new List<Primary_Sales_Rep__c>(); }
    }


}
public with sharing class SelectSegmentBudgetController {

	private Territory_Plan__c tp;
	private Boolean foundRecord;
	
	public SelectSegmentBudgetController(ApexPages.StandardController stdController)
	{	
        tp = [select Id, Fiscal_Quarter__c, Fiscal_Year__c, Primary_Sales_Rep__c, Primary_Sales_Rep__r.Reports_To__c 
				from Territory_Plan__c where Id = :stdController.getId()];
        try
        {
        	// Query for Segment Budgets - need to include
        	// or condition at end to account for those who are their own BMs
	        Segment_Budget__c sb = [select Id from Segment_Budget__c
	        						where Fiscal_Year__c = :tp.Fiscal_Year__c
	        						and Primary_Sales_Rep__c = :tp.Primary_Sales_Rep__c
	        						and (Reports_To__c = :tp.Primary_Sales_Rep__r.Reports_To__c
	        						or Reports_To__c = :tp.Primary_Sales_Rep__c)
	        						order by LastModifiedDate DESC
	        						limit 1];
	        						
			tp.Segment_Budget__c = sb.Id;
			foundRecord = true;
        }
        catch(QueryException qe)
        {
        	foundRecord = false;
        }
        
	}
	
	public PageReference cancel()
	{
		return new PageReference('/' + tp.Id);
	}
	
	public PageReference setSegmentBudget()
	{
		if(!foundRecord)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There were no Segment Budgets found for the selected time period.'));
			return null;
		}
		else
		{
			update tp;
	        return new PageReference('/' + tp.Id);
		}
	}
}
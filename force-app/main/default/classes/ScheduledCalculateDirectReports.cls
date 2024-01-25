global class ScheduledCalculateDirectReports implements Schedulable {

	global void execute(SchedulableContext sc)
	{
		Batch_CalculateDirectReports cdr = new Batch_CalculateDirectReports('Select Id from Primary_Sales_Rep__c');
		Database.executeBatch(cdr);
	}
}
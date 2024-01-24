global class SyncOpportunityRepsToAccountBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable{

	global String query;
	global String errors;
	global final String BATCH_NAME = 'Process Accounts With IRep Errors Batch Job';

	global SyncOpportunityRepsToAccountBatch()
	{
		query = AccountServices.getSyncOpportunityRepsBatchQuery();
		errors = '';
	}

	global database.querylocator start(Database.BatchableContext bc)
	{
		return Database.getQueryLocator( query );
	}

	global void execute(Database.BatchableContext bc, Sobject[] scope)
	{
		List<Account> batchedAccounts = (List<Account>)scope;
		errors += AccountServices.processAccountsFromBatch( batchedAccounts );
	}

	global void finish(Database.BatchableContext bc)
	{
		if( !errors.equals( '' ) )
		{
			AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
								FROM AsyncApexJob
								WHERE Id =:bc.getJobId()];

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			Opportunity_Rep_Sync_Email__c emailSetting = Opportunity_Rep_Sync_Email__c.getInstance();
			String sendEmailAddress;

			if( emailSetting == null )
			{
				sendEmailAddress = job.CreatedBy.Email;
			}
			else
			{
				sendEmailAddress = emailSetting.Email_Address__c;
			}

			mail.setToAddresses(new List<String> { sendEmailAddress });
			mail.setSaveAsActivity( false );
			mail.setSubject(BATCH_NAME + job.Status);

			String emailBody = BATCH_NAME + ' processed ' + job.TotalJobItems + ' batches with '+ job.NumberOfErrors + ' failures.';
			emailBody += '\n\nThe following errors occured:\n' + errors;

			mail.setPlainTextBody(emailBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}

	global void execute(SchedulableContext sc)
	{
		SyncOpportunityRepsToAccountBatch job = new SyncOpportunityRepsToAccountBatch();
		Database.executeBatch( job );
	}

}
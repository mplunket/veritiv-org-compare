global class ChatterAutoFollowBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable
{
	
	public static final String BATCH_NAME = 'Auto Follow Opportunities and Active Accounts Through Chatter';
	public String query;
	public String dateOrderField;
	global DateGetters.DateGetter dateGetter;
	global EntitySubscriptionSorters.EntitySubscriptionSorter sortPreference;
	
	global String errors = '';

	global ChatterAutoFollowBatch() { 
		dateGetter = DateGetterFactory.getDateGetter(DateGetterFactory.GETTER_LAST_MODIFIED_DATE);
		sortPreference = EntitySubscriptionSorterFactory.getEntitySubscriptionSorter(EntitySubscriptionSorterFactory.OnlyHaveOpportunities);
	}
	
	global ChatterAutoFollowBatch(DateGetters.DateGetter howToGetDateField, EntitySubscriptionSorters.EntitySubscriptionSorter howToPrioritize) {
		 dateGetter = howToGetDateField;
		 sortPreference = howToPrioritize;  
	}

	// builds dynamic query
	global database.querylocator start( Database.BatchableContext bc )
	{
		Set<Id> salesProfileIds = ChatterServices.getSalesProfileIds();
		String profileIds = ChatterServices.generateProfileFilter( salesProfileIds );
		query = 'SELECT Id FROM User WHERE IsActive = true AND ProfileId IN ' + profileIds;

		/*
		When unit-testing, the above query will result in this error:
		'No more than one executeBatch can be called from within a testmethod.
		Please make sure the iterable returned from your start method matches the
		batch size, resulting in one executeBatch invocation.'

		The below code limits the users we test to those we created during that day,
		which effectively includes the users in our unit-test.

		*/

		If (test.isRunningTest())
		{
			query += ' AND CreatedDate >= TODAY';
		}

		return Database.getQueryLocator( query );
	}

	// performs functionality from service class
	global void execute( Database.BatchableContext BC, List<User> scope )
	{
		Set<String> CLOSED_STAGE_NAMES = ChatterServices.CLOSED_STAGE_NAMES;
		
		List<Primary_Sales_Rep__c> primarySalesReps = [SELECT Id FROM Primary_Sales_Rep__c WHERE SF_userid__c IN : scope];

		String oppQuery = 'SELECT Id, Primary_Sales_Rep_Name__c, OwnerId, ' + dateGetter.getFieldName(Opportunity.SObjectType) +  ' FROM Opportunity ' +
													'WHERE (NOT StageName IN: CLOSED_STAGE_NAMES) AND (OwnerId IN :scope ' +
														'OR Primary_Sales_Rep_Name__c IN :primarySalesReps)';
														
		List<Opportunity> opportunityMatches = Database.query( oppQuery );

		String accountQuery = 'SELECT Id, Primary_Sales_Rep_Name__c, OwnerId,' + dateGetter.getFieldName(Account.SObjectType) + ' FROM Account WHERE ' 
		 + '( OwnerId IN :scope OR Primary_Sales_Rep_Name__c IN :primarySalesReps ) AND Active__c=\'Yes\'';
		
		List<Account> accountMatches = Database.query( accountQuery );
		
		List<SObject> opportunitiesAndAccounts = new List<SObject>();
		opportunitiesAndAccounts.addAll((List<SObject>) accountMatches);
		opportunitiesAndAccounts.addAll((List<SObject>) opportunityMatches);
		

		errors = ChatterServices.subscribePSRandOwnerToSObject(opportunitiesAndAccounts,dateGetter,sortPreference);
	}

	// if error, build message and send email
	global void finish( Database.BatchableContext bc )
	{
		AsyncApexJob job = [ SELECT Id, Status, NumberOfErrors,
								JobItemsProcessed, TotalJobItems,
								CreatedBy.Email
							FROM AsyncApexJob
							WHERE Id =:bc.getJobId() ];

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses( BatchServices.ERROR_EMAILS  );
		mail.setSubject( 'Batch to ' + BATCH_NAME + ' ' + job.Status );

		String emailBody = 'Batch to ' + BATCH_NAME + ' processed '
							+ job.TotalJobItems
							+ ' batches with '
							+ job.NumberOfErrors
							+ ' failures.';

		if( errors != '' )
		{
			emailBody += '\n\n\nThe following errors occured:\n' + errors;
		}

		mail.setPlainTextBody( emailBody );
		Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
	}

	// executes schedulable batch
	global void execute( SchedulableContext sc )
	{
		Database.executeBatch( new ChatterAutoFollowBatch() );
	}
}
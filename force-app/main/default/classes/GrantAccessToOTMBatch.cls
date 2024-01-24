global class GrantAccessToOTMBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable
{
	public static final String BATCH_NAME = 'Grant Edit Access Level To New Opportunity Team Members';
	public static final String DML_LIMIT_GENERIC_ERROR = 'DML Limit Met - The Batch will be re-run from this date : ';

	public static String query;
	global String errors = ''; 
	global DateTime completedDate;
	static Boolean executed = false;
	static String DML_LIMIT_ERROR;

	global GrantAccessToOTMBatch() { }

	// builds dynamic query
	global database.querylocator start( Database.BatchableContext bc )
	{
		query = 'SELECT Id, OpportunityId, TeamMemberRole, UserId, CreatedDate, LastModifiedDate FROM OpportunityTeamMember';

		Id apexClassId = [ SELECT Id FROM ApexClass WHERE Name = 'GrantAccessToOTMBatch' ][0].Id;
		List<AsyncApexJob> previousBatchJobs = BatchServices.lastSuccessfulBatch( apexClassId );

		//checks if previous batch ran successfully
		if( !BatchServices.userIdsFromOTMCS.isEmpty() )
		{
			String userIdString = BatchServices.generateFilterQueryString( BatchServices.userIdsFromOTMCS );
			query += ' WHERE UserId IN ' + userIdString;
		}
		/*
		else if( BatchServices.userIdsFromOTMCS.isEmpty() && !previousBatchJobs.isEmpty() )
		{
			DateTime completedDate = previousBatchJobs[0].CompletedDate <= OpportunityTeamMemberServices.lastRunDateCS ? previousBatchJobs[0].CompletedDate : OpportunityTeamMemberServices.lastRunDateCS;
			query += ' WHERE CreatedDate > :completedDate OR LastModifiedDate > :completedDate';
		}
		*/

		return Database.getQueryLocator( query );
	}

	// performs functionality from service class
	global void execute( Database.BatchableContext BC, List<OpportunityTeamMember> scope )
	{
		executed = true;
		System.debug('***SCOPE: ' + scope);
		
		if(completedDate == null)
			completedDate = DateTime.Now();
		
		DML_LIMIT_ERROR = DML_LIMIT_GENERIC_ERROR + completedDate.format() + '\n\n';
		
		// Call method to query for all Opportunites on OTMS
		// Call method to query for all Accounts on Opportunities
		// Call method to query for all Parent Accounts on Accounts
		Map<Opportunity, Account> oppToAccMap = OpportunityTeamMemberServices.relateOppToAcc( scope );
		
		
		
		// Update scope
		System.debug('*** Map: ' + oppToAccMap);
		for(OpportunityTeamMember otm : scope)
			System.debug('*** OTM: ' + otm);
			
		Set<OpportunityTeamMember> otmsToDelete = OpportunityTeamMemberServices.getBadOTMs( scope, oppToAccMap );
		if( !otmsToDelete.isEmpty() )
		{
			Set<OpportunityTeamMember> tempScope = new Set<OpportunityTeamMember>( scope );
			tempScope.removeAll( otmsToDelete ); 
			/* Instead of removing deleted ones here, pass otmsToDelete into a method that will create new otms for the related opps? */
			
			//delete atmsToDelte;
			errors += BatchServices.batchDeleteDMLOperation(new List<OpportunityTeamMember>( otmsToDelete ), LIMITS.getLimitDMLRows(), DML_LIMIT_ERROR);
			
			scope = new List<OpportunityTeamMember>( tempScope );
		}
		
		if(BatchServices.userIdsFromOTMCS.isEmpty())
		{
			// Iterate through OTMs filtering through createdDate or lastModifiedDate
			scope = OpportunityTeamMemberServices.filterOTMsOnDate( scope );
		}
		
		List<OpportunityTeamMember> newOTMs = OpportunityTeamMemberServices.updateOldOTMs();
		scope.addAll( newOTMs );
		
		//insert current scope of OTMs;
		errors += BatchServices.batchInsertDMLOperation(new List<OpportunityTeamMember>( newOTMs ), LIMITS.getLimitDMLRows(), DML_LIMIT_ERROR);
		
		//Adds Opportunity Share records to list of sObjects
		List<OpportunityShare> opptySharesToUpsert = OpportunityTeamMemberServices.grantEditAccessLevelToOpportunityTeamMembers( scope );
		errors += BatchServices.batchUpsertDMLOperation(opptySharesToUpsert, LIMITS.getLimitDMLRows(), DML_LIMIT_ERROR);
	}

	// if error, build message and send email
	global void finish( Database.BatchableContext bc )
	{   
		if(!executed) {
			List<OpportunityTeamMember> newOTMs = OpportunityTeamMemberServices.updateOldOTMs();
			//scope.addAll( newOTMs );
			
			//insert current scope of OTMs;
			errors += BatchServices.batchInsertDMLOperation(new List<OpportunityTeamMember>( newOTMs ), LIMITS.getLimitDMLRows(), DML_LIMIT_ERROR);
			
			//Adds Opportunity Share records to list of sObjects
			List<OpportunityShare> opptySharesToUpsert = OpportunityTeamMemberServices.grantEditAccessLevelToOpportunityTeamMembers( newOTMs );
			errors += BatchServices.batchUpsertDMLOperation(opptySharesToUpsert, LIMITS.getLimitDMLRows(), DML_LIMIT_ERROR);
		}
		
		
		AsyncApexJob job = [ SELECT Id, Status, NumberOfErrors,
								JobItemsProcessed, TotalJobItems,
								CreatedBy.Email
							FROM AsyncApexJob
							WHERE Id =:bc.getJobId() ];

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses( BatchServices.ERROR_EMAILS );
		mail.setSubject( 'Batch to ' + BATCH_NAME + ' ' + job.Status );

		String emailBody = 'Batch to ' + BATCH_NAME + ' processed '
							+ job.TotalJobItems
							+ ' batches with '
							+ job.NumberOfErrors
							+ ' failures.';
		//Clear out the last successful date custom setting if it was set
		List<Sales_Team_Batch_Run_Date__c> CSDates = [ SELECT Id FROM Sales_Team_Batch_Run_Date__c ];
			
		if( CSDates != null )
			delete CSDates;
		
		if( errors != '' )
		{
			emailBody += '\n\n\nThe following errors occured:\n' + errors;
			
			if( errors.contains( DML_LIMIT_GENERIC_ERROR ) )
			{
				//We need to reset the custom settings to the last successful date if it was set
				Sales_Team_Batch_Run_Date__c CSDate = new Sales_Team_Batch_Run_Date__c( Sales_Team_Last_Run_Date_Time__c = completedDate );
				
				try
				{
					insert CSDate;
				}
				catch (Exception ex)
				{
					emailBody += ' Error Re-Setting Date : ' + ex.getMessage();
				}
			}
		}

		mail.setPlainTextBody( emailBody );
		Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
	}

	// executes schedulable batch
	global void execute( SchedulableContext sc )
	{
		Database.executeBatch( new GrantAccessToOTMBatch() );
	}
}
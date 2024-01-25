global class GrantAccessToATMBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable
{
	public static final String BATCH_NAME = 'Grant Access Level To New Account Team Members';
	public static final String BATCH_JOBTYPE = 'BatchApex';
	public static final String DML_LIMIT_GENERIC_ERROR = 'DML Limit Met - The Batch will be re-run from this date : ';

	public static String query;
	global String errors = '';
	global DateTime completedDate;

	global GrantAccessToATMBatch() { }

	// builds dynamic query
	global database.querylocator start( Database.BatchableContext bc )
	{
		query = 'SELECT Id, AccountId, TeamMemberRole, UserId, CreatedDate, LastModifiedDate FROM AccountTeamMember'; // Account.Ownership_Change_Date__c,

		//checks if previous batch ran successfully
		if( !BatchServices.userIdsFromATMCS.isEmpty() )
		{
			String userIdString = BatchServices.generateFilterQueryString( BatchServices.userIdsFromATMCS );
			query += ' WHERE UserId IN ' + userIdString;
		}

		return Database.getQueryLocator( query );
	}

	// performs functionality from service class
	global void execute( Database.BatchableContext BC, List<AccountTeamMember> scope )
	{
		if(completedDate == null)
			completedDate = DateTime.Now();
		 
		String DML_LIMIT_ERROR = DML_LIMIT_GENERIC_ERROR + completedDate.format() + '\n\n';
		
		// Update Scope here.
		Set<AccountTeamMember> atmsToDelete = AccountTeamMemberServices.getBadATMs( scope );
		if( !atmsToDelete.isEmpty() )
		{
			Set<AccountTeamMember> tempScope = new Set<AccountTeamMember>( scope );
			tempScope.removeAll( atmsToDelete ); 
			
			//delete atmsToDelte;
			errors += BatchServices.batchDeleteDMLOperation(new List<AccountTeamMember>( atmsToDelete ), LIMITS.getLimitDMLRows(), DML_LIMIT_ERROR);
			
			scope = new List<AccountTeamMember>( tempScope );
		}
		
		if(BatchServices.userIdsFromATMCS.isEmpty())
		{
			// Iterate through ATMs filtering through createdDate or lastModifiedDate
			scope = AccountTeamMemberServices.filterATMsOnDate( scope );
		}
			
		//Adds Account Share records to list of sObjects
		List<AccountShare> accountShares = AccountTeamMemberServices.grantAccessLevelToStandardObjects( scope );
		
		errors += BatchServices.batchUpsertDMLOperation(accountShares, LIMITS.getLimitDMLRows(), DML_LIMIT_ERROR);
		//errors += BatchServices.batchUpsertDMLOperation(accountShares, 2, DML_LIMIT_ERROR);

		//Adds Account Plan Share records to list of sObjects
		List<Account_Plan__Share> accountPlanShares = AccountTeamMemberServices.grantAccessLevelToAccountPlans( scope );
		
		errors += BatchServices.batchInsertDMLOperation(accountPlanShares, LIMITS.getLimitDMLRows(), DML_LIMIT_ERROR);
		//errors += BatchServices.batchInsertDMLOperation(accountPlanShares, 2, DML_LIMIT_ERROR);
        
		//Adds Quote Share records to list of sObjects
		List<Quote__Share> quoteShares = AccountTeamMemberServices.grantAccessLevelToQuotes( scope );
		
		errors += BatchServices.batchInsertDMLOperation(quoteShares, LIMITS.getLimitDMLRows(), DML_LIMIT_ERROR);
		//errors += BatchServices.batchInsertDMLOperation(quoteShares, 2, DML_LIMIT_ERROR);
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
		mail.setToAddresses( BatchServices.ERROR_EMAILS );
		mail.setSubject( 'Batch to ' + BATCH_NAME + ' ' + job.Status );

		String emailBody = 'Batch to ' + BATCH_NAME + ' processed '
							+ job.TotalJobItems
							+ ' batches with '
							+ job.NumberOfErrors
							+ ' failures.';

		//Clear out the last successful date custom setting if it was set
		List<ATM_Batch_Run_Date__c> CSDates = [ SELECT Id FROM ATM_Batch_Run_Date__c ];
			
		if( CSDates != null )
			delete CSDates;
		
		if( errors != '' )
		{
			emailBody += '\n\n\nThe following errors occured:\n' + errors;
			
			if( errors.contains( DML_LIMIT_GENERIC_ERROR ) )
			{
				//We need to reset the custom settings to the last successful date if it was set
				ATM_Batch_Run_Date__c CSDate = new ATM_Batch_Run_Date__c( Last_Run_Date_Time__c = completedDate );
				
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
		Database.executeBatch( new GrantAccessToATMBatch() );
	}
}
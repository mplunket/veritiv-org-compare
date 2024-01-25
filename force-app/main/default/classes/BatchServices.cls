public class BatchServices
{
	public static final String EDIT = 'Edit'; 
	
	public static String[] ERROR_EMAILS
	{
		get
		{
			if( ERROR_EMAILS == null )
			{
				ERROR_EMAILS = new String[]{};
				for( Read_Write_Batch_Job_Email_List__c email : Read_Write_Batch_Job_Email_List__c.getAll().values() )
				{
					ERROR_EMAILS.add( email.Email_Address__c );
				}
			}
			return ERROR_EMAILS;
		}
		private set;
	}
	
	/**
	* Pulls user Ids from custom setting and puts into Set<Id>
	*/
	public static Set<Id> userIdsFromATMCS
	{
		get
		{
			if( userIdsFromATMCS == null )
			{
				userIdsFromATMCS = new Set<Id>();
				for( ATM_Batch_Specific_Users__c user : ATM_Batch_Specific_Users__c.getAll().values() )
				{
					userIdsFromATMCS.add( user.UserID__c );
				}
			}
			return userIdsFromATMCS;
		}
		private set;
	}

	/**
	* Pulls user Ids from custom setting and puts into Set<Id>
	*/
	public static Set<Id> userIdsFromOTMCS
	{
		get
		{
			if( userIdsFromOTMCS == null )
			{
				userIdsFromOTMCS = new Set<Id>();
				for( Sales_Team_Batch_Specific_Users__c user : Sales_Team_Batch_Specific_Users__c.getAll().values() )
				{
					userIdsFromOTMCS.add( user.UserID__c );
				}
			}
			return userIdsFromOTMCS;
		}
		private set;
	}
	
	public static String generateFilterQueryString( Set<Id> userIds )
	{
		String filter = '(';
		for( Id userId : userIds )
		{
			filter += '\'' + userId + '\',';
		}
		filter = filter.subString( 0, filter.length()-1 );
		filter += ')';

		return filter;
	}
	
	public static List<AsyncApexJob> lastSuccessfulBatch( Id apexClassId )
	{
		return [ SELECT CompletedDate
					FROM AsyncApexJob
					WHERE ApexClassID = :apexClassId
						AND Status = 'Completed'
						AND JobType = 'BatchApex'
						AND NumberOfErrors = 0
					ORDER BY CompletedDate DESC ];
	}
	
	public class DatabaseResults {
		private final Integer UPSERT_RESULT = 1;
		private final Integer SAVE_RESULT = 2;
		
		Object listDatabaseResults;
		Integer instanceType;
		
		/*
		Precondition: listUpsertOrSaveResult must be a list of Database.SaveResult or Database.UpsertResult
		*/
		public DatabaseResults(Object listUpsertOrSaveResult)
		{
			listDatabaseResults = listUpsertOrSaveResult;
			if(listDatabaseResults instanceOf List<Database.SaveResult>)
			{
				instanceType = SAVE_RESULT;
			}
			else if(listDatabaseResults instanceOf List<Database.UpsertResult>)
			{
				instanceType = UPSERT_RESULT;
			}
		}
		
		public Integer size()
		{
			if(instanceType==SAVE_RESULT)
			{
				return ((List<Database.SaveResult>)listDatabaseResults).size();
			}
			else if(instanceType==UPSERT_RESULT)
			{
				return ((List<Database.UpsertResult>)listDatabaseResults).size();
			}
			
			return -1;
			
		}
		
		public boolean isSuccess(Integer index)
		{
			if(instanceType==SAVE_RESULT)
			{
				return ((List<Database.SaveResult>)listDatabaseResults)[ index ].isSuccess();
			}
			else if(instanceType==UPSERT_RESULT)
			{
				return ((List<Database.UpsertResult>)listDatabaseResults)[ index ].isSuccess();
			}
			
			return false;
		}
		
		public List<Database.Error> getErrors(Integer index)
		{
			if(instanceType==SAVE_RESULT)
			{
				return ((List<Database.SaveResult>)listDatabaseResults)[ index ].getErrors();
			}
			else if(instanceType==UPSERT_RESULT)
			{
				return ((List<Database.UpsertResult>)listDatabaseResults)[ index ].getErrors();
			}
			
			return null;
		}
	}
	
	/*
	If necessary, truncate a list of records such that a DML operation can be performed on the list without causing a limits error
	Returns true iff list is truncated.
	*/
	private static Boolean truncateListBasedOnDMLLimit(List<sObject> recordsToUpdate, Integer dmlLimit)
	{
		if( recordsToUpdate.size() >= dmlLimit
				&& dmlLimit > 0 )
			{
				//We truncate the list to the size of the limit
				while( recordsToUpdate.size() > dmlLimit )
				{
					recordsToUpdate.remove( recordsToUpdate.size() - 1 );
				}
			
				return true;
			}
			else if( dmlLimit == 0)
			{
				//We have exhausted the dml limit, record the error and return
				recordsToUpdate.clear();
				return true;
			}
		return false;
	}
	
	public static String getDMLErrorString(DatabaseResults saveResults, List<SObject> recordsToUpdate)
	{
		String dmlErrors = '';
		for( Integer index = 0; index < saveResults.size(); index++ ){
			if( !saveResults.isSuccess(index) ){
				String error = '';
				for( Database.Error errorObject : saveResults.getErrors(index) ){
					error += '\t\t' + errorObject.getMessage() + '\n';
				}
				dmlErrors += 'For ' + recordsToUpdate[index] + ', ' + error + '\n';
			}
		}
		return dmlErrors;
	}
	
	/*
	The below Batch DML Operations are designed to account for the two following cases
	1) There is a limit on how many records salesforce DML operations can process. We want to process as many records as we can, and leave the other records unprocessed. 
	2) If any records fail, we want to make sure that the other records in the specified list will go through
	*/
	
	public static String batchInsertDMLOperation( List<sObject> recordsToUpdate, Integer dmlLimit, String errorMessage)
	{
		String dmlErrors = '';
		Boolean didTruncate = truncateListBasedOnDMLLimit(recordsToUpdate,dmlLimit);
		if(didTruncate)
			dmlErrors += errorMessage;
		if( !recordsToUpdate.isEmpty() )
		{
			DatabaseResults saveResults = new DatabaseResults(Database.insert( recordsToUpdate, false ));
			dmlErrors += getDMLErrorString(saveResults,recordsToUpdate);
		} 
		
		return dmlErrors;	
	}
	
	public static String batchUpsertDMLOperation( List<sObject> recordsToUpdate, Integer dmlLimit, String errorMessage)
	{
		String dmlErrors = '';
		Boolean didTruncate = truncateListBasedOnDMLLimit(recordsToUpdate,dmlLimit);
		if(didTruncate)
			dmlErrors += errorMessage;
		if( !recordsToUpdate.isEmpty() )
		{
			DatabaseResults saveResults = new DatabaseResults(Database.upsert( recordsToUpdate, false ));
			dmlErrors += getDMLErrorString(saveResults,recordsToUpdate);
		} 
		
		return dmlErrors;	
	}
	
	public static String batchDeleteDMLOperation( List<sObject> recordsToDelete, Integer dmlLimit, String errorMessage)
	{
		String dmlErrors = ''; 
		Boolean didTruncate = truncateListBasedOnDMLLimit(recordsToDelete,dmlLimit);
		if(didTruncate)
			dmlErrors += errorMessage;
		if( !recordsToDelete.isEmpty() )
		{
			try
			{
				DatabaseResults saveResults = new DatabaseResults(Database.delete( recordsToDelete, false ));
				dmlErrors += getDMLErrorString(saveResults,recordsToDelete);
			}
			catch(Exception ex)
			{
				dmlErrors += ex;
			}
		} 
		
		return dmlErrors;	
	}
	
	/**
	* Performs DML Operation on a large list of sObjects
	* returns an error string if the defined limit is exceeded
	*/
	/*
	public static String dmlOperation ( List<sObject> recordsToUpdate, String operationToPerform, Integer dmlLimit, String errorMessage)
	{
		String dmlErrors = '';
		
		Boolean didTruncate = truncateListBasedOnDMLLimit(recordsToUpdate,dmlLimit);
		if(didTruncate)
			dmlErrors += errorMessage;
			
		if( !recordsToUpdate.isEmpty() )
		{
			DatabaseResults saveResults;
			
			
			if( operationToPerform == 'upsert')
				saveResults = new DatabaseResults(Database.upsert( recordsToUpdate, false ));
			else if( operationToPerform == 'insert' )
				saveResults = new DatabaseResults(Database.insert( recordsToUpdate, false ));
			
			dmlErrors += getDMLErrorString(saveResults,recordsToUpdate);
			
			
		} 
		
		return dmlErrors;
		
	}*/
}
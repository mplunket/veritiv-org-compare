public without sharing class AccountTeamMemberServicesWithoutSharing {
	
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
	@TestVisible 
	static void insertAccountTeamMembersWithShares( List<AccountTeamMember> atmsToInsert, Map<Id, Account> accountsToAttachErrors )
	{
		//Question - How does safeDML handle rollback scenarios?
		//Need to include limit services checks here
	
		if( atmsToInsert.isEmpty() )
			return;
			
		try{
			
			SafeDML atmRecordsToInsert = new SafeInsert();
			ErrorHandling.AddErrorsToTriggerNew errorHandling = new ErrorHandling.AddErrorsToTriggerNew( accountsToAttachErrors,'AccountID' );
			atmRecordsToInsert.queue( atmsToInsert, errorHandling );
			atmRecordsToInsert.doDML();
			
			if(!errorHandling.areThereErrors())
			{
				List<AccountShare> shares = AccountTeamMemberServices.grantAccessLevelToStandardObjectsForValidAccountTeamMembers( atmsToInsert );
				
				SafeDML acctShareRecordsToInsert = new SafeInsert();
				acctShareRecordsToInsert.queue( shares, errorHandling );
				//System.assert(false, 'List Size --> '+ shares.size()+' Size to insert --> ' + acctShareRecordsToInsert.getQueueSize() + ' Threshold --> ' + LimitServices.DML_ROWS_THRESHOLD + ' Rows so far ' + Limits.getDMLRows() );
				LimitServices.checkDMLRowsLimit( acctShareRecordsToInsert.getQueueSize() );
				acctShareRecordsToInsert.doDML();
			}
				
		}
		catch( LimitServices.CloseToDMLRowsLimitException except )
		{
			//If we hit the dml limit exception
			//we simply let the batch take care of the
			//AccountShare records
		}
		
	}
	*/
	
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
	public static void createAccountTeamMembers( List<Account> accounts, Map<Id,Account> oldAccountMap )
	{
		//If the custom settings don't exist, then there is no need for this functionality to run
		if( AccountTeamMemberServices.managerFieldToTeamRole.isEmpty() )
			return;
		//ATM Creation
		List<Account> reQueriedAccounts = AccountTeamMemberServices.queryAccountManagerInformationFromAccounts ( accounts );
		Map<ID, Set<String>> accountsToFields = AccountTeamMemberServices.filterAccountsWithModifiedUsers( reQueriedAccounts, oldAccountMap );
		List<AccountTeamMember> atmsToInsert = AccountTeamMemberServices.getAtmsToInsert(AccountTeamMemberServices.createAccountTeamMembersFromAccountManagerFields ( accountsToFields, reQueriedAccounts ));
		insertAccountTeamMembersWithShares( atmsToInsert, new Map<Id,Account>( accounts ) );
		
	}
	*/
}
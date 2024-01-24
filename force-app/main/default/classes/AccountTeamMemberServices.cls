public with sharing class AccountTeamMemberServices
{
	public static String ACCOUNT_NAME = 'Account';
	public static String ACCOUNT_PLANS_NAME = 'Account Plans';
	public static String CASES_NAME = 'Cases';
	public static String OPPORTUNITY_NAME = 'Opportunity';
	public static String QUOTES_NAME = 'Quotes';

	public static String READ_ONLY_LEVEL = 'Read';
	public static String READ_WRITE_LEVEL = 'Read/Write';
	static final String PSR_USER_RELATIONSHIP_FIELD = 'SF_UserID__c';
	static final String PSR_USER_ACTIVE_RELATIONSHIP_FIELD = 'SF_UserID__r.IsActive';
	
	public static final String NATIONAL_ACCOUNT_MANAGER_ROLE = 'National Accts Manager';

	/**
	* Pulls DateTime from ATM Batch Run Date custom setting
	*/
	public static DateTime lastRunDateCS
	{
		get
		{
			if( lastRunDateCS == null )
			{
				ATM_Batch_Run_Date__c CSDate = ATM_Batch_Run_Date__c.getInstance();
				
				if( CSDate == null || CSDate.Last_Run_Date_Time__c == null )
				{
					lastRunDateCS = DateTime.now();
				}
				else
				{
					lastRunDateCS = CSDate.Last_Run_Date_Time__c;
				}
				
			}
			return lastRunDateCS;
		}
		private set;
	}

	/**
	* Pulls relationship name and access level from custom setting and puts into Map<String, String>
	*/
	public static Map<String, String> relationshipToAccessLevel
	{
		get
		{
			if( relationshipToAccessLevel == null )
			{
				relationshipToAccessLevel = new Map<String, String>();
				for( Grant_Access_Level_ATM__c atmToAccessLvl : Grant_Access_Level_ATM__c.getAll().values() )
				{
					relationshipToAccessLevel.put( atmToAccessLvl.Name, atmToAccessLvl.Access_Level__c );
				}
			}
			return relationshipToAccessLevel;
		}
		private set;
	}
	
	/**
	* Pulls managerFieldName and Team Rolel from custom setting and puts into Map<String, String>
	*/
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
	public static Map<String, String> managerFieldToTeamRole
	{
		get
		{
			if( managerFieldToTeamRole == null )
			{
				managerFieldToTeamRole = new Map<String, String>();
				for( ATM_with_Roles__c manFieldNameToTeamRolel : ATM_with_Roles__c.getAll().values() )
				{
					managerFieldToTeamRole.put( manFieldNameToTeamRolel.Name, manFieldNameToTeamRolel.Team_Role__c );
				}
			}
			return managerFieldToTeamRole;
		}
		private set;
	}
	*/
    
	/**
	* Pulls managerFieldName and Team Rolel from custom setting and puts into Map<String, String>
	*/
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
	public static Map<String, String> managerFieldToRelationShipField
	{
		get
		{
			if( managerFieldToRelationShipField == null )
			{
				managerFieldToRelationShipField = new Map<String, String>();
				for( String managerField : managerFieldToTeamRole.keySet() )
				{
					managerFieldToRelationShipField.put( managerField, managerField.replace('__c', '__r.') );
				}
			}
			return managerFieldToRelationShipField;
		}
		private set;
	}
	*/


	/**
	* Retrieves Account Ids from Account Team Members
	*/
	private static Set<Id> getAccountIds( List<AccountTeamMember> atms )
	{
		Set<Id> accountIds = new Set<Id>();
		for( AccountTeamMember anATM : atms )
		{
			accountIds.add( anATM.AccountId );
		}
		return accountIds;
	}

	/**
	* Retrieves User Ids from Account Team Members
	*/
	private static Set<Id> getUserIds( List<AccountTeamMember> atms )
	{
		Set<Id> userIds = new Set<Id>();
		for( AccountTeamMember anATM : atms )
		{
			userIds.add( anATM.UserId );
		}
		return userIds;
	}

	public static Set<AccountTeamMember> getBadATMs( List<AccountTeamMember> atms ) 
	{
		Set<AccountTeamMember> badATMs = new Set<AccountTeamMember>();
		
		Set<Id> accountIds = Pluck.Ids('AccountId', atms);
		//List<Account> atmAccounts = [SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds];
		List<Account> childAccts = [Select Id, ParentId, Parent.OwnerId, Parent.National_Account__c From Account Where Id IN :accountIds];
		//List<Account> parentAccts = [Select Id, OwnerId, (Select Id, ParentId From ChildAccounts) From Account Where Id IN: Pluck.ids('ParentId', childAccts)];
		//Set<Id> accountOwnerIds = Pluck.Ids('OwnerId', atmAccounts);
		
		for(AccountTeamMember atm : atms)
		{
			for(Account acc : childAccts)
			{
				if( acc.ParentId != NULL && atm.AccountId == acc.Id )
				{
					if( acc.Parent.OwnerId != NULL && ((atm.TeamMemberRole ==  NATIONAL_ACCOUNT_MANAGER_ROLE && atm.UserId != acc.Parent.OwnerId ) ) )
					{
						badATMs.add( atm );
						break;
					}
				}
			}
			
		}
		
		return badATMs; 
	}
	
	public static List<AccountTeamMember> filterATMsOnDate(List<AccountTeamMember> atms)
	{
		List<AccountTeamMember> filteredATMs = new List<AccountTeamMember>();
		
		Id apexClassId = [ SELECT Id FROM ApexClass WHERE Name = 'GrantAccessToATMBatch' ][0].Id; 
		List<AsyncApexJob> previousBatchJobs = BatchServices.lastSuccessfulBatch( apexClassId );
		
		DateTime completedDate = DateTime.Now();
		if( previousBatchJobs.isEmpty())
		{
			return atms;
		}
		else
		{
			completedDate = previousBatchJobs[0].CompletedDate <= AccountTeamMemberServices.lastRunDateCS ? previousBatchJobs[0].CompletedDate : AccountTeamMemberServices.lastRunDateCS;
		}
		
		for( AccountTeamMember atm : atms)
		{
			
			if( atm.CreatedDate > completedDate || atm.LastModifiedDate > completedDate ) //atm.Account.Ownership_Change_Date__c > completedDate )
			{
				filteredATMs.add( atm );
			}
		}
		
		return filteredATMs;
	}

	/**
	* Grants Access Level to Standard Objects such as Cases, Opportunities
	* returns List of AccountShares
	*/
	public static List<AccountShare> grantAccessLevelToStandardObjects( List<AccountTeamMember> accountTeamMembers )
	{
		List<AccountShare> sharesToUpdate = new List<AccountShare>();

		Set<Id> accountIdsFromATM = getAccountIds( accountTeamMembers );
		Set<Id> userIdsFromATM = getUserIds( accountTeamMembers );

		Map<Id, Account> associatedAccounts = new Map<Id, Account>( [ SELECT Id, OwnerId FROM Account WHERE Id IN :accountIdsFromATM ] );
		List<User> associatedUsers = [ SELECT Id FROM User WHERE IsActive = true AND Id IN :userIdsFromATM ];

		List<AccountShare> accountShares = [ SELECT Id, UserOrGroupId, AccountId
												FROM AccountShare
												WHERE ( AccountAccessLevel != :BatchServices.EDIT
													OR CaseAccessLevel != :BatchServices.EDIT
													OR OpportunityAccessLevel != :BatchServices.EDIT )
												AND UserOrGroupId IN :associatedUsers
												AND AccountId IN :accountIdsFromATM ];

		for( AccountShare acctShare : accountShares )
		{
			Account associatedAcct = associatedAccounts.get( acctShare.AccountId );
			if( associatedAcct.OwnerId != acctShare.UserOrGroupId )
			{
				setAccessForAccountShareRecord(acctShare);
				sharesToUpdate.add( acctShare );
			}
		}

		return sharesToUpdate;
	}

	public static List<AccountShare> grantAccessLevelToStandardObjectsForValidAccountTeamMembers( List<AccountTeamMember> accountTeamMembers )
	{
		List<AccountShare> sharesToUpdate = new List<AccountShare>();
		for(AccountTeamMember atm : accountTeamMembers)
		{
			AccountShare acctShare = new AccountShare(UserOrGroupID=atm.UserID, AccountID=atm.AccountID);
			setAccessForAccountShareRecord(acctShare);
			sharesToUpdate.add(acctShare);
		}
		return sharesToUpdate;
	}

	public static void setAccessForAccountShareRecord ( AccountShare accountShareToGrantAccess )
	{
		//String accountAccessLevel = relationshipToAccessLevel.get( ACCOUNT_NAME );
		//String caseAccessLevel = relationshipToAccessLevel.get( CASES_NAME );
		//String opptyAccessLevel = relationshipToAccessLevel.get( OPPORTUNITY_NAME );
		accountShareToGrantAccess.AccountAccessLevel = BatchServices.EDIT;
		accountShareToGrantAccess.CaseAccessLevel = BatchServices.EDIT;
		accountShareToGrantAccess.OpportunityAccessLevel = BatchServices.EDIT;
	}

	/**
	* * Grants Access Level to Account Plans
	* returns List of sObjects that holds Account_Plan__Share records
	*/
	public static List<Account_Plan__Share> grantAccessLevelToAccountPlans( List<AccountTeamMember> accountTeamMembers )
	{
		List<Account_Plan__Share> sharesToInsert = new List<Account_Plan__Share>();

		if( !relationshipToAccessLevel.isEmpty() )
		{
			Set<Id> userIds = getUserIds( accountTeamMembers );
			Set<Id> accountIds = getAccountIds( accountTeamMembers );
			Map<Id, Account> associatedAccounts = new Map<Id, Account> ( [ SELECT Id,
																				( SELECT Id, OwnerId FROM Account_Plan__r )
																			FROM Account
																			WHERE Id IN :accountIds ] );
			Set<Id> accountPlanIds = new Set<Id>();
			for( AccountTeamMember anATM : accountTeamMembers )
			{
				Account associatedAcct = associatedAccounts.get( anATM.AccountId );
				for( Account_Plan__c anAP : associatedAcct.Account_Plan__r )
				{
					accountPlanIds.add( anAP.Id );
				}
			}

			//Lets create a map if hash -> share
			//This will help us determine wheter the user
			//already has access to a specific quote
			//Hash format -- QuoteId:UserId
			Map<String, Account_Plan__Share> accountPlanIdUserHashToaccountPlanShare = new Map<String, Account_Plan__Share>();
			
			for(Account_Plan__Share foundShare: [ SELECT Id, ParentId, UserOrGroupId 
										  FROM Account_Plan__Share 
										  WHERE ParentId 
										  IN :accountPlanIds 
										  AND UserOrGroupId 
										  IN :userIds ])
			{
				accountPlanIdUserHashToaccountPlanShare.put(foundShare.ParentId + ':' + foundShare.UserOrGroupId, foundShare);
			}
			
				Map<Id, User> associatedUsers = new Map<Id, User>( [ SELECT Id, IsActive FROM User WHERE Id IN :userIds ] );

				for( AccountTeamMember anATM : accountTeamMembers )
				{
					Account associatedAcct = associatedAccounts.get( anATM.AccountId );
					for( Account_Plan__c anAP : associatedAcct.Account_Plan__r )
					{
						User aUser = associatedUsers.get( anATM.UserId );
						
						String hash = anAP.Id + ':' + aUser.Id;
						
						if( aUser.IsActive
							&& anAP.OwnerId != aUser.Id
							&& !accountPlanIdUserHashToaccountPlanShare.containsKey(hash) )
						{
							Account_Plan__Share acctPlanShare = new Account_Plan__Share( UserOrGroupId = anATM.UserId, ParentId = anAP.Id );
							String accessLevel = relationshipToAccessLevel.get( ACCOUNT_PLANS_NAME );
							setAccessLevelToCustomObject( (sObject)acctPlanShare, accessLevel );
							sharesToInsert.add( acctPlanShare );
						}
					}
				}
		}

		return sharesToInsert;
	}

	/**
	* Grants Access Level to Quotes
	* returns List of sObjects that holds Quote__Share records
	*/
	public static List<Quote__Share> grantAccessLevelToQuotes( List<AccountTeamMember> accountTeamMembers )
	{
		List<Quote__Share> sharesToInsert = new List<Quote__Share>();

		if( !relationshipToAccessLevel.isEmpty() )
		{
			Set<Id> userIds = getUserIds( accountTeamMembers );
			Set<Id> accountIds = getAccountIds( accountTeamMembers );
			
			Map<Id, Account> associatedAccounts = new Map<Id, Account> ( [ SELECT Id,
																				( SELECT Id, OwnerId FROM Quotes__r )
																			FROM Account
																			WHERE Id IN :accountIds ] );
			Set<Id> quoteIds = new Set<Id>();
			for( AccountTeamMember anATM : accountTeamMembers )
			{
				Account associatedAcct = associatedAccounts.get( anATM.AccountId );
				for( Quote__c aQuote : associatedAcct.Quotes__r )
				{
					quoteIds.add( aQuote.Id );
				}
			}
			//Lets create a map if hash -> share
			//This will help us determine wheter the user
			//already has access to a specific quote
			//Hash format -- QuoteId:UserId
			Map<String, Quote__Share> quoteIdUserHashToquoteShare = new Map<String, Quote__Share>();
			
			for(Quote__Share foundShare: [ SELECT Id, ParentId, UserOrGroupId 
										  FROM Quote__Share 
										  WHERE ParentId 
										  IN :quoteIds 
										  AND UserOrGroupId 
										  IN :userIds ])
			{
				quoteIdUserHashToquoteShare.put(foundShare.ParentId + ':' + foundShare.UserOrGroupId, foundShare);
			}

				Map<Id, User> users = new Map<Id, User>( [ SELECT Id, IsActive FROM User WHERE Id IN :userIds ] );

				for( AccountTeamMember anATM : accountTeamMembers )
				{
					Account associatedAcct = associatedAccounts.get( anATM.AccountId );
					User associatedUser = users.get( anATM.UserId );
					for( Quote__c aQuote : associatedAcct.Quotes__r )
					{
						String hash = aQuote.Id + ':' + associatedUser.Id;
						 
						if( associatedUser.IsActive
							&& aQuote.OwnerId != associatedUser.Id
							&& !quoteIdUserHashToquoteShare.containsKey(hash) )
						{
							Quote__Share quoteShare = new Quote__Share( UserOrGroupId = anATM.UserId, ParentId = aQuote.Id );
							String accessLevel = relationshipToAccessLevel.get( QUOTES_NAME );
							setAccessLevelToCustomObject( (sObject)quoteShare, accessLevel );
							sharesToInsert.add( quoteShare );
						}
					}
				}
		}

		return sharesToInsert;
	}

	/**
	* Sets Access Level to Standard Objects such as Cases, Opportunities.
	* returns AccountShare with CaseAccessLevel and OpportunityAccessLevel set.
	*/
	private static void setAccessLevelToCustomObject( sObject shareObj, String accessLvl )
	{
		if( shareObj instanceof Account_Plan__Share || shareObj instanceof Quote__Share )
		{
			if( accessLvl == READ_ONLY_LEVEL )
			{
				shareObj.put('AccessLevel', READ_ONLY_LEVEL);
			}
			else if( accessLvl == READ_WRITE_LEVEL )
			{
				shareObj.put('AccessLevel', BatchServices.EDIT);
			}
		}
	}
	
	/**
	 * Return a map of account ID to fields. 
	 * Fields returned match the following criteria:
	 * 1) The field value is a qualifying PSR. A PSR qualifies if it links to an active user that is not the owner of the respective account.
	 * 2) The field value has been modified.
	 * Precondition:
	 * 1) Each account in accounts includes the PSR relationship fields that pertains to the respective users.
	*/
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
	@TestVisible 
	public static Map<ID, Set<String>> filterAccountsWithModifiedUsers(List<Account> accounts, Map<ID, Account> oldAccountMap)
	{
		Map<Id, Set<String>> accountIdToQualifyingManagerFields = new Map<Id, Set<String>>();
		
		for( String managerFieldtoCheck : managerFieldToTeamRole.keySet() )
		{
			String managerRelationShipField = managerFieldtoCheck.replace('__c', '__r.');
			
			String psrIsActiveField = managerRelationShipField + PSR_USER_ACTIVE_RELATIONSHIP_FIELD;
			String psrOwnerField = managerRelationShipField + PSR_USER_RELATIONSHIP_FIELD;
			
			for(Account incomingAccount : accounts )
			{
				Account oldAccount = oldAccountMap == null ? null : oldAccountMap.get( incomingAccount.Id );
				
				if( !accountIdToQualifyingManagerFields.containsKey( incomingAccount.Id ) )
					accountIdToQualifyingManagerFields.put( incomingAccount.Id, new Set<String>() );
				
				//If this is a qualifiying psr manager
				if( managerFieldIsModified( managerFieldtoCheck, incomingAccount, oldAccount ) 
					&& managerFieldIsQualified( psrIsActiveField, psrOwnerField, incomingAccount ) )
				{
					accountIdToQualifyingManagerFields.get( incomingAccount.Id ).add( managerFieldtoCheck );
				}
			}
		}
		
		return accountIdToQualifyingManagerFields;
	}
	*/

	/* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
	static boolean managerFieldIsModified( String managerField, Account newAccount, Account oldAccount )
	{
		String newAccountManagerField = (String) BluewolfDevUtils.getFieldValue( newAccount, managerField);
		String oldAccountManagerField = oldAccount == null ? null : ( String ) BluewolfDevUtils.getFieldValue( oldAccount, managerField);

		return !String.IsBlank( newAccountManagerField ) && ( newAccountManagerField != oldAccountManagerField );
	}
	*/
	
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
	static boolean managerFieldIsQualified( String psrIsActiveField, String psrOwnerField, Account newAccount )
	{		
		Id newAccountManagerUserId = (Id) BluewolfDevUtils.getFieldValue( newAccount, psrOwnerField);
		Boolean isManagerActive = newAccountManagerUserId == null ? false : (Boolean) BluewolfDevUtils.getFieldValue( newAccount, psrIsActiveField);
		Id accountOwnerField = newAccount.OwnerId;

		return isManagerActive && ( newAccountManagerUserId != accountOwnerField );
	}
	*/
	
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
	@TestVisible 
	public static List<AccountTeamMember> createAccountTeamMembersFromAccountManagerFields ( Map<Id, Set<String>> accountIdToQualifyingManagerFields, List<Account> accounts )
	{
		List<AccountTeamMember> teamMembersToCreate = new List<AccountTeamMember>();
		
		Map<Id, Account> accountsMap = new Map<Id, Account>( accounts );
		
		for( Id accountId : accountIdToQualifyingManagerFields.keySet() )
		{
			for( String validManagerField : accountIdToQualifyingManagerFields.get( accountId ) )
			{
				String validManagerRelationshipField = managerFieldToRelationShipField.get( validManagerField );
				String psrUserField = validManagerRelationshipField + PSR_USER_RELATIONSHIP_FIELD;
				
				AccountTeamMember newATM = new AccountTeamMember();
				
				newATM.AccountId = accountId;
				newATM.UserId = (Id) BluewolfDevUtils.getFieldValue( accountsMap.get( accountId ), psrUserField);
				newATM.TeamMemberRole = (String)  managerFieldToTeamRole.get( validManagerField );
				
				teamMembersToCreate.add( newATM );
			}
		}
		
		return teamMembersToCreate;
	}
	*/

    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
	@TestVisible 
	public static List<Account> queryAccountManagerInformationFromAccounts ( List<Account> incomingAccounts )
	{
		List<Account> accountsWithManagerInformation = new List<Account>();
		
		if( !incomingAccounts.isEmpty() )
		{
			String query = 'Select Id, OwnerId, {0} From Account where Id in :incomingAccounts';
			
			Set<String> managerAndRelatedFieldsSet = new Set<String>();
			
			for( String managerFieldtoCheck : managerFieldToTeamRole.keySet() )
			{
				String managerRelationShipField = managerFieldToRelationShipField.get( managerFieldtoCheck );
				
				String psrIsActiveField = managerRelationShipField + PSR_USER_ACTIVE_RELATIONSHIP_FIELD;
				String psrOwnerField = managerRelationShipField + PSR_USER_RELATIONSHIP_FIELD;
				
				managerAndRelatedFieldsSet.addAll( new Set<String> {managerFieldtoCheck, psrIsActiveField, psrOwnerField} );
			}
			
			String queryManagerString = String.join(new List<String>( managerAndRelatedFieldsSet ),',');
			
			query = String.format( query, new List<String>{queryManagerString} );
			
			accountsWithManagerInformation = database.query( query );
		}
	
		return accountsWithManagerInformation;
	}
	*/
	
	/* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
	public static void createAccountTeamMembersOnInsert( List<Account> accounts )
	{
		AccountTeamMemberServicesWithoutSharing.createAccountTeamMembers( accounts, null );
	}

	public static void createAccountTeamMembersOnUpdate( List<Account> accounts, Map<Id,Account> oldAccountMap )
	{
		AccountTeamMemberServicesWithoutSharing.createAccountTeamMembers( accounts, oldAccountMap );
	}
	*/
	
	/**
	 *  Given a list of ATMs, return ATMS such that for each combination of userID and accountID of atmsToConsider, 
	 *  there is one and just one ATM in the returned list 
	 */
    /* Commented out based on BL-3661 -- part of 3PL/VLS no longer needed
	public static List<AccountTeamMember> getAtmsToInsert(List<AccountTeamMember> atmsToConsider) 
	{
		Set<String> encounteredUserAccountHashes = new Set<String>();
		
		List<AccountTeamMember> atmsToReturn = new List<AccountTeamMember>();
		
		for(AccountTeamMember atm : atmsToConsider)
		{
			if( !encounteredUserAccountHashes.contains( atm.AccountID+';'+atm.UserId ) )
			{
				atmsToReturn.add( atm );
				encounteredUserAccountHashes.add( atm.AccountID+';'+atm.UserId );
			}
		}
		
		return atmsToReturn;
	}
	*/
	
	
}
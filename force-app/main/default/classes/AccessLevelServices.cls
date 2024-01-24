public with sharing class AccessLevelServices
{
	public static Set<Id> retrieveAccountIds( List<sObject> sObjs )
	{
		Set<Id> accountIds = new Set<Id>();
		for( sObject sObj : sObjs )
		{
			if( sObj instanceof Account_Plan__c )
			{
				accountIds.add( ( ( Account_Plan__c ) sObj ).Account__c );
			}
			else if( sObj instanceof Quote__c )
			{
				accountIds.add( ( ( Quote__c ) sObj ).Account__c );
			}
		}

		return accountIds;
	}

	public static void grantAccountPlanAccessToATMs( Map<Id, Account_Plan__c> accountPlansMap )
	{
		Set<Id> accountIds = retrieveAccountIds( accountPlansMap.values() );

		Map<Id, Account> accounts = new Map<Id, Account>( [  SELECT Id,
																( SELECT UserId FROM AccountTeamMembers
																  WHERE User.IsActive = true )
															FROM Account WHERE Id IN :accountIds ] );

		Map<Id, List<Account_Plan__c>> acctIdToAccountPlans = new Map<Id, List<Account_Plan__c>>();
		for( Account_Plan__c acctPlan : accountPlansMap.values() )
		{
			Account associatedAccount = accounts.get( acctPlan.Account__c );
			if( !acctIdToAccountPlans.containsKey( associatedAccount.Id ) )
			{
				acctIdToAccountPlans.put( associatedAccount.Id, new List<Account_Plan__c>{ acctPlan } );
			}
			acctIdToAccountPlans.get( associatedAccount.Id ).add( acctPlan );
		}

		List<Account_Plan__Share> acctPlanSharesToInsert = new List<Account_Plan__Share>();
		for( Account acct : accounts.values() )
		{
			for( AccountTeamMember atm : acct.AccountTeamMembers )
			{
				List<Account_Plan__c> accountPlans = acctIdToAccountPlans.get( acct.Id );
				for( Account_Plan__c acctPlan : accountPlans )
				{
					if( atm.UserId != acctPlan.OwnerId )
					{
						Account_Plan__Share acctPlanShare = new Account_Plan__Share( UserOrGroupId = atm.UserId, ParentId = acctPlan.Id );
						String accessLevel = AccountTeamMemberServices.relationshipToAccessLevel.get( AccountTeamMemberServices.ACCOUNT_PLANS_NAME );
						if( accessLevel == AccountTeamMemberServices.READ_ONLY_LEVEL )
						{
							acctPlanShare.AccessLevel = AccountTeamMemberServices.READ_ONLY_LEVEL;
						}
						else if( accessLevel == AccountTeamMemberServices.READ_WRITE_LEVEL )
						{
							acctPlanShare.AccessLevel = BatchServices.EDIT;
						}
						acctPlanSharesToInsert.add( acctPlanShare );
					}
				}
			}
		}
		try
		{
			insert acctPlanSharesToInsert;
		}
		catch( DMLException ex )
		{
			handleDMLException( ex, acctPlanSharesToInsert, accountPlansMap );
		}
	}

	public static List<Account_Plan__Share> getAccountPlanAccessLevelToRemove( Map<Id, Account_Plan__c> acctPlansWithOldAcctMap )
	{
		Set<Id> accountIds = retrieveAccountIds( acctPlansWithOldAcctMap.values() );

		return [ SELECT Id, ParentId
					FROM Account_Plan__Share
					WHERE UserOrGroupId
						IN ( SELECT UserId FROM AccountTeamMember WHERE AccountId IN :accountIds )
							AND ParentId IN :acctPlansWithOldAcctMap.values()
							AND RowCause != 'Owner' ];
	}

	public static void grantAccessForMigratedAccountPlans( Map<Id, Account_Plan__c> newAccountPlansMap, Map<Id, Account_Plan__c> oldAccountPlansMap )
	{
		List<Account_Plan__c> acctPlansWithNewAcct = new List<Account_Plan__c>();
		List<Account_Plan__c> acctPlansWithOldAcct = new List<Account_Plan__c>();

		for( Account_Plan__c acctPlan : newAccountPlansMap.values() )
		{
			Account_Plan__c oldAcctPlan = oldAccountPlansMap.get( acctPlan.Id );
			if( oldAcctPlan != null && ( acctPlan.Account__c != oldAcctPlan.Account__c ) )
			{
				if( acctPlan.Account__c != null )
				{
					acctPlansWithNewAcct.add( acctPlan );
				}
				if( oldAcctPlan.Account__c != null )
				{
					acctPlansWithOldAcct.add( oldAcctPlan );
				}
			}
		}
		List<Account_Plan__Share> accountPlanSharesToRemove = getAccountPlanAccessLevelToRemove( new Map<Id, Account_Plan__c> ( acctPlansWithOldAcct ) );
		try
		{
			delete accountPlanSharesToRemove;
		}
		catch( DMLException ex )
		{
			handleDMLException( ex, accountPlanSharesToRemove, newAccountPlansMap );
		}
		grantAccountPlanAccessToATMs( new Map<Id, Account_Plan__c> ( acctPlansWithNewAcct ) );
	}

	public static void grantQuoteAccessToATMs( Map<Id, Quote__c> quotesMap )
	{
		Set<Id> accountIds = retrieveAccountIds( quotesMap.values() );

		Map<Id, Account> accounts = new Map<Id, Account>( [  SELECT Id,
																( SELECT UserId FROM AccountTeamMembers 
																  WHERE User.IsActive = true )
															FROM Account WHERE Id IN :accountIds ] );

		Map<Id, List<Quote__c>> acctIdToQuotes = new Map<Id, List<Quote__c>>();
		for( Quote__c aQuote : quotesMap.values() )
		{
			Account associatedAccount = accounts.get( aQuote.Account__c );
			if( !acctIdToQuotes.containsKey( associatedAccount.Id ) )
			{
				acctIdToQuotes.put( associatedAccount.Id, new List<Quote__c>{ aQuote } );
			}
			acctIdToQuotes.get( associatedAccount.Id ).add( aQuote );
		}

		List<Quote__Share> quoteSharesToInsert = new List<Quote__Share>();
		for( Account acct : accounts.values() )
		{
			for( AccountTeamMember atm : acct.AccountTeamMembers )
			{
				List<Quote__c> quotes = acctIdToQuotes.get( acct.Id );
				for( Quote__c aQuote : quotes )
				{
					if( atm.UserId != aQuote.OwnerId )
					{
						Quote__Share quoteShare = new Quote__Share( UserOrGroupId = atm.UserId, ParentId = aQuote.Id );
						String accessLevel = AccountTeamMemberServices.relationshipToAccessLevel.get( AccountTeamMemberServices.QUOTES_NAME );
						if( accessLevel == AccountTeamMemberServices.READ_ONLY_LEVEL )
						{
							quoteShare.AccessLevel = AccountTeamMemberServices.READ_ONLY_LEVEL;
						}
						else if( accessLevel == AccountTeamMemberServices.READ_WRITE_LEVEL )
						{
							quoteShare.AccessLevel = BatchServices.EDIT;
						}
						quoteSharesToInsert.add( quoteShare );
					}
				}
			}
		}
		try
		{
			insert quoteSharesToInsert;
		}
		catch( DMLException ex )
		{
			handleDMLException( ex, quoteSharesToInsert, quotesMap );
		}
	}

	public static List<Quote__Share> getQuoteAccessLevelToRemove( Map<Id, Quote__c> quotesWithOldAcctMap )
	{
		Set<Id> accountIds = retrieveAccountIds( quotesWithOldAcctMap.values() );

		return [ SELECT Id, ParentId
					FROM Quote__Share
					WHERE UserOrGroupId
						IN ( SELECT UserId FROM AccountTeamMember WHERE AccountId IN :accountIds )
							AND ParentId IN :quotesWithOldAcctMap.values()
							AND RowCause != 'Owner' ];
	}

	public static void grantAccessForMigratedQuotes( Map<Id, Quote__c> newQuotesMap, Map<Id, Quote__c> oldQuotesMap )
	{
		List<Quote__c> quotesWithNewAcct = new List<Quote__c>();
		List<Quote__c> quotesWithOldAcct = new List<Quote__c>();

		for( Quote__c aQuote : newQuotesMap.values() )
		{
			Quote__c oldQuote = oldQuotesMap.get( aQuote.Id );
			if( oldQuote != null && ( aQuote.Account__c != oldQuote.Account__c ) )
			{
				if( aQuote.Account__c != null )
				{
					quotesWithNewAcct.add( aQuote );
				}
				if( oldQuote.Account__c != null )
				{
					quotesWithOldAcct.add( oldQuote );
				}
			}
		}
		List<Quote__Share> quoteSharesToRemove = getQuoteAccessLevelToRemove( new Map<Id, Quote__c> ( quotesWithOldAcct ) );
		try
		{
			delete quoteSharesToRemove;
		}
		catch( DMLException ex )
		{
			handleDMLException( ex, quoteSharesToRemove, newQuotesMap );
		}
		grantQuoteAccessToATMs( new Map<Id, Quote__c> ( quotesWithNewAcct ) );
	}

	public static void handleDMLException( DMLException ex, List<sObject> shareObjects, Map<Id, sObject> regObjects )
	{
		for( Integer i = 0; i < ex.getNumDml(); i++ )
		{
			sObject shareWithError = shareObjects[ ex.getDmlIndex(i) ];
			if( shareWithError instanceof Account_Plan__Share )
			{
				Account_Plan__c acctPlanWithError = (Account_Plan__c)regObjects.get( ( ( Account_Plan__Share ) shareWithError ).ParentId );
				acctPlanWithError.addError( 'For ' + shareWithError.Id + ' the following error has occurred : ' + ex.getDmlMessage(i) );
			}
			else
			{
				Quote__c quoteWithError = (Quote__c)regObjects.get( ( ( Quote__Share ) shareWithError ).ParentId );
				quoteWithError.addError( 'For ' + shareWithError.Id + ' the following error has occurred : ' + ex.getDmlMessage(i) );
			}
		}
	}
}
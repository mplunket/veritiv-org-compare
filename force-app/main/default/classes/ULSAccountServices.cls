public with sharing class ULSAccountServices
{
	public static final String ULS_ACCOUNT_TYPE = '3PL';
	public static final String ULS_STRATIFICATION = '3';

	/**
	*	Method returns a list of ULS Accounts through the Account name.
	*/
	public static List<Account> filterULSAccounts( List<Account> accountsIn )
	{
		List<Account> ulsAccounts = new List<Account>();
		for ( Account anAccount : accountsIn )
		{
			if ( anAccount.Name.contains( ULS_ACCOUNT_TYPE ) || anAccount.Segment__c == ULS_STRATIFICATION )
			{
				ulsAccounts.add( anAccount );
			}
		}

		return ulsAccounts;
	}

	/**
	*	Method groups the accounts based on their Name and returns a map of account lists
	*	with the Account name being the key.
	*/
	public static Map<String, List<Account>> groupULSNameToAccounts( List<Account> accountsIn )
	{
		Map<String, List<Account>> accountNameToAccounts = new Map<String, List<Account>>();
		for( Account anAccount : accountsIn )
		{
			String accountName = generalizeAccountName( anAccount.Name );
			if( accountName != '' )
			{
				if( !accountNameToAccounts.containsKey( accountName ) )
				{
					accountNameToAccounts.put( accountName, new List<Account>() );
				}
				accountNameToAccounts.get( accountName ).add( anAccount );
			}
		}

		return accountNameToAccounts;
	}

	public static String generalizeAccountName( String accountName )
	{
		String generalizedAccountName = '';
		if( accountName.endsWith( ULS_ACCOUNT_TYPE ) && !accountName.endsWith( '-' + ULS_ACCOUNT_TYPE ) && !accountName.endsWith( '*' + ULS_ACCOUNT_TYPE ) )
		{
			generalizedAccountName = accountName;
		}
		else if( accountName.endsWith( '(' + ULS_ACCOUNT_TYPE + ')' ) && !accountName.endsWith( '-(' + ULS_ACCOUNT_TYPE + ')' ) && !accountName.endsWith( '*(' + ULS_ACCOUNT_TYPE + ')' ) )
		{
			if( !accountName.endsWith( ' (' + ULS_ACCOUNT_TYPE + ')' ) )
			{
				generalizedAccountName = ( accountName.substringBefore( '(' + ULS_ACCOUNT_TYPE + ')' ) ) + ' ' + ULS_ACCOUNT_TYPE;
			}
			else
			{
				generalizedAccountName = ( accountName.substringBefore( '(' + ULS_ACCOUNT_TYPE + ')' ) ) + ULS_ACCOUNT_TYPE;
			}
		}
		else if( accountName.endsWith( '-(' + ULS_ACCOUNT_TYPE + ')' ) || accountName.endsWith( '-' + ULS_ACCOUNT_TYPE ) )
		{
			generalizedAccountName = ( accountName.substringBefore( '-' ) ) + ' ' + ULS_ACCOUNT_TYPE;
		}
		else if( accountName.endsWith( '*(' + ULS_ACCOUNT_TYPE + ')' ) || accountName.endsWith( '*' + ULS_ACCOUNT_TYPE ) )
		{
			generalizedAccountName = ( accountName.substringBefore( '*' ) ) + ' ' + ULS_ACCOUNT_TYPE;
		}
		else
		{
			generalizedAccountName = accountName + ' ' + ULS_ACCOUNT_TYPE;
		}

		return generalizedAccountName;
	}

	private static Set<String> generateAllAccountNames( Set<String> accountNamesIn )
	{
		Set<String> accountNames = new Set<String>();
		for( String acctName : accountNamesIn )
		{
			accountNames.add( acctName.substringBefore( ' ' + ULS_ACCOUNT_TYPE ) + ' ' + ULS_ACCOUNT_TYPE );
			accountNames.add( acctName.substringBefore( ' ' + ULS_ACCOUNT_TYPE ) + '(' + ULS_ACCOUNT_TYPE + ')' );
			accountNames.add( acctName.substringBefore( ' ' + ULS_ACCOUNT_TYPE ) + ' (' + ULS_ACCOUNT_TYPE + ')' );
			accountNames.add( acctName.substringBefore( ' ' + ULS_ACCOUNT_TYPE ) + '-' + ULS_ACCOUNT_TYPE );
			accountNames.add( acctName.substringBefore( ' ' + ULS_ACCOUNT_TYPE ) + '-(' + ULS_ACCOUNT_TYPE + ')' );
			accountNames.add( acctName.substringBefore( ' ' + ULS_ACCOUNT_TYPE ) + '*' + ULS_ACCOUNT_TYPE );
			accountNames.add( acctName.substringBefore( ' ' + ULS_ACCOUNT_TYPE ) + '*(' + ULS_ACCOUNT_TYPE + ')' );
		}

		return accountNames;
	}
	
	/* Given the generalized names of 3PL account, return the name of the account without 3PL */
	private static Set<String> generateAllNakedAccountNames(Set<String> accountNamesIn)
	{
		Set<String> accountNames = new Set<String>();
		for( String acctName : accountNamesIn )
		{
			accountNames.add( acctName.substringBefore( ' ' + ULS_ACCOUNT_TYPE ));
		}
		return accountNames;
	}

	/**
	*	From the list of accounts we receive, we filter out the non ULS accounts first.
	*	Then we query for any existing ULS parent account through the names.
	*	If there are none, we simply assign the first account of every grouped ULS accounts
	*	to be the parent of the group.
	*/
	public static void setOneAccountToParentAccount( List<Account> accountsIn )
	{
		List<Account> ulsAccounts = filterULSAccounts( accountsIn );
		Map<String, List<Account>> ulsNameToAccounts = groupULSNameToAccounts( ulsAccounts );
		Map<String, Account> ulsNameToParentAccounts = generalizedMapOfParentAccounts(ulsNameToAccounts.keySet());
		
		for( String acctName : ulsNameToAccounts.keySet() )
		{
			
			if(!ulsNameToParentAccounts.containsKey(acctName))
			{
				for( Account anAccount : ulsNameToAccounts.get( acctName ) )
				{
					if( anAccount.ULS_Primary_Account__c == null && !anAccount.Is_ULS_Primary_Acct__c )
					{
						anAccount.Is_ULS_Primary_Acct__c = true;
						break;
					}
				}
			}
		}
	}
	
	/* Of the given generalized account names, find all the relevant parent accounts and return a map of the generalized name of the parent account to the parent account*/
	public static Map<String, Account> generalizedMapOfParentAccounts(Set<String> inputAccountNames)
	{
		Set<String> accountNamePermutations = generateAllAccountNames(inputAccountNames); 
		Set<String> nakedAccountNames = generateAllNakedAccountNames(inputAccountNames);

		Map<String, Account> accountNameToParentAccount = new Map<String, Account>();
		List<Account> existingParentAccounts = [ SELECT Id, Name FROM Account WHERE (Name IN :accountNamePermutations OR (Name IN :nakedAccountNames AND Segment__c =: ULS_STRATIFICATION)) AND ULS_Primary_Account__c = null AND Is_ULS_Primary_Acct__c = true AND RecordType.DeveloperName = 'Customer'];
		for( Account anAccount : existingParentAccounts )
		{
			String accountName = generalizeAccountName( anAccount.Name );
			accountNameToParentAccount.put( accountName, anAccount );
		}
		return accountNameToParentAccount;
	}

	/**
	*	From the map of lists of accounts grouped by their ULS group name, we build another
	*	map with key-value pairing of ULS group name to ULS parent account.
	*	Next, we want to associate the other ULS child accounts in each group to the correct
	*	ULS primary account. We are calling this method in the AfterInsert trigger and we want
	*	to update the child accounts with our workaround.
	*/
	public static void associateParentAccountToChildAccounts( Map<String, List<Account>> accountsMap )
	{
		Map<String, Account> accountNameToParentAccount = generalizedMapOfParentAccounts(accountsMap.keySet());
		
		List<Account> childAccountsToUpdate = new List<Account>();
		if( !accountNameToParentAccount.isEmpty() )
		{
			for( String acctName : accountsMap.keySet() )
			{
				Account parentAccount = accountNameToParentAccount.get( acctName );
				for( Account childAcct : accountsMap.get( acctName ) )
				{
					if( !childAcct.Is_ULS_Primary_Acct__c && childAcct.ULS_Primary_Account__c == null )
					{
						Account childAccount = new Account( Id = childAcct.Id, ULS_Primary_Account__c = parentAccount.Id );
						childAccountsToUpdate.add( childAccount );
					}
				}
			}

			if( !childAccountsToUpdate.isEmpty() )
			{
				try
				{
					update childAccountsToUpdate;
				}
				catch( DMLException dmlEx )
				{
					for( Integer index = 0; index < dmlEx.getNumDml(); index++ )
					{
						String accountNameWithError = childAccountsToUpdate[ dmlEx.getDmlIndex( index ) ].Name;
						List<Account> accountsWithError = accountsMap.get( accountNameWithError );
						for( Account acct : accountsWithError )
						{
							acct.addError( dmlEx.getDmlMessage( index ) );
						}
					}
				}
			}
		}
	}
}
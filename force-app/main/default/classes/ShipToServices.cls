public class ShipToServices {

	/*
		used to update the irepinfovaries checkbox on accounts as well as populate account irep and irep plan fields
		this method is used on insert and delete of shiptos
	*/
	public static void updateIRepInfoForAccounts( Map<Id, Ship_To__c> incomingShipTos )
	{
		Map<Id, List<Ship_To__c>> accountIdsToShipTos = groupShipTosByAccountId( incomingShipTos.values() );

		List<Account> accountsToUpdate = getAccountsToUpdate( accountIdsToShipTos.keySet() );

		doUpdateOnAccounts( accountsToUpdate, accountIdsToShipTos );
	}

	/*
		this method takes in a list of shiptos and groups them together in lists based on their accountIds
		used on insert and delete because it does not need to filter out accounts that may not be updated
	*/
	private static Map<Id, List<Ship_To__c>> groupShipTosByAccountId( List<Ship_To__c> shipTos )
	{
		Map<Id, List<Ship_To__c>> accountIdToShipTos = new Map<Id, List<Ship_To__c>>();

		for( Ship_To__c shipTo : shipTos )
        {
            if(shipTo.iRep__c != null){
                if( !accountIdToShipTos.containsKey( shipTo.Bill_To_Account__c ) )
                {
                    accountIdToShipTos.put( shipTo.Bill_To_Account__c, new List<Ship_To__c>() );
                }
                accountIdToShipTos.get( shipTo.Bill_To_Account__c ).add( shipTo );
            }
            
		}

		return accountIdToShipTos;
	}

	/*
		looks through the map of shiptos grouped by accountId and makes a query to find all shiptos beloning to accounts passed in
		then it looks through all the shipto records and keeps track of which ireps have been seen across shiptos for each account
		finally, create an instance of each account for update
	*/
	private static List<Account> getAccountsToUpdate( Set<Id> accountIds )
	{
		Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
		for( Account account : [ SELECT Id, iRep_Info_Varies__c, Primary_Sales_Rep_Name__c, iRep__c, iRep_Code__c,
										( SELECT Id, iRep__c, iRep_Code__c, iRep_Plan__c, iRep_Plan_Code__c FROM Ship_Tos__r ORDER BY LastModifiedDate DESC, Id DESC )
									FROM Account
									WHERE Id IN :accountIds ] )
		{
			Set<Id> iRepIds = new Set<Id>();

			// do not try to find another irep if the code and irep are already filled in
			Boolean iRepfound = account.iRep__c != null && account.iRep_Code__c != null;
            //Made changes to see this will help with trigger error
			//List<Ship_To__c> shipTosForAccount = account.getSObjects( 'Ship_Tos__r' );
			//for( Ship_To__c shipTo : shipTosForAccount )
			for( Ship_To__c shipTo : Account.Ship_Tos__r )
			{
				if( !iRepFound && account.Primary_Sales_Rep_Name__c != null
					&& shipTo.iRep__c == account.Primary_Sales_Rep_Name__c && account.iRep__c != shipTo.iRep__c )
				{
					account.iRep__c = account.Primary_Sales_Rep_Name__c;
					account.iRep_Plan__c = shipTo.iRep_Plan__c;
					account.iRep_Plan_Code__c = shipTo.iRep_Plan_Code__c;
					iRepfound = true;
					accountsToUpdate.put( account.Id, account );
				}

				iRepIds.add( shipTo.iRep__c );
			}
			if( !iRepfound )
			{
				//get the latest shipTo from the list and use that shipTos irep
				//Changed the code to see if trigger is fixed.
				//Ship_To__c tempShipTo = getLatestShipToForAccount( shipTosForAccount );
                Ship_To__c tempShipTo = getLatestShipToForAccount( Account.Ship_Tos__r);
               
				if(tempShipTo != null && account.iRep__c != tempShipTo.iRep__c)
				{
					account.iRep__c = tempShipTo.iRep__c;
					account.iRep_Plan__c = tempShipTo.iRep_Plan__c;
					account.iRep_Plan_Code__c = tempShipTo.iRep_Plan_Code__c;
					accountsToUpdate.put( account.Id, account );
				}
			}

			Boolean shipTosHaveMoreThanOneIRep = iRepIds.size() > 1;
			if( account.iRep_Info_Varies__c != shipTosHaveMoreThanOneIRep )
			{
				account.iRep_Info_Varies__c = shipTosHaveMoreThanOneIRep;
				accountsToUpdate.put( account.Id, account );
			}
		}

		return accountsToUpdate.values();
	}

	private static Ship_To__c getLatestShipToForAccount(List<Ship_To__c> allShipToForAccount)
	{
		//get the latest shipTo from this list
		for(Ship_To__c shipTo : allShipToForAccount)
		{
			if(shipTo.iRep__c != null)
				return shipTo;
		}
		return null;
	}

	/*
		executes dml for any accounts passed in, needs to take a map referencing trigger.new records for error handling
	*/
	private static void doUpdateOnAccounts( List<Account> accountsToUpdate, Map<Id, List<Ship_To__c>> accountIdToShipToMap )
	{
		if( !accountsToUpdate.isEmpty() )
		{
			try
			{
				update accountsToUpdate;
			}
			catch( System.DmlException ex )
			{
				for( Integer index = 0; index < ex.getNumDml(); index++ )
				{
					Id errorAccountId = accountsToUpdate[ ex.getDmlIndex( index ) ].Id;
					for( Ship_To__c errorShipTo : accountIdToShipToMap.get( errorAccountId ) )
					{
						errorShipTo.addError( ex.getDmlMessage( index ) );
					}
				}
			}
		}
	}
}
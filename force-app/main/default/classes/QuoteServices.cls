/**
 Objective: Noninstantiable services class that collects all
 			static SOQL service methods operating on Quote__c object
 Developer: Hiremath, Naveen - Bluewolf
*/
public with sharing class QuoteServices {

	public static Quote__c getQuote(Id quoteId) {

		return [SELECT Id,
					   Expiration_Date__c,
					   Name,
					   OwnerId,
					   Opportunity__c,
					   Print_Quote_Totals__c,
					   Promotion__c,
					   Account__r.Name,
					   Account__r.AccountNumber,
					   Account__r.RecordType.Name,
					   Customer_Contact__c,
					   Customer_Contact__r.Name,
					   Ship_To_Number__c,
					   Ship_To__c,
					   Ship_To__r.Name,
					   Ship_To__r.State__c,
					   Ship_To__r.Postal_Code__c,
					   Ship_To__r.City__c,
					   Ship_To__r.Address_Line2__c,
					   Ship_To__r.Address_Line1__c,
					   Ship_To__r.Ship_To_Code__c,
					   Ship_To_Address__c,
					   Servicing_Division__c,
					   System_Code__c,
					   Shipment_Method__c,
					   Requested_Delivery_Date__c,
					   Lost_Reason__c,
					   Last_Submitted_Timestamp__c,
					   Date_Quoted__c,
					   Comments__c,
					   PO_Number__c,
					   Number_of_Orders_Submitted__c,
					   Servicing_Division_Name__c,
					   Quote_Stage__c,
					   Quote_Type__c,
					   Primary_Merchandising_Segment__c,
					   Account_Legacy_System_Cd__c,
					   Bill_To_Number__c,
					   iRep__c,
					   Primary_Sales_Rep__c,
					   Service_Level__c,
					   End_User__c,
					   Subject__c,
					   Vendor_Comments__c,
					   Internal_Comments__c,
					   Count_of_Line_Items__c,
					   Currency__c
				FROM Quote__c
				WHERE Id = :quoteId LIMIT 1];
	}

	public static List<Quote__c> filterQuotesForPSRUpdate( Map<Id, Quote__c> oldQuotes, List<Quote__c> newQuotes )
	{
		List<Quote__c> changedQuotes = new List<Quote__c>();

		for( Quote__c incomingQuote : newQuotes )
		{
			if( oldQuotes.containsKey( incomingQuote.Id )
				&& oldQuotes.get( incomingQuote.Id ).Account__c != incomingQuote.Account__c )
			{
				changedQuotes.add( incomingQuote );
			}
		}

		return changedQuotes;
	}

	public static List<Quote__c> populatePSRAndIRepFromAccount( List<Quote__c> incomingQuotes )
	{
		List<Quote__c> quotesToModify = new List<Quote__c>();
		Set<Id> accountIds = new Set<Id>();

		for( Quote__c aQuote : incomingQuotes )
		{
			if( aQuote.Account__c != null )
			{
				accountIds.add( aQuote.Account__c );
			}
		}

		if( !accountIds.isEmpty() )
		{
			Map<Id, Account> accountsMap = new Map<Id, Account>( [ SELECT Id, Primary_Sales_Rep_Name__c, iRep__c FROM Account WHERE Id IN :accountIds ] );
			for( Quote__c aQuote : incomingQuotes )
			{
				if( accountsMap.containsKey( aQuote.Account__c ) )
				{
					aQuote.Primary_Sales_Rep__c = accountsMap.get( aQuote.Account__c ).Primary_Sales_Rep_Name__c;
					aQuote.iRep__c = accountsMap.get( aQuote.Account__c ).iRep__c;
					aQuote.Ship_To__c = null;
					aQuote.Ship_To_Address__c = null;
					aQuote.Ship_To_Account__c = null;
					quotesToModify.add( aQuote );
				}
			}
		}

		return quotesToModify;
	}

	/**
	 Suppress default constructor for noninstantiability
	*/
	private QuoteServices() { }
}
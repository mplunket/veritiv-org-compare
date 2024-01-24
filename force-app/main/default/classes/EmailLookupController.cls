public with sharing class EmailLookupController
{
	public String addressJSON {get; set;}
	public Quote__c quote {get; set;}
	
	static final String UNISOURCE_WORLDWIDE_ACCOUNT_ID = '0017000000NJvZc';
		
	public EmailLookupController()
	{
		String quoteId = ApexPages.currentPage().getParameters().get('id');
		if(quoteId != null)
		{
			quote = [SELECT Id, Account__c FROM Quote__c WHERE Id = :quoteId];
		}
		initPossibleAddresses();
	}
	
	public void initPossibleAddresses()
	{
		addressJSON = '[';

		for(Contact contact : [SELECT Id, Name, Email, AccountId, Account.Name
							 	FROM Contact
							 	WHERE (AccountId = :UNISOURCE_WORLDWIDE_ACCOUNT_ID
							 	 OR AccountId = :quote.Account__c)
							 	 AND email <> null
							 	 AND Inactive__c = false
								 ORDER BY Name LIMIT 9999])
		{
			addressJSON += '{"name" : "' + EncodingUtil.urlEncode(contact.Account.Name +': '+ contact.Name, 'UTF-8') + 
            '", "email" : "' +EncodingUtil.urlEncode(contact.Email, 'UTF-8') + '" },';
		}	
		
		//remove trailing comma
		addressJSON = addressJSON.substring(0, addressJSON.length() - 1);
	
		addressJSON += ']';
	}
	
}
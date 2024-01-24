public class QuoteModel {

	public static String WITH_FIELD_SOURCING = 'With Field Sourcing';
	public static String RETURNED_FROM_FIELD_SOURCING = 'Returned From Field Sourcing';

	public static List<Quote__c> returnQuoteToRequester(Map<Id, Quote__c> updatedQuotes, Map<Id, Quote__c> oldMap)
	{
		Set<String> merchandiserRoleNames = new Set<String>();
		Map<Id, List<Quote__c>> ownerToQuotes = new Map<Id, List<Quote__c>>();
		Map<Id, String> ownerIdToRoleName = new Map<Id, String>();
		Set<Id> newOwnerIds = new Set<Id>();
		
		for(UserRole ur : [Select Name From UserRole where Name like 'Merch -%'])
		{
			merchandiserRoleNames.add(ur.Name);
		}
		
		List<Quote__c> quotesToUpdate = new List<Quote__c>();
		
		for(Quote__c q : updatedQuotes.values())
		{
			if((q.Quote_Stage__c == WITH_FIELD_SOURCING && oldMap.get(q.Id).Quote_Stage__c == WITH_FIELD_SOURCING)
			&&
				(oldMap.get(q.Id).OwnerId != q.OwnerId))
				{
					newOwnerIds.add(q.OwnerId);
					if(!ownerToQuotes.containsKey(q.OwnerId))
						ownerToQuotes.put(q.OwnerId, new List<Quote__c>());
						
					ownerToQuotes.get(q.OwnerId).add(q);
				}
		}
		
		for(User newOwner : [select Id, Role_Name__c from User where Id in :newOwnerIds])
		{
			if(!merchandiserRoleNames.contains(newOwner.Role_Name__c))
			{
				for(Quote__c q : ownerToQuotes.get(newOwner.Id))
				{
					Quote__c newQuote = new Quote__c(Id=q.Id, Quote_Stage__c=RETURNED_FROM_FIELD_SOURCING);
					quotesToUpdate.add(newQuote);
				}	
			}
		}
		
		return quotesToUpdate;
	}

}
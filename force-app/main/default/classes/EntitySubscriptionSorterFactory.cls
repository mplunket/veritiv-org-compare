public with sharing class EntitySubscriptionSorterFactory {
	public static final String PreferOpportunitiesBeforeAnyAccounts = 'PreferOpportunitiesBeforeAnyAccounts';
	public static final String OnlyHaveOpportunities = 'OnlyHaveOpportunities';
	
	public static EntitySubscriptionSorters.EntitySubscriptionSorter getEntitySubscriptionSorter(String sortingPreference)
	{
		if(sortingPreference==PreferOpportunitiesBeforeAnyAccounts)
		{  
			return new EntitySubscriptionSorters.PreferOpportunitiesBeforeAnyAccounts();
		}
		else if(sortingPreference==OnlyHaveOpportunities)
		{
			return new EntitySubscriptionSorters.OnlyHaveOpportunities();
		}
		return null;
	}
}
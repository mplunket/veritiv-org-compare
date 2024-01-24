global with sharing class EntitySubscriptionSorters {
	
	global interface EntitySubscriptionSorter {
		List<EntitySubscription>  sortByDateGetter(List<EntitySubscription> subscriptions,  Map<ID,SObject> records, DateGetters.DateGetter dateGetter);
	}
	
	
	global class OnlyHaveOpportunities implements EntitySubscriptionSorter{
		global List<EntitySubscription> sortByDateGetter(List<EntitySubscription> subscriptions, Map<ID,SObject> records, DateGetters.DateGetter dateGetter)
		{
			List<EntitySubscription> opportunitySubs= new List<EntitySubscription>();
			for(EntitySubscription e : subscriptions)
			{
				if(ChatterServices.isOpportunity(e.ParentID))
				{
					opportunitySubs.add(e);
				}
			}
			
			List<ChatterDateTimeWrapper> wrappers = new List<ChatterDateTimeWrapper>();
			for(EntitySubscription e : opportunitySubs)
			{
				wrappers.add(new ChatterDateTimeWrapper(e,dateGetter.getDateTime(records.get(e.parentId))));
			}
			return ChatterDateTimeWrapper.getSortedListByDESCOrder(wrappers);
		}
	}
	
	global class PreferOpportunitiesBeforeAnyAccounts implements EntitySubscriptionSorter{
		global List<EntitySubscription> sortByDateGetter(List<EntitySubscription> subscriptions, Map<ID,SObject> records, DateGetters.DateGetter dateGetter)
		{
			List<ChatterDateTimeWrapper> wrappers = new List<ChatterDateTimeWrapper>();
			for(EntitySubscription e : subscriptions)
			{
				wrappers.add(new ChatterDateTimeWrapper(e,dateGetter.getDateTime(records.get(e.parentId))));
			}
			List<EntitySubscription> sortedByDateFieldList = ChatterDateTimeWrapper.getSortedListByDESCOrder(wrappers);
			
			//Now everything is sorted by date, but we must put opportunities before accounts
			
			List<EntitySubscription> opportunitySubs= new List<EntitySubscription>();
			List<EntitySubscription> accountSubs= new List<EntitySubscription>();
			for(EntitySubscription e : sortedByDateFieldList)
			{
				if(ChatterServices.isAccount(e.ParentID))
				{
					accountSubs.add(e);
				}
				else
				{
					opportunitySubs.add(e);
				}
			}
			
			List<EntitySubscription> retList = new List<EntitySubscription>();
			retList.addAll(opportunitySubs);
			retList.addAll(accountSubs);
			return retList;
		}
	}
}
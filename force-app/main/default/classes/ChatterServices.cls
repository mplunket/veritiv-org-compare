public without sharing class ChatterServices
{
	
	public static Set<String> CLOSED_STAGE_NAMES = new Set<String>{ '0- Closed Lost', '8- Closed Won' };
	private static final String OPPORTUNITY_PREFIX = Opportunity.SObjectType.getDescribe().getKeyPrefix();
	private static final String ACCOUNT_PREFIX = Account.SObjectType.getDescribe().getKeyPrefix();
	
	public static Set<String> allSalesProfiles
	{
		get
		{
			if( allSalesProfiles == null )
			{
				allSalesProfiles = new Set<String>();
				for( Chatter_Auto_Follow_Records__c aCS : Chatter_Auto_Follow_Records__c.getAll().values() )
				{
					allSalesProfiles.add( aCS.Name );

				}
			}
			return allSalesProfiles;
		}
		set;
	}

	public static Set<Id> chatterAutoFollow_Blacklist_UserIds
	{
		get
		{
			if( chatterAutoFollow_Blacklist_UserIds == NULL )
			{
				chatterAutoFollow_Blacklist_UserIds = new Set<Id>();
				for( Chatter_Auto_Follow_User_Blacklist__c aCS : Chatter_Auto_Follow_User_Blacklist__c.getAll().values() )
				{
					chatterAutoFollow_Blacklist_UserIds.add( Id.valueOf(aCS.Name) );

				}
			}
			return chatterAutoFollow_Blacklist_UserIds;
		}
		set;
	}

	public static Set<Id> getSalesProfileIds()
	{
		Set<Id> profileIds = new Set<Id>();
		List<Profile> salesProfiles = [ SELECT Id FROM Profile WHERE Name IN :allSalesProfiles ];
		for( Profile profile : salesProfiles )
		{
			profileIds.add( profile.Id );
		}

		return profileIds;
	}

	public static String generateProfileFilter( Set<Id> profileIds )
	{
		String filter = '(';
		if( profileIds != null && !profileIds.isEmpty() )
		{
			for( Id profileId : profileIds )
			{
				filter += '\'' + profileId + '\',';
			}
		}
		filter = filter.substring(0, filter.length()-1);
		filter += ')';

		return filter;
	}

	public static List<Opportunity> filterOpenOpportunities( List<Opportunity> newOpportunities )
	{
		List<Opportunity> openOpportunities = new List<Opportunity>();
		for( Opportunity oppty : newOpportunities )
		{
			if( !CLOSED_STAGE_NAMES.contains( oppty.StageName ) )
			{
				openOpportunities.add( oppty );
			}
		}

		return openOpportunities;
	}

	public static void subscribePSRandOwnerToSObject(List<SObject> newRecords, Map<ID, SObject> oldRecords)
	{
		List<EntitySubscription> insertList;
		
		try
		{
			insertList = getSubscribePSRandOwnerToSObjectList(newRecords,oldRecords);
			insert insertList;
		}
		catch ( System.Dmlexception ex )
		{
			for( Integer index = 0; index < ex.getNumDml(); index++ )
	        {
	            Id errorId = insertList[ ex.getDmlIndex( index ) ].parentId;
	            trigger.newMap.get(errorId).addError( ex.getDmlMessage( index ) );
	        }
		}
	}
	
	/*
	Use this method when processing large numbers of records..i.e in a batch, as it will account for DML Limits
	Specify the dateGetter Object that will determine which field it will orderBy
	Precondition: recordsToProcess may only include objects that have both OwnerID and Primary_Sales_Rep_Name__c field
	Returns error message
	
	*/
	public static String subscribePSRandOwnerToSObject(List<SObject> recordsToProcess, DateGetters.DateGetter dateGetter, EntitySubscriptionSorters.EntitySubscriptionSorter sortPreference)
	{
		List<EntitySubscription> insertList = getSubscribePSRandOwnerToSObjectList(recordsToProcess,new Map<ID,SObject>());
		
		insertList = sortPreference.sortByDateGetter(insertList, new Map<ID,SObject>(recordsToProcess), dateGetter);
		
		return '\n\n' + BatchServices.batchInsertDMLOperation(insertList, LIMITS.getLimitDMLRows(),'DML Limit Met - Another batch needed to finish creating some chatter subscriptions\n\n');
	}
	
	/*
	This function creates a map of all the different values found in the specified field to the set of records that have that same value in the field
	s.t. the record does not belong to oldRecords (i.e. new record) or the value in the field has changed
	*/
	public static Map<ID,Set<ID>> createMapBasedOnField(List<SObject> newRecords, Map<ID, SObject> oldRecords, String fieldName)
	{
		Map<ID,Set<ID>> mapOnFieldValue = new Map<ID,Set<ID>>();
		
		for(SObject o: newRecords)
		{
			if (!oldRecords.containsKey(o.Id) || (oldRecords.get(o.Id).get(fieldName) != o.get(fieldName)))
				{

					if(mapOnFieldValue.containsKey((ID) o.get(fieldName)))
					{
						mapOnFieldValue.get((ID) o.get(fieldName)).add(o.ID);
					}
					else
					{
						Set<ID> newRecordList = new Set<ID>();
						newRecordList.add(o.Id);
						mapOnFieldValue.put((ID) o.get(fieldName),newRecordList);
					}
				}
		}
		
		return mapOnFieldValue;
	}
	
	/*
	This function returns a Map of User IDs to a set of records that the same user is either the owner or the PSR
	s.t the record does not belong to oldRecords (i.e. new record) or either the PSR or Owner has changed
	*/
	public static Map<ID,Set<ID>> createUserToRecordsMap(List<SObject> newRecords, Map<ID, SObject> oldRecords)
	{	
		Map<ID,Set<ID>> mapToReturn;
		
		/*
			subscribeMapForUsersWhoOwnRecords is a Map of User IDs to a set of records that the same user is the owner
			    s.t the record does not belong to oldRecords (i.e. new record) or the Owner has changed
			subscribeMapForPSRsOnRecords is a Map of PSR IDs to a set of records that have the same primary sales rep
			   s.t the record does not belong to oldRecords (i.e. new record) or the PSR has changed
		*/
		Map<ID,Set<ID>> subscribeMapForUsersWhoOwnRecords = createMapBasedOnField(newRecords,oldRecords,'OwnerId'); 
		Map<ID,Set<ID>> subscribeMapForPSRsOnRecords = createMapBasedOnField(newRecords,oldRecords,'Primary_Sales_Rep_Name__c'); 
		
		/* 
			We will be basically combining both subscribeMapForUsersWhoOwnRecords and 
			subscribeMapForPSRsOnRecords. subscribeMapForUsersWhoOwnRecords is already 
			in the proper User ID to Set of Records format, so we can use that as it is, 
			but for the other map, we need to translate the PSR Id to User Ids. 
			We can use the SF_userid__c f the PSR as the new key for all the values in 
			subscribeMapForPSRsOnRecords. 
		*/
			
		mapToReturn = subscribeMapForUsersWhoOwnRecords; 
		
		List<Primary_Sales_Rep__c> psrs = [Select Id, SF_userid__c from Primary_Sales_Rep__c where Id in: subscribeMapForPSRsOnRecords.keySet() ];
		for(Primary_Sales_Rep__c p : psrs)
		{
			if(p.SF_userid__c!=null)
			{
				if(mapToReturn.containsKey(p.SF_userid__c))
				{
					mapToReturn.get(p.SF_userid__c).addAll(subscribeMapForPSRsOnRecords.get(p.Id));
				}
				else
				{
					mapToReturn.put(p.SF_userid__c,subscribeMapForPSRsOnRecords.get(p.Id));
				}
			}
		}
		
		return mapToReturn;
		
	}
	
	/*
	  Remove from our mappings any users that arent sales users (according to our custom settings), 
	  as well as users that are inactive (this will remove PSR users who are inactive)
	*/
	public static void removeInvalidUsers(Map<ID,Set<ID>> subscribeMapForUsers)
	{
		Map<Id, User> repUserInfoMap = new Map<Id, User>([Select Id, Name, Profile.Name, IsActive from User 
															where ID in :subscribeMapForUsers.keySet() AND UserRole.Name like '%Rep%' ]);
		
		for ( Id subscriberId : subscribeMapForUsers.keySet()){
			
			if (!repUserInfoMap.containsKey(subscriberId) || 
				!allSalesProfiles.contains(repUserInfoMap.get(subscriberId).Profile.Name) || 
				!repUserInfoMap.get(subscriberId).IsActive || 
				chatterAutoFollow_Blacklist_UserIds.contains(repUserInfoMap.get(subscriberId).Id))
			{
				subscribeMapForUsers.remove(subscriberId);
			}
			
		}
		
	}
	
	public static Map<ID,Set<ID>> getAlreadyExistingSubscriptionsInvolvingTheseRecordsAndUsers(Set<ID> userIds, List<SObject> records)
	{
		Set<ID> recordIds = new Set<ID>();
		for(SObject o : records)
		{
			recordIds.add(o.Id);
		}
		
		List<EntitySubscription> alreadyExistingFollows =
													[SELECT Id, parentId, subscriberId FROM EntitySubscription
													WHERE subscriberId IN : userIds
													AND parentID IN: recordIds];

		Map<ID,Set<ID>> subscriptionsAlreadyExisting = new Map<ID,Set<ID>>();
		for(ID idForUser : userIds)
		{
			subscriptionsAlreadyExisting.put(idForUser,new Set<ID>());
		}

		for(EntitySubscription e : alreadyExistingFollows)
		{
			subscriptionsAlreadyExisting.get(e.subscriberId).add(e.parentId);
		}
		
		return subscriptionsAlreadyExisting;
	}
	
	
	public static List<EntitySubscription> createEntitySubscriptionList(Map<ID,Set<ID>> subscribeMapForUsers,Map<ID,Set<ID>> subscriptionsAlreadyExisting)
	{
		List<EntitySubscription> insertList = new List<EntitySubscription>();
		
		for(Id idForUser : subscribeMapForUsers.keySet())
		{
			for(ID idForSObject : subscribeMapForUsers.get(idForUser))
			{
				if(!subscriptionsAlreadyExisting.get(idForUser).contains(idForSObject)) 
				{
					EntitySubscription e = new EntitySubscription();
					e.parentId = idForSObject;
					e.subscriberId = idForUser;
					insertList.add(e);
				} 
			}
		}
		
		return insertList;
	}
	
	/*
	When the PSR or Owner of these records changes (or the record is inserted),
	if the PSR or Owner corresponds to a Sales user as defined by a custom profile,
	then make that user(s) follow the records on chatter.

	Precondition:
		newRecords and oldRecords may only include objects that have both OwnerID and Primary_Sales_Rep_Name__c field
	
	Returns a list of entity subscriptions to insert.
	*/
	public static List<EntitySubscription> getSubscribePSRandOwnerToSObjectList(List<SObject> newRecords, Map<ID, SObject> oldRecords)
	{
		//We want to map users to appropriate records, so that we can evenutally subscribe them as such
		Map<ID,Set<ID>> subscribeMapForUsers  = createUserToRecordsMap(newRecords, oldRecords);
		
		removeInvalidUsers(subscribeMapForUsers);
		
		/*Before we insert any entity subscriptions, we have to figure out what these users are already
			subscribed to, because a duplicate submission will cause an error */
			
		Map<ID,Set<ID>> subscriptionsAlreadyExisting = getAlreadyExistingSubscriptionsInvolvingTheseRecordsAndUsers(subscribeMapForUsers.keySet(),newRecords);

		//Now actually create an entity subscription object if it doesn't already exist
		List<EntitySubscription> insertList = createEntitySubscriptionList(subscribeMapForUsers, subscriptionsAlreadyExisting); 
		return insertList;
	}
	
	/*
	TODO: MOVE THESE SOMEWHERE MORE APPROPRIATE?
	*/
	public static boolean isOpportunity(ID id)
    {
    	return ((String)id).substring(0,3)==OPPORTUNITY_PREFIX;
    }
    
    public static boolean isAccount(ID id)
    {
    	return ((String)id).substring(0,3)==ACCOUNT_PREFIX;
    }
}
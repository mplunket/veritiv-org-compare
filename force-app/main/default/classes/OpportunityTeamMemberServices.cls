public with sharing class OpportunityTeamMemberServices
{
	public static final String NATIONAL_ACCOUNT_MANAGER_ROLE = 'National Accts Manager';
	
	/**
	* Retrieves Opportunity Ids from Opportunity Team Members
	*/
	private static Set<Id> getOpportunityIds( List<OpportunityTeamMember> otmsIn )
	{
		Set<Id> opportunityIds = new Set<Id>();
		for( OpportunityTeamMember anOTM : otmsIn )
		{
			opportunityIds.add( anOTM.OpportunityId );
		}
		return opportunityIds;
	}
	
	/**
	* Retrieves User Ids from Opportunity Team Members
	*/
	private static Set<Id> getUserIds( List<OpportunityTeamMember> otmsIn )
	{
		Set<Id> userIds = new Set<Id>();
		for( OpportunityTeamMember anOTM : otmsIn )
		{
			userIds.add( anOTM.UserId );
		}
		return userIds;
	}
	
	/**
	* Pulls DateTime from OTM Batch Run Date custom setting
	*/
	public static DateTime lastRunDateCS
	{
		get
		{
			if( lastRunDateCS == null )
			{
				Sales_Team_Batch_Run_Date__c CSDate = Sales_Team_Batch_Run_Date__c.getInstance();
				
				if( CSDate == null || CSDate.Sales_Team_Last_Run_Date_Time__c == null)
				{
					lastRunDateCS = DateTime.now();
				}
				else
				{
					lastRunDateCS = CSDate.Sales_Team_Last_Run_Date_Time__c;
				}
				
			}
			return lastRunDateCS;
		}
		private set;
	}
	
	/**
	* Grants Access Level to Opportunities
	* returns List of OpportunityShares
	*/
	public static List<OpportunityShare> grantEditAccessLevelToOpportunityTeamMembers( List<OpportunityTeamMember> otmsIn )
	{
		List<OpportunityShare> sharesToUpsert = new List<OpportunityShare>();

		Set<Id> opportunityIdsFromOTM = getOpportunityIds( otmsIn );
		Set<Id> userIdsFromOTM = getUserIds( otmsIn );
		List<User> associatedUsers = [ SELECT Id FROM User WHERE IsActive = true AND Id IN :userIdsFromOTM ];
		
		List<OpportunityShare> opportunityShares = [ SELECT Id, UserOrGroupId, OpportunityId, Opportunity.OwnerId
														FROM OpportunityShare
														WHERE OpportunityAccessLevel != :BatchServices.EDIT
														AND UserOrGroupId IN :associatedUsers
														AND OpportunityId IN :opportunityIdsFromOTM ];

		for( OpportunityShare opptyShare : opportunityShares )
		{
			if( opptyShare.Opportunity.OwnerId != opptyShare.UserOrGroupId )
			{
				opptyShare.OpportunityAccessLevel = BatchServices.EDIT;
				sharesToUpsert.add( opptyShare );
			}
		}

		return sharesToUpsert;
	}
	
	/* Only return those opportunity shares which don't already exist */
	public static List<OpportunityShare> filterOutOwnerOpportunityShares(List<OpportunityShare> opportunityShares)
	{
		List<OpportunityShare> retList = new List<OpportunityShare>();
		Set<ID> oppIds = new Set<ID>();
		for(OpportunityShare os : opportunityShares)
		{
			oppIds.add(os.OpportunityID);
			
		}
		Map<Id,Opportunity> oppMap = new Map<Id,Opportunity> ([Select ID, OwnerID From Opportunity Where ID IN:oppIds]);
		for(OpportunityShare os : opportunityShares)
		{
			if(oppMap.containsKey(os.OpportunityId))
			{
				if (oppMap.get((os.OpportunityId)).OwnerID != os.UserOrGroupId)
				{
					retList.add(os);
				}
			}
		}
		return retList;
	}
	
	public static List<OpportunityTeamMember> filterOTMsOnDate(List<OpportunityTeamMember> otms)
	{
		List<OpportunityTeamMember> filteredOTMs = new List<OpportunityTeamMember>();
		
		Id apexClassId = [ SELECT Id FROM ApexClass WHERE Name = 'GrantAccessToOTMBatch' ][0].Id; 
		List<AsyncApexJob> previousBatchJobs = BatchServices.lastSuccessfulBatch( apexClassId );
		
		DateTime completedDate = DateTime.Now();
		if( previousBatchJobs.isEmpty())
		{
			return otms;
		}
		else
		{
			completedDate = previousBatchJobs[0].CompletedDate <= OpportunityTeamMemberServices.lastRunDateCS ? previousBatchJobs[0].CompletedDate : OpportunityTeamMemberServices.lastRunDateCS;
		}
		
		for( OpportunityTeamMember otm : otms)
		{
			
			if( otm.CreatedDate > completedDate || otm.LastModifiedDate > completedDate ) //atm.Account.Ownership_Change_Date__c > completedDate )
			{
				filteredOTMs.add( otm );
			}
		}
		
		return filteredOTMs;
	}
	
	public static Set<OpportunityTeamMember> getBadOTMs( List<OpportunityTeamMember> otms, Map<Opportunity, Account> oppToAcc ) 
	{
		Set<OpportunityTeamMember> badOTMs = new Set<OpportunityTeamMember>();
		
		List<Opportunity> otmOpportunities = new List<Opportunity>( oppToAcc.keySet() );
		
		for(OpportunityTeamMember otm : otms)
		{
			for(Opportunity opp : otmOpportunities)
			{
				
				Account parentAccount = oppToAcc.get(opp);
				
				if( otm.OpportunityId == opp.Id )
				{
					
					if( otm.TeamMemberRole ==  NATIONAL_ACCOUNT_MANAGER_ROLE && otm.UserId != parentAccount.OwnerId )
					{
						badOTMs.add( otm );
						break;
					}
				}
			}
			
		}
		
		return badOTMs; 
	}
	
	public static List<OpportunityTeamMember> updateOldOTMs()
	{
		List<OpportunityTeamMember> newOTMs = new List<OpportunityTeamMember>();
		
		List<Opportunity> missingOTMOpps = [SELECT Id, isClosed, AccountId, Account.ParentId, Account.Parent.OwnerId, Account.Parent.National_Account__c From Opportunity 
											WHERE 
												(Account.Parent.National_Account__c = TRUE) AND
												(isClosed = false) AND Id NOT IN 
												(SELECT OpportunityId FROM OpportunityTeamMember WHERE TeamMemberRole = :NATIONAL_ACCOUNT_MANAGER_ROLE) ];
																					
		//[SELECT Id, o.Account.OwnerId, o.AccountId From Opportunity o WHERE o.Id NOT IN (SELECT OpportunityId FROM OpportunityTeamMember WHERE TeamMemberRole != :NATIONAL_ACCOUNT_MANAGER_ROLE) ];
		
		for(Opportunity opp : missingOTMOpps)
		{
			// Add update to check for null accounts.
			
			if(opp.AccountId != NULL) // What to do if Opportunity has no direct parent account? Nothing?
			{
				if(opp.getSobject('Account').get('ParentId') != NULL) // What to do if the opportunity's parent doesn't have a parent? Nothing? Create an OTM based on that owner?
				{
					Id accOwnerId = (Id) opp.getSobject('Account').getSObject('Parent').get('OwnerId');
					newOTMs.add( new OpportunityTeamMember(UserId=accOwnerId, OpportunityId=opp.Id, TeamMemberRole=NATIONAL_ACCOUNT_MANAGER_ROLE) );
				}
			}
		}
		
		return newOTMs;
	}
	
	public static Map<Opportunity, Account> relateOppToAcc(List<OpportunityTeamMember> otms)
	{
		Map<Opportunity, Account> oppToAcc = new Map<Opportunity, Account>();
		if(otms.isEmpty()){
			return oppToAcc;
		}
		
		List<Opportunity> otmOpps = [Select Id, isClosed, AccountId From Opportunity Where Id IN: Pluck.ids('OpportunityId', otms) AND isClosed = false];
		List<Account> childAccts = [Select Id, ParentId From Account Where Id IN: Pluck.Ids('AccountId', otmOpps) ];
		List<Account> parentAccts = [Select Id, OwnerId, National_Account__c, (Select Id, ParentId From ChildAccounts) From Account Where Id IN: Pluck.ids('ParentId', childAccts)];
		
		Map<Id, Account> childAcctIdToAcct = new Map<Id, Account>(childAccts);
		Map<Id, Account> parentAcctIdToAcct = new Map<Id, Account>(parentAccts);
		
		
		for(Opportunity opp : otmOpps){
			for(Account acct : parentAccts){
				
				if( opp.AccountId != NULL && childAcctIdToAcct.get(opp.AccountId).ParentId == acct.Id){
					oppToAcc.put(opp, acct);
				}
			}
			
		}
		return oppToAcc;
	}
    
    // When adding, updating, or deleting Sales Team members to an opportunity,
    // this function looks up active team members on the opportunity and updates
    // the Active Sales Team Roles multi-select picklist (BL-3647)
    public static void calculateActiveSalesTeamRoles(Set<Id> opportunityIds) {
        
        List<String> teamRoles = OpportunityTeamMemberServices.getPicklistValues(Opportunity.Active_Sales_Team_Roles__c);
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity opp: [Select Id,(Select Id, UserId, Name, TeamMemberRole from OpportunityTeamMembers WHERE TeamMemberRole IN : teamRoles),Name from Opportunity where Id in: opportunityIds] ){
            List<String> activeRoles = new List<String>();
            for(OpportunityTeamMember teamMember : opp.OpportunityTeamMembers) {
                if(!activeRoles.contains(teamMember.TeamMemberRole)) {
                    activeRoles.add(teamMember.TeamMemberRole);
                }
            }
            opp.Active_Sales_Team_Roles__c = String.join(activeRoles, ';');
            oppsToUpdate.add(opp);
        }
        if(oppsToUpdate.size() > 0) {
            try {
                update oppsToUpdate;
            } catch(Exception e) {
                System.debug('Error updating opportunities with active team member roles.');
            }
        }
    }
    
    // Retrieves active picklist values for a given object and field
    // Example: getPicklistValues(Account.Industry)
    public static List<String> getPicklistValues(Schema.sObjectField field) {
        // Get all picklist values
        List<Schema.PicklistEntry> entries = field.getDescribe().getPickListValues();
        // Only return active picklist values
        List<String> activeEntries = new List<String>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                activeEntries.add(entry.getLabel());
            }
        }
        return activeEntries;
    }
    
}
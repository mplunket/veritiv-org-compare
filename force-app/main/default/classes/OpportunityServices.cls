public without sharing class OpportunityServices {
    
    //Updated line 3-6 on 08/21/2023 - Thunder
    public static List<Opportunity> newOpportunity = new List<Opportunity>();
    public static List<Opportunity> oldOpportunity = new List<Opportunity>();
    public static Map<Id, Opportunity> newMapOpportunity = new Map<Id, Opportunity>();
    public static Map<Id, Opportunity> oldMapOpportunity = new Map<Id, Opportunity>();
    
    
    
    
    @TestVisible
    private static final String READ_ACCESS_LEVEL = 'Read';
    @TestVisible
    private static final String ROLE_PROMO_OWNER = 'Promotion Owner';
    
    public static String OPP_ACCESS_LEVEL = READ_ACCESS_LEVEL;
    public static String OPP_TEAM_MEMBER_ROLE = ROLE_PROMO_OWNER;
    
    public static void OTMCreationFlow(Map<Id, Opportunity> oldOppsMap, List<Opportunity> newOpps)
    {
        List<Opportunity> filteredOpps = filterOnCampaignChange(oldOppsMap, newOpps);
        if( !filteredOpps.isEmpty() )
        {
            insertOTMs( createOTMFromCampaigns(filteredOpps), newOpps );
        }
    }
    
    /* Campaign and Opportunity Team Member Functionality */
    @TestVisible
    private static List<Opportunity> filterOnCampaignChange(Map<Id, Opportunity> oldOppsMap, List<Opportunity> newOpps)
    {
        List<Opportunity> changedOpps = new List<Opportunity>();
        
        if( oldOppsMap == NULL || oldOppsMap.isEmpty() )
        {
            for(Opportunity opp : newOpps)
            {
                if(opp.CampaignId != NULL)
                {
                    changedOpps.add( opp );
                }
            }
        }
        else
        {
            for(Opportunity opp : newOpps)
            {
                if(oldOppsMap.get(opp.Id).CampaignId != opp.CampaignId && opp.CampaignId != NULL)
                {
                    changedOpps.add( opp );
                }
            }
        }
        
        return changedOpps;
    }
    
    @TestVisible
    private static List<OpportunityTeamMember> createOTMFromCampaigns(List<Opportunity> newOpps)
    {
        List<OpportunityTeamMember> otmsToInsert = new List<OpportunityTeamMember>();
        List<Opportunity> queriedOpps = [SELECT Id, CampaignId, Campaign.Owner.isActive, Campaign.OwnerId FROM Opportunity WHERE Id IN: newOpps];
        
        for(Opportunity opp : queriedOpps)
        {
        	if(opp.Campaign.Owner.isActive == true) {
	            OpportunityTeamMember otm = new OpportunityTeamMember(
	                        UserId = opp.Campaign.OwnerId,
	                        OpportunityId = opp.Id,
	                        TeamMemberRole = OPP_TEAM_MEMBER_ROLE,
	                        OpportunityAccessLevel = OPP_ACCESS_LEVEL
	                    );
	            otmsToInsert.add( otm );
        	}
        }
        
        return otmsToInsert;
    }
    
    @TestVisible
    private static void insertOTMs(List<OpportunityTeamMember> otms, List<Opportunity> opps)
    {
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>(opps);
        
        try
        {
            insert otms; 
        }
        catch(Exception ex)
        {
            for(Integer i = 0; i < ex.getNumDML(); i++)
            {
                Integer errorPosition = ex.getDMLIndex(i);
                Opportunity relatedOpp = oppsMap.get(otms[errorPosition].OpportunityId);
                
                relatedOpp.addError( ex.getDMLMessage(errorPosition));
            }
        }
    }
	
	public static void updatePrimarySalesRepFromOwnerId(List<Opportunity> newOpps) {
		Id ownerId = UserInfo.getUserId();
		List<Primary_Sales_Rep__c> relatedReps = [SELECT Id, SF_UserId__c FROM Primary_Sales_Rep__c WHERE SF_UserId__c = :ownerId];

		if (relatedReps.size() > 0) {
			Primary_Sales_Rep__c psr = relatedReps[0];
			for (Opportunity opp : newOpps) {
				opp.Primary_Sales_Rep_Name__c = psr.Id;
			}
		}
	}

	public static void updatePrimarySalesRepFromOwnerId(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) {
		Set<Id> ownerIds = Pluck.ids(Schema.sObjectType.Opportunity.fields.OwnerId.getName(), newMap);
		List<Primary_Sales_Rep__c> relatedReps = [SELECT Id, SF_UserId__c FROM Primary_Sales_Rep__c WHERE SF_UserId__c IN :ownerIds];

		Map<Id, Id> userIdsToPSRId = new Map<Id, Id>();
		for (Primary_Sales_Rep__c rep : relatedReps) {
			userIdsToPSRId.put(rep.SF_UserId__c, rep.Id);
		}

		for (Id oppId : newMap.keySet()) {
			Opportunity oldOpp = oldMap.get(oppId);
			Opportunity updatedOpp = newMap.get(oppId);

			if (oldOpp.OwnerId != updatedOpp.OwnerId) {
				if (userIdsToPSRId.containsKey(updatedOpp.OwnerId)) {
					updatedOpp.Primary_Sales_Rep_Name__c = userIdsToPSRId.get(updatedOpp.OwnerId);
				}
			}
		}
	}

    //updated promotion owner to OpportunityTeamMember on 08/21/2023 - Thunder
    Public static void addSalesTeamMember(){
        List<OpportunityTeamMember> teamMembersToAdd = new List<OpportunityTeamMember>();

    // Collect Opportunity Ids with changed CampaignId and Campaign Type is "Sales Initiative"
    Map<Id, Id> opportunityIdToNewCampaignIdMap = new Map<Id, Id>();
    for (Opportunity Opp : newOpportunity) {
        Opportunity oldOpp = oldMapOpportunity.get(Opp.Id);

        if (Opp.CampaignId != oldOpp.CampaignId &&
            Opp.Campaign.Type == 'Sales Initiative') {
            opportunityIdToNewCampaignIdMap.put(Opp.Id, Opp.CampaignId);
        }
    }

    if (!opportunityIdToNewCampaignIdMap.isEmpty()) {
        // Query the related Campaigns to get their owners
        Map<Id, Campaign> campaignIdToCampaignMap = new Map<Id, Campaign>([
            SELECT Id, OwnerId FROM Campaign WHERE Id IN :opportunityIdToNewCampaignIdMap.values()
        ]);

        for (Id opportunityId : opportunityIdToNewCampaignIdMap.keySet()) {
            Id campaignId = opportunityIdToNewCampaignIdMap.get(opportunityId);
            Campaign campaign = campaignIdToCampaignMap.get(campaignId);

            if (campaign != null && campaign.OwnerId != null) {
                // Add the Campaign Owner as an Opportunity Team Member
                teamMembersToAdd.add(new OpportunityTeamMember(OpportunityId = opportunityId, UserId = campaign.OwnerId));
            }
        }

        // Insert Opportunity Team Members
        if (!teamMembersToAdd.isEmpty()) {
            insert teamMembersToAdd;
        }
    }
        
    }
}
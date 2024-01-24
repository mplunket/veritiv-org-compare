public with sharing class CampaignServices {
    
    @TestVisible
    private static final String READ_ACCESS_LEVEL = 'Read';
    @TestVisible
    private static final String ROLE_PROMO_OWNER = 'Promotion Owner';
    
    public static String OPP_ACCESS_LEVEL = READ_ACCESS_LEVEL;
    public static String OPP_TEAM_MEMBER_ROLE = ROLE_PROMO_OWNER;
    
    public static void OTMCreationFlow(Map<Id, Campaign> oldMap, Map<Id, Campaign> newMap)
    {
        List<Campaign> filteredCamps = filterCampaignOwnerChange(oldMap, newMap);
        if(!filteredCamps.isEmpty())
        {
            createOTMFromCampaigns(filteredCamps);
        }
    }
    
    @TestVisible
    private static List<Campaign> filterCampaignOwnerChange(Map<Id, Campaign> oldMap, Map<Id, Campaign> newMap)
    {
        List<Campaign> filteredCampaigns = new List<Campaign>();
        
        /* Insert Case is Never Possible */
        /*
        if( oldMap == NULL || oldMap.isEmpty() )
        {
            filteredCampaigns = newMap.values();
        }
        */
        /* BL 3093 Updated code to change that logic to exclude adding the team member 1/10/22 */
        Campaign newMapCam;
        map<Id, String>  userIdVsProfileName = new Map<Id, String>();
        List<User> usrList = [Select id, profile.Name from user];
        for(user us: usrList){
            userIdVsProfileName.put(us.Id, us.profile.Name);
        }
        
        for(Id promotionId : newMap.keySet())
        {
            newMapCam = newMap.get(promotionId);
            
            /* BL 3268 Removed Marketing Restricted - Lightning Profile 7/08/22 */
            if(oldMap.get(promotionId).OwnerId != newMapCam.OwnerId && userIdVsProfileName.get(newMapCam.OwnerId) != 'Marketing - Lightning') //&& userIdVsProfileName.get(newMapCam.OwnerId) != 'Marketing Restricted - Lightning')
            
            {
                filteredCampaigns.add(newMapCam);
            }
        }
        
        return filteredCampaigns;
    }
    
    @TestVisible
    private static void createOTMFromCampaigns(List<Campaign> filteredCampaigns)  
    {
        List<OpportunityTeamMember> otmsToInsert = new List<OpportunityTeamMember>();
        Map<Id, Campaign> filteredCampaignsMap = new Map<Id, Campaign>( filteredCampaigns );
        
        Map<Id, Opportunity> relatedOppsMap = new Map<Id, Opportunity>([SELECT Id, CampaignId FROM Opportunity WHERE CampaignId IN :filteredCampaigns]);
        Map<Id, List<Opportunity>> campIdToOpps = (Map<Id, List<Opportunity>>) GroupBy.Ids('CampaignId', relatedOppsMap.values());
        
        for(Id campaignId : campIdToOpps.keySet())
        {
            if(campIdToOpps.containsKey(campaignId))
            {
                for(Opportunity opp : campIdToOpps.get(campaignId))
	            {
	                OpportunityTeamMember otm = new OpportunityTeamMember(
	                    UserId = filteredCampaignsMap.get(campaignId).OwnerId,
	                    OpportunityId = opp.Id,
	                    TeamMemberRole = OPP_TEAM_MEMBER_ROLE,
	                    OpportunityAccessLevel = OPP_ACCESS_LEVEL
	                );
	                otmsToInsert.add( otm );
	            }
            }
        }
        
        if(otmsToInsert.isEmpty())
        {
            return;
        }
        
        try
        {
            insert otmsToInsert; 
        }
        catch(Exception ex)
        {
            for(Integer i = 0; i < ex.getNumDML(); i++)
            {
                Integer errorPosition = ex.getDMLIndex(i);
                Id campaignId = relatedOppsMap.get(otmsToInsert[errorPosition].OpportunityId).CampaignId;
                
                filteredCampaignsMap.get(campaignId).addError( ex.getDMLMessage(errorPosition));
            }
        }
    }
    
}
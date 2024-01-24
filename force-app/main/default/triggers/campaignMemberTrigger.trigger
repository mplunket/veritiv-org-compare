// Sujitha: Created a new after insert trigger for sharing leads with promo owner.

trigger campaignMemberTrigger on CampaignMember(after insert, after update)
  {
    List<LeadShare> listLeadShare = new List<LeadShare>();

    for(CampaignMember campMemb : Trigger.new)
      {
        if(campMemb.leadId!=null && campMemb.CampaignId!=null)
          {
            LeadShare leadShr_Recd  = new LeadShare();
            leadShr_Recd.LeadId = campMemb.leadId;
            leadShr_Recd.UserOrGroupId = campMemb.CampaignOwner__c;
            leadShr_Recd.LeadAccessLevel = 'Read';
            listLeadShare.add(leadShr_Recd);
          }
      }
     try
     {
      
      if(listLeadShare!=null && listLeadShare.size()>0)
         insert listLeadShare;
 }catch(Exception e)
     {
         system.debug('Error Message'+e.getMessage());
      }
    }
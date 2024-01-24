// Sujitha- Campaign Trigger
trigger campaignTrigger on Campaign(after update)
 {
   set<Id> setCampId = new Set<Id>();
   set<Id> setLeadId = new Set<Id>();
   set<Id> setOldCampOwnerId = new set<Id>();
   List<LeadShare> listLeadShare = new List<LeadShare>();
   Map<Id,List<CampaignMember>> mapListCampMember = new Map<Id,List<CampaignMember>>();
   for(Campaign campRecd : Trigger.new)
     {
       if(campRecd.ownerId!=Trigger.oldMap.get(campRecd.id).ownerId)
          {
             setCampId.add(campRecd.id);
          }
     }
     
     for(CampaignMember campMember : [Select Id,Type,LeadId,CampaignId from CampaignMember where Type='Lead' and CampaignId IN : setCampId])
       {
         if(mapListCampMember.containsKey(campMember.CampaignId))
           {
             List<CampaignMember> campMemList = mapListCampMember.get(campMember.CampaignId);
             campMemList.add(campMember);
             mapListCampMember.put(campMember.CampaignId,campMemList);
           }
         else
          mapListCampMember.put(campMember.CampaignId,new List<CampaignMember>{campMember});
    }

     for(Campaign campRecd : Trigger.new)
     {
        if(campRecd.ownerId!=Trigger.oldMap.get(campRecd.id).ownerId)
          {
            setOldCampOwnerId.add(Trigger.oldMap.get(campRecd.id).ownerId);
            if(mapListCampMember.containsKey(campRecd.Id))
              {
                 for(CampaignMember campMemb : mapListCampMember.get(campRecd.Id))
                   {
                     setLeadId.add(campMemb.leadId);
                     LeadShare ldShare = new LeadShare();
                     ldShare.leadId = campMemb.leadId;
                     ldShare.LeadAccessLevel = 'Read';
                     ldShare.UserOrGroupId = campRecd.ownerId;
                     listLeadShare.add(ldShare);

                  }
             }
        }
   }

   List<LeadShare> leadShareDelList = new list<leadShare>([Select Id from LeadShare where LeadId IN : setLeadId and UserOrGroupId IN : setOldCampOwnerId and LeadAccessLevel = 'Read']);
    try
    {
   if(listLeadShare!=null && listLeadShare.size()>0)
      insert listLeadShare;
       if(leadShareDelList!=null && leadShareDelList.size()>0)
     delete leadShareDelList;
    }catch(Exception e)
        {
            system.debug('Error Message'+ e.getMessage());
        }

     }
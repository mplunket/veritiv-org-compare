public class SharePromoToUsers {
public String selectedUsers{get;set;}
public Campaign campRecd{get;set;}
public Id CampaignRecdId {get;set;}
//public List<String> selectedCategories { get; set; }

public sharePromoToUsers(ApexPages.StandardController std)
 {
   campRecd = new Campaign();
   this.CampaignRecdId = (Id)std.getRecord().get('Id');
    
 }

   
     public PageReference save(){
      system.debug('SelectedUsers');
      
    //  List<User> userList = new List<User>([Select Id,Name from user where Name=:SelectedUsers limit 1]);
    List<User> userList = new List<User>([Select Id,Name from user where Id=:campRecd.User__c limit 1]);
      List<LeadShare> leadShareList = new List<LeadShare>();
      List<OpportunityShare> oppShareList = new List<OpportunityShare>();
      Set<Id> setLead = new Set<Id>();
      
            
 //   List<CampaignShare> listCampaignShare = new List<CampaignShare>([Select Id,CampaignId,CampaignAccessLevel,RowCause,UserOrGroupId from CampaignShare where CampaignId=:CampaignRecdId and UserOrGroupId=:userList[0].id]);
    
    List<CampaignMember> campMemberList = new List<CampaignMember>([Select Id,LeadId,CampaignId,Type from CampaignMember where CampaignId =:CampaignRecdId and Type='Lead']);
   
    List<Opportunity> listOpportunity = new List<Opportunity>([Select Id,CampaignId from Opportunity where CampaignId =:CampaignRecdId]);
   
     if(campMemberList!=null && campMemberList.size()>0)
       {
          for(CampaignMember campRecd : campMemberList)
            {
              setLead.add(campRecd.LeadId);
            }
            
                for(Lead leadRecord : [Select Id from lead where Id IN: setLead])
           {
              LeadShare leadShareRecord = new LeadShare();
              leadShareRecord.LeadId = leadRecord.id;
              leadShareRecord.LeadAccessLevel = 'Read';
              leadShareRecord.RowCause = 'Manual';
              leadShareRecord.UserOrGroupId = userList[0].Id;
              leadShareList.add(leadShareRecord);
           }
       }
       
              if(listOpportunity!=null && listOpportunity.size()>0)
       {
         for(Opportunity oppRecord : listOpportunity)
           {
              OpportunityShare oppShareRecord = new OpportunityShare();
              oppShareRecord.OpportunityId = oppRecord.id;
              oppShareRecord.OpportunityAccessLevel= 'Read';
              oppShareRecord.RowCause = 'Manual';
              oppShareRecord.UserOrGroupId = userList[0].Id;
              oppShareList.add(oppShareRecord);
           }
       }
       
       try
        {
        if(leadShareList!=null && leadShareList.size()>0)
           insert leadShareList;
           
        if(oppShareList!=null && oppShareList.size()>0)
           insert oppShareList;  
        }
        catch(Exception e)
          {
            system.debug('Exception'+ e.getMessage());
          }    
                  
     //  return null;
       return new PageReference('/'+ CampaignRecdId);
    }

}
//@isTest(SeeAllData = true)
@isTest
public class TestLeadSharingWithPromoOwner
  {
    
      public testMethod static void TestLeadSharingMethod()
        {


           Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      
           User u = new User(Alias = 'standt', Email='standarduser12@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Network_Id__c = 'standt', Country = 'USA',
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test223@testorg.com');
            insert u;

            Lead leadRcd = new Lead();
            leadRcd.LastName = 'Test Lead';
            leadRcd.Email = 'testLead4@gmail.com';
            leadRcd.Company = 'test453';
            insert leadRcd;


            Campaign campRecd = new Campaign();
            campRecd.Name = 'Test Campaign';
            campRecd.Status = 'Planned';
            campRecd.isActive = true;
            campRecd.ownerId = UserInfo.getUserId();
            insert campRecd;
            
             CampaignMember campMember = new CampaignMember();
            campMember.LeadId = leadRcd.Id;
            campMember.CampaignId = campRecd.Id;
            //campMember.Type = 'Lead';
            campMember.Status = 'Sent';
            
            try
             {
            insert campMember;
             }catch(Exception e)
                 {
                      system.debug('ErrorMessage'+ e.getMessage());
                  }
                  
                  CampaignMember campMem = [Select Id,CampaignId,Campaign.ownerId,LeadId from CampaignMember where Type = 'Lead' limit 1];
                  
                  campMem.Campaign.ownerId = u.Id;
                  try
                   {
                  update campMem.Campaign;
                  }catch(Exception e)
                     {
                         system.debug('Err'+ e.getmessage());
                     }
                  
                  
                  
                           //   system.assertEquals(campRecd.ownerId,UserInfo.getUserId());

      /*      
         //   system.assertEquals(campRecd.ownerId,UserInfo.getUserId());
            
            Campaign campRecord = [Select Id,OwnerId from Campaign where Id =:campRecd.Id limit 1];
            campRecord.OwnerId = u.Id;
              
            try
             {
            update campRecord;
            }catch(Exception e)
                 {
                     system.debug('Error'+ e.getMessage());
                  }
     */
            
          //  system.assertEquals(campRecord.OwnerId,u.Id);
       

       }

 }
@isTest
public class TestSharePromoToUsers
 {
   public static testMethod void ShareToUsersLogic()
     {
       TriggerSettings__c triggerSetting = new TriggerSettings__c();
       triggerSetting.IsVeritivContact__c = false;
       insert triggerSetting;
       
       Campaign campRecd = new Campaign();
       campRecd.Name = 'Test Campaign';
       campRecd.User__c = userInfo.getUserId();
       campRecd.IsActive = True;
       insert campRecd;
       
       Account acc = new Account();
       acc.Name = 'Test Account';
       insert acc;
       
       Lead leadRecd = new Lead();
       leadRecd.LastName = 'Test Lead1';
       leadRecd.Email = 'testLead1@gmail.com';
       leadRecd.Company = 'Test Company';
       insert leadRecd;
       
       Lead leadRecd1 = new Lead();
       leadRecd1.LastName = 'Test Lead2';
       leadRecd1.Email = 'testLead2@gmail.com';
       leadRecd1.Company = 'Test Company';
       insert leadRecd1;
       
       Lead leadRecd2 = new Lead();
       leadRecd2.LastName = 'Test Lead3';
       leadRecd2.Email = 'testLead3@gmail.com';
       leadRecd2.Company = 'Test Company';
       insert leadRecd2;
       
       
       
       CampaignMember campMemb = new CampaignMember();
       campMemb.CampaignId = campRecd.Id;
       campMemb.LeadId = leadRecd.Id;
       campMemb.Status = 'Sent';
       insert campMemb;
       
       CampaignMember campMemb1 = new CampaignMember();
       campMemb1.CampaignId = campRecd.Id;
       campMemb1.LeadId = leadRecd1.Id;
       campMemb1.Status = 'Sent';
       insert campMemb1;
       
       CampaignMember campMemb2 = new CampaignMember();
       campMemb2.CampaignId = campRecd.Id;
       campMemb2.LeadId = leadRecd2.Id;
       campMemb2.Status = 'Sent';
       
       insert campMemb2;
       
       Opportunity oppRecord = new Opportunity();
       oppRecord.StageName = 'Closed Won';
       oppRecord.Name = 'Test Opp';
       oppRecord.AccountId = acc.Id;
       oppRecord.CampaignId = campRecd.id;
       oppRecord.CloseDate = system.today();
       insert oppRecord;
       
       
      Test.StartTest();
       PageReference pageRef = Page.CampaignShare;
       pageRef.getParameters().put('Id',campRecd.Id);
       Test.setCurrentPageReference(pageRef);
       
       sharePromoToUsers shareToUserRecd = new sharePromoToUsers(new ApexPages.StandardController(campRecd));
       shareToUserRecd.campRecd = campRecd;
       shareToUserRecd.selectedUsers = campRecd.User__c;
       shareToUserRecd.CampaignRecdId = campRecd.id;
       shareToUserRecd.save();
      Test.StopTest();
       
      
       
       
  }
}
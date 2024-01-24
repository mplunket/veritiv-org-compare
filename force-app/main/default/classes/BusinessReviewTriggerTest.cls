@isTest
public class BusinessReviewTriggerTest {

    @isTest
    public static void testMethod1(){
        
        
       Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        
     	User usr1 = new User(LastName = 'twert1234',
                           FirstName='teswr43t',
                           Alias = 'tu32bk',
                           Email = 'jasowen.liwrveston@asdf.com',
                           Username = 'jason.liveston@uyf4s.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US',
                            Network_Id__c = 'tu32bk',
                            country = 'USA'
                           );
        
        insert usr1;
        
     	User usr = new User(LastName = 'tet1234',
                           FirstName='tes543t',
                           Alias = 'tiubk',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liviuyutgcteston@uyf4s.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US',
                            Network_Id__c = 'tiubk',
                            country = 'USA',
                            managerId = usr1.id
                           );
         insert usr;
        
        Primary_Sales_Rep__c newPSR = new Primary_Sales_Rep__c();
        newPSR.Name = 'Joe Test ';
        newPSR.Network_Id__c = 'tiubk';
        newPSR.Email__c = 'user@domain.com';
        newPSR.SF_userid__c = usr.id;
        insert newPSR ;
        
        
       
        
        
        Pipeline_Review__c pR = new Pipeline_Review__c();
        pR.Name = 'test';
         pR.Primary_Sales_Rep__c = newPSR.id;
        insert pR;
        
    }
    
}
@isTest
public class userTrigger_Test {
    
    @isTest
    public static void testUser(){
        
        primary_sales_rep__c psr = new primary_sales_rep__c();
        psr.Name = 'sfdc admin';
        psr.Network_ID__c = 'alias';
        insert psr;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'test.test@amamama.com',
            Username = 'test@amamama.com',
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Network_Id__c = 'alias',
            country = 'USA'
        );
        
        insert u;
		
        u.LastName = 'test update';
        update u;
        
        
    }
    
}
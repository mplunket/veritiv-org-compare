@isTest
private class LegalContractServicesTest {
    
    @testSetup static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        UserRole r = new UserRole(DeveloperName = 'FS_CATEGORY_MGMT_Leaderstest', Name = 'FS - CATEGORY MGMT - Leaders');
        insert r;
        User u = new User(Alias = 't74vdt', Email='sttesdt435user@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Country = 'USA',
            TimeZoneSidKey='America/Los_Angeles', UserName='standartes536r@tigorg.com',userRoleId = r.id,Network_Id__c ='t74vdt' );
        
        insert u;
        
        User u1= new User(Alias = 't7uydt', Email='sttkjhdt435user@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Country = 'USA',
            TimeZoneSidKey='America/Los_Angeles', UserName='stdjhgvartes536r@tigorg.com',Network_Id__c ='t7uydt' );
        
        insert u1;    
    }
    
    static testmethod void testChangeOwner(){
        user u = [select id from user where Username = 'standartes536r@tigorg.com' limit 1];
        user u1 = [select id from user where Username = 'stdjhgvartes536r@tigorg.com' limit 1];
        
        Account acc = new Account ();
        acc.Name = 'test';
        acc.ownerid = u.id;
        insert acc;
           
        Legal_Contract__c lc = new Legal_Contract__c();
        lc.Account__c=acc.id;
        lc.ownerid = u.id;
        insert lc;
           
        acc.ownerid = u1.id;
        update acc;
           
       
        
    }
}
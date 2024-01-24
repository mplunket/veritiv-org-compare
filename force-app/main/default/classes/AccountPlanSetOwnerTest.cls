/**
 * Modified By Deepak Chawla on 2019-10-29.
  Added condition to select Account if they have Customer_Link_Account__c field set to True
 */
@isTest(seeAllData = false)
public class AccountPlanSetOwnerTest {
    
    
  /*  @testSetup static void testSetupData() {
       
    }
    */
    static testMethod void setOwnerTest(){ //should cover the insert case
        
         Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Link_Account__c = true;
        insert acc;
        
        primary_sales_rep__c psr = new primary_sales_rep__c();
        psr.Name = 'sfdc admin';
        psr.Network_ID__c = 'alias';
        insert psr;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'test.test@kasdj.com',
            Username = 'test@amamdakdjbama.com',
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
        
        Account someAccount = [SELECT Name FROM Account WHERE Customer_Link_Account__c  = True LIMIT 1][0];
        List<User> userList = [SELECT Name, Network_Id__c FROM User WHERE IsActive = true and id=:u.id LIMIT 200];
        List<String> userNetIds = new List<String>();
        for(User someUser : userList){
            userNetIds.add(someUser.Network_Id__c);
        }
        system.debug('userNetIds'+userNetIds);
        Primary_Sales_Rep__c someRep = [SELECT Name, Network_ID__c FROM Primary_Sales_Rep__c WHERE Network_Id__c IN :userNetIds LIMIT 1][0];
        Account_Plan__c somePlan = new Account_Plan__c(Name = 'somePlan',
                                              Account__c = someAccount.Id,
                                              Primary_Sales_Rep__c = someRep.Id,
                                              Financial_year__c = '2016',
                                              Fiscal_Quarter__c = 'Q1: Jan-Mar',
                                              Review_Date__c = Date.TODAY(),
                                              FY_Sales_Budget__c = 1,
                                              Selling_Margin_PCT_Budget__c = 1);
        test.starttest();
            insert somePlan;
        test.stoptest();
    }
}
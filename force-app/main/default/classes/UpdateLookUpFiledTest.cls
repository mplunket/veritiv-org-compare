@isTest
private class UpdateLookUpFiledTest { 
static testMethod void myUnitTest() {

       Account acc = new Account(name='TestAccount', AccountNumber='123567test');
       insert acc; 

       CA_Customer_Assessment__c  caCus = new CA_Customer_Assessment__c(TP_Account__c = acc.Id );

insert caCus;

     }
}
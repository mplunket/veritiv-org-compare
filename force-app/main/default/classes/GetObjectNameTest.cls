@isTest
public class GetObjectNameTest {
 
 @isTest
 public static void testReturnObjectName(){
 //Create and insert lead record
 Lead testLead = new Lead();
 testLead.Status = 'Open';
 testLead.FirstName = 'Testy';
 testLead.LastName = 'McTesty';
 testLead.Company = 'Test Company';
 insert testLead;
 
 //Return newly created lead record 
 List<Lead> LeadList = new List<Lead> ();
 LeadList = [Select Id from Lead where FirstName = 'Testy' AND LastName = 'McTesty' AND Company = 'Test Company' LIMIT 1];
 
 List<string> IdList = new List<string> ();
 
 For (Lead l: LeadList){
 IdList.add(l.Id);
 }
 test.startTest();
 List<string> results = GetObjectName.returnObjectName(IdList);
 test.stopTest();
 System.assertEquals('Lead', results[0], 'ERROR IN GetObjectNameTest.testReturnObjectName : sObject Name did not match');
 }

}
/***
 * Created by Eduardo Carvalho on 2019-11-15.
 */
@isTest
public class LookupSearchComponentControllerTest {
    
    static testMethod void LookupSearchComponentControllerTest(){   
        
        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Name').assign('AccountTestGetResults')
            .property('Zilliant_Active__c').assign('AI');
        insert UnitTest.get('Account').getList();
        String filterField = 'Name';
        String value = 'AccountTestGetResults';
        String objectName = 'Account';
        Integer accountCount = [Select id from Account where Name = :value].size();
        Integer accountResult = LookupSearchComponentController.getResults(objectName, filterField,value).size(); 
        System.assertEquals(accountCount, accountResult); //return account with name AccountTestGetResults
    }
}
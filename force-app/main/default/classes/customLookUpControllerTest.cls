/***
 * Created by Eduardo Carvalho on 2019-11-15.
 */
@isTest
public class customLookUpControllerTest {
    
    static testMethod void fetchLookUpValuesTest(){        
        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Name').assign('AccountTest')
            .property('Zilliant_Active__c').assign('AI');
        insert UnitTest.get('Account').getList();
        
        String searchKeyWord = 'AccountTest';
        String objectName = 'Account';
        Integer accountCount = [Select id from Account where Name = :searchKeyWord].size();
        Integer accountResult = customLookUpController.fetchLookUpValues(searchKeyWord,objectName).size();
        
        System.assertEquals(accountCount, accountResult); //return account with name AccountTest
		
        
    }
    
    static testMethod void fetchRecordsTest(){        
        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Name').assign('AccountTestRecords')
            .property('Zilliant_Active__c').assign('AI');
        insert UnitTest.get('Account').getList();
        String filterField = 'Name';
        String searchString = 'AccountTestRecords';
        String objectName = 'Account';
        Integer accountCount = [Select id from Account where Name = :searchString].size();
        Integer accountResult = customLookUpController.fetchRecords(objectName, filterField,searchString).size(); 
        System.assertEquals(accountCount, accountResult); //return account with name AccountTestRecords
    }

}
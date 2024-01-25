@isTest
public class callToCreditControllerTest {

    @isTest static void testGetAccount() {
		Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
		insert testAccount;

		Test.startTest();
			Account returnedAccount = callToCreditController.getAccount(testAccount.Id);
		Test.stopTest();

		System.assertEquals(testAccount.Id, returnedAccount.Id, 'We expect the controller to return the correct account.');
    }
    
    @isTest static void testGetServicing(){
        Servicing_Division__c testSD = new Servicing_Division__c();
        testSD.Name = 'Test';
        testSD.Division_Country__c = 'USA';
        insert testSD;

        Test.startTest();
			Servicing_Division__c returnedSD = callToCreditController.getServicing(testSD.Id);
        Test.stopTest();
        
        system.assertEquals(testSD.Id, returnedSD.Id, 'We expect the controller to return the correct Service Division.');
    }

    @isTest static void testCallOut() {

        Test.setMock(HttpCalloutMock.class, new callToCreditControllerMock());

        Credit_Application_Credential__c rCreditApplicationSetting = new Credit_Application_Credential__c();
        rCreditApplicationSetting.Username__c = 'soauser';
        rCreditApplicationSetting.Password__c = 'soapuserpass';
        rCreditApplicationSetting.Oracle_AR_Endpoint__c= 'test.veritiv.com';

        insert rCreditApplicationSetting;

        Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
        testAccount.Name = 'Test Account';
        testAccount.Sales_Rep_Code__c = 'ABC';
        testAccount.Equipment_Account__c = true;
        testAccount.Prospect_Segment__c = 'Print';
        testAccount.Parent_Duns_Number__c = '12345';
        testAccount.D_U_N_S__c = '0124';
        testAccount.Domestic_Ultimate_Duns_Number__c = '123';
        testAccount.Global_Ultimate_Duns_Number__c = '897';
        insert testAccount;
        
        Servicing_Division__c testSD = new Servicing_Division__c();
        testSD.Name = 'Test';
        testSD.Division_Country__c = 'USA';
        testSD.Division_Composite_Key__c = '4567';
        insert testSD;

        Test.startTest();
        callToCreditController.callOut(testAccount.Id, testSD.Id, testAccount.Sales_Rep_Code__c, testAccount.Equipment_Account__c, testAccount.Prospect_Segment__c);
        Test.stopTest();

        Account newAcc = [SELECT Name, Credit_Reason_Code__c  FROM Account WHERE Id = :testAccount.Id];
        system.assertEquals('New Customer', newAcc.Credit_Reason_Code__c, 'Callout logic didnt execute');
    }
}
@isTest
public class CreditAppTriggerHandlerTest {

    @isTest static void insertCreditApp() {

        Test.setMock(HttpCalloutMock.class, new CredAppCalloutMock());
        Test.startTest();

        // Create 50 accounts for test class
        List<Account> accList = new List<Account>();
        for(Integer i = 0 ; i < 50 ; i++){
            Account tempAcc = new Account();
            tempAcc.Name = 'Test Acc ' + i;
            tempAcc.Credit_Action_for_Setup__c = '1';
            tempAcc.D_U_N_S__c = '111';
            tempAcc.Sales_Rep_Code__c = '111';
            tempAcc.OwnerId = UserInfo.getUserId();
            tempAcc.Credit_Submitted_By__c = UserInfo.getUserId();
            tempAcc.Legacy_Division_Cd__c = '111';
            tempAcc.Legacy_System_Cd__c = '03';
            tempAcc.Prospect_Segment__c = 'Print';
            tempAcc.Equipment_Account__c = true;
            tempAcc.Global_Ultimate_Duns_Number__c = '111';
            tempAcc.Domestic_Ultimate_Duns_Number__c = '111';
            tempAcc.D_B_Doing_Business_As__c = 'test';
            accList.add(tempAcc);
        }
        insert accList;
        
        // Create 50 Credit Apps
        List<Credit_Application__c> credList = new List<Credit_Application__c>();
        for(Integer i = 0 ; i < 50 ; i++){
            Credit_Application__c temp = new Credit_Application__c();
            temp.Name = 'Test CredApp ' + i;
            temp.Account__c = accList[i].Id;
            temp.Federal_ID_Number__c = '111';
            temp.W_9__c = 'Yes';
            temp.Bank_Name__c = 'test';
            temp.Bank_Contact__c = 'test';
            temp.Bank_Contact_Email__c = 'test@gmail.com';
            temp.Bank_Account_Number__c = '111';
            temp.Bank_Account_Type__c = 'Checking';
            temp.Bank_City__c = 'Atlanta';
            temp.Bank_State__c = 'GA';
            temp.Bank_Zip__c = '30332';
            temp.Bank_Phone__c = '6784929393';
            temp.Bank_Fax__c = '6784929898';
            temp.Shipto_Name__c = 'test';
            temp.Shipto_Street__c = '123 main st';
            temp.Shipto_Street2__c = 'unit A';
            temp.Shipto_City__c = 'Atlanta';
            temp.Shipto_Postal_Zip__c = '30332';
            temp.Shipto_Phone__c = '6784928776';
            temp.Tax_Status__c = 'Exempt';
            temp.Tax_Contact_Name__c = 'test';
            temp.Tax_Dept_Phone__c = '6784920909';
            temp.Tax_Dept_Email__c = 'test@gmail.com';
            temp.Tax_Exempt_Type__c = 'Resale';
            temp.Tax_Exempt_Products__c = 'Equipment';
            temp.Tax_Exempt_Other__c = 'test';
            temp.Tax_Exempt_States__c = 'Alabama';
            temp.A_P_Contact__c = 'test';
            temp.A_P_Email__c = 'test@gmail.com';
            temp.A_P_Phone__c = '6784927766';
            temp.Invoice_Requirements__c = 'Other';
            temp.Back_Orders_Accepted__c = true;
            temp.Purchase_Order_Required__c = true;
            temp.Method_of_Invoice_Delivery__c = 'Mail';
            temp.Delivery_Email_Address__c = 'test@gmail.com';
            temp.Portal_Website_Address__c = 'www.test.com';
            temp.Shipto_Name__c = 'test';
            temp.Shipto_Street__c = '123 Main St';
            temp.Shipto_Street2__c = 'Unit A';
            temp.Shipto_City__c = 'Atlanta';
            temp.Shipto_State__c = 'GA';
            temp.Shipto_Postal_Zip__c = '30332';
            temp.Shipto_Phone__c = '6784926575';
            temp.Tax_Status__c = 'Exempt';
            temp.Tax_Contact_Name__c = 'test';
            temp.Tax_Dept_Phone__c = '6784929733';
            temp.Tax_Dept_Email__c = 'test@gmail.com';
            temp.Tax_Exempt_Type__c = 'Resale';
            temp.Tax_Exempt_Products__c = 'Equipment';
            temp.Tax_Exempt_Other__c = 'test';
            temp.Tax_Exempt_States__c = 'Alabama';
            credList.add(temp);
        }
        insert credList;

        List<String> creds = new List<String>();
        for (Credit_Application__c cred : credList) {
            creds.add(cred.Id);
        }
        CredAppTriggerHandler.sendCreditAppDataAPI(creds);
        Test.stopTest();

        // Verify we receive a status code from the CredAppCalloutMock class
        Credit_Application__c verifyCred = [SELECT Id, Response_code__c FROM Credit_Application__c WHERE Id IN :creds LIMIT 1];

        system.assertEquals('200', verifyCred.Response_code__c, 'Wrong status code received');
    }
}
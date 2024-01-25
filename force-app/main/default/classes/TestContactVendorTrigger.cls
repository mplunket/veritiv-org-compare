/*

 */
@isTest
private class TestContactVendorTrigger {

    static testMethod void testContactCreationWithAccountVendor() 
    {
    	//create a vendor account
    	Account testAcct = TestingUtils.createAccount('Test Acct');
    	testAcct.VENDOR_CODE__c = 'B1U3';
    	testAcct.RecordTypeId = ContactServices.ACCOUNT_VENDOR_RTYPE_ID;
    	
    	insert testAcct;
    	
     	//Create a vendor detail
     	Vendor_Detail__c testVendorDetail = Testingutils.createVendorDetails(1, 'Test Vendor Detail', false)[0];
     	testVendorDetail.Vendor_Code__c = 'B1U3';
     	
     	insert testVendorDetail;
     	
     	//create a contact
     	Contact testContact = TestingUtils.createContact('Test', 'User', false);
     	testContact.RecordTypeId = ContactServices.CONTACT_VENDOR_RTYPE_ID;
     	testContact.AccountId = testAcct.Id;
     	
     	Test.StartTest();
     		insert testContact;
     	Test.StopTest();
     	
     	testContact = [Select id, Vendor_Lookup__c from Contact where Id = :testContact.Id];
     	
     	System.assertEquals( testVendorDetail.Id, testContact.Vendor_Lookup__c);
     		   
    }

    static testMethod void testUpdateContactAccount() 
    {
    	//create a vendor account
    	Account testAcct = TestingUtils.createAccount('Test Acct');
    	testAcct.VENDOR_CODE__c = 'B1U3';
    	testAcct.RecordTypeId = ContactServices.ACCOUNT_VENDOR_RTYPE_ID;
    	
    	insert testAcct;

    	//create another vendor account
    	Account testAcct2 = TestingUtils.createAccount('Test Acct');
    	testAcct2.VENDOR_CODE__c = 'B1U3W';
    	testAcct2.RecordTypeId = ContactServices.ACCOUNT_VENDOR_RTYPE_ID;
    	
    	insert testAcct2;
    	
     	//Create a vendor detail
     	Vendor_Detail__c testVendorDetail = Testingutils.createVendorDetails(1, 'Test Vendor Detail', false)[0];
     	testVendorDetail.Vendor_Code__c = 'B1U3';
     	
     	insert testVendorDetail;
     	
     	//Create another vendor detail
     	Vendor_Detail__c testVendorDetail2 = Testingutils.createVendorDetails(1, 'Test Vendor Detail2', false)[0];
     	testVendorDetail2.Vendor_Code__c = 'B1U3W';
     	
     	insert testVendorDetail2;
     	
     	//create a contact
     	Contact testContact = TestingUtils.createContact('Test', 'User', false);
     	testContact.RecordTypeId = ContactServices.CONTACT_VENDOR_RTYPE_ID;
     	testContact.AccountId = testAcct.Id;
     	
 		insert testContact;
 		
 		//Change the account of the contact
     	testContact.AccountId = testAcct2.Id;
     	
     	Test.StartTest();
     		update testContact;
     	Test.StopTest();
     	
     	testContact = [Select id, Vendor_Lookup__c from Contact where Id = :testContact.Id];
     	
     	System.assertEquals( testVendorDetail2.Id, testContact.Vendor_Lookup__c);
     		   
    }
}
@isTest
public class EmailLookupControllerTest {

        static testMethod void testPossibleAddresses()
	{
		ID prosRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Prospect'].Id;
        Account testCustAccount = new Account(Name='Test Customer', RecordTypeId=prosRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001');
        insert testCustAccount;

        Quote__c testQuote = new Quote__c(Account__c=testCustAccount.Id, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today(),Order_Request_Submitted__c=true);
        insert testQuote;
        
        PageReference emailLookup = Page.EmailLookup;
        emailLookup.getParameters().put('id', testQuote.Id);
        Test.setCurrentPageReference(emailLookup);
        
        Test.startTest();
        EmailLookupController elc = new EmailLookupController();
        Test.stopTest();
        System.assertEquals(testQuote.Id, elc.quote.Id);
	}

	
}
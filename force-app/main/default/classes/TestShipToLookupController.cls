@isTest
private class TestShipToLookupController
{
	static testMethod void testShipToLookupController()
	{
		Account testAccount = new Account(Name='Test Account');
		insert testAccount;
		Contact testContact = new Contact(AccountId = testAccount.Id, LastName = 'Johnson', FirstName='John');
		insert testContact;

		Test.setCurrentPageReference(new PageReference('/apex/ShipToLookup?id=' +
				testContact.Id + '&type=Contact&name=' + testContact.Name + '&accountId=' +
				testAccount.Id + '&accountName=' + testAccount.Name));

		ShipToLookupController shipToController = new ShipToLookupController();
		//We show the none option
		System.assert(shipToController.showShipTos);

		Ship_To__c shipTo = new Ship_To__c(Bill_To_Account__c = testAccount.Id, Address_Line1__c = '123 test Street', Active__c = 'Yes');
		insert shipTo;

		shipToController = new ShipToLookupController();
		System.assert(shipToController.showShipTos);

		/*
		//We can save a blank shipto
		
		shipToController.saveShipTo();
		System.assert(ApexPages.hasMessages());
		System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages()[0].getSeverity());
		*/
		shipToController.shipToId = shipTo.Id;
		shipToController.saveShipTo();
		testContact = [SELECT Id, Ship_To__c FROM Contact WHERE Id = :testContact.Id];
		System.assertEquals(shipToController.shipToId, testContact.Ship_To__c);
	}
}
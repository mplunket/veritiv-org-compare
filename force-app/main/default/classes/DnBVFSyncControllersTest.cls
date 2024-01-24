@isTest
private class DnBVFSyncControllersTest {
	
	@isTest static void testAccountVFSyncController() {
		PageReference pageRef = Page.DnBAccountVFSyncPage; //replace with your VF page name
        Test.setCurrentPage(pageRef);

		Account testAccount = (Account) SObjectFactory.build(Account.SObjectType);
		insert testAccount;

		ApexPages.currentPage().getParameters().put('id', testAccount.Id);

		Test.startTest();
			DnBAccountVFSyncController cont = new DnBAccountVFSyncController();
		Test.stopTest();

		System.assertEquals(testAccount.Id, cont.account.Id, 'We expect the account in the controller to be the same as the one referenced in the page parameters.');
	}
	
	@isTest static void testLeadVFSyncController() {
		PageReference pageRef = Page.DnBLeadVFSyncPage; //replace with your VF page name
        Test.setCurrentPage(pageRef);

		Lead testLead = (Lead) SObjectFactory.build(Lead.SObjectType);
		insert testLead;

		Test.startTest();
			ApexPages.currentPage().getParameters().put('id', testLead.Id);
		Test.stopTest();

		DnBLeadVFSyncController cont = new DnBLeadVFSyncController();

		System.assertEquals(testLead.Id, cont.lead.Id, 'We expect the lead in the controller to be the same as the one referenced in the page parameters.');
	}
	
}
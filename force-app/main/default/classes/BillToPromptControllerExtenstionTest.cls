@istest
public class BillToPromptControllerExtenstionTest {
    
public testMethod static void testShowAccountBillToPrompt()
	{
		Account prospectAccount = BillToPromptControllerExtenstion.createProspectAccount();
		BillToPromptControllerExtenstion.createClosedWonOpportunity(prospectAccount.Id);
		
		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(prospectAccount);
		
		BillToPromptControllerExtenstion billToController = new BillToPromptControllerExtenstion(sc);
		
		System.assert(billToController.showBillToPrompt);
		System.assert(!billToController.isSubmitted);
		System.assert(!billToController.isReminded);
		Test.stopTest();
	}
	 
	public testMethod static void testNoAccountBillToPrompt()
	{
		Account prospectAccount = BillToPromptControllerExtenstion.createProspectAccount();
		BillToPromptControllerExtenstion.createNonClosedWonOpportunity(prospectAccount.Id);
		
		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(prospectAccount);
		BillToPromptControllerExtenstion billToController = new BillToPromptControllerExtenstion(sc);
		
		System.assert(!billToController.showBillToPrompt);
		System.assert(!billToController.isSubmitted);
		System.assert(!billToController.isReminded);
		
		BillToPromptControllerExtenstion.createClosedWonOpportunity(prospectAccount.Id);
		prospectAccount.Bill_To_Number_to_Merge_With__c = '123456';
		update prospectAccount;
		
		sc = new ApexPages.StandardController(prospectAccount);
		billToController = new BillToPromptControllerExtenstion(sc);
		
		System.assert(!billToController.showBillToPrompt);
		System.assert(!billToController.isSubmitted);
		System.assert(!billToController.isReminded);
		
		Account nonProspectAccount = BillToPromptControllerExtenstion.createNonProspectAccount();
		BillToPromptControllerExtenstion.createClosedWonOpportunity(nonProspectAccount.Id);
		
		sc = new ApexPages.StandardController(nonProspectAccount);
		billToController = new BillToPromptControllerExtenstion(sc);
		System.assert(!billToController.showBillToPrompt);
		Test.stopTest();
	}
	
	
	
	public testMethod static void testShowOpportunityBillToPrompt()
	{
		Account prospectAccount = BillToPromptControllerExtenstion.createProspectAccount();
		Opportunity closedWonOpp = BillToPromptControllerExtenstion.createClosedWonOpportunity(prospectAccount.Id);
		
		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(closedWonOpp);
		
		BillToPromptControllerExtenstion billToController = new BillToPromptControllerExtenstion(sc);
		
		System.assert(billToController.showBillToPrompt);
		System.assert(!billToController.isSubmitted);
		System.assert(!billToController.isReminded);
		Test.stopTest();
	}
	
	public testMethod static void testNoOpportunityBillToPrompt()
	{
		Account prospectAccount = BillToPromptControllerExtenstion.createProspectAccount();
		Opportunity nonClosedWonOpp = BillToPromptControllerExtenstion.createNonClosedWonOpportunity(prospectAccount.Id);
		Test.startTest();
		
		ApexPages.StandardController sc = new ApexPages.StandardController(nonClosedWonOpp);
		
		BillToPromptControllerExtenstion billToController = new BillToPromptControllerExtenstion(sc);
		
		System.assert(!billToController.showBillToPrompt);
		System.assert(!billToController.isSubmitted);
		System.assert(!billToController.isReminded);
		Test.stopTest();
	}	
	
	public testMethod static void testUpdateBillToNumber()
	{
		Account prospectAccount = BillToPromptControllerExtenstion.createProspectAccount();
		BillToPromptControllerExtenstion.createClosedWonOpportunity(prospectAccount.Id);
		
		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(prospectAccount);
		BillToPromptControllerExtenstion billToController = new BillToPromptControllerExtenstion(sc);
		
		billToController.submit();
		System.assert(!billToController.isSubmitted);
		
		billToController.account.Bill_To_Number_to_Merge_With__c = '123455';
		billToController.submit();
		System.assert(billToController.isSubmitted);
		prospectAccount = [SELECT Id, Name, Bill_To_Number_to_Merge_With__c, RecordTypeId 
							FROM Account 
							WHERE Id = :prospectAccount.Id];
		
		System.assertEquals(billToController.account.Bill_To_Number_to_Merge_With__c, prospectAccount.Bill_To_Number_to_Merge_With__c);
		Test.stopTest();
	}
	
	public testMethod static void testRemindMeLater()
	{
		Account prospectAccount = BillToPromptControllerExtenstion.createProspectAccount();
		BillToPromptControllerExtenstion.createClosedWonOpportunity(prospectAccount.Id);
		
		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(prospectAccount);
		BillToPromptControllerExtenstion billToController = new BillToPromptControllerExtenstion(sc);
		
		billToController.createRemindMeLaterTask();
		
		Task task = [SELECT Id FROM Task WHERE WhatId = :prospectAccount.Id];

		System.assert(billToController.isReminded);
		System.assert(!billToController.showBillToPrompt);
		Test.stopTest();
	}	
	
}
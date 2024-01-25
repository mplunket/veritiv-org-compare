public class BillToPromptControllerExtenstion 
{
	public Account account {get; set;}
	public Boolean showBillToPrompt {get; set;}
	public Boolean isSubmitted {get; set;}
	public Boolean isReminded {get; set;}
	
	public static final String CLOSED_WON_STAGE = '8- Closed Won';
	public static final RecordType PROSPECT_ACCOUNT_RECORD_TYPE = [SELECT Id, Name, SObjectType
																	 FROM RecordType
																	 WHERE SObjectType = 'Account'
																	  AND Name = 'Prospect'];
	
	public BillToPromptControllerExtenstion(ApexPages.StandardController stdController)
	{
		String recordId = stdController.getRecord().Id;
		Boolean hasClosedWonOpportunity;
		
		if(recordId.startsWith('001')) //account
		{
			account = getAccountById(recordId);
			Integer closedWonOppCount =  [SELECT Count() 
											FROM Opportunity 
											WHERE AccountId = :recordId 
											 AND  StageName = :CLOSED_WON_STAGE];
			hasClosedWonOpportunity = (closedWonOppCount > 0);
		}
		else if(recordId.startsWith('006')) //opportunity
		{
			Opportunity opportunity = [SELECT Id, Name, StageName, AccountId
							FROM Opportunity
							WHERE Id = :recordId];
			account = getAccountById(opportunity.AccountId);
			hasClosedWonOpportunity = (opportunity.StageName == CLOSED_WON_STAGE);
		}
		
					  
		showBillToPrompt = (hasClosedWonOpportunity
							 && account.Bill_To_Number_to_Merge_With__c == null
							 && account.RecordTypeId == PROSPECT_ACCOUNT_RECORD_TYPE.Id);
		isSubmitted = false;
		isReminded = false;
	}
	
	/*
	* create task to remind user in 7 days
	*/
	public void createRemindMeLaterTask()
	{
		Integer reminderInterval = 7;
		Date reminderDate = Date.today().addDays(reminderInterval);
		Datetime reminderDateTime = Datetime.now().addDays(reminderInterval);

		Task billToReminder = new Task();
		billToReminder.ActivityDate = reminderDate;
		billToReminder.ReminderDateTime = reminderDateTime;
		billToReminder.IsReminderSet = true;
		billToReminder.WhatId = account.Id;
		billToReminder.Subject = 'Enter bill to number for account '+account.Name;
		billToReminder.Description = 'Enter bill to number for account '+account.Name;
		billToReminder.OwnerId = UserInfo.getUserId(); 
		
		try
		{
			insert billToReminder;
			isReminded = true;
			showBillToPrompt = false;
		}
		catch(Exception ex)
		{
			System.debug(ex);
		}
	}
	
	public void submit()
	{
		if(account.Bill_To_Number_to_Merge_With__c == null 
		   || account.Bill_To_Number_to_Merge_With__c == '')
		{
			return;
		}
		
		try
		{
			update account;
			isSubmitted = true;
			showBillToPrompt = false;
		}
		catch(Exception ex)
		{
			System.debug(ex);
		}
	}
	
	private Account getAccountById(String accountId)
	{
		Account acc = [SELECT Id, Name, Bill_To_Number_to_Merge_With__c, RecordTypeId 
						FROM Account 
						WHERE Id = :accountId];
		return acc;
	}
	

	
	@testVisible
	private static Account createProspectAccount()
	{
		Account account = new Account(Name='prospect account', RecordTypeId = PROSPECT_ACCOUNT_RECORD_TYPE.Id);
		insert account;
		return account;
	}
	@testVisible
	private static Account createNonProspectAccount()
	{
		RecordType customerRecordType = [SELECT Id, Name, SObjectType
											 FROM RecordType
											 WHERE SObjectType = 'Account'
											  AND Name = 'Customer'];
		
		Account account = new Account(Name='customer account', RecordTypeId = customerRecordType.Id);
		insert account;
		return account;							  
	}
	@testVisible
	private static Opportunity createClosedWonOpportunity(String accountId)
	{
		Opportunity opp = TestingUtils.createOpportunities(1, accountId, 'test opp', false)[0];
		opp.StageName = CLOSED_WON_STAGE;
		opp.Expected_Billing_Date__c = Date.today();
		opp.Customer_Selling_Margin_Rate__c = 50;
		opp.Prod_Category__c = 'CARBONLESS';
										 
		insert opp;
		return opp;
	}
	@testVisible
	private static Opportunity createNonClosedWonOpportunity(String accountId)
	{
		Opportunity opp = TestingUtils.createOpportunities(1, accountId, 'test opp', false)[0];
		opp.StageName = '1 - Prospect';
		opp.Customer_Selling_Margin_Rate__c = 50;
		opp.Prod_Category__c = 'CARBONLESS';
		insert opp;	
		return opp;
	}
}
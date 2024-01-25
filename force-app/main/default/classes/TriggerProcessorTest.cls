@isTest
private class TriggerProcessorTest {

	static Integer objectNum;
	
	static BluewolfDevUtils utils = new BluewolfDevUtils();

    static testMethod void runTrigger_Test_NewObjects() {
    	objectNum = 10;
    	
    	List<Account> accounts = (List<Account>) new SobjectBuilder(Account.SObjectType).count( objectNum ).build().getRecords();
    	insert accounts;
    	
    	Test.startTest();
    		Boolean runResults = TriggerProcessor.runTrigger( new Map<Id, SObject>( accounts ) );
    	Test.stopTest();
    	
    	System.assert(runResults, 'We expect the results to be true because these are brand new objects.');
    	
    }
    
    static testMethod void runTrigger_Test_SameObjects() {
    	objectNum = 10;
    	
    	List<Account> accounts = (List<Account>) new SobjectBuilder(Account.SObjectType).count( objectNum ).build().getRecords();
    	insert accounts;
    	
    	TriggerProcessor.firstTimeStateMap = new Map<Id, SObject>( accounts );
    	
    	Test.startTest();
    		Boolean runResults = TriggerProcessor.runTrigger( new Map<Id, SObject>( accounts ) );
    	Test.stopTest();
    	
    	System.assert(!runResults, 'We expect the results to be true because the object maps are the same.');
    	
    }
    
    static testMethod void runTrigger_Test_DifferentObjects() {
    	objectNum = 100;
    	
    	Map<String, Schema.SObjectField> fieldMap = Account.SObjectType.getDescribe().fields.getMap();
    	String accountQuery = 'SELECT ' + String.join(  new List<String>(fieldMap.keySet()), ' , ') + ' FROM Account'; System.debug('** Account Query: ' + accountQuery);
    	
    	List<Account> preAccounts = (List<Account>) new SobjectBuilder(Account.SObjectType).count( objectNum ).build().getRecords();
    	insert preAccounts;
    	preAccounts = Database.query(accountQuery);
    	
    	TriggerProcessor.firstTimeStateMap = new Map<Id, SObject>( preAccounts );
    	
		List<Account> triggerAccounts = new List<Account>();
		triggerAccounts = preAccounts.deepClone(true, true);
		for(Account acc : triggerAccounts)
			acc.Name = ('Updated Acc');
		update triggerAccounts;
		triggerAccounts = Database.query(accountQuery);
    	
    	Test.startTest();
    		Boolean runResults = TriggerProcessor.runTrigger( new Map<Id, SObject>( triggerAccounts ) );
    	Test.stopTest();
    	
    	System.assert(!runResults, 'We expect the results to be false because the object maps are different.');
    }
}
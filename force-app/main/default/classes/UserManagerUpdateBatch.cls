global class UserManagerUpdateBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
	
	ErrorHandling.ErrorLog errorLog;
	
    global UserManagerUpdateBatch()
    {
    	errorLog = new ErrorHandling.ErrorLog();
    }
	
    global database.querylocator start(Database.BatchableContext bc)
    {
    	String subordinatesQuery = 'Select Id, ManagerId,' + String.join(UserService.reportingHierarchyFields, ',') + ' From User ' +
    		'Where Inherit_Reporting_Hierarch__c = true AND Reporting_Hierarchy_Update_Needed__c = true AND isActive = true';
        return Database.getQueryLocator( subordinatesQuery );
    }

    global void execute(Database.BatchableContext bc, List<User> userSubordinatesToUpdate)
    {
    	PrimarySalesRepServices.batchRunning = true;
    	UserService.forceUserUpdate = true;
    	SafeUpdate updateDML = new SafeUpdate();
    	
		updateDML.queue(userSubordinatesToUpdate, errorLog);
		updateDML.doDML();
		
    	UserService.forceUserUpdate = false;
    }
    
    global void execute(SchedulableContext sc)
	{
		UserManagerUpdateBatch batchSheduled = new UserManagerUpdateBatch();
		Database.executeBatch( batchSheduled,50);
	}

    global void finish(Database.BatchableContext bc)
    {
    	if (errorLog.areThereErrors()) 
        {
            errorLog.emailLog(new List<String>{UserInfo.getUserEmail()}, 'Errors encountered while updating manager fields');
        }
    }
    
}
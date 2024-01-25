global class AIQasync_ContractJobSchedule extends AIQasync_AbstractJobSchedule implements Schedulable{

    private Boolean abortOnCompletion = false;
    private Boolean processAll = false;
    private String jobName;
    private String scopeQuery;

    private static String CRONEXPRESSION_IMEDIATE {
        get {
            DateTime currentDT = Datetime.now();
            DateTime futureDT = currentDT.addMinutes(1);
            String hour = String.valueOf(futureDT.hour());
            String min = String.valueOf(futureDT.minute()); 
            String ss = String.valueOf(futureDT.second());
            String batchProcSch = ss + ' ' + min + ' ' + hour + ' * * ?';
            return batchProcSch;
        }
    }
    
    AIQasync_ContractJobSchedule(String theJobName){
        this.jobName = theJobName;
    }

    AIQasync_ContractJobSchedule(String theJobName, Boolean abort, Boolean toProcessAll, String scopeQuery){
        this.jobName = theJobName;
        this.abortOnCompletion = abort;
        this.processAll = toProcessAll;
        this.scopeQuery = scopeQuery;
    }

    global static String scheduleOneTimeJob() 
    {
        String cronExp = CRONEXPRESSION_IMEDIATE;
        String jobName = 'AIQ Contract Line/Contract - One Time Job';
        if(Test.isRunningTest()){ jobName += ' - test job';}
        AIQasync_ContractJobSchedule SC = new AIQasync_ContractJobSchedule(jobName, true, true, null);
        return System.schedule(jobName, cronExp, SC);
    }

    global static String scheduleOneTimeJob(String scopeQuery) 
    {
        String cronExp = CRONEXPRESSION_IMEDIATE;
        String jobName = 'AIQ Contract Line/Contract - One Time Job';
        if(Test.isRunningTest()){ jobName += ' - test job';}
        AIQasync_ContractJobSchedule SC = new AIQasync_ContractJobSchedule(jobName, true, true, scopeQuery);
        return System.schedule(jobName, cronExp, SC);
    }
    
    //AIQasync_ContractJobSchedule.scheduleRecurringJob('0 0 2 * * ? *');
    global static String scheduleRecurringJob(String batchProcessSch) 
    {
        String jobName = 'AIQ Contract Line/Contract - Nightly Job';
        if(Test.isRunningTest()){ jobName += ' - test job';}
        AIQasync_ContractJobSchedule SC = new AIQasync_ContractJobSchedule(jobName); 
        return System.schedule(jobName, batchProcessSch, SC);
    }
    
	global override void execute(SchedulableContext sc) 
    {    
       AIQasync_LineAlignment batchProcess = new AIQasync_LineAlignment(notificationGroup, processAll, scopeQuery, batchSize);       
       ID batchProcId = Database.executeBatch(batchProcess, batchSize);
       System.debug('Processed Job ID ---'+'   '+batchProcId);

       if(abortOnCompletion){
            abortSchedule(this.jobName);
        }
	}

}
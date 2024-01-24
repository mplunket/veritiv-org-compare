global class AIQsec_PermissionSetBatchProSchedule implements Schedulable{
    
    private Boolean abortOnCompletion = false;
    private String jobName;
    private Integer batchSize; 

    global static String scheduleJob(Integer batchSize) 
    {
        DateTime currentDT = Datetime.now();
        DateTime futureDT = currentDT.addMinutes(1);
        String hour = String.valueOf(futureDT.hour());
        String min = String.valueOf(futureDT.minute()); 
        String ss = String.valueOf(futureDT.second());
        String batchProcSch = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobName = 'AIQ Security - Permission Set Assignment One Time Job';
        if(Test.isRunningTest()){ jobName += ' - test job';}
        AIQsec_PermissionSetBatchProSchedule SC = new AIQsec_PermissionSetBatchProSchedule(jobName, batchSize, true); 
        return System.schedule(jobName, batchProcSch, SC);
    }

    //AIQsec_PermissionSetBatchProSchedule.scheduleJob('0 0 7 1 * ? *');
    global static String scheduleJob(String batchCalcSch, Integer batchSize) 
    {
        String jobName = 'AIQ Security - Permission Set Assignment Recurring Job';
        if(Test.isRunningTest()){ jobName += ' - test job';}
        AIQsec_PermissionSetBatchProSchedule SC = new AIQsec_PermissionSetBatchProSchedule(jobName, batchSize); 
        return System.schedule(jobName, batchCalcSch, SC);
    }

    AIQsec_PermissionSetBatchProSchedule(String theJobName, Integer batchSize){
        this.jobName = theJobName;
        this.batchSize = (batchSize!= null? batchSize : 200);
    }

    AIQsec_PermissionSetBatchProSchedule(String theJobName, Integer batchSize, Boolean abort){
        this.jobName = theJobName;
        this.batchSize = (batchSize!= null? batchSize : 200);
        this.abortOnCompletion = abort;
    }
        
	global void execute(SchedulableContext sc) 
    {    
        AIQsec_PermissionSetBatchProcessor batchProcess = new AIQsec_PermissionSetBatchProcessor();
        batchProcess.getUsersForUpdateAll();
        ID batchProcId = Database.executeBatch(batchProcess, this.batchSize);
        System.debug('Processed Job ID ---'+'   '+batchProcId);
        if(this.abortOnCompletion){
            abortSchedule(this.jobName);
        }
	}

    private void abortSchedule(String jobName) {
        List<CronTrigger> lstJobs = new List<CronTrigger>();
        String query = 'SELECT Id, State, CronjobDetail.Name, CronJobDetail.Id, NextFireTime FROM CronTrigger WHERE ';
        query = query + ' CronJobDetail.Name = \''+String.escapeSingleQuotes(jobName)+'\' LIMIT 1';
        
        System.debug(query);
        lstJobs = Database.query(query);

        if(lstJobs.size() > 0) {
            for (CronTrigger job : lstJobs)
                System.abortJob(job.Id);
        }
    }

}
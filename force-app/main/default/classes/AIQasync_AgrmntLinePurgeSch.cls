global class AIQasync_AgrmntLinePurgeSch extends AIQasync_AbstractJobSchedule implements Schedulable{
    
    public AIQasync_AgrmntLinePurgeSch(){
    }
    
    //AIQasync_AgmntLinePurgeSch.scheduleJob('0 0 2 * * ? *');
    global static String scheduleJob(String batchProcessSch) 
    {
        String jobName = 'AIQ Contract Line Purging Job';
        if(Test.isRunningTest()){ jobName += ' - test job';}
        AIQasync_AgrmntLinePurgeSch SC = new AIQasync_AgrmntLinePurgeSch(); 
        return System.schedule(jobName, batchProcessSch, SC);
    }
    
	global override void execute(SchedulableContext sc) 
    {    
       AIQasync_AgrmntLinePurging purge = new AIQasync_AgrmntLinePurging(notificationGroup);        
       ID batchProcId = Database.executeBatch(purge, batchSize);
	}
    
}
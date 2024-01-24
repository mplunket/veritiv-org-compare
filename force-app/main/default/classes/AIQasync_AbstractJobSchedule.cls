global virtual class AIQasync_AbstractJobSchedule implements Schedulable {
    
    protected String[] notificationGroup;
    protected String[] FESLineLevels;
    protected Integer batchSize;
    protected Integer FESBatchSize;
    protected String eeFormulaName;
    protected Integer FESThreads;


    public AIQasync_AbstractJobSchedule(){
        this.getJobVariables();
    }

    global virtual void  execute(SchedulableContext sc){}

    public void abortSchedule(String jobName) {
        List<CronTrigger> lstJobs = new List<CronTrigger>();
        String query = 'SELECT Id, State, CronjobDetail.Name, CronJobDetail.Id, NextFireTime FROM CronTrigger WHERE ';
        if(jobName == NULL) {
            return;

        } else {
            query = query + ' CronJobDetail.Name = \''+String.escapeSingleQuotes(jobName)+'\' LIMIT 1';
        }
        System.debug(query);
        lstJobs = Database.query(query);

        if(lstJobs.size() > 0) {
            for (CronTrigger job : lstJobs)
                System.abortJob(job.Id);
        }
    }

    private void getJobVariables(){
        AIQZilliantConfiguration__c configFields = AIQZilliantConfiguration__c.getInstance();
        String notifGroupString = (String) configFields.get('NotificationGroup__c');
        String emailsString = '';
        if (!String.isBlank(notifGroupString)){
            emailsString = notifGroupString.replaceAll('(\\r|\\n)+', ',');
        }
        this.notificationGroup = emailsString.trim().split(',');
        this.batchSize = Integer.valueOf((Decimal) configFields.get('BatchJobSize__c'));
        this.FESBatchSize = Integer.valueOf((Decimal) configFields.get('FESRequestSize__c'));
        String FESLineLevelString = (String) configFields.get('FESEnabledLineLevel__c');
        String fesLLString = '';
        if (!String.isBlank(FESLineLevelString)){
            fesLLString = FESLineLevelString.replaceAll('(\\r|\\n)+', ',');
        }
        this.FESLineLevels = fesLLString.trim().split(',');
        this.eeFormulaName = (String) configFields.get('GetPriceDataFormulaEE__c');
        this.FESThreads = (Integer.valueOf((Decimal)configFields.get('FESThreads__c'))>0 ? Integer.valueOf((Decimal)configFields.get('FESThreads__c')) : 1);
    }
    
}
global class AIQasync_FESProcessorSchedule extends AIQasync_AbstractJobSchedule implements Schedulable{
    
    private Boolean abortOnCompletion = false;
    private String jobName;
    private zal.SoqlBuilder baseSoql;
    private zal.AndCondition whereCondition;
    
    AIQasync_FESProcessorSchedule(String jobName, Boolean abort, zal.SoqlBuilder baseSoql, zal.AndCondition whereCondition){
        this.jobName = jobName;
        this.abortOnCompletion = abort;
		this.baseSoql = baseSoql;
        this.whereCondition = whereCondition; 
    }

    global static String scheduleJob(zal.SoqlBuilder baseSoql, zal.AndCondition whereCondition) 
    {
        DateTime currentDT = Datetime.now();
        DateTime futureDT = currentDT.addMinutes(1);
        String hour = String.valueOf(futureDT.hour());
        String min = String.valueOf(futureDT.minute()); 
        String ss = String.valueOf(futureDT.second());
        String batchProcSch = ss + ' ' + min + ' ' + hour + ' * * ?';
        String theJobName = 'AIQ FES Processor - One Time Job';
        if(Test.isRunningTest()){ theJobName += ' - test job';}
        AIQasync_FESProcessorSchedule SC = new AIQasync_FESProcessorSchedule(theJobName, true, baseSoql, whereCondition);
        return System.schedule(theJobName, batchProcSch, SC);
    }

    global static String scheduleJob(String batchProcSch, zal.SoqlBuilder baseSoql, zal.AndCondition whereCondition)
    {
        String theJobName = 'AIQ FES Processor - Recurring Job';
        if(Test.isRunningTest()){ theJobName += ' - test job';}
        AIQasync_FESProcessorSchedule SC = new AIQasync_FESProcessorSchedule(theJobName, false, baseSoql, whereCondition); 
        return System.schedule(theJobName, batchProcSch, SC);
    }  

	global override void execute(SchedulableContext sc) 
    {   
        if(this.baseSoql!=null && this.whereCondition!=null){
             runUpdate(this.baseSoql, this.whereCondition);
        }
    }

    // FESThreads setting defines the number of parallel job executions 
    private void runUpdate(zal.SoqlBuilder baseSoql, zal.AndCondition whereCondition)
    {
     	List<AggregateResult> agrmntsGrouped = Database.query(new zal.SoqlBuilder().selectx('zpl__Contract__c, count(id) numb_lines')
                                                                .fromx('zpl__ContractLineItem__c')
                                                                .wherex(whereCondition)
                                                                .groupByx('zpl__Contract__c')
                                                                .orderByx(new zal.OrderBy('zpl__Contract__c'))
                                                                .toSoql()
                                                            );
        AggregateResult linesGrouped = Database.query(new zal.SoqlBuilder().selectx('count(id) numb_lines')
                                                        .fromx('zpl__ContractLineItem__c')
                                                        .wherex(whereCondition)
                                                        .toSoql()
                                                    );
        Integer bucketSize = Math.round((Decimal) linesGrouped.get('numb_lines')/FESThreads);

        Map<Integer,List<Id>> threads = new Map<Integer,List<Id>>();
        Integer counter =0;
        Integer thread =1;
        for(AggregateResult ar : agrmntsGrouped){
            counter += (Integer) ar.get('numb_lines');
            Id contractId = (Id) ar.get('zpl__Contract__c');
            if(!threads.containsKey(thread)){
                
                threads.put(thread, new List<Id>{contractId});
            }else{
                threads.get(thread).add(contractId);
            }
            
            if(counter>=bucketSize){    
                thread++;
                counter=0;
            }  
        }
        
        for(Integer i : threads.keySet()){
            
            // need to ensure that ConditionGroup is an instance of AndCondition
            zal.AndCondition whereAndConditions = new zal.AndCondition();
            for(zal.Condition condtn : whereCondition.conditions){
                whereAndConditions.add(condtn);
            }
            whereAndConditions.add(new zal.SetCondition('zpl__Contract__c', zal.Operator.INX, threads.get(i)));
            String query = baseSoql.wherex(whereAndConditions).toSoql();
            
            AIQasync_FESBatchProcessor batchProcess = new AIQasync_FESBatchProcessor(null, eeFormulaName, zpl__ContractLineItem__c.SobjectType, query);
            ID batchProcId = Database.executeBatch(batchProcess, FESbatchSize);
           
        }

        if(abortOnCompletion){
            abortSchedule(this.jobName);
        }
        
    }
    
}
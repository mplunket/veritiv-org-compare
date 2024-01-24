global class AIQasync_RollupCalculations implements Database.Batchable<sObject>, Database.Stateful{
    
    public class AIQasync_RollupCalculationsException extends Exception{}
    private DateTime currentDate;
    private DateTime expireStartDate;
    private DateTime expireEndDate;
    private List<Object> jobMessages;
    private List<String> notificationGroup;
    private Boolean processAll = false;
    private Integer batchSize;
    
    public AIQasync_RollupCalculations(List<String> notificationGroup, Integer batchSize)
    {
        this.currentDate = DateTime.now();
        this.expireStartDate =  DateTime.now().addDays(45);
        this.expireEndDate =  DateTime.now().addDays(-16); // covering one day after to reduce the count
        this.jobMessages = new List<Object>();
        this.notificationGroup = notificationGroup;
        this.batchSize = batchSize;
    }   
    
    public AIQasync_RollupCalculations(List<String> notificationGroup, Boolean toProcessAll, Integer batchSize)
    {
        this.currentDate = DateTime.now();
        this.expireStartDate =  DateTime.now().addDays(45);
        this.expireEndDate =  DateTime.now().addDays(-16); // covering one day after to reduce the count
        this.jobMessages = new List<Object>();
        this.processAll = toProcessAll;
        this.notificationGroup = notificationGroup;
        this.batchSize = batchSize;
    }    

    global Database.QueryLocator start(Database.BatchableContext BC){
		String query = '';
        
        if(this.processAll){
            query = 'SELECT Id FROM Contract';
        	query  += ' WHERE';
            query  += ' RecordType.Name in (\'Pricing Contract\')';
            query  += ' AND HasActiveAccount__c=true';
        } else {
            query = 'SELECT Id FROM Contract';
            query  += ' WHERE';
            query  += ' RecordType.Name in (\'Pricing Contract\')';
            query  += ' AND HasActiveAccount__c=true';
            query  += ' AND ';
            /** Lines becoming effective today on */
            query  += ' Id IN (';
            query  += ' SELECT zpl__Contract__c FROM zpl__ContractLineItem__c';
            query  += ' WHERE';
            query  += ' (RecordType.Name in (\'Active\')';
            query  += ' AND SupersededDate__c = null';
            query  += ' AND zpl__EffectiveDate__c = '+ currentDate.format('yyyy-MM-dd') + ')';
            query  += ' OR ';
            /** expiring Campaign Lines and Rebate Lines */
            query  += ' (RecordType.Name in (\'Active\', \'Inactive\')';
            query  += ' AND ((DisallowCampaignsThroughDate__c >=' + expireEndDate.format('yyyy-MM-dd');
            query  += ' AND DisallowCampaignsThroughDate__c <=' + expireStartDate.format('yyyy-MM-dd')+ ')';
            query  += ' OR ';
            query  += ' (ExternalCostDeviationDate__c >=' + expireEndDate.format('yyyy-MM-dd');
            query  += ' AND ExternalCostDeviationDate__c <=' + expireStartDate.format('yyyy-MM-dd')+ '))))';
        }
        system.debug('AIQBatchCalculations: ' + query);

        return Database.getQueryLocator(query);

    }    

    global void execute(Database.BatchableContext BC, List<Contract> scope)
    {
        
        try{
            AIQRollupCalculation calc = new AIQRollupCalculation (scope);
		    calc.saveUpdatedContracts();
            if(Test.isRunningTest()){throw new AIQasync_RollupCalculationsException();}
            
        }catch(System.Exception e){
            this.jobMessages.add(new AIQasync_RollupCalculationsException(e.getMessage()));
        } 
    }
    
    
    global void finish(Database.BatchableContext BC){
    
        //we need to send email here to Zilliant Support Portal
        if(!jobMessages.isEmpty()){
            new AIQco_Messenger('Veritiv DM: AIQasync_RollupCalculations class errors', this.jobMessages, this.notificationGroup).send();
        }

        //chaining NA conflict resolver job
        
        AIQasync_NAConflictResolver batchCalcs = new AIQasync_NAConflictResolver(notificationGroup, batchSize);   
        ID batchProcId = Database.executeBatch(batchCalcs, batchSize);
        System.debug('Processed Job ID ---'+'   '+batchProcId);
    }
}
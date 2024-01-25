global class AIQasync_FESBatchProcessor implements Database.Batchable<SObject>, Database.AllowsCallouts{

    public class AIQasync_FESBatchProcessorException extends Exception{}
    
    private SObject parent; 
    private String formulaName;
    private Schema.SObjectType sobjType;
    private String query;

    public AIQasync_FESBatchProcessor(SObject theParent, String theFormulaName, Schema.SObjectType theSobjType, String queryStr) {
         this.parent = theParent;
         this.formulaName = theFormulaName;
         this.sobjType = theSobjType;
         this.query = queryStr;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(this.query);
    }


    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {

        if(!scope.isEmpty()){
            
            //AIQco_FESClient.evaluateLinesVoid(scope, this.formulaName, this.sobjType);
            AIQPriceAPIClient.evaluateLines(scope, this.formulaName, this.sobjType);

        }        
    }

    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        system.debug('parent ' + this.parent);
        if(this.parent!=null){
            this.parent.put('IsProcessing__c', false);
            if(parent.Id!=null)
            {
                Savepoint sp = Database.setSavepoint();
                try
                {
                    zpf.DatabaseUtil.updateObjects(parent);
                } catch(Exception e)
                {
                    Database.rollback(sp);
                    throw new AIQasync_FESBatchProcessorException(e);
                }
            }
        }
       
    }


}
global class AIQco_FESBatchProcessorSync implements Database.Batchable<SObject>, Database.AllowsCallouts{

    public class AIQco_FESBatchProcessorSyncException extends Exception{}
    
    private SObject parent; 
    private String formulaName;
    private Schema.SObjectType sobjType;
    private List<SObject> records;

    public AIQco_FESBatchProcessorSync(SObject theParent, List<SObject> records, String theFormulaName, Schema.SObjectType theSobjType) {
         this.parent = theParent;
         this.formulaName = theFormulaName;
         this.sobjType = theSobjType;
         this.records = records;
    }

    global Iterable<SObject> start(Database.BatchableContext BC){
        
        return this.records;
    }


    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {

        if(!scope.isEmpty()){
            
            AIQPriceAPIClient.evaluateLines(records, formulaName, sobjType);

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
                    throw new AIQco_FESBatchProcessorSyncException(e);
                }
            }
        }
       
    }


}
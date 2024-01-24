global class Cust360RelationshipBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global static String sObjectToProcess {
        get {
            if(sObjectToProcess == null)
                sObjectToProcess = Cust360RelationshipBatchServices.getUnprocessedObject(); 
                
            return sObjectToProcess;
        }
        
        set;
    }
    
    public BatchInterface strategyInterface = new Relationship_BatchInterface();
    
    global static Set<String> objectsInOrg = Schema.getGlobalDescribe().keySet();
    global static List<String> globalErrors = new List<String>();

    global Database.QueryLocator start(Database.BatchableContext context)
    {
        String query = Cust360RelationshipBatchServices.buildQuery( sObjectToProcess );
        
        System.debug('QUERY: ' + query);
        
        return Database.getQueryLocator( query );
    }

    global void execute(Database.BatchableContext context, List<sObject> scope) 
    {
        globalErrors.addAll(Cust360RelationshipBatchServices.updateC360s(scope));
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        
        System.debug('OBJECT: ' + sObjectToProcess);
        
        if( String.isBlank(sObjectToProcess) )
        {
            Cust360RelationshipBatchServices.resetProcessedSobjects();
            
            /* Send Emails Here -> Passing in Errors */
            EmailMessageServices.sendBatchCompletedEmail(globalErrors, Cust360RelationshipBatchServices.C360_RELATIONSHIP_BATCH);
        }
        else
        {
        	/* Calls Itself */
            strategyInterface.reRunBatch(sObjectToProcess);
        }
    }
    
    /* Interface Used to Apply Testing */
    public class Relationship_BatchInterface implements BatchInterface {
    	
    	public void reRunBatch(String sObjectToUse)
    	{
            Cust360RelationshipBatchServices.updateCustomSettingSobject(sObjectToUse);
            
            Cust360RelationshipBatch batch = new Cust360RelationshipBatch();
            Database.executeBatch(batch);
    	}
    }
    
    public Interface BatchInterface {
    	
    	void reRunBatch(String sObjectToUse);
    	
    }

}
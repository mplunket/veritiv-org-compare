global class Cust360ToCaseAggregatorBatch implements Database.Batchable<AggregateResult>, Database.stateful, Schedulable
{
    global String sObjectToAggregate = '';
    global Boolean isLastSObjectToAggregate = false;
    
    global static List<String> globalErrors = new List<String>();
    
    public BatchInterface strategyInterface;
	
	public Cust360ToCaseAggregatorBatch(){
		 strategyInterface = new Aggregator_BatchInterface();
	}
	
	public Cust360ToCaseAggregatorBatch( BatchInterface testingInterface ){
		strategyInterface = testingInterface;
	}
	
    global Iterable<AggregateResult> start (Database.batchableContext info)
    {
        System.debug('Cust360ToCaseAggregatorBatch: start.' );
        Iterable<AggregateResult> queriedResult = Cust360AggregatorBatchService.getAggregateResultIterable();
        System.debug('Cust360ToCaseAggregatorBatch: queriedResult: ' + queriedResult);
        sObjectToAggregate = Cust360AggregatorBatchService.sObjectToAggregate;
        System.debug('Cust360ToCaseAggregatorBatch: sObjectToAggregate: ' + sObjectToAggregate );
        isLastSObjectToAggregate = Cust360AggregatorBatchService.isLastSObjectToAggregate;
        System.debug('Cust360ToCaseAggregatorBatch: isLastSObjectToAggregate: ' + isLastSObjectToAggregate );
        return queriedResult;
    }
    
    global void execute(SchedulableContext context){
        Cust360ToCaseAggregatorBatch batch = new Cust360ToCaseAggregatorBatch();
        Database.executeBatch(batch);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope)
    {
        System.debug('Cust360ToCaseAggregatorBatch:execute - scope: ' + scope );
        globalErrors.addAll( Cust360AggregatorBatchService.aggregateToCustomer360( scope ) );
    }

    global void finish(Database.BatchableContext BC)
    {
        System.debug( 'Cust360ToCaseAggregatorBatch:finish: isLastSObjectToAggregate: ' + isLastSObjectToAggregate);
        System.debug( 'Cust360ToCaseAggregatorBatch:finish: sObjectToAggregate: ' + sObjectToAggregate );
        
        if( isLastSObjectToAggregate )
        {
            System.debug( 'Cust360ToCaseAggregatorBatch:finish: updateAggregatingSobject-false.' );
            Cust360AggregatorBatchService.updateAggregatingSobject( sObjectToAggregate, false );
            
            /* Sends Emails */
            EmailMessageServices.sendBatchCompletedEmail(globalErrors, Cust360AggregatorBatchService.C360_AGGREGATOR_BATCH);
            
            /* Call Relationship Batch */
            strategyInterface.runRelationshipBatch();
        }
        else
        {
            System.debug( 'Cust360ToCaseAggregatorBatch:finish: updateAggregatingSobject-true.' );
            Cust360AggregatorBatchService.updateAggregatingSobject( sObjectToAggregate, true );
            Cust360ToCaseAggregatorBatch batch = new Cust360ToCaseAggregatorBatch( strategyInterface );
            Database.executeBatch(batch);
        }
    }
    
    /* Interface Used to Apply Testing */
    public class Aggregator_BatchInterface implements BatchInterface {
    	
    	public void runRelationshipBatch()
    	{
    		Cust360RelationshipBatch batch = new Cust360RelationshipBatch();
            Database.executeBatch(batch);
    	}
    }
    
    public Interface BatchInterface {
    	
    	void runRelationshipBatch();
    	
    }
}
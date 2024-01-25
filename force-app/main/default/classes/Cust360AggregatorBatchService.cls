public with sharing class Cust360AggregatorBatchService 
{
	public static String sObjectToAggregate;
	public static Boolean isLastSObjectToAggregate;
	public static String C360_AGGREGATOR_BATCH = 'C360 Aggregator Batch';

	public static List<C360_Customer_360_Rollup_Mapping__c>  customer360RollupMapping
	{
		get
		{
			if( customer360RollupMapping == NULL )
			{
				customer360RollupMapping = C360_Customer_360_Rollup_Mapping__c.getall().values();
			}
			return customer360RollupMapping;
		}
		private set;
	}


	public class CaseAggregateResultIterable implements Iterable<AggregateResult> 
	{
		public Iterator<AggregateResult> Iterator()
		{
			return new AggregateResultIterator( 'Case' );
		}
	}

	public class AccountAggregateResultIterable implements Iterable<AggregateResult> 
	{
		public Iterator<AggregateResult> Iterator()
		{
			return new AggregateResultIterator( 'Account' );
		}
	}

	public class OpportunityAggregateResultIterable implements Iterable<AggregateResult> 
	{
		public Iterator<AggregateResult> Iterator()
		{
			return new AggregateResultIterator( 'Opportunity' );
		}
	}

	public class AccountPlanAggregateResultIterable implements Iterable<AggregateResult> 
	{
		public Iterator<AggregateResult> Iterator()
		{
			return new AggregateResultIterator( 'AccountPlan' );
		}
	}

	public class QuoteAggregateResultIterable implements Iterable<AggregateResult> 
	{
		public Iterator<AggregateResult> Iterator()
		{
			return new AggregateResultIterator( 'Quote__c' );
		}
	}

	public class VendorDetailLinkAggregateResultIterable implements Iterable<AggregateResult> 
	{
		public Iterator<AggregateResult> Iterator()
		{
			return new AggregateResultIterator( 'Vendor_Detail_Link__c' );
		}
	}


	public class AggregateResultIterator implements Iterator<AggregateResult> 
	{
		AggregateResult [] results {get; set;}
		Integer index {get; set;} 
		String fieldsToAggregate = '';
		public List<String> parentFields = new List<String>();
		String groupByField = '';
		
		public AggregateResultIterator( String thisSObjectToAggregate ) 
		{
			sObjectToAggregate = thisSObjectToAggregate;
			index = 0;
			for(C360_Customer_360_Rollup_Mapping__c rollup : customer360RollupMapping) 
			{
				if(rollup.C360_Map_from_object__c.equalsIgnorecase( sObjectToAggregate ) ) 
				{
					fieldsToAggregate += rollup.C360_Aggregation_Type__c + '(' + rollup.C360_Map_from_field__c + ') ' + ', ';
					parentFields.add( rollup.name );
					groupByField = rollup.C360_Group_by_field__c; //Assuming groupby field is unique for aggregating sobject
				}
			}
			if( String.isNotBlank( groupByField ) )
			{
				String aggregateQuery = 'Select ' + fieldsToAggregate + groupByField + ' customer360Id from ' + sObjectToAggregate + ' where ' + groupByField + ' != null  group by ' + groupByField;
				System.debug('Building Query String: ' + aggregateQuery);
				results = Database.query(aggregateQuery);
			}
			else
			{
				results = new List<AggregateResult>();
			}
					
		} 

		public boolean hasNext()
		{ 
			return results != null && !results.isEmpty() && index < results.size(); 
		}    

		public AggregateResult next()
		{ 
			return results[index++];
		}
	}

	public static Iterable<AggregateResult> getAggregateResultIterable()
	{
		sObjectToAggregate = getAggregatingSobject();
		System.debug( sObjectToAggregate );

		if( String.isBlank( sObjectToAggregate ) )
		{
			return new List<AggregateResult>();
		}
		Type t = Type.forName( 'Cust360AggregatorBatchService.' + sObjectToAggregate + 'AggregateResultIterable' );
		if( sObjectToAggregate == 'Vendor_Detail_Link__c' )
		{
			t = Type.forName( 'Cust360AggregatorBatchService.VendorDetailLinkAggregateResultIterable' );
		}
		if( sObjectToAggregate == 'Quote__c' )
		{
			t = Type.forName( 'Cust360AggregatorBatchService.QuoteAggregateResultIterable');
		}
		if( t == null )
		{
			System.debug( 'class not found for ' + sObjectToAggregate + 'AggregateResultIterable' );
			return new List<AggregateResult>();
		}
		//todo error handling
		return (Iterable<AggregateResult>)t.newInstance(); 
	}

	public static String getAggregatingSobject()
	{
		Map<Decimal, List<C360_Customer_360_SObjects__c>> customer360AggregatingSObjects = GroupBy.Decimals( 'C360_Order__c', C360_Customer_360_SObjects__c.getall().values() );
		if (customer360AggregatingSObjects.isEmpty()){
		    isLastSObjectToAggregate = true;
		    return '';
		}
		
		isLastSObjectToAggregate = false;
		for( Decimal order : customer360AggregatingSObjects.keySet() )
		{
		    //System.debug('customer360AggregatingSObjects: ' + customer360AggregatingSObjects);
		    //System.debug('order: ' + order);
			C360_Customer_360_SObjects__c aRecord = customer360AggregatingSObjects.get( order )[0];
			//System.debug('aRecord: ' + aRecord);
			if( aRecord.C360_Is_Processed__c )
			{
				Decimal nextOrder = order + 1;
				//System.debug('nextOrder: ' + nextOrder);
				if( customer360AggregatingSObjects.containsKey( nextOrder ) )
				{
					isLastSObjectToAggregate = !customer360AggregatingSObjects.containsKey( nextOrder + 1);
					//System.debug('isLastSObjectToAggregate: ' + isLastSObjectToAggregate);
					return customer360AggregatingSObjects.get( nextOrder )[0].Name;
				}
				else {
				    isLastSObjectToAggregate = true;
				}
				return '';
			}
		}
		return customer360AggregatingSObjects.get( 1.0 )[0].Name;
	}

	public static void updateAggregatingSobject( String sObjectName, Boolean isProcessed )
	{
		List<C360_Customer_360_SObjects__c> customer360AggregatingSObjects = C360_Customer_360_SObjects__c.getall().values();
		for( C360_Customer_360_SObjects__c aSObjectCustomSetting : customer360AggregatingSObjects )
		{
			if( aSObjectCustomSetting.Name == sObjectName )
			{
				aSObjectCustomSetting.C360_Is_Processed__c = isProcessed;
			}
			else
			{
				aSObjectCustomSetting.C360_Is_Processed__c = false;
			}
		}
		system.debug('customer360AggregatingSObjects: ' + customer360AggregatingSObjects);
		update customer360AggregatingSObjects;
	}

	public static List<String> aggregateToCustomer360( List<Sobject> scope )
	{
		List<String> errors = new List<String>();
		
		if( scope.isEmpty() )
		{
			return errors;
		}
		System.debug('Cust360ToCaseAggregatorBatch:Cust360AggregatorBatchService: aggregateToCustomer360');
		Map<Id, AggregateResult> customer360IdToAggrResult = new Map<Id, AggregateResult>();

		for( Sobject sobjectRecords : scope )
		{
			AggregateResult ar = (AggregateResult)sobjectRecords;
			Id customer360Id = (Id)ar.get('customer360Id');
			customer360IdToAggrResult.put( customer360Id, ar );
		}
        System.debug('Cust360ToCaseAggregatorBatch:Cust360AggregatorBatchService: customer360IdToAggrResult - ' + customer360IdToAggrResult );
        
		List<SObject> customer360sToUpdate = new List<SObject>();
		Set<Id> parentIds = customer360IdToAggrResult.keyset();
		
		System.debug('Cust360ToCaseAggregatorBatch:Cust360AggregatorBatchService: parentIds - ' + parentIds );
		
		//AggregateResultIterator ari = new AggregateResultIterator( sObjectToAggregate );
		sObjectToAggregate = getAggregatingSobject();
		
		System.debug('Cust360ToCaseAggregatorBatch:Cust360AggregatorBatchService: sObjectToAggregate - ' + sObjectToAggregate );
		
		List<String> parentFields = getParentFields();
		String parentQuery = 'SELECT Id, ' + String.join( parentFields, ', ') + ' from C360_Customer_360__c where Id IN :parentIds';
		
		System.debug( 'Cust360ToCaseAggregatorBatch:Cust360AggregatorBatchService: parentQuery - ' + parentQuery );
		
		//for each affected parent object, retrieve aggregate results and 
		//for each field definition add aggregate value to parent field

		for( C360_Customer_360__c c360 : Database.query( parentQuery ) ) 
		{        
			Integer row = 0; //row counter reset for every parent record
			for( String fieldName : parentFields ) 
			{
				String field = 'expr' + row.format();
				AggregateResult aggrResult = customer360IdToAggrResult.get( c360.Id );
				//r will be null if no records exist 
				//(e.g. last record deleted)
				if( aggrResult != null ) 
				{ 
					Decimal value = ((Decimal)aggrResult.get(field) == null ) ? 0 : (Decimal)aggrResult.get(field);
					c360.put( fieldName, value);
				} 
				else 
				{
					c360.put( fieldName, 0);
				}
				row += 1; //plus 1 for every field definition after first
			}
			customer360sToUpdate.add(c360);
		}
        
		if(!customer360sToUpdate.isEmpty()){
			
			try{
				
				update customer360sToUpdate;
				
			}catch(DMLException e){
				
				//Loop over e and grab messages
				for(Integer i = 0; i < e.getNumDml(); i++){
				    errors.add('Error: ' + e.getDmlMessage(i));
				}
			}
		}
		
		
        System.debug( 'Cust360ToCaseAggregatorBatch:Cust360AggregatorBatchService: customer360sToUpdate - ' + customer360sToUpdate );
        System.debug( 'Cust360ToCaseAggregatorBatch:Cust360AggregatorBatchService: Pluck.ids( customer360sToUpdate ) - ' + Pluck.ids( customer360sToUpdate ) );
        
        return errors;
	}

	public static List<String> getParentFields()
	{
		List<String> parentFields = new List<String>();
		for(C360_Customer_360_Rollup_Mapping__c rollup : customer360RollupMapping) 
		{
			if(rollup.C360_Map_from_object__c.equalsIgnorecase( sObjectToAggregate ) ) 
			{
				parentFields.add( rollup.name );
			}
		}
		return parentFields;
	}

}
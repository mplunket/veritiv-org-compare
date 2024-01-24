public with sharing class Cust360RelationshipBatchServices {
	
	final public static String ACCOUNT_IGNORE = 'Account';
	final public static String EMPTY_RESULTS_QUERY = 'SELECT Id FROM Account WHERE Id = null';

	final public static String C360_FORMULA_FIELD = 'C360_Customer_360_ID_Formula__c';
	final public static String C360_ID_FIELD = 'C360_Customer_360__c';
	final public static String C360_RELATIONSHIP_BATCH = 'C360 Relationship Batch';
	final public static String RELATIONSHIP_BATCH_APEX_CLASS_NAME = 'Cust360RelationshipBatch';
	
	/*public static List<String> getUnprocessedObjects()
	{
		List<String> unprocessedObjects = new List<String>();
		
		List<C360_Customer_360_SObjects__c> customer360SObjects = C360_Customer_360_SObjects__c.getall().values();
		for(C360_Customer_360_SObjects__c sobj : customer360SObjects)
		{
			// Ignores Accounts and Objects that have isProcessing set to false;
			if(sobj.Name.equalsIgnoreCase(ACCOUNT_IGNORE) || sobj.C360_Is_Processed__c) 
				continue;
			
			unprocessedObjects.add(sobj.Name);
		}
		
		return unprocessedObjects;
	}*/
	
	public static String getUnprocessedObject()
	{
		List<String> unprocessedObjects = new List<String>();
		
		List<C360_Customer_360_SObjects__c> customer360SObjects = C360_Customer_360_SObjects__c.getall().values();
		for(C360_Customer_360_SObjects__c sobj : customer360SObjects)
			// Ignores Accounts and Objects that have isProcessing set to false;
			if(!sobj.Name.equalsIgnoreCase(ACCOUNT_IGNORE) && !sobj.C360_Is_Processed__c) 
				return sobj.Name;

		
		return '';
	}
	
	public static void updateCustomSettingSobject( String sObjectName )
	{
		
		C360_Customer_360_SObjects__c customer360SObject = C360_Customer_360_SObjects__c.getInstance( sObjectName );
		customer360SObject.C360_Is_Processed__c = true;

		update customer360SObject;
		
	}
	
	public static void resetProcessedSobjects()
	{
		List<C360_Customer_360_SObjects__c> customer360AggregatingSObjects = C360_Customer_360_SObjects__c.getall().values();
		for( C360_Customer_360_SObjects__c aSObjectCustomSetting : customer360AggregatingSObjects )
			aSObjectCustomSetting.C360_Is_Processed__c = false;
		
		system.debug('customer360AggregatingSObjects: ' + customer360AggregatingSObjects);
		update customer360AggregatingSObjects; 
	}
	
	public static String buildQuery(String currentSObject)
	{
		if(Cust360RelationshipBatch.objectsInOrg.contains(currentSObject.toLowerCase()))
			return 'SELECT '+ C360_ID_FIELD + ',' + C360_FORMULA_FIELD +' FROM ' + currentSObject;
		else 
		{
			Cust360RelationshipBatch.sObjectToProcess = '';
			Cust360RelationshipBatch.globalErrors.add('Object Does Not Exists: ' + currentSObject);
			return EMPTY_RESULTS_QUERY; // Should return no results.
		}
	}

	public static List<SObject> processFields(String formulaFieldName, String lookupFieldName, List<SObject> sobjs){
		// Check if Fields exist.
		List<SObject> objsToUpdate = new List<SObject>();
		Set<String> objFields = sobjs.getSObjectType().getDescribe().fields.getMap().keySet();
		System.debug('Lookup: ' + objFields.contains(lookupFieldName.toLowerCase()));
		if(objFields.contains(formulaFieldName.toLowerCase()) && objFields.contains(lookupFieldName.toLowerCase())){
			for(SObject singleObj : sobjs){
				// If they Exists compare them.
				if((Id)singleObj.get(formulaFieldName) != (Id)singleObj.get(lookupFieldName)){
					singleObj.put(C360_ID_FIELD, (Id)singleObj.get(C360_FORMULA_FIELD));
					objsToUpdate.add(singleObj);
				}
			}
		}
		
		return objsToUpdate;
	}

	public static List<String> updateC360s(List<SObject> objs){
	    List<String> errors = new List<String>();
	    
	    if( objs.isEmpty() )
			return errors;
	    
		List<SObject> updateTheseItems = processFields(C360_FORMULA_FIELD, C360_ID_FIELD, objs);
		if(!updateTheseItems.isEmpty()){
			try{
				update updateTheseItems;
			}catch(DMLException e){
				//Loop over e and grab messages
				for(Integer i = 0; i < e.getNumDml(); i++){
				    errors.add('Error: ' + e.getDmlMessage(i));
				}
			}
		}
		return errors;
	}

}
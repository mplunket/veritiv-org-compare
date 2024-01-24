public class TriggerProcessor {
    
     public static Map<Id, SObject> firstTimeStateMap{
    	get{
    		if( firstTimeStateMap == null )
    		{
    			firstTimeStateMap = new Map<Id, SObject>();
    			//System.debug('*** First Time State Map: ' + firstTimeStateMap);
    		}
    		
    		return firstTimeStateMap;
    	}
    	set;
    }
    
    public static Boolean runTrigger( Map<Id, SObject> triggerNewMap )
    {
    	List<String> allFields = new List<String>();
    	
    	Map<String, Schema.SObjectField> fieldMap = triggerNewMap.values()[0].getSObjectType().getDescribe().fields.getMap();
    	
    	for( String field : fieldMap.keySet() ){
    		
    		if( fieldMap.get( field ).getDescribe().isUpdateable() )
    			allFields.add( field );
    	}
    	
    	
    	Set<Id> triggerRecords = triggerNewMap.keySet();
    	Set<Id> stateMapRecords = firstTimeStateMap.keySet();
    	if( firstTimeStateMap.isEmpty() || triggerRecords != stateMapRecords )
    	{
			firstTimeStateMap.putAll( triggerNewMap );
			return true;
			
    	}
		
		for(Id idKey : triggerNewMap.keySet() )
		{	
			//System.debug('*** id key: '+idKey);
			//System.debug('*** trigger map: '+triggerNewMap.keySet() );
			//System.debug('*** firstTimeStateMap: '+ firstTimeStateMap);
			SObject storedState =  firstTimeStateMap.get( idKey );
			SObject currentState =  triggerNewMap.get( idKey );
			
			for( String field : allFields)
			{
				if( storedState.get( field ) != currentState.get( field ) )
				{
					return true;
				}
			}
			
		}    	
    	return false;
    }
    
}
/*

JSONUtils
	About:
		By leveraging JSON this tool can set *some* unwritable fields on SObject and create SObjects
		with *some* unwritable fields set (e.g LastModifiedDate).

	Methods:
		createSObject(Schema.SObjectType sobjType, Map<String, Object> fieldValues)
		createSObject(Schema.SObjectType sobjType, Map<Schema.SObjectField,Object> fieldValues)
			Returns an SObject

			Setups an Sobject of the given SObjectType 
			with the fields specified in the map.

		createSObjects(Integer howMany, Schema.SObjectType sobjType, Map<String, Object> fieldValues)
		createSObjects(Integer howMany, Schema.SObjectType sobjType, Map<Schema.SObjectField, Object> fieldValues)
			Returns a List of SObjects
			
			Setups an List of Sobjects of the given SObjectType 
			with the fields specified in the map.

		setField(SObject record, String field, Object value)
		setField(SObject record, Schema.SObjectField field, Object value)
			Returns Sobject
			
			Sets the specified field on the passed in SObject
			to specified value.

		setField(List<SObject> records, String field, Object value)
		setField(List<SObject> records, Schema.SObjectField field, Object value)
			Returns List of Sobject
			
			Sets the specified field on each SObject 
			in the provided List to specified value.

		setFields(SObject record, Map<String,Object> fieldValues)
		setFields(SObject record, Map<Schema.SObjectField,Object> fieldValues)
			Returns an SObject

			Sets the specified fields on the passed in SObject
			to specified values from the map.

		setFields(List<SObject> records, Map<Schema.SObjectField,Object> fieldValues)
		setFields(List<SObject> records, Map<String,Object> fieldValues)
			Returns a List of SObjects

			Sets the specified fields on each SObject 
			in the provided List to specified values 
			from the map.


*/
public class JSONUtils {
	private static final String DATEIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ';
	private static final String DATE_FORMAT = 'yyyy-MM-dd';
	private static final Time DEFAULT_TIME_FOR_DATE = Time.newInstance(0, 0, 0, 0);

	public static SObject createSObject(Schema.SObjectType sobjType, Map<String, Object> fieldValues){
        
        String jsondata1 = '{ "attributes" :'
        				+		'{"type" : "' + sobjType.getDescribe().getName() + '"}';

		jsondata1 = populateJSONFields(sobjType,jsondata1,fieldValues);

		SObject opp1 = (SObject) JSON.deserialize(jsondata1, SObject.class) ;
		
		return opp1;		
	}

	public static List<SObject> createSObjects(Integer howMany, Schema.SObjectType sobjType, Map<String, Object> fieldValues){
        List<SObject> objects = new List<SObject>();
        
		for (Integer i = 0; i < howMany; i++){
			objects.add(createSObject(sobjType, fieldValues));
		}
	
		return objects;			
	}

	public static SObject createSObject(Schema.SObjectType sobjType, Map<Schema.SObjectField,Object> fieldValues)
	{
		return createSObject(sobjType,convertMap(fieldValues));
	}


	public static List<SObject> createSObjects(Integer howMany, Schema.SObjectType sobjType, Map<Schema.SObjectField, Object> fieldValues)
	{
		List<SObject> objects = new List<SObject>();

    	for (Integer i = 0; i < howMany; i++){
			objects.add(createSObject(sobjType, fieldValues));
		}

		return objects;
    }

    public static SObject setField(SObject record, String field, Object value)
    {
    	return setFields(new List<SObject>{record},new Map<String,Object>{field => value})[0];
    }

    public static SObject setField(SObject record, Schema.SObjectField field, Object value)
    {
    	return setField(record,field.getDescribe().getName(),value);
    }

    public static List<SObject> setField(List<SObject> records, String field, Object value)
    {
    	return setFields(records, new Map<String,Object>{field => value});
    }

    public static List<SObject> setField(List<SObject> records, Schema.SObjectField field, Object value)
    {
    	return setField(records,field.getDescribe().getName(),value);
    }

    public static SObject setFields(SObject record, Map<String,Object> fieldValues)
    {
    	return setFields(new List<SObject>{record},fieldValues)[0];
    }

    public static SObject setFields(SObject record, Map<Schema.SObjectField,Object> fieldValues)
    {
    	return setFields(new List<SObject>{record},convertMap(fieldValues))[0];
    }

    public static List<SObject> setFields(List<SObject> records, Map<Schema.SObjectField,Object> fieldValues)
    {
    	return setFields(records,convertMap(fieldValues));
    }

    public static List<SObject> setFields(List<SObject> records, Map<String,Object> fieldValues)
    {
    	List<SObject> objs = new List<SObject>();
    	String jsonString;
    	for(Sobject record : records)
    	{
    		jsonString = JSON.serialize(record);
    		jsonString = jsonString.substring(0,jsonString.length()-1);
    		jsonString = populateJSONFields(record.getSobjectType(),jsonString,fieldValues);
    		objs.add((SObject) JSON.deserialize(jsonString, SObject.class));
    	}
    	return objs;
    }

    private static String populateJSONFields(Schema.SObjectType sobjType, String jsonString, Map<String,Object> fieldValues)
    {
    	Object fieldValue;
    	for (String field : fieldValues.keySet())
    	{	
			fieldValue = fieldValues.get(field);

			jsonString += ', "' +field+'":"';
			
			if( sobjType.getDescribe().fields.getMap().get(field).getDescribe().getType() == Schema.DisplayType.DATETIME
				&& 
				fieldValue instanceof Datetime
			  )
			{
				jsonString += ((Datetime)fieldValue).format(DATEIME_FORMAT) +'" ';	
			}
			else if(sobjType.getDescribe().fields.getMap().get(field).getDescribe().getType() == Schema.DisplayType.DATE
					&&
					fieldValue instanceof Date
				   )
			{
				jsonString += Datetime.newInstance((Date)fieldValue, DEFAULT_TIME_FOR_DATE).format(DATE_FORMAT) +'" ';
			}
			else
			{
				jsonString += fieldValue+'" ';
			}
		}
		jsonString += '}';

		return jsonString;
	}

	private static Map<String,Object> convertMap(Map<Schema.SObjectField, Object> schemaFieldMap)
	{
		Map<String,Object> fieldToValues = new Map<String,Object>();
		
		for(Schema.SObjectField field : schemaFieldMap.keySet())
		{
			fieldToValues.put(field.getDescribe().getName(),schemaFieldMap.get(field));
		}

		return fieldToValues;
	}
	
}
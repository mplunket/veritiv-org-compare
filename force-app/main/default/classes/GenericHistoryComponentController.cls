/*
	Original code: http://boards.developerforce.com/t5/Visualforce-Development/History-related-List-using-Visualforce/m-p/156208#M18714
*/

public class GenericHistoryComponentController {


	public static final String CREATE_BY_ID_TAG = 'CreatedById';
	public static final String CREATE_DATE_TAG  = 'CreatedDate';
	public static final String NEW_VALUE_TAG    = 'newValue';
	public static final String OLD_VALUE_TAG    = 'oldValue';
	public static final String FIELD_TAG        = 'Field';


    // External variables

    public static final Map<String, Schema.SObjectType> mySObjectTypeMap = Schema.getGlobalDescribe();
    public static Map<String, Schema.SObjectField> myObjectFieldMap;
    public static List<Schema.PicklistEntry> historyFieldPicklistValues;
    public static String objectHistoryTableName;
    public static String objectLabel {get;set;}

    public SObject myObject {get; set;}
    public Integer recordLimit {get; set;}

    // Internal Variables
    public ObjectHistoryLine[] objectHistory;
    public static final Integer DEFAULT_RECORD_LIMIT = 50;
    private static Id myObjectId;


    public List<ObjectHistoryLine> getObjectHistory(){

        List<ObjectHistoryLine> objectHistory = new List<ObjectHistoryLine>();

        if( !initSObjectDescribe() ) return objectHistory;

        if( recordLimit == null ){
            recordLimit = DEFAULT_RECORD_LIMIT;
        }

		if( myObjectId != null )
		{
	        List<sObject> historyList = Database.query( 'SELECT CreatedDate,'+
	                                                    'CreatedById,'+
	                                                    'Field,'+
	                                                    'NewValue,'+
	                                                    'OldValue ' +
	                                                    'FROM ' + objectHistoryTableName + ' ' +
	                                                    'WHERE ParentId =\'' + myObjectId + '\' ' +
	                                                    'ORDER BY CreatedDate DESC '+
	                                                    'LIMIT ' + String.valueOf(recordLimit));

			List<ObjectHistoryWrapper>  objHistoryWrapperList = generateObjectHistory ( historyList ) ;

	        objectHistory = createHistoryLinesFromHistory( objHistoryWrapperList );

			List<Id> userIdList = new List<Id>();
			for (ObjectHistoryLine myHistory : objectHistory){
			    userIdList.add(myHistory.userId);
			}
			Map<Id, User> userIdMap = new Map<ID, User>([SELECT Id, Name FROM User WHERE Id IN : userIdList]);

			for (ObjectHistoryLine myHistory : objectHistory){
			    if (userIdMap.containsKey(myHistory.userId) & (myHistory.who != '') ){
			        myHistory.who = userIdMap.get(myHistory.who).Name;
			    }
			}
		}

        return objectHistory;
    }

    // Function to return Field Label of a object field given a Field API name
    public static String returnFieldLabel(String fieldName){

        if (GenericHistoryComponentController.myObjectFieldMap.containsKey(fieldName)){
            return GenericHistoryComponentController.myObjectFieldMap.get(fieldName).getDescribe().getLabel();
        }
        else {
            for(Schema.PicklistEntry pickList : historyFieldPicklistValues){
                if (pickList.getValue() == fieldName){
                    if (pickList.getLabel() != null){
                        return pickList.getLabel();
                    }
                    else {
                        return pickList.getValue();
                    }
                }
            }
        }
        return '';
    }

	public Boolean initSObjectDescribe()
	{
		if( myObject == null ) return false;

		myObjectId = String.valueOf(myObject.get('Id'));
        Schema.DescribeSObjectResult objectDescription = myObject.getSObjectType().getDescribe();

        myObjectFieldMap = objectDescription.fields.getMap();
        GenericHistoryComponentController.objectLabel = String.valueOf(objectDescription.getLabel());

        //Get the name of the history table
        objectHistoryTableName = objectDescription.getName();
        //if we have a custom object we need to drop the 'c' off the end before adding 'History' to get the history tables name
        if (objectDescription.isCustom()){
            objectHistoryTableName = objectHistoryTableName.substring(0, objectHistoryTableName.length()-1);
        }
        objectHistoryTableName = objectHistoryTableName + 'History';

        Schema.DescribeFieldResult objectHistoryFieldField = mySObjectTypeMap.get(objectHistoryTableName).getDescribe().fields.getMap().get('Field').getDescribe();
        historyFieldPicklistValues = objectHistoryFieldField.getPickListValues();

        return true;
	}


	/*
		@param List<sObject>
		@return List<ObjectHistoryWrapper>
	*/
	public List<ObjectHistoryWrapper> generateObjectHistory ( List<sObject> historyObject ){

		List<ObjectHistoryWrapper> wrapper = new List<ObjectHistoryWrapper>();

		for  ( sObject hObject : historyObject ){

			  ObjectHistoryWrapper	ohw = new ObjectHistoryWrapper ();
			  ohw.createdById = (Id) hObject.get( CREATE_BY_ID_TAG );
			  ohw.createdDate = (Datetime) hObject.get( CREATE_DATE_TAG );
			  ohw.newValue    = hObject.get( NEW_VALUE_TAG );
			  ohw.oldValue    = hObject.get( OLD_VALUE_TAG );
			  ohw.field       = hObject.get( FIELD_TAG );
			  ohw.fieldLabel  = GenericHistoryComponentController.returnFieldLabel ( String.valueOf ( ohw.field ) );
			  wrapper.add ( ohw );
		}

		return wrapper;
	}

	public List<ObjectHistoryLine> createHistoryLinesFromHistory( List<ObjectHistoryWrapper> incomingHistoryRecords )
	{
        String prevDate = '';
		List<ObjectHistoryLine> objectHistory = new List<ObjectHistoryLine>();

		for( ObjectHistoryWrapper historyLine : incomingHistoryRecords )
        {
            if ((historyLine.newValue == null && historyLine.oldValue == null)
                    || (historyLine.newValue != null && !(string.valueOf(historyLine.newValue).startsWith('005') || string.valueOf(historyLine.newValue).startsWith('00G')))
                    || (historyLine.oldValue != null && !(string.valueOf(historyLine.oldValue).startsWith('005') || string.valueOf(historyLine.oldValue).startsWith('00G')))){

				ObjectHistoryLine tempHistory = new ObjectHistoryLine();
		        // Set the Date and who performed the action
		        if (String.valueOf(historyLine.createdDate ) != prevDate){
		            tempHistory.theDate = historyLine.createdDate.format();
		            tempHistory.userId = String.valueOf(historyLine.createdById );
		            tempHistory.who = String.valueOf(historyLine.createdById );
		        }
		        // do not need to reshow date and user if the action occurred at the same time
		        else{
		            tempHistory.theDate = '';
		            tempHistory.who = '';
		            tempHistory.userId = String.valueOf(historyLine.createdById );
		        }
		        prevDate = String.valueOf(historyLine.createdDate );

		        // Get the field label
		        String fieldLabel = historyLine.fieldLabel;

		        // Set the Action value
				if (String.valueOf(historyLine.field) == 'created') {    // on Creation
					tempHistory.action = 'Created.';
				}
				else if (historyLine.oldValue != null && historyLine.newValue == null){ // when deleting a value from a field
					// Format the Date and if there's an error, catch it and reformat as string
					try {
						tempHistory.action = 'Deleted ' + Date.valueOf(historyLine.oldValue).format() + ' in <b>' + fieldLabel + '</b>.';
					} catch (Exception e){
						tempHistory.action = 'Deleted ' + String.valueOf(historyLine.oldValue) + ' in <b>' + fieldLabel + '</b>.';
					}
				}
				else{  // all other scenarios
					String fromText = '';
		            if (historyLine.oldValue != null) {
						try {
							fromText = ' from ' + Date.valueOf(historyLine.oldValue).format();
						} catch (Exception e) {
							fromText = ' from ' + String.valueOf(historyLine.oldValue);
						}
					}

					String toText = '';
					if (historyLine.oldValue != null) {
						try {
							toText = Date.valueOf(historyLine.newValue).format();
						} catch (Exception e) {
							toText = String.valueOf(historyLine.newValue);
						}
					}
					if (toText != ''){
						tempHistory.action = 'Changed <b>' + fieldLabel + '</b>' + fromText + ' to <b>' + toText + '</b>.';
					}
					else {
		                tempHistory.action = 'Changed <b>' + fieldLabel;
		            }
				}

				// Add to the list
				objectHistory.add(tempHistory);
            }
		}

		return objectHistory;
	}

    // Inner Class to store the detail of the object history lines
    public class ObjectHistoryLine {

        public transient String theDate {get; set;}
        public transient String who {get; set;}
        public transient Id userId {get; set;}
        public transient String action {get; set;}
    }

	public class ObjectHistoryWrapper {

		public String   fieldLabel  {get; set;}
		public Object   field  {get; set;}
		public Object   newValue  {get; set;}
		public Object   oldValue  {get; set;}
		public Id       createdById  {get; set;}
		public Datetime createdDate  {get; set;}

	}

}
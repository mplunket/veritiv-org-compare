public with sharing class customLookUpController {
    
    @AuraEnabled
    public static List<sObject> fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'SELECT id, Name FROM ' + ObjectName + ' WHERE Name LIKE: searchKey order by createdDate DESC limit 5';
        List <sObject> lstOfRecords = Database.query(sQuery);
		
        List <sObject> returnList = new List <sObject> ();
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        
        return returnList;
    }
    
   	@AuraEnabled
    public static List<sObject> fetchRecords(String objectName, String filterField, String searchString) {
        String query = 'SELECT Id, ' + filterField+
                        ' FROM '+objectName+
                        ' WHERE '+filterField+' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' LIMIT 50000';
 
        return Database.query(query);
    }
}
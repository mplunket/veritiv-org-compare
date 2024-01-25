/**
 * @description       : 
 * @author            : Khushi Gambhir
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Khushi Gambhir
**/
global without sharing class MigrationHelper {
    
    global static final String STOREFRONT = 'Veritiv';
    global static final String MODULE_NAME = 'Migration Module';
    global static final String CLASSNAME = 'MigrationHelper';

    public static Map<String,Object> getObjectData(){
        Map<String,Object> dataMap = new Map<String,Object>();
        Map<String,Object> objectMap = new Map<String,Object>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        if(schemaMap != null){
            for (Schema.SObjectType schemaObj : schemaMap.values())
            {
                Schema.DescribeSObjectResult objResult = schemaObj.getDescribe();
                objectMap.put(objResult.getLabel(), objResult.getName());
            }
        }
        dataMap.put('objectMap',objectMap);
        List<NamedCredential> nameCredList = getNamedCredentials();
        if(!nameCredList.isEmpty()){
            dataMap.put('namedCredentialList',nameCredList);
        }
        return dataMap;
    }

    public static Map<String,Object> getFieldData(Map<String,Object> mapParams){
        Map<String,Object> dataMap = new Map<String,Object>();
        String objectName = '';
        if(mapParams.containsKey('objectName') && String.isNotBlank(String.valueOf(mapParams.get('objectName'))))
        {
            objectName = String.valueOf(mapParams.get('objectName'));
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            if(schemaMap != null && schemaMap.containsKey(objectName) && schemaMap.get(objectName) != null){
                Schema.SObjectType objSchema = schemaMap.get(objectName);
                Map<String, Schema.SObjectField> objFieldMap = objSchema.getDescribe().fields.getMap();
                for(String field : objFieldMap.keySet()){
                    Schema.DescribeFieldResult fieldObj = objFieldMap.get(field).getDescribe();
                    if(fieldObj.isUpdateable() || fieldObj.getRelationshipOrder() == 0 || field == 'CreatedDate' || field == 'LastModifiedDate'){
                        dataMap.put(fieldObj.getLabel(),fieldObj.getName());
                    }
                }
            }
        }
        return dataMap;
    }

    public static List<NamedCredential> getNamedCredentials(){
        String methodName = 'getNamedCredentials';
        String supportData = '';
        List<NamedCredential> nameCredList = null;
        try {
            nameCredList = [SELECT Id, DeveloperName, MasterLabel FROM NamedCredential];
        }
        catch(Exception expObject)
        {
            System.debug('Exception - '+expObject);
            dcm_CustomException.storeExceptionLog(expObject, STOREFRONT , MODULE_NAME, CLASSNAME , methodName , supportData );
        }
        return nameCredList;
    }

    public static Map<String,Object> submitMigrationObject(Map<String,Object> dataMap){
        if(dataMap != null &&
            dataMap.containsKey('objectName') && String.isNotBlank(String.valueOf(dataMap.get('objectName'))) &&
            dataMap.containsKey('objectLabel') && String.isNotBlank(String.valueOf(dataMap.get('objectLabel'))) &&
            dataMap.containsKey('namedCredential') && String.isNotBlank(String.valueOf(dataMap.get('namedCredential'))) &&
            dataMap.containsKey('operation') && String.isNotBlank(String.valueOf(dataMap.get('operation'))) &&
            dataMap.containsKey('sequence') && Integer.valueOf(dataMap.get('sequence')) != null &&
            dataMap.containsKey('fieldsList') && dataMap.get('fieldsList') != null
            )
        {
            String whereClause;
            String csvHeaderString;
            String relationshipString;
            String valString;
            String destinationExtId;
            Integer limitValue;
            Boolean active;
            String objectName = String.valueOf(dataMap.get('objectName'));
            String objectLabel = String.valueOf(dataMap.get('objectLabel'));
            String namedCredential = String.valueOf(dataMap.get('namedCredential'));
            String operation = String.valueOf(dataMap.get('operation'));
            Integer sequence = Integer.valueOf(dataMap.get('sequence'));
            List<String> fieldsList = (List<String>)Json.deserialize(String.valueOf(dataMap.get('fieldsList')), List<String>.class);
            String fieldStr = String.join(fieldsList,',');

            Migration_Object__c obj = new Migration_Object__c();
            obj.Name = objectLabel;
            obj.Object_Api_Name__c = objectName;
            obj.Named_Credential__c = namedCredential;
            obj.Operation__c = operation;
            obj.Sequence__c = sequence;
            obj.Fields__c = fieldStr;

            if(dataMap.containsKey('whereClause') && String.isNotBlank(String.valueOf(dataMap.get('whereClause')))){
                whereClause = String.valueOf(dataMap.get('whereClause'));
                obj.Where_Clause__c = whereClause;
            }
            if(dataMap.containsKey('destinationExtId') && String.isNotBlank(String.valueOf(dataMap.get('destinationExtId')))){
                destinationExtId = String.valueOf(dataMap.get('destinationExtId'));
                obj.Destination_External_Id__c = destinationExtId;
            }
            if(dataMap.containsKey('csvHeaderMap') && String.isNotBlank(String.valueOf(dataMap.get('csvHeaderMap')))){
                csvHeaderString = String.valueOf(dataMap.get('csvHeaderMap'));
                obj.CSV_Header_Override_Map__c = csvHeaderString;
            }
            if(dataMap.containsKey('relationshipMap') && String.isNotBlank(String.valueOf(dataMap.get('relationshipMap')))){
                relationshipString = String.valueOf(dataMap.get('relationshipMap'));
                obj.Relationship_Mapping__c = relationshipString;
            }
            if(dataMap.containsKey('valueMap') && String.isNotBlank(String.valueOf(dataMap.get('valueMap')))){
                valString = String.valueOf(dataMap.get('valueMap'));
                obj.Values_Map__c = valString;
            }
            if(dataMap.containsKey('limitValue') && Integer.valueOf(dataMap.get('limitValue')) != null){
                limitValue = Integer.valueOf(dataMap.get('limitValue'));
                obj.Limit_Records__c = limitValue;
            }
            if(dataMap.containsKey('active') && Boolean.valueOf(dataMap.get('active')) != null){
                active = Boolean.valueOf(dataMap.get('active'));
                obj.Active__c = active;
            }
            if(obj != null){
                insert obj;
                dataMap.put('migrationObject',obj);
            }
        }
        return dataMap;
    }
}
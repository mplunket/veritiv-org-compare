/**
 * @description       : 
 * @author            : Khushi Gambhir
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Khushi Gambhir
**/
global without sharing class MigrationController {

    global static final String STOREFRONT = 'Veritiv';
    global static final String MODULE_NAME = 'Migration Module';
    global static final String CLASSNAME = 'MigrationController';

    @AuraEnabled
    public static Map<String,Object> getObjectData(){
        String methodName = 'getObjectData';
        String supportData = '';
        Map<String,Object> dataMap = new Map<String,Object>();
        try {
            dataMap = MigrationHelper.getObjectData();
        }
        catch(Exception expObject)
        {
            System.debug('Exception - '+expObject);
            dcm_CustomException.storeExceptionLog(expObject, STOREFRONT , MODULE_NAME, CLASSNAME , methodName , supportData );
        }
        return dataMap;
    }

    @AuraEnabled
    public static Map<String,Object> getFieldData(Map<String,Object> mapParams){
        String methodName = 'getFieldData';
        String supportData = '';
        Map<String,Object> dataMap = new Map<String,Object>();
        try {
            dataMap = MigrationHelper.getFieldData(mapParams);
        }
        catch(Exception expObject)
        {
            System.debug('Exception - '+expObject);
            dcm_CustomException.storeExceptionLog(expObject, STOREFRONT , MODULE_NAME, CLASSNAME , methodName , supportData );
        }
        return dataMap;
    }

    @AuraEnabled
    public static Map<String,Object> submitMigrationObject(Map<String,Object> dataMap){
        String methodName = 'submitMigrationObject';
        String supportData = '';
        try {
            dataMap = MigrationHelper.submitMigrationObject(dataMap);
        }
        catch(Exception expObject)
        {
            System.debug('Exception - '+expObject);
            dcm_CustomException.storeExceptionLog(expObject, STOREFRONT , MODULE_NAME, CLASSNAME , methodName , supportData );
        }
        return dataMap;
    }

}
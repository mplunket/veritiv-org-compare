public with sharing class MigrationHandler {


    public static void initMigration(){
        List<Migration_Object__c> migrationObjectList = [SELECT Id FROM Migration_Object__c WHERE Sequence__c!=NULL AND Status__c = null AND Active__c=true ORDER BY Sequence__c ASC LIMIT 1 ];
        if(!migrationObjectList.isEmpty()){
            initMigration(migrationObjectList.get(0).Id);
        }
    }

    public static void initMigration(Id migrationObjectId){
        
    }
}
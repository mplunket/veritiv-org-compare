public with sharing class GenerateErrorBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    public String  migrationObjectId {get;set;}

    public GenerateErrorBatch(String migrationObjectId){
        this.migrationObjectId = migrationObjectId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> statusList = new List<String>{'Job Failed','Job Partial Success'} ;
        String query = 'SELECT Id,Bulk_JobId__c,Job_Status__c,Migration_Object__r.Named_Credential__c,Total_Records__c  FROM Migration_File__c WHERE Migration_Object__c=:migrationObjectId AND  Bulk_JobId__c != null AND Job_Status__c IN: statusList ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Migration_File__c> mFiles){
        Migration_File__c mFile = mFiles.get(0);
        List<Attachment> attList = new List<Attachment>();
        Attachment att = BulkApiService.fetchFailedRecords(mfile.Migration_Object__r.Named_Credential__c,mfile.Bulk_JobId__c,migrationObjectId);
        if(att!=null){
            attList.add(att);
        }
        if(!attList.isEmpty()){
            insert attList;
        }
    }

    public void finish(Database.BatchableContext bc){

    }
}
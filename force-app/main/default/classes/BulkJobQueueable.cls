/**
 * @description       : 
 * @author            : Abhishek
 * @group             : RafterOne
 * @last modified on  : 01-30-2023
 * @last modified by  : Abhishek
 * Modifications Log
 * Ver   Date         Author     Modification
 * 1.0   01-24-2023   Abhishek   Initial Version
**/
public with sharing class BulkJobQueueable implements Queueable,Database.AllowsCallouts{

    public String  migrationObjectId {get;set;}

    public BulkJobQueueable(String migrationObjectId){
        this.migrationObjectId = migrationObjectId ;
    }

    public void submitMigrationBulk(){
        List<Migration_File__c> migrationFiles = [SELECT Id,Migration_Object__c,Migration_Object__r.Named_Credential__c,Migration_Object__r.Destination_External_Id__c,Migration_Object__r.Object_Api_Name__c,Migration_Object__r.Operation__c  FROM Migration_File__c WHERE Migration_Object__c=:migrationObjectId AND  Bulk_JobId__c=null AND Job_Status__c='Data Generated' LIMIT 1];
        if(!migrationFiles.isEmpty()){
            //Submit BULK JOB
            Migration_File__c mfile = migrationFiles.get(0);
            system.debug(mfile.Id);
            List<Attachment> attachments = [SELECT Id,Body FROM Attachment WHERE parentId =:mfile.Id LIMIT 1];
            if(!attachments.isEmpty()){
                Attachment attch = attachments.get(0);
                String csvStr = attch.Body.toString() ;
                String bulkJobId = BulkApiService.createBulkJobId(mfile.Migration_Object__r.Named_Credential__c,mfile.Migration_Object__r.Object_Api_Name__c, mfile.Migration_Object__r.Operation__c,mfile.Migration_Object__r.Destination_External_Id__c) ;
                if(String.isNotBlank(bulkJobId)){
                    BulkApiService.uploadDataToBulkJob(mfile.Migration_Object__r.Named_Credential__c,bulkJobId, csvStr);
                    BulkApiService.submitBulkJob(mfile.Migration_Object__r.Named_Credential__c,bulkJobId);
                    mfile.Bulk_JobId__c = bulkJobId ;
                    mfile.Job_Status__c = 'Job Submitted' ;
                    update mfile;
                }else{
                    mfile.Job_Status__c = 'Job Failed' ;
                    update mfile;
                }
            }else{
                mfile.Job_Status__c = 'Job Failed' ;
                update mfile;
            }
            System.enqueueJob(new BulkJobQueueable(migrationObjectId), MigrationConstant.QUEUEABLE_DEPLAY);
        }else{
            checkBulkStatus();
        }
    }

    public void checkBulkStatus(){
        List<Migration_File__c> submittedMigrationFiles = [SELECT Id,Bulk_JobId__c,Job_Status__c,Migration_Object__r.Named_Credential__c,Total_Records__c  FROM Migration_File__c WHERE Migration_Object__c=:migrationObjectId AND  Bulk_JobId__c != null AND Job_Status__c IN ('Job Submitted') ORDER BY LASTMODIFIEDDATE ASC LIMIT 5];
        if(!submittedMigrationFiles.isEmpty()){
            List<Attachment> attList = new List<Attachment>();
            for(Migration_File__c mFile : submittedMigrationFiles){
                Map<String, Object> respMap = BulkApiService.getBulkJobInfo(mfile.Migration_Object__r.Named_Credential__c,mfile.Bulk_JobId__c);
                system.debug('respMap - '+respMap);
                if(respMap.containsKey('state')){
                    mFile.Job_End_Time__c = Datetime.now() ;
                    mFile.Failed_Record__c = respMap.containsKey('numberRecordsFailed') ? Integer.valueOf(respMap.get('numberRecordsFailed')) : 0 ;
                    mFile.Successful_Record__c = respMap.containsKey('numberRecordsProcessed') ? Integer.valueOf(respMap.get('numberRecordsProcessed')) : 0 ;
                    mFile.Successful_Record__c = mFile.Successful_Record__c - mFile.Failed_Record__c  ;
                    if(String.valueOf(respMap.get('state')) == 'JobComplete'){
                        if(mFile.Failed_Record__c > 0 && mFile.Successful_Record__c > 0){
                            mFile.Job_Status__c = 'Job Partial Success' ;
                        }else if(mFile.Failed_Record__c == 0){
                            mFile.Job_Status__c ='Job Successful' ;
                        }else{
                            mFile.Job_Status__c ='Job Failed' ;
                        }
                    }else if(String.valueOf(respMap.get('state')) == 'Failed' || String.valueOf(respMap.get('state')) == 'Aborted'){
                        mFile.Job_Status__c = 'Job Failed' ;
                    }
                    if(mFile.Job_Status__c == 'Job Partial Success' || mFile.Job_Status__c == 'Job Failed'){
                        Attachment att = BulkApiService.fetchFailedRecords(mfile.Migration_Object__r.Named_Credential__c,mfile.Bulk_JobId__c,migrationObjectId);
                        if(att!=null){
                            attList.add(att);
                        }
                    }
                }
            }
            update submittedMigrationFiles;
            if(!attList.isEmpty()){
                insert attList;
            }
            System.enqueueJob(new BulkJobQueueable(migrationObjectId), MigrationConstant.QUEUEABLE_DEPLAY);
        }else{
            Migration_Object__c mgObject = [SELECT Id,Failed_Record__c,Sequence__c FROM Migration_Object__c WHERE Id =: migrationObjectId ];
            mgObject.End_Date__c = Datetime.now();
            mgObject.Status__c = mgObject.Failed_Record__c > 0 ? 'Failed' : 'Completed' ;
            update mgObject;
            if(mgObject.Status__c == 'Completed'){
                List<Migration_Object__c> migrationObjectList = [SELECT Id FROM Migration_Object__c WHERE Sequence__c >: mgObject.Sequence__c AND Sequence__c!=NULL AND Status__c ='Inprogress' AND Active__c=true ORDER BY Sequence__c ASC LIMIT 1 ];
                if(!migrationObjectList.isEmpty()){
                    System.enqueueJob(new BulkJobQueueable(migrationObjectList.get(0).Id));
                }
            }
        }
    }

    public void execute(QueueableContext context) {
        submitMigrationBulk();
    }

}
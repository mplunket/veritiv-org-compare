/**
 * @description       :
 * @author            : Abhishek
 * @group             : RafterOne
 * @last modified on  : 02-02-2023
 * @last modified by  : Abhishek
 * Modifications Log
 * Ver   Date         Author     Modification
 * 1.0   01-16-2023   Abhishek   Initial Version
**/
public with sharing class GenerateBulkCSVBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    private class GenerateBulkCSVException extends Exception {

    }

    public String  objectName{get;set;} //'ccrz__E_Cart__c'
    public List<String>  queryFields{get;set;} //'Name,ccrz__Account__c'
    public List<String> dataList{get;set;}
    public String whereClause {get;set;}
    public String statusField {get;set;}
    public String namedCredential {get;set;}
    public Integer limitClause {get;set;}
    public Boolean createAttachment{get;set;}
    public Boolean submitBulk {get;set;}
    public String  operation {get;set;}
    public String  sourceExtId {get;set;}
    public String  destinationExtId {get;set;}
    public String  migrationObjectId {get;set;}
    public Boolean  fetchIdsFromDestination {get;set;}

    public Integer sequence {get;set;}

    public Map<String,String>  relationshipFieldsMap{get;set;} //ownerId => owner.username,ccrz__Account__c => ccrz__Account__r.AccountNumber
    public Map<String,String>  csvFieldsMap{get;set;} 
    public Map<String,String>  fieldValuesMap{get;set;} 


    public GenerateBulkCSVBatch(String migrationObjectId,Boolean submitBulk){
        List<Migration_Object__c> migrationObjectList = [SELECT Id, Name, Object_Api_Name__c, Fields__c, Relationship_Mapping__c, Named_Credential__c, Sequence__c, Status__c, Where_Clause__c, Limit_Records__c, Status_Field__c, Destination_External_Id__c,CSV_Header_Override_Map__c,Values_Map__c, Operation__c FROM Migration_Object__c WHERE Id=:migrationObjectId AND Active__c=true];
        if(!migrationObjectList.isEmpty()){
            Migration_Object__c mgObject = migrationObjectList.get(0);
            if(verifyMigrationObject(mgObject)){
                this.migrationObjectId = migrationObjectId;
                this.objectName = mgObject.Object_Api_Name__c ;
                this.queryFields = mgObject.Fields__c.split(',') ;
                this.relationshipFieldsMap = String.isNotBlank(mgObject.Relationship_Mapping__c) ? (Map<String,String>)JSON.deserialize(mgObject.Relationship_Mapping__c, Map<String,String>.class) : new Map<String,String>()  ;
                this.csvFieldsMap = String.isNotBlank(mgObject.CSV_Header_Override_Map__c) ? (Map<String,String>)JSON.deserialize(mgObject.CSV_Header_Override_Map__c, Map<String,String>.class) : new Map<String,String>()  ;
                this.fieldValuesMap = String.isNotBlank(mgObject.Values_Map__c) ? (Map<String,String>)JSON.deserialize(mgObject.Values_Map__c, Map<String,String>.class) : new Map<String,String>()  ;
                this.whereClause = mgObject.Where_Clause__c ;
                this.statusField = mgObject.Status_Field__c ;
                this.namedCredential = mgObject.Named_Credential__c ;
                this.limitClause = Integer.valueOf(mgObject.Limit_Records__c) ;
                this.createAttachment = true ;
                this.submitBulk = submitBulk ;
                if(objectName.equalsIgnoreCase('Attachment') || objectName.equalsIgnoreCase('ContentWorkspaceDoc')){
                    this.createAttachment = false ;
                    this.submitBulk = false ;
                }
                this.operation = mgObject.Operation__c  ;
                this.sourceExtId = 'Id' ;
                this.sequence =  mgObject.Sequence__c != null ? Integer.valueOf(mgObject.Sequence__c): null ;
                this.destinationExtId = mgObject.Destination_External_Id__c ;
                mgObject.Status__c = 'Inprogress';
                mgObject.Start_Date__c = Datetime.now();
                update mgObject;
            }else{
                throw new GenerateBulkCSVException('Migration Object setup is incorrect.');
            }
        }else{
            throw new GenerateBulkCSVException('Migration Object not found.');
        }
    }

    public GenerateBulkCSVBatch(String migrationObjectId){

        this(migrationObjectId,false);
    }

    public Boolean verifyMigrationObject(Migration_Object__c mgObject){
        return true;
    }

    public String getHeaderCsv(){
        List<String>  queryFieldsNew = new List<String>();
        for(String str : queryFields){
            if(operation == 'upsert' && (str.equalsIgnoreCase('CreatedDate') || str.equalsIgnoreCase('LastModifiedDate') )){
                continue;
            }
            if(csvFieldsMap.containsKey(str)){
                queryFieldsNew.add(csvFieldsMap.get(str));
            }else{
                queryFieldsNew.add(str);
            }
        }
        if(queryFieldsNew.contains(sourceExtId)){
            if(String.isNotBlank(destinationExtId)){
                queryFieldsNew.set(queryFieldsNew.indexOf(sourceExtId), destinationExtId);
            }else{
                queryFieldsNew.remove(queryFieldsNew.indexOf(sourceExtId));
            }
        }
        System.debug('queryFieldsNew : '+queryFieldsNew);
        return String.join(queryFieldsNew, MigrationConstant.COLUMN_DELIMITER_CHAR);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String>  queryFieldsNew = new List<String>();
        for(String field : queryFields){
            field = field.trim();
            queryFieldsNew.add(field);
        }
        if(!queryFieldsNew.contains(sourceExtId)){
            queryFieldsNew.add(sourceExtId);
        }
        queryFields = queryFieldsNew;
        dataList = new List<String>{getHeaderCsv()};
        String query = ' SELECT Id FROM '+objectName+' ';
        if(String.isNotBlank(whereClause)){
            query += whereClause ;
        }
        if(limitClause != null){
            query += ' LIMIT :limitClause ' ;
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<sObject> scopeIds){
        String relationShipFields = '';
        if(!relationshipFieldsMap.isEmpty()){
            for(String rField : relationshipFieldsMap.keySet() ){
                if(!queryFields.contains(rField)){
                    relationShipFields += ' , '+rField ;
                }
            }
        }

        String query = ' SELECT '+String.join(queryFields, ',')+relationShipFields+' FROM '+objectName+' WHERE ID IN: scopeIds ';
        List<sObject> scope = Database.query(query);
        Map<String,String> idsMap = relationshipFieldsMap.isEmpty() ? new Map<String,String>() :  getNewIdsMap(scope);
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        List<Migration_File__c> migrationAttachmentFiles = new List<Migration_File__c>();
        for(sObject sobj : scope ){
            if(objectName.equalsIgnoreCase('Attachment')){
                Attachment att = (Attachment)sobj;
                Migration_File__c mFile = new Migration_File__c();
                mFile.Migration_Object__c = migrationObjectId  ;
                mFile.Bulk_JobId__c = att.Id ;
                mFile.Job_Start_Time__c = Datetime.now() ;
                mFile.Job_End_Time__c = Datetime.now() ;
                mFile.Total_Records__c = 1  ;
                mFile.Successful_Record__c = 0 ;
                mFile.Job_Status__c ='Job Failed';
                if(idsMap.containsKey(att.ParentId)){
                    Boolean isAttachmentSuccess = BulkApiService.pushAttachment(namedCredential,idsMap.get(att.ParentId),att);
                    mFile.Job_Status__c = isAttachmentSuccess ? 'Job Successful' : 'Job Failed' ;
                    mFile.Successful_Record__c = isAttachmentSuccess ? 1 : 0 ;
                }
                mFile.Failed_Record__c = mFile.Total_Records__c - mFile.Successful_Record__c  ;
                migrationAttachmentFiles.add(mFile);
            }else if(objectName.equalsIgnoreCase('ContentWorkspaceDoc')){
                ContentWorkspaceDoc cwd = (ContentWorkspaceDoc)sobj;
                ContentVersion version = cwd.ContentDocument.LatestPublishedVersion ;
                Migration_File__c mFile = new Migration_File__c();
                mFile.Migration_Object__c = migrationObjectId  ;
                mFile.Bulk_JobId__c = version.Id ;
                mFile.Job_Start_Time__c = Datetime.now() ;
                mFile.Job_End_Time__c = Datetime.now() ;
                mFile.Total_Records__c = 1  ;
                mFile.Successful_Record__c = 0 ;
                String cvId = BulkApiService.pushContentVersion(namedCredential,version);
                mFile.Job_Status__c = String.isNotBlank(cvId) ? 'Job Successful' : 'Job Failed' ;
                mFile.Successful_Record__c = String.isNotBlank(cvId) ? 1 : 0 ;
                mFile.Failed_Record__c = mFile.Total_Records__c - mFile.Successful_Record__c  ;
                migrationAttachmentFiles.add(mFile);
                String cvQuery = 'SELECT+ContentDocumentId+FROM+ContentVersion+WHERE+Id'+'+=\''+cvId+'\'+';
                List<Object> recordList = BulkApiService.doQuery(namedCredential,cvQuery);
                if(recordList!=null && !recordList.isEmpty()){
                    Map<String,Object> objectMap = (Map<String,Object>)recordList.get(0);
                    String contentDocumentId = (String)objectMap.get('ContentDocumentId');
                    String folderName = fieldValuesMap.get('destinationFolderName');
                    List<Object> contentWorkSpaceList = BulkApiService.doQuery(namedCredential,'SELECT+Id+FROM+ContentWorkspace+WHERE+Name'+'=\''+folderName+'\'+');
                    if(contentWorkSpaceList != null && !contentWorkSpaceList.isEmpty()){
                        Map<String,Object> cwMap = (Map<String,Object>)contentWorkSpaceList.get(0);
                        String cwId = (String)cwMap.get('Id');
                        BulkApiService.pushContentWorkspaceDoc(namedCredential,contentDocumentId,cwId);
                    }
                }

            }else{
                List<String> csvList = new List<String>();
                Boolean isAdd = true;
                for(String field : queryFields){
                    if(operation == 'upsert' && (field.equalsIgnoreCase('CreatedDate') || field.equalsIgnoreCase('LastModifiedDate') )){
                        continue;
                    }
                    String val = '';
                    if(field.contains('.')){
                        String sobjName = field.split('\\.').get(0);
                        if(sobjName.endsWithIgnoreCase('__r')){
                            sobjName = sobjName.removeEndIgnoreCase('__r')+'__c';
                        }else{
                            //sobjName += 'Id';//TESTING
                        }
                        if(sobj.getSObject(field.split('\\.').get(0)) != null){
                            val =  String.valueOf(sobj.getSObject(field.split('\\.').get(0)).get(field.split('\\.').get(1))) ;
                        }
                    }else{
                        val = String.valueOf(sobj.get(field)) ;
                    }
                    if(fieldValuesMap.containsKey(val)){
                        val = fieldValuesMap.get(val);
                    }else if(fieldValuesMap.containsKey(field)){
                        val = fieldValuesMap.get(field);
                        if(fieldMap.containsKey(val)){
                            val = String.valueOf(sobj.get(val)) ;
                        }
                    }
                    if(String.isNotBlank(val) && relationshipFieldsMap.containsKey(field)){
                        if(idsMap.containsKey(val)){
                            csvList.add(idsMap.get(val));
                        }else{
                            isAdd = false;
                            break;
                        }
                    }else{
                        if(objectName.equalsIgnoreCase('user')){
                            if(String.isNotBlank(val) && field.equalsIgnoreCase('email') ){
                                if(!val.endsWithIgnoreCase(MigrationConstant.USER_EMAIL_INVALID)){
                                    val += MigrationConstant.USER_EMAIL_INVALID ;
                                }
                            }

                            if(String.isNotBlank(val) && field.equalsIgnoreCase('username') ){
                                if(!val.endsWithIgnoreCase(MigrationConstant.USER_USERNAME_INVALID)){
                                    val += MigrationConstant.USER_USERNAME_INVALID ;
                                }
                            }
                        }

                        if(String.isNotBlank(val) && fieldMap.containsKey(field) && fieldMap.get(field).getDescribe().getType() == Schema.DisplayType.DATETIME){
                            val = Datetime.valueOf(val).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                        }
                        if(String.isBlank(val) ){
                            if(csvFieldsMap.containsKey(field) || field.contains('.')){
                                val = '' ;
                            }else{
                                val = '#N/A' ;
                            }
                        }
                        if( field.equalsIgnoreCase(sourceExtId) && String.isBlank(destinationExtId)){
                            continue;
                        }
                        csvList.add(val.escapeCsv());
                    }
                }
                if(isAdd){
                    dataList.add(String.join(csvList, MigrationConstant.COLUMN_DELIMITER_CHAR));
                    if(String.isNotBlank(statusField)){
                        sobj.put(statusField, 'Submitted');//todo if boolean
                    }
                }
            }
        }
        if(!migrationAttachmentFiles.isEmpty()){
            insert migrationAttachmentFiles;
        }else{
            Integer currentHeapSize = Limits.getHeapSize() + 2000000;
            if(currentHeapSize >= Limits.getLimitHeapSize()){
                submitData();
            }
            if(String.isNotBlank(statusField)){
                //update scope;
            }
        }
    }

    public Map<String,String> getNewIdsMap(List<sObject> scope){
        Map<String,Set<String>> relationShipFieldsValueMap = new Map<String,Set<String>>();
        for(sObject sobj : scope ){
            for(String field : relationshipFieldsMap.keySet()){
                String value = String.valueOf(sobj.get(field));
                if(String.isNotBlank(value)){
                    Id recId = Id.valueOf(value);
                    String objName = String.valueOf(recId.getSobjectType()) ;
                    String key = objName+'.'+relationshipFieldsMap.get(field);
                    if(relationShipFieldsValueMap.containsKey(key)){
                        relationShipFieldsValueMap.get(key).add(value);
                    }else{
                        relationShipFieldsValueMap.put(key , new Set<String>{value});
                    }
                }
            }
        }
        Map<String,String> idsMap = new Map<String,String>();
        for(String key : relationShipFieldsValueMap.keySet()){
            String objName = key.split('\\.').get(0) ;
            String fieldName = key.split('\\.').get(1) ;
            Set<String> valuesSet = relationShipFieldsValueMap.get(key);
            String wh = '+WHERE+(+';
            Integer i = 0;
            for(String val : valuesSet){
                val = val.replaceAll(' ', '+');
                if(i==0){
                    wh += '+'+fieldName+'+=\''+val+'\'+';
                }else{
                    wh += 'OR+'+fieldName+'+=\''+val+'\'+';
                }
                i++;
            }
            wh += '+)+';
            String query = 'SELECT+Id,'+fieldName+'+FROM+'+objName+'+'+wh;
            List<Object> recordList = BulkApiService.doQuery(namedCredential,query);
            for(Object obj :recordList){
                Map<String,Object> objectMap = (Map<String,Object>)obj;
                String fieldValue = (String)objectMap.get(fieldName);
                idsMap.put(String.valueOf(objectMap.get(fieldName)),String.valueOf(objectMap.get('Id')));
            }
        }
        return idsMap;
    }


    // public Map<String,String> getRelationshipShipFieldsValueMap(List<sObject> scope){
    //     Map<String,Set<String>> relationShipFieldsValueMap = new Map<String,Set<String>>();
    //     Map<String,String> valueOldIdMap = new Map<String,String>();
    //     for(sObject sobj : scope ){
    //         for(String field : relationshipFieldsMap.keySet()){
    //             field = field.trim();
    //                 String rField = relationshipFieldsMap.get(field);
    //                 String value = '';
    //                 String keyField = rField;
    //                 if(rField.contains('.')){
    //                     if(sobj.getSObject(rField.split('\\.').get(0)) != null){
    //                         value = String.valueOf(sobj.getSObject(rField.split('\\.').get(0)).get(rField.split('\\.').get(1)));
    //                         keyField = rField.split('\\.').get(1);
    //                     }
    //                 }else{
    //                     value = String.valueOf(sobj.get(rField));
    //                 }

    //                 if(String.isNotBlank(value)){
    //                     Id recId = Id.valueOf(String.valueOf(sobj.get(field)));
    //                     String objName = String.valueOf(recId.getSobjectType()) ;
    //                     String key = objName + '.' +keyField ;
    //                     valueOldIdMap.put( value , String.valueOf(sobj.get(field)) );
    //                     if(relationShipFieldsValueMap.containsKey(key)){
    //                         relationShipFieldsValueMap.get(key).add(value);
    //                     }else{
    //                         relationShipFieldsValueMap.put(key , new Set<String>{value});
    //                     }
    //                 }
                    

    //             }
    //         }
    //     }
    //     return getNewIdsMap(relationShipFieldsValueMap,valueOldIdMap);
    // }
    // public Map<String,String> getNewIdsMap(Map<String,Set<String>> relationShipFieldsValueMap,Map<String,String> valueOldIdMap){
    //     Map<String,String> idsMap = new Map<String,String>();
    //     for(String str : relationShipFieldsValueMap.keySet()){
    //         String objName = str.split('\\.').get(0) ;
    //         String fieldName = str.split('\\.').get(1) ;
    //         Set<String> valuesSet = relationShipFieldsValueMap.get(str);
    //         String wh = '+WHERE+(+';
    //         Integer i = 0;
    //         for(String val : valuesSet){
    //             val = val.replaceAll(' ', '+');
    //             if(i==0){
    //                 wh += '+'+fieldName+'+=\''+val+'\'+';
    //             }else{
    //                 wh += 'OR+'+fieldName+'+=\''+val+'\'+';
    //             }
    //             i++;
    //         }
    //         wh += '+)+';
    //         String query = 'SELECT+Id,'+fieldName+'+FROM+'+objName+'+'+wh;
    //         List<Object> recordList = BulkApiService.doQuery(namedCredential,query);
    //         for(Object obj :recordList){
    //             Map<String,Object> objectMap = (Map<String,Object>)obj;
    //             String fieldValue = (String)objectMap.get(fieldName);
    //             if(valueOldIdMap.containsKey(fieldValue) && valueOldIdMap.get(fieldValue) != null){
    //                 idsMap.put(valueOldIdMap.get(fieldValue),String.valueOf(objectMap.get('Id')));
    //             }
    //         }
    //     }
    //     return idsMap;
    // }
    public void finish(Database.BatchableContext bc){
        if(objectName.equalsIgnoreCase('Attachment') || objectName.equalsIgnoreCase('ContentWorkspaceDoc')){
            Migration_Object__c mgObject = [SELECT Id,Failed_Record__c,Sequence__c FROM Migration_Object__c WHERE Id =: migrationObjectId ];
            mgObject.End_Date__c = Datetime.now();
            mgObject.Status__c = mgObject.Failed_Record__c > 0 ? 'Failed' : 'Completed' ;
            update mgObject;
        }else{
            if(dataList.size()>1){
                submitData();
            }
            if(submitBulk){
                System.enqueueJob(new BulkJobQueueable(migrationObjectId));
            }else{
                List<Migration_Object__c> migrationObjectList = [SELECT Id FROM Migration_Object__c WHERE Sequence__c >: sequence AND Sequence__c!=NULL AND Status__c =null AND Active__c=true and Object_Api_Name__c!='Attachment' ORDER BY Sequence__c ASC LIMIT 1 ];
                if(!migrationObjectList.isEmpty()){
                    GenerateBulkCSVBatch batchObj = new GenerateBulkCSVBatch(migrationObjectList.get(0).Id);
                    //Database.executeBatch(batchObj);
                }
            }
        }
        

    }
    public void submitData(){
        if(objectName.equalsIgnoreCase('Attachment') || objectName.equalsIgnoreCase('ContentWorkspaceDoc')){
            return ;
        }
        String bulkJobId = '';
        String csvStr = String.join(dataList,'\n');
        if(submitBulk){
            bulkJobId = BulkApiService.createBulkJobId(namedCredential,objectName, operation,destinationExtId) ;
            BulkApiService.uploadDataToBulkJob(namedCredential,bulkJobId, csvStr);
            BulkApiService.submitBulkJob(namedCredential,bulkJobId);
        }

        Migration_File__c mFile = new Migration_File__c();
        mFile.Migration_Object__c = migrationObjectId  ;
        mFile.Bulk_JobId__c = bulkJobId ;
        mFile.Job_Start_Time__c = Datetime.now() ;
        mFile.Total_Records__c = dataList.size() - 1  ;
        mFile.Job_Status__c = String.isNotBlank(bulkJobId) ? 'Job Submitted' : 'Data Generated' ;
        insert mFile;

        if(createAttachment){
            Attachment att=new Attachment();
            att.Body=Blob.valueOf(csvStr);
            att.Name= objectName+ System.now().format('yyyy_MM_dd_hh_mm_ss') + '.csv';
            att.parentId = mFile.Id;
            insert att;
        }
        dataList = new List<String>{getHeaderCsv()};
    }
}
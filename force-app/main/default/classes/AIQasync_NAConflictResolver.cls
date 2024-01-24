global with sharing class AIQasync_NAConflictResolver implements Database.Batchable<sObject>, Database.Stateful {
    private List<Object> jobMessages;
    private DateTime currentTime = Datetime.now();
    private List<String> notificationGroup;
    private Integer batchSize;

    public class AIQasync_NAConflictResolverException extends Exception {}
    
    public AIQasync_NAConflictResolver(List<String> notificationGroup, Integer batchSize) {
        this.notificationGroup = notificationGroup;
        this.jobMessages = new List<Object>();
        this.batchSize = batchSize;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        
        query = 'SELECT Id, zpl__Contract__c, SKU__c, zpl__PolicyType__c FROM zpl__ContractLineItem__c';
        query  += ' WHERE';
        query  += ' zpl__Contract__r.RecordType.Name in (\'Pricing Contract\')';
        query  += ' AND (zpl__Contract__r.National_Account__c!=null OR zpl__Contract__r.National_Account__c!=\'\')';
        query  += ' AND zpl__LineLevel__r.Name = \'Item\'';
        query  += ' ORDER BY zpl__Contract__c';
        
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext bc, List<zpl__ContractLineItem__c> scope) {
        if(!scope.isEmpty()) {
            try{
                List<zpl__ContractLineItem__c> updateList = Test.isRunningTest() ? scope : AIQService.resolveNAConflict(scope);
                if(updateList.size() > 0) {
                    /**
                    * tolarates partial success
                    */
                    Database.Saveresult[] srList = Database.update(updateList, false);
                    Contract[] errorLines = new List<Contract>();

                    Set<String> errorMessages = new Set<String>();
                    Set<String> errorLineIds = new Set<String>();
                    for (Integer i = 0; i < updateList.size(); i++) {
                        Database.SaveResult sr = srList[i];
                        zpl__ContractLineItem__c record = updateList[i];

                        if(!sr.isSuccess()) {
                            errorLineIds.add(record.Id);
                            errorMessages.add(sr.getErrors().get(0).getMessage().left(255));
                        }

                    }
                    if(!errorMessages.isEmpty()) {
                        this.jobMessages.add(new AIQasync_NAConflictResolverException('Errors received: '+String.valueOf(errorMessages).replace('{', '[').replace('}', '] ') +
                            + ' for lines with Id '+String.valueOf(errorLineIds).replace('{', '[').replace('}', '] ').left(1000)));
                    }
                }
            } catch(Exception e) {
                this.jobMessages.add(e.getMessage());
            }
        }        
    }
    
    global void finish(Database.BatchableContext bc) {
        if(!jobMessages.isEmpty()) {
            new AIQco_Messenger('Veritiv DM: AIQasync_NAConflictResolver class errors', this.jobMessages, this.notificationGroup).send();
        }
    }
}
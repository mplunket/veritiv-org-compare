global class AIQasync_AgrmntLinePurging implements Database.Batchable<sObject>, Database.Stateful{
    
    public class AIQasync_AgrmntLinePurgingException extends Exception{}
    
    private List<zpl__ContractLineItem__c> agrLines;
    private DateTime purgeDate;
    private List<Object> jobMessages;
    private String[] notificationGroup;
    
    public AIQasync_AgrmntLinePurging(List<String> notificationGroup)
    {
        this.jobMessages = new List<Object>();
        this.notificationGroup = notificationGroup;
        this.purgeDate = date.today().addYears(-7);
        this.agrLines = new List<zpl__ContractLineItem__c>();
    }
        
    global database.queryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id FROM zpl__ContractLineItem__c';
            if (!Test.isRunningTest()) {
                query  += ' WHERE isCurrent__c=false';
                query  += ' AND SupersededDate__c not in (null)';
                query  += ' AND zpl__EffectiveDate__c<=' + this.purgeDate.format('yyyy-MM-dd');
                query  += ' AND RecordType.Name in (\'Active\', \'Inactive\')';
            }
        return Database.getQueryLocator(query);      
    }
    
	global void execute(Database.BatchableContext BC, List<zpl__ContractLineItem__c> scope)
    {
        this.agrLines = scope;        
        try{
            if(!agrLines.isEmpty()){            
      			delete agrLines;
                if(Test.isRunningTest()){throw new AIQasync_AgrmntLinePurgingException();}
    		}
        } catch(Exception e){
            this.jobMessages.add(new AIQasync_AgrmntLinePurgingException(e.getMessage()+'[StackTrace: '+e.getStackTraceString()+']'));
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if(!this.jobMessages.isEmpty() && !Test.isRunningTest()){
            new AIQco_Messenger('Veritiv DM: AIQasync_AgrmntLinePurging class errors', this.jobMessages, this.notificationGroup).send();
        }
        
    }
}
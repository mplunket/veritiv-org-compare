public class AIQPESService {

    static public void publish(Id userId, zpl__ContractLineItem__c agreementLine)  {
        // update flag
        Id recordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
            .get('Draft').getRecordTypeId();
                    
        agreementLine.RecordTypeId = recordTypeId;
        agreementLine.zpl__Status__c = 'Pend Appr';
        agreementLine.Published_By__c = userId;
        agreementLine.isCurrent__c = true;
        agreementLine.Publish_Date__c = system.now();
        if(agreementLine.zpl__EffectiveDate__c==null || agreementLine.zpl__EffectiveDate__c<Date.today()) //VERITIVAIQ-283
        {
            agreementLine.zpl__EffectiveDate__c = Date.today();
        } 
    }
    
    static public void cancel(Id userId, zpl__ContractLineItem__c agreementLine){
        Id recordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Inactive').getRecordTypeId();        
        agreementLine.RecordTypeId = recordTypeId;                
        agreementLine.isCurrent__c = false;
        agreementLine.zpl__Status__c = 'Deleted By Quote';
        agreementLine.Inactivated_By__c = userId;
        agreementLine.Inactivated_Date__c = system.now();    	
    }        
    
    
    static public void cancel(Id userId, List<zpl__ContractLineItem__c> agreementLines){        
        Id recordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Inactive').getRecordTypeId();        
    	for(zpl__ContractLineItem__c agreementLine: agreementLines) {
    		cancel(userid, agreementLine);
    	}
    }
    
}
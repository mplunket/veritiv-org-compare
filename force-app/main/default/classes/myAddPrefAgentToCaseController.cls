global with sharing class myAddPrefAgentToCaseController {
     
    // add preferred agent id to case
    @RemoteAction
    global static void addPrefAgentToCase(String caseId, String agentId) {
        try {
            system.debug('entered myAddPrefAgentToCaseController');
            //read the existing case entry
            Case c = [SELECT Id, Return_to_Agent_ID__c, owner.profile.name, status, Email_Counter__c, recordtypeId  FROM Case WHERE Id = :caseId LIMIT 1];
            system.debug('case = '+c);
            //now we can change any of the fields
            c.Return_to_Agent_ID__c = agentId;
            system.debug('c.Return_to_Agent_ID__c = '+ agentId);           
   
            
            //simplus update start
            /*
            Map<Id,Schema.RecordTypeInfo> recordTypeMap = new Map<Id,Schema.RecordTypeInfo>();
            recordTypeMap = Schema.SObjectType.Case.getRecordTypeInfosById();
            system.debug('BucherSuter recordTypeMap...getName.. = ' + recordTypeMap.get(c.recordtypeId).getName());
            Set<String> consoleRecordNames = new Set<String>{'Console Case', 'Console CS - Lightning'};
            system.debug('BucherSuter  consoleRecordNames = ' + consoleRecordNames);
            
            Id profileId = UserInfo.getProfileId();
            String currentProfile = [SELECT Name FROM Profile WHERE Id =: profileId][0].Name;
            system.debug('BucherSuter  currentProfile = ' + currentProfile);
            
            if(consoleRecordNames.contains(recordTypeMap.get(c.recordtypeId).getName()) && c.Email_Counter__c == 1 && c.owner.profile.name == 'CS Console Pilot Profile' && c.status!='Closed'){
                system.debug('BucherSuter  setting status to In Progress');
                c.status= 'In Process';
            }
            */
            //save it to update the database
            update c;
        } catch (Exception e) {
            system.debug('BucherSuter Exception message = ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
        }
    }
}
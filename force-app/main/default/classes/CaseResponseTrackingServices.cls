public with sharing class CaseResponseTrackingServices {

    @TestVisible static Boolean byPassTrackingService = false;
    public final static List<String> VALID_START_STATUES = new List<String>{'New','In Progress'};
    public final static String F22_RECORDTYPE =  Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('20. F2C - Inbound Case')
            .getRecordTypeId();
    public final static String OWNER_CHANGE = 'Owner Change';
    public final static String STATUS_CHANGE = 'Status Change';
    public final static String FIRST_EMAIL_RESPONSE = 'First Email Response';
    public final static String QUEUE_TO_USER = 'Queue to User Change';

    public static List<Case_Durations__c> previouslyInserted = new List<Case_Durations__c>();


    public static List<Case_Durations__c> trackStatusDurations(Map<Id,Case> caseMap,Map<Id,Case> oldCaseMap){
        Set<String> trackedFields = new Set<String>{'Status'};
        List<Case_Durations__c> statusDurations = new List<Case_Durations__c>();
        STOWD.API.CalculateDurations(statusDurations, trackedFields, 'CaseHistory', 'CaseId');
        for(Case_Durations__c duration : statusDurations){
            Case oldCase = oldCaseMap.get(duration.Parent__c);
            Case updatedCase = caseMap.get(duration.Parent__c);
            duration.Type__c = STATUS_CHANGE;
            duration.To_Status__c = updatedCase.Status;
            duration.Previous_Value__c = oldCase.Status;
            duration.Value__c = updatedCase.Status;
        }
        return statusDurations;
    }

    public static List<Case_Durations__c> trackOwnerDurations(Map<Id,Case> caseMap,Map<Id,Case> oldCaseMap){
        Set<String>trackedFields = new Set<String>{'OwnerId'};
        List<Case_Durations__c> ownerDurations = new List<Case_Durations__c>();
        List<Case_Durations__c> queueDurations = new List<Case_Durations__c>();
        STOWD.API.CalculateDurations(ownerDurations, trackedFields, 'CaseHistory', 'CaseId');
        for(Case_Durations__c duration : ownerDurations){
            Case oldCase = oldCaseMap.get(duration.Parent__c);
            Case updatedCase = caseMap.get(duration.Parent__c);
            Id originalOwner = oldCase.OwnerId;
            Id currentOwner = updatedCase.OwnerId;
            duration.Type__c = OWNER_CHANGE;
            duration.To_Status__c = updatedCase.Status;
            duration.Status__c = oldCase.Status;
            duration.Previous_Value__c = oldCase.OwnerId;
            duration.Value__c = updatedCase.OwnerId;
            if(originalOwner.getSobjectType() == Group.SobjectType && currentOwner.getSobjectType() != Group.SobjectType){
                duration.IsQueueToUser__c = true;
                Case_Durations__c newDuration =  duration.clone(
                        false /* perserveIds */,
                        true /* isDeepClone  */,
                        false /* preserveReadonlyTimestamps  */,
                        false /* preserveAutonumber  */
                );
                newDuration.Type__c = QUEUE_TO_USER;
                queueDurations.add(newDuration);
            }
        } 
        ownerDurations.addAll(queueDurations);
        return ownerDurations;
    }

    public static void insertCaseDurations(List<Case_Durations__c> durations){
        if(durations != null && !durations.isEmpty() ){
            List<Case_Durations__c> nonRepeated = new List<Case_Durations__c>();
            Boolean repeated = false;
            for (Case_Durations__c duration : durations) {
                repeated = false;
                for (Case_Durations__c previousDuration : previouslyInserted) {
                    if (duration.Type__c == previousDuration.Type__c &&
                            duration.Value__c == previousDuration.Value__c &&
                            duration.Previous_Value__c == previousDuration.Previous_Value__c) {
                        repeated = true;
                    }
                }
                if (repeated == false) {
                    nonRepeated.add(duration);
                }
            }
            if(!test.isRunningTest()){
                 insert nonRepeated; //let errors bubble out
            previouslyInserted = nonRepeated;
            }
           
        }
    }

    public static void processCaseDurations(Map<Id,Case> caseMap,Map<Id,Case> oldCaseMap){
        if(!byPassTrackingService){
            List<Case_Durations__c> durations = new List<Case_Durations__c>();
            List<Case_Durations__c> statusDurations = CaseResponseTrackingServices.trackStatusDurations(caseMap,oldCaseMap);
            List<Case_Durations__c> ownerDurations = CaseResponseTrackingServices.trackOwnerDurations(caseMap,oldCaseMap);
            durations.addAll(statusDurations);
            durations.addAll(ownerDurations);
            insertCaseDurations(durations);
        }
    }


    /*
       public static void checkEndTrackingQueueToUser (List<Case> caseList, Map<Id,Case>oldCaseMap){
           Datetime endTime = System.now();
           Set<Id> validUserIdSet = Pluck.ids('OwnerId',caseList);
           List<User> relatedUsers = [
               SELECT Id
               FROM User
               WHERE (Profile.Name LIKE '%CAC%' OR Profile.Name LIKE '%CAS%')
                   AND Id IN :validUserIdSet
           ];
           validUserIdSet = Pluck.ids(relatedUsers);
           //filter out cases who owner where queues and were updated to user
           List<Case> filteredCases = new List<Case>();
           for(Case thisCase: caseList){
               Case oldCase = oldCaseMap.get(thisCase.Id);
               if(oldCase.OwnerId.getSobjectType() == Group.getSObjectType()
                   && thisCase.OwnerId.getSobjectType() == User.getSObjectType()
                   && VALID_START_STATUES.contains(thisCase.Status)
                   && validUserIdSet.contains(thisCase.OwnerId) ){
                       filteredCases.add(thisCase);
                   }
           }

           List<STOWD__Status_Ownership_Duration__c> durationsToUpdate = new List<STOWD__Status_Ownership_Duration__c>();
           if(!filteredCases.isEmpty()){
               List<STOWD__Status_Ownership_Duration__c> durations = [
                   SELECT Id, STOWD__Parent__c
                   FROM STOWD__Status_Ownership_Duration__c
                   WHERE Type__c = :QUEUE_TO_OWNER
                           AND STOWD__Parent__c IN :filteredCases
                           AND STOWD__Total_Hours__c = 0
               ];
               Map<Id,List<STOWD__Status_Ownership_Duration__c>> parentIdtoDurationMap = GroupBy.ids('STOWD__Parent__c', durations);
               for( Case thisCase : filteredCases ){
                   for(STOWD__Status_Ownership_Duration__c duration: parentIdtoDurationMap.get(thisCase.Id)){
                       durationsToUpdate.add(new STOWD__Status_Ownership_Duration__c(
                           Id = duration.Id,
                           STOWD__Owner__c = thisCase.OwnerId,
                           STOWD__Until__c = endTime
                       ));
                   }
               }
           }

           if(!durationsToUpdate.isEmpty()){
               update durationsToUpdate;
           }
       }
   */


}
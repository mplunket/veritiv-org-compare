public with sharing class DelegatedApprovalController {

    @AuraEnabled 
    public static user fetchUser(String userId) {
        // query current user information 
        User oUser = [SELECT id, Name, DelegatedApproverId, Pricing_Delegated_Approver__c, Delegation_Start_Date__c, Delegation_End_Date__c
                      FROM User WHERE id =: userId];
        return oUser;
    }
    
    
}
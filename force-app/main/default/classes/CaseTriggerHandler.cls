public class CaseTriggerHandler {
    public static Map <id,boolean> caseVHQSkip = new map<id,boolean>();
    public static boolean newCase = false;
    
    //below boolean fields are to make sure casetrigger only runs the before and after update once. Backlog 2791
    
    public static Boolean isFirstTimeCaseTriggerBUpdate = true;
    public static Boolean isFirstTimeCaseTriggerAUpdate = true;
    
    
    
    public static void validateCase(Map<Id, Case> oldMap, Map<Id, Case> newMap) {
        //Removed Training and Support profile
        Set<String> profileNames = new Set<String>{'System Administrator', 'API admin'};//simplus 08-22-20 changed API Admin to API admin
        Set<String> recordNames = new Set<String>{'Vendor Claim Print', 'Print - Dead and Excess', 'Equipment Parts and Service'}; //record types that will be skipped
        Set<String> consoleRecordNames = new Set<String>{'Console Case', 'Console CS - Lightning'};
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
            for (Case c : newMap.Values()){
                
                system.debug('Old is = new?');
                system.debug( oldmap.get(c.id)==c);
                
                system.debug('Old Value = '+oldmap.get(c.id));
                system.debug('New Value = '+c);
                
                system.debug('Old MasterRecordId = '+oldmap.get(c.id).MasterRecordId);
                system.debug('New MasterRecordId = '+c.MasterRecordId);
                
                system.debug('Old Status = '+oldmap.get(c.id).Status);
                system.debug('New Status = '+c.Status);
                
                accountIds.add(c.AccountId);
                contactIds.add(c.ContactId);
            }
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN : accountIds]);
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, Account_Name_Formula__c FROM Contact WHERE Id IN : contactIds]);
        String queue = [SELECT Id FROM Group WHERE  Type = 'Queue' AND NAME = 'Console Case Queue'][0].Id;
        Map<Id,Schema.RecordTypeInfo> recordTypeMap = new Map<Id,Schema.RecordTypeInfo>();
        recordTypeMap = Schema.SObjectType.Case.getRecordTypeInfosById();
        Id profileId = UserInfo.getProfileId();
        String currentProfile = [SELECT Name FROM Profile WHERE Id =: profileId][0].Name;
        System.debug('DEBUG: newcases = ' + newMap);
        System.debug('DEBUG: profilenames = ' + profileNames);
        System.debug('DEBUG: recordnames = ' + recordNames);
        System.debug('DEBUG: recordTypeMap = ' + recordTypeMap);
        System.debug('DEBUG: profileId = ' + profileId);
        System.debug('DEBUG: currentProfile = ' + currentProfile);
        map<id,string> caseAccountMap = new Map<id,String>();
        map<id,string> caseConAccMap = new Map<id,String>();
        
        
        
        //removed in BL 3188 if(!profileNames.contains(currentProfile)){
            for(Case c : newMap.values()){ 
                system.debug(c.id+' debug caseVHQSkip before setting ' +caseVHQSkip.get(c.id));       
                if(!caseVHQSkip.containskey(c.id)){
                    caseVHQSkip.put(c.id,false);    
                }
                //check for status change from in process to in routing. Prevent the changes.
                System.debug('Old Status' + oldmap.get(c.id).status);
                System.debug('New Status' + c.status);
                if(oldmap.get(c.id).status == 'In Process' && c.status=='In Routing' && !string.isblank(c.Return_to_Agent_ID__c)&&newCase==false){
                    c.status='In Process';    
                }
                
                // BL-3201
                /* commented out for 3188 deployment
                Id consCaseRecrdTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Console CS - Lightning').getRecordTypeId();
                if(c.RecordTypeId == consCaseRecrdTypeId && c.status=='Closed') {
                    if(c.Category__c == 'I - Product/Item Issue' && (c.Details__c == 'Vendor Claim - FS/PKG' || c.Details__c == 'Vendor Claim - PRINT')) {
                        if(String.isBlank(c.Vendor_Claim__c)) {
                            c.addError('Vendor Claim # is required.');
                            return;
                        }
                    }
                    
                    if((c.Category__c == 'I - Product/Item Issue' && (c.Details__c == 'No Claim' || c.Details__c == 'Freight Claim' || c.Details__c == 'Not Sure of Claim' || c.Details__c == 'Damaged Product/Item'))
                       || (c.Category__c == 'I - Order Issue' && c.Details__c == 'Ordered Incorrectly')
                       || (c.Category__c == 'I - Delivery Issue' && c.Details__c == 'Driver/Truck Complaint')
                       || (c.Category__c == 'I - Credit' && c.Details__c == 'Vendor Credit')){
                           List<Case_Product__c> caseProduct = [SELECT Id FROM Case_Product__c WHERE Case__c = :c.Id AND Product__c != Null AND Product_Description__c != Null AND  Vendor_Name__c != Null AND  Qty__c != Null AND  Unit_of_Measure__c  != Null LIMIT 1];

                           if(caseProduct.size() == 0) {
                               c.addError('At least one Case Product must be added including the Product, Qty, & Unit of Measure.');
                           } else if(c.Customer_Expectation_Summary__c==null || c.Customer_Expectations_from_Veritiv__c==null) {
                               c.addError('There are required fields in the Quality Assurance section.');
                           } else if(c.CS_MAX_Order_Number__c==null) {
                               c.addError('Order Number is required.');
                           }
                    }
                }
                // end BL-3201 */
                
                //check if owner was changed from queue to user or vice versa
                boolean ownerTypeChanged = true;
                if((string.valueOf(c.OwnerId).startsWith('005')&&string.valueOf(oldmap.get(c.id).OwnerId).startsWith('005'))||(string.valueOf(c.OwnerId).startsWith('00G')&&string.valueOf(oldmap.get(c.id).OwnerId).startsWith('00G'))){
                    ownerTypeChanged = false;
                }
                        
                //updated all instances of accountMap.get(c.AccountId).Name to use a caseid to string map for the account name for cases that has no account
                if(accountMap.containskey(c.AccountId)){
                    caseAccountMap.put(c.id,accountMap.get(c.AccountId).Name);        
                }else{
                    caseAccountMap.put(c.id,'Null');    
                }
                //updated all instances of contactMap.get(c.ContactId).Account_Name_Formula__c to use a caseid to string map for the contact's account name for cases where the email has no associated contact
                if(contactMap.containskey(c.ContactId)){
                    caseConAccMap.put(c.id,contactMap.get(c.ContactId).Account_Name_Formula__c);        
                }else{
                    caseConAccMap.put(c.id,'Null');    
                }
                
         
                if(oldmap.get(c.id)==c || (c.OwnerId != oldMap.get(c.Id).OwnerId && oldMap.get(c.Id).OwnerId == queue)||c.OwnerId != oldMap.get(c.Id).OwnerId || c.status == 'Merged' 
                   || (c.Return_to_Agent_ID__c != oldMap.get(c.Id).Return_to_Agent_ID__c && string.isblank(oldMap.get(c.Id).Return_to_Agent_ID__c))||c.OwnerId ==queue||caseVHQSkip.get(c.id)){      
                
                    System.debug('DEBUG: exception!');
                    system.debug(c.id+' debug caseVHQSkip before setting ' +caseVHQSkip.get(c.id));     
                    caseVHQSkip.put(c.id,true);
                    system.debug(c.id+' debug caseVHQSkip after exception ' +caseVHQSkip.get(c.id));     
                }
                else if((caseAccountMap.get(c.id) == 'Veritiv Headquarters' || 
                   (caseConAccMap.get(c.id) == 'Veritiv Headquarters' && c.AccountId == null)) && !recordNames.contains(recordTypeMap.get(c.recordtypeId).getName())  && c.Last_Activity_Date__c == oldMap.get(c.Id).Last_Activity_Date__c && c.Is_Spam__c == oldMap.get(c.Id).Is_Spam__c && c.OwnerId == oldMap.get(c.Id).OwnerId){
                   //removed in BL 3188
                   //c.addError('Cases can not be added to the Veritiv Headquarters account. Please select the appropriate customer account.');
                }
           }
        //}
    }
    
    public static void caseStatusDetailBlank(List<Case> newList) {
        for (Case c: newList){
            if(C.status!='On Hold - Veritiv'){
                c.Status_Detail__c = null;
            }
        }
    }
    
    @future
    public static void caseClearVHQOnCreate(List<id> caseVHQ) {
        //get all cases with VHQ
        system.debug('Entered caseClearVHQOnCreate ');
        system.debug('caseVHQ= '+caseVHQ);
        List<case> caseToUpdate = new list<case>();
        caseToUpdate = [select id, accountid, contactid from case where id in:caseVHQ];
        
        for (case c : caseToUpdate){
            c.accountid=null;
            c.contactid=null;
        }
        system.debug('caseToUpdate= '+caseToUpdate);
        update caseToUpdate;
    }
    
    /*
    public static void checkMergedCases(Map<Id, Case> oldMap, Map<Id, Case> newMap) {
        
        Map<id,id> masterCaseAccountMap = new Map<id,id>();
        List<id> masterCaseIds = new list<id>();
        for(Case c: newMap.values()){
            //check if record was merged
            if(string.isBlank(c.MasterRecordId)==false){
                //get the master case
                masterCaseIds.add(c.MasterRecordId);
                //check if merged case was reopened
                if(oldMap.get(c.id).status == 'Merged' && c.status != oldMap.get(c.id).status){
                    c.addError('This case has already been merged with a separate case and cannot be reopened');    
                }
            }    
        }
        
        //get master case accounts
        for(Case c: [select id, accountid from case where id in:masterCaseIds]){
            masterCaseAccountMap.put(c.id, c.accountid);    
        }
        //update account to match master case
        for(Case c: newMap.values()){
            if(string.isBlank(c.MasterRecordId)==false){
                //get the master case account and update merged case account
                if(masterCaseAccountMap.containskey(c.MasterRecordId)){
                    c.accountid = masterCaseAccountMap.get(c.MasterRecordId);                    
                }
            }       
        }
        
    }
*/
    //Below method is added for the logic of blocking cases
  /* public static void blockCases(List<Case> newCases){
        set<Id> AcIds = new Set<Id>();
        for(case cs : newCases){
            string recID = Schema.SObjectType.Case.getRecordTypeInfosById().get(cs.recordtypeid).getname();
            if(recId == '20. F2C - Inbound Case' || recId == 'Console Case'|| recId == 'Sales Support'|| 
               recId == 'Order/Request/Issue'|| recId == 'Print - Dead and Excess'|| recId == 'Vendor Claim Print'){
                   AcIds.add(cs.AccountId);
               }
        }
        
         Map<Id, boolean> accActOrNot = new Map<Id, Boolean>();
        if(AcIds.size() > 0){
           
            List<Account> acList = [Select id, Active__c from account where id in: AcIds];
            for(account ac: acList){
                if(ac.Active__c == 'Yes'){
                    accActOrNot.put(ac.id,true);
                        }else{
                            accActOrNot.put(ac.id,false);
                        }
            }
        }
        
        
        for(case cs : newCases){
            string recID = Schema.SObjectType.Case.getRecordTypeInfosById().get(cs.recordtypeid).getname();
            if(recId == '20. F2C - Inbound Case' || recId == 'Console Case'|| recId == 'Sales Support'|| 
               recId == 'Order/Request/Issue'|| recId == 'Print - Dead and Excess'|| recId == 'Vendor Claim Print'){
                   if(cs.AccountId != null && accActOrNot.containsKey(cs.AccountId)){
                       if(!accActOrNot.get(cs.AccountId)){
                           if(!test.isRunningTest()){
                               cs.addError('This Account is inactive, Cases should not be related to this Account.');
                               
                           }
                       }
                   }
               }
        }
         
    }*/
 //End of method
}
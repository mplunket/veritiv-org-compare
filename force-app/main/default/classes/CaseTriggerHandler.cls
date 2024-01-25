public class CaseTriggerHandler {
    public static Map <id,boolean> caseVHQSkip = new map<id,boolean>();
    public static boolean newCase = false;
    
    //below boolean fields are to make sure casetrigger only runs the before and after update once. Backlog 2791
    
    public static Boolean isFirstTimeCaseTriggerBUpdate = true;
    public static Boolean isFirstTimeCaseTriggerAUpdate = true;
    
    //backlog 3030
    public static Map<id,userrole> userRoleMap;
    public static Map <string, id> mapNameToQueue = new map<string, id>();
    public static Map<Id,Schema.RecordTypeInfo> recordTypeMap = new Map<Id,Schema.RecordTypeInfo>();
    
    
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
                   //Error message removed in BL 3188                  
                }
           }
        
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
    
     //backlog 3030
    public static void checkActiveOwner(Map<Id, Case> newMap){
        recordTypeMap = Schema.SObjectType.Case.getRecordTypeInfosById();
         //add a boolean to skip if all cases are active
         boolean allActive = true;
         //get owners and account
         map<id,boolean>ownerActiveMap = new map<id,boolean>();
         list <id> accidList = new list<id>();
         list <id> roleID = new list<id>();
         list <id> newOwnerID = new list<id>();
         for(case ca:newmap.values()){
             //create map and prepopulate value as true
             ownerActiveMap.put(ca.ownerid,true);
             
             if(ca.accountid!=null){
                 accidList.add(ca.accountid);
             }
         }
          
         //get owners
         //list <user> ownerList = new list<user>();
         map<id,user>ownerList = new map<id,user>([select id, isactive, ManagerID, Manager.isactive,userroleid, Manager.userrole.name from user where id in :ownerActiveMap.keyset()]);
     
         //map inactive owners
         for(user us:ownerList.values()){
             if(us.isActive == false){
                 ownerActiveMap.put(us.id,us.isActive);
                 allActive = false;
                 roleID.add(us.userroleid);
             }
         }
     
     
         //skip if all are active
         if(allActive == false){
             //map the user roles in userRoleMap
             userRoleMap = new map<id,userrole> ([select id, Name from userrole where id in:roleID]);
             system.debug('Rodney userRoleMap '+userRoleMap.values());
             //get accounts
             Map<id, account> accMap = new Map<id, account>([select id, ANI_Primary__c, ANI_Secondary__c, ANI_Tertiary__c, ANI_Primary__r.isactive, ANI_Secondary__r.isactive, ANI_Tertiary__r.isactive, ANI_Primary__r.profile.name, ANI_Secondary__r.profile.name, ANI_Tertiary__r.profile.name from account where id in: accidList]);
             system.debug('Rodney accIDList '+accidList);
             system.debug('Rodney accMap Values '+accMap.values());
             
             //ANI validation check. Prevent the OnlySpecificProfilesCanOwnOrChgOwner validation rule from causing an error
             Set<String> profileSkipANI = new Set<String>{'CSP Team Lead','CSP with Create Order','Quality Assurance','System Administrator','Cost Maintenance','CAN - CS and Sourcing','CAN - CS','API admin','Sales Admin - Lightning','Training and Support - Lightning','Equipment - Parts and Service - Lightning','CS - Lightning Console','CS - Support Restricted - Lightning','Credit & Collections'};
             
             //Manager role check. Cases should not be assigned to below roles 
             Set<String> managerRoleSkip = new Set<String>{'CS - CIN - CXC Manager', 'CS - DAL - CXC Manager', 'CS - JAX - CXC Manager', 'CS - LA - FS/PKG - CXC Mgr', 'CS - LA - PRINT - DIRECTOR', 'Specialist - Mgr '};
             
             //get queues 
             List <group> queueList = new list<group> ([select Id, Name from Group where Type = 'Queue']);
             for(group que : queueList){              
                 switch on que.name {
                     when 'CIN-PRT-ESC-LEX'{       
                         mapNameToQueue.put('CIN-PRT',que.id);
                     }   
                     When 'CIN-ESC-LEX'{           
                         mapNameToQueue.put('CIN',que.id);
                     }
                     When 'LA-PRT-ESC-LEX'{           
                         mapNameToQueue.put('LA-PRT',que.id);
                     }
                     When 'LA-ESC-LEX'{           
                         mapNameToQueue.put('LA',que.id);
                     }
                     When 'MN-PRT-ESC-LEX'{           
                         mapNameToQueue.put('MN-PRT',que.id);
                     }
                     When 'NJ-PRT-ESC-LEX'{           
                         mapNameToQueue.put('NJ-PRT',que.id);
                     }
                     When 'JAX-ESC-LEX'{           
                         mapNameToQueue.put('JAX',que.id);
                     }
                     When 'DAL-ESC-LEX'{           
                         mapNameToQueue.put('DAL',que.id);
                     }
                     When 'VENDOR CLAIMS FS/PKG - E2C'{           
                         mapNameToQueue.put('VC-FS',que.id);
                     }   
                     When 'SALES SUPPORT - E2C'{           
                         mapNameToQueue.put('SALESSUPPORT',que.id);
                     }  
                     When 'EQUIP PARTS AND SERVICE - TRANSFER - E2C'{           
                         mapNameToQueue.put('EQUIPMENT',que.id);
                     }                  
                 }  
             }
             //record types to be checked
             Set<String> validRecordTypes = new Set<String>{'Equipment Parts and Service', 'Console CS - Lightning','Sales Support - Vendor Claim FS and PKG','Sales Support', 'Sales Support - WH Only Vendor Claim FS and PKG' };
             
             //ids to be passed to create new case comment
             List<id> caseIdNewOwnerList = new list<id>();
             for(case ca:newmap.values()){
                 //check if created in last 60 days. Skip if more than 60 days
                 Date createDate = date.newinstance(ca.createddate.year(), ca.createddate.month(), ca.createddate.day());
                 if(createDate.daysBetween(system.today()) <=60 && validRecordTypes.contains(recordTypeMap.get(ca.recordtypeId).getName())){
                     //check if owner is inactive
                     if(ownerActiveMap.get(ca.ownerid) == false){                     
                         
                         boolean activePri=false;
                         boolean activeSec=false;
                         boolean activeThi=false;
                         Account acc = new account();
                         //check ANI only if Console CS Lightning
                         if(recordTypeMap.get(ca.recordtypeId).getName() == 'Console CS - Lightning' && accMap.containskey(ca.accountid)){                         
                             acc = accMap.get(ca.accountid);
                             //get ANI if active                             
                             
                             system.debug('Rodney accid '+ca.accountid);
                             system.debug('Rodney acc '+acc);
                             //make sure ANI profiles are valid
                             if(acc.ANI_Primary__c!=null && profileSkipANI.contains(acc.ANI_Primary__r.profile.name)){
                                activePri = acc.ANI_Primary__r.isactive;
                             } 
                             
                             
                             if(acc.ANI_Secondary__c!=null && profileSkipANI.contains(acc.ANI_Secondary__r.profile.name)){
                                activeSec = acc.ANI_Secondary__r.isactive;
                             } 
                             
                             
                             if(acc.ANI_Tertiary__c!=null && profileSkipANI.contains(acc.ANI_Tertiary__r.profile.name)){
                                activeThi = acc.ANI_Tertiary__r.isactive;
                             } 
                         
                         }
                         
                         
                         //if primary ani active, set as the owner
                         // 12/12/2022 notes: Requirement update, ANI users should only apply to Console CS - Lightning
                         // Updated code so active ANI will be marked as false by default and will only be checked if the record type is Console CS - Lightning
                         // This way the code will still run with the new requirements with minimal changes.
                         if(activePri){
                             ca.ownerid = acc.ANI_Primary__c;
                             caseIdNewOwnerList.add(ca.id);
                             newOwnerID.add(acc.ANI_Primary__c);
                         }else{
                             if(activeSec){
                                 ca.ownerid = acc.ANI_Secondary__c;    
                                 caseIdNewOwnerList.add(ca.id);
                                 newOwnerID.add(acc.ANI_Secondary__c);
                             }else{
                                 if(activeThi){
                                     ca.ownerid = acc.ANI_Tertiary__c;    
                                     caseIdNewOwnerList.add(ca.id);
                                     newOwnerID.add(acc.ANI_Tertiary__c);
                                 }else{
                                     //use the manager as the owner if all ANI are inactive
                                     User caseOwner = new user();
                                     caseOwner = ownerList.get(ca.ownerid);                                 
                                     if(caseOwner.Manager.isactive){
                                         if(ca.isclosed){
                                             //skip if manager role is team manager or director
                                             if(managerRoleSkip.contains(caseOwner.Manager.userrole.name) == false){
                                                 ca.ownerid = caseOwner.ManagerId;    
                                                 caseIdNewOwnerList.add(ca.id);
                                                 newOwnerID.add(caseOwner.ManagerId);
                                             }
                                         }else{
                                             ca.ownerid = AssignQueueBasedonRole(ownerList.get(ca.ownerid).userroleid);
                                             caseIdNewOwnerList.add(ca.id);
                                             newOwnerID.add(ca.ownerid);
                                         }
                                     }
                                 }    
                             }
                             
                         }//end active ANI check
                     }// end owner active check
                 }
             }
             
             //get user's CS_Telephony_Login_ID__c 
             Map<id,user> newOwnerMap = new Map<id,user>([Select Id,CS_Telephony_Login_ID__c from user where id in:newOwnerID]);
             
             //update cases, create case comment
             if(caseIdNewOwnerList.size()> 0){
                 List<case> caseToUpdate = new list<case>();
                 
                 for(id updatedCaseId: caseIdNewOwnerList){
                     if(newmap.containskey(updatedCaseId)){
                         case caseRecUpdate = newmap.get(updatedCaseId);
                         //add the Return_to_Agent_ID__c to the updated cases
                         if(newOwnerMap.containskey(caseRecUpdate.ownerid)){
                             caseRecUpdate.Return_to_Agent_ID__c = newOwnerMap.get(caseRecUpdate.ownerid).CS_Telephony_Login_ID__c;
                         }
                         caseToUpdate.add(caseRecUpdate);
                     }
                 }
                 if(caseToUpdate.size()>0){
                     update caseToUpdate;
                 }
                 
                 createCaseCommentInactive(caseIdNewOwnerList);
             }
         }    
    }//end checkActiveOwner
    //backlog 3030
    public static id AssignQueueBasedonRole(id roleId){
         system.debug('Rodney roleId '+roleId);
         system.debug('Rodney userRoleMap '+userRoleMap);
         userrole uRole = userRoleMap.get(roleID);
         system.debug('Rodney uRole  '+uRole );
         //userRoleMap
         String roleName = uRole.name;         
         id queueId;
         
         system.debug('Rodney RoleName '+rolename);
         /*
         mapNameToQueue 
         CIN-PRT
         CIN
         LA-PRT
         LA
         MN-PRT
         NJ-PRT
         JAX
         DAL
         */
         //CIN
         if(rolename.contains('CS - CIN - PRINT')){
             queueId = mapNameToQueue.get('CIN-PRT');
         }else 
             if(rolename.contains('CS - CIN')){
                 queueId = mapNameToQueue.get('CIN');    
             }
         //LA
         if(rolename.contains('CS - LA - PRINT')){
             queueId = mapNameToQueue.get('LA-PRT');
         }else 
             if(rolename.contains('CS - LA')){
                 queueId = mapNameToQueue.get('LA');    
             }
         //MN
         if(rolename.contains('CS - MN - PRINT')){
             queueId = mapNameToQueue.get('MN-PRT');
         }
         //NJ
         if(rolename.contains('CS - NJ - PRINT')){
             queueId = mapNameToQueue.get('NJ-PRT');
         }   
         //JAX
         if(rolename.contains('CS - JAX')){
             queueId = mapNameToQueue.get('JAX');
         }  
         //DAL
         if(rolename.contains('CS - DAL')){
             queueId = mapNameToQueue.get('DAL');
         }
         //VC-FS
         if(rolename == 'Vendor Claim Coordinators - FS/PKG'){
             queueId = mapNameToQueue.get('VC-FS');
         }
         
         //SALESSUPPORT
         if(rolename.contains('Sales Support')){
             queueId = mapNameToQueue.get('SALESSUPPORT');
         }
         
         //EQUIPMENT
         if(rolename.contains('EQUIPMENT')){
             queueId = mapNameToQueue.get('EQUIPMENT');
         }
         system.debug('New Owner '+queueId );
         
         return queueId;
     }
     //backlog 3030
     public static void createCaseCommentInactive(List<id> caseIDList){
         
         list<casecomment> newCaseComments = new List<casecomment>();
         
         for(id caseId: caseIdList){
             casecomment cc = new casecomment();
             cc.parentid = caseId;
             cc.commentbody = 'This case was previously owned by an inactive user and has been reassigned.';
             cc.ispublished = false;
             newCaseComments.add(cc);     
         }
         if (newCaseComments.size()>0){
             insert newCaseComments;
         }
     }            
}
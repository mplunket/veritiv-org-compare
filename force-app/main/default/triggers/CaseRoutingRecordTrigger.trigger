trigger CaseRoutingRecordTrigger on Case (before insert, before update) {
    
    try {
        //identify new cases
        if(trigger.isInsert){
            CaseTriggerHandler.newCase = true;    
        }
        List<Case> cases = Trigger.new;
        map<id, case> caseOldMap = Trigger.oldmap;
        Map<id, ANI_Routing_Record__c> idToRoutingRecord = new Map<id, ANI_Routing_Record__c>();
        Map<id, case> conId = new Map<id, case>();
        Map<id, boolean> caseIdPassMap = new Map<id, boolean>();
        //use SuppliedEmail field for checking                                        
        map<string,case> emailCaseMap = new map<string,case>();
        map<string,boolean> emailMultipleRouting = new map<string,boolean>();
        map<string,contact> emailContactMap = new map<string,contact>();
        map<string,boolean> emailMultipleContact = new map<string,boolean>();
        map <id,id> caseToRoutingMap = new map<id,id>();      
        Account VHQacc = new Account();
        VHQacc = [select id from account where name ='Veritiv Headquarters'];//skip adding account at contact ids if VHQ account
        
          
        for(Case c :cases){
            
            conId.put(c.contactId, c);
           // system.assertEquals(conId.keyset(), null);
           if(c.SuppliedEmail!=null){
               emailCaseMap.put(c.SuppliedEmail, c);
           }
            
        }
        
        for(Contact con : [select id, accountid, email, Inactive__c from contact where Inactive__c = false AND email in:emailCaseMap.keyset()]){
            if(emailMultipleContact.containskey(con.email)){
                emailMultipleContact.put(con.email,true);    
            }else{
                emailMultipleContact.put(con.email,false);   
            }    
            emailContactMap.put(con.email,con);
        }
        
        
        /*
        for(ANI_Routing_Record__c routes : [SELECT Id, ANI_Contact__c , Contact_Email_Address__c, Email_To_Address__c
                                            FROM ANI_Routing_Record__c
                                            WHERE ANI_Contact__c IN :conId.keySet()])
        */
        for(ANI_Routing_Record__c routes : [SELECT Id, ANI_Contact__c , Contact_Email_Address__c, Email_To_Address__c
                                            FROM ANI_Routing_Record__c
                                            WHERE Inactive__c =false and Contact_Email_Address__c IN :emailCaseMap.keySet()]){
          //ystem.assertEquals(routes, null);
            if(routes == null) return;
            if(emailMultipleRouting.containskey(routes.Contact_Email_Address__c+routes.Email_To_Address__c.toUpperCase().split(';|,|\\s'))){
                emailMultipleRouting.put(routes.Contact_Email_Address__c+routes.Email_To_Address__c.toUpperCase().split(';|,|\\s'),true);    
            }else{
                emailMultipleRouting.put(routes.Contact_Email_Address__c+routes.Email_To_Address__c.toUpperCase().split(';|,|\\s'),false);   
            }
            //routes.Email_To_Address__c.toUpperCase().split(';|,|\\s')== conId.get(routes.ANI_Contact__c).ToAddressRouting__c.toUpperCase().split(';|,|\\s')
            system.debug(routes);
            system.debug(conId.get(routes.ANI_Contact__c));
            if(conId.containskey(routes.ANI_Contact__c)){
                system.debug('routes.Contact_Email_Address__c = '+routes.Contact_Email_Address__c);
                system.debug('conId.get(routes.ANI_Contact__c).SuppliedEmail = '+conId.get(routes.ANI_Contact__c).SuppliedEmail);
                system.debug('routes.Email_To_Address__c.toUpperCase() = '+routes.Email_To_Address__c.toUpperCase());
                system.debug('conId.get(routes.ANI_Contact__c).ToAddressRouting__c = '+conId.get(routes.ANI_Contact__c).ToAddressRouting__c);
                
                //move ToAddressRouting__c to a variable with white spaces to avoid getting null values when using toUpperCase
                string addressRouting = '';
                if (String.isblank(conId.get(routes.ANI_Contact__c).ToAddressRouting__c)==false){
                    addressRouting = conId.get(routes.ANI_Contact__c).ToAddressRouting__c;
                }
                
                //if(routes.Contact_Email_Address__c.toUpperCase().split(';|,|\\s')== conId.get(routes.ANI_Contact__c).SuppliedEmail.toUpperCase().split(';|,|\\s')&& routes.Email_To_Address__c.toUpperCase().split(';|,|\\s')== conId.get(routes.ANI_Contact__c).ToAddressRouting__c.toUpperCase().split(';|,|\\s')){
                if(routes.Contact_Email_Address__c.toUpperCase().split(';|,|\\s')== conId.get(routes.ANI_Contact__c).SuppliedEmail.toUpperCase().split(';|,|\\s')&& routes.Email_To_Address__c.toUpperCase().split(';|,|\\s')== addressRouting.toUpperCase().split(';|,|\\s')){    
                    //conId.get(routes.ANI_Contact__c).Routing_Record__c = routes.id;
                    caseToRoutingMap.put(conId.get(routes.ANI_Contact__c).id,routes.id);
                }
            }
            
        }
        
        //TO DO: Check emailMultipleRouting and emailMultipleContact and update cases afterwards
        //    update conId.values();
        for(case ca:cases){ 
        //debuggin purposes
        // if we can catch the both ToAddressRouting__c as null in before an populated in after and New_Email_Flag__c, can we ignore the New_Email_Flag__c checking as the ToAddressRouting__c wasn't populated?
        //otherwise, we can create a static variable for this.
        caseIdPassMap.put(ca.id, false);
        if(Trigger.IsUpdate){
            system.debug('Entered update');
            system.debug('before New_Email_Flag__c ===' + caseOldMap.get(ca.id).New_Email_Flag__c );
            system.debug('after New_Email_Flag__c ===' + ca.New_Email_Flag__c );
            system.debug('before ToAddressRouting__c ===' + caseOldMap.get(ca.id).ToAddressRouting__c);
            system.debug('AfterToAddressRouting__c ===' + ca.ToAddressRouting__c);
            
            if(caseOldMap.get(ca.id).New_Email_Flag__c == 0 && ca.New_Email_Flag__c == 1 && string.isblank(caseOldMap.get(ca.id).ToAddressRouting__c) && string.isblank(ca.ToAddressRouting__c)==false ){
                caseIdPassMap.put(ca.id, true);
            }
            
        }
        
            if(ca.status=='In Routing'&& (ca.New_Email_Flag__c<1 || caseIdPassMap.get(ca.id) || CaseTriggerHandler.newCase) && string.isblank(ca.Return_to_Agent_ID__c)){           
                //move ToAddressRouting__c to a variable with white spaces to avoid getting null values when using toUpperCase
                string addressRouting = '';
                if (String.isblank(ca.ToAddressRouting__c)==false){
                    addressRouting = ca.ToAddressRouting__c;
                }
                //if(emailMultipleRouting.containskey(ca.SuppliedEmail+ca.ToAddressRouting__c.toUpperCase().split(';|,|\\s'))==false){
                if(emailMultipleRouting.containskey(ca.SuppliedEmail+addressRouting.toUpperCase().split(';|,|\\s'))==false){
                    //no routing match
                    system.debug('entered no routing match');
                    if(emailContactMap.containskey(ca.SuppliedEmail)==false||(emailContactMap.containskey(ca.SuppliedEmail)&&emailMultipleContact.get(ca.SuppliedEmail))){//nocontact match or multi match
                        ca.accountid = null;
                        ca.contactid = null;
                        ca.Routing_Record__c =null;
                        system.debug('entered no or multiple contact match');
                    }else{//single contact match
                        //commented out for backlog 3188
                        //ca.accountid = emailContactMap.get(ca.SuppliedEmail).accountid;
                        //ca.contactid = emailContactMap.get(ca.SuppliedEmail).id;     
                        //backlog 3188 - should skip if account is VHQ
                            if(emailContactMap.get(ca.SuppliedEmail).accountid != VHQacc.id){
                                ca.accountid = emailContactMap.get(ca.SuppliedEmail).accountid;
                                ca.contactid = emailContactMap.get(ca.SuppliedEmail).id;  
                            }
                        ca.Routing_Record__c =null;               
                        system.debug('entered single contact match');
                    }
                }else{//has routing
                    system.debug('entered routing match');
                    //if(emailMultipleRouting.get(ca.SuppliedEmail+ca.ToAddressRouting__c.toUpperCase().split(';|,|\\s'))){
                    if(emailMultipleRouting.get(ca.SuppliedEmail+addressRouting.toUpperCase().split(';|,|\\s'))){                    
                        system.debug('entered multi routing match');
                        if(emailContactMap.containskey(ca.SuppliedEmail)==false||(emailContactMap.containskey(ca.SuppliedEmail)&&emailMultipleContact.get(ca.SuppliedEmail))){//nocontact match or multi match
                            system.debug('entered multi routing contact match'); 
                            ca.accountid = null;
                            ca.contactid = null;
                        }else{//single contact match
                            //backlog 3188 - should skip if account is VHQ
                            if(emailContactMap.get(ca.SuppliedEmail).accountid != VHQacc.id){
                                ca.accountid = emailContactMap.get(ca.SuppliedEmail).accountid;
                                ca.contactid = emailContactMap.get(ca.SuppliedEmail).id;  
                            }
                            system.debug('entered multi routing match and single contact');                  
                        }
                        ca.Routing_Record__c =null;
                        /*
                        ca.Routing_Record__c =null;
                        ca.accountid = null;
                        ca.contactid = null;
                        */
                    }else{//single routing    
                        system.debug('entered single routing match');
                        ca.Routing_Record__c = caseToRoutingMap.get(ca.id);    
                    }
                }
                
            }
        
        }
        
        
    } catch (Exception ex) {
        System.debug('BD');
        System.debug('Error in CaseRoutingRecordTrigger');
        System.debug(ex.getMessage());
        System.debug(ex.getLineNumber());
        System.debug(ex.getStackTraceString());
        System.debug(ex.getCause());
        // silently fail to allow the case to be updated
    }    
}
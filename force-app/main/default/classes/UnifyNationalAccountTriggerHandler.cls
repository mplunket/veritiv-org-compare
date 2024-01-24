public class UnifyNationalAccountTriggerHandler {
    
    public static void afterInsertOperations(List<Unify_National_Account__C> newList){
        Map<string , Unify_National_Account__C> custNumberVsUnifyAccount = new Map<string , Unify_National_Account__C>();
        for(Unify_National_Account__C uNA: newList){
            // if(uNA.Unify_NA_Account_Type__c == 'N' && uNA.Unify_NA_Parent_Name__c != ''){
            //if(uNA.Unify_NA_Account_Type__c == 'N'){
            custNumberVsUnifyAccount.put(uNA.Unify_NA_Account_DW_Key__c, uNA);
            // }
            
        }
        
        system.debug('custNumberVsUnifyAccount'+custNumberVsUnifyAccount.keySet());
        if(custNumberVsUnifyAccount.keyset().size() > 0){
            List<Account> accList = [Select id,UNIFY_Account_Number__c,
                                     //Contract_Start_Date__c,
                                    // Contract_End_Date__c,
                                     NA_Parent_Bill_To__c,
                                     Legacy_System_Cd__c,
                                     Unify_Account_Type__c,
                                     Account_Type_Code_Definition__c,
                                     Service_Type_Unify__c,
                                     OwnerId,
                                     Account_ActionCd__c,
                                     Segment_2__c,
                                     Natl_Acct_Group_ID__c,
                                     ParentId,National_Account__c,
                                     Account_DW_Key__c,Parent.OwnerId,
                                     Contract_Group_Description__c from account where Account_DW_Key__c in: custNumberVsUnifyAccount.keySet() ];
            
            if(accList.size() > 0){
                list<AccountTeamMember> acTeamList = new List<AccountTeamMember>();
                system.debug('acclist'+ accList.size());
               // DateTime myDateTime = (DateTime) date.today();
               // String dayOfWeek = myDateTime.format('E');
                List<Account> accListUpdate = new List<Account>();
                for(account acc: accList){
                    if( custNumberVsUnifyAccount.containsKey(acc.Account_DW_Key__c)){
                        system.debug('inside first if');
                        if( custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_ActionCd__c == 'A'){
                            system.debug('inside A');
                            if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Bill_To_Number__c != null){
                                acc.NA_Parent_Bill_To__c =  custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Bill_To_Number__c;
                            }
                            if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Legacy_System_Cd__c != null){
                                acc.Legacy_System_Cd__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Legacy_System_Cd__c;
                            }
                            if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type__c != null){
                                acc.Unify_Account_Type__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type__c;
                                if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type__c ==  'N' ||
                                   custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type__c ==  'U'){
                                       acc.National_Account__c = true;
                                   }
                                
                            }
                            if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type_code_Definition__c != null){
                                acc.Account_Type_Code_Definition__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type_code_Definition__c;
                            }
                            if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Service_TypeCd__c != null){
                                acc.Service_Type_Unify__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Service_TypeCd__c;   
                            }
                            
                            
                            if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_ActionCd__c != null){
                                acc.Account_ActionCd__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_ActionCd__c; 
                            }  
                            
                            if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Natl_Acct_Group_ID__c != null){
                                acc.Natl_Acct_Group_ID__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Natl_Acct_Group_ID__c; 
                            }
                            if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Contract_Group_Description__c != null){
                                acc.Contract_Group_Description__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Contract_Group_Description__c;
                            }
                            if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Parent_Name__c != null)
                            {
                                //   acc.ParentId = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Parent_Name__c; 
                            }
                            if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Segment__c != null)
                            {
                                acc.Segment_2__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Segment__c;
                            }
                            if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Number__c != null)
                            {                                
                                
                                acc.UNIFY_Account_Number__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Number__c ;
                            }
                            if( custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_CustAcctTypeDesc__c != null)
                            {   
                                acc.Account_Type_Code_Definition__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_CustAcctTypeDesc__c;
                            }
                            
                            accListUpdate.add(acc);
                        }
                        
                        else if( custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_ActionCd__c == 'D'){
                            system.debug('inside D');
                            acc.NA_Parent_Bill_To__c = '';
                           // acc.Legacy_System_Cd__c = '';
                            acc.Unify_Account_Type__c =  '';
                            acc.Account_Type_Code_Definition__c = '';
                            acc.Service_Type_Unify__c = '';
                            acc.Account_ActionCd__c = '';
                            acc.Natl_Acct_Group_ID__c = '';
                            acc.Contract_Group_Description__c = '';
                            acc.National_Account__c = false;
                           // acc.UNIFY_Account_Number__c = '';
                             accListUpdate.add(acc);
                        }
                        
                        else if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_ActionCd__c == null)
                             
                                //&&  dayOfWeek == 'Fri'   
                                {
                                    //since system considers one day advance
                                    //system.debug('Inside Blank with saturday '+dayOfWeek);
                                    acc.NA_Parent_Bill_To__c =  custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Bill_To_Number__c;
                                    acc.Legacy_System_Cd__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Legacy_System_Cd__c;
                                    
                                    
                                   // acc.Unify_Account_Type__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type__c;
                                    
                                    if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type__c != null){
                                acc.Unify_Account_Type__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type__c;
                                if(custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type__c ==  'N' ||
                                   custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type__c ==  'U'){
                                      // system.debug('inside team member'+'Unify_NA_Account_Type__c');
                                       acc.National_Account__c = true;
                                        
                                   }
                                        else
                                        acc.National_Account__c = false;    
                                    }
                                    
                                    acc.Account_Type_Code_Definition__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Type_code_Definition__c;
                                    acc.Service_Type_Unify__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Service_TypeCd__c;   
                                    acc.Natl_Acct_Group_ID__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Natl_Acct_Group_ID__c; 
                                    acc.Account_ActionCd__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_ActionCd__c;    
                                    acc.Contract_Group_Description__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Contract_Group_Description__c;
                                    acc.Segment_2__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Segment__c;  
                                    acc.UNIFY_Account_Number__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_Account_Number__c ;     
                                    acc.Account_Type_Code_Definition__c = custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_CustAcctTypeDesc__c; 
                                     accListUpdate.add(acc);
                                }
                       
                        
                        if(acc.parentId != null && custNumberVsUnifyAccount.get(acc.Account_DW_Key__c ).Unify_NA_ActionCd__c != null){
                            system.debug('inside team member');
                            AccountTeamMember acMemb = new AccountTeamMember();
                            acMemb.accountId = acc.Id;
                            acMemb.userId = acc.Parent.OwnerId;
                            acMemb.AccountAccessLevel = 'All';
                            acMemb.CaseAccessLevel = 'All';
                            acMemb.OpportunityAccessLevel = 'All';
                            acMemb.TeamMemberRole = 'National Accts Manager';
                            acTeamList.add(acMemb);
                        }
                        
                    }
                }
                
                if( accListUpdate.size() > 0){
                     system.debug('update acc A');
                update accListUpdate;
                }
               
                
                if(acTeamList.size() > 0){
                    system.debug('insert team member');
                  // List<Database.SaveResult> updateResults = database.insert(acTeamList, false) ;
                    
                   // for(Integer i=0;i<updateResults.size();i++){
                      //  if (updateResults.get(i).isSuccess()){
                        //    updateResults.get(i).getId();
                          //  system.debug('success id'+updateResults.get(i).getId());
                       // }else if (!updateResults.get(i).isSuccess()){
                            // DML operation failed
                          //  Database.Error error = updateResults.get(i).getErrors().get(0);
                          //  String failedDML = error.getMessage();
                         //   system.debug('Failed ID'+failedDML);
                       // }/

//}
                    
                }
            }
        }
    }
}
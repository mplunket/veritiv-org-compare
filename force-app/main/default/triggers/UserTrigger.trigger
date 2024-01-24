trigger UserTrigger on User (before insert, after insert, after update, before update) {
    
    if( trigger.isInsert && trigger.isAfter){
        List<Contact> conList = new List<Contact>(); 
        List<Id> userIds = new List<Id>();
        
        List<User> usList = [Select id,Profile.UserLicense.Name from user where id in: trigger.new and Profile.UserLicense.Name != 'Customer Portal Manager Standard' and Profile.UserLicense.Name != 'Customer Community Plus'];        
        for(user us : usList){
           
                userIds.add(us.id);
          
            
        }
        
        if(userIds.size() > 0){
            createContact.createCon(trigger.newmap.keyset());
        }
        
        }



    /**/
    system.debug('isUpdate'+trigger.isUpdate);
        system.debug('isAfter'+trigger.isUpdate);
    if(trigger.isUpdate && trigger.isAfter){
        system.debug('inside update');
        List<Id> UserIds = new List<Id>();
        //The update contact code does not run when the batch process runs in the morning
        if(!system.isBatch()){
        for(User Usr: trigger.new){
            if(trigger.oldMap.get(Usr.Id).FirstName != trigger.newMap.get(Usr.Id).FirstName  ||
              trigger.oldMap.get(Usr.Id).LastName != trigger.newMap.get(Usr.Id).LastName  ||
               trigger.oldMap.get(Usr.Id).AccountId != trigger.newMap.get(Usr.Id).AccountId  ||
               trigger.oldMap.get(Usr.Id).Email != trigger.newMap.get(Usr.Id).Email  ||
               trigger.oldMap.get(Usr.Id).Title != trigger.newMap.get(Usr.Id).Title  ||
               trigger.oldMap.get(Usr.Id).Phone != trigger.newMap.get(Usr.Id).Phone  ||
               trigger.oldMap.get(Usr.Id).Primary_Sales_Rep_Id__c != trigger.newMap.get(Usr.Id).Primary_Sales_Rep_Id__c  ||
               trigger.oldMap.get(Usr.Id).CurrencyIsoCode != trigger.newMap.get(Usr.Id).CurrencyIsoCode ||
                trigger.oldMap.get(Usr.Id).isactive != trigger.newMap.get(Usr.Id).isactive
              ){
                  UserIds.add(Usr.id);
                
            }
        }
        
                if(UserIds.size() > 0){
            createContact.updateCont(UserIds);
        }
        }
        
    }
}
public class createContact {
    
    @Future
    public static void createCon(set<Id> UsrIds){
        List<Contact> conList = new List<Contact>();
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal Contacts').getRecordTypeId();
        Id UsrId = [Select Id from User where Name = 'sfdc admin'][0].Id;
        Id psrId;
        Id AccId;
        if(!test.isRunningTest()){
            psrId = [Select id from primary_sales_rep__c where name ='sfdc admin'][0].Id;
            AccId = [Select id from Account where name ='Veritiv Headquarters'][0].Id;       
        }
        
        for(user usr : [Select id,mobilephone,Fax,firstname,lastname,title,email,phone,currencyisocode,isactive,accountId from user where id in: UsrIds]){
            contact con = new contact();
            con.user__c = usr.id;
            con.recordtypeId  = conRecordTypeId;
            con.FirstName = usr.FirstName;
            con.LastName = usr.LastName;
            con.AccountId = AccId;
            con.Title = usr.Title;
            con.Email = usr.Email;
            con.ownerId = UsrId;
            con.Primary_Sales_Rep_Name__c  = psrId;
            con.currencyIsoCode = usr.currencyIsoCode;
            con.phone = usr.Phone;
            con.Fax = usr.Fax;
            con.isActive__c = true;
            con.MobilePhone = usr.MobilePhone;
            conList.add(con);
            
        }
        
        Insert conList;
    }
    
    @future
    public static void updateCont(list<Id> UserIds){
        
        
        Map<id,contact> usrIdContact = new Map<id,Contact>();
        if(UserIds.size() > 0){
            for(contact con: [Select id,Inactive_Reason__c,firstname,lastname,accountId,inactive__c,email,title,phone,Fax,Primary_Sales_Rep_Name__c ,currencyisocode,user__C From Contact where user__c in: UserIds AND recordtype.name = 'Internal Contacts']){
                usrIdContact.put(con.user__c,con);
            }
        }
        system.debug(usrIdContact+'usrIdContact');
        List<Contact> updateCOnt = new List<Contact>();
        for(user usr: [Select id,Deactivation_Reason__c,firstname,mobilephone,lastname,title,email,phone,Fax,currencyisocode,isactive,accountId from user where id in: UserIds]){
            if(usrIdContact.keyset().contains(usr.id)){
                system.debug('inside forloop');
                contact con = usrIdContact.get(usr.id);
                con.FirstName = usr.FirstName;
                con.LastName = Usr.LastName;
                con.Title = Usr.Title;
                con.Email = Usr.Email;
                con.currencyIsoCode = usr.currencyIsoCode;
                con.phone = Usr.Phone;
                con.MobilePhone = Usr.MobilePhone;
                con.Fax = Usr.Fax;
                
                
                if(usr.isActive == false){
                    con.isactive__c = false;
                    con.Inactive_Reason__c = 'No longer at company';
                    con.inactive__c = true;
                }else{
                    con.isactive__c = true;
                   con.Inactive_Reason__c = '';
                    con.inactive__c = false;
                }
                con.Bypass_Validation_Rule__c = true;
                updateCOnt.add(con);
            }
        }
        
        system.debug('updateCont'+updateCont);
        Update updateCont;
    }
}
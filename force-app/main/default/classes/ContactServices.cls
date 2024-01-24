public with sharing class ContactServices 
{
    static Integer TEST = 0;

    public static final String OPT_OUT_FIELD = 'HasOptedOutOfEmail';

    public static final Boolean DEFAULT_OPT_STATUS = false;

    public static String CREATED_DATE_FIELD = 'CreatedDate';

    public static Boolean processedMarketing = false;
    
    public static Id ACCOUNT_VENDOR_RTYPE_ID {
        
        get{
            if( ACCOUNT_VENDOR_RTYPE_ID == null )
            {
                return  [SELECT ID 
                                        FROM Recordtype
                                        WHERE DeveloperName = 'Vendor' 
                                        AND SObjectType = 'Account'
                                        LIMIT 1].Id;
            }
            return ACCOUNT_VENDOR_RTYPE_ID;
            //return ACCOUNT_VENDOR_RTYPE_ID;
        } 
        
    }
    
    public static Id CONTACT_VENDOR_RTYPE_ID {
        
        get{
            if( CONTACT_VENDOR_RTYPE_ID == null )
            {
               /* return [SELECT ID 
                                            FROM Recordtype
                                            WHERE DeveloperName = 'VendorContact' 
                                            AND SObjectType = 'Contact'
                                            LIMIT 1].Id;*/
                
                return Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor Contact').getRecordTypeId();


            }
            return CONTACT_VENDOR_RTYPE_ID;
        } 
        
    }
    
    public static List<Contact> filterContactsFromULSAccounts(List<Contact> contacts)
    {
        Set<ID> contactsWithULSAccts = Pluck.ids([Select ID From Contact Where ID IN:contacts AND Account.Is_ULS_Primary_Acct__c = true]);
        List<Contact> retContacts = new List<Contact>();
        for(Contact c : contacts)
        {
            if(contactsWithULSAccts.contains(c.ID))
            {
                retContacts.add(c);
            }
        }
        return retContacts;
    }
    
    public static List<Contact> filterContactsFromPublisherAction(List<Contact> contacts)
    {
        List<Contact> retContacts = new List<Contact>();
        for(Contact c: contacts)
        {
            if(c.Created_by_Quick_Create__c)
                retContacts.add(c);
        }
        return retContacts;
    }
    
    public static Map<String, Contact> groupContactsByFromAddress(List<Contact> contacts)
    {
        Map<String, Contact> retMap = new Map<String, Contact>();
        for(Contact c : contacts)
        {
            retMap.put(c.Email,c);
        }
        return retMap;
    }
    

    public static List<Case> associateCasesWithContact(Map<String, List<Case>> emailToCases, Map<String, Contact> emailToContact)
    {
        List<Case> cases = new List<Case>();
        for(String email : emailToCases.keySet())
        {
            ID contactID = emailToContact.get(email).ID;
            for(Case aCase : emailToCases.get(email))
            {
                aCase.ContactID = contactID;
                aCase.AccountID = emailToContact.get(email).AccountID;
                cases.add(aCase);
            }
        }
        return cases;
    }
    
    //Sujitha commented to remove FS Aduit Functionality Backlog#702    
    /*public static List<Contact> filterOutInternalContacts(List<Contact> contacts)
    {
        List<Contact> retContacts = new List<Contact>();
        for(Contact c : contacts)
        {
            if(!EmailMessageServices.isInternalEmailDomain(c.Email))
            {
                retContacts.add(c);
            }
        }
        return retContacts;
    }
    */
    public static void populateMatchingCasesWithContacts(Map<ID, Contact> newContacts)
    {
        //Sujitha commented to remove FS Aduit Functionality Backlog#702
        //Map<String, Contact> emailToQCContact = groupContactsByFromAddress(filterContactsFromULSAccounts(filterOutInternalContacts(filterContactsFromPublisherAction(newContacts.values()))));
        //Map<String, List<Case>> emailToCase = findCasesForEmails(emailToQCContact.keySet());
        //List<Case> cases = associateCasesWithContact(emailToCase,emailToQCContact);
        SafeDML casesToUpdate = new SafeUpdate();
        //casesToUpdate.queue(cases, new ErrorHandling.AddErrorsToTriggerNew(newContacts,'ContactID'));
        casesToUpdate.doDml();
    }
    
    public static Map<String, List<Contact>> filterContactsAttachedToVendors (List<Contact> incomingContacts, Map<Id, Contact>oldContactIdToOldContact)
    {
        //VendorCode => List Of Contacts
        Map<String, List<Contact>> vendorCodeToContactList = new Map<String, List<Contact>>();
        
        //Create a list of prelim cases, to save on queries
        List<Contact> prelimContacts = new List<Contact>();
        
        for( Contact incomingContact : incomingContacts )
        {
            Contact oldContact = oldContactIdToOldContact == null ? null : oldContactIdToOldContact.get( incomingContact.Id );
            
            Boolean prelimChange = ( incomingContact.RecordtypeId == CONTACT_VENDOR_RTYPE_ID )
                                && (oldContact == null || incomingContact.AccountId != oldContact.AccountId );
            
            if( prelimChange )
                prelimContacts.add( incomingContact );
        }
        
        //Lets get the account information for these cases
        if( !prelimContacts.isEmpty() )
        {
            prelimContacts = [SELECT Id, AccountId, 
                                     Account.RecordTypeId, RecordTypeId,
                                     Account.VENDOR_CODE__c 
                              FROM Contact 
                              WHERE Id in :prelimContacts];
            
            for( Contact incomingContact : prelimContacts)
            {
                Contact oldContact = oldContactIdToOldContact == null ? null : oldContactIdToOldContact.get( incomingContact.Id );
                
                Boolean isChanged = ( (incomingContact.Account.RecordTypeId == ACCOUNT_VENDOR_RTYPE_ID)
                                    &&( incomingContact.RecordtypeId == CONTACT_VENDOR_RTYPE_ID )
                                    && (oldContact == null || incomingContact.AccountId != oldContact.AccountId )
                                    && (incomingContact.Account.VENDOR_CODE__c != null ));
                                    
                if( isChanged )
                {
                    if( !vendorCodeToContactList.containsKey( incomingContact.Account.VENDOR_CODE__c ) )
                        vendorCodeToContactList.put( incomingContact.Account.VENDOR_CODE__c, new List<Contact>() );
                    vendorCodeToContactList.get( incomingContact.Account.VENDOR_CODE__c ).add( incomingContact );
                }   
            }
        }
        return vendorCodeToContactList; 
    }
    //backlogv 2259 and 2342     
    public static void assignAccountOwner (List<Contact> newContacts){
        list <string> profileNames = new list<string>{'Can - Manager', 'Can - Sales Rep', 'Sales Professional - Lightning','Sales Manager - Lightning', 'TSB Rep - Lightning','TSB Manager - Lightning', 'Corporate Accounts - Lightning', 'VLS - Lightning', 'Credit & Collections'};
        set <id> profileIdSet = new set<id>();
        //get profiles that are excluded
        for (Profile p: [select id, name from profile where name in:profileNames]){
            profileIdSet.add(p.id);
        }
        //get current owners to check profile. Get accounts as well        
        list<id> contactOwners = new list<id>();
        list<id> accountIdList = new list<id>();
        
        for (Contact con: newContacts){
            contactOwners.add(con.ownerid);
            accountIdList.add(con.accountid);
        }
        //map owner to profile, map if active as well
        map<id, id> mapOwnerToProfile = new map<id,id>();     
        map<id, boolean> mapOwnerActive = new map<id,boolean>();      
        for(User u: [select id, profileid, IsActive from user where id in :contactOwners]){
            mapOwnerToProfile.put(u.id, u.profileid);
            mapOwnerActive.put(u.id, u.IsActive);
        }
        //Map account to account owner
        map<id,id> mapAccountOwner = new map<id,id>();
        for(Account acc:[select id, ownerid from account where id in:accountIdList]){
            mapAccountOwner.put(acc.id,acc.ownerid);
        }
        //check if account owners are active
        if(mapAccountOwner.values().size()>0){
            for(User u: [select id, profileid, IsActive from user where id in :mapAccountOwner.values()]){
               
                mapOwnerActive.put(u.id, u.IsActive);
            } 
        }
        
        //get primary sales rep
        List<Primary_Sales_Rep__c> relatedReps = [SELECT Id, SF_UserId__c FROM Primary_Sales_Rep__c WHERE SF_UserId__c IN :mapAccountOwner.values()];
        //Map PSR to user ID
        map<id,id> userPSRMap = new map<id,id>();
        for(Primary_Sales_Rep__c psr : relatedReps){
            userPSRMap.put(psr.SF_UserId__c, psr.id);    
        }
        
        //check contacts and update owners if needed
        for (Contact con: newContacts){
            //check if excluded
            id currentOwner = con.ownerid;
            if(profileIdSet.contains(mapOwnerToProfile.get(currentOwner))==false){
                //update contact owner to match account
                if(mapAccountOwner.containskey(con.accountid)){
                    if(string.isblank(mapAccountOwner.get(con.accountid))==false){
                        if(mapOwnerActive.containskey(mapAccountOwner.get(con.accountid))){
                            if(mapOwnerActive.get(mapAccountOwner.get(con.accountid)))
                            {
                                con.ownerid =  mapAccountOwner.get(con.accountid);  
                                con.Primary_Sales_Rep_Name__c  = userPSRMap.get(con.ownerid); 
                            }
                        }
                    }
                }
                
                
            }
            
        }
        
    
    }
    //backlog 2342
    public static void PSRUpdateOnOwnerChange(Map<Id, Contact> oldMap, Map<Id, Contact> newMap){
        //check if owner changed
        list<id> ownerIdList = new list<id>();
        list<id> affectedContacts = new list<id>();
        for (Contact con: newMap.values()){
            if(con.ownerid!=oldMap.get(con.id).ownerid){
                ownerIdList.add(con.ownerid);
                affectedContacts.add(con.id);
            }            
        }
        
        //get primary sales rep
        List<Primary_Sales_Rep__c> relatedReps = [SELECT Id, SF_UserId__c FROM Primary_Sales_Rep__c WHERE SF_UserId__c IN :ownerIdList];
        //Map PSR to user ID
        map<id,id> userPSRMap = new map<id,id>();
        for(Primary_Sales_Rep__c psr : relatedReps){
            userPSRMap.put(psr.SF_UserId__c, psr.id);    
        }
        
        for(id conId : affectedContacts ){
            if(userPSRMap.containskey(newMap.get(conid).ownerid)){
                newMap.get(conid).Primary_Sales_Rep_Name__c = userPSRMap.get(newMap.get(conid).ownerid);
            }
        }
        
             
    }
    
    public static void populateContactVendors ( Map<String, List<Contact>> vendorCodeToContactList)
    {
        if( !vendorCodeToContactList.isEmpty() )
        {
            List<Contact> contactsToUpdate = new List<Contact>();
            
            //VendorCode => Vendor
            Map<String, Vendor_Detail__c> vendorCodeToVendor = new Map<String, Vendor_Detail__c>();
            
            for(Vendor_Detail__c foundVendor : [SELECT Id, Vendor_Code__c 
                                                FROM Vendor_Detail__c 
                                                WHERE Vendor_Code__c in :vendorCodeToContactList.keySet() ] )
            {
                vendorCodeToVendor.put( foundVendor.Vendor_Code__c, foundVendor );
            }       
            
            for( String vendorCode : vendorCodeToContactList.keySet() )
            {
                for( Contact contactToUpdate : vendorCodeToContactList.get( vendorCode ) )
                {
                    contactToUpdate.Vendor_Lookup__c = vendorCodeToVendor.get( vendorCode ).Id;
                    contactsToUpdate.add( contactToUpdate );
                }
                
            }
        
            if( !contactsToUpdate.isempty() )
                update contactsToUpdate;
        }
    }
    
    //Converting PB logic to Trigger to add Address to Contact from Acccount  if the State is NULL in Contact 6/17/2021
   /* public static void updateMaillingAddress(List<Contact> newList){
        List<Id> accIds = new List<Id>();
        for(contact con: newList){
            if(con.MailingState == null || con.MailingState == ''){
                accIds.add(con.accountId);
            }
        }
        if(accIds.size() > 0){
            Map<Id,Account> accMap = new Map<Id, Account>([SELECT Id, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStreet FROM Account where id in:accIds]);
        	for(contact con: newList){
            if(con.MailingState == null || con.MailingState == ''){
                con.MailingCity = accMap.get(con.accountId).billingCity;
                con.MailingCountry = accMap.get(con.accountId).BillingCountry;
                con.MailingPostalCode = accMap.get(con.accountId).BillingPostalCode;
                con.MailingState = accMap.get(con.accountId).BillingState;
                con.MailingStreet = accMap.get(con.accountId).BillingStreet;
            }
        }
            
        }
    }
    */
}
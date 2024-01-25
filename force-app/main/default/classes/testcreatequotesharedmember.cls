@isTest(SeeAllData=true)
public class testcreatequotesharedmember {
    //Test method for testing trigger and class     
    private static Id DIRECT_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get( '20. F2C - Inbound Case' ).getRecordTypeId();
    
    public static testMethod void testInsertQuote()
    {
        RecordType accountrecordtype = [select r.Id from RecordType r where r.name = 'Prospect'];
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User ownerid1 = [select id from user where isactive = true and ProfileId =: p.Id limit 1];
        User ownerid2 = [select id from user where user.id != :ownerid1.id and isactive = true and ProfileId =: p.Id and id !=:ownerid1.Id limit 1];
        System.debug('==== : '+ownerid1+' - '+ownerid2);
        Account account = new Account();
        account.name = 'RamiTestAccount';
        account.ownerid = ownerid1.Id;
        account.recordtypeid = accountrecordtype.Id;


        Test.startTest();
        insert account;
        
        Quote__c newquote = new Quote__c();
        newquote.account__c = account.id;
        newquote.ownerid = ownerid2.Id;

        insert newquote;
        Test.stopTest();        
    }
    
    public static testMethod void testUpdateQuoteOwner()
    {
        RecordType accountrecordtype = [select r.Id from RecordType r where r.name = 'Prospect'];
        List<User> testUsers = new List<User>();
        System.runAs ( TestingUtils.ADMIN_USER ){ 
            /* BL 3268 Removed PDN Restricted - Lightning Profile 7/08/22 */
            testUsers = TestingUtils.createUsers( 'xzsuser', 'PDN - Lightning', /*'PDN Restricted - Lightning',*/ 3, true );
        }
        Account account = new Account();
        account.name = 'RamiTestAccount';
        account.ownerid = testUsers[0].Id;
        account.recordtypeid = accountrecordtype.Id;


        Test.startTest();
        insert account;
        
        Quote__c newquote = new Quote__c();
        newquote.account__c = account.id;
        newquote.ownerid = testUsers[1].Id;

        insert newquote;
        
        Quote__c updatequote = [select id, account__c, ownerid from Quote__c where id = :newquote.id];
        
        
        updatequote.ownerid = testUsers[2].id;
        
        update updatequote;
        
        Test.stopTest();            
    }   
    
    public static testMethod void testUpdateQuote()
    {
        RecordType accountrecordtype = [select r.Id from RecordType r where r.name = 'Prospect'];
                Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];

        User ownerid1 = [select id,profile.Name from user where isactive = true and ProfileId =: p.id limit 1];
        User ownerid2 = [select id,profile.Name from user where user.id != :ownerid1.id and isactive = true  and ProfileId =: p.id limit 1];
        Account account = new Account();
        account.name = 'RamiTestAccount';
        account.ownerid = ownerid1.Id;
        account.recordtypeid = accountrecordtype.Id;


        Test.startTest();
        Quote__c newquote = new Quote__c();
         system.runAs(ownerid1){
        insert account;
        
        
        newquote.account__c = account.id;
        newquote.ownerid = ownerid2.Id;

       
            
         system.debug('quote owner'+newquote.account__r.Owner.Profile.Name); 
            system.debug('quote owner'+ownerid1.Profile.Name);
           insert newquote;
        }
        
        
        Quote__c updatequote = [select id, account__c, ownerid from Quote__c where id = :newquote.id];
        
        User ownerid3 = [select id from user where user.id != :ownerid1.id and user.id != :ownerid2.id and profileId =: p.id and isactive = true limit 1];
        
        //Create new account for updating existing quote
        Account newAccount = new Account();
        newAccount.name = 'NewTestAccount';
        newAccount.ownerid = ownerid3.id;
        
        insert newAccount;
        
        
        updatequote.account__c = newAccount.id;
        
        update updatequote;
        
       
        Test.stopTest();            
    }
    
        //Test method for testing trigger and class     
    public static testMethod void testInsertCase()
    {
        RecordType accountrecordtype = [select r.Id from RecordType r where r.name = 'Prospect'];
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        
        User ownerid1 = [select id from user where isactive = true and profileId = : p.id limit 1];
        User ownerid2 = [select id from user where user.id != :ownerid1.id  and profileId = : p.id and isactive = true limit 1];
        Account account = new Account();
        account.name = 'RamiTestAccount';
        account.ownerid = ownerid1.Id;
        account.recordtypeid = accountrecordtype.Id;


        Test.startTest();
        insert account;
        RecordType caserecordtype = [select r.Id from RecordType r where SobjectType = 'Case' and IsActive = true limit 1];
        Case newcase = new Case();
        newcase.accountid = account.id;
        newcase.ownerid = ownerid2.Id;
        newcase.type = 'Proactive';
        newcase.Status = 'New';
        newcase.recordtypeid = caserecordtype.Id;

        insert newcase;
        Test.stopTest();
    }
    
    
    public static testMethod void testUpdateCase()
    {
        RecordType accountrecordtype = [select r.Id from RecordType r where r.name = 'Prospect'];
        User ownerid1 = [select id from user where isactive = true and Profile.Name = 'CS - Lightning Console' limit 1];
        User ownerid2 = [select id from user where user.id != :ownerid1.id and isactive = true and Profile.Name = 'CS - Lightning Console' limit 1];
        Account account = new Account();
        account.name = 'RamiTestAccount';
        account.ownerid = ownerid1.Id;
        account.recordtypeid = accountrecordtype.Id;


        Test.startTest();
        insert account;
        
        RecordType caserecordtype = [select r.Id from RecordType r where SobjectType = 'Case' and IsActive = true limit 1];
        Case newcase = new Case();
        newcase.accountid = account.id;
        newcase.ownerid = ownerid2.Id;
        newcase.type = 'Proactive';
        newcase.Status = 'New';
        newcase.recordtypeid = caserecordtype.Id;

        insert newcase;
        
        Case updatecase = [select id, accountid, ownerid from case where id = :newcase.id];
                Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];

        User ownerid3 = [select id from user where user.id != :ownerid1.id and profile.id=: p.id and user.id != :ownerid2.id and isactive = true limit 1];
        
        //Create new account for updating existing quote
        Account newAccount = new Account();
        newAccount.name = 'NewTestAccount';
        newAccount.ownerid = ownerid3.id;
        
        insert newAccount;
        
        
        updatecase.accountid = newAccount.id;
        
        update updatecase;
        
        Test.stopTest();            
    }
    
    public static testMethod void testcreatebulkcase()
    {
        RecordType contactrecordtype = [select r.Id from RecordType r where r.Name = 'Customer Contact'];
        Account account = [select a.id, a.Account_DW_key__c from Account a where account.owner.isActive = true limit 1];
        Contact contact = [select c.id from Contact c where contact.owner.isActive = true limit 1];
        list<Case> cases = new list<Case>();

        for(Integer i=0; i<21; i++)
        {       
            Case newcase = new Case();
            newcase.accountid = account.id;
            newcase.contactid = contact.id;
            newcase.type = 'Service Request';
            newcase.recordtypeid = DIRECT_ORDER_RECORD_TYPE_ID;
            newcase.Proactive_Case_ID__c = null;
            cases.add(newcase);
        }
        
        Test.startTest();       
        insert cases;
        Test.stopTest();
    }
    
    public static testMethod void testcreatecasesharedmember()
    {
        RecordType contactrecordtype = [select r.Id from RecordType r where r.Name = 'Customer Contact'];
        Account account = [select a.id, a.Account_DW_key__c from Account a where account.owner.isActive = true limit 1];
        Contact contact = [select c.id from Contact c where contact.owner.isActive = true limit 1];
        
        Case newcase = new Case();
        newcase.accountid = account.id;
        newcase.contactid = contact.id;
        newcase.type = 'Service Request';
        newcase.recordtypeid = DIRECT_ORDER_RECORD_TYPE_ID;
        newcase.Proactive_Case_ID__c = null;
        
        Test.startTest();       
        insert newcase;
        Test.stopTest();
    }
    

    
    public static testMethod void testcreatecasesharedmemberupdate()
    {
        RecordType contactrecordtype = [select r.Id from RecordType r where r.Name = 'Customer Contact'];
        Account account = [select a.id, a.Account_DW_key__c from Account a where account.owner.isActive = true limit 1];
        Account newaccount = [select a.id, a.Account_DW_key__c from Account a where a.id != :account.id and account.owner.isActive = true limit 1];
        Contact contact = [select c.id from Contact c where contact.owner.isActive = true limit 1];
        User ownerid1 = [select id from user where isactive = true and Profile.Name = 'CS - Lightning Console' limit 1];   
            
        Case newcase = new Case();
        newcase.accountid = account.id;
        newcase.contactid = contact.id;
        newcase.ownerid = ownerid1.id;
        newcase.type = 'Service Request';
        newcase.recordtypeid = DIRECT_ORDER_RECORD_TYPE_ID;
        newcase.Proactive_Case_ID__c = null;
        
        Test.startTest();       
        insert newcase;
        
        Case updatecase = new Case(Id = newcase.id, accountid = newaccount.id);
        update updatecase;
        
        Test.stopTest();
    }

    public static testMethod void testupdatecaseowner()
    {
        RecordType contactrecordtype = [select r.Id from RecordType r where r.Name = 'Customer Contact'];
        Account account = [select a.id, a.Account_DW_key__c from Account a where account.owner.isActive = true limit 1];
        Contact contact = [select c.id from Contact c where contact.owner.isActive = true limit 1];
        User ownerid1 = [select id from user where isactive = true and Profile.Name = 'CS - Lightning Console' limit 1];   
        User ownerid2 = [select id from user where id != :ownerid1.id and isactive = true and Profile.Name = 'CS - Lightning Console' limit 1];
                
        Case newcase = new Case();
        newcase.accountid = account.id;
        newcase.contactid = contact.id;
        newcase.ownerid = ownerid1.id;
        newcase.type = 'Service Request';
        newcase.recordtypeid = DIRECT_ORDER_RECORD_TYPE_ID;
        newcase.Proactive_Case_ID__c = null;

        Test.startTest();           
        insert newcase;
                
        Case updatecaseowner = new Case(Id = newcase.id, ownerid = ownerid2.id);
        update updatecaseowner;
        Test.stopTest();
    }   
    

}
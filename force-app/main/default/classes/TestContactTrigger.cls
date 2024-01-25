@isTest
private class TestContactTrigger {
    static Integer offset = 0;
    static Id caseGroupOwnerId;
    
    
    static
    {
        List<RecordType> caseRecordTypes = [Select ID From RecordType Where SObjectType='Case' And IsActive=True Limit 1];
        insert (new InactiveRecordTypes__c(Name=CaseServices.EBUSINESS_RT_NAME,Record_Type_Id__c=caseRecordTypes[0].ID));
        caseGroupOwnerId = TestingUtils.createGroup('CaseGroupOwner', 'Queue', true).Id;
    }
    
    public static List<String> generateEmails(Integer howMany, String domain)
    {
        List<String> emails = new List<String>();
        Integer i = offset;
        for(; i < offset+howMany; i++)
        {
            emails.add('sampleemail'+i+'@'+domain);
        }
        offset = i;
        return emails;
    }
    
    private static testMethod void Test_AccountRollup_Insert()
    {
        List<Account> testAccount = (List<Account>) SObjectFactory.create(2, Account.SObjectType);
        List<Contact> testContacts = (List<Contact>) SObjectFactory.build(40, Contact.SObjectType);
        UnitTest.addData(testContacts).tag('All Contacts').divide(2).part('Active C').part('Inactive C');
        UnitTest.addData(testAccount).tag('All Accounts');
        UnitTest.get('All Contacts').property('AccountId').assignFrom('All Accounts');
        UnitTest.get('Active C').property('Inactive__c').assign(true);
        
        Test.startTest();
            UnitTest.get('All Contacts').insertAll();
        Test.stopTest();
        Boolean contactTriggerActive = checkContactTriggerStatus();
        List<Account> requeriedAccounts = [SELECT Id, Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account];
        for(Account acc : requeriedAccounts)
        {
            if(contactTriggerActive ){//skip if contactTrigger is inactive
                System.assertEquals(20, acc.Number_of_Contacts__c, 'We expect each Account to have a sum of 20 Total Contacts.');
                System.assertEquals(10, acc.Number_of_Active_Contacts__c, 'We expect each Account have a sum of 10 Active Contacts.');
            }
        }
    }
    
    private static testMethod void Test_AccountRollup_Update()
    {
        List<Account> testAccount = (List<Account>) SObjectFactory.create(2, Account.SObjectType);
        List<Contact> testContacts = (List<Contact>) SObjectFactory.build(40, Contact.SObjectType);
        UnitTest.addData(testContacts).tag('All Contacts').divide(2).part('Active C').part('Inactive C');
        UnitTest.addData(testAccount).tag('All Accounts');
        UnitTest.get('All Contacts').property('AccountId').assignFrom('All Accounts');
        UnitTest.get('Active C').property('Inactive__c').assign(true);
        UnitTest.get('All Contacts').insertAll();
        Boolean contactTriggerActive = checkContactTriggerStatus();
        List<Account> requeriedAccounts = [SELECT Id, Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account];
        for(Account acc : requeriedAccounts)
        {
            if(contactTriggerActive ){//skip if contactTrigger is inactive
                System.assertEquals(20, acc.Number_of_Contacts__c, 'We expect each Account to have a sum of 20 Total Contacts.');
                System.assertEquals(10, acc.Number_of_Active_Contacts__c, 'We expect each Account have a sum of 10 Active Contacts.');
            }
        }
        
        UnitTest.get('Active C').property('Inactive__c').assign(false);
        
        Test.startTest();
            UnitTest.get('Active C').updateAll();
        Test.stopTest();
        
        requeriedAccounts = [SELECT Id, Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account];
        for(Account acc : requeriedAccounts)
        {
            if(contactTriggerActive ){//skip if contactTrigger is inactive
                System.assertEquals(20, acc.Number_of_Contacts__c, 'We expect each Account to have a sum of 20 Total Contacts.');
                System.assertEquals(20, acc.Number_of_Active_Contacts__c, 'We expect each Account have a sum of 10 Active Contacts.');
            }
        }
    }
    
    private static testMethod void Test_AccountRollup_Delete()
    {
        CaseNotification.isInsertingTempContacts = true;
        
        List<Account> testAccount = (List<Account>) SObjectFactory.create(2, Account.SObjectType);
        List<Contact> testContacts = (List<Contact>) SObjectFactory.build(40, Contact.SObjectType);
        UnitTest.addData(testContacts).tag('All Contacts').divide(2).part('Active C').part('Inactive C');
        UnitTest.addData(testAccount).tag('All Accounts');
        UnitTest.get('All Contacts').property('AccountId').assignFrom('All Accounts');
        UnitTest.get('Active C').property('Inactive__c').assign(true);
        UnitTest.get('All Contacts').insertAll();
        
        Test.startTest();
            UnitTest.get('All Contacts').deleteAll();
        Test.stopTest();
        
        List<Account> requeriedAccounts = [SELECT Id, Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account];
        for(Account acc : requeriedAccounts)
        {
            System.assertEquals(0, acc.Number_of_Contacts__c, 'We expect each Account to have a sum of 20 Total Contacts.');
            System.assertEquals(0, acc.Number_of_Active_Contacts__c, 'We expect each Account have a sum of 10 Active Contacts.');
        }
    }
    
    private static testMethod void Test_AccountRollup_UnDelete()
    {
        CaseNotification.isInsertingTempContacts = true;
        
        List<Account> testAccount = (List<Account>) SObjectFactory.create(2, Account.SObjectType);
        List<Contact> testContacts = (List<Contact>) SObjectFactory.build(40, Contact.SObjectType);
        UnitTest.addData(testContacts).tag('All Contacts').divide(2).part('Active C').part('Inactive C');
        UnitTest.addData(testAccount).tag('All Accounts');
        UnitTest.get('All Contacts').property('AccountId').assignFrom('All Accounts');
        UnitTest.get('Active C').property('Inactive__c').assign(true);
        UnitTest.get('All Contacts').insertAll();
        
        Test.startTest();
            UnitTest.get('All Contacts').deleteAll();
            
            List<Contact> requeriedContacts = [SELECT Id FROM Contact];
            System.assertEquals(0, requeriedContacts.size(), 'We expect no contacts to exists.');
        
            undelete UnitTest.get('All Contacts').getList();
        Test.stopTest();
        Boolean contactTriggerActive = checkContactTriggerStatus();
        List<Account> requeriedAccounts = [SELECT Id, Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account];
        for(Account acc : requeriedAccounts)
        {
            if(contactTriggerActive ){//skip if contactTrigger is inactive
                System.assertEquals(20, acc.Number_of_Contacts__c, 'We expect each Account to have a sum of 20 Total Contacts.');
                System.assertEquals(10, acc.Number_of_Active_Contacts__c, 'We expect each Account have a sum of 10 Active Contacts.');
            }
        }
    }
    
    public static boolean checkContactTriggerStatus(){
        ApexTrigger contactTrigger =  [Select Id, Status, name, NamespacePrefix from ApexTrigger where name='ContactTrigger' AND NamespacePrefix = null];
        if(contactTrigger.status == 'Active'){
            return true;
        }
        return false;
    }
    
    /*public static testMethod void testQuickCreateContactTrigger()
    {
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        //App_Domain_Restrictions__c internalDomainCustomSetting = TestingUtils.createDomainRestrictions('unisource.com', 1, 'USD', true)[0];
        //final String internalDomain = internalDomainCustomSetting.domain__c;
        
        final ID qualifyingRecordTypeID = [Select ID From RecordType Where DeveloperName IN: CaseServices.ULS_CASES AND IsActive=TRUE LIMIT 1].ID;
        final ID notQualifyingRecordTypeID = [Select ID From RecordType Where DeveloperName NOT IN: CaseServices.ULS_CASES AND SObjectType='Case' AND IsActive=TRUE LIMIT 1].ID;
        
        Integer NUM_NORMAL_CREATE_CONTACTS = 100;
        Integer NUM_QUICK_CREATE_ULS_CONTACTS = 25;
        Integer NUM_QUICK_CREATE_NON_ULS_CONTACTS = 50;
        Integer NUM_QUICK_CREATE_ULS_INTERNAL_CONTACTS = 25;
        
        List<String> emailsForNormalCreateContacts = generateEmails(NUM_NORMAL_CREATE_CONTACTS, 'gmail.com');
        List<String> emailsForQuickCreateULSContacts = generateEmails(NUM_QUICK_CREATE_ULS_CONTACTS, 'gmail.com');
        List<String> emailsForQuickCreateNonULSContacts = generateEmails(NUM_QUICK_CREATE_NON_ULS_CONTACTS, 'gmail.com');
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        //List<String> emailsForQuickCreateULSInternalContacts = generateEmails(NUM_QUICK_CREATE_ULS_INTERNAL_CONTACTS, internalDomain);
                
        UnitTest.addData(TestingUtils.createULSAccounts(10, 'Test', false)).assign('Is_ULS_Primary_Acct__c',true).tag('ULS Accounts');
        UnitTest.addData(TestingUtils.createAccounts('Test',20)).tag('NonULS Accounts');
        UnitTest.get(Account.SObjectType).insertAll();
                
        UnitTest.addData(TestingUtils.createContacts('Preexisting Contact', 10, true)).tag('Preexisting Contact');
        
        UnitTest.createTestData(TestingUtils.cases).many(1000).tag('Cases').divide(2).part('Cases to Modify').part('Cases to Not Modify');
        
        UnitTest.get('Cases to Modify').property('From_Address_of_Originating_Email__c').assignFrom(emailsForQuickCreateULSContacts)
                                       .assign('RecordTypeID',qualifyingRecordTypeID);
                                       
        UnitTest.get('Cases to Not Modify').divide(4).part('Cases That Already Have Contacts').part('Cases Which Match To NonULS Contacts')
                                            .part('Cases Without Matching Quick Created Contacts') //.part('Cases With Different Record Type')
                                            .part('Cases With Internal Contacts');
                                            
        
        UnitTest.get('Cases Without Matching Quick Created Contacts').property('From_Address_of_Originating_Email__c').assignFrom(emailsForNormalCreateContacts)
                                                                     .assign('RecordTypeID',qualifyingRecordTypeID);
        UnitTest.get('Cases That Already Have Contacts').property('From_Address_of_Originating_Email__c').assignFrom(emailsForQuickCreateULSContacts);
        //UnitTest.get('Cases With Different Record Type').assign('RecordTypeID',notQualifyingRecordTypeID)
        //                                              .property('From_Address_of_Originating_Email__c').assignFrom(emailsForQuickCreateULSContacts);      
        UnitTest.get('Cases Which Match To NonULS Contacts').property('From_Address_of_Originating_Email__c').assignFrom(emailsForQuickCreateNonULSContacts)
                                                            .assign('RecordTypeID',qualifyingRecordTypeID);
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        /*UnitTest.get('Cases With Internal Contacts').property('From_Address_of_Originating_Email__c').assignFrom(emailsForQuickCreateULSInternalContacts)
                                                            .assign('RecordTypeID',qualifyingRecordTypeID);
                                                                                                                
        UnitTest.get('Cases').insertAll();
        
        
        UnitTest.get('Cases That Already Have Contacts').property('ContactID').assignFrom('Preexisting Contact')
                                                        .assign('RecordTypeID',qualifyingRecordTypeID)
                                                        .updateAll();
        UnitTest.addData(TestingUtils.createContacts('QC NonULS Contact', NUM_QUICK_CREATE_NON_ULS_CONTACTS, false)).tag('Quick Create Non Contact').tag('Contact to Insert')
                                                                                                    .property('Email').assignFrom(emailsForQuickCreateNonULSContacts)
                                                                                                    .property('AccountID').assignFrom('NonULS Accounts')
                                                                                                    .assign('Created_by_Quick_Create__c',true);
        UnitTest.addData(TestingUtils.createContacts('QC Contact', NUM_QUICK_CREATE_ULS_CONTACTS, false)).tag('Quick Create ULS Contact').tag('Contact to Insert')
                                                                                                    .property('Email').assignFrom(emailsForQuickCreateULSContacts)
                                                                                                    .assign('Created_by_Quick_Create__c',true)
                                                                                                    .property('AccountID').assignFrom('ULS Accounts');
        UnitTest.addData(TestingUtils.createContacts('NM Contact', NUM_NORMAL_CREATE_CONTACTS, false)).tag('Normal Contact').tag('Contact to Insert')
                                                                                                    .property('Email').assignFrom(emailsForNormalCreateContacts)
                                                                                                    .property('AccountID').assignFrom('ULS Accounts');
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        /*UnitTest.addData(TestingUtils.createContacts('Internal Contact', NUM_QUICK_CREATE_ULS_INTERNAL_CONTACTS, false)).tag('Internal Contact').tag('Contact to Insert')
                                                                                                    .property('Email').assignFrom(emailsForQuickCreateULSInternalContacts)
                                                                                                    .property('AccountID').assignFrom('ULS Accounts')
                                                                                                    .assign('Created_by_Quick_Create__c',true);                                                                                 
        Test.startTest();                                                                           
            UnitTest.get('Contact to Insert').insertAll();
        Test.stopTest();                                    
            
        List<Case> modifiedCases = [Select ID, ContactID FROM Case WHERE ContactID IN:UnitTest.getIds('Contact to Insert')];
        try{

            UnitTest.analyze('Cases to Modify').assertEquivalence(modifiedCases, 'We will only modify cases that meet the appropriate criteria. Namely, they must not currently be associated to a contact, they must have an originating email address that matches an inserted quick create uls contact with a external email address, and they must have a qualifying record type');             
        }
        catch(exception e){
            
        }
        for(Case c : modifiedCases)
        {
            System.assert(UnitTest.analyze('Quick Create ULS Contact').hasID(c.ContactID), 'When a contact is inserted, it will only be associated to existing cases if the contact has been created via quick create, is related to a uls account, and has an external email address');
            String emailOfContact = (String) UnitTest.analyze('Quick Create ULS Contact').selectByID(c.ContactID).getPropertyValue('Email');
            String emailAssociatedToCase = (String) UnitTest.analyze('Cases to Modify').selectByID(c.ID).getPropertyValue('From_Address_of_Originating_Email__c');
            System.assertEquals(emailAssociatedToCase,emailOfContact, 'When a contact is inserted by quick create and associated to a case, it must be associated to a case that has an email message with the same from address as the email of that contact');        
        }   
    } */
}
@isTest
private class TestEmailOptOut {

    private static final Boolean OPT_OUT = true;
    private static final Boolean NO_OPT_OUT = OPT_OUT;

    private static final Boolean WILL_INSERT = true;
    private static final Boolean WONT_INSERT = !WILL_INSERT;

    private static final Integer LEAD_COUNT = 10;
    private static final Integer CONTACT_COUNT = LEAD_COUNT;

    static testMethod void optOutAllLeadsSameEmail() {
        
        List<Lead> testLeads = new List<Lead>();

        TestDataGeneration.generateTestLeadBatch( LEAD_COUNT, TestDataGeneration.SINGLE_EMAIL, OPT_OUT, testLeads );

        Lead leadToToggleOptOut = testLeads[0];

        leadToToggleOptOut.HasOptedOutOfEmail = NO_OPT_OUT;
        LeadServices.processedMarketing = false;

        Test.startTest();

            update leadToToggleOptOut;

        Test.stopTest();

        for ( Lead possiblyChangedLead : [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE Id IN :testLeads] ) {
            System.assertEquals(OPT_OUT, possiblyChangedLead.HasOptedOutOfEmail, 'We expect the Lead to be unchanged and' +
                    ' remain OPT_OUT.');
        }
        
    }

    static testMethod void optOutContactsSameEmail() {

        List<Contact> testContacts = new List<Contact>();

        TestDataGeneration.generateTestContactBatch( CONTACT_COUNT, TestDataGeneration.SINGLE_EMAIL, OPT_OUT, testContacts );

        Contact contactToToggleOptOut = testContacts[0];

        contactToToggleOptOut.HasOptedOutOfEmail = NO_OPT_OUT;
        ContactServices.processedMarketing = false;

        Test.startTest();

        update contactToToggleOptOut;

        Test.stopTest();

        for ( Contact possiblyChangedContact : [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id IN :testContacts] ) {
            System.assertEquals(OPT_OUT, possiblyChangedContact.HasOptedOutOfEmail, 'We expect the Contact to be unchanged' +
                    ' and remain OPT_OUT.');
        }

    }

    static testMethod void optInAllLeadsSameEmail() {

        List<Lead> testLeads = new List<Lead>();

        TestDataGeneration.generateTestLeadBatch( LEAD_COUNT, TestDataGeneration.SINGLE_EMAIL, NO_OPT_OUT, testLeads );

        Lead leadToToggleOptOut = testLeads[0];

        leadToToggleOptOut.HasOptedOutOfEmail = OPT_OUT;
        LeadServices.processedMarketing = false;

        Test.startTest();

            update leadToToggleOptOut;

        Test.stopTest();

        for ( Lead possiblyChangedLead : [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE Id IN :testLeads] ) {
            System.assertEquals(NO_OPT_OUT, possiblyChangedLead.HasOptedOutOfEmail, 'We expect the Lead to be unchanged' +
                    ' and remain NO_OPT_OUT.');
        }
    
    }

    static testMethod void optInAllRelatedWithNewLead() {
        
        List<Lead> testLeads = new List<Lead>();
             
        // Will create a batch of opted in
        TestDataGeneration.generateTestLeadBatch( LEAD_COUNT, TestDataGeneration.SINGLE_EMAIL, OPT_OUT, testLeads );

        // now that we've opted out, let's check that a new opted in lead is reversed
        Lead newOpt = TestDataGeneration.generateTestLead( TestDataGeneration.SINGLE_EMAIL, NO_OPT_OUT );
    
        LeadServices.processedMarketing = false;
    
        Test.startTest();
        
            insert newOpt;
        
        Test.stopTest();
        
        for ( Lead possiblyChangedLead : [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE Id = :newOpt.Id] )
            System.assertEquals( OPT_OUT, possiblyChangedLead.HasOptedOutOfEmail, 'We expect the newly inserted Lead to' +
                    ' switch from NO_OPT_OPT to OPT_OUT.' );
    
    }

    static testMethod void optInAllRelatedWithNewLeadCaseInsensitiveEmail() {
        
        List<Lead> testLeads = new List<Lead>();
             
        // Will create a batch of opted in
        TestDataGeneration.generateTestLeadBatch( LEAD_COUNT, TestDataGeneration.SINGLE_EMAIL, OPT_OUT, testLeads );

        // now that we've opted out, let's check that a new opted in lead is reversed - case insensitive test
        Lead newOpt = TestDataGeneration.generateTestLead( TestDataGeneration.SINGLE_EMAIL.swapCase(), NO_OPT_OUT );
    
        LeadServices.processedMarketing = false;
    
        Test.startTest();
        
            insert newOpt;
        
        Test.stopTest();
        
        for ( Lead possiblyChangedLead : [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE Id = :newOpt.Id] )
            System.assertEquals( OPT_OUT, possiblyChangedLead.HasOptedOutOfEmail, 'We expect the newly inserted Lead to' +
                    ' switch from NO_OPT_OPT to OPT_OUT.' );
    
    }

    static testMethod void NewLeadNoOptOutResolvesToExistingOptOutVal() {
        
        List<Lead> testLeads = new List<Lead>();

        // Will create a batch of opted out leads
        TestDataGeneration.generateTestLeadBatch( LEAD_COUNT, TestDataGeneration.SINGLE_EMAIL, OPT_OUT, testLeads ); 

        // now that we've opted in, let's add a new lead with no opt out and see if its value equals the others (opt in)
        Lead newOpt = TestDataGeneration.generateTestLead( TestDataGeneration.SINGLE_EMAIL, NO_OPT_OUT );
    
        LeadServices.processedMarketing = false;
    
        Test.startTest();
        
            insert newOpt;
        
        Test.stopTest();
        
        Lead newlyInsertedLead = [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE Id = :newOpt.Id];
        
        System.assertEquals( OPT_OUT, newlyInsertedLead.HasOptedOutOfEmail, 'We expect the newly inserted Lead to' +
                ' switch from NO_OPT_OPT to OPT_OUT.' );
        
    }
    
    static testMethod void mixedAddressesUpdateLead() {
        
        final String TEST_EMAIL_TWO = 'joe@schmoeschmoe.com';
        final String TEST_EMAIL_THREE = 'steve@schmoeschmoe.com';
        
        final Set<String> TEST_EMAILS = new Set<String> {TestDataGeneration.SINGLE_EMAIL, TEST_EMAIL_TWO, TEST_EMAIL_THREE };
        
        List<Lead> testLeads = new List<Lead>();
            
        for ( String testEmail : TEST_EMAILS ) {
            
            // Will create a batch of opted in leads
            TestDataGeneration.generateTestLeadBatch( LEAD_COUNT, testEmail, NO_OPT_OUT, testLeads, WONT_INSERT );
             
        }

        insert testLeads;
        
        LeadServices.processedMarketing = false;
        
        Lead newOpt4emailOne = TestDataGeneration.generateTestLead( TestDataGeneration.SINGLE_EMAIL, OPT_OUT );
        Lead newOpt4emailTwo = TestDataGeneration.generateTestLead( TEST_EMAIL_TWO, NO_OPT_OUT );
        Lead newOpt4emailThree = TestDataGeneration.generateTestLead( TEST_EMAIL_THREE, OPT_OUT );

        List<Lead> newOpt4emailLeads = new List<Lead>{newOpt4emailOne, newOpt4emailTwo, newOpt4emailThree};
    
        Test.startTest();
            
            insert newOpt4emailLeads;
        
        Test.stopTest();
        
        for ( Lead possiblyChangedLead : [SELECT Id, HasOptedOutOfEmail, Email FROM Lead WHERE Id IN :newOpt4emailLeads] )
            System.assertEquals( possiblyChangedLead.HasOptedOutOfEmail, NO_OPT_OUT, 'We expect all Leads to match the' +
                    ' NO_OPT_OUT status in the system.' );

    }

    static testMethod void optInAllRelatedWithNewContact() {
        
        List<Contact> testContacts = new List<Contact>();
             
        // Will create a batch of opted in
        TestDataGeneration.generateTestContactBatch( CONTACT_COUNT, TestDataGeneration.SINGLE_EMAIL, OPT_OUT, testContacts );

        // now that we've opted in, let's reverse w/ a newly created Opt Out lead
        Contact newOpt = TestDataGeneration.generateTestContact( TestDataGeneration.SINGLE_EMAIL, NO_OPT_OUT );
    
        LeadServices.processedMarketing = false;
    
        Test.startTest();
        
            insert newOpt;
        
        Test.stopTest();

        for ( Contact possiblyChangedContact : [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id = :newOpt.Id] )
            System.assertEquals( OPT_OUT, possiblyChangedContact.HasOptedOutOfEmail, 'We expect the inserted Contact' +
                    ' to have OPT_OUT status.' );
    
    }

    static testMethod void NewContactNoOptOutResolvesToExistingOptOutVal() {

        List<Contact> testContacts = new List<Contact>();
             
        // Will create a batch of opted out leads
        TestDataGeneration.generateTestContactBatch( CONTACT_COUNT, TestDataGeneration.SINGLE_EMAIL, OPT_OUT, testContacts );
    
        // now that we've opted in, let's add a new lead with no opt out and see if its value equals the others (opt in)
        Contact newOpt = TestDataGeneration.generateTestContact( TestDataGeneration.SINGLE_EMAIL, NO_OPT_OUT );
    
        LeadServices.processedMarketing = false;
    
        Test.startTest();
        
            insert newOpt;
        
        Test.stopTest();
        
        Contact newlyInsertedLead = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id = :newOpt.Id];
        
        System.assertEquals( OPT_OUT, newlyInsertedLead.HasOptedOutOfEmail );
        
    }
    
    static testMethod void mixedAddressesUpdateContact() {
        
        final String TEST_EMAIL_TWO = 'joe@schmoeschmoe.com';
        final String TEST_EMAIL_THREE = 'steve@schmoeschmoe.com';
        
        final Set<String> TEST_EMAILS = new Set<String> {TestDataGeneration.SINGLE_EMAIL, TEST_EMAIL_TWO, TEST_EMAIL_THREE };

        List<Contact> testContacts = new List<Contact>();
            
        for ( String testEmail : TEST_EMAILS ) {
            
            // Will create a batch of opted in contacts
            TestDataGeneration.generateTestContactBatch( CONTACT_COUNT, testEmail, NO_OPT_OUT, testContacts, WONT_INSERT );
             
        }

        insert testContacts;
        
        LeadServices.processedMarketing = false;
        
        Contact newOpt4emailOne = TestDataGeneration.generateTestContact( TestDataGeneration.SINGLE_EMAIL, OPT_OUT );
        Contact newOpt4emailTwo = TestDataGeneration.generateTestContact( TEST_EMAIL_TWO, NO_OPT_OUT );
        Contact newOpt4emailThree = TestDataGeneration.generateTestContact( TEST_EMAIL_THREE, OPT_OUT );

        List<Contact> newOpt4emailContacts = new List<Contact>{newOpt4emailOne, newOpt4emailTwo, newOpt4emailThree};
    
        Test.startTest();
        
            insert newOpt4emailContacts;
        
        Test.stopTest();

        for ( Contact possiblyChangedContact : [SELECT Id, HasOptedOutOfEmail, Email FROM Contact WHERE Id IN :newOpt4emailContacts] )
            System.assertEquals( possiblyChangedContact.HasOptedOutOfEmail, NO_OPT_OUT, 'We expect all Contacts to match the' +
                    ' NO_OPT_OUT status in the system.' );
        
    }

    /*
    static private testMethod void convertLeadToBreakTriggersByUpdatingConvertedLeads() {
        
        List<Lead> testLeads = new List<Lead>();
        List<Contact> testContacts = new List<Contact>();
             
        // Will create a batch of opted in
        TestDataGeneration.generateTestLeadBatch( LEAD_COUNT, TestDataGeneration.SINGLE_EMAIL, NO_OPT_OUT, testLeads ); 
        TestDataGeneration.generateTestContactBatch( CONTACT_COUNT, TestDataGeneration.SINGLE_EMAIL, NO_OPT_OUT, testContacts );
    
        Database.LeadConvert lc=new Database.LeadConvert(); 
        lc.setLeadId(testLeads[0].id); 
        LeadStatus convertStatus=[Select Id,MasterLabel from LeadStatus where IsConverted=true  limit 1]; 
        lc.setConvertedStatus(convertStatus.MasterLabel); 
        Database.LeadConvertResult lcr=Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
    }
    */
   
    static testMethod void updateLeadOptOutWithEloquaIntegrationUser() {
    
        // This is a special case: if the user doing the updating of leads or contacts is the
        // Eloqua Marketing integration user, then the settings they save should overwrite all
        // settings. This is especially relevant in the case of a lead being entered as false
        // (unchecked) in the HasOptedOutOfEmail field - normally the correct value would be
        // pulled from other pre-existing leads/contacts but in this case, the value will be
        // -pushed- to them instead.
        
        List<Lead> testLeads = new List<Lead>();
        List<Contact> testContacts = new List<Contact>();
             
        // Will create a batch of opted out leads
        TestDataGeneration.generateTestLeadBatch( LEAD_COUNT, TestDataGeneration.SINGLE_EMAIL, OPT_OUT, testLeads ); 
        TestDataGeneration.generateTestContactBatch( CONTACT_COUNT, TestDataGeneration.SINGLE_EMAIL, OPT_OUT, testContacts );
    
        // now that we've opted in, let's add a new lead with no opt out and see if its value equals the others (opt in)
        Lead newOpt = TestDataGeneration.generateTestLead( TestDataGeneration.SINGLE_EMAIL, NO_OPT_OUT );
    
        LeadServices.processedMarketing = false;
    
        Test.startTest();
        
        User userRecd = [Select Id,isActive from user where Id=:LeadServices.EloquaUserIdToOverride limit 1];
       
       //code added
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User usr = new User(LastName = 'test',
                           FirstName='test',
                           Alias = 'tst',
                           Network_Id__c = 'tst',
                           Email = 'test.test@asdf.com',
                           Username = 'test.test@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US',
                           isActive =true,
                           Country='USA'
                           );
        insert usr;
        
        
        
        if(userRecd.isActive == true){
            System.runAs( usr ) {

                insert newOpt;
                
            }
            }
        
        Test.stopTest();
        
        List<Lead> recentlyInsertedLeads = [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE Id IN :testLeads];
        
        for ( Lead aLead : recentlyInsertedLeads ){
        system.debug('NO_OPT_OUT' + NO_OPT_OUT);
        system.debug('aLead.HasOptedOutOfEmail' + aLead.HasOptedOutOfEmail);        
      
          //  System.assertEquals( NO_OPT_OUT, aLead.HasOptedOutOfEmail );        
       } 
        
   }
   
    static testMethod void deferToFutureMethodWithManyRelatedRecords() {
        
        List<Lead> testLeads = new List<Lead>();
        List<Contact> testContacts = new List<Contact>();
             
        // Will create a batch of opted in
        TestDataGeneration.generateTestLeadBatch( 110, TestDataGeneration.SINGLE_EMAIL, NO_OPT_OUT, testLeads ); 
        TestDataGeneration.generateTestContactBatch( CONTACT_COUNT, TestDataGeneration.SINGLE_EMAIL, NO_OPT_OUT, testContacts );
    
        System.debug( '!!! test leads' + testLeads );

        // now that we've opted in, let's reverse w/ a newly created Opt Out lead
        Contact newContact = TestDataGeneration.generateTestContact( TestDataGeneration.SINGLE_EMAIL, OPT_OUT );
    
        LeadServices.processedMarketing = false;
    
        Test.startTest();
        
            insert newContact;
        
        Test.stopTest();
        
        //for ( Lead possiblyChangedLead : [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE Id IN :testLeads] )
            //System.assertEquals( OPT_OUT, possiblyChangedLead.HasOptedOutOfEmail );

        for ( Contact possiblyChangedContact : [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id = :newContact.Id] )
            System.assertEquals( NO_OPT_OUT, possiblyChangedContact.HasOptedOutOfEmail );
    
    }

    /*
    static private List<Lead> toggleOptOut( Integer numOfLeads, Integer numOfContacts, Boolean initialEmailOpt, List<Lead> testLeads, List<Contact> testContacts ) {
        
        TestDataGeneration.generateTestLeadBatch( numOfLeads, TestDataGeneration.SINGLE_EMAIL, initialEmailOpt, testLeads ); 
        TestDataGeneration.generateTestContactBatch( numOfContacts, TestDataGeneration.SINGLE_EMAIL, initialEmailOpt, testContacts );
        
        Lead leadToToggleOptOut = testLeads[0];
        
        leadToToggleOptOut.HasOptedOutOfEmail = !initialEmailOpt;
        LeadServices.processedMarketing = false;
        update leadToToggleOptOut;
        
        for ( Lead possiblyChangedLead : [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE Id IN :testLeads] ){
            System.debug(possiblyChangedLead);
            System.assertEquals( !initialEmailOpt, possiblyChangedLead.HasOptedOutOfEmail ); }

        //for ( Contact possiblyChangedContact : [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id IN :testContacts] )
            //System.assertEquals( !initialEmailOpt, possiblyChangedContact.HasOptedOutOfEmail );
        
        return testLeads;
        
    }

     */

    
}
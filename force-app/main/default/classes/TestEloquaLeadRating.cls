@isTest
private class TestEloquaLeadRating {
/*
	private static final String TEST_OLD_ELOQUA_RATING = 'A1';
	private static final String TEST_NEW_ELOQUA_RATING = 'A2';

	private static final Boolean WILL_INSERT = true;
	private static final Boolean WONT_INSERT = !WILL_INSERT;

	private static final String SINGLE_EMAIL = 'bob@smith.com';

	private static final Integer LEAD_COUNT = 10;
	private static final Integer CONTACT_COUNT = LEAD_COUNT;

    static testMethod void updateLeadRating() {
    	
 		List<Lead> testLeads = new List<Lead>();
 		List<Contact> testContacts = new List<Contact>();
		
		for( Integer i = 0; i < LEAD_COUNT; i++ )
			testLeads.add( TestDataGeneration.generateTestLead( SINGLE_EMAIL, TEST_OLD_ELOQUA_RATING ) );
     
		for( Integer i = 0; i < CONTACT_COUNT; i++ )
			testContacts.add( TestDataGeneration.generateTestContact( SINGLE_EMAIL, TEST_OLD_ELOQUA_RATING ) );

    	insert testLeads;		
    	insert testContacts;		
		
		Lead leadToUpdateRatingOn = testLeads[0];
		
		leadToUpdateRatingOn.Eloqua_Lead_Rating__c = TEST_NEW_ELOQUA_RATING;
		
		LeadServices.processedMarketing = false;
		
		Test.startTest();
		
			update leadToUpdateRatingOn;

		Test.stopTest();
		
		for ( Lead possiblyChangedLead : [SELECT Id, Eloqua_Lead_Rating__c FROM Lead WHERE Id IN :testLeads] )
			System.assertEquals( TEST_NEW_ELOQUA_RATING, possiblyChangedLead.Eloqua_Lead_Rating__c );

		for ( Contact possiblyChangedContact : [SELECT Id, Eloqua_Lead_Rating__c FROM Contact WHERE Id IN :testContacts] )
			System.assertEquals( TEST_NEW_ELOQUA_RATING, possiblyChangedContact.Eloqua_Lead_Rating__c );
    	
    }

    static testMethod void updateContactRating() {
    	
 		List<Lead> testLeads = new List<Lead>();
 		List<Contact> testContacts = new List<Contact>();
		
		for( Integer i = 0; i < LEAD_COUNT; i++ )
			testLeads.add( TestDataGeneration.generateTestLead( SINGLE_EMAIL, TEST_OLD_ELOQUA_RATING ) );
     
		for( Integer i = 0; i < CONTACT_COUNT; i++ )
			testContacts.add( TestDataGeneration.generateTestContact( SINGLE_EMAIL, TEST_OLD_ELOQUA_RATING ) );

    	insert testLeads;		
    	insert testContacts;		
		
		Contact contactToUpdateRatingOn = testContacts[0];
		
		contactToUpdateRatingOn.Eloqua_Lead_Rating__c = TEST_NEW_ELOQUA_RATING;
		
		LeadServices.processedMarketing = false;
		
		Test.startTest();
		
			update contactToUpdateRatingOn;

		Test.stopTest();
		
		for ( Lead possiblyChangedLead : [SELECT Id, Eloqua_Lead_Rating__c FROM Lead WHERE Id IN :testLeads] )
			System.assertEquals( TEST_NEW_ELOQUA_RATING, possiblyChangedLead.Eloqua_Lead_Rating__c );

		for ( Contact possiblyChangedContact : [SELECT Id, Eloqua_Lead_Rating__c FROM Contact WHERE Id IN :testContacts] )
			System.assertEquals( TEST_NEW_ELOQUA_RATING, possiblyChangedContact.Eloqua_Lead_Rating__c );
    	
    }

   static testMethod void deferToFutureMethodWithManyRelatedRecords() {
        
 		List<Lead> testLeads = new List<Lead>();
 		List<Contact> testContacts = new List<Contact>();
		
		for( Integer i = 0; i < 110; i++ )
			testLeads.add( TestDataGeneration.generateTestLead( SINGLE_EMAIL, TEST_OLD_ELOQUA_RATING ) );
     
		for( Integer i = 0; i < CONTACT_COUNT; i++ )
			testContacts.add( TestDataGeneration.generateTestContact( SINGLE_EMAIL, TEST_OLD_ELOQUA_RATING ) );

    	insert testLeads;		
    	insert testContacts;
    
    	// now that we've opted in, let's reverse w/ a newly created Opt Out lead
    	Contact newlyChangedContact = testContacts[0];
    	
    	newlyChangedContact.Eloqua_Lead_Rating__c = TEST_NEW_ELOQUA_RATING;
    
    	LeadServices.processedMarketing = false;
    
    	Test.startTest();
    	
    		update newlyChangedContact;
    	
    	Test.stopTest();
		for ( Lead possiblyChangedLead : [SELECT Id, Eloqua_Lead_Rating__c FROM Lead WHERE Id IN :testLeads] )
			System.assertEquals( TEST_NEW_ELOQUA_RATING, possiblyChangedLead.Eloqua_Lead_Rating__c );

		for ( Contact possiblyChangedContact : [SELECT Id, Eloqua_Lead_Rating__c FROM Contact WHERE Id IN :testContacts] )
			System.assertEquals( TEST_NEW_ELOQUA_RATING, possiblyChangedContact.Eloqua_Lead_Rating__c );	
    
    }
 */
}
@isTest
private class TestLeadAssignmentRange {

    static testMethod void assignmentRangeTest() {
    	
    	Id marketingUserProfileId = [ Select Id, Name From Profile WHERE Name = 'Marketing User' ][0].Id;
    	
		User testUser = new User( FirstName='Testttt', LastName='Testtttt', UserName='test11@unisourcelink.com', Email='test11@unisourcelink.com', Alias='tester11',
								LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', CommunityNickname='test11', Network_Id__c = 'tester11',
								TimeZoneSidKey='America/New_York', Country = 'USA', profileId = marketingUserProfileId );
    	insert testUser;
    	
    	List<leadAssignmentRange__c> existingAssignmentSettings = leadAssignmentRange__c.getAll().values();
    	delete existingAssignmentSettings;
    	
    	leadAssignmentRange__c testAssignmentRange = new leadAssignmentRange__c( Name = 'Some test range', Lower_Bound__c = 1, Upper_Bound__c = 25, Assignee_Id__c = testUser.Id );
    	insert testAssignmentRange;
    	
		Lead testLead = new Lead( 	Status = '1-Identify', 
									LeadSource = '', 
									LastName = 'Smith', 
									Department__c = 'Marketing', 
									CurrencyIsoCode = 'USD', 
									Company = 'Some Company' );
		
		testLead.Employee_Range__c = '1 - 25';
        
        SundogLeadOverrideConfig leadOverride = new SundogLeadOverrideConfig();
		Boolean assignmentSuccess;
		
        Test.startTest();
        
			assignmentSuccess = leadOverride.assignLead( testLead );
        
        Test.stopTest();
        
        System.assertEquals( testLead.OwnerId, testUser.Id );
        
    }
    
    /*
    
    Currently being addressed in solving the problem of trigger ordering
    
    static testMethod void ensureEloquaAssignment() {
    	
		Lead testLead = new Lead( 	Status = '1-Identify', 
									LeadSource = '', 
									LastName = 'Smith', 
									Department__c = 'Marketing', 
									CurrencyIsoCode = 'USD', 
									Company = 'Some Company' );
		
        SundogLeadOverrideConfig leadOverride = new SundogLeadOverrideConfig();
		Boolean assignmentSuccess;
		
        Test.startTest();
        
			insert testLead;
        
        Test.stopTest();
        
        Lead resolvedLead = [ SELECT sundog_deprm2__Use_Automatic_Lead_Assignment__c FROM Lead WHERE Id = :testLead.Id ];
        
        //Todo: also populate sundog records and check for appropriate assignment
        
        System.assertEquals( true , resolvedLead.sundog_deprm2__Use_Automatic_Lead_Assignment__c );   	
    	
    	update testLead;
    	
        Lead doublyResolvedLead = [ SELECT sundog_deprm2__Use_Automatic_Lead_Assignment__c FROM Lead WHERE Id = :testLead.Id ];

        System.assertEquals( false , doublyResolvedLead.sundog_deprm2__Use_Automatic_Lead_Assignment__c );   	

    }
    */
    
}
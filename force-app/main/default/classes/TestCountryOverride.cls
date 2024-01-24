@isTest
private class TestCountryOverride {

	/*
	private static final String EXPECTED_COUNTRY = 'United States';
	private static final Integer TEST_LEAD_COUNT = 3;

    static testMethod void testCountryOverride() {

		//Create some custom settings
		USA_Aliases__c testAlias = new USA_Aliases__c( Name = EXPECTED_COUNTRY, Is_Primary_Alias__c = true);
		USA_Aliases__c testAlias2 = new USA_Aliases__c( Name = 'USA', Is_Primary_Alias__c = false);
		USA_Aliases__c testAlias3 = new USA_Aliases__c( Name = 'US', Is_Primary_Alias__c = false); 
		USA_Aliases__c testAlias4 = new USA_Aliases__c( Name = 'America', Is_Primary_Alias__c = false);
		
		insert new List<USA_Aliases__c>{ testAlias, testAlias2, testAlias3, testAlias4 };
		
		List<Lead> testLeads = new List<Lead>();

		// Ok test seeing as how we cannot insert Custom Settings 
		// to test more robustly.
		for ( Integer i = 0; i < TEST_LEAD_COUNT; i++ ) {
			
			Lead testLead = new Lead( 	Status = '1-Identify', 
										LeadSource = '', 
										LastName = 'Smith', 
										Department__c = 'Marketing', 
										CurrencyIsoCode = 'USD', 
										Company = 'Some Company' );
			
			testLeads.add( testLead );			
			
		}
		
		testLeads[0].State = 'GA';
		testLeads[1].State = 'Colorado';
		testLeads[2].State = 'New York';
		
		 
		Test.startTest();
		
			insert testLeads;
		
		Test.stopTest();
		
		List<Lead> resolvedLeads = [ SELECT Id, Country FROM Lead WHERE Id IN :testLeads ];
		
	    System.assertEquals( TEST_LEAD_COUNT, resolvedLeads.size(), 'The correct number of leads should be returned');
	    
		for ( Lead aLead : resolvedLeads )
			System.assertEquals( EXPECTED_COUNTRY, aLead.Country, 'The correct country should be set for each lead' );
    
    }
    */

}
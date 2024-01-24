@isTest
private class TestPSRTrigger
{
	static final Integer NUM_OF_PSRs = 4;
	static final String VERTICAL_ONE = 'Education';
	static final String VERTICAL_TWO = 'Food Service';
	static Verticals__c testVertical;

	static void setup()
	{
		testVertical = new Verticals__c( Name = VERTICAL_ONE );
		insert testVertical;
	}

	static testMethod void testPSRVerticalMajor_onInsert_VerticalSetOnHalfPSRs()
	{
		setup();

		List<Primary_Sales_Rep__c> newPSRs = TestingUtils.createPSRs( NUM_OF_PSRs, 'TestName', '10230123', false );
		for( Integer i = 0; i < NUM_OF_PSRs; i+=2 )
		{
			newPSRs[i].Vertical_Major__c = VERTICAL_ONE;
		}

		Test.startTest();

			insert newPSRs;

		Test.stopTest();

		List<Primary_Sales_Rep__c> resultPSRs = [ SELECT Id, Vertical_Major__c, Vertical_Major_Page__c FROM Primary_Sales_Rep__c WHERE Vertical_Major__c != null ];

		System.assertEquals( NUM_OF_PSRs / 2, resultPSRs.size(), 'Only PSRs with Vertical Major specified should be returned' );

		for( Primary_Sales_Rep__c aPSR : resultPSRs )
		{
			System.assertEquals( VERTICAL_ONE, aPSR.Vertical_Major__c, 'Vertical Major on returned PSR object should be equals to the Name of Vertical object' );
			System.assertEquals( testVertical.Id, aPSR.Vertical_Major_Page__c, 'Vertical Lookup on PSR object should be set to matching Vertical' );
		}
	}

	static testMethod void testPSRVerticalMajor_onInsert_VerticalSetAllPSRs_OneVerticalMatching()
	{
		setup();

		Set<String> verticalNames = new Set<String>{ VERTICAL_ONE, VERTICAL_TWO };

		List<Primary_Sales_Rep__c> newPSRs = new List<Primary_Sales_Rep__c>();
		for( Integer i = 0; i < NUM_OF_PSRs; i++ )
		{
			Primary_Sales_Rep__c aPSR = TestingUtils.createPSRs( 1, 'Test PSR'+i, 'TestNW'+i, false )[0];
			Integer residue = Math.mod( i, 2 );
			if( residue == 0 )
			{
				aPSR.Vertical_Major__c = VERTICAL_ONE;
			}
			else
			{
				aPSR.Vertical_Major__c = VERTICAL_TWO;
			}
			newPSRs.add( aPSR );
		}

		Test.startTest();

			insert newPSRs;

		Test.stopTest();

		List<Primary_Sales_Rep__c> resultPSRs = [ SELECT Id, Vertical_Major__c, Vertical_Major_Page__c FROM Primary_Sales_Rep__c ];

		System.assertEquals( NUM_OF_PSRs, resultPSRs.size(), 'All PSRs should be returned' );

		for( Primary_Sales_Rep__c aPSR : resultPSRs )
		{
			System.assert( verticalNames.contains( aPSR.Vertical_Major__c ) );
			if( aPSR.Vertical_Major__c == VERTICAL_ONE )
			{
				System.assertEquals( testVertical.Id, aPSR.Vertical_Major_Page__c, 'Vertical Lookup on PSR object should be set to matching Vertical' );
			}
			else
			{
				System.assertEquals( null, aPSR.Vertical_Major_Page__c, 'Vertical Lookup on PSR object should not be set' );
			}
		}
	}

	static testMethod void testPSRVerticalMajor_onUpdate()
	{
		final String NEW_VERTICAL = 'Education';
		final String OLD_VERTICAL = 'Food Service';

		Verticals__c testVert = new Verticals__c( Name = NEW_VERTICAL );
		insert testVert;

		List<Primary_Sales_Rep__c> testPSRs = new List<Primary_Sales_Rep__c>();
		for( Integer i = 0; i < NUM_OF_PSRs; i++ )
		{
			Primary_Sales_Rep__c aPSR = TestingUtils.createPSRs( 1, 'Test PSR'+i, 'TestNW'+i, false )[0];
			aPSR.Vertical_Major__c = OLD_VERTICAL;
			testPSRs.add( aPSR );
		}
		insert testPSRs;

		for( Integer i = 0; i < NUM_OF_PSRs; i+=2 )
		{
			testPSRs[i].Vertical_Major__c = NEW_VERTICAL;
		}

		Test.startTest();

			update testPSRs;

		Test.stopTest();

		List<Primary_Sales_Rep__c> resultPSRs = [ SELECT Id, Vertical_Major__c, Vertical_Major_Page__c FROM Primary_Sales_Rep__c ];

		System.assertEquals( NUM_OF_PSRs, resultPSRs.size(), 'All PSRs should be returned' );

		for( Primary_Sales_Rep__c aPSR : resultPSRs )
		{
			if( aPSR.Vertical_Major__c == NEW_VERTICAL )
			{
				System.assertEquals( testVert.Id, aPSR.Vertical_Major_Page__c, 'Vertical Lookup on PSR object should be set to matching Vertical' );
			}
			else
			{
				System.assertEquals( OLD_VERTICAL, aPSR.Vertical_Major__c, 'Vertical Name should not be updated to new value' );
				System.assertEquals( null, aPSR.Vertical_Major_Page__c, 'Vertical Lookup on PSR object should not be set' );
			}
		}
	}

	static testMethod void testPSRVerticalMinor_onInsert_VerticalSetOnHalfPSRs()
	{
		setup();

		List<Primary_Sales_Rep__c> newPSRs = TestingUtils.createPSRs( NUM_OF_PSRs, 'TestName', '10230123', false );
		for( Integer i = 0; i < NUM_OF_PSRs; i+=2 )
		{
			newPSRs[i].Vertical_Minor__c = VERTICAL_ONE;
		}

		Test.startTest();

			insert newPSRs;

		Test.stopTest();

		List<Primary_Sales_Rep__c> resultPSRs = [ SELECT Id, Vertical_Minor__c, Vertical_Minor_Page__c FROM Primary_Sales_Rep__c WHERE Vertical_Minor__c != null ];

		System.assertEquals( NUM_OF_PSRs / 2, resultPSRs.size(), 'Only PSRs with Vertical Minor specified should be returned' );

		for( Primary_Sales_Rep__c aPSR : resultPSRs )
		{
			System.assertEquals( VERTICAL_ONE, aPSR.Vertical_Minor__c, 'Vertical Minor on returned PSR object should be equals to the Name of Vertical object' );
			System.assertEquals( testVertical.Id, aPSR.Vertical_Minor_Page__c, 'Vertical Lookup on PSR object should be set to matching Vertical' );
		}
	}

	static testMethod void testPSRVerticalMinor_onInsert_VerticalSetAllPSRs_OneVerticalMatching()
	{
		setup();

		Set<String> verticalNames = new Set<String>{ VERTICAL_ONE, VERTICAL_TWO };

		List<Primary_Sales_Rep__c> newPSRs = new List<Primary_Sales_Rep__c>();
		for( Integer i = 0; i < NUM_OF_PSRs; i++ )
		{
			Primary_Sales_Rep__c aPSR = TestingUtils.createPSRs( 1, 'Test PSR'+i, 'TestNW'+i, false )[0];
			Integer residue = Math.mod( i, 2 );
			if( residue == 0 )
			{
				aPSR.Vertical_Minor__c = VERTICAL_ONE;
			}
			else
			{
				aPSR.Vertical_Minor__c = VERTICAL_TWO;
			}
			newPSRs.add( aPSR );
		}

		Test.startTest();

			insert newPSRs;

		Test.stopTest();

		List<Primary_Sales_Rep__c> resultPSRs = [ SELECT Id, Vertical_Minor__c, Vertical_Minor_Page__c FROM Primary_Sales_Rep__c ];

		System.assertEquals( NUM_OF_PSRs, resultPSRs.size(), 'All PSRs should be returned' );

		for( Primary_Sales_Rep__c aPSR : resultPSRs )
		{
			System.assert( verticalNames.contains( aPSR.Vertical_Minor__c ) );
			if( aPSR.Vertical_Minor__c == VERTICAL_ONE )
			{
				System.assertEquals( testVertical.Id, aPSR.Vertical_Minor_Page__c, 'Vertical Lookup on PSR object should be set to matching Vertical' );
			}
			else
			{
				System.assertEquals( null, aPSR.Vertical_Minor_Page__c, 'Vertical Lookup on PSR object should not be set' );
			}
		}
	}

	static testMethod void testPSRVerticalMinor_onUpdate()
	{
		final String NEW_VERTICAL = 'Education';
		final String OLD_VERTICAL = 'Food Service';

		Verticals__c testVert = new Verticals__c( Name = NEW_VERTICAL );
		insert testVert;

		List<Primary_Sales_Rep__c> testPSRs = new List<Primary_Sales_Rep__c>();
		for( Integer i = 0; i < NUM_OF_PSRs; i++ )
		{
			Primary_Sales_Rep__c aPSR = TestingUtils.createPSRs( 1, 'Test PSR'+i, 'TestNW'+i, false )[0];
			aPSR.Vertical_Minor__c = OLD_VERTICAL;
			testPSRs.add( aPSR );
		}
		insert testPSRs;

		for( Integer i = 0; i < NUM_OF_PSRs; i+=2 )
		{
			testPSRs[i].Vertical_Minor__c = NEW_VERTICAL;
		}

		Test.startTest();

			update testPSRs;

		Test.stopTest();

		List<Primary_Sales_Rep__c> resultPSRs = [ SELECT Id, Vertical_Minor__c, Vertical_Minor_Page__c FROM Primary_Sales_Rep__c ];

		System.assertEquals( NUM_OF_PSRs, resultPSRs.size(), 'All PSRs should be returned' );

		for( Primary_Sales_Rep__c aPSR : resultPSRs )
		{
			if( aPSR.Vertical_Minor__c == NEW_VERTICAL )
			{
				System.assertEquals( testVert.Id, aPSR.Vertical_Minor_Page__c, 'Vertical Lookup on PSR object should be set to matching Vertical' );
			}
			else
			{
				System.assertEquals( OLD_VERTICAL, aPSR.Vertical_Minor__c, 'Vertical Name should not be updated to new value' );
				System.assertEquals( null, aPSR.Vertical_Minor_Page__c, 'Vertical Lookup on PSR object should not be set' );
			}
		}
	}
}
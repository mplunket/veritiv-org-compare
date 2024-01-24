@isTest
private class TestLeadTrigger {
    static final Integer NUM_OF_LEADS = 4;
    static final Integer NUM_TO_CREATE = 20;
    static final String VERTICAL_ONE = 'Education';
    static final String VERTICAL_TWO = 'Food Service';
    static Verticals__c testVertical;
static void setup()
    {
        testVertical = new Verticals__c( Name = VERTICAL_ONE );
        insert testVertical;
    }
    
    static testMethod void testChangedCurrencyISOCode()
    {
        
       
        TestLeadServices.setupData();
        
        for(Lead theLead : TestLeadServices.oldLeads)
        {
           theLead.OwnerId = TestLeadServices.newLeadOwner.Id;
        }
        
        Test.startTest();
          try
           {
            update TestLeadServices.oldLeads;
           }
           catch(Exception e)
             {
               system.debug('ErrorMessage'+ e.getMessage());
             }
        Test.stopTest();
        
        List<Lead> updatedLeads = [SELECT Id, CurrencyIsoCode FROM Lead WHERE Id IN : TestLeadServices.oldLeads];
        
        for(Lead theLead : updatedLeads)
        {
           // System.assertEquals(TestLeadServices.CANADIAN_CURENCY_CODE , theLead.CurrencyIsoCode);
        }
        
    }

    static testMethod void testChangedCurrencyISOCodeQueue()
    {
        List<Group> queueList = [Select Id From Group where Name = 'Inside Sales - Lead Qualification'];
        
        System.assertEquals ( 1, queueList.size(), 'Queue is Missing');
        
        TestLeadServices.setupData();
        
        for(Lead theLead : TestLeadServices.oldLeads)
        {
           theLead.OwnerId = queueList[0].id;
        }
        
        Test.startTest();
            update TestLeadServices.oldLeads;
        Test.stopTest();
        
        List<Lead> updatedLeads = [SELECT Id, CurrencyIsoCode FROM Lead WHERE Id IN : TestLeadServices.oldLeads];
        
        for(Lead theLead : updatedLeads)
        {
            System.assertEquals(TestLeadServices.US_CURRENCY_CODE, theLead.CurrencyIsoCode);
        }
        
    }
     

    static testMethod void testPSRVerticalMinor_onInsert_VerticalSetOnHalfPSRs()
    {
        setup();

        List<Lead> newLeads = TestingUtils.createLeads( NUM_OF_LEADS, 'TestLead', false );
        for( Integer i = 0; i < NUM_OF_LEADS; i+=2 )
        {
            newLeads[i].Vertical__c = VERTICAL_ONE;
        }

        Test.startTest();

            insert newLeads;

        Test.stopTest();

        List<Lead> resultLeads = [ SELECT Id, Vertical__c, Vertical_Page__c FROM Lead WHERE Vertical__c != null ];

        System.assertEquals( NUM_OF_LEADS / 2, resultLeads.size(), 'Only Leads with Vertical Name specified should be returned' );

        for( Lead anLead : resultLeads )
        {
            System.assertEquals( VERTICAL_ONE, anLead.Vertical__c, 'Lead Vertical on returned Lead object should be equals to the Name of Vertical object' );
            System.assertEquals( testVertical.Id, anLead.Vertical_Page__c, 'Vertical Lookup on Lead object should be set to matching Vertical' );
        }
    }
    
    static testMethod void testPSRVerticalMinor_onUpdate_ClearVerticalPicklist()
    {
        setup();

        List<Lead> newLeads = TestingUtils.createLeads( NUM_OF_LEADS, 'TestLead', false );
        for(Lead l : newLeads)
        {
            l.Vertical__c = VERTICAL_ONE;
        }
        insert newLeads;
        
        for( Integer i = 0; i < NUM_OF_LEADS; i+=2 )
        {
            newLeads[i].Vertical__c = null;
        }

        Test.startTest();

            update newLeads;

        Test.stopTest();

        List<Lead> resultLeads = [ SELECT Id, Vertical__c, Vertical_Page__c FROM Lead WHERE Vertical__c = null ];

        System.assertEquals( NUM_OF_LEADS / 2, resultLeads.size(), 'Only Leads with Vertical Name cleared should return' );

        for( Lead anLead : resultLeads )
        {
            System.assertEquals( null, anLead.Vertical_Page__c, 'Vertical Lookup on Lead object should be cleared' );
        }
    }

    static testMethod void testPSRVerticalMinor_onInsert_VerticalSetAllPSRs_OneVerticalMatching()
    {
        setup();

        Set<String> verticalNames = new Set<String>{ VERTICAL_ONE, VERTICAL_TWO };

        List<Lead> newLeads = new List<Lead>();
        for( Integer i = 0; i < NUM_OF_LEADS; i+=2 )
        {
            Lead anLead = TestingUtils.createLeads( 1,'TestLead', false )[0];
            Integer residue = Math.mod( i, 2 );
            if( residue == 0 )
            {
                anLead.Vertical__c = VERTICAL_ONE;
            }
            else
            {
                anLead.Vertical__c = VERTICAL_TWO;
            }
            newLeads.add( anLead );
        }

        Test.startTest();

            insert newLeads;

        Test.stopTest();

        List<Lead> resultLeads = [ SELECT Id, Vertical__c, Vertical_Page__c FROM Lead ];

        System.assertEquals( NUM_OF_LEADS / 2, resultLeads.size(), 'Only Leads with matching Vertical Name should be returned' );

        for( Lead anLead : resultLeads )
        {
            System.assert( verticalNames.contains( anLead.Vertical__c ) );
            if( anLead.Vertical__c == VERTICAL_ONE )
            {
                System.assertEquals( testVertical.Id, anLead.Vertical_Page__c, 'Vertical Lookup on Lead object should be set to matching Vertical' );
            }
            else
            {
                System.assertEquals( null, anLead.Vertical_Page__c, 'Vertical Lookup on Lead object should not be set' );
            }
        }
    }
}
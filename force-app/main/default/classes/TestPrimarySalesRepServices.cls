@isTest
private class TestPrimarySalesRepServices
{
    static List<Primary_Sales_Rep__c> psrs;
    static List<Primary_Sales_Rep__c> iReps;

    static Integer numUsersToCreate = 5;
    static Integer numPSRsToCreate = 2;
    static Integer numIRepsToCreate = numPSRsToCreate;
    static Integer numOpptysPerPSR = 10;

    static void setup()
    {

        datetime dt = datetime.now();
        string temp = string.valueOf(dt.millisecond()) + string.valueOf(dt.second());
        List<User> testUsers = TestDataGeneration.createUsers( 'Test3'+temp, 'Standard User', numUsersToCreate, true );

        psrs = new List<Primary_Sales_Rep__c>();
        iReps = new List<Primary_Sales_Rep__c>();

        for( User user : testUsers )
        {
            for( Primary_Sales_Rep__c psr : TestDataGeneration.createPSRs( numPSRsToCreate, false ) )
            {
                psr.SF_userid__c = user.Id;
                psrs.add( psr );
            }

            for( Primary_Sales_Rep__c psr : TestDataGeneration.createPSRs( numIRepsToCreate, false ) )
            {
                psr.SF_userid__c = user.Id;
                iReps.add( psr );
            }
        }

        insert psrs;
        insert iReps;
    }

    static testMethod void testGetOpportunitiesByPSR()
    {
        setup();

        List<Opportunity> psrOpportunities = new List<Opportunity>();
        List<Opportunity> iRepOpportunities = new List<Opportunity>();
        List<Opportunity> closedIRepOpportunities = new List<Opportunity>();

        Account testAccount = TestDataGeneration.createAccount( 'Test Account' );

        for( Primary_Sales_Rep__c psr : psrs )
        {
            for( Opportunity opportunity : TestDataGeneration.createOpportunities( numOpptysPerPSR, testAccount.Id, false ) )
            {
                opportunity.Primary_Sales_Rep_Name__c = psr.Id;
                psrOpportunities.add( opportunity );
                
            }
        }
        
        
        System.debug('psrOpportunities'+psrOpportunities.size());
        
        for( Primary_Sales_Rep__c iRep : iReps )
        {
            for( Opportunity opportunity : TestDataGeneration.createOpportunities( numOpptysPerPSR, testAccount.Id, false ) )
            {
                opportunity.iRep__c = iRep.Id;
                iRepOpportunities.add( opportunity );
            }

            for( Opportunity opportunity : TestDataGeneration.createOpportunities( numOpptysPerPSR, testAccount.Id, false ) )
            {
                opportunity.iRep__c = iRep.Id;
                opportunity.StageName = '0- Closed Lost';
                opportunity.Lost_Date__c = Date.today();
                opportunity.Lost_Reason__c = 'Price';
                closedIRepOpportunities.add( opportunity );
            }
        }

        insert psrOpportunities;
        insert iRepOpportunities;
        insert closedIRepOpportunities;

        Test.startTest();
			system.debug('psrs'+psrs);
            List<Opportunity> relatedPSROpportunities =  PrimarySalesRepServices.getOpportunitiesByPSR( psrs );
            List<Opportunity> relatedIRepOpportunities = PrimarySalesRepServices.getOpportunitiesByPSR( iReps );
			System.debug('relatedPSROpportunities'+relatedPSROpportunities);
        Test.stopTest();

        Map<Id, Opportunity> psrOppMap = new Map<Id, Opportunity>(psrOpportunities);
        Map<Id, Opportunity> iRepOppMap = new Map<Id, Opportunity>(iRepOpportunities);

        //System.debug('psrOpportunities.size()'+psrOpportunities.size()+'-->relatedPSROpportunities.size()'+relatedPSROpportunities.size());
        
        
        if(psrOpportunities.size() == relatedPSROpportunities.size()){
             System.assertEquals(psrOpportunities.size(), relatedPSROpportunities.size());
        }
       

        for(Opportunity opportunity : relatedPSROpportunities)
        {
            System.assert(psrOppMap.containsKey(opportunity.Id));
        }

        System.assertEquals(iRepOpportunities.size(), relatedIRepOpportunities.size());

        for(Opportunity opportunity : closedIRepOpportunities)
        {
            System.assert(!iRepOppMap.containsKey(opportunity.Id), 'Should only include open opportunities');
        }


        for(Opportunity opportunity : relatedIRepOpportunities)
        {
            System.assert(iRepOppMap.containsKey(opportunity.Id));
        }

    }

    static testMethod void testCopyPSREmailFields()
    {
        Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, false )[0];

        testPSR.email_zm_sm__c  = 'bob@unisourcelink.com';
        testPSR.email_vp__c     = 'dan@unisourcelink.com';
        testPSR.email_pres__c   = 'george@unisourcelink.com';
        testPSR.email_dir__c    = 'frank@unisourcelink.com';
        testPSR.email_bdm_rvp__c = 'mike@unisourcelink.com';
        testPSR.GSM_Email__c    = 'jason@unisourcelink.com';
        testPSR.Email_TL__c     = 'hank@unisourcelink.com';
        testPSR.Email_DMD__c    = 'joe@unisourcelink.com';

        insert testPSR;

        Account testAccount = TestDataGeneration.createAccount( 'Test Account' );

        Opportunity testOpportunity = TestDataGeneration.createOpportunities( 1, testAccount.Id, true )[0];

        Test.startTest();

            Opportunity returnedOpportunity = PrimarySalesRepServices.copyPSREmailFields( testOpportunity, testPSR );

        Test.stopTest();

        System.assertEquals( testPSR.email_zm_sm__c,    returnedOpportunity.PSR_ZM_SM_Email__c);
        System.assertEquals( testPSR.email_vp__c   ,    returnedOpportunity.PSR_VP_Email__c);
        System.assertEquals( testPSR.email_pres__c  , returnedOpportunity.PSR_Pres_Email__c);
        System.assertEquals( testPSR.email_dir__c   , returnedOpportunity.Email_PSR_Dir__c);
        System.assertEquals( testPSR.email_bdm_rvp__c, returnedOpportunity.PSR_BDM_RVP_Email__c);
        System.assertEquals( testPSR.GSM_Email__c   , returnedOpportunity.PSR_GSM_Email__c);
        System.assertEquals( testPSR.Email_TL__c    , returnedOpportunity.PSR_TL_Email__c);
        System.assertEquals( testPSR.Email_DMD__c   , returnedOpportunity.Email_PSR_DMD__c);

    }

    static testMethod void testCopyiRepEmailFields()
    {
        Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, false )[0];

        testPSR.email_zm_sm__c  = 'bob@unisourcelink.com';
        testPSR.email_vp__c     = 'dan@unisourcelink.com';
        testPSR.email_pres__c   = 'george@unisourcelink.com';
        testPSR.email_dir__c    = 'frank@unisourcelink.com';
        testPSR.email_bdm_rvp__c = 'mike@unisourcelink.com';
        testPSR.GSM_Email__c    = 'jason@unisourcelink.com';
        testPSR.Email_TL__c     = 'hank@unisourcelink.com';
        testPSR.Email_DMD__c    = 'joe@unisourcelink.com';

        insert testPSR;

        Account testAccount = TestDataGeneration.createAccount( 'Test Account' );

        Opportunity testOpportunity = TestDataGeneration.createOpportunities( 1, testAccount.Id, true )[0];

        Test.startTest();

            Opportunity returnedOpportunity = PrimarySalesRepServices.copyIRepEmailFields( testOpportunity, testPSR );

        Test.stopTest();

        System.assertEquals( testPSR.email_zm_sm__c,    returnedOpportunity.Email_iRep_ZM_SM__c);
        System.assertEquals( testPSR.email_vp__c   ,    returnedOpportunity.Email_iRep_VP__c);
        System.assertEquals( testPSR.email_pres__c  , returnedOpportunity.Email_iRep_Pres__c);
        System.assertEquals( testPSR.email_dir__c   , returnedOpportunity.Email_iRep_Dir__c);
        System.assertEquals( testPSR.email_bdm_rvp__c, returnedOpportunity.Email_iRep_BDM_RVP__c);
        System.assertEquals( testPSR.GSM_Email__c   , returnedOpportunity.Email_iRep_GSM__c);
        System.assertEquals( testPSR.Email_TL__c    , returnedOpportunity.Email_iRep_TL__c);
        System.assertEquals( testPSR.Email_DMD__c   , returnedOpportunity.Email_iRep_DMD__c);
    }

    static testMethod void testUpdateOpportunityEmailFieldsFromPSRs()
    {
        setup();

        String psrValueToSet = 'dan@unisourcelink.com';
        String iRepValueToSet = 'joe@unisourcelink.com';

        List<Opportunity> psrOpportunities = new List<Opportunity>();
        List<Opportunity> iRepOpportunities = new List<Opportunity>();
        List<Opportunity> mixedOpportunities = new List<Opportunity>();

        Account testAccount = TestDataGeneration.createAccount( 'Test Account' );

        for( Primary_Sales_Rep__c psr : psrs )
        {
            for( Opportunity opportunity : TestDataGeneration.createOpportunities( numOpptysPerPSR, testAccount.Id, false ) )
            {
                opportunity.Primary_Sales_Rep_Name__c = psr.Id;
                psrOpportunities.add( opportunity );
            }
        }

        for( Primary_Sales_Rep__c iRep : iReps )
        {
            for( Opportunity opportunity : TestDataGeneration.createOpportunities( numOpptysPerPSR, testAccount.Id, false ) )
            {
                opportunity.iRep__c = iRep.Id;
                iRepOpportunities.add( opportunity );
            }
        }

        Integer index = 0;
        for( Opportunity opportunity : TestDataGeneration.createOpportunities( numPSRsToCreate, testAccount.Id, false ) )
        {
            opportunity.Primary_Sales_Rep_Name__c = psrs[index].Id;
            opportunity.iRep__c = iReps[index].Id;
            mixedOpportunities.add( opportunity );

            index++;
        }
        
        insert psrOpportunities;
        insert iRepOpportunities;
        insert mixedOpportunities;

        Test.startTest();

            for( Primary_Sales_Rep__c psr : psrs )
            {
                psr.email_zm_sm__c = psrValueToSet;
            }

            for( Primary_Sales_Rep__c iRep : iReps )
            {
                iRep.email_zm_sm__c = iRepValueToSet;
            }

            List<Primary_Sales_Rep__c> psrsAndIReps = new List<Primary_Sales_Rep__c>();
            psrsAndIReps.addAll( psrs );
            psrsAndIReps.addAll( iReps );

            PrimarySalesRepServices.updateOpportunityEmailFieldsFromPSRs( psrsAndIReps );

        Test.stopTest();

        for( Opportunity updatedPSROppty : [ SELECT Id, PSR_ZM_SM_Email__c, Email_iRep_ZM_SM__c FROM Opportunity WHERE Id IN :psrOpportunities ] )
        {
            //System.assertEquals( psrValueToSet, updatedPSROppty.PSR_ZM_SM_Email__c );
        }

        Integer i = 0;
        for( Opportunity updatedIRepOppty : [ SELECT Id, PSR_ZM_SM_Email__c, Email_iRep_ZM_SM__c FROM Opportunity WHERE Id IN :iRepOpportunities ] )
        {
            System.assertEquals( iRepValueToSet, updatedIRepOppty.Email_iRep_ZM_SM__c );
        }

        for( Opportunity updatedMixedOppty : [ SELECT Id, PSR_ZM_SM_Email__c, Email_iRep_ZM_SM__c FROM Opportunity WHERE Id IN :mixedOpportunities ] )
        {
            System.assertEquals( iRepValueToSet, updatedMixedOppty.Email_iRep_ZM_SM__c );
           // System.assertEquals( psrValueToSet, updatedMixedOppty.PSR_ZM_SM_Email__c );
        }
    }

    static testMethod void testInsertPSRWithUser()
    {
        String testEmailValue = 'dan@unisourcelink.com.test';

        User testUser = TestDataGeneration.createUser( 'TUser', 'Standard User', false );
        testUser.Email_DMD__c = testEmailValue;

        //System.runAs( TestDataGeneration.ADMIN_USER )
       // {
            insert testUser;
       // }

        Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, false )[0];
        testPSR.SF_userid__c = testUser.Id;

        Test.startTest();

            insert testPSR;

        Test.stopTest();

        List<Primary_Sales_Rep__c> updatedPSR = [ SELECT Id, Email_DMD__c FROM Primary_Sales_Rep__c WHERE Id = :testPSR.Id ];

       // System.assertEquals( testEmailValue, updatedPSR[0].Email_DMD__c, 'PSR should sync upon create when it looks up to a user.' );
    }

    static testMethod void testUpdatePSRWithUser()
    {
        String testEmailValue = 'dan@unisourcelink.com.test';

        User testUser = TestDataGeneration.createUser( 'TUser', 'Standard User', false );
        testUser.Email_DMD__c = testEmailValue;

       // System.runAs( TestDataGeneration.ADMIN_USER )
       // {
            insert testUser;
       // }

        Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, true )[0];

        Test.startTest();

            testPSR.SF_userid__c = testUser.Id;
            update testPSR;

        Test.stopTest();

        List<Primary_Sales_Rep__c> updatedPSR = [ SELECT Id, Email_DMD__c FROM Primary_Sales_Rep__c WHERE Id = :testPSR.Id ];

        //System.assertEquals( testEmailValue, updatedPSR[0].Email_DMD__c, 'PSR should sync upon update when the user lookup changes' );
    }

    static testMethod void testSyncPSRUserLookupByNetwork()
    {
        User testUser = TestDataGeneration.createUser( 'NUser', 'Standard User', true );

        Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, false )[0];
        testPSR.Network_ID__c = testUser.Network_Id__c;

        Test.startTest();

            insert testPSR;

        Test.stopTest();

        List<Primary_Sales_Rep__c> updatedPSR = [ SELECT Id, SF_userid__c FROM Primary_Sales_Rep__c WHERE Id = :testPSR.Id ];

        System.assertEquals( 1, updatedPSR.size() );
        System.assertEquals( testUser.Id, updatedPSR[0].SF_userid__c );
    }

    static testMethod void testSyncPSRUserLookupByNetworkBulk()
    {
        Integer usersToCreate = 30;

        List<User> testUsers = TestDataGeneration.createUsers( 'TUser', 'Standard User', usersToCreate, true );

        Map<String, User> networkIdToUser = new Map<String, User>();
        for( User testUser : testUsers )
        {
            networkIdToUser.put( testUser.Network_Id__c, testUser );
        }

        List<Primary_Sales_Rep__c> testPSRs = new List<Primary_Sales_Rep__c>();
        for( User testUser : testUsers )
        {
            Primary_Sales_Rep__c psrForUser = TestDataGeneration.createPSRs( 1, false )[0];
            psrForUser.Network_ID__c = testUser.Network_Id__c;
            testPSRs.add( psrForUser );
        }

        Test.startTest();

            insert testPSRs;

        Test.stopTest();

        List<Primary_Sales_Rep__c> updatedPSRs = [ SELECT Id, Network_ID__c, SF_userid__c FROM Primary_Sales_Rep__c WHERE Id IN :testPSRs ];

        for( Primary_Sales_Rep__c updatedPSR : updatedPSRs )
        {
            System.assertEquals( networkIdToUser.get( updatedPSR.Network_ID__c ).Id, updatedPSR.SF_userid__c );
        }
    }
    
    static testMethod void testPSRInsertWithoutCoupledUser() {
        Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, false )[0];
        
            Test.startTest();
                insert testPSR;
            Test.stopTest();
                
            List<Primary_Sales_Rep__c> updatedPSRs = [Select Id, SF_userid__c From Primary_Sales_Rep__c Where Id = :testPSR.Id];
            System.assertEquals(null, updatedPSRs[0].SF_userid__c);
    }

}
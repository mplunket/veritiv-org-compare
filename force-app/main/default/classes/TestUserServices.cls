@isTest
private class TestUserServices {
    
    static testMethod void testChangeUserStatus()
    {
        User testUser;
        System.runAs( TestDataGeneration.ADMIN_USER )
        {
            testUser = TestDataGeneration.createUser( 'NUser', 'Standard User', true );
        }

        Test.startTest();

            testUser.Working_Status__c = CaseServices.RECEIVED_CASE_WHILE_OUT_STATUS;

            // updating as admin user gets around MIXED_DML exceptions
            System.runAs( TestDataGeneration.ADMIN_USER )
            {
                update testUser;
            }

        Test.stopTest();

        List<User_out_of_office__c> createdStatuses = [ SELECT Id, User__c FROM User_out_of_office__c WHERE User__c = :testUser.Id ];

        System.assertEquals( 1, createdStatuses.size(), 'An incorrect number of UserOutOfOffice objects have been created' );
        System.assertEquals( testUser.Id, createdStatuses[0].User__c, 'The UserOutOfOffice object was created for an incorrect user' );
    }

    static testMethod void testBulkChangeUserStatus()
    {
        Integer usersToCreate = 25;
        List<User> testUsers;
        System.runAs( TestDataGeneration.ADMIN_USER )
        {
            testUsers = TestDataGeneration.createUsers( 'Nuser', 'Standard User', usersToCreate, true );
        }

        Test.startTest();

            for( User user : testUsers )
            {
                user.Working_Status__c = CaseServices.RECEIVED_CASE_WHILE_OUT_STATUS;
            }

            System.runAs( TestDataGeneration.ADMIN_USER )
            {
                update testUsers;
            }

        Test.stopTest();

        List<User_out_of_office__c> createdStatuses = [ SELECT Id, User__c FROM User_out_of_office__c WHERE User__c IN :testUsers ];

        System.assertEquals( usersToCreate, createdStatuses.size(), 'The same number of statuses as users should be created' );

        // get all the user ids that the status were created for
        Set<Id> createdStatusUserIds = new Set<Id>();
        for( User_out_of_office__c status : createdStatuses )
        {
            createdStatusUserIds.add( status.User__c );
        }
        for( User user : testUsers )
        {
            System.assert( createdStatusUserIds.contains( user.Id ), 'User should have a UserOutOfOffice object created' );
        }
    }

    static testMethod void testPushUserChangesToPSR()
    {
        String testNameValue = 'John Doe';
        String testEmailValue = 'dan@unisourcelink.com.test';

        User testUser = TestDataGeneration.createUser( 'TUser', 'Standard User', true );

        Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, false )[0];
        testPSR.SF_userid__c = testUser.Id;
        insert testPSR;

        Test.startTest();

            testUser.name_dmd__c  = testNameValue;
            testUser.Email_DMD__c = testEmailValue;

            System.runAs( TestDataGeneration.ADMIN_USER )
            {
                update testUser;
            }

        Test.stopTest();

        List<Primary_Sales_Rep__c> updatedPSR = [ SELECT Id, Email_DMD__c, name_dmd__c FROM Primary_Sales_Rep__c WHERE Id = :testPSR.Id ];

        System.assertEquals( 1, updatedPSR.size() );
       // System.assertEquals( testEmailValue, updatedPSR[0].Email_DMD__c );
       // System.assertEquals( testNameValue, updatedPSR[0].name_dmd__c);
    }

    static testMethod void testPushUserChangesToPSRBulk()
    {
        String testNameValue = 'John Doe';
        String testEmailValue = 'dan@unisourcelink.com.test';
        Integer usersToCreate = 10;
        Integer psrsPerUser = 3;

        List<User> testUsers = TestDataGeneration.createUsers( 'TUser', 'Standard User', usersToCreate, true );

        List<Primary_Sales_Rep__c> testPSRs = new List<Primary_Sales_Rep__c>();

        for( User user : testUsers )
        {
            List<Primary_Sales_Rep__c> psrsForUser = TestDataGeneration.createPSRs( psrsPerUser, false );

            for( Primary_Sales_Rep__c psr : psrsForUser )
            {
                psr.SF_userid__c = user.Id;
                testPsrs.add( psr );
            }
        }
        insert testPSRs;

        Test.startTest();

            for( User user : testUsers )
            {
                user.Pres_Email__c = user.Alias + testEmailValue;
                user.name_pres__c  = user.Alias + testNameValue;
            }

            System.runAs( TestDataGeneration.ADMIN_USER )
            {
                update testUsers;
            }

        Test.stopTest();

        List<Primary_Sales_Rep__c> updatedPSRs = [ SELECT Id, email_pres__c, SF_userid__r.Pres_Email__c,
                                                         name_pres__c, SF_userid__r.name_pres__c
                                                    FROM Primary_Sales_Rep__c
                                                    WHERE SF_userid__c IN :testUsers ];

        for( Primary_Sales_Rep__c updatedPSR : updatedPSRs )
        {
           // System.assertEquals( updatedPSR.SF_userid__r.Pres_Email__c, updatedPSR.email_pres__c );
         //   System.assertEquals( updatedPSR.SF_userid__r.name_pres__c, updatedPSR.name_pres__c );
        }
    }

    static testMethod void testUserEmailsNamesHaveChanged()
    {
        List<String> fieldNames = new List<String>{ 'name_bdm_rvp__c',
                                                'name_dir__c',
                                                'name_dmd__c',
                                                'name_gsm__c',
                                                'name_pres__c',
                                                'name_team_lead__c',
                                                'name_vp__c',
                                                'name_zm_sm__c',
                                                'BDM_RVP_Email__c',
                                                'Dir_Email__c',
                                                'Email_DMD__c' ,
                                                'GSM_Email__c' ,
                                                'Pres_Email__c' ,
                                                'TL_Email__c' ,
                                                'Vice_President_Email__c',
                                                'ZM_SM_Email__c' };

        User oldUser = new User();
        User newUser = new User();

        String value = 'someValue';

        for(String field : fieldNames)
        {
            newUser.put(field, value);
            Boolean hasChanged = UserService.userEmailsNamesHaveChanged(oldUser, newUser);

            System.assert(hasChanged);

            oldUser.put(field, value);
            hasChanged = UserService.userEmailsNamesHaveChanged(oldUser, newUser);

            System.assert(!hasChanged);
        }
    }

/*
    NEED A WAY TO MAKE UPDATE FAIL

    static testMethod void testPushUserChangesToPSRFailure()
    {
        String testEmailValue = 'dan@unisourcelink.com.test';

        User testUser = TestDataGeneration.createUser( 'TUser', 'Standard User', true );

        Contact joe = TestDataGeneration.generateTestContact('joe@deleteme.com', false);
        insert joe;

        Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, false )[0];
        testPSR.SF_userid__c = testUser.Id;
        testPSR.Contact__c = joe.Id;

        insert testPSR;

        //invalidate PSR record
        delete joe;

        update testPSR;

        //reload test psr
        testPSR = [ SELECT Id, Email_DMD__c FROM Primary_Sales_Rep__c WHERE Id = :testPSR.Id ];

        Test.startTest();

            testUser.Email_DMD__c = testEmailValue;

            System.runAs( TestDataGeneration.ADMIN_USER )
            {
                update testUser;

            }

        Test.stopTest();

        //record should not have been updated
        List<Primary_Sales_Rep__c> updatedPSR = [ SELECT Id, Email_DMD__c FROM Primary_Sales_Rep__c WHERE Id = :testPSR.Id ];
        System.assertEquals(testPSR.Email_DMD__c, updatedPSR[0].Email_DMD__c);
    }*/

    static testMethod void testSyncPSRsToNewUserByNetwork()
    {
        User testUser = TestDataGeneration.createUser( 'NUser', 'Standard User', false );

        Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, false )[0];
        testPSR.Network_ID__c = testUser.Network_Id__c;
        insert testPSR;

        Test.startTest();

            insert testUser;

        Test.stopTest();

        List<Primary_Sales_Rep__c> updatedPSR = [ SELECT Id, SF_userid__c FROM Primary_Sales_Rep__c WHERE Id = :testPSR.Id ];

        System.assertEquals( 1, updatedPSR.size() );
        System.assertEquals( testUser.Id, updatedPSR[0].SF_userid__c );
    }

    static testMethod void testSyncPSRsToNewUserByNetworkBulk()
    {
        Integer usersToCreate = 30;

        List<User> testUsers = TestDataGeneration.createUsers( 'TUser', 'Standard User', usersToCreate, false );

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
        insert testPSRs;

        Test.startTest();

            insert testUsers;

        Test.stopTest();

        List<Primary_Sales_Rep__c> updatedPSRs = [ SELECT Id, Network_ID__c, SF_userid__c FROM Primary_Sales_Rep__c WHERE Id IN :testPSRs ];

        System.assertEquals( usersToCreate, updatedPSRs.size() );

        for( Primary_Sales_Rep__c updatedPSR : updatedPSRs )
        {
            System.assertEquals( networkIdToUser.get( updatedPSR.Network_ID__c ).Id, updatedPSR.SF_userid__c );
        }
    }

}
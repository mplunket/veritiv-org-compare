@isTest
private class TestShipToAccountUpdateTrigger {

    static List<Account> testAccounts;
    static List<Ship_To__c> testShipTos;
    static List<Ship_To__c> testShipTosSubset;
    static Primary_Sales_Rep__c testIRep1;
    static Primary_Sales_Rep__c testIRep2;

    static void setup( Integer accountsToCreate, Integer shipTosPerAccount )
    {
        testAccounts = TestDataGeneration.createAccounts( 'Test Account', accountsToCreate );
        insert testAccounts;

        List<Primary_Sales_Rep__c> testIReps = TestDataGeneration.createPSRs( 2, false );
        for( Primary_Sales_Rep__c testIRep : testIReps )
        {
            testIRep.iRep_Indicator__c = 'Y';
        }
        insert testIReps;
        testIRep1 = testIReps[0];
        testIRep2 = testIReps[1];

        testShipTos = new List<Ship_To__c>();
        testShipTosSubset = new List<Ship_To__c>();
        for( Account testAccount : testAccounts )
        {
            List<Ship_To__c> shipTos = TestDataGeneration.createShipTos( shipTosPerAccount, testAccount.Name + ' ShipTo', testAccount.Id, false );
            // set all the shiptos to have the same irep per account
            for( Ship_To__c shipTo : shipTos )
            {
                shipTo.iRep__c = testIRep1.Id;
                shipTo.iRep_Plan_Code__c = 'S';
                testShipTos.add( shipTo );
            }

            // store one shipto per account to act on later
            testShipTosSubset.add( shipTos[0] );
        }
    }

     static testMethod void testSetIRepInfoVariesOnInsertOfShipTos()
     {
        Integer accountsToCreate = 5;
        Integer shipTosPerAccount = 4;

        setup( accountsToCreate, shipTosPerAccount );

        for( Ship_To__c shipTo : testShipTosSubset )
        {
            if( shipTo.Bill_To_Account__c != testAccounts[0].Id )
            {
                shipTo.iRep__c = testIRep2.Id;
            }
            // if the ship to is looking at the last test account, set the irep to null
            if( shipTo.Bill_To_Account__c == testAccounts[ accountsToCreate - 1 ].Id )
            {
                shipTo.iRep__c = null;
            }
        }

        Test.startTest();

            insert testShipTos;

        Test.stopTest();

        List<Account> updatedAccounts = [ SELECT Id, iRep_Info_Varies__c FROM Account WHERE Id IN :testAccounts ];

        System.assertEquals( accountsToCreate, updatedAccounts.size() );
        for( Account testAccount : updatedAccounts )
        {
            if( testAccount.Id == testAccounts[0].Id )
            {
                System.assert( !testAccount.iRep_Info_Varies__c, 'The iRep Info Varies field should be unchecked when all ShipTos have the same iRep' );
            }
            else
            {
               // System.assert( testAccount.iRep_Info_Varies__c, 'The iRep Info Varies field should be checked when ShipTos do not all have the same iRep' );
            }
        }
     }

     static testMethod void testSetIRepInfoVariesOnUpdateOfShipTos()
     {
        Integer accountsToCreate = 5;
        Integer shipTosPerAccount = 4;

        setup( accountsToCreate, shipTosPerAccount );

        insert testShipTos;

        for( Ship_To__c shipTo : testShipTosSubset )
        {
            if( shipTo.Bill_To_Account__c != testAccounts[0].Id )
            {
                shipTo.iRep__c = testIRep2.Id;
            }
            // if the ship to is looking at the last test account, set the irep to null
            if( shipTo.Bill_To_Account__c == testAccounts[ accountsToCreate - 1 ].Id )
            {
                shipTo.iRep__c = null;
            }
        }

        Test.startTest();

            update testShipTos;

        Test.stopTest();

        List<Account> updatedAccounts = [ SELECT Id, iRep_Info_Varies__c FROM Account WHERE Id IN :testAccounts ];

        System.assertEquals( accountsToCreate, updatedAccounts.size() );
        for( Account testAccount : updatedAccounts )
        {
            if( testAccount.Id == testAccounts[0].Id )
            {
                System.assert( !testAccount.iRep_Info_Varies__c, 'The iRep Info Varies field should be unchecked when all ShipTos have the same iRep' );
            }
            else
            {
                //System.assert( testAccount.iRep_Info_Varies__c, 'The iRep Info Varies field should be checked when ShipTos do not all have the same iRep' );
            }
        }
     }

     static testMethod void testSetIRepInfoVariesOnDeleteOfShipTos()
     {
        Integer accountsToCreate = 5;
        Integer shipTosPerAccount = 3;

        setup( accountsToCreate, shipTosPerAccount );

        for( Ship_To__c shipTo : testShipTosSubset )
        {
            shipTo.iRep__c = null;
        }
        insert testShipTos;

        for( Account testAccount : [ SELECT Id, iRep_Info_Varies__c FROM Account WHERE Id IN :testAccounts ] )
        {
            //System.assert( testAccount.iRep_Info_Varies__c, 'The iRep Info Varies field should be checked when ShipTos do not all have the same iRep' );
        }

        Test.startTest();

            delete testShipTosSubset;

        Test.stopTest();

        List<Account> updatedAccounts = [ SELECT Id, iRep_Info_Varies__c FROM Account WHERE Id IN :testAccounts ];

        System.assertEquals( accountsToCreate, updatedAccounts.size() );
        for( Account testAccount : updatedAccounts )
        {
            //System.assert( !testAccount.iRep_Info_Varies__c, 'The iRep Info Varies field should be unchecked when all ShipTos have the same iRep' );
        }
     }

     static testMethod void testUpdateIRepAccountWithPSROnShipToInsert()
     {
        Integer accountsToCreate = 5;
        Integer shipTosPerAccount = 3;

        setup( accountsToCreate, shipTosPerAccount );

        // look through every account and set the PSR field to be the same PSR as the ireps on the shiptos
        for( Account testAccount : testAccounts )
        {
            testAccount.Primary_Sales_Rep_Name__c = testIRep1.Id;
        }
        update testAccounts;

        Test.startTest();

            insert testShipTos;

        Test.stopTest();

        List<Account> updatedAccounts = [ SELECT Id, iRep__c FROM Account WHERE Id IN :testAccounts ];

        for( Account updatedAccount : updatedAccounts )
        {
            //System.assertEquals( testIRep1.Id, updatedAccount.iRep__c, 'When the account\'s Primary Sales Rep exists among its ShipTo iReps, it should get set as the Account\'s iRep' );
        }
     }

     static testMethod void testUpdateIRepAccountWithPSROnShipToUpdate()
     {
        Integer accountsToCreate = 5;
        Integer shipTosPerAccount = 3;

        setup( accountsToCreate, shipTosPerAccount );

        for( Account testAccount : testAccounts )
        {
            testAccount.Primary_Sales_Rep_Name__c = testIRep2.Id;
        }
        update testAccounts;

        insert testShipTos;
        for( Ship_To__c testShipTo : testShipTos )
        {
            testShipTo.iRep__c = testIRep2.Id;
        }

        removeIRepFromAccounts( testAccounts );

        Test.startTest();

            update testShipTos;

        Test.stopTest();

        List<Account> updatedAccounts = [ SELECT Id, iRep__c FROM Account WHERE Id IN :testAccounts ];

        for( Account updatedAccount : updatedAccounts )
        {
            //System.assertEquals( testIRep2.Id, updatedAccount.iRep__c, 'When the account\'s Primary Sales Rep exists among its ShipTo iReps, it should get set as the Account\'s iRep' );
        }
     }

     static testMethod void testUpdateAccountIRepWithPSROnShipToDelete()
     {
        Integer accountsToCreate = 5;
        Integer shipTosPerAccount = 3;

        setup( accountsToCreate, shipTosPerAccount );

        for( Account testAccount : testAccounts )
        {
            testAccount.Primary_Sales_Rep_Name__c = testIRep2.Id;
        }
        update testAccounts;

        for( Ship_To__c testShipTo : testShipTos )
        {
            if( testShipTo.Bill_To_Account__c == testAccounts[0].Id )
            {
                testShipTo.iRep__c = testIRep2.Id;
            }
        }
        for( Ship_To__c testShipTo : testShipTosSubset )
        {
            testShipTo.iRep__c = testIRep2.Id;
        }
        insert testShipTos;

        removeIRepFromAccounts( testAccounts );

        Test.startTest();

            delete testShipTosSubset;

        Test.stopTest();

        List<Account> updatedAccounts = [ SELECT Id, iRep__c FROM Account WHERE Id IN :testAccounts ];

        for( Account updatedAccount : updatedAccounts )
        {
            if( updatedAccount.Id == testAccounts[0].Id )
            {
                //System.assertEquals( testIRep2.Id, updatedAccount.iRep__c, 'When the account\'s Primary Sales Rep exists among its ShipTo iReps, it should get set as the Account\'s iRep' );
            }
            else
            {
                //System.assertEquals( testIRep1.Id, updatedAccount.iRep__c, 'When the account\'s Primary Sales Rep does not exist among its ShipTo iReps, the Account\'s irep should not be the PSR' );
            }
        }
     }

    static testMethod void testUpdateAccountIRepWithoutPSROnShipToInsert()
    {
        Integer accountsToCreate = 5;
        Integer shipTosPerAccount = 3;

        setup( accountsToCreate, shipTosPerAccount );

        List<Ship_To__c> newerShipTos = new List<Ship_To__c>();
        for( Account testAccount : testAccounts )
        {
            Ship_To__c aNewShipTo = TestDataGeneration.createShipTos( 1, 'New Ship To', testAccount.Id, false )[0];
            aNewShipTo.iRep_Plan_Code__c = 'S';
            if( testAccount.Id == testAccounts[0].Id )
            {
                aNewShipTo.iRep__c = testIRep1.Id;
            }
            else
            {
                aNewShipTo.iRep__c = testIRep2.Id;
            }
            newerShipTos.add( aNewShipTo );
        }

        insert testShipTos;

        removeIRepFromAccounts( testAccounts );

        Test.startTest();

            insert newerShipTos;

        Test.stopTest();

        List<Account> updatedAccounts = [ SELECT Id, iRep__c FROM Account WHERE Id IN :testAccounts ];

        for( Account updatedAccount : updatedAccounts )
        {
            if( updatedAccount.Id == testAccounts[0].Id )
            {
                // this account did not receive a shipto in the newerShipTo list so it should still retain the default shipto irep
                //System.assertEquals( testIRep1.Id, updatedAccount.iRep__c, 'The iRep on the account should be the iRep on the most recently inserted ShipTo' );
            }
            else
            {
                //System.assertEquals( testIRep2.Id, updatedAccount.iRep__c, 'When the account does not find its PSR among its ShipTos, use the latest ShipTos iRep' );
            }
        }
    }

    static testMethod void testUpdateAccountIRepWithoutPSROnShipToUpdate()
    {
        Integer accountsToCreate = 5;
        Integer shipTosPerAccount = 10;

        setup( accountsToCreate, shipTosPerAccount );

        insert testShipTos;

        for( Ship_To__c shipTo : testShipTosSubset )
        {
            if( shipTo.Bill_To_Account__c != testAccounts[0].Id )
            {
                shipTo.iRep__c = testIRep2.Id;
            }
        }

        removeIRepFromAccounts( testAccounts );

        Test.startTest();

            update testShipTosSubset;

        Test.stopTest();

        List<Account> updatedAccounts = [ SELECT Id, iRep__c FROM Account WHERE Id IN :testAccounts ];

        /*for( Account updatedAccount : updatedAccounts )
        {
            if( updatedAccount.Id == testAccounts[0].Id )
            {
                // this account did not have any of its shiptos modified recently, so it retains the original value from the insert
                System.assertEquals( testIRep1.Id, updatedAccount.iRep__c, 'The iRep on the account should be the iRep on the most recently modified ShipTo' );
            }
            else
            {
                System.assertEquals( testIRep2.Id, updatedAccount.iRep__c, 'When the account does not find its PSR among its ShipTos, use the latest ShipTos iRep' );
            }
        }*/
    }

    static void removeIRepFromAccounts( List<Account> accounts )
    {
        // need to null out irep and codes on accounts since trigger has already fired on insert
        for( Account testAccount : accounts )
        {
            testAccount.iRep__c = null;
            testAccount.iRep_Plan__c = null;
        }
        update accounts;
    }
}
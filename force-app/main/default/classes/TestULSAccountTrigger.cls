@isTest
private class TestULSAccountTrigger
{
    static final Integer NUM_OF_CHILD_ACCOUNTS = 5;
    static final String NON_ULS_ACCOUNT_NAME = 'Test';
    static final String ULS_ACCOUNT_NAME = 'Test 3PL';

    static testMethod void testAssociateParentAccountToChildAccounts_ExistingParentAccount_Insert()
    {
        Account testParentAccount = TestingUtils.createULSAccounts( 1, ULS_ACCOUNT_NAME, false )[0];
        testParentAccount.Is_ULS_Primary_Acct__c = true;
        insert testParentAccount;

        List<Account> testChildAccounts = TestingUtils.createULSAccounts( NUM_OF_CHILD_ACCOUNTS, ULS_ACCOUNT_NAME, false );

        Test.startTest();

            insert testChildAccounts;

        Test.stopTest();

        List<Account> actualChildAccounts = [ SELECT Id, ULS_Primary_Account__c FROM Account WHERE Id IN :testChildAccounts ];
        System.assertEquals( NUM_OF_CHILD_ACCOUNTS, actualChildAccounts.size(), 'All the child accounts should be returned' );
        for ( Account anAccount : actualChildAccounts )
        {
           // System.assertEquals( testParentAccount.Id, anAccount.ULS_Primary_Account__c, 'Child accounts should look up to its parent account' );
        }
    }
    

    static testMethod void testAssociateParentAccountToChildAccounts_NonExistingParentAccount_Insert()
    {
        final Integer NUM_OF_ULS_ACCOUNTS = 10;

        /* We want to make sure that this account is not picked up to be a parent account for any of the testAccounts*/
        Account preExistingNon3PLAccount = TestingUtils.createULSAccounts(1,NON_ULS_ACCOUNT_NAME,true)[0];
        
        List<Account> testAccounts = TestingUtils.createULSAccounts( NUM_OF_ULS_ACCOUNTS, ULS_ACCOUNT_NAME, false );
        
        Test.startTest();

            insert testAccounts;

        Test.stopTest();

        Account parentAccount = [ SELECT Id, Is_ULS_Primary_Acct__c FROM Account WHERE Id IN :testAccounts AND ULS_Primary_Account__c = null LIMIT 1 ];
        System.assert( parentAccount.Is_ULS_Primary_Acct__c, 'Is ULS Primary Acct should be set to true' );

        List<Account> actualAccounts = [ SELECT Id, ULS_Primary_Account__c FROM Account WHERE Id IN :testAccounts AND ULS_Primary_Account__c != null ];
       // System.assertEquals( NUM_OF_ULS_ACCOUNTS-1, actualAccounts.size(), 'All accounts should be returned' );
        for( Account anAccount : actualAccounts )
        {
            System.assertEquals( parentAccount.Id, anAccount.ULS_Primary_Account__c, 'Child accounts should look up to its parent account' );
        }
    }
    
    static testMethod void testAssociateParentAccountToChildAccounts_NonExistingParentAccount_ByStratification_Insert()
    {
        final Integer NUM_OF_ULS_ACCOUNTS = 10;

        List<Account> testAccounts = TestingUtils.createULSAccounts( NUM_OF_ULS_ACCOUNTS-1, NON_ULS_ACCOUNT_NAME, false );
        for(Account a : testAccounts)
        {
            a.Segment__c = ULSAccountServices.ULS_STRATIFICATION;
        }
        testAccounts.add(TestingUtils.createULSAccounts( 1, ULS_ACCOUNT_NAME, false )[0]);
        
        Test.startTest();

            insert testAccounts;

        Test.stopTest();

        Account parentAccount = [ SELECT Id, Is_ULS_Primary_Acct__c FROM Account WHERE Id IN :testAccounts AND ULS_Primary_Account__c = null LIMIT 1 ];
        System.assert( parentAccount.Is_ULS_Primary_Acct__c, 'Is ULS Primary Acct should be set to true' );

        List<Account> actualAccounts = [ SELECT Id, ULS_Primary_Account__c FROM Account WHERE Id IN :testAccounts AND ULS_Primary_Account__c != null ];
        //System.assertEquals( NUM_OF_ULS_ACCOUNTS-1, actualAccounts.size(), 'All accounts should be returned' );
        for( Account anAccount : actualAccounts )
        {
            System.assertEquals( parentAccount.Id, anAccount.ULS_Primary_Account__c, 'Child accounts should look up to its parent account' );
        }
    }
    
    static testMethod void testAssociateParentAccountToChildAccounts_NonULSAccounts()
    {
        final Integer NUM_OF_ACCOUNTS = 10;

        List<Account> testAccounts = TestingUtils.createULSAccounts( NUM_OF_ACCOUNTS, 'Test Account', false );

        Test.startTest();

            insert testAccounts;

        Test.stopTest();

        List<Account> actualAccounts = [ SELECT Id, ULS_Primary_Account__c FROM Account WHERE Id IN :testAccounts];
        System.assertEquals( NUM_OF_ACCOUNTS, actualAccounts.size(), 'All accounts should be returned' );
        for( Account anAccount : actualAccounts )
        {
            System.assertEquals( null, anAccount.ULS_Primary_Account__c, 'The association between the child and parent account should not be populated' );
        }
    }

    static testMethod void testAssociateParentAccountToChildAccounts_ExistingParentAccount_MultipleParents_Insert()
    {
        final String ULS_ACCOUNT_ONE = 'First Account 3PL';
        final String ULS_ACCOUNT_TWO = 'Second Account 3PL';
        final Integer NUM_OF_ULS_ACCOUNTS = 10;
        
        Account existingParentAccount = TestingUtils.createULSAccounts(1, ULS_ACCOUNT_ONE, true)[0];
        
        List<Account> testNewChildOnlyULSAccounts = TestingUtils.createULSAccounts( NUM_OF_ULS_ACCOUNTS, ULS_ACCOUNT_ONE, false );
        List<Account> testNewParentAndChildULSAccounts = TestingUtils.createULSAccounts( NUM_OF_ULS_ACCOUNTS, ULS_ACCOUNT_TWO, false );
        List<Account> testNewULSAccounts = new List<Account>();
        testNewULSAccounts.addAll( testNewChildOnlyULSAccounts );
        testNewULSAccounts.addAll( testNewParentAndChildULSAccounts );

        Test.startTest();

            insert testNewULSAccounts;
 
        Test.stopTest();

        Account parentAccountOne = [Select ID, Is_ULS_Primary_Acct__c FROM Account WHERE Id=:existingParentAccount.ID];
        System.assert( parentAccountOne.Is_ULS_Primary_Acct__c, 'Is ULS Primary Acct should be set to true' );

        Account parentAccountTwo = [ SELECT Id,Is_ULS_Primary_Acct__c FROM Account WHERE Id IN :testNewULSAccounts AND ULS_Primary_Account__c = null AND Id IN :testNewParentAndChildULSAccounts LIMIT 1 ];
        System.assert( parentAccountTwo.Is_ULS_Primary_Acct__c, 'Is ULS Primary Acct should be set to true' );
        
        testNewChildOnlyULSAccounts = [ SELECT Id, Name, ULS_Primary_Account__c FROM Account WHERE Id IN :testNewChildOnlyULSAccounts AND ULS_Primary_Account__c != null ];
        testNewParentAndChildULSAccounts = [ SELECT Id, Name, ULS_Primary_Account__c FROM Account WHERE Id IN :testNewParentAndChildULSAccounts AND ULS_Primary_Account__c != null ];
        
        //System.assertEquals(NUM_OF_ULS_ACCOUNTS,testNewChildOnlyULSAccounts.size(),'All child accounts should be returned');
        
        Integer expectdAccountsAfterIgnoringParentAccount = NUM_OF_ULS_ACCOUNTS-1;
      //  System.assertEquals(expectdAccountsAfterIgnoringParentAccount,testNewParentAndChildULSAccounts.size(),'All child accounts should be returned');
        
        for(Account anAccount : testNewChildOnlyULSAccounts)
        {
            System.assertEquals( parentAccountOne.Id, anAccount.ULS_Primary_Account__c, 'Child accounts should be looking upto the correct parent account' );
        }
        
        for(Account anAccount : testNewParentAndChildULSAccounts)
        {
            System.assertEquals( parentAccountTwo.Id, anAccount.ULS_Primary_Account__c, 'Child accounts should be looking upto the correct parent account' );
        }
    }
    
    static testMethod void testAssociateParentAccountToChildAccounts_NonExistingParentAccount_MultipleParents_Insert()
    {
        final String ULS_ACCOUNT_ONE = 'First Account 3PL';
        final String ULS_ACCOUNT_TWO = 'Second Account 3PL';
        final Integer NUM_OF_ULS_ACCOUNTS = 10;

        List<Account> testULSAccountOne = TestingUtils.createULSAccounts( NUM_OF_ULS_ACCOUNTS, ULS_ACCOUNT_ONE, false );
        List<Account> testULSAccountTwo = TestingUtils.createULSAccounts( NUM_OF_ULS_ACCOUNTS, ULS_ACCOUNT_TWO, false );
        List<Account> testULSAccounts = new List<Account>();
        testULSAccounts.addAll( testULSAccountOne );
        testULSAccounts.addAll( testULSAccountTwo );

        Test.startTest();

            insert testULSAccounts;

        Test.stopTest();

        Account parentAccountOne = [ SELECT Id, Is_ULS_Primary_Acct__c FROM Account WHERE Id IN :testULSAccounts AND ULS_Primary_Account__c = null AND Id IN :testULSAccountOne LIMIT 1 ];
        System.assert( parentAccountOne.Is_ULS_Primary_Acct__c, 'Is ULS Primary Acct should be set to true' );

        Account parentAccountTwo = [ SELECT Id,Is_ULS_Primary_Acct__c FROM Account WHERE Id IN :testULSAccounts AND ULS_Primary_Account__c = null AND Id IN :testULSAccountTwo LIMIT 1 ];
        System.assert( parentAccountTwo.Is_ULS_Primary_Acct__c, 'Is ULS Primary Acct should be set to true' );

        Integer expectedAccountSize = ( NUM_OF_ULS_ACCOUNTS * 2 ) - 2;
        List<Account> actualAccounts = [ SELECT Id, Name, ULS_Primary_Account__c FROM Account WHERE Id IN :testULSAccounts AND ULS_Primary_Account__c != null ];
        //System.assertEquals( expectedAccountSize, actualAccounts.size(), 'All accounts should be returned' );
        for( Account anAccount : actualAccounts )
        {
            if( anAccount.Name == ULS_ACCOUNT_ONE )
            {
                System.assertEquals( parentAccountOne.Id, anAccount.ULS_Primary_Account__c, 'Child accounts should be looking upto the correct parent account' );
            }
            else
            {
                System.assertEquals( parentAccountTwo.Id, anAccount.ULS_Primary_Account__c, 'Child accounts should be looking upto the correct parent account' );
            }
        }
    }

    static testMethod void testAssociateParentAccountToChildAccounts_ExistingParentAccount_ParentAccountWithParent_Insert()
    {
        final Integer NUM_OF_ULS_ACCOUNTS = 5;

        Account grandParentAccount = TestingUtils.createULSAccounts( 1, ULS_ACCOUNT_NAME, true )[0];
        //Resetting the Is_ULS_Primary_Acct__c to false
        grandParentAccount.Is_ULS_Primary_Acct__c = false;
        update grandParentAccount;

        Account parentAccount = TestingUtils.createULSAccounts( 1, ULS_ACCOUNT_NAME, false )[0];
        parentAccount.ULS_Primary_Account__c = grandParentAccount.Id;
        insert parentAccount;

        List<Account> testULSAccounts = TestingUtils.createULSAccounts( NUM_OF_ULS_ACCOUNTS, ULS_ACCOUNT_NAME, false );

        Test.startTest();

            insert testULSAccounts;

        Test.stopTest();

        Account actualParentAccount = [ SELECT Id, Is_ULS_Primary_Acct__c FROM Account WHERE Id IN :testULSAccounts AND Is_ULS_Primary_Acct__c = true LIMIT 1 ];
        System.assert( actualParentAccount.Is_ULS_Primary_Acct__c, 'One of the account from ULS Account should be set to Primary (Parent) Account' );

        Integer expectedAccountSize = NUM_OF_ULS_ACCOUNTS - 1;
        List<Account> actualAccounts = [ SELECT Id, ULS_Primary_Account__c FROM Account WHERE ULS_Primary_Account__c != null AND Id IN :testULSAccounts ];
        //System.assertEquals( expectedAccountSize, actualAccounts.size(), 'All accounts should be returned' );
        for( Account anAccount : actualAccounts )
        {
            System.assertEquals( actualParentAccount.Id, anAccount.ULS_Primary_Account__c, 'Child accounts should be looking upto the correct parent account' );
        }
    }

    static testMethod void testAssociateParentAccountToChildAccounts_TEST_FirstHalf()
    {
        final String ULS_NAME_ONE = 'Test 3PL';
        final String ULS_NAME_FIVE = 'Test-(3PL)';
        final String ULS_NAME_SIX = 'Test*3PL';
        final String ULS_NAME_SEVEN = 'Test*(3PL)';

        Id customerRecordtypeId = [ SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Customer' ].Id;

        Test.startTest();

            Account testAccountOne = TestingUtils.createULSAccounts( 1, ULS_NAME_ONE, false )[0];
            testAccountOne.RecordTypeId = customerRecordtypeId;
            insert testAccountOne;

            Account actualAccountOne = [ SELECT Id, Is_ULS_Primary_Acct__c FROM Account WHERE Id = :testAccountOne.Id ];
            System.assert( actualAccountOne.Is_ULS_Primary_Acct__c, 'First account with ULS name should be considered as a Parent Account' );

            Account testAccountFive = TestingUtils.createULSAccounts( 1, ULS_NAME_FIVE, false )[0];
            testAccountFive.RecordTypeId = customerRecordtypeId;
            insert testAccountFive;

            Account actualAccountFive = [ SELECT Id, Is_ULS_Primary_Acct__c, ULS_Primary_Account__c FROM Account WHERE Id = :testAccountFive.Id ];
          //  System.assert( !actualAccountFive.Is_ULS_Primary_Acct__c, 'Sub accounts with ULS name should not be considered as a Parent Account' );
           // System.assertEquals( testAccountOne.Id, actualAccountFive.ULS_Primary_Account__c, 'ULS Primary Account on sub accounts should be set to its parent account' );

            Account testAccountSix = TestingUtils.createULSAccounts( 1, ULS_NAME_SIX, false )[0];
            testAccountSix.RecordTypeId = customerRecordtypeId;
            insert testAccountSix;

            Account actualAccountSix = [ SELECT Id, Is_ULS_Primary_Acct__c, ULS_Primary_Account__c FROM Account WHERE Id = :testAccountSix.Id ];
            System.assert( !actualAccountSix.Is_ULS_Primary_Acct__c, 'Sub accounts with ULS name should not be considered as a Parent Account' );
           // System.assertEquals( testAccountOne.Id, actualAccountSix.ULS_Primary_Account__c, 'ULS Primary Account on sub accounts should be set to its parent account' );

            Account testAccountSeven = TestingUtils.createULSAccounts( 1, ULS_NAME_SEVEN, false )[0];
            testAccountSeven.RecordTypeId = customerRecordtypeId;
            insert testAccountSeven;

            Account actualAccountSeven = [ SELECT Id, Is_ULS_Primary_Acct__c, ULS_Primary_Account__c FROM Account WHERE Id = :testAccountSeven.Id ];
            System.assert( !actualAccountSeven.Is_ULS_Primary_Acct__c, 'Sub accounts with ULS name should not be considered as a Parent Account' );
           // System.assertEquals( testAccountOne.Id, actualAccountSeven.ULS_Primary_Account__c, 'ULS Primary Account on sub accounts should be set to its parent account' );

        Test.stopTest();
    }
    
    static testMethod void testAssociateParentAccountToChildAccounts_TEST_SecondHalf()
    {
        final String ULS_NAME_ONE = 'Test 3PL';
        final String ULS_NAME_TWO = 'Test (3PL)';
        final String ULS_NAME_THREE = 'Test(3PL)';
        final String ULS_NAME_FOUR = 'Test-3PL';

        Id customerRecordtypeId = [ SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Customer' ].Id;

        Test.startTest();

            Account testAccountOne = TestingUtils.createULSAccounts( 1, ULS_NAME_ONE, false )[0];
            testAccountOne.RecordTypeId = customerRecordtypeId;
            insert testAccountOne;

            Account actualAccountOne = [ SELECT Id, Is_ULS_Primary_Acct__c FROM Account WHERE Id = :testAccountOne.Id ];
            System.assert( actualAccountOne.Is_ULS_Primary_Acct__c, 'First account with ULS name should be considered as a Parent Account' );

            Account testAccountTwo = TestingUtils.createULSAccounts( 1, ULS_NAME_TWO, false )[0];
            testAccountTwo.RecordTypeId = customerRecordtypeId;
            insert testAccountTwo;

            Account actualAccountTwo = [ SELECT Id, Is_ULS_Primary_Acct__c, ULS_Primary_Account__c FROM Account WHERE Id = :testAccountTwo.Id ];
            //System.assert( !actualAccountTwo.Is_ULS_Primary_Acct__c, 'Sub accounts with ULS name should not be considered as a Parent Account' );
            //System.assertEquals( testAccountOne.Id, actualAccountTwo.ULS_Primary_Account__c, 'ULS Primary Account on sub accounts should be set to its parent account' );

            Account testAccountThree = TestingUtils.createULSAccounts( 1, ULS_NAME_THREE, false )[0];
            testAccountThree.RecordTypeId = customerRecordtypeId;
            insert testAccountThree;

            Account actualAccountThree = [ SELECT Id, Is_ULS_Primary_Acct__c, ULS_Primary_Account__c FROM Account WHERE Id = :testAccountThree.Id ];
            //System.assert( !actualAccountThree.Is_ULS_Primary_Acct__c, 'Sub accounts with ULS name should not be considered as a Parent Account' );
            //System.assertEquals( testAccountOne.Id, actualAccountThree.ULS_Primary_Account__c, 'ULS Primary Account on sub accounts should be set to its parent account' );

            Account testAccountFour = TestingUtils.createULSAccounts( 1, ULS_NAME_FOUR, false )[0];
            testAccountFour.RecordTypeId = customerRecordtypeId;
            insert testAccountFour;

            Account actualAccountFour = [ SELECT Id, Is_ULS_Primary_Acct__c, ULS_Primary_Account__c FROM Account WHERE Id = :testAccountFour.Id ];
            //System.assert( !actualAccountFour.Is_ULS_Primary_Acct__c, 'Sub accounts with ULS name should not be considered as a Parent Account' );
            //System.assertEquals( testAccountOne.Id, actualAccountFour.ULS_Primary_Account__c, 'ULS Primary Account on sub accounts should be set to its parent account' );

        Test.stopTest();
    }
}
@isTest
public class TestUpdateContactsCount {
    @isTest static void testContactsCountUpdateAfterInsert() {
        // Create test Account with no contacts
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Verify initial Number_of_Contacts__c and Number_of_Active_Contacts__c values for an account with no contacts
        testAccount = [SELECT Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(0, testAccount.Number_of_Contacts__c);
        System.assertEquals(0, testAccount.Number_of_Active_Contacts__c);

        // Create test Contacts with different Inactive__c values
        Contact activeContact1 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact1', Inactive__c = false);
        Contact activeContact2 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact2', Inactive__c = false);
        Contact inactiveContact = new Contact(AccountId = testAccount.Id, FirstName = 'Inactive', LastName = 'Contact3', Inactive__c = true);
        insert new List<Contact>{ activeContact1, activeContact2, inactiveContact };

        // Verify updated Number_of_Contacts__c and Number_of_Active_Contacts__c values after inserting contacts
        testAccount = [SELECT Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(3, testAccount.Number_of_Contacts__c);
        System.assertEquals(2, testAccount.Number_of_Active_Contacts__c);

    }
    
    @isTest static void testContactsCountUpdateAfterInactiveUpdate() {
        // Create test Account with no contacts
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Contacts with different Inactive__c values
        Contact activeContact1 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact1', Inactive__c = false);
        Contact activeContact2 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact2', Inactive__c = false);
        Contact inactiveContact = new Contact(AccountId = testAccount.Id, FirstName = 'Inactive', LastName = 'Contact3', Inactive__c = true);
        insert new List<Contact>{ activeContact1, activeContact2, inactiveContact };

        // Update one contact to be inactive
        activeContact1.Inactive__c = true;
        update activeContact1;

        // Verify updated Number_of_Contacts__c and Number_of_Active_Contacts__c values
        testAccount = [SELECT Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(3, testAccount.Number_of_Contacts__c);
        System.assertEquals(1, testAccount.Number_of_Active_Contacts__c);

    }
    
    @isTest static void testContactsCountUpdateAfterActiveUpdate() {
        // Create test Account with no contacts
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Contacts with different Inactive__c values
        Contact activeContact1 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact1', Inactive__c = false);
        Contact activeContact2 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact2', Inactive__c = false);
        Contact inactiveContact = new Contact(AccountId = testAccount.Id, FirstName = 'Inactive', LastName = 'Contact3', Inactive__c = true);
        insert new List<Contact>{ activeContact1, activeContact2, inactiveContact };
            
        // Update one contact to be inactive
        activeContact1.Inactive__c = true;
        update activeContact1;

        // Update an inactive contact to be active
        inactiveContact.Inactive__c = false;
        update inactiveContact;

        // Verify updated Number_of_Contacts__c and Number_of_Active_Contacts__c values after update to active
        testAccount = [SELECT Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(3, testAccount.Number_of_Contacts__c);
        System.assertEquals(2, testAccount.Number_of_Active_Contacts__c);

    }
    
    @isTest static void testContactsCountUpdateAfterDelete() {
        // Create test Account with no contacts
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Contacts with different Inactive__c values
        Contact activeContact1 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact1', Inactive__c = false);
        Contact activeContact2 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact2', Inactive__c = false);
        Contact inactiveContact = new Contact(AccountId = testAccount.Id, FirstName = 'Inactive', LastName = 'Contact3', Inactive__c = true);
        insert new List<Contact>{ activeContact1, activeContact2, inactiveContact };

        // Update one contact to be inactive
        activeContact1.Inactive__c = true;
        update activeContact1;

        // Update an inactive contact to be active
        inactiveContact.Inactive__c = false;
        update inactiveContact;

        // Delete an active contact
        delete activeContact2;
        
        // Verify updated Number_of_Contacts__c and Number_of_Active_Contacts__c values after delete
        testAccount = [SELECT Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(2, testAccount.Number_of_Contacts__c);
        System.assertEquals(1, testAccount.Number_of_Active_Contacts__c);
    }
    
    @isTest static void testContactsCountUpdateAfterUndelete() {
        // Create test Account with no contacts
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Contacts with different Inactive__c values
        Contact activeContact1 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact1', Inactive__c = false);
        Contact activeContact2 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact2', Inactive__c = false);
        Contact inactiveContact = new Contact(AccountId = testAccount.Id, FirstName = 'Inactive', LastName = 'Contact3', Inactive__c = true);
        insert new List<Contact>{ activeContact1, activeContact2, inactiveContact };

        // Delete an active contact
        delete activeContact2;
        
        // Undelete an active contact
        undelete activeContact2;
        
        // Verify updated Number_of_Contacts__c and Number_of_Active_Contacts__c values after delete
        testAccount = [SELECT Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(3, testAccount.Number_of_Contacts__c);
        System.assertEquals(2, testAccount.Number_of_Active_Contacts__c);
    }
    
    @isTest static void testContactsCountUpdateAfterDeleteNull() {
        // Create test Account with no contacts
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Contacts with different Inactive__c values
        Contact activeContact1 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact1', Inactive__c = false);
        Contact activeContact2 = new Contact(AccountId = testAccount.Id, FirstName = 'Active', LastName = 'Contact2', Inactive__c = false);
        Contact inactiveContact = new Contact(AccountId = testAccount.Id, FirstName = 'Inactive', LastName = 'Contact3', Inactive__c = true);
        insert new List<Contact>{ activeContact1, activeContact2, inactiveContact };

        // Update one contact to be inactive
        activeContact1.Inactive__c = true;
        update activeContact1;

        // Update an inactive contact to be active
        inactiveContact.Inactive__c = false;
        update inactiveContact;

        // Delete an active contact
        delete activeContact2;
        delete activeContact1;
        delete inactiveContact;

        // Verify updated Number_of_Contacts__c and Number_of_Active_Contacts__c values after delete
        testAccount = [SELECT Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(0, testAccount.Number_of_Contacts__c);
        System.assertEquals(0, testAccount.Number_of_Active_Contacts__c);
    }
    
    @isTest static void testAccountMerge() {
        
        System.debug('Account merge');
        // Create test Accounts
        Account account1 = new Account(Name = 'Account 1');
        Account account2 = new Account(Name = 'Account 2');
        insert new List<Account>{ account1, account2 };

        // Create test Contacts associated with each Account
        Contact contact1 = new Contact(AccountId = account1.Id, FirstName = 'Contact', LastName = '1', Inactive__c = false);
        Contact contact2 = new Contact(AccountId = account1.Id, FirstName = 'Contact', LastName = '2', Inactive__c = false);
        Contact contact3 = new Contact(AccountId = account2.Id, FirstName = 'Contact', LastName = '3', Inactive__c = false);
        insert new List<Contact>{ contact1, contact2, contact3 };

        // Reparent contacts from account2 to account1 (simulate account merge)
        Test.startTest();
		contact3.AccountId = account1.Id;
        System.debug('Reparenting contact');
        update contact3;
        Test.stopTest();

        // Verify updated Number_of_Contacts__c and Number_of_Active_Contacts__c values for merged Account 1
        account1 = [SELECT Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account WHERE Id = :account1.Id];
        System.assertEquals(3, account1.Number_of_Contacts__c);
        System.assertEquals(3, account1.Number_of_Active_Contacts__c);

        // Verify updated Number_of_Contacts__c and Number_of_Active_Contacts__c values for merged Account 2
        account2 = [SELECT Number_of_Contacts__c, Number_of_Active_Contacts__c FROM Account WHERE Id = :account2.Id];
        System.assertEquals(0, account2.Number_of_Contacts__c);
        System.assertEquals(0, account2.Number_of_Active_Contacts__c);
    }
}
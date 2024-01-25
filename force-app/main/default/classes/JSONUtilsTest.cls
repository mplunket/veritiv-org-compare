@isTest
public class JSONUtilsTest {
	
	static Date expectedDate = Date.today().addDays(1);
	static Datetime expectedDatetime = Datetime.now().addDays(1);
	static Integer NUM_OF_RECORDS = 50;

	public final static String TEST_ACCOUNT_NAME = 'Test Account1';
	public final static String TEST_ACCOUNT_WEBSITE = 'https://www.test.com';
	
	public static testMethod void testCreateSObject(){
		
		Datetime nowReference = Datetime.now();
		
		Map<String, Object> expectedFields = new Map<String, Object>{
			'Name' => TEST_ACCOUNT_NAME,
			'Website' => TEST_ACCOUNT_WEBSITE,
			'LastModifiedDate' => nowReference.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')
		};
		
		Test.startTest();
		
			SObject acct = JSONUtils.createSObject(Account.getSobjectType(), expectedFields);
		
		Test.stopTest();
		
		System.assertNotEquals(null, acct, 'We expect to have an SObject instance created. ');
		System.assertEquals(Account.getSobjectType(), acct.getSobjectType(), 'We expect to have an instance of Account. ');
		for (String fieldName : expectedFields.keySet()){
			if (fieldName != 'LastModifiedDate'){
				System.assertEquals(expectedFields.get(fieldName), acct.get(fieldName), 
					'We expect to have the correct value on the Sobject created for field: ' + fieldName);
			}
			else {
				System.assertEquals(nowReference, acct.get(fieldName), 
					'We expect to have the correct value on the Sobject created for field: ' + fieldName);
			}
		}
		
	}
	
	public static testMethod void testCreateSObjects(){
		
		Integer NUM_OF_ACCOUNTS = 50; 
		
		Datetime nowReference = Datetime.now();
		
		Map<String, Object> expectedFields = new Map<String, Object>{
			'Name' => TEST_ACCOUNT_NAME,
			'Website' => TEST_ACCOUNT_WEBSITE,
			'LastModifiedDate' => nowReference.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')
		};
		
		Test.startTest();
		
			List<SObject> accts = JSONUtils.createSObjects(NUM_OF_ACCOUNTS, Account.getSobjectType(), expectedFields);
		
		Test.stopTest();
		
		System.assertEquals(NUM_OF_ACCOUNTS, accts.size(), 'We expect to have the correct number of accounts created.');
		for (Sobject acct : accts){
			System.assertNotEquals(null, acct, 'We expect to have an SObject instance created. ');
			System.assertEquals(Account.getSobjectType(), acct.getSobjectType(), 'We expect to have an instance of Account. ');
			for (String fieldName : expectedFields.keySet()){
				if (fieldName != 'LastModifiedDate'){
					System.assertEquals(expectedFields.get(fieldName), acct.get(fieldName), 
						'We expect to have the correct value on the Sobject created for field: ' + fieldName);
				}
				else {
					System.assertEquals(nowReference, acct.get(fieldName), 
						'We expect to have the correct value on the Sobject created for field: ' + fieldName);
				}
			}
		}
	}
	
	public static testMethod void testCreateSObject_Dates() {

		Map<String,Object> expectedFields = new Map<String,Object>
		{
			'LastName' => 'Test Contact',
			'Birthdate' =>  Date.today().addDays(1),
			'LastModifiedDate' => Datetime.now().addDays(1)
		};

		Test.startTest();
			SObject cont = JSONUtils.createSObject(Contact.SObjectType, expectedFields);
		Test.stopTest();

		System.assertNotEquals(null,cont,'We expect a Contact to be returned');

		for(String field : expectedFields.keySet())
		{
			System.assertEquals(expectedFields.get(field),cont.get(field),
						  'We expect to have the correct value on the Sobject created for field: ' + field);
		}

	}

	public static testMethod void testCreateSObject_SObjectField()
	{
		Map<Schema.SobjectField,Object> expectedFields = new Map<Schema.SobjectField,Object>
		{
			Contact.LastName => 'Test Contact',
			Contact.Birthdate =>  Date.today().addDays(1),
			Contact.LastModifiedDate => Datetime.now().addDays(1)
		};

		Test.startTest();
			SObject cont = JSONUtils.createSObject(Contact.SObjectType, expectedFields);
		Test.stopTest();

		for(Schema.SobjectField field : expectedFields.keySet())
		{
			System.assertEquals(expectedFields.get(field),cont.get(field),
						  'We expect to have the correct value on the Sobject created for field: ' + field);
		}
	}


	public static testMethod void testCreateSObjects_SObjectField()
	{

		Map<Schema.SobjectField,Object> expectedFields = new Map<Schema.SobjectField,Object>
		{
			Contact.LastName => 'Test Contact',
			Contact.Birthdate =>  Date.today().addDays(1),
			Contact.LastModifiedDate => Datetime.now().addDays(1)
		};

		Test.startTest();
			List<SObject> contacts = JSONUtils.createSObjects(NUM_OF_RECORDS, Contact.SObjectType, expectedFields);
		Test.stopTest();

		System.assertEquals(NUM_OF_RECORDS,contacts.size(),'We expect to have the correct number of accounts created.');
		for(SObject cont : contacts)
		{
			System.assertNotEquals(null, cont, 'We expect to have an SObject instance created. ');
			System.assertEquals(Contact.SObjectType, cont.getSobjectType(), 'We expect to have an instance of Contact. ');
			for(Schema.SobjectField field : expectedFields.keySet())
			{
				System.assertEquals(expectedFields.get(field),cont.get(field),
							  'We expect to have the correct value on the Sobject created for field: ' + field);
			}
		}
	}

	public static testMethod void testSetField()
	{
		String expectedName = 'Test Account';
		Account testAccount = new Account(Name = expectedName);
		String expectedField = 'CreatedDate';

		Test.startTest();
			Account actualAccount = (Account) JSONUtils.setField(testAccount, expectedField, expectedDatetime);
		Test.stopTest();

		System.assertEquals(expectedName,actualAccount.Name,'We expected these fields to be the same');
		System.assertEquals(expectedDatetime,actualAccount.get(expectedField),'We expected the field to be properly set');

	}

	public static testMethod void testSetField_SObjectField()
	{
		String expectedName = 'Test Account';
		Account testAccount = new Account(Name = expectedName);
		Schema.SObjectField expectedField = Account.CreatedDate;

		Test.startTest();
			Account actualAccount = (Account) JSONUtils.setField(testAccount, expectedField, expectedDatetime);
		Test.stopTest();

		System.assertEquals(expectedName,actualAccount.Name,'We expected these fields to be the same');
		System.assertEquals(expectedDatetime,actualAccount.get(expectedField),'We expected the field to be properly set');

	}

	public static testMethod void testSetField_SObjects()
	{
		
		String expectedName = 'Test Account';
		List<Account> testAccountList = new List<Account>();
		
		for(Integer i = 0; i < NUM_OF_RECORDS; i++)
		{
			testAccountList.add(new Account(Name = expectedName));
		}

		String expectedField = 'CreatedDate';

		Test.startTest();
			List<Account> actualAccountList = (List<Account>) JSONUtils.setField(testAccountList, expectedField, expectedDatetime);
		Test.stopTest();

		System.assertEquals(testAccountList.size(),actualAccountList.size(),'We expect List size to be the same');
		for(Account actualAccount :  actualAccountList)
		{
			System.assertEquals(expectedName,actualAccount.Name,'We expected these fields to be the same');
			System.assertEquals(expectedDatetime,actualAccount.get(expectedField),'We expected the field to be properly set');
		}

	}

	public static testMethod void testSetField_SObjects_SObjectField()
	{
		
		String expectedName = 'Test Account';
		List<Account> testAccountList = new List<Account>();
		
		for(Integer i = 0; i < NUM_OF_RECORDS; i++)
		{
			testAccountList.add(new Account(Name = expectedName));
		}

		Schema.SObjectField expectedField = Account.CreatedDate;

		Test.startTest();
			List<Account> actualAccountList = (List<Account>) JSONUtils.setField(testAccountList, expectedField, expectedDatetime);
		Test.stopTest();

		System.assertEquals(testAccountList.size(),actualAccountList.size(),'We expect List size to be the same');
		for(Account actualAccount :  actualAccountList)
		{
			System.assertEquals(expectedName,actualAccount.Name,'We expected these fields to be the same');
			System.assertEquals(expectedDatetime,actualAccount.get(expectedField),'We expected the field to be properly set');
		}

	}

	public static testMethod void testSetFields()
	{
		String expectedName = 'Test Contact';
		Contact testContact = new Contact(LastName = 'Overwrite name');
		
		Map<String,Object> expectedFields = new Map<String,Object>
		{
			'LastName' => expectedName,
			'Birthdate' =>  Date.today().addDays(1),
			'LastModifiedDate' => Datetime.now().addDays(1)
		};

		Test.startTest();
			Contact actualContact = (Contact) JSONUtils.setFields(testContact, expectedFields);
		Test.stopTest();
		
		System.assertEquals(expectedName,actualContact.LastName,'We expect the name to be set');
		for(String field : expectedFields.keySet())
		{
			System.assertEquals(expectedFields.get(field),actualContact.get(field),
						  'We expect to have the correct value on the Sobject created for field: ' + field);
		}
	}

	public static testMethod void testSetFields_SObjectField()
	{
		String expectedName = 'Test Contact';
		Contact testContact = new Contact(LastName = expectedName);
		
		Map<Schema.SobjectField,Object> expectedFields = new Map<Schema.SobjectField,Object>
		{
			Contact.Birthdate =>  Date.today().addDays(1),
			Contact.LastModifiedDate => Datetime.now().addDays(1)
		};

		Test.startTest();
			Contact actualContact = (Contact) JSONUtils.setFields(testContact, expectedFields);
		Test.stopTest();
		
		System.assertEquals(expectedName,actualContact.LastName,'We expect the name to be set');
		for(Schema.SobjectField field : expectedFields.keySet())
		{
			System.assertEquals(expectedFields.get(field),actualContact.get(field),
						  'We expect to have the correct value on the Sobject created for field: ' + field);
		}
	}

	public static testMethod void testSetFields_SObjects()
	{
		String expectedName = 'Test Contact';
		List<Contact> testContactList = new List<Contact>();
		
		for(Integer i = 0; i < NUM_OF_RECORDS; i++)
		{
			testContactList.add(new Contact(LastName = expectedName));
		}

		Map<String,Object> expectedFields = new Map<String,Object>
		{
			'Birthdate' =>  Date.today().addDays(1),
			'LastModifiedDate' => Datetime.now().addDays(1)
		};

		Test.startTest();
			List<Contact> actualContactList = (List<Contact>) JSONUtils.setFields(testContactList, expectedFields);
		Test.stopTest();

		System.assertEquals(testContactList.size(),actualContactList.size(),'We expect List size to be the same');
		for(Contact actualContact :  actualContactList)
		{
			System.assertEquals(expectedName,actualContact.LastName);
			for(String field : expectedFields.keySet())
			{
				System.assertEquals(expectedFields.get(field),actualContact.get(field),
						  'We expect to have the correct value on the Sobject created for field: ' + field);
			}
		}
	}

	public static testMethod void testSetFields_SObjects_SObjectField()
	{
		String expectedName = 'Test Contact';
		List<Contact> testContactList = new List<Contact>();
		
		for(Integer i = 0; i < NUM_OF_RECORDS; i++)
		{
			testContactList.add(new Contact(LastName = expectedName));
		}

		Map<Schema.SObjectField,Object> expectedFields = new Map<Schema.SObjectField,Object>
		{
			Contact.Birthdate =>  Date.today().addDays(1),
			Contact.LastModifiedDate => Datetime.now().addDays(1)
		};

		Test.startTest();
			List<Contact> actualContactList = (List<Contact>) JSONUtils.setFields(testContactList, expectedFields);
		Test.stopTest();

		System.assertEquals(testContactList.size(),actualContactList.size(),'We expect List size to be the same');
		for(Contact actualContact :  actualContactList)
		{
			System.assertEquals(expectedName,actualContact.LastName);
			for(Schema.SObjectField field : expectedFields.keySet())
			{
				System.assertEquals(expectedFields.get(field),actualContact.get(field),
						  'We expect to have the correct value on the Sobject created for field: ' + field);
			}
		}
	}

}
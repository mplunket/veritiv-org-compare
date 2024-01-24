@isTest
public class testcreatecaseforproactivecase {

	public static testMethod void testcopycontactid()
	{
		RecordType accountrecordtype = [select r.Id from RecordType r where r.name = 'Prospect'];
		RecordType contactrecordtype = [select r.Id from RecordType r where r.Name = 'Customer Contact'];
		User ownerid1 = [select id from user where isactive = true limit 1];	
		Account account = new Account();
		account.name = 'RamiTestAccount';
		account.ownerid = ownerid1.Id;
		account.recordtypeid = accountrecordtype.Id;
		account.Account_DW_key__c = '999999';
		insert account;
		
		Contact contact = new Contact();
		contact.lastname = 'testlastname';
		contact.phone = '(386) 269-0802';
		contact.accountid = account.id;
		contact.recordtypeid = contactrecordtype.id;
		insert contact;
		
		Contact delcontact = new Contact(Id = contact.id);
		Test.startTest();
		delete delcontact;
		Test.stopTest();
	}
}
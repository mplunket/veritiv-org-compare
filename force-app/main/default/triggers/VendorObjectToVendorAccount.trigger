trigger VendorObjectToVendorAccount on Vendor_Detail__c (after insert) 
{
	Id vendorAccountId = [select Id from RecordType where SObjectType = 'Account' and Name = 'Vendor'].Id;
	
	List<Account> vendorAccounts = new List<Account>();
	for(Vendor_Detail__c v : trigger.new)
	{
		Account vendorAccount = new Account(Name = v.Name, 
											Vendor_Code__c = v.Vendor_Code__c,
											Client_Number__c = v.Vendor_Client_Number__c,
											RecordtypeId = vendorAccountId);
		vendorAccounts.add(vendorAccount);
	}
	
	insert vendorAccounts;
}
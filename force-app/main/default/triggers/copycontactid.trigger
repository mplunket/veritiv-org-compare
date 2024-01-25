trigger copycontactid on Contact (before delete) 
{
	if(!CaseNotification.isInsertingTempContacts)
	{
		list<contactdelete__c> contactdel = new list<contactdelete__c>();
		
		Id custcontacrecordtypeid = [select r.Id From RecordType r where r.Name = 'Customer Contact'].id;
		for (Integer i = 0; i<trigger.old.size(); i++)
		{
			if (trigger.old[i].RecordTypeId == custcontacrecordtypeid)
			{
				contactdelete__c cd = new contactdelete__c();
				cd.copycontactid__c = trigger.old[i].id;
				contactdel.add(cd);
			}
		}
		
		insert contactdel;
	}
}
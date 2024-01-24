public class CaseNotification {

	public static Boolean isInsertingTempContacts = false;

	public static Boolean caseTriggerBeforeIsRunning = false;
	public static Boolean caseTriggerAfterIsRunning = false;
	
	
	public static Boolean sendOwnerChangedEmail( List<Case> casesWithNewOwners )
	{
        String templateName = Fax_To_Case_Queue_Backups__c.getInstance().Case_assignment_template__c;
        
        String orgWideEmailName = Fax_To_Case_Queue_Backups__c.getInstance().Org_Wide_Email_Display_Name__c;
        
        return sendEmail( casesWithNewOwners, templateName, orgWideEmailName );
	}
	
	/**
		generates a map from case Id to a temporary contact with an email address of the case owner.
	*/
	public static Map<Id, Contact> generateTempContacts( List<Case> casesToMail )
	{
		
		List<Case> resolvedCases = [ SELECT Id, Owner.Email, Owner.FirstName, Owner.LastName FROM Case WHERE Id IN :casesToMail ];
		
		Map<Id, Contact> caseId2contactId = new Map<Id, Contact>();
		
		for ( Case aCase : resolvedCases )
			caseId2contactId.put( aCase.Id, new Contact( FirstName = aCase.Owner.FirstName, LastName = aCase.Owner.LastName, Email = aCase.Owner.Email ) );

		try 
		{
			isInsertingTempContacts = true;
			insert caseId2contactId.values();
			
		} catch( System.Exception anEx ) {
			
			System.debug( System.Logginglevel.ERROR, anEx );
			return null;
		}
		
		return caseId2contactId;	
			
	}
	
	private static Boolean sendEmail(List<Case> casesWithNewOwners, String templateName, String orgWideEmailName )
	{
		EmailTemplate template;
		OrgWideEmailAddress orgWideEmail;
        
        try
        {
        	template = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = :templateName];
        	orgWideEmail = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE  DisplayName = :orgWideEmailName];
        }
        catch(System.Exception ex)
        {
        	//template or org wide email does not exist
        	System.debug(System.Logginglevel.ERROR, ex);
        	return false;
        }
		
		Map<Id, Contact> caseId2tempContacts = generateTempContacts( casesWithNewOwners );
		
		List<Messaging.SendEmailResult> sendResults;
		List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
		
		if ( caseId2tempContacts == null )
			return false;
		
		for(Case aCase : casesWithNewOwners)
		{
			Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
	        
	        emailMsg.setWhatId(aCase.Id);
	        emailMsg.setTemplateId(template.Id);
        	emailMsg.setTargetObjectId( caseId2tempContacts.get( aCase.Id ).Id );

        	emailMsg.setOrgWideEmailAddressId(orgWideEmail.Id);

//        	emailMsg.setReplyTo(aCase.Group_Inbox_Address__c);
        	System.debug(aCase.Group_Inbox_Address__c);
//        	emailMsg.setSenderDisplayName(aCase.Group_Inbox_Address__c);
        	emailMessages.add(emailMsg);
        	
        	System.debug('EMAIL MESSAGE:::');
        	System.debug(emailMsg);
		}
		//TODO: do we allow partial success
		try
		{
			sendResults = Messaging.sendEmail(emailMessages);
			
		}
		catch(Exception e)
		{
			System.debug(System.Logginglevel.ERROR, e);
			System.debug(System.Logginglevel.ERROR, sendResults);
			return false;
		}
		finally
		{
			delete caseId2tempContacts.values();
			isInsertingTempContacts = false;
		}
		
		for(Messaging.SendEmailResult sendResult : sendResults)
		{
			if(!sendResult.isSuccess())
			{
				//TODO: do something
				System.debug(System.Logginglevel.ERROR, sendResult.getErrors());
				return false;
			}
		}
		
		return true;
	}
}
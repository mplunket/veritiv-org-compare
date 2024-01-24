public class EmailMessageServices { 
	public final static String CASE_CRITICAL_PRIORITY = 'Critical';
	public final static String PRIORITY_KEY_PREFIX = 'X-Priority: '; 
	public final static String RETURN_PATH_PREFIX = 'Return-Path: ';
	public final static String EMPTY_RETURN_PATH = '<>';
	public final static String DUPLICATE_CONTACTS = 'duplicate contacts';
	public final static String CONTACT_NOT_FOUND = 'contact not found';
	public final static String INTERNAL_EMAIL = 'internal email';
	public final static String NEW_EMAIL_STATUS = '0';
	public final static String READ_EMAIL_STATUS = '1';
	public final static String REPLIED_EMAIL_STATUS = '2';
	public final static String SENT_EMAIL_STATUS = '3';
	//public final static String BATCH_ERROR_WARNING = '\n The batch has completed, but you should still double check your objects for any errors.';
	
	public final static Set<String> outOfOfficeStatuses = new Set<String> {'Vacation'}; 
	//Sujitha commented to remove FS Aduit Functionality Backlog#702
	/*public static Set<String> internalDomains {
		get{
			if(internalDomains == null){
				List<App_Domain_Restrictions__c> appDomainRestrictions = [SELECT Id, Domain__c FROM App_Domain_Restrictions__c];
				internalDomains = new Set<String>();
				for(App_Domain_Restrictions__c a : appDomainRestrictions)
				{
					internalDomains.add(a.Domain__c.toLowerCase());
				}
			}
			
			return internalDomains;
		}
	}*/
	
	public static Map<String, Email_Origins_E2C_Search_Contact__c> allEmailOriginsForSearchingContact {
		get {
			if(allEmailOriginsForSearchingContact==null)
			{
				allEmailOriginsForSearchingContact = new Map<String, Email_Origins_E2C_Search_Contact__c>();
				for(Email_Origins_E2C_Search_Contact__c e : Email_Origins_E2C_Search_Contact__c.getAll().values())
				{
					allEmailOriginsForSearchingContact.put(e.Email__c,e);
				} 
			}
			return allEmailOriginsForSearchingContact;
		}
	} 
	
	public static Set<String> allUFreightGroupBoxOrigins {
		get {
			if(allUFreightGroupBoxOrigins==null)
			{
				allUFreightGroupBoxOrigins = new Set<String>();
				for(UFreight_Groupbox__c e : UFreight_Groupbox__c.getAll().values())
				{
					allUFreightGroupBoxOrigins.add(e.Email_Address__c);
				} 
			}
			return allUFreightGroupBoxOrigins;
		}
	} 
	
	public static Set<String> importantEmailOrigins {
		get {
			if(importantEmailOrigins==null)
			{
				importantEmailOrigins = new Set<String>();
				importantEmailOrigins.addAll(allUFreightGroupBoxOrigins);
				importantEmailOrigins.addAll(allEmailOriginsForSearchingContact.keySet());
				importantEmailOrigins = toUpperCase(importantEmailOrigins);
			}
			return importantEmailOrigins;
		}
	}
	
	public static Set<String> toUpperCase(Set<String> aSet)
	{
		Set<String> retSet = new Set<String>();
		for(String s : aSet)
		{
			retSet.add(s.toUppercase());
		}
		return retSet;
	}
	
	public static Pattern freightSubjectPattern {
		get {
			if(freightSubjectPattern==null)
			{
				//freightSubjectPattern = Pattern.compile('((?:[Rr][Ee]:\\s*)|(?:[Ff][Ww][Dd]:\\s*))*\\b(\\d{5,})\\s+[Uu][Ll][Ss]\\s+([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4})\\s+\\b(\\d\\d/\\d\\d/\\d\\d)\\b.*');
				freightSubjectPattern = Pattern.compile('((?:[Rr][Ee]:\\s*)|(?:[Ff][Ww][Dd]:\\s*))*(\\b(?:[T][E][S][T])*(?:\\d{5,}))\\s+(?:(?:(?:\\w*)(?:\\s*))*)[-]([\\S\\s]+)[-]\\s+\\b(\\d\\d[/]\\d\\d[/]\\d\\d\\d\\d)\\b.*');
			}
			return freightSubjectPattern;
		}
	} 
	
	public static Pattern returnPathPattern {
		get {
			if(returnPathPattern==null)
			{
				returnPathPattern = Pattern.compile('(?:Return-Path: )(.*)');
			}
			return returnPathPattern;
		}
	}

	public static List<ID> errorEmailRecipients {
		get {
			if(errorEmailRecipients==null)
			{
				errorEmailRecipients = new List<ID>();
				for(Apex_Class_Error_Emails__c u : Apex_Class_Error_Emails__c.getAll().values())
					errorEmailRecipients.add(u.User_ID__c);
			}
			return errorEmailRecipients;
		}
	} 
	
	public static Set<String> qualifiedAddressSet {
 		get {
 		    if(qualifiedAddressSet == null) {
 		        qualifiedAddressSet  = new Set<String>();
 		        for (Qualified_Email_Addresses__c qualifiedAddress : Qualified_Email_Addresses__c.getall().values()){
 		            qualifiedAddressSet.add(qualifiedAddress.name.toUpperCase());
 		        }
 		    }
 		    return qualifiedAddressSet;
 		} set;
 	}
	
	/* Specify what priority email will cause us to set the case's priority to CASE_CRITICAL_PRIORITY*/
	public final static String EMAIL_CRITICAL_PRIORITY_NUMBER = '1';
	
	/*
	Given properly formatted headers of a email, return the priority of the email.
	Return null if the priority is not specified in the headers.
	*/
	public static String getPriorityOfEmail(String emailHeaders)
	{
		String[] splitByLine = emailHeaders.split('\n'); 
		for(String line : splitByLine)
		{
			if(line.startsWith(PRIORITY_KEY_PREFIX))
			{
				return line.substring(PRIORITY_KEY_PREFIX.length(),line.length());
			}
		}
		return null;
	}
	
	/*
	Given properly formatted headers of a email, return the return path of the email.
	Return null if the return path is not specified in the headers.
	*/
	public static String getReturnPath(String emailHeaders)
	{
		If(emailHeaders!=null)
		{
			Matcher m = returnPathPattern.matcher(emailHeaders);
			if(m.find() && m.groupCount()==1) {
				String value = m.group(1);
				if(!String.isBlank(value) && value!=EMPTY_RETURN_PATH)
					return value;
			}
		}
		return null;
	}
	
	/*
	Return all the cases of CaseServices.CASE_RECORD_TYPES that are associated with the specified emails. 
	*/
	public static List<Case> returnCasesFromEmails(List<EmailMessage> emails)
	{
		List<Id> parentCaseIds = new List<Id>();
		for(EmailMessage e : emails)
	 	{
			if( e.ParentId != null)
			{
				parentCaseIds.add(e.ParentId);
			}
	  	}
	  		
	  	return [select Id, AccountId, Subject, ContactId, RecordTypeId, Email_Origin__c, Routing_Error_Reason__c
	  				 from Case
	  				 where Id in :parentCaseIds
	  				  AND RecordType.DeveloperName in :CaseServices.CASE_RECORD_TYPES ];
	}
	 
	/*
	Given a list of email messages, return a map of the associated Case ID to the respecitve Email Message
	*/
	public static Map<ID, EmailMessage> createCaseIDToEmailMessageMap(List<EmailMessage> messages)
	{
		Map<Id, EmailMessage> caseIdToEmail = new Map<Id, EmailMessage>();
	
		for(EmailMessage e : messages)
		{
			if( e.ParentId != null)
			{
				caseIdToEmail.put(e.ParentId, e);
			}
		}
		return caseIdToEmail;
	}

	/* BW JK 8/15/14 
		Added filter functionality that further narrows down map
	*/
	@TestVisible static Map<Id, EmailMessage> getCaseIDToOnlyIncomingEmailMessageMap(Map<Id, EmailMessage> caseIdToEmail) {
		Map<Id, EmailMessage> filteredMap = new Map<Id, EmailMessage>();
		for (Id caseID : caseIdToEmail.keySet()) {
			EmailMessage emailM = caseIdToEmail.get(caseID);
			if (emailM.Incoming)
				filteredMap.put(caseID, emailM);
		}
		return filteredMap;
	}
	
	public static void makeCasePrioritiesCritical(List<Case> cases)
	{
		for(Case c : cases) {
			c.Priority = CASE_CRITICAL_PRIORITY;
		}
	}
	
	/*
	Given a list of cases, return those cases that have associated emails with a priority that begins with the EMAIL_CRITICAL_PRIORITY_NUMBER
	*/
	public static List<Case> filterCasesToSetCriticalPriority(List<Case> cases, Map<Id,EmailMessage> caseIdToEmail)
	{
		List<Case> casesToRet = new List<Case>();
		for(Case c : cases) { 
	            
	        EmailMessage e = caseIdToEmail.get(c.Id);
		  	if(e.Headers!=null)
		  	{
		  		String priority = getPriorityOfEmail(e.Headers);
		  		if(!String.isBlank(priority) && priority.startsWith(EMAIL_CRITICAL_PRIORITY_NUMBER))
		  			casesToRet.add(c);
		  	}
		}
		return casesToRet;
	}
	
	/*
	  Return those cases that have an email in Email_Origin__c that is listed in the 
	  'UFreight Groupbox' custom setting
	  
	  Preconditions:
			1) The Email Origin field is formatted as such:
				a) All email address specified in the email origin field are delimited by a semicolon. 
				b) The last character of the email origin field is a semicolon.
	*/
	public static List<Case> filterCasesFromFreightGroupbox(List<Case> cases)
	{
		return casesWithQualifyingEmailInEmailOrigin(cases, allUFreightGroupBoxOrigins);
	}
	
	/*
	Given a list of cases, return those cases that contain a qualifying email address stored in the Email_Origin__c field.
	An email address is consider qualifying if it has been listed in the 'Email Origins to Search for Contact' custom setting.
		Preconditions:
			1) The Email Origin field is formatted as such:
				a) All email address specified in the email origin field are delimited by a semicolon. 
				b) The last character of the email origin field is a semicolon.
	*/
	public static List<Case> filterCasesToSearchForContacts(List<Case> cases)
	{
		return casesWithQualifyingEmailInEmailOrigin(cases, allEmailOriginsForSearchingContact.keySet());
	}
	
	/*
	Return those cases that have no error specified in the field Routing_Error_Reason__c 
	*/
	public static List<Case> filterCasesWithoutRoutingErrors(List<Case> cases)
	{   
		List<Case> filteredCases = new List<Case>();
		
		for(Case c: cases)
		{
			if(String.isBlank(c.Routing_Error_Reason__c))
			{
				filteredCases.add(c);
			}
		}
		return filteredCases;
	}
	
	/*
	  Return those cases that have an email in Email_Origin__c that is listed in the 
	  'Email Origins to Search for Contact' custom setting with the 'Assign AM/BM' checked.
		  
		  Preconditions:
				1) The Email Origin field is formatted as such:
					a) All email address specified in the email origin field are delimited by a semicolon. 
					b) The last character of the email origin field is a semicolon.
		*/
		public static List<Case> filterCasesToAssignAMBM(List<Case> cases)
		{
		    Set<String> AMBMEmailOrigins = new Set<String>();
		   	for(String qualifyingEmailOrigin: allEmailOriginsForSearchingContact.keySet())
			{
				if(allEmailOriginsForSearchingContact.get(qualifyingEmailOrigin).Assign_AM_BM__c)
				{
									
					
					AMBMEmailOrigins.add(qualifyingEmailOrigin);
				}
			}
			
			System.debug('CUSTOMDEBUG: Email Origins for AM BM: ' + AMBMEmailOrigins);
	
			return casesWithQualifyingEmailInEmailOrigin(cases, AMBMEmailOrigins);
		}
		
		/*
		Return those cases that have at least one qualifying email in Email_Origin__c.
		Specify all qualifying emails in qualifyingEmails.
		
		Preconditions:
				1) The Email Origin field is formatted as such:
					a) All email address specified in the email origin field are delimited by a semicolon. 
					b) The last character of the email origin field is a semicolon.
		*/
		private static List<Case> casesWithQualifyingEmailInEmailOrigin(List<Case> cases, Set<String> qualifyingEmails)
		{
			List<Case> qualifyingEmailCases = new List<Case>();
			for(Case c:cases)
			{
				if(c.Email_Origin__c!=null)
				{
					Set<String> emailOrigins = splitAndTrimEmailOrigins(c.Email_Origin__c.toUpperCase());
					for(String qualifyingEmailOrigin: qualifyingEmails)
					{
						if(emailOrigins.contains(qualifyingEmailOrigin.toUpperCase()))
						{
							qualifyingEmailCases.add(c);
							break;
						} 
					} 
				}
			}
			return qualifyingEmailCases; 
		}
		
		private static Set<String> splitAndTrimEmailOrigins(String str)
		{
			List<String> splitStrings = str.split(';');
			Set<String> retSet = new Set<String>();
			for(String split : splitStrings)
			{
				retSet.add(split.trim());
			}
			return retSet;
		}
		
		/*
		  For each specified case, if there is an account manager, assign the case to the account manager if 
		  the account manager is not out of office. Otherwise, if there is a backup manager, assign to the backup 
		  manager if the backup manager is not out of office. Otherwise, do not change owner.
		  
		  Return the list of cases to change owner.
		  
		  Preconditions
		       1) Every case must have a contact that has an account
		*/ 
		public static List<Case> assignAMBM(List<Case> cases)
		{
			Set<ID> relevantAccounts = Pluck.ids('AccountID', cases);
			
			Map<ID, Account> accounts = new Map<ID, Account>([Select ID, Name, Account_Manager__c, Account_Manager_Backup__c, 
															  Account_Manager__r.SF_userid__c, 
															  Account_Manager__r.SF_userid__r.Working_Status__c,
															  Account_Manager__r.SF_userid__r.isActive, 
															  Account_Manager_Backup__r.SF_userid__c, 
															  Account_Manager_Backup__r.SF_userid__r.Working_Status__c,
															  Account_Manager_Backup__r.SF_userid__r.isActive
															  From Account Where ID IN: relevantAccounts]);
			
			List<Case> casesToUpdate = new List<Case>();
			
			for(Case c : cases)
			{
				System.debug('CUSTOMDEBUG: Going through assignambm');
				System.debug('CUSTOMDEBUG: Case: ' + c);
				Account caseAcct = accounts.get(c.AccountID);
				
				System.debug('CUSTOMDEBUG: Case Account Details: ' + caseAcct + ';' + caseAcct.Account_Manager__r.SF_userid__r.Working_Status__c+';'+caseAcct.Account_Manager_Backup__r.SF_userid__r.Working_Status__c);
				
				if(caseAcct.Account_Manager__c!=null && caseAcct.Account_Manager__r.SF_userid__r.isActive && !outOfOfficeStatuses.contains(caseAcct.Account_Manager__r.SF_userid__r.Working_Status__c))
				{ 
					c.OwnerID = caseAcct.Account_Manager__r.SF_userid__c;
					casesToUpdate.add(c);
				}
				else if(caseAcct.Account_Manager_Backup__c!=null && caseAcct.Account_Manager_Backup__r.SF_userid__r.isActive &&!outOfOfficeStatuses.contains(caseAcct.Account_Manager_Backup__r.SF_userid__r.Working_Status__c))
				{
					c.OwnerID = caseAcct.Account_Manager_Backup__r.SF_userid__c;
					casesToUpdate.add(c);
				}
			}
			
			return casesToUpdate;
		}
		
		/*
		Return only those cases which don't meet the following criteria:
			1) The subject line includes "RE:" or "FWD:" and body contains "ref:_" 
			2) The subject line is NULL or empty
		*/
		public static List<Case> filterCasesToParse(List<Case> cases, Map<Id,EmailMessage> caseIdToEmail)
		{
			List<Case> qualifyingCases = new List<Case>();
	
			for(Case c: cases) {
				EmailMessage email = caseIdToEmail.get(c.id);
				// Check if email is not qualifying: Response emails with "ref:_" in TextBody
				if (!String.isBlank(email.Subject)) {
					String subjectToCheck = email.Subject.toUpperCase();
					if(subjectToCheck.startsWith('RE:') || subjectToCheck.startsWith('FWD:')) {
						if (email.TextBody == null) {
							qualifyingCases.add(c);
						} else {
							String bodyToCheck = email.TextBody.toUpperCase();
							if(!bodyToCheck.contains('REF:_')) // 1/2 qualifying case
								qualifyingCases.add(c);
						}
					} else qualifyingCases.add(c); // 2/2 qualifying case
				}
			}
	
			return qualifyingCases;
		}
		
		/*
		For each case specified in cases:
		If there is a contact that matches the from address of the email associated with the case, then we will populate that contact on the case.
			If there are multiple contacts, we will set the Routing_Error_Reason__c picklist to duplicate contacts. 
			If there are no contacts, we will set the the Routing_Error_Reason__c picklist to contact not found.
		*/
		public static void populateContactLookupsOnCases(Map<String,List<Contact>> emailsToContacts, List<Case> cases, Map<Id,EmailMessage> caseIdToEmail)
		{
			for(Case c: cases)
			{
				EmailMessage em = caseIdToEmail.get(c.id);
				if (em != null) {
					String fromEmail = em.fromAddress;
					if(emailsToContacts.get(fromEmail).size()== 0)
					{
						c.AccountID = null;
						c.ContactID = null;
						c.Routing_Error_Reason__c = CONTACT_NOT_FOUND;
					}
					
					else if (emailsToContacts.get(fromEmail).size()== 1)
					{
						c.AccountId = emailsToContacts.get(fromEmail)[0].AccountID;
						c.contactId = emailsToContacts.get(fromEmail)[0].Id;
					}	
			        else
			        {
			        	c.AccountID = null;
						c.ContactID = null;
			        	c.Routing_Error_Reason__c = DUPLICATE_CONTACTS;
			        }
			    }
			}
			
		}
		
		/*
		For each specificed email, find all the ULS contacts that have the matching email.
		A ULS contact is a contact has is linked to an account which is a ULS account.
		*/
		public static Map<String,List<Contact>> findAllContactsForEmails(Set<String> emails)
		{
			List<Contact> contacts = [Select id, Email, AccountID from Contact where Email in: emails AND Account.Is_ULS_Primary_Acct__c = TRUE];
			Map<String,List<Contact>> contactEmails = new Map<String,List<Contact>>();
			for(String email : emails)
			{
				contactEmails.put(email, new List<Contact>());
			}
			for(Contact c: contacts)
			{
			     if (contactEmails.containsKey(c.email)){
			      	contactEmails.get(c.email).add(c);
			     }
			}
			
			return contactEmails; 
		}
		
		public static Set<String> extractFromAddresses(List<EmailMessage> emails)
		{
			return Pluck.strings('FromAddress', emails);
		}
		
		/*
		Given a list of cases, return those cases in which the Email_Origin__c field is not populated
		*/
		public static List<Case> filterCasesToPopulateEmailOrigins(List<Case> cases)
		{
			List<Case> casesToRet = new List<Case>();
			for(Case c : cases) { 
		            
			  	if(c.Email_Origin__c == null || c.Email_Origin__c == '') {
			  		casesToRet.add(c);
			  	}
			}
			return casesToRet;
		}

		/**
		 * For the filtered cases with from address as null, copy the FromAddress of the respective email message 
		 *	into the From_Address_of_Originating_Email__c field on the case
		 * @param cases the given cases
		 * @param caseIdToEmail a map from the case ID to the respective email message
		 * @precondition every case in cases has an associated email message in caseIdToEmail
		 */
		public static void stampFromAddress(List<Case> cases, Map<Id, EmailMessage> caseIdToEmail)
		{
			for(Case eachCase : cases)
			{
				eachCase.From_Address_of_Originating_Email__c = caseIdToEmail.get(eachCase.Id).FromAddress;
			}
		}

		public static Boolean doesEmailAddressQualify(String anAddy)
 		{
 			for(String address : qualifiedAddressSet ) {
 			    if(anAddy.contains(address)){
 		    	    return true;
 			    }
 			}
 			return false;
 		}
		
		public static void populateEmailOrigins(List<Case> cases, Map<Id,EmailMessage> caseIdToEmail)
		{
			Schema.DescribeFieldResult describe = Case.Email_Origin__c.getDescribe();
		    Integer maxLength = describe.getLength();
            //code change to add SS record Type Condition
            Id salesSupportRecId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Support').getRecordTypeId();
            
            for(Case c : cases) { 
                
                EmailMessage e = caseIdToEmail.get(c.Id);
			    System.debug('CUSTOMDEBUG: Actual Email: ' + e);    
				String emailOrigin = '';
			            
				Set<String> everyEmailAddy = new Set<String>();
			            
				if ( e.ToAddress != null )
			    	everyEmailAddy.addAll( e.ToAddress.deleteWhitespace().toUpperCase().split( ';' ) );
			            
			    if ( e.CcAddress != null )
			    	everyEmailAddy.addAll( e.CcAddress.deleteWhitespace().toUpperCase().split( ';' ) );
			      
			    List<String> importantEmailOriginsForThisCase = new List<String>();
			    List<String> normalEmailOriginsForThisCase = new List<String>();
			     System.debug(LoggingLevel.ERROR, 'ImpOrigins' + importantEmailOrigins);   
			    
			    for ( String anAddy : everyEmailAddy ) { 
			    	if(importantEmailOrigins.contains(anAddy))
			    	{
			    		importantEmailOriginsForThisCase.add(anAddy);
			    	}
			    	else if ( doesEmailAddressQualify(anAddy) )
			    	{
			    		normalEmailOriginsForThisCase.add(anAddy);
			    	}
		        }
		        
		        String returnPath = getReturnPath(e.Headers);
		        
		        emailOrigin = (returnPath!=null?returnPath.toUpperCase()+';':'') + String.join(importantEmailOriginsForThisCase,';') 
		        			  + (importantEmailOriginsForThisCase.size()>0 && normalEmailOriginsForThisCase.size()>0?';':'') 
		        			  + String.join(normalEmailOriginsForThisCase,';');
			            
			    if(emailOrigin.length() > maxLength-1)
			    	emailOrigin = emailOrigin.substring(0, maxLength-1);
			            
			    c.Email_Origin__c = emailOrigin;
                
                if( c.recordTypeId != salesSupportRecId){
                    c.AccountId = null;
                }

                
			   
			    c.ContactId = null; 
			}
	}
	
	public static void sendBatchCompletedEmail(List<String> errors,String batchName)
	{ 
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
				
		for(Id usId : errorEmailRecipients){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTargetObjectId(usId);
			mail.saveAsActivity = false;
						
			mail.setSubject('Batch Response');
			
			String emailBody = 'The batch has completed: '+ batchName + '.\n';
			emailBody += Label.Apex_Batch_Email_Message; 
			/*
			if(!errors.isEmpty()){
				emailBody += '\nThese are the errors: \n';
				for(String err: errors){
				   emailBody += err + '.\n';
				}
			}
			*/
			mail.setPlainTextBody( emailBody ); 
			emails.add(mail);
		}
			
		if(!emails.isEmpty())
			Messaging.sendEmail( emails );
		
	
	}

	public static void sendErrorEmail(String errorBody)
	{ 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses( new String[] {'james.dadouris@bluewolfgroup.com','krishna.kollu@bluewolfgroup.com'} );
		mail.setSubject('Error When Processing Email Messages With Related Cases');

		String emailBody = 'These are the errors:  \n\n\n' + errorBody;

		mail.setPlainTextBody( emailBody );
		Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
	}
	
	/*
	Mark the specified cases as having their Owner Assigned By Code 
	*/
	public static void setOwnerAssignedByCode(List<Case> cases)
	{
		for(Case c : cases)
		{
			c.Owner_Assigned_by_Code__c = true;
		}	
	}
	
	
	@TestVisible private static String updateCasesAndReturnErrorsIfAny(Set<ID> casesToUpdate, List<Case> cases)
	{
	  if(!casesToUpdate.isEmpty()) 
	  {
	  	List<Case> listCasesToUpdate = new List<Case>();
	  	for(Case c : cases)
	  	{
	  		if(casesToUpdate.contains(c.ID))
	  		{
	  			listCasesToUpdate.add(c);
	  		}
	  	}
	  
	  	//Update the above cases and send an error message with any cases that failed to update if there were errors
	  	Database.DMLOptions useDefaultRuleOption = new Database.DMLOptions();
		useDefaultRuleOption.AssignmentRuleHeader.useDefaultRule = true;
		useDefaultRuleOption.optAllOrNone=false;
		
	  	BatchServices.DatabaseResults saveResults = new BatchServices.DatabaseResults(Database.update( listCasesToUpdate, useDefaultRuleOption ));
		return BatchServices.getDMLErrorString(saveResults,listCasesToUpdate);
	  }
	  return '';
	}
	
	private static Map<String, Case> parentsOfResponseCases(List<Case> rCases) {
		List<String> orderNumbers = new List<String>();
		for (Case c : rCases) orderNumbers.add(c.Order_Number__c);
		List<Case> parentCases = [Select Id, Order_Number__c From Case Where Order_Number__c in :orderNumbers AND ParentID = null];

		Map<String, Case> parentCaseMap = new Map<String, Case>();
		for (Case c : parentCases) {
			parentCaseMap.put(c.Order_Number__c, c);
		}
		return parentCaseMap;
	}
 
	/**
	* Parse the subject lines of the emails associated with the specified cases.
	* Furthermore, for any response cases, if there is a master case in the system with the same order#, set that case as its parent.
	* Return only those cases that need to be updated.
	* 
	* A case will only be returned if the associated email subject is specified as such:
	*     1) It contains: "Order# ULSSenderEmail DateOfShipment" 
	*        where Order# is a number, ULSSenderEmail is an email, DateOfShipment is a date MM/DD/YY.
	*     2) It can be preceded by any number of "RE: " or "FWD: "
	*     3) It can be preceded by leading spaces, and completed by trailing spaces.
	*		 There can be any number of spaces between fields,i.e. multiple spaces between Order# and ULSSenderEmail
	*/
	public static List<Case> parseFreightSubjects(List<Case> cases, Map<Id,EmailMessage> caseIdToEmail)
	{
		List<Case> casesParsed = new List<Case>();
		List<Case> responseCases = new List<Case>();
		for(Case c : cases)
		{
			Matcher m = freightSubjectPattern.matcher(caseIdToEmail.get(c.Id).Subject);
			if(m.matches() && m.groupCount()==4) {
				if (!String.isEmpty(m.group(1))) 
					responseCases.add(c);
				if (m.group(2).startsWith('TEST'))
					c.Order_Number__c = m.group(2).substring(4);
				else c.Order_Number__c = m.group(2);
				//c.Sender_s_Email__c = m.group(3);
				c.Delivery_Date__c = Date.parse(m.group(4));
				casesParsed.add(c);
			}
		}
		Map<String, Case> parentCaseMap = parentsOfResponseCases(responseCases);
		for (Case rc : responseCases) {
			Case possibleParent = parentCaseMap.get(rc.Order_Number__c);
			if (possibleParent != null) {
				rc.ParentId = possibleParent.Id;
			}
		}
		return casesParsed;
	}
	
	public static void processEmailMessagesBeforeInsert(List<EmailMessage> emailMessages)
	{
	  ErrorHandling.ErrorLog trackErrorLog = new ErrorHandling.ErrorLog();
	  try
	  {
		  SafeDML casesToUpdate = new SafeUpdate();	
		  
		  List<Case> cases = returnCasesFromEmails(Trigger.new);
		  Map<Id, EmailMessage> caseIdToEmail = createCaseIDToEmailMessageMap(Trigger.new);
		  	  
		  List<Case> casesToPopulateEmailOrigins = filterCasesToPopulateEmailOrigins(cases);
		  if(!casesToPopulateEmailOrigins.isEmpty()) 
		  {
		  	stampFromAddress(casesToPopulateEmailOrigins, caseIdToEmail);
		  	populateEmailOrigins(casesToPopulateEmailOrigins, caseIdToEmail); 
		  	casesToUpdate.queue(casesToPopulateEmailOrigins, trackErrorLog);
		  }	  
		  //Sujitha commented to remove FS Aduit Functionality Backlog#702
		  //List<Case> casesToFlagAsInternalEmail = filterInternalCases(cases, caseIdToEmail);
		//  List<Case> casesToNotFlagAsInternalEmail = filterExternalCases(cases, casesToFlagAsInternalEmail);
		  
		/*  if(!casesToFlagAsInternalEmail.isEmpty())
		  {
		      flagAsInternalEmail(casesToFlagAsInternalEmail);
		  }
		  */
		 // List<Case> casesToPopulateContacts = filterCasesToSearchForContacts(casesToNotFlagAsInternalEmail);
		 /* if(!casesToPopulateContacts.isEmpty()) 
		  {
		  	 Map<String, List<Contact>> emailToContacts = findAllContactsForEmails(extractFromAddresses(caseIdToEmail.values()));
		  	 populateContactLookupsOnCases(emailToContacts,casesToPopulateContacts,getCaseIDToOnlyIncomingEmailMessageMap(caseIdToEmail));
		  	 casesToUpdate.queue(casesToPopulateContacts, trackErrorLog);
		  	 
		  	 List<Case> casesWithContactsPopulated = filterCasesWithoutRoutingErrors(casesToPopulateContacts);
		  	 List<Case> casesToAssignAMBM = filterCasesToAssignAMBM(casesWithContactsPopulated);
		  	 List<Case> casesWhereValidAMOrBMAssigned = assignAMBM(casesToAssignAMBM);
		  	 setOwnerAssignedByCode(casesWhereValidAMOrBMAssigned);
		  }*/
		  		  //End of Comment
		  List<Case> casesToSetCriticalPriority = filterCasesToSetCriticalPriority(cases, caseIdToEmail);
		  if(!casesToSetCriticalPriority.isEmpty()) 
		  {
		  	makeCasePrioritiesCritical(casesToSetCriticalPriority); 
		  	casesToUpdate.queue(casesToSetCriticalPriority, trackErrorLog);
		  }
		  
		  List<Case> casesToParseFreightSubject = filterCasesToParse(filterCasesFromFreightGroupbox(cases),caseIdToEmail);
		  if(!casesToParseFreightSubject.isEmpty())
		  {
		  	List<Case> parsedCases = parseFreightSubjects(casesToParseFreightSubject,caseIdToEmail);
		  	casesToUpdate.queue(parsedCases, trackErrorLog);
		  }
		  
		  casesToUpdate.doDml(false);
	  }
	  catch(Exception e)
	  {
	  	trackErrorLog.trackNonDMLException(e);
	  }
	  finally
	  {
	  	if(trackErrorLog.areThereErrors()) 
	  		trackErrorLog.emailLog(errorEmailRecipients, 'E2C Errors');
	  }
	}
	//Sujitha commented to remove FS Aduit Functionality Backlog#702
	/*public static Boolean isInternalEmailDomain(String email){
		
		if(email==null) return false;
		
		List<String> spiltEmail = email.split('@');
		
		if(internalDomains.contains(spiltEmail[1])){
			return true;
		}
		else return false;
	}*/
	
	public static void flagAsInternalEmail(List<Case> cases)
	{
		for(Case c : cases)
		{
			c.Routing_Error_Reason__c = INTERNAL_EMAIL;
		}
	}
	
	/*
	 * given a list of cases and a map of Id to email message, returns the list of internal cases
	*/
    //Sujitha commented to remove FS Aduit Functionality Backlog#702
	/*public static List<Case> filterInternalCases(List<Case> cases, Map<Id, EmailMessage> caseIdToEmail){
		List<Case> filteredInternalCases = new List<Case>();
		
		for(Case cs: cases){
			if(isInternalEmailDomain(caseIdToEmail.get(cs.Id).FromAddress)){
				filteredInternalCases.add(cs);
			}
		}
		
		return filteredInternalCases;
	}*/
	
	public static List<Case> filterExternalCases(List<Case> allCases, List<Case> internalCases)
	{
		Set<ID> internalCaseIDs = Pluck.ids(internalCases);
		List<Case> externalCases = new List<Case>();
		for(Case c : allCases)
		{
			if(!internalCaseIDs.contains(c.ID))
			{
				externalCases.add(c);
			}
		}
		return externalCases;
	}

	public static void processCaseFirstEmailResponseTracking( List<EmailMessage> emailMessageList ){
		Map<Id,EmailMessage> originalEmailMessageMap = new Map<Id,EmailMessage>([
			SELECT Id, ParentId, CreatedDate 
			FROM EmailMessage 
			WHERE Id IN : PLuck.ids('ReplyToEmailMessageId',emailMessageList) 
					AND Incoming = true
		]);
		List<EmailMessage> repliedEmails = new List<EmailMessage>();
		List<Case_Durations__c> durations = new List<Case_Durations__c>();
		Set<Id> relatedCaseIds = new Set<Id>();
		for(EmailMessage email: emailMessageList){
			EmailMessage originalMessage = originalEmailMessageMap.get(email.ReplyToEmailMessageId);
			if(email.Status == EmailMessageServices.SENT_EMAIL_STATUS
				&& originalMessage != null 
				&& originalMessage.ParentId != null 
				&& originalMessage.ParentId.getSobjectType() == Case.SobjectType
			){
				relatedCaseIds.add(email.ParentId);
				repliedEmails.add(originalMessage);
			}
		}
		Map<Id, Case> relatedCaseMap = new Map<Id, Case>([
			SELECT Id, Status,
				(SELECT Id 
				FROM Case_Durations__r 
				WHERE Type__c =: CaseResponseTrackingServices.FIRST_EMAIL_RESPONSE LIMIT 1) 
			FROM Case 
			WHERE Id IN :relatedCaseIds
		]);

		Datetime currentTime = System.now();
		for(EmailMessage email : repliedEmails){
			Case relatedCase = relatedCaseMap.get(email.ParentId);
			//if we have a case record without a first email response tracking, create one
			if(relatedCase != null && relatedCase.Case_Durations__r.isEmpty()){
				durations.add(new Case_Durations__c(
					Parent__c = email.ParentId,
					From__c = email.CreatedDate,
					Until__c = currentTime,
					Status__c = relatedCase.Status,
					Type__c = CaseResponseTrackingServices.FIRST_EMAIL_RESPONSE,
					Value__c = email.Id
				));
			}
		}
		CaseResponseTrackingServices.insertCaseDurations(durations);
	}
}
global class CaseVacationEmailService implements Messaging.InboundEmailHandler {

	public static Boolean isRunning = false;

	private final String USER_PREFIX = Schema.SObjectType.User.getKeyPrefix();
	private final String CASE_ASSIGNMENT_EMAIL_ADDRESS = 'sfcasereply@unisourceworldwide.com';
	private final String CASE_ASSIGNMENT_TEMPLATE_NAME = 'Alert_Last_Assigner_of_OOO';

	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
	{
		isRunning = true;
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

		System.debug(email.plainTextBody);
        
		String caseNum = CaseVacationEmailService.parseCaseNumberFromSubject(email.subject);

		if(caseNum == '')
		{
			// @TODO: send email to admin
			return null;
		}

		Case targetCase;
		try
		{
			targetCase = [ SELECT Id, CaseNumber, OwnerId, Owner.Email, Owner.Name,
								Previous_Owner_ID__c, Last_Assigner__c, RecordTypeId, Override_Outlook_Auto_Response__c
							FROM Case
							WHERE CaseNumber = :caseNum ];
		}
		catch(System.Exception ex)
		{
			// @TODO: send email to admin
		}

		setOwnerOutOfOffice( targetCase.OwnerId );

		// get the fax to case record types
		Set<Id> faxToCaseRecordTypesSet = CaseModel.getRecordTypesIntoSet( CaseServices.CASE_RECORD_TYPES );

		// check if the outlook auto response should be overidden
		if (!targetCase.Override_Outlook_Auto_Response__c) {

			// if a the case has a fax to case record type
			if ( faxToCaseRecordTypesSet.contains( targetCase.RecordTypeId ) )
			{
				if ( targetCase.Previous_Owner_ID__c != null )
				{
					targetCase.Previous_Case_Owner_ID__c = targetCase.OwnerId;

					targetCase.Previous_Case_Owner_Name__c = targetCase.Owner.Name;

					targetCase.OwnerId = targetCase.Previous_Owner_ID__c;

					try
					{
						update targetCase;
					}
					catch( Exception ex )
					{
						System.debug( ex.getMessage() );
						// @TODO: send email to admin
					}
				}
			}
			// send an email to the previous assigner instead of setting the previous owner
			//else if( CaseServices.eBusiness_RecordType_Id != null && targetCase.RecordTypeId != CaseServices.eBusiness_RecordType_Id )
			else //if( label.eBusinessRT != null && targetCase.RecordTypeId != label.eBusinessRT )
            {
				List<OrgWideEmailAddress> caseAssignmentOrgWideAddress = [ SELECT Id FROM OrgWideEmailAddress WHERE Address = :CASE_ASSIGNMENT_EMAIL_ADDRESS LIMIT 1 ];
				List<EmailTemplate> caseAssignmentTemplate = [ SELECT Id FROM EmailTemplate WHERE DeveloperName = :CASE_ASSIGNMENT_TEMPLATE_NAME LIMIT 1 ];

				if( !caseAssignmentTemplate.isEmpty() && !caseAssignmentOrgWideAddress.isEmpty() )
				{
					Messaging.SingleEmailMessage emailToAssigner = new Messaging.SingleEmailMessage();

					//emailToAssigner.setToAddresses( new List<String>{ targetCase.Owner.Email } );
					//emailToAssigner.setSubject( 'NOTICE: Assignee of Case #' + targetCase.CaseNumber + ' is out of office' );
					//emailToAssigner.setPlainTextBody( 'Case owner ' + targetCase.Owner.Name + ' is out of office. Please reassign case as necessary.' );

					emailToAssigner.setTemplateId( caseAssignmentTemplate[0].Id );
					emailToAssigner.setTargetObjectId( targetCase.Last_Assigner__c );
					emailToAssigner.setWhatId( targetCase.Id );

					emailToAssigner.setOrgWideEmailAddressId( caseAssignmentOrgWideAddress[0].Id );
					emailToAssigner.setSaveAsActivity( false );

					Messaging.sendEmail( new List<Messaging.SingleEmailMessage>{ emailToAssigner } );
				}
			}
		}
		else {

			// resets the override for the case

			targetCase.Override_Outlook_Auto_Response__c = false;

			try
			{
				update targetCase;
			}
			catch( Exception ex )
			{
				System.debug( ex.getMessage() );
				// @TODO: send email to admin
			}
		}

		return result;
	}

	//
	//   Out of  Office: re: Case: 1234234545 has been assigned to you
	//

	public static String parseCaseNumberFromSubject(String subject)
	{
		//strip out new lines
		subject = subject.replaceAll('\r', '');
		subject = subject.replaceAll('\n', '');

		System.debug('::SUBJECT:::'+ subject);
		Pattern caseNumberPattern = Pattern.compile('^.*Case: ([0-9]{8,}).*');

		Matcher matchResult = caseNumberPattern.matcher(subject.trim());

		if(matchResult.matches())
		{
			System.debug(matchResult.group(0));
			System.debug(matchResult.group(1));

			return matchResult.group(1);
		}
		else
		{
			System.debug('NO CASE # MATCHED');
			return '';
		}
	}

	public static void sendErrorNotification(Messaging.InboundEmail email, String message)
	{
		String toAddresses = Fax_To_Case_Queue_Backups__c.getInstance().Alert_Emails__c;
	}

	private void setOwnerOutOfOffice( Id caseOwnerId )
	{
		String ownerPrefix = String.valueOf( caseOwnerId ).substring(0, 3);

		// if owner is a user, make sure the user's working status is set properly
		if( ownerPrefix == USER_PREFIX )
		{
			List<User> caseOwner = [ SELECT Id FROM User WHERE Id = :caseOwnerId AND Working_Status__c not in :CaseServices.OOO_STATUSES ];

			if( !caseOwner.isEmpty() )
			{
				caseOwner[0].Working_Status__c = CaseServices.RECEIVED_CASE_WHILE_OUT_STATUS;
				try
				{
					update caseOwner;
				}
				catch( System.Exception ex )
				{
					// @TODO: send email to admin
				}
			}
		}
	}

}
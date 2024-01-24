public with sharing class ChangeCaseOwnerControllerExt {

	public static final String OUT_OF_OFFICE_USER_MESG = 'NOTE: User\'s Working Status is currently - ';
	public final String USER_PREFIX = Schema.SObjectType.User.getKeyPrefix();

	public Case changeOwnerCase {get; set;}
	public Boolean overrideUserStatus {get; set;}
	public Boolean failedSave {get; private set;}

	private ApexPages.StandardController stdController {get; set;}

	public ChangeCaseOwnerControllerExt( ApexPages.StandardController stdController ){

		this.stdController = stdController;
		changeOwnerCase = (Case)stdController.getRecord();
		failedSave = false;
		overrideUserStatus = false;

	}

	public ApexPages.PageReference beforeSave(){

		if( String.valueOf( changeOwnerCase.OwnerId ).substring( 0, 3 ) == USER_PREFIX
			&& !( CaseServices.eBusiness_RecordType_Id != null && changeOwnerCase.RecordTypeId == CaseServices.eBusiness_RecordType_Id ) ){

			User newOwner = [ SELECT Id, Working_Status__c FROM User WHERE Id = :changeOwnerCase.OwnerId AND IsActive = true ];

			if( !overrideUserStatus && newOwner.Working_Status__c != null && newOwner.Working_Status__c != CaseServices.IN_OFFICE_STATUS ){

				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, OUT_OF_OFFICE_USER_MESG + newOwner.Working_Status__c ) );
				failedSave = true;
				return null;

			}
		}

		changeOwnerCase.Last_Assigner__c = UserInfo.getUserId();

		if (overrideUserStatus) {
			changeOwnerCase.Override_Outlook_Auto_Response__c = true;
		}

		return stdController.save();

	}

}
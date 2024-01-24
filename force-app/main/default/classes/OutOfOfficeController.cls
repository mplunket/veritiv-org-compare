public class OutOfOfficeController
{
	public User targetUser {get; set;}
	public Boolean hasErrors {get; private set;}

	public List<SelectOption> workingStatuses { get; private set; }
	public String selectedWorkingStatus { get; set; }

	public static String ERROR_MESSAGE = 'An error has occured while updating your status.  Please contact your administrator.';
		
	public OutOfOfficeController()
	{
		targetUser = [ SELECT Working_Status__c FROM User WHERE Id = :UserInfo.getUserId() ];
		selectedWorkingStatus = targetUser.Working_Status__c;

		hasErrors = false;
		
		workingStatuses = new List<SelectOption>();
		
		List<Schema.PicklistEntry> workingStatusPicklist = User.Working_Status__c.getDescribe().getPicklistValues();
		
		for( Schema.PicklistEntry statusEntry : workingStatusPicklist )
		{
			workingStatuses.add( new SelectOption( statusEntry.getValue(), statusEntry.getLabel() ) );
		}
	}
	
	public void toggle()
	{
		if( targetUser.Working_Status__c != selectedWorkingStatus )
		{
			try
			{
				targetUser.Working_Status__c = selectedWorkingStatus;
				update targetUser;
				
				//Checking if selected picklist value has posted and updated User record, related to sporadic IE issues
				if( targetUser.Working_Status__c != selectedWorkingStatus)
					{
						ERROR_MESSAGE = 'There is a mismatch on your Working Status, please click the link in the sidebar "Send an Email" enter the error and send so that a SFDC admin can help you. Thank you.';
						ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ERROR_MESSAGE));
					}
			}
			catch( System.Exception ex )
			{
				hasErrors = true;
				System.debug(ex.getMessage());
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ERROR_MESSAGE ) );
			}
		}
	}
}
public with sharing class FileAttachmentController
{
	public static final String FILE_ATTACHMENT_ERROR = 'Unable to attach file. Please contact your System Administrator';
	public static final String FILE_ATTACHMENT_SUCCESS = 'Attachment Successfully Added' ;

	public Attachment attachment { get; set; }
	public Contract contract { get; set; }
	public Id existingContractId { get; set; }
	public Id existingAttachmentId { get; set; }
	public Id opportunityId { get; set; }
	public Id accountId { get; set; }
	public Id divisionId { get; set; }
	public String attachType { get; set; }
	
	public FileAttachmentController()
	{ 
		initializeAttachment();
	}

	public void attachFile()
	{
		if( null == attachment.Body || null == attachment.Name )
		{
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, FILE_ATTACHMENT_ERROR ) );
			initializeAttachment();
			return;
		}
		SavePoint sp = Database.setSavepoint();
		try
		{
			createContract();
			createAttachment();
		}
		catch ( Exception ex )
		{
			ApexPages.addMessages(ex);
			Database.rollback( sp );
			return;
		}
		ApexPages.addMessage( new ApexPages.Message ( ApexPages.Severity.CONFIRM, FILE_ATTACHMENT_SUCCESS ));
		initializeAttachment();
	}
	
	private void buildContract()
	{
		contract.Division__c = divisionId;
		contract.AccountId = accountId;
		contract.Document_Type__c = attachType;
		System.debug(attachType + ';' + ContractFileManagementCtrl.valid_contract_doc_types);
		if(ContractFileManagementCtrl.valid_contract_doc_types.get( attachType ).File_Varies_by_Opp__c == ContractFileManagementCtrl.FILE_ON_OPPORTUNITY )
		{ 
			contract.Opportunity__c = opportunityId;
		}
	}
	
	public void createContract()
	{
		if( String.isBlank( existingContractId ) )
		{
			buildContract();
			insert contract;
		}
		/*else
		{
			contract.ID = existingContractId;
		}*/
	}
	
	public void createAttachment()
	{
		String prefix = ContractFileManagementCtrl.valid_contract_doc_types.get( attachType ).Attachment_Prefix__c;
		attachment.Name = (prefix!=null ? prefix : '') + attachment.Name;
		
		if(!String.isBlank( existingContractId ))
		{
			attachment.ParentId = existingContractId;
			if(!String.isBlank( existingAttachmentId ) )
			{
				attachment.ID = existingAttachmentId;
			}
		}
		else
		{
			attachment.ParentId = contract.Id;
		}
		
		
		upsert attachment;
	}
	
	public void initializeAttachment()
	{
		attachment = new Attachment();
		contract = new Contract();
	}
}
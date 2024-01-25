public with sharing class ContractFileManagementCtrl 
{
	public static final String BUTTON_ADD_NEW = 'Add New';
	public static final String BUTTON_CHANGE = 'Change';
	public static final String CLOSED_WON = '8- Closed Won';
	public static final Boolean FILE_ON_ACCOUNT = false;
	public static final Boolean FILE_ON_OPPORTUNITY=true;
	public static final String TERMS_MONTH_TO_MONTH = 'Month-to-Month';
	public static final String TERMS_CONTRACT_PERIOD = 'Contract Period';
	public static final Integer LONG_CONTRACT_TERM = 600;
	public static final Integer SHORT_CONTRACT_TERM = 12;
	public static final String OPPORTUNITY_OBJECT = 'Opportunity';
	public static final String ACCOUNT_OBJECT = 'Account';
	public static final String MISSING_START_DATE_ON_CONTRACT = 'Missing Start Date';
	
	/* Map from the field name in opportunity to that in the FAP_Specification__c custom object */
	public static final Map<String,String> requiredCheckboxMappings = new Map<String,String> {'LTL__c' => 'LTL__c', 'Truckload__c'=>'FTL__c', 'Warehouse__c'=>'WH__c'};															
																								
	public String opportunityId 
	{
		 get
		 {
		 	if( opportunityId == NULL )
		 	{
		 		opportunityId =  ApexPages.currentPage().getParameters().get ( 'Id' );
		 	}
		 	return opportunityId;
		 }
		 private set;
	 }
	 	
	public List<ContractAttachmentWrapper> contractWrappers { get; set; }
	
	public static void populateULSLocationFieldMappings()
	{
		Set<ULS_Location_Field_Mapping__c> accountULSLocationFieldMappings = new Set<ULS_Location_Field_Mapping__c>();
		Set<ULS_Location_Field_Mapping__c> opportunityULSLocationFieldMappings = new Set<ULS_Location_Field_Mapping__c>();
		for(ULS_Location_Field_Mapping__c fieldMapping : ULS_Location_Field_Mapping__c.getAll().values())
		{
			if(fieldMapping.Object__c == OPPORTUNITY_OBJECT)
			{
				opportunityULSLocationFieldMappings.add(fieldMapping);
			}
			else if(fieldMapping.Object__c == ACCOUNT_OBJECT)
			{
				accountULSLocationFieldMappings.add(fieldMapping);
			}
		}
	}
	
	public static Set<ULS_Location_Field_Mapping__c> accountULSLocationFieldMappings 
	{
		get{
			if(accountULSLocationFieldMappings==null)
			{
				populateULSLocationFieldMappings();
			}
			return accountULSLocationFieldMappings;
		}
	}
	
	public static Set<ULS_Location_Field_Mapping__c> opportunityULSLocationFieldMappings 
	{
		get{
			if(opportunityULSLocationFieldMappings==null)
			{
				populateULSLocationFieldMappings();
			}
			return opportunityULSLocationFieldMappings;
		}
	}
	
	public static Set<String> getOriginFieldNames(Set<ULS_Location_Field_Mapping__c>  ulsFieldMappings)
	{
        Set<String> fieldSet = new Set<String>();
        if(ulsFieldMappings != null && ulsFieldMappings.size() > 0){
            for(ULS_Location_Field_Mapping__c fm : ulsFieldMappings)
            { 
                fieldSet.add(fm.Map_From_Field__c);
            }
        }
        
		return fieldSet;
	}
	
	public Account account
	{
		get {
			if( account == NULL)
			{
				Set<String> accountFieldsNeeded = getOriginFieldNames(accountULSLocationFieldMappings);
				account = Database.query('Select ' + String.join(new List<String>(accountFieldsNeeded),',') + ' FROM Account WHERE Id = \'' + opportunity.AccountID + '\'');
			}
			return account;
		}
		set;
	}
	
	public Opportunity opportunity 
	{ 
		get
		{
			if( opportunity == NULL )
			{
				Set<String> opportunityFieldsNeeded = new Set<String> {'ID','AccountID','Servicing_Division__c'};
				opportunityFieldsNeeded.addAll(requiredCheckboxMappings.keySet());
				opportunityFieldsNeeded.addAll(getOriginFieldNames(opportunityULSLocationFieldMappings));
				opportunity = Database.query('Select ' + String.join(new List<String>(opportunityFieldsNeeded),',') + ' FROM Opportunity WHERE Id = \'' + opportunityID + '\'');
			}
			return opportunity;
		}
		private set;
	}
 
	public static Set<String> possible_document_types {
		get{
			if(possible_document_types==null)
			{
				possible_document_types = new Set<String>();
				for(Schema.Picklistentry picklistOption : Contract.Document_Type__c.getDescribe().getPicklistValues())
				{
					possible_document_types.add(picklistOption.getValue());
				}
			}
			return possible_document_types;
		} 
		private set;
	}
	private static void populateValidContractDocTypes()
	{
		valid_contract_doc_types = new Map<String,FAP_Specification__c>();
		documentTypesInOrder = new List<String>();
		for(FAP_Specification__c fap : [Select ID, Name, Alternate_Attachment__c, Attachment_Prefix__c, 
				                                       File_Varies_by_Opp__c, FTL__c, LTL__c, Need_Date__c,
				                                       Stage_Required_At__c, WH__c From FAP_Specification__c Order By Order__c])
		{
			if(possible_document_types.contains(fap.Name))
					{
						valid_contract_doc_types.put(fap.Name,fap);
						documentTypesInOrder.add(fap.Name);
					}
		}
	}
	
	public static Map<String,FAP_Specification__c> valid_contract_doc_types
	{
		get{
			if(valid_contract_doc_types==null)
			{
				populateValidContractDocTypes();
			}	
			return valid_contract_doc_types;
		}
		private set;
	} 
	
	public static List<String> documentTypesInOrder { 
		get {
			if(documentTypesInOrder==null)
			{
				populateValidContractDocTypes();
			}
			return documentTypesInOrder;
		}
		set;
	} 
	
	public static Set<String> varyByOppDocumentTypes {
		get{
			if(varyByOppDocumentTypes==null)
			{
				Set<String> varyByOppDocumentTypes = new Set<String>();
				for(String docType : valid_contract_doc_types.keySet())
				{
					if(valid_contract_doc_types.get(docType).File_Varies_by_Opp__c)
					{
						varyByOppDocumentTypes.add(docType);
					}
				}
			}
			return varyByOppDocumentTypes;
		}
	}
	
	/* 
	From a list of all possible contracts, create a map of document type to contract. If multiple contracts are encountered with the same document type,
	choose the contract that has the most recently created attachment.
	 
	Precondition: The child list of Attachments for each contract in contracts must be sorted in descending order by created date
	*/
	public static Map<String,Contract> createMapDocumentTypeToContract(List<Contract> contracts)
	{
		Map<String,Contract> mapDtToContract = new Map<String,Contract>();
		
		for(Contract c : contracts)
		{
			if(!mapDtToContract.containsKey(c.Document_Type__c)){
				mapDtToContract.put(c.Document_Type__c,c);	
			} 
			else 
			{
				DateTime attachmentDateOfThisContract = getAttachmentDate(c);
				if(attachmentDateOfThisContract!=null)
				{
					DateTime attachmentDateOfContractInMap = getAttachmentDate(mapDtToContract.get(c.Document_Type__c));
					if(attachmentDateOfContractInMap==null || attachmentDateOfContractInMap < attachmentDateOfThisContract)
					{
						mapDtToContract.put(c.Document_Type__c,c);
					} 
				}
			} 
		}
		return mapDtToContract; 
	}
	
	/* 
	Precondition: The child list of Attachments for the contract must be sorted in descending order by created date
	*/
	private static DateTime getAttachmentDate(Contract c)
	{
		return (c.Attachments != null && !c.Attachments.isEmpty() ? c.Attachments[0].CreatedDate : null);
	}
	
	public ContractFileManagementCtrl()
	{
		if (opportunityId instanceOf Id )
		{
			initializePage();
		} 
		else
		{
			ApexPages.addMessage( new ApexPages.Message ( ApexPages.Severity.ERROR, 'Invalid Opportunity Id' ) );
		}
	}
	
	
	public static Attachment findAttachment(String prefix, Contract aContract)
	{
		prefix = (prefix!=null) ? prefix : '';
		for(Attachment anAttachment : aContract.Attachments)
		{
			if(anAttachment.Name.startsWith(prefix))
			{
				return anAttachment;
			}
		}
		return null;
	}
	
	public void createWrapperList(Map<String,Contract> mapDocTypeToExistingContract)
	{
		/* Preserve old wrapper values */
		Map<Id, Contract> contractWrapperEntryMap = new Map<Id, Contract>();
		if (contractWrappers != null ){
			for (ContractAttachmentWrapper caw : contractWrappers ){
				if (caw.contract != null){
					contractWrapperEntryMap.put(caw.contract.Id, caw.contract); 
				}
			}
		}
		
		contractWrappers = new List<ContractAttachmentWrapper>();
		for( String validDocType : documentTypesInOrder )
		{
			
			FAP_Specification__c fap = valid_contract_doc_types.get( validDocType );
			if( mapDocTypeToExistingContract.containsKey( validDocType ) )
			{
				Contract existingContract = mapDocTypeToExistingContract.get( validDocType );
				Attachment attachment = findAttachment(fap.Attachment_Prefix__c, existingContract);
				if(attachment!=null)
				{
					ContractAttachmentWrapper newContractWrapper = new ContractAttachmentWrapper(existingContract,attachment.ID,attachment.Name, fap, this);
					if (contractWrapperEntryMap.containsKey(existingContract.Id)){
						newContractWrapper.contract.StartDate = contractWrapperEntryMap.get(existingContract.Id).StartDate; 
						newContractWrapper.contract.ContractTerm = contractWrapperEntryMap.get(existingContract.Id).ContractTerm; 
						newContractWrapper.contract.Terms__c = contractWrapperEntryMap.get(existingContract.Id).Terms__c; 
					}
					contractWrappers.add( newContractWrapper );
				}
				else
				{ 
					contractWrappers.add( new ContractAttachmentWrapper(existingContract, NULL, NULL, fap, this ) );
				}
			}
			else
			{
				contractWrappers.add( new ContractAttachmentWrapper( fap, this ) );
			}
		}
		
	}
	 
	public void initializePage()
	{
		List<Contract> relatedContracts = [ SELECT Opportunity__c, AccountId, StartDate, ContractTerm, Terms__c, Document_Type__c, Division__c, 
											( SELECT Id, ParentId, Name, CreatedDate FROM Attachments ORDER BY CreatedDate DESC) 
											FROM Contract WHERE AccountId = :opportunity.AccountId AND Document_Type__c=:valid_contract_doc_types.keySet() 
											AND ((Document_Type__c NOT IN:varyByOppDocumentTypes) OR (Opportunity__c=:opportunity.ID AND Division__c = :opportunity.Servicing_Division__c AND Document_Type__c IN: varyByOppDocumentTypes)) ];
		List<Attachment> attachments = new List<Attachment>(); 
		for( Contract aContract : relatedContracts )
		{
			attachments.addAll( aContract.Attachments );
		}
		Map<String,Contract> mapDocTypeToExistingContract = createMapDocumentTypeToContract(relatedContracts);
		createWrapperList(mapDocTypeToExistingContract);
	}
	
	public PageReference returnToOpportunity()
	{
		return new PageReference( '/' + opportunityId );
	}
	
	public static List<Contract> getContractsMissingRequiredStartDates(List<ContractAttachmentWrapper> contractWrappers)
	{
		/* {!AND(wrapper.contract!=null,NOT(wrapper.isMonthToMonth),wrapper.fapSpecification!=null,wrapper.fapSpecification.Need_Date__c)} */
		List<Contract> contactsMissing = new List<Contract>();
		for (ContractAttachmentWrapper wrapper : contractWrappers){
			if ( wrapper.contract != null && 
				!wrapper.isMonthToMonth && 
				wrapper.fapSpecification != null && 
				wrapper.fapSpecification.Need_Date__c && 
				wrapper.contract.StartDate == null)
			{
				contactsMissing.add(wrapper.contract);
			} 
		}
		return contactsMissing;
	}
	
	public static void addErrorsToContactsMissingRequiredStartDates(List<Contract> invalidContracts){
		for (Contract contract : invalidContracts){
			contract.StartDate.addError(MISSING_START_DATE_ON_CONTRACT);
		}
	}
	
	public Boolean validate()
	{
		List<Contract> invalidContracts = getContractsMissingRequiredStartDates(contractWrappers);
		if(invalidContracts.isEmpty())
		{
			return true;
		}
		else
		{
			addErrorsToContactsMissingRequiredStartDates(invalidContracts);
			return false;
		}
	}
	
	public PageReference goBackAndSave()
	{
		if(validate())
		{
			Savepoint sp = Database.setSavepoint();
			try
			{
				update getAllContracts(contractWrappers);
				
				try
				{
					opportunity.Max_Stage_Number__c = getMaxStageNumber();
					update opportunity;
					return new PageReference( '/' + opportunityId );
				}
				catch (DMLException dmlEx)
				{
					Database.rollback( sp );
					ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, dmlEx.getDmlMessage(0) ) );
				}
			}
			catch (Exception ex)
			{
				ApexPages.addMessages( ex );
			}
		}
		return null;
	}
	
	public PageReference closeWinOpportunity()
	{
		/*
		if( areAllRequiredDocumentsAttached() ) 
		{
		*/
		Savepoint sp = Database.setSavepoint();
		try
		{
			updateOpportunityAsValidatedForCloseWon();
			createULSAndUpdateContractsForWarehouseOpportunity();
			return new PageReference( '/' + opportunityId ); 
		}
		catch ( DMLException dmlEx )
		{
			Database.rollback( sp );
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, dmlEx.getDmlMessage(0) ) );
			return null;
		}
		//}
		//
		
	}
	
	/* Try to capture the first letter in the stage name and return the integer. If the first letter is not an integer, return 8 */
	public static Integer getStageNumber(String stageName)
	{
		try
		{
			return Integer.valueOf(stageName.substring(0, 1));
		}
		catch(Exception e)
		{
			return 8;
		}
	} 
	
	public Set<String> allDocumentsWithAttachments()
	{
		Set<String> docsWithAttachments = new Set<String>();
		for(ContractAttachmentWrapper aWrapper : contractWrappers )
		{
			if(aWrapper.attachmentId!=null)
				docsWithAttachments.add(aWrapper.documentType);
				
		}
		return docsWithAttachments;
	}
	
	public Integer getMaxStageNumber()
	{
		Boolean[] documentsFoundForStages = new Boolean[9];
		for(Integer i = 0; i < documentsFoundForStages.size(); i++)
		{
			documentsFoundForStages[i] = true;
		}
		
		Set<String> allDocumentsWithAttachments = allDocumentsWithAttachments();
		
		Integer MAX_STAGE = 0;
		for(Integer stage = 1; stage < documentsFoundForStages.size(); stage++)
		{
			if(documentsFoundForStages[stage])
			{
				MAX_STAGE = stage;	
			}
			else
			{
				break;
			}
		}
		
		return MAX_STAGE;
	}

	public void updateOpportunityAsValidatedForCloseWon()
	{
		opportunity.Validated_for_Close_Won__c = true;
		opportunity.StageName = CLOSED_WON;
		opportunity.Max_Stage_Number__c = 8;
		update opportunity;
	}
	
	public void createULSAndUpdateContractsForWarehouseOpportunity()
	{
		if( opportunity.Warehouse__c )
		{
			ULS_Location__c newULSLocation = createULSLocation();
			updateContractsWithULSLocation( newULSLocation );
		}
	}
	
	private ULS_Location__c createULSLocation()
	{
        ULS_Location__c newULSLocation = new ULS_Location__c();
        if(accountULSLocationFieldMappings != null  && accountULSLocationFieldMappings.size() > 0){
            for(ULS_Location_Field_Mapping__c fieldMapping : accountULSLocationFieldMappings)
            {
                newULSLocation.put(fieldMapping.Name,account.get(fieldMapping.Map_From_Field__c));
            }
        }
        if(opportunityULSLocationFieldMappings != null  && opportunityULSLocationFieldMappings.size() > 0){
            
            for(ULS_Location_Field_Mapping__c fieldMapping : opportunityULSLocationFieldMappings)
            {
                newULSLocation.put(fieldMapping.Name,opportunity.get(fieldMapping.Map_From_Field__c));
            }
        }
        if(newULSLocation != null && !test.isRunningTest()){
            insert newULSLocation;
        }
        
        return newULSLocation;
    }
    
    public static List<Contract> getAllContracts(List<ContractAttachmentWrapper> wrappers)
    {
        List<Contract> contractsToBeUpdated = new List<Contract>();
        for( ContractAttachmentWrapper aWrapper : wrappers )
		{
			if( aWrapper.contract != NULL )
			{
				if(aWrapper.isMonthToMonth || (aWrapper.contract.ContractTerm==null && !aWrapper.fapSpecification.Need_Date__c))
				{
					aWrapper.contract.ContractTerm = LONG_CONTRACT_TERM;
				}
				else if(aWrapper.fapSpecification.Need_Date__c && aWrapper.contract.ContractTerm==null)
				{
					aWrapper.contract.ContractTerm = SHORT_CONTRACT_TERM;
				}
				
				if(aWrapper.contract.StartDate==null && (aWrapper.isMonthToMonth || !aWrapper.fapSpecification.Need_Date__c))
				{
					aWrapper.contract.StartDate = Date.today();
				}
					
				contractsToBeUpdated.add( aWrapper.contract );
			}
		}
		return contractsToBeUpdated;
	}
	
	private void updateContractsWithULSLocation( ULS_Location__c aULSLocation )
	{
		List<Contract> contractsToBeUpdated = getAllContracts(contractWrappers);
		for( Contract c : contractsToBeUpdated )
		{
			c.ULS_Location_Detail__c = aULSLocation.Id;
		}
		
		update contractsToBeUpdated;
	} 
	
	public Class ContractAttachmentWrapper
	{
		public Contract contract {get; set;}
		public Id attachmentId { get; set;}
		public String attachmentName {get; set;}
		public String documentType {
			get {
					return fapSpecification.Name;
				}
			set;}
			
		public Boolean isMonthToMonth {
			get{
				return (contract.Terms__c == TERMS_MONTH_TO_MONTH ? true : false);
			}
			set{
				contract.Terms__c = (value==true ? TERMS_MONTH_TO_MONTH : TERMS_CONTRACT_PERIOD);
				isMonthToMonth = value;
			}
		}
		
		public ContractFileManagementCtrl controllerInstance;
		//public Boolean isMissing {get;set;}
		
		public FAP_Specification__c fapSpecification {get;set;}
		
		public String buttonText {
			get{
				if(contract==null || attachmentId==null)
				{
					return BUTTON_ADD_NEW;
				} 
				else
				{
					return BUTTON_CHANGE;
				}
			} 
		}
		
		public String requiredHelp {
			get{
				String ret = 'Required before ' + fapSpecification.Stage_Required_At__c;
				if(!String.isBlank(fapSpecification.Alternate_Attachment__c))
				{
					ret+='\nAlternatively, you may attach ' + fapSpecification.Alternate_Attachment__c;
				}
				return ret;
			}
			set;
		}
		
		
		public ContractAttachmentWrapper( Contract contract, Id attachmentId, String attachmentName, FAP_Specification__c fapSpecification, ContractFileManagementCtrl thisCtrl )
		{
			this.contract = contract;
			this.attachmentId = attachmentId;
			this.attachmentName = attachmentName;
			this.fapSpecification = fapSpecification;
			//this.isMissing = false;
			this.controllerInstance = thisCtrl;
			
		}
		
		public ContractAttachmentWrapper( FAP_Specification__c fapSpecification, ContractFileManagementCtrl thisCtrl)
		{
			this.fapSpecification = fapSpecification;
			//this.isMissing = false;
			this.controllerInstance = thisCtrl;
		}
	}
}
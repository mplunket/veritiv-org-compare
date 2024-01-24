public class CPLViewController {
	
    public static Map<String, String> cplFieldsToAgreementLineItemFields = new Map<String, String>{
		String.valueOf(Customer_Price_List__c.Division__c) => String.valueOf(zpl__ContractLineItem__c.Division__c),
		String.valueOf(Customer_Price_List__c.Segments__c) => String.valueOf(zpl__ContractLineItem__c.Segment__c),
		String.valueOf(Customer_Price_List__c.Classes__c) => String.valueOf(zpl__ContractLineItem__c.Class__c),
		String.valueOf(Customer_Price_List__c.Brands__c) => String.valueOf(zpl__ContractLineItem__c.Brand__c)
	};

	public static List<FieldSetMember> CPLView_Fields {
		get {
			if (CPLView_Fields == null) {
				CPLView_Fields = Schema.SObjectType.Customer_Price_List__c.fieldSets.CPLView_Fields.getFields();
			}

			return CPLView_Fields;
		} 
		
		set;
	}

	@AuraEnabled
	public static String getAgreementIdFromNumber(String agreementNumber)
	{
		Contract agreement = [SELECT Id FROM Contract WHERE ContractNumber = :agreementNumber];
		return agreement.Id;
	}

	@AuraEnabled
	public static Customer_Price_List__c getDefaultCPL(String recordTypeId)
	{
		Customer_Price_List__c cpl = (Customer_Price_List__c) Customer_Price_List__c.sObjectType.newSObject(recordTypeId, true);
        return cpl;
	}

	@AuraEnabled
	public static Customer_Price_List__c getCPLById(String cplId)
	{
		String query = 'SELECT Id, RecordType.Name, RecordTypeId, Agreement__c, Customer_Email__c ';
		for (FieldSetMember fieldSetMember : CPLView_Fields) 
		{
			query += ', ' + fieldSetMember.getFieldPath();
		}

		query += ' FROM Customer_Price_List__c WHERE Id = :cplId';

		Customer_Price_List__c cpl = Database.query(query);

		return cpl;
	}

	@AuraEnabled
	public static String getRecordTypeById(String recordTypeId) 
	{
		String recordTypeName;

		try 
		{
			recordTypeName = Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosById().get(recordTypeId).getName();
		} 
		catch (NullPointerException npe) 
		{
			AuraHandledException ahe = new AuraHandledException(npe.getMessage());
			ahe.setMessage(npe.getMessage());
			throw ahe;
		}
		
		return recordTypeName;
	}

	@AuraEnabled
	public static List<User> getSalesRepOptions(String agreementId) {
		Contract agreement = [
			SELECT AccountId, Account.OwnerId
			FROM Contract
			WHERE Id = :agreementId
		];

		List<Ship_To__c> shipTos = [
			SELECT Account_Owner__c
			FROM Ship_To__c
			WHERE Bill_To_Account__c = :agreement.AccountId
            AND Account_Owner__c != :agreement.Account.OwnerId
		];

		User agreementAccountOwner = [
			SELECT Id, Name
			FROM User
			WHERE Id = :agreement.Account.OwnerId
		];

		List<User> salesReps = [
			SELECT Id, Name
			FROM User
			WHERE Id IN :Pluck.ids('Account_Owner__c', shipTos)
		];

		if (salesReps.size() > 0) { 
			salesReps.add(0, agreementAccountOwner);
		} else {
			salesReps.add(agreementAccountOwner);
		}
		
		return salesReps;
	}

	@AuraEnabled
	public static Map<String, List<DependentPicklistOption>> getDependentPicklistValues(Customer_Price_List__c cpl) 
	{
		System.debug(cpl);

		List<DependentPicklistOption> divisionOptions = getPicklistValues(cpl, 'Division__c', 'Division__c');
		List<DependentPicklistOption> segmentOptions = getPicklistValues(cpl, 'Segments__c', 'Segment__c');
		List<DependentPicklistOption> classOptions = getPicklistValues(cpl, 'Classes__c', 'Class__c');
		List<DependentPicklistOption> brandOptions = getPicklistValues(cpl, 'Brands__c', 'Brand__c');

		return new Map<String, List<DependentPicklistOption>> {
			'Division__c' => divisionOptions,
			'Segments__c' => segmentOptions,
			'Classes__c' => classOptions,
			'Brands__c' => brandOptions
		};
	}
	
	@AuraEnabled
	public static String getCustomerPriceListName(String agreementId) 
	{
		Contract agreement = [SELECT Account.Name FROM Contract WHERE Id = :agreementId];
		return 'CPL: ' + agreement.Account.Name;
	}

	private static List<DependentPicklistOption> getPicklistValues(Customer_Price_List__c cpl, String cplField, String aliField) 
	{	
		List<CPLServices.AgreementLineItemWrapper> agreementLineItems = CPLServices.getAgreementLineItemsForDependentFieldValue(cpl, cplField);

		List<zpl__ContractLineItem__c> currentLineItems = new List<zpl__ContractLineItem__c>();
		for (CPLServices.AgreementLineItemWrapper agreementLineItem : agreementLineItems)
		{
			currentLineItems.add(agreementLineItem.currentAgreementLineItem);
		}

		List<DependentPicklistOption> options = new List<DependentPicklistOption>();

		if (cplField == 'Division__c') 
		{
			Map<Id, List<zpl__ContractLineItem__c>> currentLineItemsMap = GroupBy.ids('Division__c', currentLineItems);	

			for (Id divisionId : currentLineItemsMap.keySet()) 
			{
				options.add(new DependentPicklistOption(
					currentLineItemsMap.get(divisionId)[0].Division__r.Name,
					divisionId,
					currentLineItemsMap.get(divisionId).size()
				));
			} 
		}
		else if (cplField == 'Segments__c')
		{
			Map<String, List<zpl__ContractLineItem__c>> currentLineItemsMap = GroupBy.strings(aliField, currentLineItems);	

			for (String fieldValue : currentLineItemsMap.keySet()) 
			{
				options.add(new DependentPicklistOption(
					fieldValue,
					fieldValue,
					currentLineItemsMap.get(fieldValue).size()
				));
			} 
		}
		else if (cplField == 'Classes__c')
		{
			Map<String, List<zpl__ContractLineItem__c>> currentLineItemsMap = GroupBy.strings(aliField, currentLineItems);

			for (String fieldValue : currentLineItemsMap.keySet())
			{
				options.add(new DependentPicklistOption(
                    currentLineItemsMap.get(fieldValue)[0].Class_Desc__c != null ? currentLineItemsMap.get(fieldValue)[0].Class_Desc__c : currentLineItemsMap.get(fieldValue)[0].Class__c,
                    fieldValue,
                    currentLineItemsMap.get(fieldValue).size()
				));
			}
		}
		else if (cplField == 'Brands__c')
		{
			Map<String, List<zpl__ContractLineItem__c>> currentLineItemsMap = GroupBy.strings(aliField, currentLineItems);

			for (String fieldValue : currentLineItemsMap.keySet())
			{
				options.add(new DependentPicklistOption(
                    currentLineItemsMap.get(fieldValue)[0].Brand_Desc__c != null ? currentLineItemsMap.get(fieldValue)[0].Brand_Desc__c : currentLineItemsMap.get(fieldValue)[0].Brand__c,
                    fieldValue,
                    currentLineItemsMap.get(fieldValue).size()
				));
			}
		}

		return options;
	}

	public class DependentPicklistOption {
		public DependentPicklistOption(String label, String value, Integer count) {
			this.label = label;
			this.value = value;
			this.count = count;
		}

		@AuraEnabled
		public String label;

		@AuraEnabled
		public String value;

		@AuraEnabled
		public Integer count;
	}
}
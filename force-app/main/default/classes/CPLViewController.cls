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

	@AuraEnabled
	public static contract getContractFromId(String agreementId) 
	{
		Contract agreement = [
            SELECT Id, Account.Chain_Account__c, Account.ParentId, Account.Natl_Acct_Group_ID__c, Name
            FROM Contract
            WHERE Id = :agreementId
        ];
		return agreement;
	}

	@AuraEnabled
	public static void getNeededQueries(Customer_Price_List__c cpl) 
	{
		//get contract
		Contract agreement = [
            SELECT Id, Account.Chain_Account__c, Account.ParentId, Account.Natl_Acct_Group_ID__c, Name
            FROM Contract
            WHERE Id = :cpl.Agreement__c
        ];
		
		transient List<Id> contractsRegional = new List<Id>();        
        for( Contract regional : [Select id from contract where AccountId   = :agreement.Account.Chain_Account__c]){
            contractsRegional.add(regional.id);
        }
		
		transient Set<Id> relevantContracts = CPLServices.getRelevantContractIds(agreement, cpl.Regional_National_Filter__c, contractsRegional );

		String query =  'SELECT Id, Name, PricingUOM__c, zpl__PolicyType__r.zpl__PolicyTypeId__c, Bracket1MinQty__c, Bracket1Value__c, Bracket1Price__c, Bracket2MinQty__c, Bracket2Value__c, Bracket2Price__c, Bracket3MinQty__c, '+
            'Bracket3Value__c, Bracket3Price__c, Bracket4MinQty__c, Bracket4Value__c, Bracket4Price__c, Bracket5MinQty__c, Bracket5Value__c, Bracket5Price__c, Bracket6MinQty__c, Product_Composite_Key__c, '+
            'Bracket6Value__c, Bracket6Price__c, CustomerUOM__c, Description__c, Bracket7MinQty__c, Bracket7Value__c, Bracket7Price__c, Brand__c, Brand_Desc__c, CPLSortField__c, ' +
            'Class__c, Class_Desc__c, CustomerSKU__c, CustomerCalculatedPrice__c, GTM__C, aiq_GTM__C, Set_Desc__c, Customer_Description__c, Division__c, Division__r.Division_Code__c, Division__r.Name, ' +
            'ExternalCostDeviationDate__c, ExternalCostDeviation__c, InternalCostDeviationDate__c, InternalCostDeviation__c, aiq_Net_Price__c, PricingCost__c, ' +
            'QuantityBreakUOM__r.Name, Quantity_Break_UOM__c, SKU__c, Segment__c, Set__c, Subset__c, Subset_Desc__c, VendorCode__c, AIQdt_Vendor__c, X12MonthSalesVolume__c, '+
            'zpl__LevelValue__c, zpl__LineLevel__c, zpl__LineLevel__r.Name, zpl__PolicyType__c, zpl__PolicyType__r.Name, zpl__PolicyValue__c, zpl__Product__c, ' +
            'zpl__EffectiveDate__c, zpl__Product__r.Brand_Description__c, zpl__Product__r.Class_Description__c, zpl__Product__r.Composite_Key__c, ' +
            'zpl__Product__r.Description, zpl__Product__r.ProductCode, zpl__Product__r.Set_Description__c, zpl__Product__r.Segment__c, zpl__ContractLineItem__c.Net_Price__c, ' +
            'zpl__Product__r.Subset_Description__c, zpl__Product__r.Vendor_Product_Code__c, zpl__UOM__c, zpl__UOM__r.Name, zpl__Product__r.Unit_of_Measure__c, Publish_Date__c, Level_Indicator__c, ' +
            'zpl__Contract__r.Account.RecordType.Name ' +
            'FROM zpl__ContractLineItem__c ' +
            'WHERE zpl__Contract__c IN :relevantContracts ' +
            'AND RecordTypeId = \'' + Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByName().get('Active').getRecordTypeId() + '\' ' +
            'AND zpl__Status__c = \'Published\' ';
        
        if (CPLServices.CPLType == 'External') {        
            query += 'AND ( aiq_Net_Price__c > 0 OR zpl__PolicyType__r.name = \'List Down\') ';    
        }

		if(cpl.Purchased_Stocked_Filter__c == 'Show Purchased Agreement Lines Only'){
            query += 'AND X12MonthSalesVolume__c > 0 ';
        }
            
        //KM - Chain Accounts filter
        if(cpl.Regional_National_Filter__c == 'Show Chain Accounts Only'){
            query += 'AND isCurrent__c = TRUE ';
        }
        
        //SP - 04012022
       /* if(cpl.Regional_National_Filter__c == 'Ignore Regional Chain AND National Agreement Lines (if any)'){
            String strChain = 'CHAIN';
            query += 'AND (NOT zpl__Contract__r.Account.Name LIKE \'%' + strChain + '%\')';
        }*/
        
        //SP-05172022
        if(cpl.Regional_National_Filter__c == 'Ignore Regional Chain AND National Agreement Lines (if any)'){
            String strChain = 'CHAIN';
            if(!((agreement.Name).contains(strChain))){
                //System.debug('((agreement.Name).contains(strChain)) ' + ((agreement.Name).contains(strChain)));
                //System.debug('agreement.Name ' + agreement.Name);
                query += 'AND (NOT Account__c LIKE \'%' + strChain + '%\')';
            }
		}

		 //If Contract Name DOES NOT CONTAIN CHAIN, 
        //check line items account from zplcontractline, if contains chain do not include  AND //chain
        //check Contracts Account Natl Acct Group ID == Natl Acct Group ID from NationalAccountsPricing__c, if same do not include
        
        List<String> divisions = new List<String>();
        if (String.isNotBlank(cpl.Division__c)) {
            divisions = cpl.Division__c.split(';');
            query += 'AND Division__c IN :divisions ';
        }
        
        List<String> segments = new List<String>();
        if (String.isNotBlank(cpl.Segments__c)) {
            segments = cpl.Segments__c.split(';');
            query += 'AND Segment__c IN :segments ';
        }
        
        List<String> classes = new List<String>();
        if (String.isNotBlank(cpl.Classes__c)) {
            classes = cpl.Classes__c.split(';');
            query += 'AND Class__c IN :classes ';
        }
        
        List<String> brands = new List<String>();
        if (String.isNotBlank(cpl.Brands__c)) {
            brands = cpl.Brands__c.split(';');
            query += 'AND Brand__c IN :brands ';
        }
        
        if (cpl.New_Or_Changed_Only__c) {
            query += 'AND (Publish_Date__c > :effectiveDate OR LastModifiedDate > :effectiveDate) ';
        }
        
        if (cpl.Purchased_Stocked_Filter__c == 'Show Purchased Agreement Lines Only') {
            query += 'AND X12MonthSalesVolume__c > 0 ';
        } else if (cpl.Purchased_Stocked_Filter__c == 'Show Stock Agreement Lines Only') {
            query += 'AND zpl__Product__r.Stocking_Flag__c = true ';
        } else if (cpl.Purchased_Stocked_Filter__c == 'Show Purchased Or Stocked Agreement Lines') {
            query += 'AND (X12MonthSalesVolume__c > 0 OR zpl__Product__r.Stocking_Flag__c = true) ';
        }

		query += 'ORDER BY zpl__EffectiveDate__c DESC, Publish_Date__c DESC';
        //System.debug(' query  ' + query);
        transient List<zpl__ContractLineItem__c> allAgreementLineItems = Database.query(query);
		
		query = null; //heap deallocation
        divisions = null; //heap deallocation
        segments = null; //heap deallocation 
        classes = null; //heap deallocation
        brands = null; //heap deallocation
        
        //[START] Backlog Item 2810 
        Id conRecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        
        //Get Duplicate/greater than 1 'Item #(SKU__c)'
        transient List<AggregateResult> queryWithFuture =  [SELECT Count(Id), SKU__c skuName
                                                  FROM zpl__ContractLineItem__c 
                                                  WHERE zpl__Contract__c IN :relevantContracts
                                                  AND RecordTypeId =:conRecordTypeId
                                                  AND zpl__Status__c = 'Published' 
                                                  GROUP BY SKU__c HAVING count(Id)>1];
        Set<string> skuValues = new Set<string>();
        
        //Add 'Item #(SKU__c)' values to Set 
        for(AggregateResult ar : queryWithFuture){
            skuValues.add(string.valueOf(ar.get('skuName')));
        }
        //System.debug('skuValues ' + skuValues);
        
        //Get Id of Contract Line Item with duplicate 'Item #(SKU__c)'
        transient List<zpl__ContractLineItem__c> agreementWithDuplicates =  [SELECT Id
                                                                   FROM zpl__ContractLineItem__c
                                                                   WHERE zpl__Contract__c IN :relevantContracts 
                                                                   AND RecordTypeId =:conRecordTypeId
                                                                   AND zpl__Status__c = 'Published'
                                                                   AND Name IN :skuValues];                                                      

		//System.debug('agreementWithDuplicatesfff ' + agreementWithDuplicates);        
        Set<Id> aggreementLineSet = (new Map<Id,zpl__ContractLineItem__c>(allAgreementLineItems)).keySet();
        //System.debug('aggreementLineSetfff ' + aggreementLineSet);
        Set<Id> resultIds = (new Map<Id,zpl__ContractLineItem__c>(agreementWithDuplicates)).keySet();
        //System.debug('resultIdsff ' + resultIds);
        aggreementLineSet.removeAll(resultIds);
        
        agreementWithDuplicates = null;
        resultIds = null;
        
        //For Agreement Lines with no duplicates - Future Only aggreement lines

		transient List<zpl__ContractLineItem__c> agreementLineNoDupes = new List<zpl__ContractLineItem__c>();
        if(aggreementLineSet != null){
            agreementLineNoDupes =  [SELECT Id, zpl__LevelValue__c, zpl__EffectiveDate__c, Level_Indicator__c, CPLSortField__c, Segment__c, Division__c,  Division__r.Division_Code__c, Division__r.Name,
                                                                              Name, PricingUOM__c, zpl__PolicyType__r.zpl__PolicyTypeId__c, Bracket1MinQty__c, Bracket1Value__c, Bracket1Price__c, Bracket2MinQty__c, Bracket2Value__c, Bracket2Price__c, Bracket3MinQty__c,
                                                                              Bracket3Value__c, Bracket3Price__c, Bracket4MinQty__c, Bracket4Value__c, Bracket4Price__c, Bracket5MinQty__c, Bracket5Value__c, Bracket5Price__c, Bracket6MinQty__c,  
                                                                              Bracket6Value__c, Bracket6Price__c, CustomerUOM__c, Description__c, Bracket7MinQty__c, Bracket7Value__c, Bracket7Price__c, Brand__c, Brand_Desc__c,
                                                                              Class__c, Class_Desc__c, CustomerSKU__c, CustomerCalculatedPrice__c, GTM__C, aiq_GTM__C, Set_Desc__c, Customer_Description__c, 
                                                                              ExternalCostDeviationDate__c, ExternalCostDeviation__c, InternalCostDeviationDate__c, InternalCostDeviation__c, aiq_Net_Price__c, PricingCost__c, 
                                                                              QuantityBreakUOM__r.Name, Quantity_Break_UOM__c, SKU__c, Set__c, Subset__c, Subset_Desc__c, VendorCode__c, AIQdt_Vendor__c, X12MonthSalesVolume__c, 
                                                                              zpl__LineLevel__c, zpl__LineLevel__r.Name, zpl__PolicyType__c, zpl__PolicyType__r.Name, zpl__PolicyValue__c, zpl__Product__c,
                                                                              zpl__Product__r.Brand_Description__c, zpl__Product__r.Class_Description__c, zpl__Product__r.Composite_Key__c, Product_Composite_Key__c,
                                                                              zpl__Product__r.Description, zpl__Product__r.ProductCode, zpl__Product__r.Set_Description__c, zpl__Product__r.Segment__c, zpl__ContractLineItem__c.Net_Price__c,
                                                                              zpl__Product__r.Subset_Description__c, zpl__Product__r.Vendor_Product_Code__c, zpl__UOM__c, zpl__UOM__r.Name, zpl__Product__r.Unit_of_Measure__c, Publish_Date__c,
                                                                              zpl__Contract__r.Account.RecordType.Name 
                                                                              FROM zpl__ContractLineItem__c
                                                                              WHERE zpl__Contract__c IN :relevantContracts 
                                                                              AND RecordTypeId =:conRecordTypeId
                                                                              AND zpl__Status__c = 'Published'
                                                                              AND Id IN :aggreementLineSet
                                                                              ORDER BY zpl__EffectiveDate__c DESC, Publish_Date__c DESC]; 
        }
         //System.debug('agreementLineNoDupes ' + agreementLineNoDupes);
         aggreementLineSet = null;

		 Map<String, List<Product2>> classificationsToProducts = new Map<String, List<Product2>>();
        if (cpl.Level_Filter__c == 'Item Level (Expand Sets and Subsets)') {
            List<zpl__ContractLineItem__c> setLevelAgreementLineItems = CPLServices.getLineLevelAgreementLineItems(allAgreementLineItems, 'Set');
            List<zpl__ContractLineItem__c> subsetLevelAgreementLineItems = CPLServices.getLineLevelAgreementLineItems(allAgreementLineItems, 'Subset');
            
            if (setLevelAgreementLineItems.size() > 0) {
                String setQuery = 'SELECT Id, Name, IsActive, Unit_of_Measure__c, ' +
                    'Brand__c, Brand_Description__c, Class__c, Class_Description__c, Composite_Key__c, ' +
                    'Description, ProductCode, Set__c, Set_Description__c, Division_Name__r.Name, Division_Name__c, Division_Name__r.Division_Code__c, ' +
                    'Subset__c, Subset_Description__c, Vendor_Product_Code__c, zpl__UOM__c, Pricing_Costing_UOM__c, ' +
                    'Segment__c ' +
                    'FROM Product2 '+
                    'WHERE ';
                
                set<String> setLevelFilters = new set<String>();
                for (zpl__ContractLineItem__c setLevelAgreementLineItem : setLevelAgreementLineItems){
                  
                        setLevelFilters.add('(Division_Name__c = ' + (setLevelAgreementLineItem.Division__c ==null ? 'null ':  ('\'' + setLevelAgreementLineItem.Division__c) + '\' ') +
                                            'AND Class__c = ' + '\'' + setLevelAgreementLineItem.Class__c + '\' ' +
                                            'AND Brand__c = ' + '\'' + setLevelAgreementLineItem.Brand__c + '\' ' +
                                            'AND Set__c = ' + '\'' + setLevelAgreementLineItem.Set__c + '\' ' +
                                            'AND IsActive = TRUE)');
                }
                //setQuery += String.join(setLevelFilters, ' OR ');
                setQuery += String.join(new List<String>(setLevelFilters), ' OR ');
                
                List<Product2> setProducts = Database.query(setQuery);
                
                if(setProducts != null){
                for (Product2 setProduct : setProducts){                    
                    String classification = setProduct.Division_Name__r.Division_Code__c + setProduct.Class__c + setProduct.Brand__c + setProduct.Set__c ; 
                    if (classificationsToProducts.containsKey(classification)) {
                        classificationsToProducts.get(classification).add(setProduct);
                    } else {
                        classificationsToProducts.put(classification, new List<Product2> {setProduct});
                    }
                }
            }
            }
            
            if (subsetLevelAgreementLineItems.size() > 0){
                String subsetQuery = 'SELECT Id, Name, IsActive, Unit_of_Measure__c, ' +
                    'Brand__c, Brand_Description__c, Class__c, Class_Description__c, Composite_Key__c, ' +
                    'Description, ProductCode, Set__c, Set_Description__c, Division_Name__r.Name, Division_Name__c, Division_Name__r.Division_Code__c, ' +
                    'Subset__c, Subset_Description__c, Vendor_Product_Code__c, zpl__UOM__c, Pricing_Costing_UOM__c, ' +
                    'Segment__c ' +
                    'FROM Product2 ' +
                    'WHERE ';
                
                List<String> subsetLevelFilters = new List<String>();
                for (zpl__ContractLineItem__c subsetLevelAgreementLineItem : subsetLevelAgreementLineItems){
                    subsetLevelFilters.add('(Division_Name__c = '  + (subsetLevelAgreementLineItem.Division__c ==null ? 'null ':  ('\''+ subsetLevelAgreementLineItem.Division__c)+ '\' ') +
                                           'AND Class__c = ' + '\'' + subsetLevelAgreementLineItem.Class__c + '\' ' +
                                           'AND Brand__c = ' + '\'' + subsetLevelAgreementLineItem.Brand__c + '\' ' +
                                           'AND Set__c = ' + '\'' + subsetLevelAgreementLineItem.Set__c + '\' ' +
                                           'AND Subset__c = ' + '\'' + subsetLevelAgreementLineItem.Subset__c + '\' ' +
                                           'AND IsActive = TRUE)');
                }
                subsetQuery += String.join(subsetLevelFilters, ' OR ');
                
                List<Product2> subsetProducts = Database.query(subsetQuery);
                
                if(subsetProducts != null){
                    for (Product2 subsetProduct : subsetProducts){
                        String classification = subsetProduct.Division_Name__r.Division_Code__c + subsetProduct.Class__c + subsetProduct.Brand__c + subsetProduct.Set__c + subsetProduct.Subset__c;
                        if (classificationsToProducts.containsKey(classification)) {
                            classificationsToProducts.get(classification).add(subsetProduct);
                        } else {
                            classificationsToProducts.put(classification, new List<Product2> {subsetProduct});
                        }
                    }
                }
            }
		}

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
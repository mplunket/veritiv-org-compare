public with sharing class UpdatePricingDetailsQuoteContExt extends QuoteLineItemsCont {
	
	public static String PT_MaintainMargin = 'RETAIN GTM';
	public static String PT_CWTFixed = 'CWT PRICE';
	public static String PT_ListDown = 'LIST DOWN';
	public static String PT_CostUp = 'COST UP';
	public static String PT_Fixed = 'FIXED';
	
	public static final String SEGMENT_PACKAGING = 'PACKAGING';
	public static final String SEGMENT_PACKAGING_SHORT = 'PK';
	public static final String SEGMENT_PRINTING_AND_IMAGING = 'PRINTING AND IMAGING';
	public static final String SEGMENT_PRINTING_AND_IMAGING_SHORT = 'PI';
	public static final String SEGMENT_FACILITY_SUPPLIES = 'FACILITY SUPPLIES';
	public static final String SEGMENT_FACILITY_SUPPLIES_SHORT = 'FS';
	public static final String SEGEMENT_DEFAULT_SHORT = 'SU';
	
	public static final String CUSTOMER_COMPOSITE_KEY_03 = '03';
	public static final String CUSTOMER_COMPOSITE_KEY_SW = 'SW';
    public static final String SAALFELD_PERMISSION_SET_NAME = 'Saalfeld_Pricing_Access';
	
	public static Map<String, String> segmentMapping = new Map<String, String>
	{
		SEGMENT_PACKAGING => SEGMENT_PACKAGING_SHORT,
		SEGMENT_PRINTING_AND_IMAGING => SEGMENT_PRINTING_AND_IMAGING_SHORT,
		SEGMENT_FACILITY_SUPPLIES => SEGMENT_FACILITY_SUPPLIES_SHORT
	};
	
	public static String errorLevel { get; set; }
	public static String message { get; set; }
	public static Integer qliIndex { get; set; }
	public static Boolean isNewError { get; set; }
	public Integer currentPageRow { get; set; }
	
	public Boolean renderSendButton
	{
		get
		{
			for(QuoteLineItemModel qli : qliModels)
			{
				if(!qli.getqliErrors().isEmpty())
				{
					return true;
				}
			}
			return false;
		}
		
		private set;
	}
	
	private Boolean operationSuccess = Consts.SUCCESS;
    public Quote__c quote { get; private set; }
    
	public List<QuoteLineItemModel> qliModels {  
	get
	{
	    return qliIdToModel.values();
	}
	
	private set { }
	    
	}
	
    public static Boolean isSaalfeldUser {
        get {
            if(isSaalfeldUser == null) {
                isSaalfeldUser = false;
                Integer recordCount = [SELECT count() 
                                       FROM PermissionSetAssignment 
                                       WHERE AssigneeId = :UserInfo.getUserId() 
                                           AND PermissionSet.Name = :SAALFELD_PERMISSION_SET_NAME];
                if(recordCount > 0) {
                    isSaalfeldUser = true;   
                }
            }
            return isSaalfeldUser;
        }

        private set;
    }
    
    public Boolean isAccountActive {get;set;}
    public Map<Id, QuoteLineItemModel> qliIdToModel {get; private set;}
    public Map<Integer, QuoteLineItemModel> qliIntToModel {get; set;}

	private String quoteId;
	private String qliIds;
	private Quote__c pilotQuoteFields;

    public UpdatePricingDetailsQuoteContExt(ApexPages.StandardController standardController) {

		this.quote          = (Quote__c)standardController.getRecord();

		this.quoteId        = ApexPages.currentPage().getParameters().get('id');
		this.qliIds         = ApexPages.currentPage().getParameters().get('qliIds');

        isAccountActive = getAccountActive(this.quote);

		if(this.quoteId  == null || this.quoteId == Consts.EMPTY_STRING ||
		   this.qliIds == null || this.qliIds == Consts.EMPTY_STRING) {

		   	this.quoteId = null;
			 return;

		}

    	Set<Id> setOfQliIds = new Set<Id>();
    	for(String qliId :qliIds.split(','))
    	{
    		if( qliId != null && qliId != '' )
    		{
    			setOfQliIds.add(qliId);
    		}
    	}

		QuotesModel quoteModel = new QuotesModel(this.quote);
	    qliIdToModel = new Map<Id, QuoteLineItemModel>();
	    qliIntToModel = new Map<Integer, QuoteLineItemModel>();
	    Integer i = 0;
		for( Quote_Line_Item__c qli : QuoteLineItemServices.getQuoteLineItem(quoteId, setOfQliIds))
		{
			QuoteLineItemModel tempModel = new QuoteLineItemModel(quoteModel,qli);
		    qliIdToModel.put(qli.Id, tempModel);
		 	qliIntToModel.put(i, tempModel);
		 	
		 	i++;
		}


		pilotQuoteFields = [SELECT System_Code__c, Account__c, Account__r.AccountNumber, Account__r.Zilliant_Active__c FROM Quote__c WHERE Id = :this.quote.Id];
    }
    
    public void resetErrors()
    {
    	qliIntToModel.get(qliIndex).setqliErrors( new List<String>() ); 
    }
    
	public void addErrorToPage()
	{
		resetErrors();
		
		if( String.isNotBlank(message) )
		{
			qliIntToModel.get(qliIndex).addQLIError(errorLevel + '! ' + message, isNewError); 
		}
	}
	
	public static String convertSegment(String prodSegment)
	{
		if(String.isBlank(prodSegment))
		{
			return SEGEMENT_DEFAULT_SHORT;
		}
		
		if( prodSegment.equalsIgnoreCase(SEGMENT_PACKAGING) )
		{
			return SEGMENT_PACKAGING_SHORT;
		}
		else if( prodSegment.equalsIgnoreCase(SEGMENT_PRINTING_AND_IMAGING) )
		{
			return SEGMENT_PRINTING_AND_IMAGING_SHORT;
		}
		else if( prodSegment.equalsIgnoreCase(SEGMENT_FACILITY_SUPPLIES) )
		{
			return SEGMENT_FACILITY_SUPPLIES_SHORT;
		}
		else
		{
			return SEGEMENT_DEFAULT_SHORT;
		}
	}
	
	public static String getCustomerCompositeKey(Quote__c parentQuote)
	{
		String billToNumber = parentQuote.Bill_To_Number__c;
		String legacyCode = parentQuote.Account_Legacy_System_Cd__c;
		
		if(billToNumber != NULL && legacyCode != NULL)
		{
			if( legacyCode.equals( CUSTOMER_COMPOSITE_KEY_03 ) )
			{
				return CUSTOMER_COMPOSITE_KEY_SW + billToNumber;
			}
			else
			{
				return legacyCode + billToNumber;
			}
		}
		else
		{
			return NULL;
		}
		
	}
	
	public static String convertPricingType(String policyType)
	{
		String convertedPolicyType = '';
		
		if( policyType.equalsIgnoreCase('Maintain Margin') )
		{
			convertedPolicyType = PT_MaintainMargin;
		}
		else if( policyType.equalsIgnoreCase('CWT Fixed') )
		{
			convertedPolicyType = PT_CWTFixed;
		}
		else if( policyType.equalsIgnoreCase('Fixed') )
		{
			convertedPolicyType = PT_Fixed;
		}
		else if( policyType.equalsIgnoreCase('Cost Up') )
		{
			convertedPolicyType = PT_CostUp;
		}
		else if( policyType.equalsIgnoreCase('List Down') )
		{
			convertedPolicyType = PT_ListDown;
		}
		else
		{
			convertedPolicyType = policyType;
		}
		return convertedPolicyType;
	}
    
    public static String convertPolicyTypeForZilliant(String policyType)
	{
		String convertedPolicyType = '';

		if( policyType.equalsIgnoreCase('Maintain Margin') )
		{
			convertedPolicyType = 'maintainGTM';
		}
		else if( policyType.equalsIgnoreCase('CWT Fixed') )
		{
			convertedPolicyType = 'cwtFixed';
		}
		else if( policyType.equalsIgnoreCase('Fixed') )
		{
			convertedPolicyType = 'fixedPrice';
		}
		else if( policyType.equalsIgnoreCase('List Down') )
		{
			convertedPolicyType = 'listDown';
		}
		else
		{
			convertedPolicyType = policyType;
		}
		return convertedPolicyType;
	}
	
	public void updatePricingDetails()
	{
		List<Quote_Line_Item__c> qlisToUpdate = new List<Quote_Line_Item__c>();
		
		Map<Id, Integer> qliToIndex = new Map<Id, Integer>();
		Integer qliCount = 0;
		Boolean startOver = false;
		
		for(QuoteLineItemModel qli : qliModels)
		{
			qliIndex = qliCount;
			resetErrors();
			
			if(qli.quoteLineItem.Pricing_Start_Date__c == null)
			{
				qli.addQLIError('QLI #' + (qliCount + 1) + ' Pricing Start Date cannot be empty!', true);
				startOver = true;
			}
			
			else if(qli.quoteLineItem.Pricing_Start_Date__c < Date.today())
			{
				qli.addQLIError('QLI #' + (qliCount + 1) + ' Pricing Start Date cannot be in the past!', true);
				startOver = true;
			}
			
			if( String.isBlank(qli.matrix.Price_Level_Value__c) )
			{
				qli.addQLIError('QLI #' + (qliCount + 1) + ' Price Level Value cannot be blank!', true);
				startOver = true;
			}
			
			if( String.isBlank(qli.matrix.Policy_Type_Value__c) )
			{
				qli.addQLIError('QLI #' + (qliCount + 1) + ' Policy Type Value cannot be blank!', true);
				startOver = true;
			}
			
			qliCount++;
		}
		
		if( startOver )
		{
			return;
		}
		
		qliCount = 0;
		
		for(QuoteLineItemModel qli : qliModels)
		{
			qliCount++;
			qliToIndex.put(qli.quoteLineItem.Id, qliCount);
			
			if (pilotQuoteFields.Account__r.Zilliant_Active__c == 'AI')
			{
				String convertedPricingType = convertPolicyTypeForZilliant(qli.matrix.Policy_Type_Value__c.toUpperCase());
				String gtmPercentValue = qli.getGTMPercentValue();
				Decimal maitainMarginGTMPercent = 0.0; 
				if(String.isNotBlank(gtmPercentValue))
				{
					System.debug('Inside If: ' + gtmPercentValue);
					maitainMarginGTMPercent = gtmPercentValue.contains('%') 
								? Decimal.valueOf( gtmPercentValue.substring(0, gtmPercentValue.length() - 1) )
								: Decimal.valueOf( gtmPercentValue.substring(0, gtmPercentValue.length() ));
				}
                
				AIQAddLineResponse response = AIQService.addAgreementLine(
					pilotQuoteFields.Account__r.AccountNumber, // customerId 
					qli.matrix.Price_Level_Value__c, // level
					qli.quoteLineItem.Vendor_Contact__c, // vendorId
					qli.quoteLineItem.Product__r.Division_Code__c, // divisionId
					pilotQuoteFields.System_Code__c, // systemId
					convertSegment(qli.quoteLineItem.Product__r.Segment__c), // segmentId
					qli.quoteLineItem.Product__r.Class__c, // classId
					qli.quoteLineItem.Product__r.Brand__c, // brandId
					qli.quoteLineItem.Product__r.Set__c, // setId
					qli.quoteLineItem.Product__r.Subset__c, // subsetId
					qli.quoteLineItem.Product__r.ProductCode, // productCode
					convertedPricingType, // policyType
					(convertedPricingType == 'maintainGTM') ? maitainMarginGTMPercent : qli.getCostUp(), // policyValue
					qli.quoteLineItem.Price_unit_of_measure__c, // priceUnit
					qli.quoteLineItem.Pricing_Start_Date__c // effectiveDate
				);
                
                

				if(response.getResponseCode() == 0)
				{
					qli.zilliantStatus = 'QLI #' + qliCount + ' Successfully Sent to Zillliant (Pilot)!';
				}
				else
				{
					Integer responseError = response.getResponseCode();
					String responseMessage = response.getMessage();
					
					qli.zilliantStatus = '(Pilot) ERROR Error on QLI #' + qliCount + '\nError: ' + responseError + '\nMessage: ' + responseMessage;
				}
			}
			else 
			{
				UpdateZilliantRequest zilliantRequest = new UpdateZilliantRequest();
				
				// Calculate Necessary Values
				String convertedPricingType = convertPricingType(qli.matrix.Policy_Type_Value__c.toUpperCase());
				String gtmPercentValue = qli.getGTMPercentValue();
				Decimal maitainMarginGTMPercent = 0.0; 
				if(String.isNotBlank(gtmPercentValue))
				{
					System.debug('Inside If: ' + gtmPercentValue);
					maitainMarginGTMPercent = gtmPercentValue.contains('%') 
								? Decimal.valueOf( gtmPercentValue.substring(0, gtmPercentValue.length() - 1) )
								: Decimal.valueOf( gtmPercentValue.substring(0, gtmPercentValue.length() ));
				}
				
				try
				{
					zilliantRequest.CustomerCompositeKey = getCustomerCompositeKey(qli.getQuotesModel().getquote());
				}
				catch(Exception ex)
				{
					// Default the Customer Composite Key
					//zilliantRequest.CustomerCompositeKey = getCustomerCompositeKey(qli.getQuotesModel().getquote());
				}
				
				zilliantRequest.Division = qli.quoteLineItem.Product__r.Division_Code__c;
				/* zilliantRequest.Vendor = ''; */
				zilliantRequest.Segment = convertSegment(qli.quoteLineItem.Product__r.Segment__c);
				zilliantRequest.ClassCd = qli.quoteLineItem.Product__r.Class__c	;
				zilliantRequest.BrandCd = qli.quoteLineItem.Product__r.Brand__c;
				zilliantRequest.SetCd = qli.quoteLineItem.Product__r.Set__c;
				zilliantRequest.SubsetCd = qli.quoteLineItem.Product__r.Subset__c; 
				zilliantRequest.ShortItem = qli.quoteLineItem.Product_Code__c; 
				zilliantRequest.PricingType =  convertedPricingType;
				//zilliantRequest.ListDownPercent = qli.getListDown();
				zilliantRequest.CostUpPercent = (convertedPricingType == PT_MaintainMargin) ? maitainMarginGTMPercent : qli.getCostUp();
				zilliantRequest.Price = qli.quoteLineItem.Price__c;
				zilliantRequest.PriceUnit = qli.quoteLineItem.Price_unit_of_measure__c;
				zilliantRequest.QuantityUnit = qli.quoteLineItem.Quantity_unit_of_measure__c;
				zilliantRequest.DateBegin = qli.quoteLineItem.Pricing_Start_Date__c;
				/* zilliantRequest.DateEnd = ''; */
				
				System.debug('*** REQUEST: ' + zilliantRequest);
				
				zilliantRequest.postData();
				if( zilliantRequest.Response.StatusSendDate != null)
				{
					Quote_Line_Item__c tempQLI = new Quote_Line_Item__c( Id = qli.quoteLineItem.Id, Sent_To_Zilliant_Time__c = zilliantRequest.Response.StatusSendDate);
						if(Test.isRunningTest())
							tempQLI.Vendor_Contact__c = qli.quoteLineItem.Vendor_Contact__c;
					qlisToUpdate.add( tempQLI );
					qli.zilliantStatus = 'QLI #' + qliCount + ' Successfully Sent to Zillliant!';
				}
				else
				{
					String responseError = zilliantRequest.Response.StatusCode;
					String responseMessage = zilliantRequest.Response.StatusMessage;
					
					qli.zilliantStatus = 'ERROR Error on QLI #' + qliCount + ' Error: ' + responseError + ' Message: ' + responseMessage;
				}
			}
		}
		
		Map<Id, Quote_Line_Item__c> qlisMap = new Map<Id, Quote_Line_Item__c>( qlisToUpdate );
		Database.SaveResult[] results;
		
		if(!qlisToUpdate.isEmpty())
		{
			results = Database.update(qlisToUpdate, false);
		}
		
		for( Integer i = 0,k = 0; i < qliModels.size(); i++ )
		{
			if( qlisMap.containsKey(qliModels[i].quoteLineItem.Id) )
			{
				Id recordId = qliModels[i].quoteLineItem.Id;
				Database.SaveResult sr = results[k++];
				
			    if (sr.isSuccess()) 
			    {
				    qliModels[i].addQLIError(qliIdToModel.get( recordId ).zilliantStatus 
			    							   + ' QLI has been updated in the database!', true);
			    }
			    else 
			    {
			    	for(Database.Error err : sr.getErrors())
					{
						 qliModels[i].addQLIError('WARNING ' + qliIdToModel.get( recordId ).zilliantStatus 
													 + ' QLI not updated in database Error: ' + err.getMessage(), true);
					}
			    	
			    }
			}
			else
			{
				qliModels[i].addQLIError( qliModels[i].zilliantStatus, true );
			}
			
		}
		
		renderSendButton = false;
		
	}
	
    public static boolean getAccountActive(Quote__c quote) {
        Account relatedAccount = [SELECT Active__c FROM Account WHERE Id = :quote.Account__c];

        if(String.isNotBlank(relatedAccount.Active__c) && relatedAccount.Active__c.toLowerCase() == 'yes') {
            return true;
        }
        
        return false;
    }
    
}
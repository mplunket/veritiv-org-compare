/**
 Objective: Quote__c Controller Extenstion provides an ability to search for products, 
            CRUD on quote line items  
 Developer: Hiremath, Naveen - Bluewolf     
*/
public with sharing class QuotesQuoteContExt {
		
	/**
	 Returns true if search boxes has no data 
	*//*
	private static Boolean validateSearchInput(final String itemNumber, 
										final String description,
										final String vendorName,
										final String vendorProductCode) {
		
		return (!Utils.isNonEmptyString(itemNumber) && 
		        !Utils.isNonEmptyString(description) &&
		        !Utils.isNonEmptyString(vendorName) &&
		        !Utils.isNonEmptyString(vendorProductCode));
		
	}*/
	
	/**
	 When unit price is less than cost, a warning page message must be shown
	*//* 
    private static void generateUnitPriceLessThanCostMessage(String unitPriceLessThanCost) {
    	
    	if(unitPriceLessThanCost != null) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, unitPriceLessThanCost));
    	}
    	
    }*/
    
    /**
     Any list of string will be converted to error page message block
    *//*
    private static void insertErrorPageMessages(List<String> messages, Integer messageCount) {
    	
    	for(Integer i=0; i < messageCount; ++i) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, messages.get(i)));
    	}
    	
    }*/
    
	/**
	 ContExt must always retain a reference to its 
	 model instance
	*/	
	//public final QuotesModel quotesModel    { get; private set; }
	
	/**
	 ProductSearch is independent of QuoteModel's existence
	*/
	//public final ProductModel productSearch { get; private set; }
	
	/**
	 Flag that indicates a valid/invalid quote 
	*//*
	public Boolean isValidQuote             { get; private set; }
	
	public Integer rowIndex					{ get; set; }
	*/
	/**
	 Quote Header command methods
	*//*
	public PageReference doShare() {
    
    	String sharingURL ='/p/share/CustomObjectSharingDetail?parentId='+ quotesModel.getQuote().Id;
    	PageReference sharingPage = new PageReference(sharingURL);
    	sharingPage.setRedirect(true);
    	
    	return sharingPage;    	
    }*/
    /*
    public PageReference doClone(){
    	
    	String cloningURL = '/' + quotesModel.getQuote().Id + '/e?clone=1&retURL=%2F' + quotesModel.getQuote().Id;
    	PageReference clone = new PageReference(cloningURL);
    	clone.setRedirect(true);
    	return clone;
    	 
    }*/
    /*
    public PageReference doSearchOrder(){
    	String searchOrderURL ='http://universe.com/uniweb/OrderLookupCriteria.aspx?environment=PRODUCTION&system='+
    				 quotesModel.getQuote().Account_Legacy_System_Cd__c +
    				'&BillToNum=' + quotesModel.getQuote().Bill_To_Number__c +
    	 			'&BillToName=' + quotesModel.getQuote().Account__c  + 
    	 			'&ShipToNum=' + quotesModel.getQuote().Ship_To_Number__c;    	
    	PageReference searchOrder = new PageReference(searchOrderURL); 
		searchOrder.setRedirect(true);

    	return searchOrder;
    }*/
    /*
	public PageReference doShipToAddress(){
    	
    	PageReference shipToAddrPage = Page.SelectShipToAddress;
    	shipToAddrPage.getParameters().put('id', quotesModel.getQuote().Id);
    	shipToAddrPage.setRedirect(true); 

    	return shipToAddrPage;
    }*/
    /*
    public PageReference doSendToMerchandiser(){
    	
    	PageReference merchandiserPage = Page.FieldSourcingQuoting;
    	merchandiserPage.getParameters().put('id', quotesModel.getQuote().Id);
    	merchandiserPage.setRedirect(true);
    	
    	return merchandiserPage;
    }*/
    /*
    public PageReference doCancel() {
    	
    	PageReference quoteTabPage = new PageReference('/a0O/o');
    	quoteTabPage.setRedirect(true);
    	
    	return quoteTabPage;
    }*/
    /*
    public String linkToChangeOwner {
    	get {
    		return '/' + quotesModel.getQuote().Id +'/a?retURL=%2F' + quotesModel.getQuote().Id;
    	}
    }*/
    
	/**
	 Enables/Disables Create Order
	*//*
	public Boolean showRetry { 
		get {
			return quotesModel.getEnableRetryOnCreateOrder();
		}		
	}*/
	
	/**
	 Returns a pixel size that provides an inline 
	 scroll bar for search results 
	*//*
	public Integer determineProductsSize {
        get {
            return productSearch.getProductsPixelSize();
        }
    }*/
    
    /**
     For each selected product, add it to the Quote Line Item 
    *//*
    public PageReference addToQuote() {
    	
    	quotesModel.addQLI(productSearch);
    	
    	return null;
    	
    }*/ 
    
    /**
     This is a special customizable line item added to the Quote
    *//*
    public PageReference addSpecialLineItem() {
    	
    	quotesModel.addSpecialQLI();
    	
    	return null;
    	
    }*/
    
    /**
     Any line items can be deleted
    *//*
    public PageReference deleteLineItem() {
    	
    	quotesModel.deleteQLI(rowIndex);
    	
    	return null;	
    	
    }*/
    
    /**
     Any line items can be cloned
    *//*
    public PageReference cloneLineItem() {
    	
    	quotesModel.cloneQLI(rowIndex);
    	
    	return null;
    }*/
    
    /**
     Performs calculation on Extended Price
    *//*
    public PageReference calcExtendedPrice() {
    		
    	generateUnitPriceLessThanCostMessage(quotesModel.calcExtendedPrice(rowIndex));
    	
    	return null;
    		
    }*/
    
    /**
     Show Pricing and Availability for a product
    *//*
    public PageReference showPandAForProduct() {
    	
    	generateUnitPriceLessThanCostMessage(quotesModel.showPandAForProduct(rowIndex));
    	
    	return null;
    	
    }*/
    
    /**
     Show Pricing and Availability for a product and 
     display message for price mismatch
    *//*
    public PageReference getPandAForProduct() {
    
    	List<String> messages = new List<String>();
    	messages 			  = quotesModel.getPandAForProduct(rowIndex);
    	
    	insertErrorPageMessages(messages, messages.size()-1);
    	
    	if(!messages.isEmpty()) {
    		generateUnitPriceLessThanCostMessage(messages.get(messages.size()-1));    		
    	}
    	
    	return null;
    	
    }*/
    
    /**
     Add quote line items to this quote 
    *//*
    public PageReference saveLineItems() {
    
    	List<String> messages = new List<String>(); 
    	messages              = quotesModel.validateSave();
    	
    	insertErrorPageMessages(messages, messages.size());
    	
    	if(!messages.isEmpty()) {
    		 
    		 messages.clear();
    		 return null;
    		 
    	}
    	
    	Savepoint sp = Database.setSavepoint();
        try {
        	
        	quotesModel.saveQLI();
        	            
        } catch(DmlException dmle) {
            
            for (Integer i=0; i < dmle.getNumDml(); i++)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmle.getDmlMessage(i)));

            Database.rollback(sp);
            return null;
            
        } catch(Exception e) {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            
            Database.rollback(sp);
            return null;
        } 
        
    	return null;
    		
    }*/
    
    /**
     Adds a freight to the selected products container 
    *//*
    public PageReference addFreight() {
    	
    	quotesModel.addFreight();
    	return null;
    		
    }*/
    
	/**
	 Perform a search for any matching products
	*//*
	public PageReference search() {
		
		String itemNumber, description, vendorName, vendorProductCode;
		
		Product2 product  = productSearch.getProduct();
		itemNumber        = product.productCode;
		description       = product.Description;
		vendorName        = productSearch.getVendor().Name;
		vendorProductCode = product.Vendor_Product_Code__c;
		
		
		// With no search criteria there is no point 
		// in invoking product search
		if(validateSearchInput(itemNumber, description, vendorName, vendorProductCode)) {
			
			 //Clean the search results section for any 
			 //residual  
			
			productSearch.clear();
			return null;	
			
		}

		if(Utils.isWildSearch(description, Consts.WILD_CARD_OPERATOR) || 
		   Utils.isWildSearch(vendorName, Consts.WILD_CARD_OPERATOR)) {
			
			productSearch.wild();
			 
		} else {
		 	
		 	productSearch.exact();
		 	 	
		}
		
		return null;
	}*/
	
	/**
	 Validates create order request before redirecting to a new page 
	*//*
	public PageReference validateCreateOrder() {
		
		List<String> anyErrorMessages = quotesModel.validateCreateOrder();
		 
		insertErrorPageMessages(anyErrorMessages, anyErrorMessages.size());
		
		if(!anyErrorMessages.isEmpty()) return null;
		
		PageReference createOrder = Page.CreateOrder;
		createOrder.getParameters().put('id', quotesModel.getQuote().Id);
			
		return createOrder.setRedirect(false);
			
	}*/	
	
	/**
	 Page action method to execute a Create Order request
	*//*
	public PageReference createOrder() {
	
		List<String> anyErrorMessages = quotesModel.createOrder();
		
		if(anyErrorMessages.isEmpty()) return null;
		
		if(anyErrorMessages.size() >= 1 && 
		   anyErrorMessages.get(0).startsWith('Status Code: ')) {
		
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, anyErrorMessages.get(0)));
				
		} else {
		
			insertErrorPageMessages(anyErrorMessages, anyErrorMessages.size());
		}
		
		return null;
			
	}*/
	
	/**
	 Handles validating the Quote before proceeding with the request
	*/
	/*
	public PageReference sendToMerchandiser() {
	
		String message = quotesModel.validateSendToMerchandiser();
		
		if(message != null) { 
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));			
		}
			
		return quotesModel.getSendToMerchandiser();
			
	}
	*/
	
	/**
	 Action method that sets the stage for the Merchandiser
	*//*
	public PageReference saveMerchandiserStage() {
	
		List<String> anyErrorMessages = quotesModel.saveMerchandiserStage();
		insertErrorPageMessages(anyErrorMessages, anyErrorMessages.size());
		
		return returnToQuotes();
					
	}*/
	
	/**
	 Helps in re-directing users to the Quotes page
	*//*
	public PageReference returnToQuotes() {
		
		return quotesModel.getQuotes();
		
	}*/
	
	/**
	 Explicit constructor that accepts a standardController reference
	*//*
	public QuotesQuoteContExt(ApexPages.StandardController standardController) {		
		
		Quote__c quote = (Quote__c)standardController.getRecord();
		
	
		//With a null Quote Id no operations must be performed
		if(quote.Id == null) {
			
			isValidQuote = Consts.FAILURE;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Consts.INVALID_QUOTE, Consts.EMPTY_STRING));
			return;
				
		}
		
		//Default this to the created date
		if(quote.Date_Quoted__c == null)
			quote.Date_Quoted__c = quote.CreatedDate.date();
		
		//Flag this as a valid quote and proceed with other operations
		this.isValidQuote  = Consts.SUCCESS;
		
		
		// Hold on to productModel that has freight lines and 
		// servicing division references
		this.productSearch  = new ProductModel(new Product2(), 
							  	Freight_Lines__c.getAll(), 
							  	ServicingDivisionServices.getActiveServiceDivisions());
		
		
		// QuotesModel maintains a reference to Quote__c 
		// and an aggregation relationship with ProductModel
		this.quotesModel   = new QuotesModel(quote, productSearch);
		
		
	}*/
}
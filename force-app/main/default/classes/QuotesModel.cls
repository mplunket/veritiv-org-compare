/**
 Objective: Container that holds all the business logic attached 
 			with Quote__c and handles all the processing  
 			delegated by QuotesQuoteContExt
 Developer: Hiremath, Naveen - Bluewolf     
*/
public with sharing class QuotesModel {
	/*
	private final static String DIRECT_QUOTE = 'Direct';
	private final static String WITH_MERCHANDISER = 'With Merchandiser';
	*/
	/**
	 Maintain a reference to Quote__c object
	*/
	private final Quote__c quote;
	
	/**
	 Immutable reference to Quote Line Item Model
	*/
	private final QuoteLineItemModel quoteLineItemModel;
	
	/**
	 Quote__c enjoys a "has-a" relationship with Product2 
	*/
	private final ProductModel productModel;
	
	private Boolean enableRetryOnCreateOrder;
	
	/**
	 Accessor method that returns a reference to Quote__c
	*/
	public Quote__c getQuote() {
		
		return this.quote;
		
	}
	
	/**
	 Getter that returns a reference to the aggregated
	 product Model instance 
	*/
	public ProductModel getProductModel() {
		
		return this.productModel;
		
	}
	
	/**
	 Getter that returns a reference to the aggregated
	 Quote Line Item Model instance
	*/
	public QuoteLineItemModel getQuoteLineItemModel() {
		
		return this.quoteLineItemModel;
	}
	
	/**
	 Calculate Pricing and Availability for this product
	*//*
	public List<String> getPandAForProduct(final Integer rowIndex) {
		
		return quoteLineItemModel.getPandAForProduct(rowIndex);
			
	}*/
	/*
	public Boolean getEnableRetryOnCreateOrder() {
		
		return this.enableRetryOnCreateOrder;
	}*/
	/*
	public PageReference getQuotes() {
	
		PageReference quotes = Page.Quotes;
		quotes.getParameters().put('id', this.quote.Id);
		
		return quotes.setRedirect(false); 
			
	}*/
	/*
	public PageReference getSendToMerchandiser() {
	
		PageReference merchandiserQuoting = Page.SendToMerchandiser;
		merchandiserQuoting.getParameters().put('id', this.quote.Id);
		
		return merchandiserQuoting.setRedirect(false);
			
	}*/
	/*
	public void setEnableRetryOnCreateOrder(Boolean value) {
		
		this.enableRetryOnCreateOrder = value;
		
	}*/
	
	/**
	 Adding Quote Line Items on a Quote is dependent on the 
	 product search results
	*//*
	public void addQLI(ProductModel productSearch) {

		quoteLineItemModel.createQLI(productSearch.getSearchResults());
			
	}*/
	
	/**
	 Special Line Item is a default customizable QLI on the quote
	*//*
	public void addSpecialQLI() {
		
		quoteLineItemModel.createSpecialQLI();
	}*/
	
	/**
	 Move the selected line item to thrash container
	*//*
	public void deleteQLI(final Integer rowIndex) {
		
		quoteLineItemModel.deleteQLI(rowIndex);
		
	}*/
	
	/**
	 Clone the line item at the given index 
	*//*
	public void cloneQLI(final Integer rowIndex) {
	
		quoteLineItemModel.cloneQLI(rowIndex);
			
	}*/
	
	/**
	 Perform calculation on Extended Price
	*//*
	public String calcExtendedPrice(final Integer rowIndex) {
	
		return quoteLineItemModel.calcExtendedPrice(rowIndex);
			
	}*/
	
	/**
	 Show Pricing and Availability for this product
	*//*
	public String showPandAForProduct(final Integer rowIndex) {
		
		return quoteLineItemModel.showPandAForProduct(rowIndex);
			
	}*/
	/*
	public List<String> validateCreateOrder() {
	
		List<String> pageMessages = new List<String>();
		
		if(quote.Account__r.RecordType.Name == 'Prospect') {	
				
			pageMessages.add('Orders cannot be created for Prospect accounts.');
			
		}
		
		if(quote.Ship_To__c == null) {
			
			pageMessages.add('A Ship To address must be selected before creating an order.  Please go back to the quote and click the "Select Ship To Address" button before clicking the "Create Order" button.');
			
		}
		
		if(quote.Expiration_Date__c < System.today()) {
			
			pageMessages.add('This quote has expired and cannot be submitted for an order request.');
			
		}
		
		pageMessages.addAll(quoteLineItemModel.validateLineItems(productModel.getFreightCodes()));
		
		this.enableRetryOnCreateOrder = (pageMessages.isEmpty()) ? Consts.ENABLE : Consts.DISABLE;
		
		return pageMessages;
		
	}*/
	
	/**
	 Orders can be created against a quote
	*//*
	public List<String> createOrder() {
		
		List<String> pageMessages = quoteLineItemModel.createOrder();
					
		return pageMessages; 
			
	}*/
	
	/**
	 Before line items are saved they must be checked for freight lines
	 and price 
	*//*
	public List<String> validateSave() {
		
		List<String> messages = new List<String>();
		
		// Quote header validation rules
        if(this.quote.Shipment_Method__c == DIRECT_QUOTE && 
           !quoteLineItemModel.validateFreightLines(productModel.getFreightCodes())) {
        	  
            messages.add(Consts.PAGE_MSG_NO_FREIGHT_LINES_ON_DIRECT_QUOTE);
            return messages;
            
        }
        
        messages = quoteLineItemModel.validateCostUOMPriceUOMMismatch();
        if(!messages.isEmpty()) return messages;
        
        return messages;
        
	}*/
	
	/**
	 Invokes upsert on the selected line items and delete on
	 the line items that were moved to thrash
	*//*
	public void saveQLI() {
	
		quoteLineItemModel.upsertQLIs();
		quoteLineItemModel.deleteQLIs();
		
	}*/
	
	/**
	 Add the selected freight to our selected products basket
	*//*
	public void addFreight() {
	
		String freightName = productModel.getSelectedFreight();
		String freightCode = productModel.getSelectedFreightCode();
		
		if(freightName != Consts.SELECT_OPTION_NONE && 
		   freightCode != Consts.SELECT_OPTION_NONE) {
			
			quoteLineItemModel.createFreight(freightCode, freightName);
			
		}
		
	}*/
	
	/**
	 Check to see the state of Quote_Stage__c
	*//*
	public String validateSendToMerchandiser() {
	
		String message;
		if(this.quote.Quote_Stage__c == WITH_MERCHANDISER) {
			message = 'This Quote is already marked as \'With Merchandiser\'.  If you would like to update the Primary Merchandising Segment, please do so, otherwise, please hit \'Cancel\' to return to the Quote.';	
		}
		
		return message;
		
	}*/
	
	/**
	 Update the quote stage
	*//*
	public List<String> saveMerchandiserStage() {
	
		List<String> messages = new List<String>();		
		this.quote.Quote_Stage__c = WITH_MERCHANDISER;
		
		try {
			update quote;
		}
		catch(Exception e) {			
			messages.add(e.getMessage());
		}	
		
		return messages;
		
	}*/
	
	/**
	 Identifies the default service division for this 
	 quote
	*/
	private void selectDefaultDivison() {
	
		List<String> defaultDivisionToBeSelected = new List<String>();
		 
		for(Servicing_Division__c div :productModel.getServiceDivisions()) {
			
			if(quote.Servicing_Division_Name__c == div.Name) {
				
				defaultDivisionToBeSelected.add(div.Id);
				break;				
			}
			
		}
		
		productModel.setSelectedDivisions(defaultDivisionToBeSelected);	
	}
	
	/**
	 Instantiates QuotesModel with a quote and a ProductModel 
	 that maintains a 'has-a' relationship
	*/
	public QuotesModel(Quote__c quote, ProductModel productModel) {
		
		this(quote);
		
		/*
		 Maintain an aggregation to Product Model that 
		 facilitates product search 
		*/
		this.productModel = productModel;
		
		/*
		 The default division name for this quote must be 
		 selected
		*/
		this.selectDefaultDivison();
		
		/**
		 A Quote can have existing Quote Line Items 
		*/
		/*
		List<Quote_Line_Item__c> existingQuoteLineItems = QuoteLineItemServices.getQuoteLineItems(quote.Id);
		this.quoteLineItemModel = (!existingQuoteLineItems.isEmpty()) ?
								  new QuoteLineItemModel(this, new Quote_Line_Item__c(), existingQuoteLineItems) :
								  new QuoteLineItemModel(this, new Quote_Line_Item__c());
		*/
	}
	
	/**
	 Explicit constructor that accepts a Quote__c reference
	 and with no aggregations 
	*/
	public QuotesModel(Quote__c quote) {
		
		this.quote = QuoteServices.getQuote(quote.Id);
			
	}

}
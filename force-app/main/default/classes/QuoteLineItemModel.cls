/**
 Objective: Quote Line Item Model class that incorporates all the 
 			logic needed for the Quote_Line_Item__c object and 
 			maintains a child-parent relationship with Quote__c
 Developer: Hiremath, Naveen - Bluewolf     
*/
public with sharing class QuoteLineItemModel {
	/*
	private static final Integer DEFAULT_PRODUCT_QUANTITY = 1;
	private static final Integer DEFAULT_QUANTITY_UNIT_FACTOR = 1;
	*/
	/**
	 Maintain a reference to the Quote_Line_Item__c object
	*/
	public final Quote_Line_Item__c quoteLineItem;
	
	/**
	 Must always maintain a master relationship 
	 with QuotesModel
	*/
	private final QuotesModel quotesModel;
	
	/**
	 Selected products will be immutable by nature 
	*/
	private final List<QuoteLineItemModel> selectedProducts;
	
	/**
	 Thrash basket that holds all the deleted line items
	*/
	private final List<Quote_Line_Item__c> qlisToDelete;
	
	/**
	 Stores list of errors relating to QLI for Zilliant Integration.
	*/
	private List<String> qliErrors = new List<String>();
	
	/**
	 Properties that depict a product's details 
	*/
	private Opportunity extendedCost;
	private Boolean showPandA;
	private Boolean enableUOM;
	private SelectOption[] quantityUOMs;
	private SelectOption[] priceUOMs;
	private String gtmPercent;
	private PricingAndAvailability PandA;
	private Integer itemSequence;
	
	/* Related Product2 to the Quote Line Item */
	public ProductModel prodModel;
	
	/**
	 Fields needed for Update Pricing functionality.
	*/
	public PricingMatrix__c matrix;
	public Decimal listDown;
	public Decimal costUp;
	public String zilliantStatus;
	public String GTMPercentValue;
	
	/**
	 Accessor that hands over the Quote Line Item reference 
	*/
	public Quote_Line_Item__c getQuoteLineItem() {
	
		return this.quoteLineItem;	
	}
	
	/**
	 Accessor that hands over the Pricing Matrix reference 
	*/
	public PricingMatrix__c getMatrix() { 
	
		return this.matrix;	
	}
	
	/**
	 Accessor that returns the state of the List Down field
	*/
	public Decimal getListDown() { 
	
		if(this.listDown == null)
		{
			this.listDown = 0;
		}
		
		return this.listDown;	
	}
	
	/**
	 Accessor that returns the state of the Cost Up field
	*/
	public Decimal getCostUp() { 
	
		if(this.costUp == null)
		{
			this.costUp = 0;
		}
		
		return this.costUp;	
	}
	
	/**
	 Accessor that returns the status after attempting to send to Zilliant
	*/
	public String getZilliantStatus() { 
	
		if(this.zilliantStatus == null)
		{
			this.zilliantStatus = '';
		}
		
		return this.zilliantStatus;	
	}
	
	/**
	 Accessor that sets the status after being sent to Zilliant
	*/
	public void setZilliantStatus(String status) { 
	
		this.zilliantStatus = status;	
	}

	/**
	 Accessor that sets the state of the List Down field
	*/
	public void setListDown(Decimal value) { 
	
		this.listDown = value;	
	}
	
	/**
	 Accessor that sets the state of the Cost Up field
	*/
	public void setCostUp(Decimal value) { 
	
		this.costUp = value;
	}
	
	/**
	 Accessor that hands over the Quote reference 
	*/
	public QuotesModel getQuotesModel() {
	
		return this.quotesModel;
			
	}
	
	/**
	 Accessor that hands over the search results reference 
	*/
	public List<QuoteLineItemModel> getSelectedProducts() {
	
		return this.selectedProducts;
			
	}
	
	/**
	 Accessor that returns the state of extendedCost
	*/
	public Opportunity getExtendedCost() {
		
		  if(this.extendedCost == null) {
		  	 this.extendedCost = new Opportunity(Amount=0);
		  }
		  
		  return this.extendedCost;		  
	}
	
	/**
	 Accessor that returns the state of showPandA
	*/
	public Boolean getShowPandA() {
		
		if(this.showPandA == null) {
			 this.showPandA = Consts.DISABLE;
		}
        
        return this.showPandA;
	}
	
	/**
	 Accessor for enableUOM
	*/
	public Boolean getEnableUOM() {
		
		 if(this.enableUOM == null) { 
		 	this.enableUOM = Consts.DISABLE;
		 }
         
         return this.enableUOM;
	}
	
	/**
	 Accessor for quantityUOMs
	*/
	public SelectOption[] getQuantityUOMs() {
		
		 if(this.quantityUOMs ==  null) {
		 	 this.quantityUOMs = new SelectOption[0];
		 }
		 
         return quantityUOMs;            
	}
	
	/**
	 Accessor for priceUOMs
	*/
	public SelectOption[] getPriceUOMs() {
		
		if(this.priceUOMs ==  null) { 
			this.priceUOMs = new SelectOption[0];
		}
        return this.priceUOMs;
            
	}
	
	/**
	 Accessor for gtmPercent
	*/
	public String getGtmPercent() {
		
		gtmPercent = '';
    	
    	if(quoteLineItem.Cost__c != null && 
    	   quoteLineItem.Price__c != null && 
    	   quoteLineItem.Price__c != 0) {
    		
    		Decimal cost = quoteLineItem.Cost__c;
			Decimal percent =  (1 - cost.divide(quoteLineItem.Price__c, 4, System.RoundingMode.HALF_UP)) * 100;
		
			percent = percent.setScale(1, System.RoundingMode.HALF_UP);
			this.gtmPercent = percent.toPlainString();
			this.gtmPercent += '%';
							
			
    	} else if(quoteLineItem.GTM_percent__c == null) {
    		
    		//Do nothing as of now
    		
    	} else {
    			
    		this.gtmPercent = String.valueOf(quoteLineItem.GTM_percent__c) + '%';
    		    		
    	}
    	
    	return this.gtmPercent;
    		
	}
	
	/* Returns Raw Value of GTM Percent */
	public String getGTMPercentValue() {
		
		String value = '0.0';
		
		if(this.GTMPercentValue == NULL)
		{
			if(this.quoteLineItem.GTM_Percent__c != NULL)
			{
			    this.GTMPercentValue = String.valueOf(this.quoteLineItem.GTM_Percent__c);
			}
			else
			{
			    this.GTMPercentValue = value;
			}
		}
		
		return this.GTMPercentValue;
    		
	}
	
	/* Set Raw Value of GTM Percent */
	public void setGTMPercentValue(String gtmPercent) {
		
		this.GTMPercentValue = gtmPercent;
	}
	
	/**
	 Accessor for PandA
	*/
	public PricingAndAvailability getPandA() {
		
		 if(this.PandA == null) {
		 	 this.PandA = new PricingAndAvailability();
		 }
		 
         return this.PandA;            
	}
	
	/**
	 Line Items should be reordered via item sequence numbers
	*/
	public Integer getItemSequence() {
	
		return this.itemSequence;
			
	}
	
	/*
	 Generates the next sequence # for a line item
	*/
	public Integer getNextItemSequence() {
		
		return this.selectedProducts.size() + 1;
		
	}
	
	/**
	 Query the current count of selected line items
	*/
	public Integer getCount() {
	
		return this.selectedProducts.size();	
	}
	
	/**
	 Every time a product is selected we need to sum up the existing
	 product's Extended_Price__c
	*/
	public Decimal getExtendedPriceRunningTotal() {
		
		Decimal extendedPriceRunningTotal = 0.0;
		
		for(QuoteLineItemModel currentQLIModel :selectedProducts) {
				if(currentQLIModel.quoteLineItem.Extended_Price__c != null)
	        		extendedPriceRunningTotal += currentQLIModel.quoteLineItem.Extended_Price__c;
		}
		
		return extendedPriceRunningTotal;
	}
	
	/**
	 Every time a product is selected we need to sum up the existing
	 product's GTM_CAS__c
	*/
	public Decimal getGTMRunningTotal() {
		
		Decimal GTMRunningTotal = 0.0;
		
		for(QuoteLineItemModel currentQLIModel :selectedProducts) {
				if(currentQLIModel.quoteLineItem.GTM_CAS__c != null)
	        		GTMRunningTotal += currentQLIModel.quoteLineItem.GTM_CAS__c;
		}
		
		return GTMRunningTotal; 
	}
	
	/**
	 Returns the current list of errors for the QLI
	*/
	public List<String> getqliErrors() {
	
		return this.qliErrors;	
	}
	
	/**
	 Mutator for qliErrors
	*/
	public void setqliErrors(List<String> errors) {
		
		this.qliErrors = errors;
		
	}
	
	public void addQLIError(String error, Boolean isNewError) {
		if( isNewError)
		{
			Integer i = 0;
			for(String exError : this.qliErrors)
			{
				// Adding Error -> Error Already Exists -> Do Nothing!
				if(error == exError)
				{
					return;
				}
				i++;
			}
			
			// Adding Error -> Error Not Found -> Add To List
			this.qliErrors.add( error );
		}
		else
		{
			Integer i = 0;
			for(String exError : this.qliErrors)
			{
				// Removing Error -> Error Found to Remove -> Remove Index of Error 
				if(error == exError)
				{
					this.qliErrors.remove(i);
					return;
				}
				i++;
			}
		}
		
	}
	
	/**
	 Mutator for extendedCost
	*/
	public void setExtendedCost(Opportunity value) {
		
		this.extendedCost = value;
		
	}
	
	/**
	 Mutator for showPandA
	*/
	public void setShowPandA(Boolean value) {
		
		this.showPandA = value;
		
	}
    
    /**
	 Mutator for enableUOM
	*/
    public void setEnableUOM(Boolean value) {
    
    	this.enableUOM = value;
    		
    }
    
    /**
	 Mutator for quantityUOMs
	*/
    public void setQuantityUOMs(SelectOption[] value) {
    	
    	this.quantityUOMs = value;
    }
    
    /**
	 Mutator for priceUOMs
	*/
    public void setPriceUOMs(SelectOption[] value) {
    	
    	this.priceUOMs = value;
    	
    }
    
    /**
	 Mutator for gtmPercent
	*/
    public void setGtmPercent(String value) {
    	
    	this.gtmPercent = value;
    	
    }  
    
    /**
     Mutator to override the sequencing of line items
    */
    public void setItemSequence(Integer value) {
    
    	this.itemSequence = value;	
    	
    }
    
    /**
	 Mutator for PandA
	*/
    public void setPandA(PricingAndAvailability value) {
    	
    	this.PandA = value;
    }
	
	/**
	 For all the selected products, after a product search, create
	 corresponding Quote Line Items and maintain this selection to
	 support CRUD operations
	*//*
	public void createQLI(final List<ProductModel> productSearchResults) {
		
		for(ProductModel searchResult :productSearchResults) {
		
			if(searchResult.getIsSelected()) {
				
				Product2 currentProduct = searchResult.getProduct();
				 
				Quote_Line_Item__c qli 			= new Quote_Line_Item__c();
                qli.Product__c 		   			= currentProduct.Id;
                qli.Product__r 		   			= currentProduct;
                qli.Product_Code__c    			= currentProduct.ProductCode;
                qli.Unisource_Item__c  			= currentProduct.Unisource_Item_Number_U_number__c;
                qli.Vendor_Item__c              = currentProduct.Vendor_Product_Code__c;
                qli.Product_Description__c      = currentProduct.Description;
                qli.Unisource_Item__c           = currentProduct.Unisource_Item_Number_U_number__c;
                qli.Vendor_Name__c              = currentProduct.Vendor__c;                
                qli.Qty__c                      = DEFAULT_PRODUCT_QUANTITY;
                qli.Quantity_unit_of_measure__c = currentProduct.Unit_of_Measure__c;
                qli.Price_unit_of_measure__c    = currentProduct.Pricing_Costing_UOM__c;
                qli.Costing_unit_of_measure__c  = currentProduct.Pricing_Costing_UOM__c;
                qli.Quantity_Unit_Factor__c     = DEFAULT_QUANTITY_UNIT_FACTOR;
                qli.Price_Unit_Factor__c        = currentProduct.Conversion_Factor__c;
                qli.Cost_Unit_Factor__c         = currentProduct.Conversion_Factor__c;
                qli.Quote__c                    = this.quotesModel.getQuote().Id;
                qli.Projected_Delivery_Date__c  = this.quotesModel.getQuote().Requested_Delivery_Date__c;

				// Make non integer product codes special products
                try {
                	Integer.valueOf(currentproduct.ProductCode.substring(0,1));
                }
                catch(Exception e) {
	                qli.Special_Product__c = Consts.ENABLE;
                }
             
             	addToSelectedProducts(qli, getNextItemSequence()); //addToSelectedProducts(qli);   
			}	
			
		}
		
	}
	
	/**
	 Special Quote Line Items for purposes where they want to add their own
	 custom entry
	*//*
	public void createSpecialQLI() {
	
		Quote_Line_Item__c qli         = new Quote_Line_Item__c();
        qli.Quote__c           		   = this.quotesModel.getQuote().Id;
        qli.Special_Item__c            = Consts.ENABLE;
        qli.Projected_Delivery_Date__c = this.quotesModel.getQuote().Requested_Delivery_Date__c;        
    
    	addToSelectedProducts(qli, getNextItemSequence()); //addToSelectedProducts(qli);
        	
	}*/
	
	/**
	 Freights are special products whose quantity will be 1
	*//*
	public void createFreight(final String freightCode, final String freightName) {
	
		Quote_Line_Item__c qli     = new Quote_Line_Item__c();
		qli.Quote__c               = this.quotesModel.getQuote().Id;
		qli.Product_Code__c        = freightCode;
		qli.Product_Description__c = freightName;
		qli.Qty__c                 = DEFAULT_PRODUCT_QUANTITY;
		qli.Special_Product__c     = Consts.ENABLE;
		
		addToSelectedProducts(qli, getNextItemSequence()); //addToSelectedProducts(qli);
			
	}*/
	
	/**
     For each selected/existing line item on the quote create an Order request;
     must follows item sequence #  
    *//*
    public List<String> createOrder() {
    	
    	Quote__c quote = this.quotesModel.getQuote();
    		 
        //Assign header values to request header
        OrderRequest ordReq = new OrderRequest();
        ordReq.Request.Header.QuoteNum = quote.Name;
        ordReq.Request.Header.BillToCode = quote.Account__r.AccountNumber;
        ordReq.Request.Header.BillToName = quote.Account__r.Name;
        ordReq.Request.Header.CustomerContactName = quote.Customer_Contact__r.Name;
        ordReq.Request.Header.ShipToCode = quote.Ship_To_Number__c;
        ordReq.Request.Header.ShipToName = quote.Ship_To__r.Name;
        ordReq.Request.Header.ShipToStreet = quote.Ship_To__r.Address_Line1__c + quote.Ship_To__r.Address_Line2__c == null? '' :', ' + quote.Ship_To__r.Address_Line2__c;
        ordReq.Request.Header.ShipToCity = quote.Ship_To__r.City__c;
        ordReq.Request.Header.ShipToState = quote.Ship_To__r.State__c;
        ordReq.Request.Header.ShipToZip = quote.Ship_To__r.Postal_Code__c;
        ordReq.Request.Header.DivisionCode = quote.Servicing_Division__c;
        ordReq.Request.Header.SystemCode = quote.System_Code__c;
        ordReq.Request.Header.RequestedDeliveryDate = quote.Requested_Delivery_Date__c;
        ordReq.Request.Header.ShipmentMethod = quote.Shipment_Method__c;        
        ordReq.Request.Header.CustomerComments = quote.Comments__c;
        ordReq.Request.Header.PoNumber = quote.PO_Number__c;
        
        Double unitPriceTotal = 0; 
        orderSelectedProductsByItemSequence();
        for(QuoteLineItemModel selectedProduct :this.selectedProducts) {
        	
        	Quote_Line_Item__c qli = selectedProduct.quoteLineItem;
        	
        	 //Validation rules passed, continue
            OrderRequest.DetailClass detail = new OrderRequest.DetailClass();

            detail.Quantity = qli.Qty__c;
            detail.QuantityUOM = qli.Quantity_unit_of_measure__c;
            detail.ProjectedDeliveryDate = qli.Projected_Delivery_Date__c;
            detail.ProductCode = qli.Product_Code__c;
            detail.ProductDescription = qli.Product_Description__c;
            detail.UnitPrice = qli.Price__c;
            detail.UnitPriceUOM = qli.Price_unit_of_measure__c;
            detail.UnitCost = qli.Cost__c;
            // Temporarily stop passing BidNumber field as per Michelle on 8/10
            //detail.BidNumber = qli.Bid_number_Contract_number__c;

            unitPriceTotal += qli.Price__c == null? 0: qli.Price__c;
            ordReq.Request.Details.add(detail);
        	
        }
        
        List<String> messages = new List<String>();
        ordReq.Request.Header.TotalPrice = unitPriceTotal;
        try {
            ordReq.postData();
        } catch(Exception e) {
            messages.add(e.getMessage());
            return messages;             
        }
        
        messages.add('Status Code: ' + ordReq.Response.StatusCode + ', Status Message: ' + ordReq.Response.StatusMessage);
    
        if(ordReq.Response.StatusCode == '202') {
            try {
            	
                Double numberTimesSubmitted = 0;
                if(quote.Number_of_Orders_Submitted__c == null)
                    numberTimesSubmitted = 1;
                else
                    numberTimesSubmitted = quote.Number_of_Orders_Submitted__c + 1;
                    
                Quote__c quoteToUpdate = new Quote__c( Id=quote.Id,
                                                        Quote_Stage__c = 'Won', 
                                                        Number_of_Orders_Submitted__c = numberTimesSubmitted,
                                                        Last_Submitted_Timestamp__c = System.now());                
                update quoteToUpdate;
                
                Task taskToInsert = new Task(WhoId=quote.Customer_Contact__c, WhatId=quote.Id, OwnerId=UserInfo.getUserId());
                taskToInsert.Subject = 'Quote Converted to Order';
                taskToInsert.Description = '' + ordReq.Request.Header;
                for(OrderRequest.DetailClass detail : ordReq.Request.Details)
                    taskToInsert.Description += '\n\n' + detail;
                taskToInsert.Status = 'Completed';
                taskToInsert.Priority = 'Normal';
                taskToInsert.ActivityDate = System.today();
                
                quotesModel.setEnableRetryOnCreateOrder(Consts.DISABLE);
                
                insert taskToInsert;
                                
            } catch(Exception e) {  
            	              
                messages.add(e.getMessage());
                return messages;
                
            }
        }
        
        return messages;
        	
    }*/
	
	/**
	 Move the selected product to a trash container and get rid-off it from the 
	 selected products basket
	*//*
	public void deleteQLI(final Integer rowIndex) {	
		
        if(selectedProducts[rowIndex].quotelineItem.Id != null) {
        	 qlisToDelete.add(selectedProducts[rowIndex].quoteLineItem);
        }
        
        selectedProducts.remove(rowIndex);
    	
    	// Re order the item sequence numbers after each delete 
        reOrderItemSequence(rowIndex);
         	
	}*/
	
	/**
	 Make an exact copy of this quote line item
	*//*
	public void cloneQLI(final Integer rowIndex) {
	
		QuoteLineItemModel oldQLIModel     = selectedProducts.get(rowIndex);
        QuoteLineItemModel newQLIModel     = createQuoteLineItemModel(oldQLIModel.quoteLineItem.clone(false, true), getNextItemSequence());
        newQLIModel.quoteLineItem.Quote__c = this.quotesModel.getQuote().Id;
        
        Integer newItemMustBeAddedAfterTheClonedItem = rowIndex + 1;
        selectedProducts.add(newItemMustBeAddedAfterTheClonedItem, newQLIModel);
        
	}*/
	/*
	public String calcExtendedPrice(final Integer rowIndex) {
	
		assignUnitFactors(selectedProducts[rowIndex]);
        Double quantity = selectedProducts[rowIndex].quoteLineItem.Qty__c;
        Double quantityUnitFactor = selectedProducts[rowIndex].quoteLineItem.Quantity_Unit_Factor__c;
        Double price = selectedProducts[rowIndex].quoteLineItem.Price__c;
        Double priceUnitFactor = selectedProducts[rowIndex].quoteLineItem.Price_Unit_Factor__c;
        Double cost = selectedProducts[rowIndex].quoteLineItem.Cost__c;
        Double costUnitFactor = selectedProducts[rowIndex].quoteLineItem.Cost_Unit_Factor__c;
        
        if(quantity != null && price != null && priceUnitFactor != null && quantityUnitFactor != null) {
            if(priceUnitFactor > 0)
                if(quantityUnitFactor >= 0)
                    selectedProducts[rowIndex].quoteLineItem.Extended_Price__c = (price / priceUnitFactor) * quantityUnitFactor * quantity;
                else
                    selectedProducts[rowIndex].quoteLineItem.Extended_Price__c = ((price / priceUnitFactor) / Math.abs(quantityUnitFactor)) * quantity;
            else
                if(quantityUnitFactor >= 0)
                    selectedProducts[rowIndex].quoteLineItem.Extended_Price__c = price * Math.abs(priceUnitFactor) * quantityUnitFactor * quantity;
                else
                    selectedProducts[rowIndex].quoteLineItem.Extended_Price__c = ((price * Math.abs(priceUnitFactor)) / Math.abs(quantityUnitFactor)) * quantity;
                    
            selectedProducts[rowIndex].quoteLineItem.GTM_CAS__c = selectedProducts[rowIndex].quoteLineItem.Extended_Price__c - selectedProducts[rowIndex].getExtendedCost().Amount;
        }
        
        if(quantity != null && cost != null && costUnitFactor != null && quantityUnitFactor != null) {
            Double extendedCost = 0;
            if(costUnitFactor > 0)
                if(quantityUnitFactor >= 0)
                    extendedCost = (cost / costUnitFactor) * quantityUnitFactor * quantity;
                else
                    extendedCost = ((cost / costUnitFactor) / Math.abs(quantityUnitFactor)) * quantity;
            else
                if(quantityUnitFactor >= 0)
                    extendedCost = cost * Math.abs(costUnitFactor) * quantityUnitFactor * quantity;
                else
                    extendedCost = ((cost * Math.abs(costUnitFactor)) / Math.abs(quantityUnitFactor)) * quantity;
            selectedProducts[rowIndex].extendedCost.Amount = extendedCost;
            Double extendedPrice = selectedProducts[rowIndex].quoteLineItem.Extended_Price__c == null? 0: selectedProducts[rowIndex].quoteLineItem.Extended_Price__c;
            selectedProducts[rowIndex].quoteLineItem.GTM_CAS__c = extendedPrice - extendedCost;
        }
        
        return (price < cost) ? Consts.PAGE_MSG_UNIT_PRICE_LESS_THAN_COST : null;
              	
	}*/
	/*
	public String showPandAForProduct(final Integer rowIndex) {
	
		selectedProducts[rowIndex].showPandA = (selectedProducts[rowIndex].showPandA) ?
            											Consts.DISABLE:
            											Consts.ENABLE;
        
        return calcExtendedPrice(rowIndex);
        	
	}*/
	/*
	public List<String> getPandAForProduct(final Integer rowIndex) {
		
		List<String> messages = new List<String>();
        getPandAData(selectedProducts[rowIndex]);
        
        if(selectedProducts[rowIndex].PandA.Response.Errors.size() > 0) {
            for(PricingAndAvailability.ErrorsClass ec : selectedProducts[rowIndex].PandA.Response.Errors)
             	messages.add(ec.description);
        }

        fillUOM(selectedProducts[rowIndex]);
        assignUnitFactors(selectedProducts[rowIndex]);
        assignQLIValues(selectedProducts[rowIndex]);
        
        String unitPriceLessThanCost = calcExtendedPrice(rowIndex);        
        messages.add(unitPriceLessThanCost);

        return messages;
    }*/
    /*
    public void deleteQLIs() {
    	
    	if(!qlisToDelete.isEmpty())
    		delete qlisToDelete;
    	
    }*/
    /*
    public void upsertQLIs() {
    	
        List<Quote_Line_Item__c> qlisToUpsert = new List<Quote_Line_Item__c>();
        
        for(QuoteLineItemModel qliModel :selectedProducts)
        	qlisToUpsert.add(qliModel.quoteLineItem);
        
    	if(!qlisToUpsert.isEmpty())
    		upsert qlisToUpsert;
    	
    }*/
    /*
    public List<String> validateCostUOMPriceUOMMismatch() {
    	
    	final String ERROR_IN_LINE = 'Error in line ';
    	List<String> messages = new List<String>();
    	
        for(Integer i=0; i < selectedProducts.size(); i++) {
        	
        	// Quote line item validation rules
        	if(selectedProducts[i].quoteLineItem.Cost__c != null && selectedProducts[i].quoteLineItem.Cost__c != 0) {
        		
        		if(selectedProducts[i].quoteLineItem.Price_unit_of_measure__c != selectedProducts[i].quoteLineItem.Costing_unit_of_measure__c) {
        			
        			String errMsg = ERROR_IN_LINE + (1 + i) + '. ';
        			errMsg += Consts.PAGE_MSG_COST_UOM_PRICE_UOM_MUST_BE_SAME;
        			messages.add(errMsg);
        			        
        		}
        	}            
        }
        
        return messages;	
        
    }*/
    
        
    /**
     Any line items on a quote must be checked for some mandatory conditions
    *//*
    public List<String> validateLineItems(final Set<String> availableFreightCodes) {
    	
    	List<String> messages = new List<String>();
    	
    	for(QuoteLineItemModel selectedProduct :selectedProducts) {
        	
        	Quote_Line_Item__c qli = selectedProduct.quoteLineItem;
        	
        	 //Line items validation rules
            if(qli.Special_Item__c) {
                messages.add('Orders cannot be created for special item lines.  Please go back to the quote and do not select any special items before clicking the "Create Order" button.');
            } 
            
            if(qli.Projected_Delivery_Date__c == null) {
                messages.add('Projected Delivery Date is required on all quote line items being submitted for an order request.  Please edit the line items that are being submitted and add projected delivery dates.');
            }   
             
            if(selectedProduct.quotesModel.getQuote().Shipment_Method__c == 'Direct' && 
                (!availableFreightCodes.contains(qli.Product_Code__c)) &&
                (qli.Cost__c == 0 || qli.Cost__c == null)) {
                messages.add('Cost is required for all item codes being submitted for a Direct order request.  Please edit the item codes that are being submitted to include the Cost.');                
            } 	
        	
        }
        
        return messages;
        
    }*/
    
    /**
     For a quote that has Direct Shipment enabled, atleast a single
     line item on the Quote must be a freight line item
    *//*
    public Boolean validateFreightLines(final Set<String> availableFreightCodes) {
    
    	//Recalc extended price and GTM, and check for freight lines
        Boolean foundFreightLine = Consts.DISABLE;
        
        for(Integer i=0; i < selectedProducts.size(); i++) {
        	            
            //Only recalculate if not special item
            if(!selectedProducts[i].quoteLineItem.Special_Item__c)
                calcExtendedPrice(i);

            if(this.quotesModel.getQuote().Shipment_Method__c == 'Direct') {
            	
            	if(availableFreightCodes.contains(selectedProducts[i].quoteLineItem.Product_Code__c)) {
                     
                    	foundFreightLine = Consts.ENABLE;
                    	break;
                    	
                   }
            }
            
        }
        
        return foundFreightLine;
    		
    }*/
    
    /**
	 Orders selected products based on Item Sequence
	*//*
	private void orderSelectedProductsByItemSequence() {
	
		Map<Integer, QuoteLineItemModel> itemSequenceToSelectedProduct = new Map<Integer, QuoteLineItemModel>();
		for(QuoteLineItemModel selectedProduct :this.selectedProducts) {
			
			itemSequenceToSelectedProduct.put(selectedProduct.itemSequence, selectedProduct);
				
		}
		
		List<Integer> itemSequenceList = new List<Integer>();
		itemSequenceList.addAll(itemSequenceToSelectedProduct.keySet());
		itemSequenceList.sort();
		
		List<QuoteLineItemModel> orderedSelectedProducts = new List<QuoteLineItemModel>();
		for(Integer orderedItemSequence :itemSequenceList) {
			
			QuoteLineItemModel orderedSelectedProduct = itemSequenceToSelectedProduct.get(orderedItemSequence);
			orderedSelectedProducts.add(orderedSelectedProduct);
			
		}
		
		this.selectedProducts.clear();
		this.selectedProducts.addAll(orderedSelectedProducts);
		
	}*/
	
    /**
	 Item sequence numbers must be re-assigned based on the line item that 
	 is deleted
	*//*
	private void reOrderItemSequence(final Integer deletedRowIndex) {
		
		for(Integer i=deletedRowIndex; i < selectedProducts.size(); ++i) {
		
			Integer currentItemSequence = selectedProducts.get(i).getItemSequence();
			selectedProducts.get(i).setItemSequence(currentItemSequence-1);
				
		}
		
	}*/
	/*
    private void assignQLIValues(final QuoteLineItemModel qliModel) {
    	
        if(qliModel.PandA.Response.ItemDetails.size() > 0) {
        	
            qliModel.quoteLineItem.Cost__c                    = Double.valueOf(qliModel.PandA.Response.ItemDetails[0].ItemCostStandard);
            qliModel.quoteLineItem.Price_unit_of_measure__c   = qliModel.PandA.Response.ItemDetails[0].ItemPricingUOM;
            qliModel.quoteLineItem.Costing_unit_of_measure__c = qliModel.PandA.Response.ItemDetails[0].ItemPricingUOM;
            qliModel.quoteLineItem.Price__c                   = Double.valueOf(qliModel.PandA.Response.ItemDetails[0].ItemPricePerUOM);
            qliModel.quoteLineItem.Cost_Code__c               = qliModel.PandA.Response.ItemDetails[0].ItemCostCode;
            qliModel.quoteLineItem.Price_Code__c              = qliModel.PandA.Response.ItemDetails[0].ItemPriceCode;
            
        }
        
        if(qliModel.PandA.Response.Availability.size() > 0)
            qliModel.quoteLineItem.Minimum_mfg_quantity__c = getMinimumPurchase(qliModel, qliModel.quoteLineItem.Product__r.Division_Code__c);
            
    }*/
    /*
    private void getPandAData(final QuoteLineItemModel qliModel) {
    	
        qliModel.enableUOM = Consts.ENABLE;
        
        qliModel.PandA.Request.SystemIdentifier = this.quotesModel.getQuote().System_Code__c;
        qliModel.PandA.Request.DivisionID       = this.quotesModel.getQuote().Servicing_Division__c;

        if(this.quotesModel.getQuote().Account__r.RecordType.Name == 'Prospect') {
            try {
                qliModel.PandA.Request.CustomerID = [select Dummy_Bill_To_Number__c from Servicing_Division__c where System_Code__c = :this.quotesModel.getQuote().System_Code__c and Division_Code__c = :this.quotesModel.getQuote().Servicing_Division__c].Dummy_Bill_To_Number__c;
            }
            catch(Exception e) {
                qliModel.PandA.Request.CustomerID = null;
            }
        }
        else
            qliModel.PandA.Request.CustomerID = this.quotesModel.getQuote().Account__r.AccountNumber;
        
        qliModel.PandA.Request.ShipToID    = this.quotesModel.getQuote().Ship_To_Number__c;
        qliModel.PandA.Request.CIFItemID   = qliModel.quoteLineItem.Product_Code__c;
        qliModel.PandA.Request.Quantity    = String.valueOf(qliModel.quoteLineItem.Qty__c);
        qliModel.PandA.Request.QuantityUOM = qliModel.quoteLineItem.Quantity_unit_of_measure__c;
        qliModel.PandA.Request.PricingUOM  = qliModel.quoteLineItem.Price_unit_of_measure__c;

        qliModel.PandA.getData();
        
    }*/
    /*
    private void fillUOM(final QuoteLineItemModel qliModel) {
    	
        qliModel.getQuantityUOMs().clear();
        qliModel.getPriceUOMs().clear();
        for(PricingAndAvailability.UnitsOfMeasureClass uomc : qliModel.PandA.Response.UnitsOfMeasure) {
        	if(uomc.UOMDisplayForPriceOrQuantity == 'B')
        	{
	            qliModel.getQuantityUOMs().add(new SelectOption(uomc.UOMName, uomc.UOMName));
	            qliModel.getPriceUOMs().add(new SelectOption(uomc.UOMName, uomc.UOMName));

	            if(qliModel.quoteLineItem.Quantity_unit_of_measure__c == null && uomc.UOMIsItemDefaultForQuantity == 'Y')
	                qliModel.quoteLineItem.Quantity_unit_of_measure__c = uomc.UOMName;
	            if(qliModel.quoteLineItem.Price_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
	                qliModel.quoteLineItem.Price_unit_of_measure__c = uomc.UOMName;
	            if(qliModel.quoteLineItem.Costing_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
	                qliModel.quoteLineItem.Costing_unit_of_measure__c = uomc.UOMName;
        	}
        	else if(uomc.UOMDisplayForPriceOrQuantity == 'Q')
        	{
	            qliModel.getQuantityUOMs().add(new SelectOption(uomc.UOMName, uomc.UOMName));

	            if(qliModel.quoteLineItem.Quantity_unit_of_measure__c == null && uomc.UOMIsItemDefaultForQuantity == 'Y')
	                qliModel.quoteLineItem.Quantity_unit_of_measure__c = uomc.UOMName;
        	}
        	else if(uomc.UOMDisplayForPriceOrQuantity == 'P')
        	{
	            qliModel.getPriceUOMs().add(new SelectOption(uomc.UOMName, uomc.UOMName));

	            if(qliModel.quoteLineItem.Price_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
	                qliModel.quoteLineItem.Price_unit_of_measure__c = uomc.UOMName;
	            if(qliModel.quoteLineItem.Costing_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
	                qliModel.quoteLineItem.Costing_unit_of_measure__c = uomc.UOMName;
        	}
        }
    }*/
    /*
    private Double getMinimumPurchase(final QuoteLineItemModel qliModel, final String divisionCode) {
        
        for(PricingAndAvailability.AvailabilityClass ac : qliModel.PandA.Response.Availability) {
        	
            if(ac.ItemDivisionId == divisionCode) {
                return Double.valueOf(ac.ItemMinimumPurchase);
            }
        }
        
        return 0;
    }*/
    /*
	private Double getUnitFactor(final QuoteLineItemModel qliModel, final String uom) {
		
        for(PricingAndAvailability.UnitsOfMeasureClass uomc : qliModel.PandA.Response.UnitsOfMeasure) {
            if(uomc.UOMName == uom)
                return Double.valueOf(uomc.UOMFactor);
        }
        return 1;
        
    }*/
    /*
	private void assignUnitFactors(final QuoteLineItemModel qliModel) {
        
        if(qliModel.PandA.Response.UnitsOfMeasure.size() > 0) {
        	
            qliModel.quoteLineItem.Price_Unit_Factor__c    = getUnitFactor(qliModel, qliModel.quoteLineItem.Price_unit_of_measure__c);
            qliModel.quoteLineItem.Quantity_Unit_Factor__c = getUnitFactor(qliModel, qliModel.quoteLineItem.Quantity_unit_of_measure__c);
            qliModel.quoteLineItem.Cost_Unit_Factor__c     = getUnitFactor(qliModel, qliModel.quoteLineItem.Costing_unit_of_measure__c);
            
        }
        
    }*/
   
   /**
    Create an instance of QuoteLineItemModel that includes a reference to its
    quoteModel and its position in the list of line items
   */
   	private QuoteLineItemModel createQuoteLineItemModel(final Quote_Line_Item__c qli, 
   														final Integer qliSequence) {
   	
   		return new QuoteLineItemModel(new QuotesModel(this.quotesModel.getQuote()), 
   									  qli, 
   									  qliSequence);
   		
   	} 
   	
   	/**
   	 Create an instance of QuoteLineItemModel that includes a reference 
   	 to its quotesModel
   	*/
	private QuoteLineItemModel createQuoteLineItemModel(final Quote_Line_Item__c qli) {
	
		return new QuoteLineItemModel(new QuotesModel(this.quotesModel.getQuote()), qli);
		
	}

	/**
	 Accept the Quote Line Item that needs to be inserted to our instance
	 of selectedProducts with its corresponding sequence #
	*/
	private void addToSelectedProducts(final Quote_Line_Item__c qli, final Integer qliSequence) {
	
		selectedProducts.add(createQuoteLineItemModel(qli, qliSequence));
			
	}
	
	/**
	 Accept the Quote Line Item that needs to be inserted to our instance
	 of selectedProducts
	*/
	private void addToSelectedProducts(final Quote_Line_Item__c qli) {
		
		selectedProducts.add(createQuoteLineItemModel(qli));
		
	}
	
	/**
	 Any existing Quote Line Items must be added to our container at the time
	 of intialization 
	*/
	private void selectExistingQLI(final List<Quote_Line_Item__c> existingQuoteLineItems) {
		Integer sequenceGenerator = 1;
		
		for(Quote_Line_Item__c qli :existingQuoteLineItems) {
			
			addToSelectedProducts(qli, sequenceGenerator);//addToSelectedProducts(qli);
			++sequenceGenerator;
			
		}
			
	}
	
	/**
	 Quote that has any existing Quote Line Items
	*/
	public QuoteLineItemModel(QuotesModel quotesModel, 
							  Quote_Line_Item__c quoteLineItem, 
							  List<Quote_Line_Item__c> existingQuoteLineItems) {
		
		this(quotesModel, quoteLineItem);
		
		/**
		 Any existing Quote Line Items must be part of 
		 selected products 
		*/
		this.selectExistingQLI(existingQuoteLineItems);
		
	}
	
	/**
	 Each indvidual line item must be sequenced for any
	 re-ordering needs
	*/
	public QuoteLineItemModel(QuotesModel quotesModel,
							  Quote_Line_Item__c quoteLineItem,
							  Integer lineItemSequence) {
	
		this(quotesModel, quoteLineItem);		
		
		this.itemSequence = lineItemSequence;
							  	
	}
	
	/**
	 A QuoteLineItem object cannot exist without a Quote instance
	*/
	public QuoteLineItemModel(QuotesModel quotesModel, 
							  Quote_Line_Item__c quoteLineItem) {
		
		this(quoteLineItem);

		/**
		 There cannot be a Quote Line Item Model without a Quotes Model
		*/
		this.quotesModel   = quotesModel;
		
	}
		
	/**
	 Overloaded explicit private intialization constructor that  
	 only takes a reference to Quote_Line_Item__c
	*/
	private QuoteLineItemModel(Quote_Line_Item__c quoteLineItem) {
		
		this.quoteLineItem    = quoteLineItem;
		
		this.matrix = new PricingMatrix__c();
		
		/**
		 Keep the container ready for selected products to be added
		*/
		this.selectedProducts = new List<QuoteLineItemModel>();
	
		/**
		 Prepare the QLIs thrash 
		*/
		this.qlisToDelete     = new List<Quote_Line_Item__c>();
	}	

}
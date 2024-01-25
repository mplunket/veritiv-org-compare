public class OrderRequestQLIControllerExtension
{
    private final ApexPages.StandardSetController qliSetController;
    public List<Quote_Line_Item__c> selectedQuoteLineItems {get; private set;}
    private final Set<String> SUNDRY_CODES = new Set<String>{'CFREIGHT', 'CFREIGHT3P', 'NFREIGHT',
																'SFREIGHT', 'UFREIGHT', 'UFREIGHT3P'};

    public OrderRequestQLIControllerExtension(ApexPages.StandardSetController stdSetController)
    {
        qliSetController = stdSetController;
        
        showRetry = true;
        
        //Validation rules
        if(!isValidQuote)
        {
            showRetry = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This page cannot be accessed directly.  It can only be reached from the "Create Order" button on a quote record.'));
            return;
        }
        if(!hasSelectedRecords)
        {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Quote Line Items have been selected. Please click the "Back" button and select at least one record.'));
            showRetry = false;
            isValidQuote = false;
            return;
        }
        //Validation rules passed, continue
    }
    //Properties
    public Quote__c quote {get; set;}
    
    public Boolean showRetry {get; set;}
    
    public Boolean isValidQuote
    {
        get
        {
            if(isValidQuote == null)
            {
                if(ApexPages.currentPage().getParameters().get('id') == null)
                {
                    isValidQuote = false;
                    return isValidQuote;
                }
                else
                {
                    isValidQuote = true;
                    return isValidQuote;
                }
            }
            return isValidQuote;
        }
        set
        {
            isValidQuote = value;
        }
    }
    
    public Boolean hasSelectedRecords
    {
        get
        {
            if(this.qliSetController.getSelected().size() > 0)
                return true;
            else
                return false;
        }
    }
    //Methods
    public PageReference postOrderRequest()
    {
        //Validation rules
        if(!isValidQuote)
            return null;
        //Validation rules passed, continue 
        //Get quote header values
        quote = [select Id, Expiration_Date__c, Name, Account__r.Name, Account__r.AccountNumber, Account__r.RecordType.Name, Customer_Contact__r.Name, Ship_To_Number__c, Ship_To__c, Ship_To__r.Name, Ship_To__r.State__c, Ship_To__r.Postal_Code__c, Ship_To__r.City__c, Ship_To__r.Address_Line2__c, Ship_To__r.Address_Line1__c, Servicing_Division__c, System_Code__c, Shipment_Method__c, Requested_Delivery_Date__c, Comments__c, PO_Number__c, Number_of_Orders_Submitted__c from Quote__c where Id = :ApexPages.currentPage().getParameters().get('id')];
        //Post query validation rules
        if(quote.Account__r.RecordType.Name == 'Prospect')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Orders cannot be created for Prospect accounts.'));
            isValidQuote = false;
            showRetry = false;
            return null;
        }
        if(quote.Ship_To__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A Ship To address must be selected before creating an order.  Please go back to the quote and click the "Select Ship To Address" button before clicking the "Create Order" button.'));
            isValidQuote = false;
            showRetry = false;
            return null;
        }
        if(quote.Expiration_Date__c < System.today())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This quote has expired and cannot be submitted for an order request.'));
            isValidQuote = false;
            showRetry = false;
            return null;
        }
        //Validation rules passed, continue 
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
    	// Temporarily stop passing CustomerComments field as per Michelle on 8/10
    	//ordReq.Request.Header.CustomerComments = quote.Comments__c;
    	ordReq.Request.Header.PoNumber = quote.PO_Number__c;
        //Loop through selected rows
        Double unitPriceTotal = 0;
        
        selectedQuoteLineItems = (List<Quote_Line_Item__c>)this.qliSetController.getSelected();
        selectedQuoteLineItems = [select Id, Special_Item__c, Projected_Delivery_Date__c, Cost__c, Product_Code__c,
        							Qty__c, Quantity_unit_of_measure__c, Product_Description__c, Price__c, Price_unit_of_measure__c,
        							Bid_number_Contract_number__c, Vendor_Name__r.Name 
        							from Quote_Line_Item__c where Id in :selectedQuoteLineItems
        							order by CreatedDate ASC];
        
        for(Quote_Line_Item__c qli : selectedQuoteLineItems)
        {
        	//Line items validation rules
        	if(qli.Special_Item__c)
        	{
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Orders cannot be created for special item lines.  Please go back to the quote and do not select any special items before clicking the "Create Order" button.'));
	            isValidQuote = false;
	            showRetry = false;
        		return null;
        	} 
        	if(qli.Projected_Delivery_Date__c == null)
        	{
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Projected Delivery Date is required on all quote line items being submitted for an order request.  Please edit the line items that are being submitted and add projected delivery dates.'));
	            isValidQuote = false;
	            showRetry = false;
        		return null;
        	}
        	if(quote.Shipment_Method__c == 'Direct' && 
        		(!SUNDRY_CODES.contains(qli.Product_Code__c)) &&
        		(qli.Cost__c == 0 || qli.Cost__c == null))
        	{
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cost is required for all item codes being submitted for a Direct order request.  Please edit the item codes that are being submitted to include the Cost.'));
	            isValidQuote = false;
	            showRetry = false;
        		return null;
        	} 
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
    	ordReq.Request.Header.TotalPrice = unitPriceTotal;
        try
        {
        	ordReq.postData();
        }
        catch(Exception e)
        {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        	return null;
        }

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Status Code: ' + ordReq.Response.StatusCode + ', Status Message: ' + ordReq.Response.StatusMessage));
		if(ordReq.Response.StatusCode == '202')
		{
			try
			{
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
				insert taskToInsert;
				showRetry = false;
			}
			catch(Exception e)
			{
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	        	return null;
			}
		}
		return null;
    }
}
public with sharing class ViewCreateOrderContExt {

    public static final Set<String> SUNDRY_CODES = new Set<String>{'CFREIGHT', 'CFREIGHT3P', 'NFREIGHT',
                                                                'SFREIGHT', 'UFREIGHT', 'UFREIGHT3P'};


    public Quote__c quote { get; private set; }

    public List<Quote_Line_Item__c> selectedQuoteLineItems { get; private set; }

    public Boolean showRetry { get; set; }

    public Boolean isValidQuote {
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

    public ViewCreateOrderContExt(ApexPages.StandardController standardController) {

        this.quote = (Quote__c)standardController.getRecord();

    }

    public PageReference createOrder() {

        if(!isValidQuote)
            return null;

        String qliIds;
        String[] selectedIds;
        Set<Id> setOfQliIds = new Set<Id>();

        qliIds      = ApexPages.currentPage().getParameters().get('qliIds');
        selectedIds = qliIds.split(',');

        for(String qliId :selectedIds)
            setOfQliIds.add(qliId);

        quote = [select Id, Expiration_Date__c, Name, PO_Reqd__c, Account__r.Name, Account__r.AccountNumber, Account__r.RecordType.Name, Account__r.Active__c, Customer_Contact__r.Name, Ship_To_Number__c, Ship_To__c, Ship_To__r.Name, Ship_To__r.State__c, Ship_To__r.Postal_Code__c, Ship_To__r.City__c, Ship_To__r.Address_Line2__c, Ship_To__r.Address_Line1__c, Servicing_Division__c, System_Code__c, Shipment_Method__c, Requested_Delivery_Date__c, Comments__c, PO_Number__c, Number_of_Orders_Submitted__c,Count_of_Freight_Lines__c/*, Order_Source__c */ from Quote__c where Id = :ApexPages.currentPage().getParameters().get('id')];
        Integer freightCount = [ SELECT COUNT() FROM Quote_Line_Item__c WHERE Product_Code__c LIKE '%FREIGHT%' AND Id IN :setOfQliIds ];

        if(quote.Account__r.RecordType.Name == 'Prospect')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorNoQuotesForProspects));
            isValidQuote = false;
        }
        if(freightCount < 1 && quote.Shipment_Method__c == 'Direct')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorFreightItemsRequiredForDirect));
            isValidQuote = false;
        }
        if(quote.PO_Reqd__c && quote.PO_Number__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorPONumberRequired));
            isValidQuote = false;
        }
        if(quote.Requested_Delivery_Date__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorRequestedDeliveryDateRequired));
            isValidQuote = false;
        }
        if(quote.Expiration_Date__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorExpirationDateRequired));
            isValidQuote = false;
        }
        if(quote.Ship_To__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorShipToAddressRequired));
            isValidQuote = false;
        }
        if(quote.Expiration_Date__c < System.today()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorExpiredQuote));
            isValidQuote = false;
        }
        if(quote.Requested_Delivery_Date__c < System.today()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorExpiredRequestedDeliveryDate));
            isValidQuote = false;
        }
        if(quote.Account__r.Active__c == 'No') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CreateOrder_ErrorAccountInactive));
            isValidQuote = false;
        }
        if(quote.Shipment_Method__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorShipmentMethodRequired));
            isValidQuote = false;
        }
        /**
        * Not ready for deployment (1-22-2012) - Philip Choi
        if(quote.Order_Source__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CreateOrder_ErrorOrderSourceRequired));
            isValidQuote = false;
        }
        */

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
        //Loop through selected rows
        Double unitPriceTotal = 0;

        selectedQuoteLineItems = [select Id, Updated_P_A__c, Special_Item__c, Projected_Delivery_Date__c, Cost__c, Product_Code__c,
                                    Qty__c, Quantity_unit_of_measure__c, Product_Description__c, Price__c, Price_unit_of_measure__c,
                                    Bid_number_Contract_number__c, Vendor_Name__r.Name, Locked__c
                                    from Quote_Line_Item__c where Id in :setOfQliIds
                                    ORDER BY Item_Seq__c];
        
        List<String> errorInformation = new List<String>();

        for(Quote_Line_Item__c qli : selectedQuoteLineItems)
        {
            if(qli.Quantity_unit_of_measure__c == 'null')
                qli.Quantity_unit_of_measure__c = null;
            if(qli.Price_unit_of_measure__c == 'null')
                qli.Price_unit_of_measure__c = null;

            //Line items validation rules
            if(qli.Special_Item__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorSpecialItemsNotAllowed));
                isValidQuote = false;
            }
            if(this.quote.Shipment_Method__c == 'Direct' &&
                (!SUNDRY_CODES.contains(qli.Product_Code__c)) &&
                (qli.Cost__c == 0 || qli.Cost__c == null))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorCostRequiredForDirect));
                isValidQuote = false;
            }
            if(qli.Locked__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.CreateOrder_ErrorLockedItemsNotAllowed));
                isValidQuote = false;
            }
            if(qli.Updated_P_A__c == FALSE)
            {
                errorInformation.add('Item Product Code: ' + qli.Product_Code__c + ' (Id: ' + qli.Id + ')');
            }

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

        if( !isValidQuote )
        {
            showRetry = false;
            return null;
        }
        if( !errorInformation.isEmpty() )
        {
            showRetry = false;
            isValidQuote = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IneligibleQuoteErrorMessage + ' <br /> '+ String.join(errorInformation, ' <br /> ')));
            return null;
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
            this.processSuccessfulOrder( ordReq, quote, selectedQuoteLineItems );
            return null;
        }
        return null;
    }

    public void processSuccessfulOrder( OrderRequest theOrder, Quote__c quote, List<Quote_Line_Item__c> selectedQuoteLineItems ) {

        System.SavePoint sp = Database.setSavepoint();
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
            taskToInsert.Description = '' + theOrder.Request.Header;
            for(OrderRequest.DetailClass detail : theOrder.Request.Details)
                taskToInsert.Description += '\n\n' + detail;
            taskToInsert.Status = 'Completed';
            taskToInsert.Priority = 'Normal';
            taskToInsert.ActivityDate = System.today();
            insert taskToInsert;

            List<Quote_Line_Item__c> lineItemsToUpdate = new List<Quote_Line_Item__c>();
            for( Quote_Line_Item__c lineItem : selectedQuoteLineItems )
            {
                Quote_Line_Item__c bareLineItem = new Quote_Line_Item__c( Id = lineItem.Id );
                bareLineItem.Locked__c = !lineItem.Product_Code__c.contains('FREIGHT');
                lineItemsToUpdate.add( bareLineItem );
            }
            update lineItemsToUpdate;

            showRetry = false;
        }
        catch(Exception e)
        {
            Database.rollback( sp );
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
}
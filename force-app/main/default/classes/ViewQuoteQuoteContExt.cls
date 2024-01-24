/**
 Objective: Quote__c Controller Extenstion
 Developer: Hiremath, Naveen - Bluewolf
*/
public with sharing class ViewQuoteQuoteContExt {

    private static final String UTF8 = 'UTF-8';
    private static final String PRINTABLE_VIEW_TITLE = 'INTERNAL USE ONLY';

    private static final Integer NUM_OF_QUICKADDS = 6;
    public Integer numLineItems {get; private set;}
    public Integer numNotesAndAttachments {get; private set;}
    public string stageName {get;set;}
    
    /**
     Reference to Stanadard Controller will help us to
     undertake standard actions
    */
    @testVisible
    private final ApexPages.StandardController stdCont;

    /**
     ContExt must always retain a reference to its
     model instance
    */
    public final QuotesModel quotesModel    { get; private set; }

    /**
     ProductSearch is independent of QuoteModel's existence
    */
    public final ProductModel productSearch { get; private set; }

    /**
     Flag that indicates a valid/invalid quote
    */
    public Boolean isValidQuote             { get; private set; } 

    /**
     Property to hold all quick add line items
    */
    public List<ViewQuoteQuoteContExt.QuoteQuickAddLineItem> quickAddItems { get; set; }

    public String linkToChangeOwner {
        get {
            return '/' + quotesModel.getQuote().Id +'/a?retURL=%2F' + quotesModel.getQuote().Id;
        }
    }

    /* Stage Render and Required Field Functionality */
    
    public Boolean renderSalesOrderNumberField {
        get {
            
            return stageName == 'Won';  
        }
        set;
    } 
    
    public Boolean renderLostReasonCommentsField {
        get {
            System.debug('this.stdCont.getRecord(): ' + this.stdCont.getRecord());
            System.debug('this.quotesModel: ' + this.quotesModel);
            return QuoteInformationExt.renderLostReasonCommentsField(this.stdCont.getRecord());     
        }
        set;
    }

    public Boolean renderProspectSpendingFields {
        get; set;
    }

    public void clearLostReasonDependentField(){
        this.stdCont.getRecord().put('Lost_Reason__c', null);
    }
    public void changeStageName(){}
    /**
     Quote Header command methods
    */
    public PageReference doShare() {

        String sharingURL ='/p/share/CustomObjectSharingDetail?parentId='+ quotesModel.getQuote().Id;
        PageReference sharingPage = new PageReference(sharingURL);
        sharingPage.setRedirect(true);

        return sharingPage;
    }

    public PageReference doClone(){

        // Save any modifications first
        this.stdCont.save();

        PageReference viewNewQuote = Page.ViewNewQuote;
        viewNewQuote.getParameters().put('isCloned', '1');
        viewNewQuote.getParameters().put('quoteId', quotesModel.getQuote().Id);
        viewNewQuote.setRedirect(true);

        return viewNewQuote;

    }

    public PageReference doSearchOrder(){

        String systemId, billToNum;

        systemId = (quotesModel.getQuote().Account_Legacy_System_Cd__c != null) ?
                    EncodingUtil.urlEncode(quotesModel.getQuote().Account_Legacy_System_Cd__c, UTF8) :
                    Consts.EMPTY_STRING;
        billToNum = (quotesModel.getQuote().Bill_To_Number__c != null) ?
                    EncodingUtil.urlEncode(quotesModel.getQuote().Bill_To_Number__c, UTF8) :
                    Consts.EMPTY_STRING;

        String searchOrderURL = [SELECT Relative_URL__c FROM Search_Order__c WHERE Name = 'Search Order'].Relative_URL__c + //'http://uwtatlusqa01/uniweb/OrderLookupCriteria.aspx?environment=TEST' +
                    '&system=' +  systemId +
                    '&BillToNum=' +  billToNum +
                    '&BillToName=' + EncodingUtil.urlEncode(quotesModel.getQuote().Account__r.Name, UTF8);
        PageReference searchOrder = new PageReference(searchOrderURL);
        searchOrder.setRedirect(true);

        return searchOrder;

    }

    public PageReference doShipToAddress(){

        PageReference shipToAddrPage = Page.SelectShipToAddress;
        shipToAddrPage.getParameters().put('id', quotesModel.getQuote().Id);
        shipToAddrPage.setRedirect(true);

        return shipToAddrPage;
    }
    
    public PageReference doShipToAddressNew(){

        PageReference shipToAddrPage2 = Page.ShipToSearchBox;
        shipToAddrPage2.getParameters().put('id', quotesModel.getQuote().Id);
        shipToAddrPage2.setRedirect(true);

        return shipToAddrPage2;
    }
    public PageReference doSendToFieldSourcing(){

        // Save any modifications first
        this.stdCont.save();
        PageReference fieldSourcingPage = Page.FieldSourcingQuoting;
        fieldSourcingPage.getParameters().put('id', quotesModel.getQuote().Id);
        fieldSourcingPage.setRedirect(true);

        return fieldSourcingPage;
    }
    public PageReference doCancel() {

        PageReference quoteTabPage = new PageReference(Consts.REL_URL_QUOTES_TAB);
        quoteTabPage.setRedirect(true);

        return quoteTabPage;
    }

    public String printableViewUrl
    {
        get
        {
            PageReference printableViewPage = Page.Quote;
            printableViewPage.getParameters().put( 'title', PRINTABLE_VIEW_TITLE );
            printableViewPage.getParameters().put( 'id', stdCont.getId() );

            List<Quote_Line_Item__c> qlis = QuoteLineItemServices.getQuoteLineItems( stdCont.getId() );

            for( Integer index = 0; index < qlis.size(); index++ )
            {
                printableViewPage.getParameters().put( 'qlid' + index, qlis[ index ].Id );
            }

            return printableViewPage.getUrl();
        }
    }
    /**
     End Quote Header command methods
    */

    /**
     Explicit constructor that accepts a standardController reference
    */
    public ViewQuoteQuoteContExt(ApexPages.StandardController standardController) {

        this.stdCont  = standardController;

        Quote__c quote = (Quote__c)this.stdCont.getRecord();
        this.stageName = quote.Quote_Stage__c;

        if (quote != null && quote.Account__c != null) 
        {
            Account a = [SELECT Id, RecordTypeId FROM Account WHERE Id = :quote.Account__c];
            Id prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            this.renderProspectSpendingFields = a.RecordTypeId == prospectRecordTypeId;
        }

        /**
         With a null Quote Id no operations must be performed
        */
        if(quote.Id == null) {

            isValidQuote = Consts.FAILURE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Consts.INVALID_QUOTE, Consts.EMPTY_STRING));
            return;

        }

        /**
         Default this to the created date
        */
        if(quote.Date_Quoted__c == null)
            quote.Date_Quoted__c = quote.CreatedDate.date();

        /**
         Flag this as a valid quote and proceed with other operations
        */
        this.isValidQuote  = Consts.SUCCESS;

        /*
         Hold on to productModel that has freight lines and
         servicing division references
        */
        this.productSearch  = new ProductModel(new Product2(),
                                Freight_Lines__c.getAll(),
                                ServicingDivisionServices.getActiveServiceDivisions());

        /*
         QuotesModel maintains a reference to Quote__c
         and an aggregation relationship with ProductModel
        */
        this.quotesModel = new QuotesModel(quote, productSearch);
        numLineItems = quotesModel.getQuote().Count_of_Line_Items__c.intValue();
        getNumberofNotesAndAttachments();

        quickAddItems = new List<QuoteQuickAddLineItem>();
        for( Integer index = 0; index < NUM_OF_QUICKADDS; index++ )
        {
            quickAddItems.add( new QuoteQuickAddLineItem() );
        }
    }

    public void getNumberOfQuoteLineItems()
    {
        List<Quote__c> quote = [SELECT Id,Count_of_Line_Items__c FROM Quote__c WHERE Id = :quotesModel.getQuote().Id];
        this.numLineItems = quote[0].Count_of_Line_Items__c.intValue();
    }
    public void getNumberofNotesAndAttachments()
    {
        Integer attachmentSize = [SELECT COUNT() FROM Note  where ParentId =: quotesModel.getQuote().Id];
        Integer noteSize = [SELECT COUNT() FROM Attachment  where ParentId =: quotesModel.getQuote().Id];
        this.numNotesAndAttachments = attachmentSize+noteSize;
    }

    public void quickAddProducts()
    {
        // get all the item codes from the quickadd line items
        Set<String> itemNumbers = new Set<String>();
        for( QuoteQuickAddLineItem quickAddLineItem : quickAddItems )
        {
            if( quickAddLineItem.itemNumber != null && quickAddLineItem.itemNumber != '' )
            {
                itemNumbers.add( quickAddLineItem.itemNumber );
            }
        }

        if( !itemNumbers.isEmpty() )
        {
            // get the largest qli sequence
            AggregateResult maxItemSeqQuery = [ SELECT MAX(Item_Seq__c) maxItemSeq FROM Quote_Line_Item__c WHERE Quote__c = :quotesModel.getQuote().Id ];
            Integer maxItemSequence = 1;
            if( maxItemSeqQuery.get( 'maxItemSeq' ) != null )
            {
                maxItemSequence = Integer.valueOf( maxItemSeqQuery.get( 'maxItemSeq' ) ) + 1;
            }

            // query for products entered by quickadd
            List<Product2> validProducts = [ SELECT Id, Division_Code__c, ProductCode, Description, Conversion_Factor__c, Pricing_Costing_UOM__c,
                                                    Unit_of_Measure__c, Vendor__r.Name, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c
                                                FROM Product2
                                                WHERE IsActive = true
                                                    /*AND Stocking_Flag__c = true*/
                                                    AND Division_Name__r.Division_Code__c = :quotesModel.getQuote().Servicing_Division__c
                                                    AND Division_Name__r.Name = :quotesModel.getQuote().Servicing_Division_Name__c
                                                    AND ProductCode IN :itemNumbers ];

            // create a map of product codes to product
            Map<String, Product2> productCodeToProduct = new Map<String, Product2>();
            for( Product2 validProduct : validProducts )
            {
                productCodeToProduct.put( validProduct.ProductCode, validProduct );
            }

            List<Quote_Line_Item__c> lineItemsToInsert = new List<Quote_Line_Item__c>();
            List<QuoteQuickAddLineItem> quickAddItemsToClear = new List<QuoteQuickAddLineItem>();
            // go through the quickadds and create qlis for any existing ones
            for( QuoteQuickAddLineItem quickAddItem : quickAddItems )
            {
                if( productCodeToProduct.containsKey( quickAddItem.itemNumber ) )
                {
                    Product2 product = productCodeToProduct.get( quickAddItem.itemNumber );
                    Quote_Line_Item__c newQLI = new Quote_Line_Item__c();
                    newQLI.Cost_Unit_Factor__c = product.Conversion_Factor__c;
                    newQLI.Item_Seq__c = maxItemSequence++;
                    newQLI.Price_Unit_Factor__c = product.Conversion_Factor__c;
                    newQLI.Price_unit_of_measure__c = product.Pricing_Costing_UOM__c;
                    newQLI.Product__c = product.Id;
                    newQLI.Product_Code__c = product.ProductCode;
                    newQLI.Product_Description__c = product.Description;
                    newQLI.Quantity_unit_of_measure__c = product.Unit_of_Measure__c;
                    newQLI.Quote__c = quotesModel.getQuote().Id;
                    newQLI.Unisource_Item__c = product.Unisource_Item_Number_U_number__c;
                    newQLI.Vendor_Item__c = product.Vendor_Product_Code__c;
                    newQLI.Vendor_Name__c = product.Vendor__c;
                    newQLI.Cost__c = 0;
                    newQLI.Extended_Cost__c = 0;
                    newQLI.Extended_Price__c = 0;
                    newQLI.GTM_CAS__c = 0;
                    newQLI.Price__c = 0;
                    newQLI.Start_Price__c = 0;
                    newQLI.Target_Price__c = 0;
                    newQLI.Floor_Price__c = 0;
                    newQLI.Price_Code__c = null;
                    newQLI.Qty__c = quickAddItem.quantity;
                    newQLI.Quantity_Unit_Factor__c = 0;

                    lineItemsToInsert.add( newQLI );
                    quickAddItemsToClear.add( quickAddItem );
                    quickAddItem.isError = false;
                }
                else
                {
                    quickAddItem.isError = true;
                }
            }

            try
            {
                insert lineItemsToInsert;
            }
            catch( System.DmlException ex )
            {
                for( Integer index = 0; index < ex.getNumDml(); index++ )
                {
                    String errorProductCode = lineItemsToInsert[ ex.getDmlIndex( index ) ].Product_Code__c;
                    
                    for( Integer qAIndex = 0; qAIndex < quickAddItemsToClear.size(); qAIndex++  )
                    {
                        if( quickAddItemsToClear[ qAIndex ].itemNumber == errorProductCode )
                        {
                            quickAddItemsToClear[ qAIndex ].isError = true;
                            quickAddItemsToClear.remove( qAIndex );
                        }
                    }
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errorProductCode + ': ' + ex.getDmlMessage( index ) ) );
                }
            }

            for( QuoteQuickAddLineItem quickAddItem : quickAddItemsToClear )
            {
                quickAddItem.itemNumber = '';
                quickAddItem.quantity = 0;
            }
        }
    }

    public class QuoteQuickAddLineItem
    {
        public String itemNumber { get; set; }
        public Integer quantity { get; set; }
        public Boolean isError {get; set;}
        
        QuoteQuickAddLineItem()
        {
            isError = false;
        }
    }
}
/**
Objective: Custom Controller that responds with a
            JSON response of all the QLI's CRUD operations
Developer: Hiremath, Naveen - Bluewolf
*/
public virtual class QuoteLineItemsCont {

    public static final Set<String> SUNDRY_CODES = new Set<String>{'CFREIGHT', 'CFREIGHT3P', 'IFREIGHT', 'NFREIGHT',
                                                                    'SFREIGHT', 'UFREIGHT', 'UFREIGHT3P'};


    private static final String INSERT_ERROR = 'There was an error while creating the record.';
    private static final String UPDATE_ERROR = 'There was an error while updating the record.';
    private static final String DELETE_ERROR = 'There was an error while deleting the record.';
    @TestVisible
    private static final String ELIGIBILITY_ERROR = '{0} is not Eligible \n';
    
    public static final String EMPTY_NOTE = '#EMPTY#';

    private Quote_Line_Item__c quoteLineItem;
    private String itemSeq = '';
    private static Map<String, Servicing_Division__c> SystemDivisionCompositeCodeMap {
        get {
            if(SystemDivisionCompositeCodeMap == null) {
                SystemDivisionCompositeCodeMap = new Map<String, Servicing_Division__c>();
                for(Servicing_Division__c sd : PricingAndAvailability.ServicingDivisions) {
                    SystemDivisionCompositeCodeMap.put(sd.System_Code__c + ':' + sd.Division_Code__c, sd);
                }
            }
            return SystemDivisionCompositeCodeMap;
        }
        set;
    }

    /**
    Handles any error message, operation failures
    */
    @TestVisible private String errorMessage;
    @TestVisible private List<String> ineligibleQLIs;
    @TestVisible private List<String> ineligibleProductCodes;
    private Boolean operationSuccess = Consts.SUCCESS;

    /**
    JSON response
    */
    public String json { get; private set; }

    public void doCreate() {

        String quoteId,
            jsonRequest;
        final Boolean clonedStatus;

        jsonRequest  = mapRequest(ApexPages.currentPage().getParameters(), 'results');
        quoteId      = getQuoteId(jsonRequest);
        clonedStatus = getClonedStatus(jsonRequest); // There can be a request for cloning the QLI

        if(clonedStatus) {

            parseJSON(jsonRequest, quoteId, Consts.DISABLE);
            //this.quoteLineItem.Quote__c = quoteId;
            this.quoteLineItem = this.quoteLineItem.clone(false, true);

        } else {

            parseJSON(jsonRequest, quoteId, Consts.ENABLE);

        }

        if(!dmlInsert()) {

            this.operationSuccess  = Consts.FAILURE;
            this.errorMessage = INSERT_ERROR;

        }

        this.json = jsonifySearchResults(QuoteLineItemServices.getQuoteLineItem(quoteId, this.quoteLineItem.Id), quoteId, clonedStatus);

    }

    /**
    Handles the request for finding all the
    Quote Line Items on a Quote
    */
    public void doRead() {

        String quoteId;

        // Cloned status is not valid while fetching the QLI's
        final Boolean clonedStatusDisabled = Consts.DISABLE;

        quoteId   = mapRequest(ApexPages.currentPage().getParameters(), 'quoteId');

        this.json = jsonifySearchResults(QuoteLineItemServices.getQuoteLineItems(quoteId), quoteId, clonedStatusDisabled);
    }

    public void doReload() {

        Id quoteId;
        String qliIds, itemSeq;
        Boolean isCloned;
        Integer counter = 0;

        // Cloned status is not valid while fetching the QLI's
        final Boolean clonedStatusDisabled = Consts.DISABLE;

        quoteId  = mapRequest(ApexPages.currentPage().getParameters(), 'quoteId');
        qliIds   = mapRequest(ApexPages.currentPage().getParameters(), 'qliIds');
        itemSeq  = mapRequest(ApexPages.currentPage().getParameters(), 'itemSeq');

        // Used for querying QLI's
        Set<Id> setOfQLIIds        = extracQLIIds(qliIds);

        // Used to map QLI Id's with their Item Seq
        List<String> listOfItemSeq = extractItemSeq(itemSeq);
        List<Id> listofQLIIds      = extractQLIIds(qliIds);

        // The order of QLI IDs and Item Seq will be the same
        Map<Id,String> qliIdToItemSeq = new Map<Id, String>();
        for(Id qliId :listOfQLIIds) {
            qliIdToItemSeq.put(qliId, listOfItemSeq.get(counter++));
        }

        this.json = jsonifySearchResults(QuoteLineItemServices.getQuoteLineItem(quoteId, setOfQLIIds), qliIdToItemSeq, quoteId, clonedStatusDisabled);

    }

    public void doUpdate() {

        String jsonRequest,
               quoteId;
        final Boolean clonedStatusDisabled = Consts.DISABLE;

        jsonRequest = mapRequest(ApexPages.currentPage().getParameters(), 'results');

        quoteId     = getQuoteId(jsonRequest);
        parseJSON(jsonRequest, quoteId, Consts.DISABLE);

        if(!dmlUpdate()) {

            this.operationSuccess  = Consts.FAILURE;
            this.errorMessage = UPDATE_ERROR;

        }

        // Query to get the value of the GTM_Percent__c formula field
        this.json = jsonifySearchResults(QuoteLineItemServices.getQuoteLineItem(quoteId, getQLIId(jsonRequest)), quoteId, clonedStatusDisabled);
        //this.json = '{"success":' + status + ', "message": "' + message + '", "total": "1", "results":' + jsonRequest + '}';
    }

    public void doDelete() {

        Id qliId;
        String message = Consts.EMPTY_STRING;
        Boolean status = Consts.SUCCESS;

        qliId = mapRequest(ApexPages.currentPage().getParameters(), 'results').replaceAll('"','');
        this.quoteLineItem = new Quote_Line_Item__c(Id=qliId);

        if(!dmlDelete()) {

            status  = Consts.FAILURE;
            message = DELETE_ERROR;

        }

        this.json = '{"success":' + status + ', "message": "' + message + '", "total": "1", "results":{} }';
    }

    public void doCalc() {

        Id quoteId;
        String qliIds;
        Boolean isCloned;

        quoteId  = mapRequest(ApexPages.currentPage().getParameters(), 'quoteId');
        qliIds   = mapRequest(ApexPages.currentPage().getParameters(), 'qliIds');
        isCloned = Boolean.valueOf(mapRequest(ApexPages.currentPage().getParameters(), 'qliCloned'));

        Set<Id> setOfQLIIds = extracQLIIds(qliIds);

        Quote__c quote;
        List<Quote_Line_Item__c> allQLIs, existingQuoteLineItems, specialQuoteLineItems;

        quote                  = [SELECT Id FROM Quote__c WHERE Id =: quoteId];
        alLQLIs                = QuoteLineItemServices.getQuoteLineItem(quoteId, setOfQLIIds);
        existingQuoteLineItems = new List<Quote_Line_Item__c>();

        for(Quote_Line_Item__c currentQLI :allQLIs) {
//Commented this code to fix time out issue
           // if( Limits.getCallouts() >= Limits.getLimitCallouts() )
           // {
            //    break;
           // }

            this.operationSuccess = Consts.SUCCESS;
            this.errorMessage     = Consts.EMPTY_STRING;

            QuoteLineItemModel qliModel = new QuoteLineItemModel(
                                                new QuotesModel(quote),
                                                currentQLI);
            if(!Test.isRunningTest())
                getPandAData(qliModel);

            ascertainPandAErrors(qliModel);
            if(!this.operationSuccess) break;

            calcExtendedPrice(qliModel);

            this.quoteLineItem = qliModel.getQuoteLineItem();
            existingQuoteLineItems.add(this.quoteLineItem);
        }

        this.json = jsonifySearchResults(existingQuoteLineItems, quoteId, isCloned);

    }
    /*
    public void doRefresh() {

        Id qliId, quoteId;
        Boolean isCloned;

        quoteId  = mapRequest(ApexPages.currentPage().getParameters(), 'quoteId');
        qliId    = mapRequest(ApexPages.currentPage().getParameters(), 'qliIds');
        isCloned = Boolean.valueOf(mapRequest(ApexPages.currentPage().getParameters(), 'qliCloned'));

        Quote_Line_Item__c selectedQli = QuoteLineItemServices.getQuoteLineItem(quoteId, qliId)[0];

        QuoteLineItemModel qliModel = new QuoteLineItemModel(
                                            new QuotesModel([SELECT Id FROM Quote__c WHERE Id =: quoteId]),
                                            selectedQLI);


        this.getPandAForProduct(qliModel);
        this.calcExtendedPrice(qliModel);
        this.quoteLineItem = qliModel.getQuoteLineItem();

        List<Quote_Line_Item__c> existingQuoteLineItems = new List<Quote_Line_Item__c>{this.quoteLineItem};

        this.json = jsonifySearchResults(existingQuoteLineItems, quoteId, isCloned);

    }
    */
    public void doUpdatePA() {

        this.operationSuccess = Consts.SUCCESS;
        this.errorMessage     = Consts.EMPTY_STRING;

        Id quoteId;
        String qliIds, itemSeq;
        Integer counter = 0;
        final Boolean clonedStatusDisabled = Consts.DISABLE;

        quoteId  = mapRequest(ApexPages.currentPage().getParameters(), 'quoteId');
        qliIds    = mapRequest(ApexPages.currentPage().getParameters(), 'qliIds');
        itemSeq  = mapRequest(ApexPages.currentPage().getParameters(), 'itemSeq');

        System.debug('*** Page Params: ' + quoteId + ' ' + qliIds);

        Set<Id> setOfQLIIds = extracQLIIds(qliIds);

        // Used to map QLI Id's with their Item Seq
        List<String> listOfItemSeq = extractItemSeq(itemSeq);
        List<Id> listofQLIIds      = extractQLIIds(qliIds);

        // The order of QLI IDs and Item Seq will be the same
        Map<Id,String> qliIdToItemSeq = new Map<Id, String>();
        for(Id qliId :listOfQLIIds) {
            qliIdToItemSeq.put(qliId, listOfItemSeq.get(counter++));
        }

        Quote__c quote;
        List<Quote_Line_Item__c> allQLIs, existingQuoteLineItems, specialQuoteLineItems;

        quote                  = [SELECT Id, Shipment_Method__c FROM Quote__c WHERE Id =: quoteId];

        if(!isUpdateableQuote(quote)) {
            this.operationSuccess = Consts.FAILURE;
            this.errorMessage = Consts.PAGE_MSG_NO_SHIPMENT_METHOD_FOR_QUOTE_ON_UPDATEPA;
        }

        alLQLIs                = QuoteLineItemServices.getQuoteLineItem(quoteId, setOfQLIIds);
        existingQuoteLineItems = new List<Quote_Line_Item__c>();
        specialQuoteLineItems  = new List<Quote_Line_Item__c>();

        System.debug('*** List of All QLIs: ' + alLQLIs);
        this.ineligibleQLIs = new List<String>();
        this.ineligibleProductCodes = new List<String>();
        for(Quote_Line_Item__c currentQLI :allQLIs) {

            if( Limits.getCallouts() >= Limits.getLimitCallouts() )
            {
                break;
            }


            // Special line item must not be included for UpdatePA
            if(currentQLI.Special_Item__c) {
                specialQuoteLineItems.add(currentQLI);
                continue;
            }

            QuoteLineItemModel qliModel = new QuoteLineItemModel(
                                            new QuotesModel(quote),
                                            currentQLI);

            this.getPandAForProduct(qliModel, quote);
            if(!this.operationSuccess) break;

            this.quoteLineItem = qliModel.getQuoteLineItem();

            existingQuoteLineItems.add(this.quoteLineItem);
        }
        System.debug('*** List of Existing QLIs: ' + existingQuoteLineItems);

        // Get the special line item back into it's herd
        existingQuoteLineItems.addAll(specialQuoteLineItems);
        if(this.operationSuccess) update existingQuoteLineItems;

        Map<Id, Quote_Line_Item__c> modifiedLineItems = new Map<Id, Quote_Line_Item__c>( existingQuoteLineItems );
        existingQuoteLineItems = QuoteLineItemServices.getQuoteLineItem( quote.Id, modifiedLineItems.keySet() );
        this.json = jsonifySearchResults(existingQuoteLineItems, qliIdToItemSeq, quoteId, clonedStatusDisabled);
       
    }


    public void doQtyUOM() {

        String query;
        String[] quoteIdAndqliId;

        query = mapRequest(ApexPages.currentPage().getParameters(), 'query');
        quoteIdAndqliId = query.split('&');

        Quote__c quote         = [SELECT Id FROM Quote__c WHERE Id =: quoteIdAndqliId[0]];
        Quote_Line_Item__c qli = QuoteLineItemServices.getQuoteLineItem(quoteIdAndqliId[0], quoteIdAndqliId[1])[0];

        QuoteLineItemModel qliModel = new QuoteLineItemModel(new QuotesModel(quote), qli);

        if(!Test.isRunningTest())
            getPandAData(qliModel);
        ascertainPandAErrors(qliModel);

        if(!this.operationSuccess) {
            this.json = '[[]]';
            return;
        }

        List<String> qtyUOM = getQtyUOM(qliModel);

        String values = '[';
        for(String uom :qtyUOM) {
            values +=  '[\'' + uom + '\'],';
        }
        values += ']';

        values = values.substring(0, values.length()-2);
        values += ']';

        this.json = values;
    }

    public void doPriceUOM() {

        String query;
        String[] quoteIdAndqliId;

        query = mapRequest(ApexPages.currentPage().getParameters(), 'query');
        quoteIdAndqliId = query.split('&');

        Quote__c quote         = [SELECT Id FROM Quote__c WHERE Id =: quoteIdAndqliId[0]];
        Quote_Line_Item__c qli = QuoteLineItemServices.getQuoteLineItem(quoteIdAndqliId[0], quoteIdAndqliId[1])[0];

        QuoteLineItemModel qliModel = new QuoteLineItemModel(new QuotesModel(quote), qli);

        if(!Test.isRunningTest())
            getPandAData(qliModel);
        ascertainPandAErrors(qliModel);

        if(!this.operationSuccess) {
            this.json = '[[]]';
            return;
        }

        List<String> priceUOM = getPriceUOM(qliModel);

        String values = '[';
        for(String uom :priceUOM) {
            values +=  '[\'' + uom + '\'],';
        }
        values += ']';

        values = values.substring(0, values.length()-2);
        values += ']';

        this.json = values;
    }

    @TestVisible
    private static Boolean isUpdateableQuote(Quote__c quoteToCheck) {
        Boolean isUpdateable = true;

        if(String.isBlank(quoteTocheck.Shipment_Method__c)) {
            isUpdateable = false;
        }

        return isUpdateable;
    }

    private static Set<Id> extracQLIIds(final String commaSeparatedQliIds) {

        Set<Id> setOfQLIIds = new Set<Id>();
        String[] arrayOfQLIIds = commaSeparatedQliIds.split(',');

        for(Integer i=0; i < arrayOfQLIIds.size(); ++i) {
            if( arrayOfQLIIds[i] != null && arrayOfQLIIds[i].trim() != '') {
                setOfQLIIds.add(arrayOfQLIIds[i]);
            }
        }

        return setOfQLIIds;
    }

    private static List<Id> extractQLIIds(final String commaSeparatedQliIds) {

        List<Id> listOfQLIIds = new List<Id>();
        String[] arrayOfQLIIds = commaSeparatedQliIds.split(',');

        for(Integer i=0; i < arrayOfQLIIds.size(); ++i) {
            if( arrayOfQLIIds[i] != null && arrayOfQLIIds[i].trim() != '') {
                listOfQLIIds.add(arrayOfQLIIds[i]);
            }
        }

        return listOfQLIIds;
    }

    private static List<String> extractItemSeq(final String commaSeparatedItemSeq) {

        List<String> listOfItemSeq = new List<String>();
        String[] arrayOfItemSeq = commaSeparatedItemSeq.split(',');

        for(Integer i=0; i < arrayOfItemSeq.size(); ++i) {
            listOfItemSeq.add(arrayOfItemSeq[i]);
        }

        return listOfItemSeq;
    }

    private Boolean dmlInsert() {

        Boolean status;

        try {

            insert this.quoteLineItem;
            status = Consts.SUCCESS;

        } catch(Exception e) {

            status = Consts.FAILURE;

        }
        return status;
    }

    private Boolean dmlDelete() {

        Boolean status;

        try {

            delete this.quoteLineItem;
            status = Consts.SUCCESS;

        } catch(DMLException dmle) {

            status = Consts.FAILURE;

        }
        return status;
    }

    private Boolean dmlUpdate() {

        Boolean status;

        try {
            update this.quoteLineItem;
            status = Consts.SUCCESS;

        } catch(DMLException dmle) {

            status = Consts.FAILURE;

        }
        return status;
    }

    private Boolean getClonedStatus(final String jsonRequest) {

        //JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(jsonRequest) );
        //return Boolean.valueOf(jsonObject.get('qliCloned'));

        JSONLineItem jsonL = (JSONLineItem)System.JSON.deserialize(jsonRequest, QuoteLineItemsCont.JSONLineItem.class);
        return Boolean.valueOf(jsonL.qliCloned);
    }

    private String getQuoteId(final String jsonRequest) {

        //JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(jsonRequest) );
        //return String.valueOf(jsonObject.get('quoteId'));

         JSONLineItem jsonL = (JSONLineItem)System.JSON.deserialize(jsonRequest, QuoteLineItemsCont.JSONLineItem.class);
         return jsonL.quoteId;
    }

    private String getQLIId(final String jsonRequest) {

        //JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(jsonRequest) );
        //return String.valueOf(jsonObject.get('id'));

        JSONLineItem jsonL = (JSONLineItem)System.JSON.deserialize(jsonRequest, QuoteLineItemsCont.JSONLineItem.class);
         return jsonL.id;
    }

    /**
     Used by doCreate() and doUpdate() actions
    */
    private void parseJSON(final String jsonRequest, final Id quoteId, final Boolean isInsert) {

        Id qliId;
        Decimal qty, priceCurrency, extendedPriceCurrency, extendedCostCurrency;
        Decimal currentGTMPercent = 0;
        Decimal currentCost = 0;

        //JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(jsonRequest) );
        JSONLineItem jsonObject = (JSONLineItem)System.JSON.deserialize(jsonRequest, QuoteLineItemsCont.JSONLineItem.class);

        if(!isInsert) {

            qliId = String.valueOf(jsonObject.id);
            this.quoteLineItem = [Select Id,Quote__c,
                                         GTM_percent__c,Price__c,
                                         Price_Unit_Factor__c,
                                         Quantity_Unit_Factor__c,
                                         Cost_Unit_Factor__c,
                                         Cost__c,
                                        Special_Item__c,
                                        Duty__c,
                                        Exchange__c,
                                        Brokerage__c
                                  FROM Quote_Line_Item__c
                                  WHERE Id = :qliId
                                  AND Quote__c = :quoteId];//new Quote_Line_Item__c(Id=qliId);

            currentGTMPercent = this.quoteLineItem.GTM_percent__c;
            currentCost = this.quoteLineItem.Cost__c;

        } else {

            this.quoteLineItem = new Quote_Line_Item__c();
            this.quoteLineItem.Quote__c = quoteId;
        }

        try
        {
            // Set Qty__c
            String qliQty = String.valueOf(jsonObject.qliQty).trim();
            quoteLineItem.Qty__c = Decimal.valueOf(qliQty);

            // Set Quantity_Unit_Factor__c
            String qliQtyUnitFactor = String.valueOf(jsonObject.qliQuantityUnitFactor).trim();
            quoteLineItem.Quantity_Unit_Factor__c = (qliQtyUnitFactor != 'null') ? Decimal.valueOf(qliQtyUnitFactor) : 0;

            // Set Minimum_mfg_quantity__c
            String qliMinMfgQty = String.valueOf(jsonObject.qliMinMfgQty).trim();
            quoteLineItem.Minimum_mfg_quantity__c = (qliMinMfgQty != 'null') ? Decimal.valueOf(qliMinMfgQty) : null;

            // Set Cost__c
            String qliCost = String.valueOf(jsonObject.qliCost).trim();
            Decimal cost = (qliCost != 'null' && qliCost != '') ? Decimal.valueOf(qliCost) : 0;
            quoteLineItem.Cost__c = (qliCost == '') ? 0 : cost;
            
            // Set Start_Price__c
//          String qliStartPrice = String.valueOf(jsonObject.qliStartPrice).trim();
//          Decimal startPrice = (qliStartPrice != 'null' && qliStartPrice != '') ? Decimal.valueOf(qliStartPrice) : 0;
//          quoteLineItem.Start_Price__c = (qliStartPrice == '') ? 0 : startPrice;
            
            // Set Floor_Price__c
            String qliFloorPrice = String.valueOf(jsonObject.qliFloorPrice).trim();
            Decimal floorPrice = (qliFloorPrice != 'null' && qliFloorPrice != '') ? Decimal.valueOf(qliFloorPrice) : 0;
            quoteLineItem.Floor_Price__c = (qliFloorPrice == '') ? 0 : floorPrice;

            // Set Target_Price__c
            String qliTargetPrice = String.valueOf(jsonObject.qliTargetPrice).trim();
            Decimal targetPrice = (qliTargetPrice != 'null' && qliTargetPrice != '') ? Decimal.valueOf(qliTargetPrice) : 0;
            quoteLineItem.Target_Price__c = (qliTargetPrice == '') ? 0 : targetPrice;

            // Set GTM_CAS__c
            String qliGTMDollar = String.valueOf(jsonObject.qliGTMDollar).trim();
            quoteLineItem.GTM_CAS__c = (qliGTMDollar != 'null') ? Decimal.valueOf(qliGTMDollar): null;

            // A user will not be able to edit this
            String extendedCost = String.valueOf(jsonObject.qliExtendedCost).trim();
            extendedCostCurrency = (extendedCost != 'null') ? Decimal.valueOf(extendedCost) : 0;
            quoteLineItem.Extended_Cost__c = extendedCostCurrency;

            // get GTM
            String targetGTMPercent = String.valueOf( jsonObject.qliGTMPercent ).trim();
            Decimal gtmPercent = Decimal.valueOf(targetGTMPercent);

            // Set Price__c
            String qliPrice = String.valueOf(jsonObject.qliPrice).trim();
            priceCurrency = (qliPrice != 'null' && qliPrice != '') ? Decimal.valueOf(qliPrice): 0;

            // if the GTM has changed and the price has not and it is an update, then change price
            if( (gtmPercent != currentGTMPercent || currentCost != quoteLineItem.Cost__c)
                 && quoteLineItem.Price__c == priceCurrency
                 && !isInsert
                 && currentCost > 0)
            {
                Decimal divisor = (1-gtmPercent/100) == 0 ? 0.0001 : (1-gtmPercent/100) ;

                quoteLineItem.Price__c =  cost.divide(divisor, 2, System.RoundingMode.HALF_UP);  //do calculation
            }
            // otherwise just set price
            else
            {
                quoteLineItem.Price__c = (qliPrice == '') ? 0 : priceCurrency;
            }

            // A user will not be able to edit this, except if this is a Special line item
            // Set Extended_Price__c
            String extendedPrice = String.valueOf(jsonObject.qliExtendedPrice).trim();
            extendedPriceCurrency = (extendedPrice != 'null') ? Decimal.valueOf(extendedPrice): null;
            quoteLineItem.Extended_Price__c = extendedPriceCurrency;
        }
        catch( System.TypeException ex )
        {
            this.quoteLineItem.addError( ex.getMessage() );
        }

        this.itemSeq = String.valueOf(jsonObject.itemSeq);
        // Set Item_Seq__c
        quoteLineItem.Item_Seq__c = (this.itemSeq == Consts.EMPTY_STRING || this.itemSeq == 'null') ? null : Integer.valueOf(this.itemSeq);

        // Set Product_Id__c
        String productId = String.valueOf(jsonObject.qliProdId);
        if(productId != 'null') {
            quoteLineItem.Product__c =  productId;
            quoteLineItem.Product__r = [SELECT Id, System_ID__c, Division_Code__c FROM Product2 WHERE Id =: productId];
        }

        // Set Product_Code__c
        String productCode = String.valueOf(jsonObject.qliProdCode);
        productCode = collapseSlashes(productCode);
        quoteLineItem.Product_Code__c = (productCode == 'null') ? null : productCode;

        // Set Product_Description__c
        String productDesc = String.valueOf(jsonObject.qliProdDesc);
        productDesc = collapseSlashes(productDesc);
        quoteLineItem.Product_Description__c = (productDesc == 'null') ? null : productDesc ;

        // Set Quantity_unit_of_measure__c
        String quantityUOM = String.valueOf(jsonObject.qliUOM);
        quoteLineItem.Quantity_unit_of_measure__c = (quantityUOM == 'null') ? null : quantityUOM;

        // Set Price_unit_of_measure__c
        String priceUOM = String.valueOf(jsonObject.qliPriceUOM);
        quoteLineItem.Price_unit_of_measure__c = (priceUOM == 'null') ? null : priceUOM;
        //Cost Unit of Measure and Price Unit of Measure must be similar
        quoteLineItem.Costing_unit_of_measure__c = quoteLineItem.Price_unit_of_measure__c;

        // Set Price_Code__c
        String priceCode = String.valueOf(jsonObject.qliPriceCode);
        quoteLineItem.Price_Code__c = (priceCode == 'null') ? null : priceCode;

        // Set Special_Item__c
        Boolean specialLineItem = Boolean.valueOf(jsonObject.qliSpecialItem);
        quoteLineItem.Special_Item__c = specialLineItem;

        // Set Special_Product__c
        Boolean specialProduct = Boolean.valueOf(jsonObject.qliSpecialProduct);
        quoteLineItem.Special_Product__c = specialProduct;

        // Set Vendor_Name__c
        String vendorName = String.valueOf(jsonObject.qliVendor);
        if(vendorName != 'null'){
            /*List<Product2> prod = [SELECT Vendor__c FROM Product2 WHERE Id =: productId];
            if(prod != null && prod.size() == 1)
                quoteLineItem.Vendor_Name__c = prod[0].Vendor__c;
            else*/ {
                List<Vendor_Detail__c> vendorDetail = [SELECT Id FROM Vendor_Detail__c WHERE name = :vendorName];
                if(vendorDetail != null && vendorDetail.size() == 1)
                    quoteLineItem.Vendor_Name__c = vendorDetail[0].Id;
                else
                    quoteLineItem.Vendor_Name__c = null;
            }
        }

        // Set Comments_Short__c
        String commentsShort = String.valueOf(jsonObject.qliComments);
        commentsShort = collapseSlashes(commentsShort);
        if(commentsShort != 'null'){
            quoteLineItem.Comments_Short__c = commentsShort;
        }

        // Set Comments__c
        String commentsDontPrint = String.valueOf(jsonObject.qliCommentsDontPrint);
        commentsDontPrint = collapseSlashes( commentsDontPrint );
        if(commentsDontPrint != 'null'){
            quoteLineItem.Comments__c = commentsDontPrint;
        }

        // Set Bid_number_Contract_number__c
        String qliBid = String.valueOf(jsonObject.qliBid);
        qliBid = collapseSlashes(qliBid);
        if(qliBid != 'null') {
            quoteLineItem.Bid_number_Contract_number__c = qliBid;
        }

        // Set Project_Delivery_Date__c
        String qliProjDel = String.valueOf(jsonObject.qliProjDel);
        quoteLineItem.Projected_Delivery_Date__c = (qliProjDel != 'null') ?
            Date.valueOf(qliProjDel) :
            [SELECT Requested_Delivery_Date__c FROM Quote__c WHERE Id =: quoteId].Requested_Delivery_Date__c;

        // Set Vendor_Item__c
        String qliVendorItem = String.valueOf(jsonObject.qliVendorItem);
        qliVendorItem = collapseSlashes(qliVendorItem);
        quoteLineItem.Vendor_Item__c = (qliVendorItem != 'null') ? qliVendorItem : null;

        // Set mfg_Tolerance__c
        String qliMfgTol = String.valueOf(jsonObject.qliMfgTol);
        quoteLineItem.mfg_tolerance__c = (qliMfgTol != 'null') ? qliMfgTol : null;

        // Set Last_Date_of_Change__c
        String qliLDC = String.valueOf(jsonObject.qliLDC);
        if(qliLDC != 'null') {
            quoteLineItem.Last_Date_of_Change__c  = Date.valueOf(qliLDC);
        }

        // Set Vendor_Contact__c
        String qliVendorContact = String.valueOf(jsonObject.qliVendorContact);
        quoteLineItem.Vendor_Contact__c = (qliVendorContact != 'null') ? qliVendorContact : null;

        if( quoteLineItem.Special_Item__c )
        {
            //Set stockMfg
            String stockMfg = String.valueOf(jsonObject.qliStockedMfg);
            quoteLineItem.Stock_Manufactured__c  = (stockMfg != 'null') ? stockMfg : null;

            //Set typeOfQuote
            String typeOfQuote = String.valueOf(jsonObject.qliTypeOfQuote);
            quoteLineItem.Type_Of_Quote__c  = (typeOfQuote != 'null') ? typeOfQuote : null;

            //Set itemOrigin
            String itemOrigin = String.valueOf(jsonObject.qliItemOrigin);
            quoteLineItem.Item_Origin__c  = (itemOrigin != 'null') ? itemOrigin : null;

            //Set rollSize
            String rollSize = String.valueOf(jsonObject.qliRollSize);
            quoteLineItem.Roll_Size__c  = (rollSize != 'null') ? rollSize : null;

            //Set Brightness
            String brightNess = String.valueOf(jsonObject.qliBrightness);
            quoteLineItem.Brightness__c  = (brightNess != 'null') ? brightNess : null;

            //Set color
            String color = String.valueOf(jsonObject.qliColor);
            quoteLineItem.Color__c  = (color != 'null') ? color : null;

            //Set finish
            String finish = String.valueOf(jsonObject.qliFinish);
            quoteLineItem.Finish__c  = (finish != 'null') ? finish : null;

            //Set brand
            String brand = String.valueOf(jsonObject.qliBrand);
            quoteLineItem.Brand__c  = (brand != 'null') ? brand : null;

            //Set gNameClass
            String gNameClass = String.valueOf(jsonObject.qliGradeNameCls);
            gNameClass = collapseSlashes( gNameClass );
            quoteLineItem.Grade_Name_Class__c  = (gNameClass != 'null') ? gNameClass : null;

            //Set basisWeight
            String basisWeight = String.valueOf(jsonObject.qliBasisWeight);
            quoteLineItem.Basis_Weight__c  = (basisWeight != 'null') ? basisWeight : null;

            //Set outerDia
            String outerDia = String.valueOf(jsonObject.qliOuterDia);
            quoteLineItem.Outer_Diameter__c  = (outerDia != 'null') ? outerDia : null;

            //Set core
            String core = String.valueOf(jsonObject.qliCore);
            quoteLineItem.Core__c  = (core != 'null') ? core : null;

            //Set recContent
            String recContent = String.valueOf(jsonObject.qliRecContent).trim();
            quoteLineItem.Recycled_Content__c  = (recContent != 'null') ? Decimal.valueOf(recContent) : 0;

            //Set pcwContent
            String pcwContent = String.valueOf(jsonObject.qliPcwContent).trim();
            quoteLineItem.PCW_Content__c  = (pcwContent != 'null') ? Decimal.valueOf(pcwContent) : 0;

            //Set cocReq
            String cocReq = String.valueOf(jsonObject.qliCocReq);
            quoteLineItem.Coc_Required__c  = (cocReq != 'null') ? cocReq : null;

            //Set costComm
            String costComm = String.valueOf(jsonObject.qliCostComm);
            costComm = collapseSlashes( costComm );
            quoteLineItem.CostCommision__c  = (costComm != 'null') ? costComm : null;

            //Set lastDateOrd
            String lastDateOrd = String.valueOf(jsonObject.qliLastDateOrd);
            quoteLineItem.Last_Date_To_Order__c  = (lastDateOrd != 'null') ? Date.valueOf(lastDateOrd) : null;
        }

        QuoteLineItemModel qliModel;

        qliModel = new QuoteLineItemModel( new QuotesModel( new Quote__c(Id=quoteLineItem.Quote__c)), quoteLineItem );
        if( !quoteLineItem.Special_Item__c && !isFreight( quoteLineItem ) )
        {
            if(!Test.isRunningTest())
                getPandAData(qliModel);

            ascertainPandAErrors(qliModel);
            if(!this.operationSuccess) return;
        }

        calcExtendedPrice( qliModel );
    }

    private Boolean isFreight( Quote_Line_Item__c qli )
    {
        return SUNDRY_CODES.contains( qli.Product_Code__c );
    }

    private String jsonifySearchResults(final List<Quote_Line_Item__c> existingQuoteLineItems,
                                        final String quoteId,
                                        final Boolean isCloned) {

        String jsonResults = Consts.EMPTY_STRING;

        if(!this.operationSuccess) {
            return '{"success":' + this.operationSuccess + ', "message": "' + this.errorMessage.replaceAll('\\\\','/').replaceAll('[\n\r]',' ') + '", "total": "1", "results":{} }';
        }

        for(Quote_Line_Item__c quoteLineItem :existingQuoteLineItems) {
            jsonResults += generateJSONForLineItem( quoteLineItem, quoteId, isCloned );
        }

        String jsonString = '{"success": true, "message": "", "total":' + existingQuoteLineItems.size() + ', "results":[' + jsonResults + ']}';
        jsonString = jsonString.replaceAll(',]',']');

        return jsonString;
    }

    private String jsonifySearchResults(final List<Quote_Line_Item__c> existingQuoteLineItems,
                                        final Map<Id,String> qliIdToITemSeq,
                                        final String quoteId,
                                        final Boolean isCloned) {

        String jsonResults = Consts.EMPTY_STRING;

        if(!this.operationSuccess) {
            return '{"success":' + this.operationSuccess + ', "message": "' + this.errorMessage.replaceAll('\\\\','/').replaceAll('[\n\r]',' ') + '", "total": "1", "results":{} }';
        }

        for(Quote_Line_Item__c quoteLineItem :existingQuoteLineItems) {
            jsonResults += generateJSONForLineItem( quoteLineItem, quoteId, isCloned );
        }
        if(this.errorMessage == null){
            this.errorMessage = Consts.EMPTY_STRING;
        }
        
        String ineligibleString = this.ineligibleQLIs != null && !this.ineligibleQLIs.isEmpty() ? ',"ineligibleQLIs":[' + String.join(this.ineligibleQLIs,',') + ']': '';
        String ineligibleProductCodesString = this.ineligibleProductCodes != null && !this.ineligibleProductCodes.isEmpty() ? ',"ineligibleProductCodes":[' + String.join(this.ineligibleProductCodes,',') + ']': '';               
        String jsonString = '{'+
                                '"success": true,'+
                                '"message": "' + this.errorMessage.replaceAll('\\\\','/').replaceAll('[\n\r]',' ') + '",'+ 
                                '"total":' + existingQuoteLineItems.size() + ','+
                                '"results":[' + jsonResults + ']'+ ineligibleString + ineligibleProductCodesString +                
                            '}';
        jsonString = jsonString.replaceAll(',]',']');
System.debug('**JSON STRING: ' + jsonString); System.debug('**INELIGIBLE: ' + ineligibleString);
        return jsonString;
    }

    private String mapRequest(final Map<String, String> requestParams, final String param) {

        return requestParams.get(param);
    }

    private Double getUnitFactor(final QuoteLineItemModel qliModel, final String uom) {

        for(PricingAndAvailability.UnitsOfMeasureClass uomc : qliModel.getPandA().Response.UnitsOfMeasure) {
            if(uomc.UOMName == uom) {
                return Double.valueOf(uomc.UOMFactor);
            }
        }
        return 1;
    }

    private void assignUnitFactors(final QuoteLineItemModel qliModel) {

        if(qliModel.getPandA().Response.UnitsOfMeasure.size() > 0) {

            qliModel.getQuoteLineItem().Price_Unit_Factor__c    = getUnitFactor(qliModel, qliModel.getQuoteLineItem().Price_unit_of_measure__c);
            qliModel.getQuoteLineItem().Quantity_Unit_Factor__c = getUnitFactor(qliModel, qliModel.getQuoteLineItem().Quantity_unit_of_measure__c);
            qliModel.getQuoteLineItem().Cost_Unit_Factor__c     = getUnitFactor(qliModel, qliModel.getQuoteLineItem().Costing_unit_of_measure__c);
        }
    }

    protected List<String> getQtyUOM(final QuoteLineItemModel qliModel) {
        List<String> qtyUOM = new List<String>();

        for(PricingAndAvailability.UnitsOfMeasureClass uomc : qliModel.getPandA().Response.UnitsOfMeasure) {

            if(uomc.UOMDisplayForPriceOrQuantity == 'B') {
                    qtyUOM.add(uomc.UOMName);
            } else if(uomc.UOMDisplayForPriceOrQuantity == 'Q') {
                     qtyUOM.add(uomc.UOMName);
            }
        }
        return qtyUOM;
    }

    protected List<String> getPriceUOM(final QuoteLineItemModel qliModel) {
        List<String> priceUOM = new List<String>();

        for(PricingAndAvailability.UnitsOfMeasureClass uomc : qliModel.getPandA().Response.UnitsOfMeasure) {

            if(uomc.UOMDisplayForPriceOrQuantity == 'B') {
                priceUOM.add(uomc.UOMName);
            } else if(uomc.UOMDisplayForPriceOrQuantity == 'P') {
                priceUOM.add(uomc.UOMName);
            }

        }
        return priceUOM;
    }

    private void fillUOM(final QuoteLineItemModel qliModel) {

        qliModel.getQuantityUOMs().clear();
        qliModel.getPriceUOMs().clear();
        for(PricingAndAvailability.UnitsOfMeasureClass uomc : qliModel.getPandA().Response.UnitsOfMeasure) {
            if(uomc.UOMDisplayForPriceOrQuantity == 'B')
            {
                qliModel.getQuantityUOMs().add(new SelectOption(uomc.UOMName, uomc.UOMName));
                qliModel.getPriceUOMs().add(new SelectOption(uomc.UOMName, uomc.UOMName));

                if(qliModel.getQuoteLineItem().Quantity_unit_of_measure__c == null && uomc.UOMIsItemDefaultForQuantity == 'Y')
                    qliModel.getQuoteLineItem().Quantity_unit_of_measure__c = uomc.UOMName;
                if(qliModel.getQuoteLineItem().Price_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
                    qliModel.getQuoteLineItem().Price_unit_of_measure__c = uomc.UOMName;
                if(qliModel.getQuoteLineItem().Costing_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
                    qliModel.getQuoteLineItem().Costing_unit_of_measure__c = uomc.UOMName;
            }
            else if(uomc.UOMDisplayForPriceOrQuantity == 'Q')
            {
                qliModel.getQuantityUOMs().add(new SelectOption(uomc.UOMName, uomc.UOMName));

                if(qliModel.getQuoteLineItem().Quantity_unit_of_measure__c == null && uomc.UOMIsItemDefaultForQuantity == 'Y')
                    qliModel.getQuoteLineItem().Quantity_unit_of_measure__c = uomc.UOMName;
            }
            else if(uomc.UOMDisplayForPriceOrQuantity == 'P')
            {
                qliModel.getPriceUOMs().add(new SelectOption(uomc.UOMName, uomc.UOMName));

                if(qliModel.getQuoteLineItem().Price_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
                    qliModel.getQuoteLineItem().Price_unit_of_measure__c = uomc.UOMName;
                if(qliModel.getQuoteLineItem().Costing_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
                    qliModel.getQuoteLineItem().Costing_unit_of_measure__c = uomc.UOMName;
            }
        }
    }
    
    public static String returnNullIfEmptyLikeString(String input)
    {
        if(input == EMPTY_NOTE)
            return null;
        return input;
    } 

    @TestVisible private void assignQLIValues(final QuoteLineItemModel qliModel, final Quote__c selectedQuote) {

        if(qliModel.getPandA().Response.ItemDetails.size() > 0) {

            qliModel.getQuoteLineItem().Cost__c                    = parseDoubleFromString(qliModel.getPandA().Response.ItemDetails[0].ItemCostStandard);
            qliModel.getQuoteLineItem().Price_unit_of_measure__c   = qliModel.getPandA().Response.ItemDetails[0].ItemPricingUOM;
            qliModel.getQuoteLineItem().Costing_unit_of_measure__c = qliModel.getPandA().Response.ItemDetails[0].ItemPricingUOM;
            qliModel.getQuoteLineItem().Price__c                   = parseDoubleFromString(qliModel.getPandA().Response.ItemDetails[0].ItemPricePerUOM);
            qliModel.getQuoteLineItem().Start_Price__c             = parseDoubleFromString(qliModel.getPandA().Response.ItemDetails[0].ItemCTSDisplayPrice);
            qliModel.getQuoteLineItem().Cost_Code__c               = qliModel.getPandA().Response.ItemDetails[0].ItemCostCode;
            qliModel.getQuoteLineItem().Price_Code__c              = qliModel.getPandA().Response.ItemDetails[0].ItemPriceCode;
            
            //Added 4/25 : MH
            qliModel.getQuoteLineItem().Price_Origin__c            = qliModel.getPandA().Response.ItemDetails[0].PriceOrigin;
            //qliModel.getQuoteLineItem().Contract_Price_Cd__c       = qliModel.getPandA().Response.ItemDetails[0].ContractPriceCode;
            //qliModel.getQuoteLineItem().Corp_Acct__c               = returnNullIfEmptyLikeString(qliModel.getPandA().Response.ItemDetails[0].IsNationalAccountsPrice);
            qliModel.getQuoteLineItem().Target_Price__c            = parseDoubleFromString(qliModel.getPandA().Response.ItemDetails[0].TargetPrice);
            qliModel.getQuoteLineItem().Floor_Price__c             = parseDoubleFromString(qliModel.getPandA().Response.ItemDetails[0].FloorPrice);
            qliModel.getQuoteLineItem().Cust_Item_Code__c          = returnNullIfEmptyLikeString(qliModel.getPandA().Response.ItemDetails[0].CustomerItemNumber);
            qliModel.getQuoteLineItem().Rebate_Code_Desc__c        = qliModel.getPandA().Response.ItemDetails[0].RebateGroupDescr;
            qliModel.getQuoteLineItem().Rebate_Starts__c           = parseResponseDateString( qliModel.getPandA().Response.ItemDetails[0].DateBegin );
            qliModel.getQuoteLineItem().Rebate_Ends__c             = parseResponseDateString( qliModel.getPandA().Response.ItemDetails[0].DateEnd );
            qliModel.getQuoteLineItem().Future_Dev_Cost__c         = parseDoubleFromString(qliModel.getPandA().Response.ItemDetails[0].FutureDevCost);
            qliModel.getQuoteLineItem().Future_Dev_Cost_Starts__c  = parseResponseDateString( qliModel.getPandA().Response.ItemDetails[0].FutureDevCostEffDate );
            qliModel.getQuoteLineItem().Contract_Price_Cd__c       = returnNullIfEmptyLikeString(qliModel.getPandA().Response.ItemDetails[0].ItemPriceCode);
        }

        if(qliModel.getPandA().Response.Availability.size() > 0)
        {
            qliModel.getQuoteLineItem().Minimum_mfg_quantity__c = getMinimumPurchase(qliModel, qliModel.getQuoteLineItem().Product__r.Division_Code__c);
            
        }
//Sujitha Damidi: commented on 31 oct 2018 for Backlog#00683
        // Objective:Direct shipment method not to default to zero and to pull Warehouse pricing 
       /* if(selectedQuote.Shipment_Method__c == Consts.SHIP_METHOD_DIRECT) 
        {
            qliModel.getQuoteLineItem().Cost__c = 0;
            qliModel.getQuoteLineItem().Price__c = 0;
            qliModel.getQuoteLineItem().Start_Price__c = 0;
            qliModel.getQuoteLineItem().Target_Price__c = 0;
            qliModel.getQuoteLineItem().Floor_Price__c = 0;
        }*/
        //End of Comment
    } 

    private Double parseDoubleFromString( String doubleString )
    {
        Double doubleToReturn = 0.0;
        
        if ( String.isNotBlank(doubleString) && doubleString != 'NULL' )
        {
            doubleToReturn = Double.valueOf(doubleString);
        }
        return doubleToReturn;
    }
    
    private Date parseResponseDateString( String dateString )
    {
        if ( String.isNotBlank(dateString) && dateString != 'NULL' )
        {
            /*
            List<String> dateVariables = dateString.split('/');
            Integer year = Integer.valueOf( dateVariables[0] );
            Integer day = Integer.valueOf( dateVariables[1] );
            Integer month = Integer.valueOf( dateVariables[2] );
            */
            if( dateString.length() != 8 )
                return null;    
            
            Integer year = Integer.valueOf( dateString.substring(0,4) );
            Integer day = Integer.valueOf( dateString.substring(6,8) );
            Integer month = Integer.valueOf( dateString.substring(4,6) );
            return Date.newInstance( year, month, day );
        }
        return null;
    }

    private Double getMinimumPurchase(final QuoteLineItemModel qliModel, final String divisionCode) {

        for(PricingAndAvailability.AvailabilityClass ac : qliModel.getPandA().Response.Availability) {

            if(ac.ItemDivisionId == divisionCode) {
                return Double.valueOf(ac.ItemMinimumPurchase);
            }
        }

        return 0;
    }

    protected void getPandAData(final QuoteLineItemModel qliModel) {

        qliModel.setEnableUOM(Consts.ENABLE);

        qliModel.getPandA().Request.SystemIdentifier = qliModel.getQuoteLineItem().Product__r.System_ID__c;
        System.debug('*** System Id:' + qliModel.getPandA().Request.SystemIdentifier);
        // qliModel.getPandA().Request.DivisionID       = qliModel.getQuotesModel().getQuote().Servicing_Division__c;
        qliModel.getPandA().Request.DivisionID = qliModel.getQuoteLineItem().Product__r.Division_Code__c;
        System.debug('*** Division Code Id:' + qliModel.getPandA().Request.DivisionID);

        if(qliModel.getQuotesModel().getQuote().Account__r.RecordType.Name == 'Prospect'
            //|| qliModel.getQuoteLineItem().Product__r.Division_Code__c != qliModel.getQuotesModel().getQuote().Servicing_Division__c 
            ) {
            try {
                qliModel.getPandA().Request.CustomerID = SystemDivisionCompositeCodeMap.get(qliModel.getQuoteLineItem().Product__r.System_ID__c + ':' 
                                                                                            + qliModel.getQuoteLineItem().Product__r.Division_Code__c).Dummy_Bill_To_Number__c;
                //qliModel.getPandA().Request.CustomerID = [select Dummy_Bill_To_Number__c from Servicing_Division__c where System_Code__c = :qliModel.getQuoteLineItem().Product__r.System_ID__c and Division_Code__c = :qliModel.getQuoteLineItem().Product__r.Division_Code__c].Dummy_Bill_To_Number__c;
            }
            catch(Exception e) {
                qliModel.getPandA().Request.CustomerID = null;
            }
        }
        else
            qliModel.getPandA().Request.CustomerID = qliModel.getQuotesModel().getQuote().Account__r.AccountNumber;

        //Dont pass the shipto if the prd's division doesnt match the quotes division
        if( qliModel.getQuoteLineItem().Product__r.Division_Code__c != qliModel.getQuotesModel().getQuote().Servicing_Division__c  )
            qliModel.getPandA().Request.ShipToID    = null;
        else
            qliModel.getPandA().Request.ShipToID    = qliModel.getQuotesModel().getQuote().Ship_To_Number__c;

        qliModel.getPandA().Request.CIFItemID   = qliModel.getQuoteLineItem().Product_Code__c;
        qliModel.getPandA().Request.Quantity    = String.valueOf(qliModel.getQuoteLineItem().Qty__c);
        qliModel.getPandA().Request.QuantityUOM = qliModel.getQuoteLineItem().Quantity_unit_of_measure__c;
        qliModel.getPandA().Request.PricingUOM  = qliModel.getQuoteLineItem().Price_unit_of_measure__c;

        qliModel.getPandA().getData();

    }
    /*
    private void getPandAData(final List<QuoteLineItemModel> qliModels) {
        Integer counter = 0;
        for(QuoteLineItemModel qliModel : qliModels) {
            if(!qliModel.getQuoteLineItem().Special_Item__c) {
                counter++;
                if(counter > 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'P&A can only be retrieved for 10 line items or less. Only the first 10 line items have been updated, the rest will have to be updated individually.'));
                    return;
                }
                getPandAData(qliModel);
            }
        }
    }
    */

    protected void ascertainPandAErrors(final QuoteLineItemModel selectedProduct) {

        if(selectedProduct.getPandA().Response.Errors.size() > 0) {

            for(PricingAndAvailability.ErrorsClass ec : selectedProduct.getPandA().Response.Errors) {
                this.errorMessage     = ec.description;
                this.operationSuccess = Consts.FAILURE;
            }
        }
    }


    @TestVisible
    private Boolean checkEligibility(final QuoteLineItemModel qliModel)
    {
        PricingAndAvailability.ResponseClass response = qliModel.getPAndA().Response;
        if(response.ItemEligibility != null && response.ItemEligibility.size() > 0)
        {
            Boolean isEligible = 'Y'.equalsIgnoreCase(response.ItemEligibility[0].EligibilityFlag)? true : false;
            qliModel.getQuoteLineItem().Updated_P_A__c = isEligible;
            return isEligible;
        }
        else{
            qliModel.getQuoteLineItem().Updated_P_A__c = false;
            return false;
        }

    }

    private void getPandAForProduct(final QuoteLineItemModel selectedProduct, final Quote__c selectedQuote) {
        if(!Test.isRunningTest())
            getPandAData(selectedProduct);

        ascertainPandAErrors(selectedProduct);
        if(!this.operationSuccess) return;
        if(!checkEligibility(selectedProduct))
        {
            if(this.ineligibleQLIs != null)
            {
                this.ineligibleQLIs.add( '\"' + selectedProduct.getQuoteLineItem().id + '\"');
                this.ineligibleProductCodes.add( '\"' + selectedProduct.getQuoteLineItem().Product_Code__c + '\"');
            }
            else
            {
                this.ineligibleQLIs = new List<String>{ '\"' + selectedProduct.getQuoteLineItem().Id + '\"'};
                this.ineligibleProductCodes = new List<String>{'\"' + selectedProduct.getQuoteLineItem().Product_Code__c + '\"'};
            }
            this.errorMessage += String.format(ELIGIBILITY_ERROR, 
                                             new List<String>{selectedProduct.getQuoteLineItem().Product_Code__c } );
            return;
        }
        fillUOM(selectedProduct);
        assignUnitFactors(selectedProduct);
        assignQLIValues(selectedProduct, selectedQuote);

        calcExtendedPrice(selectedProduct);
    }

    public void calcExtendedPrice(final QuoteLineItemModel selectedProduct) {

        assignUnitFactors(selectedProduct);
        Quote_Line_Item__c qli = selectedProduct.getQuoteLineItem();

        Double duty = qli.Duty__c;
        Double exchange = qli.Exchange__c;
        Double brokerage = qli.Brokerage__c;
        //Double conversionFactor = 1 + (duty==null?0:duty/100) + (exchange==null?0:exchange/100) + (brokerage==null?0:brokerage/100);
        Double conversionFactor = 1;
        Double quantity = qli.Qty__c;
        Double quantityUnitFactor = qli.Quantity_Unit_Factor__c;
        Double price = (qli.Price__c == null) ? 0 : qli.Price__c * conversionFactor;
        Double priceUnitFactor = qli.Price_Unit_Factor__c;
        Double cost = (qli.Cost__c == null) ? 0 : qli.Cost__c * conversionFactor;
        Double costUnitFactor = qli.Cost_Unit_Factor__c;
        if(quantity != null && price != null && priceUnitFactor != null && quantityUnitFactor != null && !qli.Special_Item__c) {
            if(priceUnitFactor > 0)
                if(quantityUnitFactor >= 0)
                    qli.Extended_Price__c = (price / priceUnitFactor) * quantityUnitFactor * quantity;
                else
                    qli.Extended_Price__c = ((price / priceUnitFactor) / Math.abs(quantityUnitFactor)) * quantity;
            else
                if(quantityUnitFactor >= 0)
                    qli.Extended_Price__c = price * Math.abs(priceUnitFactor) * quantityUnitFactor * quantity;
                else
                    qli.Extended_Price__c = ((price * Math.abs(priceUnitFactor)) / Math.abs(quantityUnitFactor)) * quantity;

            qli.GTM_CAS__c = qli.Extended_Price__c - selectedProduct.getExtendedCost().Amount;
        }
        else{
            if( !qli.Special_Item__c || qli.Quantity_unit_of_measure__c == qli.Price_unit_of_measure__c )
            {
                qli.Extended_Price__c = price * quantity;
            }
            if( qli.Extended_Price__c != null )
            {
                qli.GTM_CAS__c = qli.Extended_Price__c - selectedProduct.getExtendedCost().Amount;
            }
        }
        if(quantity != null && cost != null && costUnitFactor != null && quantityUnitFactor != null && !qli.Special_Item__c) {
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

            selectedProduct.getExtendedCost().Amount = extendedCost;
            qli.Extended_Cost__c = extendedCost;

            Double extendedPrice = qli.Extended_Price__c == null? 0: qli.Extended_Price__c;
            qli.GTM_CAS__c = extendedPrice - extendedCost;
        }
        else{
            if( !qli.Special_Item__c || qli.Quantity_unit_of_measure__c == qli.Price_unit_of_measure__c )
            {
                qli.Extended_Cost__c = cost * quantity;
            }
            if( qli.Extended_Price__c != null && qli.Extended_Cost__c != null )
            {
                qli.GTM_CAS__c = qli.Extended_Price__c - qli.Extended_Cost__c;
            }
        }
    }

    private String escapeSlashes( String targetString )
    {
        if( targetString != null && targetString.contains('\\') )
        {
            targetString = targetString.replaceAll('\\\\','\\\\\\\\');
        }
        return targetString;
    }

    private String escapeQuotes( String targetString )
    {
        if( targetString != null && targetString.contains('"') )
        {
            targetString = targetString.replaceAll('"','\\\\"');
        }
        return targetString;
    }

    private String collapseSlashes( String targetString )
    {
        if( targetString != null && targetString.contains('\\') )
        {
            targetString = targetString.replaceAll('\\\\\\\\','\\\\');
        }
        return targetString;
    }

    public String generateJSONForLineItem( Quote_Line_Item__c lineItem, String quoteId, Boolean isCloned )
    {
        String retString = '';

        String productDesc = escapeSlashes(lineItem.Product_Description__c);
        productDesc = escapeQuotes(productDesc);
        productDesc = (productDesc != null) ?
            productDesc.replaceAll('[\n\r]',' ') :
            productDesc;

        String lineItemComments = escapeSlashes(lineItem.Comments_Short__c);
        lineItemComments = escapeQuotes(lineItemComments);

        String commentsDontPrint = escapeSlashes(lineItem.Comments__c);
        commentsDontPrint = escapeQuotes(commentsDontPrint);

        String costCommission = escapeSlashes(lineItem.CostCommision__c);
        costCommission = escapeQuotes(costCommission);
        String gradeNameClass = escapeSlashes(lineItem.Grade_Name_Class__c);
        gradeNameClass = escapeQuotes(gradeNameClass);
        String productCode = escapeSlashes(lineItem.Product_Code__c);
        productCode = escapeQuotes(productCode);

        productCode = (productCode != null) ?
            productCode.replaceAll('[\n\r]',' ') :
            productCode;


        String bidNumber = escapeSlashes(lineItem.Bid_number_Contract_number__c);
        bidNumber = escapeQuotes(bidNumber);
        String vendorItemNumber = escapeSlashes(lineItem.Vendor_Item__c);
        vendorItemNumber = escapeQuotes(vendorItemNumber);

        //Bid and OD

        String od = escapeSlashes(lineItem.Outer_Diameter__c);
        od = escapeQuotes(od);

        String core = escapeSlashes(lineItem.Core__c);
        core = escapeQuotes(core);

        String qom = escapeSlashes(lineItem.Quantity_unit_of_measure__c);
        qom = escapeQuotes(qom);

        String priceUom = escapeSlashes(lineItem.Price_unit_of_measure__c);
        priceUom = escapeQuotes(priceUom);

        String priceCode = escapeSlashes(lineItem.Price_Code__c);
        priceCode = escapeQuotes(priceCode);

        String vName = escapeSlashes(lineItem.Vendor_Name__r.Name);
        vName = escapeQuotes(vName);

        String mfgTol = escapeSlashes(lineItem.mfg_tolerance__c);
        mfgTol = escapeQuotes(mfgTol);

        String uniItem = escapeSlashes(lineItem.Unisource_Item__c);
        uniItem = escapeQuotes(uniItem);

        String stockMfg = escapeSlashes(lineItem.Stock_Manufactured__c);
        stockMfg = escapeQuotes(stockMfg);

        String typeOfQuote = escapeSlashes(lineItem.Type_Of_Quote__c);
        typeOfQuote = escapeQuotes(typeOfQuote);

        String itemOrig = escapeSlashes(lineItem.Item_Origin__c);
        itemOrig = escapeQuotes(itemOrig);

        String rollSize = escapeSlashes(lineItem.Roll_Size__c);
        rollSize = escapeQuotes(rollSize);

        String brightness = escapeSlashes(lineItem.Brightness__c);
        brightness = escapeQuotes(brightness);

        String color = escapeSlashes(lineItem.Color__c);
        color = escapeQuotes(color);

        String finish = escapeSlashes(lineItem.Finish__c);
        finish = escapeQuotes(finish);

        String brand = escapeSlashes(lineItem.Brand__c);
        brand = escapeQuotes(brand);

        String basisWeight = escapeSlashes(lineItem.Basis_Weight__c);
        basisWeight = escapeQuotes(basisWeight);

        String cocReq = escapeSlashes(lineItem.Coc_Required__c);
        cocReq = escapeQuotes(cocReq);

        retString += '{';
        retString += '"id":' + '"' + lineItem.Id + '",';
        retString += '"quoteId":' + '"' + quoteId + '",';
        retString += '"itemSeq":' + '"' + lineItem.Item_Seq__c + '",';
        retString += '"qliQty":' + '"' + lineItem.Qty__c + '",';
        retString += '"qliProdId":' + '"' + lineItem.Product__c + '",';
        retString += '"qliProdCode":' + '"' + productCode + '",';
        retString += '"qliProdDesc":' + '"' + productDesc + '",';
        retString += '"qliUOM":' + '"' + qom + '",';
        retString += '"qliPrice":' + '"' + lineItem.Price__c + '",';
        retString += '"qliTargetPrice":' + '"' + lineItem.Target_Price__c + '",';
        retString += '"qliFloorPrice":' + '"' + lineItem.Floor_Price__c + '",';
        retString += '"qliPriceUOM":' + '"' + priceUom + '",';
        retString += '"qliPriceCode":' + '"' + priceCode + '",';
        retString += '"qliSpecialItem":' + lineItem.Special_Item__c + ',';
        retString += '"qliSpecialProduct":' + lineItem.Special_Product__c + ',';
        retString += '"qliGTMPercent":' +  lineItem.GTM_Percent__c + ',';
        retString += '"qliExtendedPrice":' + '"' + lineItem.Extended_Price__c + '",';
        retString += '"qliExtendedCost":' + '"' + lineItem.Extended_Cost__c + '",';
        retString += '"qliVendor":' + '"' + vName + '",';
        retString += '"qliComments":' + '"' + lineItemComments + '",';
        retString += '"qliCommentsDontPrint":' + '"' + commentsDontPrint + '",';
        retString += '"qliBid":' + '"' + bidNumber + '",';
        retString += '"qliMinMfgQty":' + '"' + lineItem.Minimum_mfg_quantity__c + '",';
        retString += '"qliCost":' + '"' + lineItem.Cost__c + '",';
        retString += '"qliProjDel":' + '"' + lineItem.Projected_Delivery_Date__c + '",';
        retString += '"qliVendorItem":' + '"' + vendorItemNumber + '",';
        retString += '"qliMfgTol":' + '"' + mfgTol + '",';
        retString += '"qliLDC":' + '"' + lineItem.Last_Date_of_Change__c + '",';
        retString += '"qliGTMDollar":' + '"' + lineItem.GTM_CAS__c + '",';
        retString += '"qliVendorContact":' + '"' + lineItem.Vendor_Contact__c + '",';
        retString += '"qliUnisourceItem":' + '"' + uniItem + '",';
        retString += '"qliPriceUnitFactor":' + '"' + lineItem.Price_Unit_Factor__c + '",';
        retString += '"qliQuantityUnitFactor":' + '"' + lineItem.Quantity_Unit_Factor__c + '",';
        retString += '"qliCostUnitFactor":' + '"' + lineItem.Cost_Unit_Factor__c + '",';
        retString += '"qliCloned":' + isCloned + ',';
        retString += '"qliStockedMfg":' + '"' + stockMfg + '",';
        retString += '"qliTypeOfQuote":' + '"' + typeOfQuote + '",';
        retString += '"qliItemOrigin":' + '"' + itemOrig + '",';
        retString += '"qliRollSize":' + '"' + rollSize + '",';
        retString += '"qliBrightness":' + '"' + brightness + '",';
        retString += '"qliColor":' + '"' + color + '",';
        retString += '"qliFinish":' + '"' + finish + '",';
        retString += '"qliBrand":' + '"' + brand + '",';
        retString += '"qliGradeNameCls":' + '"' + gradeNameClass + '",';
        retString += '"qliBasisWeight":' + '"' + basisWeight + '",';

        retString += '"qliOuterDia":' + '"' + od + '",';
        retString += '"qliCore":' + '"' + core + '",';

        retString += '"qliRecContent":' + '"' + lineItem.Recycled_Content__c + '",';
        retString += '"qliPcwContent":' + '"' + lineItem.PCW_Content__c + '",';
        retString += '"qliCocReq":' + '"' + cocReq + '",';
        retString += '"qliCostComm":' + '"' + costCommission + '",';
        retString += '"qliLastDateOrd":' + '"' + lineItem.Last_Date_To_Order__c + '",';
        retString += '"qliLocked":' + lineItem.Locked__c +','; //+ '",';
        retString += '"qliFutDevCost":'+ '"' +lineItem.Future_Dev_Cost__c+ '",';    
        retString += '"qliSentToZilliant":'+ '"' +lineItem.Sent_To_Zilliant_Time__c + '"';  
        retString += '},';
        return retString;
    }

    public class JSONLineItem {
        public String Id;
        public String quoteId;
        public String qliQty;
        public String qliProdId;
        public String itemSeq;
        public String qliProdCode;
        public String qliProdDesc;
        public String qliUOM;
        public String qliPrice;
        public String qliStartPrice;
        public String qliTargetPrice;
        public String qliFloorPrice;
        public String qliPriceUOM;
        public String qliPriceCode;
        public String qliSpecialItem;
        public String qliSpecialProduct;
        public String qliGTMPercent;
        public String qliExtendedPrice;
        public String qliExtendedCost;
        public String qliVendor;
        public String qliComments;
        public String qliCommentsDontPrint;
        public String qliBid;
        public String qliMinMfgQty;
        public String qliCost;
        public String qliProjDel;
        public String qliVendorItem;
        public String qliMfgTol;
        public String qliLDC;
        public String qliGTMDollar;
        public String qliVendorContact;
        public String qliUnisourceItem;
        public String qliPriceUnitFactor;
        public String qliQuantityUnitFactor;
        public String qliCostUnitFactor;
        public String qliStockedMfg;
        public String qliTypeOfQuote;
        public String qliItemOrigin;
        public String qliRollSize;
        public String qliBrightness;
        public String qliColor;
        public String qliFinish;
        public String qliBrand;
        public String qliGradeNameCls;
        public String qliBasisWeight;
        public String qliOuterDia;
        public String qliCore;
        public String qliRecContent;
        public String qliPcwContent;
        public String qliCocReq;
        public String qliCostComm;
        public String qliLastDateOrd;
        public String qliLocked;
        public String qliCloned;

    }
}
public class QuoteControllerExtension
{
    public static final String SALES_REP_TITLE = 'Sales Rep';
    public static final String VENDOR_TITLE = 'Vendor';
    public static final String CUSTOMER_TITLE = 'Customer';
    @testVisible
    private final Quote__c quote;
    private final ApexPages.StandardController quoteController;
    private Quote_Line_Item__c[] qlisToDelete = new Quote_Line_Item__c[0];
    Map<Id, Ship_To__c> id2shipTo = new Map<Id, Ship_To__c>();
    Map<Id, zpl__ContractLineItem__c> mProductToPoliceValue = new Map<Id, zpl__ContractLineItem__c>();
   
   
    //changes added for prospect (sujitha)
    public string recType{get;set;}
   // public boolean showVeritivLogo{get;set;}
    public boolean isSaalfeld{get;set;}
    
    //End changes
    
    
    public QuoteControllerExtension(ApexPages.StandardController stdController)
    {
        System.debug('inside controller');
        //Get quote
        this.quote = (Quote__c)stdController.getRecord();
        System.debug('this.quote'+this.quote);
        this.quoteController = stdController;
        //Initialize running totals
        this.extendedPriceRunningTotal = 0.0;
        this.GTMRunningTotal = 0.0;
        
        Account a = [select recordtype.name from Account where id =: this.quote.Account__c];
        
        
        //Added if condition for test class
        if(a != null){
             System.debug('account record type'+a.recordtype.name);
       
       
        //Changes added  by Sujitha- If Account is Prospect look at Department field on User to display the correct Logo on a Quote.
        //showVeritivLogo = false;
       // Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
//List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
       // System.debug('quote'+quote.Account__r.recordType);
        
        if(a.RecordType.Name == 'Prospect' ){
            System.debug('inside prospect');
           string dep = [Select Department From User Where Id = : UserInfo.getUserId() Limit 1].Department;
            System.debug('dep'+dep);
            if(dep == 'Saalfeld'){
                isSaalfeld = true;
            }else{
                isSaalfeld = false;
       // showVeritivLogo = true;
            }
            
        }else{
             String businessGroup = [Select Account__r.VOS_Business_Group__c From Quote__c Where Id = :quote.Id Limit 1].Account__r.VOS_Business_Group__c;
            if(businessGroup == 'SA'){
                isSaalfeld = true;
            }else{
                isSaalfeld = false;
            }
        }
        }
       
       
        //End changes


        //Get existing quote line items
        for(Quote_Line_Item__c qli : [select Id, Price_Code__c, Cost_Code__c,
                                        End_User_Agreement__c, Extended_Price__c,
                                        Cost_Unit_Factor__c, Price_Unit_Factor__c,
                                        Quantity_Unit_Factor__c, GTM_CAS__c,
                                        GTM_percent__c, Bid_number_Contract_number__c,
                                        mfg_tolerance__c, Vendor_Name__c, Vendor_Item__c,
                                        Vendor_Contact__c, Quantity_unit_of_measure__c,
                                        Qty__c, Projected_Delivery_Date__c,
                                        Product_Description__c, Product__c,
                                        Product_Code__c, Price__c, Minimum_mfg_quantity__c,
                                        Last_Date_of_Change__c, Cost__c, Special_Product__c,
                                        Special_Item__c, Price_unit_of_measure__c,
                                        Costing_unit_of_measure__c, Product__r.System_ID__c,
                                        Product__r.Division_Code__c, Unisource_Item__c,
                                        Comments_Short__c
                                        from Quote_Line_Item__c
                                        where Quote__c = :this.quote.Id
                                        order by CreatedDate ASC])
        {
            selectedProducts.add(new QLIWrapper(qli));
        }
        this.calculateRunningTotals();
    }
    //Properties
    public Decimal extendedPriceRunningTotal{get;set;}
    public Decimal GTMRunningTotal{get;set;}

    public String extendedPriceRunningTotalString{

            get
            {

                String extPrice = this.extendedPriceRunningTotal.format();


                //System.debug('INDEX OF DOT --> ' + extPrice.indexOf('.') + ' For this string --> ' + extPrice + ' with a length of ' + extPrice.length());

                if(extPrice.indexOf('.') == extPrice.length()-2 && extPrice.length() > 1)
                extPrice += '0';
                else if(extPrice.indexOf('.') == -1)
                extPrice += '.00';

                return extPrice;
            }

            set;
        }
    public String GTMRunningTotalString{

            get
            {

                String gtmTot = this.GTMRunningTotal.format();

                if(gtmTot.indexOf('.') == gtmTot.length()-2 && gtmTot.length() > 1)
                gtmTot += '0';
                else if(gtmTot.indexOf('.') == -1)
                gtmTot += '.00';

                return gtmTot;
            }

            set;
        }




    public Quote_Line_Item__c[] selectedQLIs
    {
        get
        {
            if(selectedQLIs == null) selectedQLIs = new Quote_Line_Item__c[0];
            return selectedQLIs;
        }
        set {selectedQLIs = value;}
    }

    public String quoteTemplateTitle
    {
        get
        {
            return ApexPages.currentPage().getParameters().get('title');
        }
    }

    public String formattedNow
    {
        get
        {
            return System.now().format();
        }
    }

    public boolean isValidQuote
    {
        get
        {
            if(this.quote.Id == null)
                return false;
            else
                return true;
        }
    }

    public SelectOption[] shipToAddresses
    {
        get
        {
            if(shipToAddresses == null) shipToAddresses = new SelectOption[0];
            return shipToAddresses;
        }
        set {shipToAddresses = value;}
    }

    public String shipToAccountID {get; set;}

    public Boolean foundAddresses
    {
        get
        {
            if(shipToAddresses.size() > 0)
                return true;
            else
                return false;
        }
    }

    public String searchProductCode {get; set;}

    public String searchDescription {get; set;}

    public String searchVendorName {get; set;}

    public String searchVendorProductCode {get; set;}

    public ProductWrapper[] productResults
    {
        get
        {
            if(productResults == null) productResults = new ProductWrapper[0];
            return productResults;
        }
        set {productResults = value;}
    }

    public QLIWrapper[] selectedProducts
    {
        get
        {
            if(selectedProducts == null) selectedProducts = new QLIWrapper[0];
            return selectedProducts;
        }
        set {selectedProducts = value;}
    }

    public Boolean foundProducts
    {
        get
        {
            if(productResults.size() > 0)
                return true;
            else
                return false;
        }
    }

    public Boolean hasSelectedProductResults
    {
        get
        {
            if(productResults.size() > 0)
            {
                for(ProductWrapper pw : productResults)
                    if(pw.isSelected) return true;
                return false;
            }
            else
                return false;
        }
    }

    public Integer foundProductsResize
    {
        get
        {
            if(productResults.size() > 0)
                return Math.min(360, productResults.size() * 60);
            else
                return 20;
        }
    }

    public Integer foundProductsSize
    {
        get
        {
            return productResults.size();
        }
    }
    //This property used in VF to format product fields for input on search options
    public Product2 product
    {
        get
        {
            if(product == null) product = new Product2();
            return product;
        }
        set {product = value;}
    }

    public SelectOption[] availableDivisions
    {
        get
        {
            SelectOption[] options = new SelectOption[0];
            for(Servicing_Division__c div : [select Id, Name, Division_Code__c from Servicing_Division__c WHERE Active__c = true
            ORDER BY Division_Code__c])
            //order by Sort_Order__c])
            {
                options.add(new SelectOption(div.Id, div.Division_Code__c + ' - ' + div.Name, false));
                if(div.Name == this.quote.Servicing_Division_Name__c)
                    selectedDivisions.add(div.Id);
            }
            return options;
        }
    }

    public ID[] selectedDivisions
    {
        get
        {
            if(selectedDivisions == null) selectedDivisions = new ID[0];
            return selectedDivisions;
        }
        set {selectedDivisions = value;}
    }

    public Boolean hasSelectedProducts
    {
        get
        {
            if(selectedProducts.size() > 0)
                return true;
            else
                return false;
        }
    }

    public Boolean hasPricingProducts
    {
        get
        {
            if(pricingProducts.size() > 0)
                return true;
            else
                return false;
        }
    }
    //Commented by Sujitha
    /*
    public Boolean isFordis
    {
         get
        {
           String department = [Select Department From User Where Id = : UserInfo.getUserId() Limit 1].Department;
            if (department == Consts.FORDIS_DEPARTMENT)
                return true;
            else
                return false;
        }
        set;
    }
  */

//Commented by Sujitha
/*
    public Boolean isWebsource
    {
        get
        {
           String department = [Select Department From User Where Id = : UserInfo.getUserId() Limit 1].Department;
            if (department == Consts.WEBSOURCE_DEPARTMENT)
                return true;
            else
                return false;
        }
        set;
    }
//Changed  by Sujitha -Quote Logo Display based on Account rather than User record
 */
   /* public Boolean isSaalfeld
    {
        get
        {
            String businessGroup = [Select Account__r.VOS_Business_Group__c From Quote__c Where Id = :quote.Id Limit 1].Account__r.VOS_Business_Group__c;
            
            if(businessGroup == 'SA')
                 return true;
            else
              return false;
        }
        set;
    }*/

    public Boolean isSalesRepPDF
    {
        get
        {
            return quoteTemplateTitle == SALES_REP_TITLE;
        }
        set;
    }

    public Boolean isVendorPDF
    {
        get
        {
            return quoteTemplateTitle == VENDOR_TITLE;
        }
        set;
    }

    public Boolean isCustomerPDF
    {
        get
        {
            return quoteTemplateTitle == CUSTOMER_TITLE;
        }
    }

    public Boolean isPrintableViewPDF
    {
        get
        {
            return !isSalesRepPDF && !isVendorPDF && !isCustomerPDF;
        }
    }

    public Integer rowIndex {get; set;}

    public String openPricingAndAvailability
    {
        get
        {
            String queryParms = '';
            for(Integer i=0; i < productResults.size(); i++)
            {
                if(productResults[i].isSelected)
                    queryParms += '&pid' + i + '=' + productResults[i].product.Id;
            }

            return 'window.open("' + Page.PricingAndAvailabilityQLI.getURL() + '?id=' + this.quote.Id + queryParms + '", "", "width=1200px, height=900px, resizable, scrollbars"); return false;';
        }
    }

    public ProductWrapper[] pricingProducts
    {
        get
        {
            if(pricingProducts == null) pricingProducts = new ProductWrapper[0];
            return pricingProducts;
        }
        set {pricingProducts = value;}
    }

    public Opportunity extendedPriceTotal
    {
        get
        {
            if(extendedPriceTotal == null) extendedPriceTotal = new Opportunity();
            return extendedPriceTotal;
        }
        set {extendedPriceTotal = value;}
    }

    public Opportunity gtmTotal
    {
        get
        {
            if(gtmTotal == null) gtmTotal = new Opportunity();
            return gtmTotal;
        }
        set {gtmTotal = value;}
    }

    //Actions
    public PageReference findShipToAddresses()
    {
        //Return error if quote id not found
        if(!isValidQuote)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This page cannot be accessed directly.  It can only be reached from the "Select Ship To Address" button on a quote record.'));
            return null;
        }

        shipToAddresses.clear();
        for(Ship_To__c shipToAccount : [select State__c, Ship_To_Code__c, Account_Owner__c, Postal_Code__c, Name, Id, City__c, Address_Line2__c, Address_Line1__c
                                     from Ship_To__c
                                     where Bill_To_Account__c = :this.quote.Account__c
                                     and Active__c = 'Yes'
                                     order by Ship_To_Code__c
                                     limit 999])
        {
            String curShipToAddress = '';
            if(shipToAccount.Ship_To_Code__c != null && shipToAccount.Ship_To_Code__c.length() >= 12 )
                    curShipToAddress = shipToAccount.Ship_To_Code__c.length() == 12 ? shipToAccount.Ship_To_Code__c.substring(6) + ' - ' : shipToAccount.Ship_To_Code__c.substring(10) + ' - ';
            
            //if(shipToAccount.Ship_To_Code__c != null && shipToAccount.Ship_To_Code__c.length() == 12)
            //  curShipToAddress = shipToAccount.Ship_To_Code__c.substring(6) + ' - ';
            curShipToAddress += shipToAccount.Name != null? shipToAccount.Name: '';
            curShipToAddress += shipToAccount.Address_Line1__c != null? '\n' + shipToAccount.Address_Line1__c: '';
            curShipToAddress += shipToAccount.Address_Line2__c != null? '\n' + shipToAccount.Address_Line2__c: '';
            curShipToAddress += shipToAccount.City__c != null? '\n' + shipToAccount.City__c: '';
            curShipToAddress += shipToAccount.State__c != null? ', ' + shipToAccount.State__c: '';
            curShipToAddress += shipToAccount.Postal_Code__c != null? ', ' + shipToAccount.Postal_Code__c: '';
            shipToAddresses.add(new SelectOption(shipToAccount.Id, curShipToAddress));
            id2shipTo.put(shipToAccount.Id, shipToAccount);
        }
        //Alert user if no matching addresses found
        if(shipToAddresses.size() == 0)
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Ship To Addresses found for account ' + this.quote.Account__r.Name + '.'));
             shipToAddresses.add(new SelectOption( '', 'None' ) );
        }
        else
            shipToAddresses.add( 0, new SelectOption( '', 'None' ) );

        return null;
    }

    public PageReference checkQuote()
    {
        //Return error if quote id not found
        if(!isValidQuote)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This page cannot be accessed directly.  It can only be reached from the "Add/Edit Line Items" button on a quote record.'));

        return null;
    }

    public PageReference checkPricingProducts()
    {
        //Validation rules
        //Return error if quote id not found
        if(!isValidQuote)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This page cannot be accessed directly.  It can only be reached from the "Fetch P&A" button in the "Add/Edit Line Item(s)" screen.'));
            return null;
        }
        //Return error if no products checked
        ID[] productIDs = new ID[0];
        for(String queryParm : ApexPages.currentPage().getParameters().keySet())
        {
            if(queryParm != 'id')
                productIDs.add(ApexPages.currentPage().getParameters().get(queryParm));
        }
        if(productIDs.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No products have been selected.  Please close this window and select at least one.'));
            return null;
        }

        //item-2601
        for(zpl__ContractLineItem__c cli : [SELECT Id,zpl__Status__c, zpl__EffectiveDate__c, zpl__PolicyValue__c, zpl__Contract__c, zpl__Product__c, Division_Code__c FROM zpl__ContractLineItem__c 
                                    WHERE zpl__Contract__r.AccountId =: this.quote.Account__c 
                                    AND zpl__Product__c IN :productIDs 
                                    AND zpl__Status__c = 'Published' 
                                    AND zpl__EffectiveDate__c < TODAY ORDER BY zpl__EffectiveDate__c DESC ]){ 
                    //filter by zpl__EffectiveDate__c < TODAY, so that it wont capture CLI that is beyond the start date
                    //order by zpl__EffectiveDate__c so that the latest CLI is on top of the list.
                    //with these two, we will only put latest and valid CLI on a map, per product
                    
                    //add product to map ONCE
                    if(!mProductToPoliceValue.containsKey(cli.zpl__Product__c)){
                        mProductToPoliceValue.put(cli.zpl__Product__c, cli);
                    }
        }
        //end item-2601


        //Add to wrapper array and make P&A call
        Integer counter = 0;
        for(Product2 product : [select p.System_ID__c, p.Pricing_Costing_UOM__c, p.Division_Code__c, p.Vendor_Product_Code__c, p.Description, p.ProductCode from Product2 p where ID in :productIDs])
        {
            counter++;
            ProductWrapper pw = new ProductWrapper(product);
            pricingProducts.add(pw);

            if(counter > 10)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'P&A can only be retrieved for 10 products at a time. Only the first 10 products\' P&A info is displayed.'));
            else
            {
                pw.PandA = getPandAData(product);
                //item-2601
                if(mProductToPoliceValue.containsKey(product.Id) ){
                    System.debug('product.Id ' + product.Id);
                    if(mProductToPoliceValue.get(product.Id).Division_Code__c == product.Division_Code__c){ // assign only if they have the same division
                        pw.price = new Opportunity(Amount=Double.valueOf( mProductToPoliceValue.get(product.Id).zpl__PolicyValue__c));
                    }
                }
                //end item-2601
                if(pw.PandA.Response.Errors.size() > 0)
                {
                    for(PricingAndAvailability.ErrorsClass ec : pw.PandA.Response.Errors)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ec.description));
                }
                //System.debug('pw.price.Amount ' + pw.price.Amount);
            }
        }

        return null;
    }

    public PageReference createQuote()
    {
        //Validation rules
        //Return error if quote id not found
        if(!isValidQuote)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This page cannot be accessed directly.  It can only be reached from the "Send To" buttons in the Quote screen.'));
            return null;
        }
        //Return error if no products checked
        ID[] qliIDs = new ID[0];
        for(String queryParm : ApexPages.currentPage().getParameters().keySet())
        {
            if(queryParm.startsWith('qlid'))
                qliIDs.add(ApexPages.currentPage().getParameters().get(queryParm));
        }
        if(qliIDs.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No quote line items have been selected.  Please click back and select at least one.'));
            return null;
        }

        //Add to selected array and calculate totals
        extendedPriceTotal.Amount = 0;
        gtmTotal.Amount = 0;


        String query = 'select End_User_Agreement__c, Price_Code__c, Cost_Code__c, GTM_CAS__c, ';
        query += 'GTM_percent__c, Vendor_Name__r.Name, Extended_Price__c, ';
        query += 'Projected_Delivery_Date__c, Vendor_Contact__r.Email, ';
        query += 'Vendor_Contact__r.Phone, Vendor_Contact__r.Name, ';
        query += 'Vendor_Item__c, Bid_number_Contract_number__c, mfg_tolerance__c, ';
        query += 'Special_Item__c, Special_Product__c, Quantity_unit_of_measure__c, ';
        query += 'Qty__c, Product_Description__c, Product_Code__c, ';
        query += 'Price_unit_of_measure__c, Price__c, Minimum_mfg_quantity__c, ';
        query += 'Last_Date_of_Change__c, Costing_unit_of_measure__c, Cost__c,Comments_Short__c, ';
        query += 'Roll_Size__c, Basis_Weight__c, Brand__c, Brightness__c, Finish__c, Color__c, ';
        query += 'Outer_Diameter__c, Core__c, Recycled_Content__c, PCW_Content__c, COC_Required__c, ';
        query += 'CostCommision__c, Last_Date_to_Order__c ';
        query += 'from Quote_Line_Item__c where ID in :qliIDs';

        query += ' ORDER BY Item_Seq__c ASC';//query += ' ORDER BY CreatedDate ASC';

        System.debug('** QUERY *** ' + query);

        for(Quote_Line_Item__c qli : Database.query(query))
        {
            extendedPriceTotal.Amount += qli.Extended_Price__c == null? 0: qli.Extended_Price__c;
            gtmTotal.Amount += qli.GTM_CAS__c == null? 0: qli.GTM_CAS__c;
            selectedQLIs.add(qli);
        }

        return null;
    }

    public PageReference saveShipToAddress()
    {
        //Get address
        String shipToAddress = '';
        for(SelectOption so : shipToAddresses)
        {
            if(so.getValue() == shipToAccountID)
            {
                try
                {
                    Integer.valueOf(so.getLabel().substring(0, 6));
                }
                catch(Exception e)
                {
                    shipToAddress = so.getLabel().substring(3);
                    break;
                }
                shipToAddress = so.getLabel().substring(9);
                break;
            }
        }

        Savepoint sp = Database.setSavepoint();


        try
        {
            Quote__c quoteToUpdate = new Quote__c(Id=this.quote.Id,Ship_To_Address__c=shipToAddress);

            // if the ship to is to be nulled, the primary sales rep comes from the quote's account
            if( shipToAccountId == '' || shipToAccountId == null )
            {
                quoteToUpdate.Ship_To__c = null;
                List<Account> quoteAccount = [ SELECT Id, Primary_Sales_Rep_Name__c FROM Account WHERE Id = :quote.Account__c LIMIT 1 ];
                if( !quoteAccount.isEmpty() )
                {
                    quoteToUpdate.Primary_Sales_Rep__c = quoteAccount[0].Primary_Sales_Rep_Name__c;
                }
            }
            // otherwise pull the primary sales rep from the ship to itself
            else
            {
                quoteToUpdate.Ship_To__c = shipToAccountId;
                List<Primary_Sales_Rep__c> primarySalesRep = [ SELECT Id FROM Primary_Sales_Rep__c WHERE sf_userid__c = :id2shipTo.get(shipToAccountId).Account_Owner__c LIMIT 1 ];
                if( !primarySalesRep.isEmpty() )
                {
                    quoteToUpdate.Primary_Sales_Rep__c = primarySalesRep[0].Id;
                }
            }
            update quoteToUpdate;
        }
        catch(DmlException dmle)
        {
            for (Integer i=0; i < dmle.getNumDml(); i++)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmle.getDmlMessage(i)));

            Database.rollback(sp);
            return null;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return null;
        }

        return quoteController.view();
    }

    public PageReference searchProducts()
    {
        productResults.clear();
        //Validation rules
        if(searchProductCode.trim().length() == 0 && searchDescription.trim().length() == 0 && searchVendorName.trim().length() == 0 && searchVendorProductCode.trim().length() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one of the four search query strings must not be blank.'));
            return null;
        }
        if(searchProductCode.trim().length() > 0 && searchProductCode.replace('%','').length() <= 1)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Product Code search string must be longer than one character.'));
            return null;
        }
        if(searchDescription.trim().length() > 0 && searchDescription.replace('%','').length() <= 1)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Description search string must be longer than one character.'));
            return null;
        }
        if(searchVendorName.trim().length() > 0 && searchVendorName.replace('%','').length() <= 1)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vendor Name search string must be longer than one character.'));
            return null;
        }
        if(searchVendorProductCode.trim().length() > 0 && searchVendorProductCode.replace('%','').length() <= 1)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vendor Product Code search string must be longer than one character.'));
            return null;
        }
        if(selectedDivisions.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Servicing Division found on this quote.  Please select at least one Division before searching again.'));
            return null;
        }
        //Validation rules passed, continue
        //Prepare SOQL query
        String soqlQuery = 'select Id, System_ID__c, Vendor__r.Name, Conversion_Factor__c, Pricing_Costing_UOM__c, ProductCode, Description, Stocking_Flag__c, Unit_of_Measure__c, Division_Name__c, Division_Code__c, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c from Product2 where Division_Name__c in (';
        //Add selected divisions to in clause
        for(ID selectedDivisionID : selectedDivisions)
            soqlQuery += '\'' + selectedDivisionID + '\',';
        //Delete last comma then add right parenthesis
        soqlQuery = soqlQuery.substring(0, soqlQuery.length() - 1);
        soqlQuery += ')';
        //Add stocking flag filter is true
        if(product.Stocking_Flag__c)
            soqlQuery += ' and Stocking_Flag__c = true';
        if(searchProductCode.trim().length() > 0)
            soqlQuery += ' and ProductCode = \'' + searchProductCode + '\'';
        if(searchDescription.trim().length() > 0)
        {
            String[] searchTerms = searchDescription.split(',');
            for(String searchTerm : searchTerms)
                soqlQuery += ' and Description like \'%' + searchTerm.trim() + '%\'';
        }
        if(searchVendorName.trim().length() > 0)
            soqlQuery += ' and Vendor__r.Name like \'%' + searchVendorName + '%\'';
        if(searchVendorProductCode.trim().length() > 0)
            soqlQuery += ' and Vendor_Product_Code__c = \'' + searchVendorProductCode + '\'';
        soqlQuery += ' limit 1000';

        // TODO
        // Need to escaping the query string

        for(Product2 product : Database.query(soqlQuery))
            productResults.add(new ProductWrapper(product));


        return null;
    }

    public PageReference addQuoteLineItems()
    {
        for(ProductWrapper pw : productResults)
        {
            if(pw.isSelected)
            {
                Quote_Line_Item__c qli = new Quote_Line_Item__c();
                qli.Product__c = pw.product.Id;
                qli.Product__r = pw.product;
                qli.Product_Code__c = pw.product.ProductCode;
                qli.Unisource_Item__c = pw.product.Unisource_Item_Number_U_number__c;
                qli.Vendor_Item__c = pw.product.Vendor_Product_Code__c;
                qli.Product_Description__c = pw.product.Description;
                qli.Unisource_Item__c = pw.product.Unisource_Item_Number_U_number__c;
                qli.Vendor_Name__c = pw.product.Vendor__c;
                qli.Quote__c = this.quote.Id;
                qli.Qty__c = 1;
                qli.Quantity_unit_of_measure__c = pw.product.Unit_of_Measure__c;
                qli.Price_unit_of_measure__c = pw.product.Pricing_Costing_UOM__c;
                qli.Costing_unit_of_measure__c = pw.product.Pricing_Costing_UOM__c;
                qli.Quantity_Unit_Factor__c = 1;
                qli.Price_Unit_Factor__c = pw.product.Conversion_Factor__c;
                qli.Cost_Unit_Factor__c = pw.product.Conversion_Factor__c;
                qli.Projected_Delivery_Date__c = quote.Requested_Delivery_Date__c;
                //Make non integer product codes special products
                try
                {
                    Integer.valueOf(pw.product.ProductCode.substring(0,1));
                }
                catch(Exception e)
                {
                    qli.Special_Product__c = true;
                }

                // Add new Product to bottom of list
                selectedProducts.add(new QLIWrapper(qli));

                //Clear check
                pw.isSelected = false;
            }
        }
        return null;
    }

    public PageReference addSpecialQuoteLineItem()
    {
        Quote_Line_Item__c qli = new Quote_Line_Item__c();
        qli.Quote__c = this.quote.Id;
        qli.Special_Item__c = true;
        qli.Projected_Delivery_Date__c = quote.Requested_Delivery_Date__c;
        QLIWrapper qliw = new QLIWrapper(qli);

        // Add new Product to bottom of list
        selectedProducts.add(qliw);

        return null;
    }

    public PageReference deleteQuoteLineItem()
    {
        //Only add QLI to delete array if ID not null
        if(selectedProducts[rowIndex].qli.Id != null) qlisToDelete.add(selectedProducts[rowIndex].qli);
        selectedProducts.remove(rowIndex);
        this.calculateRunningTotals();
        return null;
    }

    public PageReference cloneQuoteLineItem()
    {
        QLIWrapper oldQLI = selectedProducts.get(rowIndex);
        QLIWrapper newQLI = new QLIWrapper(oldQLI.qli.clone(false, true));
        newQLI.qli.Quote__c = this.quote.Id;
        selectedProducts.add(rowIndex, newQLI);
        this.calculateRunningTotals();
        return null;
    }

    public PageReference showPandAForProduct()
    {
        if(selectedProducts[rowIndex].showPandA)
            selectedProducts[rowIndex].showPandA = false;
        else
            selectedProducts[rowIndex].showPandA = true;

        calcExtendedPrice();

        return null;
    }

    public PageReference getPandAForProduct()
    {
        getPandAData(selectedProducts[rowIndex]);

        if(selectedProducts[rowIndex].PandA.Response.Errors.size() > 0)
        {
            for(PricingAndAvailability.ErrorsClass ec : selectedProducts[rowIndex].PandA.Response.Errors)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ec.description));
        }

        fillUOM(selectedProducts[rowIndex]);
        assignUnitFactors(selectedProducts[rowIndex]);
        assignQLIValues(selectedProducts[rowIndex]);
        calcExtendedPrice();

        return null;
    }

    public PageReference getPandAForSelectedProducts()
    {
        getPandAData(selectedProducts);

        for(QLIWrapper qliw : selectedProducts)
        {
            if(qliw.PandA.Response.Errors.size() > 0)
            {
                for(PricingAndAvailability.ErrorsClass ec : qliw.PandA.Response.Errors)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ec.description));
            }

            fillUOM(selectedProducts);
            assignUnitFactors(selectedProducts);
            assignQLIValues(selectedProducts);

            for(rowIndex = 0; rowIndex < selectedProducts.size(); rowIndex++)
            {
                if(!selectedProducts[rowIndex].qli.Special_Item__c)
                    calcExtendedPrice();
            }
        }
        return null;
    }

    private void assignUnitFactors(QLIWrapper qliw)
    {
        if(qliw.PandA.Response.UnitsOfMeasure.size() > 0)
        {
            qliw.qli.Price_Unit_Factor__c = getUnitFactor(qliw, qliw.qli.Price_unit_of_measure__c);
            qliw.qli.Quantity_Unit_Factor__c = getUnitFactor(qliw, qliw.qli.Quantity_unit_of_measure__c);
            qliw.qli.Cost_Unit_Factor__c = getUnitFactor(qliw, qliw.qli.Costing_unit_of_measure__c);
        }
    }

    public void assignUnitFactors(QLIWrapper[] qliws)
    {
        for(QLIWrapper qliw : qliws)
        {
            if(!qliw.qli.Special_Item__c)
                assignUnitFactors(qliw);
        }
    }

    private void assignQLIValues(QLIWrapper qliw)
    {
        if(qliw.PandA.Response.ItemDetails.size() > 0)
        {
            qliw.qli.Cost__c = Double.valueOf(qliw.PandA.Response.ItemDetails[0].ItemCostStandard);
            qliw.qli.Price_unit_of_measure__c = qliw.PandA.Response.ItemDetails[0].ItemPricingUOM;
            qliw.qli.Costing_unit_of_measure__c = qliw.PandA.Response.ItemDetails[0].ItemPricingUOM;
            qliw.qli.Price__c = Double.valueOf(qliw.PandA.Response.ItemDetails[0].ItemPricePerUOM);
            qliw.qli.Cost_Code__c = qliw.PandA.Response.ItemDetails[0].ItemCostCode;
            qliw.qli.Price_Code__c = qliw.PandA.Response.ItemDetails[0].ItemPriceCode;
        }
        if(qliw.PandA.Response.Availability.size() > 0)
            qliw.qli.Minimum_mfg_quantity__c = getMinimumPurchase(qliw, qliw.qli.Product__r.Division_Code__c);
    }

    public void assignQLIValues(QLIWrapper[] qliws)
    {
        for(QLIWrapper qliw : qliws)
        {
            if(!qliw.qli.Special_Item__c)
                assignQLIValues(qliw);
        }
    }

    private Double getUnitFactor(QLIWrapper qliw, String uom)
    {
        for(PricingAndAvailability.UnitsOfMeasureClass uomc : qliw.PandA.Response.UnitsOfMeasure)
        {
            if(uomc.UOMName == uom)
                return Double.valueOf(uomc.UOMFactor);
        }
        return 1;
    }

    private Double getMinimumPurchase(QLIWrapper qliw, String divisionCode)
    {
        for(PricingAndAvailability.AvailabilityClass ac : qliw.PandA.Response.Availability)
        {
            if(ac.ItemDivisionId == divisionCode)
            {
                return Double.valueOf(ac.ItemMinimumPurchase);
            }
        }
        return 0;
    }

    private void getPandAData(QLIWrapper qliw)
    {
        qliw.enableUOM = true;

        qliw.PandA.Request.SystemIdentifier = this.quote.System_Code__c;
        qliw.PandA.Request.DivisionID = this.quote.Servicing_Division__c;

        if(this.quote.Account__r.RecordType.Name == 'Prospect')
        {
            try
            {
                qliw.PandA.Request.CustomerID = [select Dummy_Bill_To_Number__c from Servicing_Division__c where System_Code__c = :this.quote.System_Code__c and Division_Code__c = :this.quote.Servicing_Division__c].Dummy_Bill_To_Number__c;
            }
            catch(Exception e)
            {
                qliw.PandA.Request.CustomerID = null;
            }
        }
        else
            qliw.PandA.Request.CustomerID = this.quote.Account__r.AccountNumber;

        qliw.PandA.Request.ShipToID = this.quote.Ship_To_Number__c;
        qliw.PandA.Request.CIFItemID = qliw.qli.Product_Code__c;
        qliw.PandA.Request.Quantity = String.valueOf(qliw.qli.Qty__c);
        qliw.PandA.Request.QuantityUOM = qliw.qli.Quantity_unit_of_measure__c;
        qliw.PandA.Request.PricingUOM = qliw.qli.Price_unit_of_measure__c;

        qliw.PandA.getData();
    }

    private void getPandAData(QLIWrapper[] qliws)
    {
        Integer counter = 0;
        for(QLIWrapper qliw : qliws)
        {
            if(!qliw.qli.Special_Item__c)
            {
                counter++;
                if(counter > 10)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'P&A can only be retrieved for 10 line items or less. Only the first 10 line items have been updated, the rest will have to be updated individually.'));
                    return;
                }
                getPandAData(qliw);
            }
        }
    }

    public PricingAndAvailability getPandAData(Product2 product)
    {
        PricingAndAvailability paa = new PricingAndAvailability();

        paa.Request.SystemIdentifier = product.System_ID__c;
        paa.Request.DivisionID = product.Division_Code__c;

        if(quote.Account__r.RecordType.Name == 'Prospect'
            || this.quote.Servicing_Division__c != product.Division_Code__c )
        {
            try
            {
                paa.Request.CustomerID = [select Dummy_Bill_To_Number__c from Servicing_Division__c where System_Code__c = :product.System_ID__c and Division_Code__c = :product.Division_Code__c].Dummy_Bill_To_Number__c;
            }
            catch(Exception e)
            {
                paa.Request.CustomerID = null;
            }
        }
        else
            paa.Request.CustomerID = this.quote.Account__r.AccountNumber;

        if( product.Division_Code__c != this.quote.Servicing_Division__c  )
            paa.Request.ShipToID    = null;
        else
            paa.Request.ShipToID = this.quote.Ship_To_Number__c;


        //paa.Request.ShipToID = this.quote.Ship_To_Number__c;
        paa.Request.CIFItemID = product.ProductCode;
        paa.Request.Quantity = '1';
        paa.Request.QuantityUOM = product.Pricing_Costing_UOM__c;
        paa.Request.PricingUOM = product.Pricing_Costing_UOM__c;

        paa.getData();

        return paa;
    }

    public void getPandAData(Product2[] products)
    {
        Integer counter = 0;
        for(Product2 product : products)
        {
            counter++;
            if(counter > 10)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'P&A can only be retrieved for 10 products at a time. Only the first 10 products\' P&A info is displayed.'));
                return;
            }
            getPandAData(product);
        }
    }

    private void fillUOM(QLIWrapper qliw)
    {
        qliw.quantityUOMs.clear();
        qliw.priceUOMs.clear();
        for(PricingAndAvailability.UnitsOfMeasureClass uomc : qliw.PandA.Response.UnitsOfMeasure)
        {
            if(uomc.UOMDisplayForPriceOrQuantity == 'B')
            {
                qliw.quantityUOMs.add(new SelectOption(uomc.UOMName, uomc.UOMName));
                qliw.priceUOMs.add(new SelectOption(uomc.UOMName, uomc.UOMName));

                if(qliw.qli.Quantity_unit_of_measure__c == null && uomc.UOMIsItemDefaultForQuantity == 'Y')
                    qliw.qli.Quantity_unit_of_measure__c = uomc.UOMName;
                if(qliw.qli.Price_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
                    qliw.qli.Price_unit_of_measure__c = uomc.UOMName;
                if(qliw.qli.Costing_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
                    qliw.qli.Costing_unit_of_measure__c = uomc.UOMName;
            }
            else if(uomc.UOMDisplayForPriceOrQuantity == 'Q')
            {
                qliw.quantityUOMs.add(new SelectOption(uomc.UOMName, uomc.UOMName));

                if(qliw.qli.Quantity_unit_of_measure__c == null && uomc.UOMIsItemDefaultForQuantity == 'Y')
                    qliw.qli.Quantity_unit_of_measure__c = uomc.UOMName;
            }
            else if(uomc.UOMDisplayForPriceOrQuantity == 'P')
            {
                qliw.priceUOMs.add(new SelectOption(uomc.UOMName, uomc.UOMName));

                if(qliw.qli.Price_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
                    qliw.qli.Price_unit_of_measure__c = uomc.UOMName;
                if(qliw.qli.Costing_unit_of_measure__c == null && uomc.UOMIsItemDefaultForPrice == 'Y')
                    qliw.qli.Costing_unit_of_measure__c = uomc.UOMName;
            }
        }
    }

    public void fillUOM(QLIWrapper[] qliws)
    {
        for(QLIWrapper qliw : qliws)
        {
            if(!qliw.qli.Special_Item__c)
                fillUOM(qliw);
        }
    }

    public void calculateRunningTotals()
    {
        this.extendedPriceRunningTotal = 0.00;
        this.GTMRunningTotal = 0.00;


        for(QLIWrapper calcAll : this.selectedProducts)
        {
            if(calcAll.qli.Extended_Price__c != null)
            this.extendedPriceRunningTotal += calcAll.qli.Extended_Price__c.setScale(2);

            if(calcAll.qli.GTM_CAS__c != null)
            this.GTMRunningTotal += calcAll.qli.GTM_CAS__c.setScale(2);
        }
       this.extendedPriceRunningTotal = this.extendedPriceRunningTotal.setScale(2);
       this.GTMRunningTotal = this.GTMRunningTotal.setScale(2);
    }

    public PageReference calcExtendedPrice()
    {
        assignUnitFactors(selectedProducts[rowIndex]);
        Double quantity = selectedProducts[rowIndex].qli.Qty__c;
        Double quantityUnitFactor = selectedProducts[rowIndex].qli.Quantity_Unit_Factor__c;
        Double price = selectedProducts[rowIndex].qli.Price__c;
        Double priceUnitFactor = selectedProducts[rowIndex].qli.Price_Unit_Factor__c;
        Double cost = selectedProducts[rowIndex].qli.Cost__c;
        Double costUnitFactor = selectedProducts[rowIndex].qli.Cost_Unit_Factor__c;
        if(quantity != null && price != null && priceUnitFactor != null && quantityUnitFactor != null)
        {
            if(priceUnitFactor > 0)
                if(quantityUnitFactor >= 0)
                    selectedProducts[rowIndex].qli.Extended_Price__c = (price / priceUnitFactor) * quantityUnitFactor * quantity;
                else
                    selectedProducts[rowIndex].qli.Extended_Price__c = ((price / priceUnitFactor) / Math.abs(quantityUnitFactor)) * quantity;
            else
                if(quantityUnitFactor >= 0)
                    selectedProducts[rowIndex].qli.Extended_Price__c = price * Math.abs(priceUnitFactor) * quantityUnitFactor * quantity;
                else
                    selectedProducts[rowIndex].qli.Extended_Price__c = ((price * Math.abs(priceUnitFactor)) / Math.abs(quantityUnitFactor)) * quantity;

            selectedProducts[rowIndex].qli.GTM_CAS__c = selectedProducts[rowIndex].qli.Extended_Price__c - selectedProducts[rowIndex].extendedCost.Amount;
        }
        if(quantity != null && cost != null && costUnitFactor != null && quantityUnitFactor != null)
        {
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
            Double extendedPrice = selectedProducts[rowIndex].qli.Extended_Price__c == null? 0: selectedProducts[rowIndex].qli.Extended_Price__c;
            selectedProducts[rowIndex].qli.GTM_CAS__c = extendedPrice - extendedCost;
        }
        if(price < cost)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The unit price is less than the cost.'));

       this.calculateRunningTotals();

        return null;
    }

    public PageReference saveQuoteLineItems()
    {
        //Recalc extended price and GTM, and check for freight lines
        Boolean foundFreightLine = false;
        for(Integer i=0; i < selectedProducts.size(); i++)
        {
            rowIndex = i;
            //Only recalculate if not special item
            if(!selectedProducts[i].qli.Special_Item__c)
                calcExtendedPrice();

            if(this.quote.Shipment_Method__c == 'Direct')
            {
                if(selectedProducts[i].qli.Product_Code__c == 'CFREIGHT' ||
                   selectedProducts[i].qli.Product_Code__c == 'NFREIGHT' ||
                   selectedProducts[i].qli.Product_Code__c == 'SFREIGHT' ||
                   selectedProducts[i].qli.Product_Code__c == 'UFREIGHT' ||
                   selectedProducts[i].qli.Product_Code__c == 'IFREIGHT' ||
                   selectedProducts[i].qli.Product_Code__c == 'CFREIGHT3P' ||
                   selectedProducts[i].qli.Product_Code__c == 'UFREIGHT3P'
                   )
                    foundFreightLine = true;
            }
        }
        //Quote header validation rules
        if(this.quote.Shipment_Method__c == 'Direct' && !foundFreightLine)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No freight lines found on this direct order quote.  Please add a freight product and save again.'));
            return null;
        }
        //Validation rules passed, continue
        Quote_Line_Item__c[] qlisToUpsert = new Quote_Line_Item__c[0];

        Boolean allSuccessfull = true;
        for(Integer i=0; i < selectedProducts.size(); i++)
        {
            //Quote line item validation rules
            if(selectedProducts[i].qli.Cost__c != null && selectedProducts[i].qli.Cost__c != 0)
            {
                if(selectedProducts[i].qli.Price_unit_of_measure__c != selectedProducts[i].qli.Costing_unit_of_measure__c)
                {
                    String errMsg = 'Error in line ' + (1 + i) + '. ';
                    errMsg += 'If cost is entered the cost UOM and price UOM must be the same.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
                    allSuccessfull = false;
                }
            }
            qlisToUpsert.add(selectedProducts[i].qli);
        }
        //Halt if line item validation failed
        if(!allSuccessfull) return null;

        Savepoint sp = Database.setSavepoint();

        try
        {
            upsert qlisToUpsert;
            delete qlisToDelete;
        }
        catch(DmlException dmle)
        {
            for (Integer i=0; i < dmle.getNumDml(); i++)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmle.getDmlMessage(i)));

            Database.rollback(sp);
            return null;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return null;
        }

        return quoteController.view();
    }
}
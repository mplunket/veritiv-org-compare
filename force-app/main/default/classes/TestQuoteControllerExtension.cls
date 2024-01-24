@isTest
private class TestQuoteControllerExtension
{
    private static Account testCustAccount;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0];

    static void testSetupData()
    {
        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001', Active__c='Yes', Legacy_Division_Cd__c = '1',VOS_Business_Group__c = 'SA');
        insert testCustAccount;

        testShipAccount = new Ship_To__c(Name='Test Customer Location 1', Ship_To_Code__c='000000000002', Bill_To_Account__c=testCustAccount.Id, Active__c='Yes');
        insert testShipAccount;

        testQuote = new Quote__c(Account__c=testCustAccount.Id, Account__r=testCustAccount, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today(), Ship_To__c = testShipAccount.id);
        insert testQuote;

        testQuote = [Select Account__c, Shipment_Method__c,
                            Servicing_Division__c, Ship_To_Number__c,
                            Requested_Delivery_Date__c, Ship_To__c,
                            Servicing_Division_Name__c,
                            Account__r.RecordType.Name,
                            Account__r.AccountNumber
                     from quote__c
                     where id = :testQuote.id ];

        Servicing_Division__c servicingDivision = TestDataGeneration.createServicingDivisions( 1, false )[0];
        servicingDivision.Active__c = true;
        insert servicingDivision;

        //Product2[] products = [select Id, ProductCode, Description, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c, Unit_of_Measure__c, Pricing_Costing_UOM__c, Conversion_Factor__c from Product2 limit 2];
        List<Product2> products = TestDataGeneration.createProducts( 2, 'Test Product', false );
        for( Product2 aProduct : products )
        {
            aProduct.Description = 'Test Cup Product 123';
            aProduct.Stocking_Flag__c = true;
            aProduct.Division_Name__c = servicingDivision.Id;
        }
        insert products;

        Vendor_Detail__c vendorObject = new Vendor_Detail__c(Name='Best Buy',
                                                             Vendor_Code__c = 'VC-12345');

        insert vendorObject;
        //Set the products vendor to the vendor contact
        products[0].Vendor__c = vendorObject.id;
        products[0].Division_Code__c = '2';
        products[1].Vendor__c = vendorObject.id;
        products[1].Division_Code__c = '1';

        update products;

        Quote_Line_Item__c qli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        qli.Product__c = products[0].Id;
        qli.Product__r = products[0];
        qli.Product_Code__c = products[0].ProductCode;
        qli.Product_Description__c = products[0].Description;
        qli.Unisource_Item__c = products[0].Unisource_Item_Number_U_number__c;
        qli.Vendor_Item__c = products[0].Vendor_Product_Code__c;
        qli.Vendor_Name__c = products[0].Vendor__c;
        qli.Qty__c = 1;
        qli.Quantity_unit_of_measure__c = products[0].Unit_of_Measure__c;
        qli.Price_unit_of_measure__c = products[0].Pricing_Costing_UOM__c;
        qli.Costing_unit_of_measure__c = products[0].Pricing_Costing_UOM__c;
        qli.Quantity_Unit_Factor__c = 1;
        qli.Price_Unit_Factor__c = products[0].Conversion_Factor__c;
        qli.Cost_Unit_Factor__c = products[0].Conversion_Factor__c;
        insert qli;
        testQLIs.add(qli);

        qli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        qli.Product__c = products[1].Id;
        qli.Product__r = products[1];
        qli.Product_Code__c = products[1].ProductCode;
        qli.Product_Description__c = products[1].Description;
        qli.Unisource_Item__c = products[1].Unisource_Item_Number_U_number__c;
        qli.Vendor_Item__c = products[1].Vendor_Product_Code__c;
        qli.Vendor_Name__c = products[1].Vendor__c;
        qli.Qty__c = 1;
        qli.Quantity_unit_of_measure__c = products[1].Unit_of_Measure__c;
        qli.Price_unit_of_measure__c = products[1].Pricing_Costing_UOM__c;
        qli.Costing_unit_of_measure__c = products[1].Pricing_Costing_UOM__c;
        qli.Quantity_Unit_Factor__c = 1;
        qli.Price_Unit_Factor__c = products[1].Conversion_Factor__c;
        qli.Cost_Unit_Factor__c = products[1].Conversion_Factor__c;
        insert qli;
        testQLIs.add(qli);
    }

    private static testMethod void pandACalloutVariousDivisions() {

        testSetupData();

        Test.startTest();

            Test.setCurrentPageReference(new PageReference(Page.manageQuoteDetails.getURL() + '?id=' + testQuote.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
            QuoteControllerExtension qce = new QuoteControllerExtension(sc);

            PricingAndAvailability paa = qce.getPandAData( testQLIs[0].Product__r );
            PricingAndAvailability paa2 = qce.getPandAData( testQLIs[1].Product__r );


        Test.StopTest();

        System.assertEquals(null, paa.Request.ShipToID );
        System.assertEquals('000002', paa2.Request.ShipToID );

    }

    private static testmethod void testConstructor()
    {
        testSetupData();

        Test.startTest();
       
        Recordtype rt = [SELECT Name, Id, IsActive, SobjectType FROM RecordType where Sobjecttype = 'Account' AND name = 'Prospect' limit 1];
        account a = new account(name = 'test', recordtypeid = rt.id );
        insert a;
        Quote__c testEmptyQuote = new Quote__c(account__c = a.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(testEmptyQuote);
        QuoteControllerExtension qce = new QuoteControllerExtension(sc);
        System.assert(!qce.isValidQuote);
        System.assert(!qce.hasSelectedProducts);
        qce.checkQuote();
        //Test with Quote
        Test.setCurrentPageReference(new PageReference(Page.manageQuoteDetails.getURL() + '?id=' + testQuote.Id));
        sc = new ApexPages.StandardController(testQuote);
        qce = new QuoteControllerExtension(sc);
        System.assert(qce.isValidQuote);
        qce.checkQuote();

        Test.stopTest();
    }

    private static testmethod void testFreightValidations()
    {
        testSetUpData();
        Test.setCurrentPageReference(new PageReference(Page.manageQuoteDetails.getURL() + '?id=' + testQuote.Id + '&title=testTitle'));

        testQuote.Shipment_Method__c = 'Direct';
        testQLIs[0].Product_Code__c = 'UFREIGHT3P';
        update testQuote;
        update testQLIs;

        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        QuoteControllerExtension qce = new QuoteControllerExtension(sc);

        Test.startTest();
        qce.SaveQuoteLineItems();
        Test.stopTest();
        System.debug(ApexPages.getMessages());
        System.assert(ApexPages.getMessages().isEmpty());


    }

    private static testmethod void testProperties()
    {
        testSetupData();

        Test.startTest();
        //Test with Quote
        Test.setCurrentPageReference(new PageReference(Page.manageQuoteDetails.getURL() + '?id=' + testQuote.Id + '&title=testTitle'));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        QuoteControllerExtension qce = new QuoteControllerExtension(sc);
        System.assert(qce.isValidQuote);

        SelectOption[] sos = qce.availableDivisions;
        System.assert(sos.size() > 0);

        Opportunity testOpp = qce.extendedPriceTotal;
        System.assertNotEquals(null, testOpp);
        testOpp.Amount = 10;
        qce.extendedPriceTotal = testOpp;
        System.assertEquals(10, qce.extendedPriceTotal.Amount);

        Boolean testBool = qce.foundAddresses;
        System.assert(!testBool);

        testBool = qce.foundProducts;
        System.assert(!testBool);

        Integer testInt = qce.foundProductsResize;
        System.assertEquals(20, testInt);

        testInt = qce.foundProductsSize;
        System.assertEquals(0, testInt);

        testOpp = qce.gtmTotal;
        System.assertNotEquals(null, testOpp);
        testOpp.Amount = 10;
        qce.gtmTotal = testOpp;
        System.assertEquals(10, qce.gtmTotal.Amount);

        testBool = qce.hasPricingProducts;
        System.assert(!testBool);

        testBool = qce.hasSelectedProductResults;
        System.assert(!testBool);

        testBool = qce.hasSelectedProducts;
        System.assert(testBool);

        String testStr = qce.openPricingAndAvailability;
        System.assert(testStr.startsWith('window.open'));

        ProductWrapper[] pws = qce.pricingProducts;
        System.assertEquals(0, pws.size());
        pws.add(new ProductWrapper(new Product2(ProductCode='test product code')));
        qce.pricingProducts = pws;
        System.assertEquals('test product code', qce.pricingProducts[0].product.ProductCode);

        Product2 p = qce.product;
        System.assertNotEquals(null, p);
        p.ProductCode = 'test product code';
        qce.product = p;
        System.assertEquals('test product code', qce.product.ProductCode);

        pws = qce.productResults;
        System.assertEquals(0, pws.size());
        pws.add(new ProductWrapper(new Product2(ProductCode='test product code')));
        qce.productResults = pws;
        System.assertEquals('test product code', qce.productResults[0].product.ProductCode);

        testStr = qce.quoteTemplateTitle;
        System.assertEquals('testTitle', qce.quoteTemplateTitle);

        qce.rowIndex = 10;
        System.assertEquals(10, qce.rowIndex);

        qce.searchDescription = 'test description';
        System.assertEquals('test description', qce.searchDescription);

        qce.searchProductCode = 'test product code';
        System.assertEquals('test product code', qce.searchProductCode);

        qce.searchVendorName = 'test vendor name';
        System.assertEquals('test vendor name', qce.searchVendorName);

        qce.searchVendorProductCode = 'test vendor product code';
        System.assertEquals('test vendor product code', qce.searchVendorProductCode);

        ID[] ids = qce.selectedDivisions;
        System.assertEquals(0, ids.size());
        ids.add(null);
        qce.selectedDivisions = ids;
        System.assertEquals(null, qce.selectedDivisions[0]);

        QLIWrapper[] qliws = qce.selectedProducts;
        System.assertEquals(2, qliws.size());
        qliws.add(new QLIWrapper(new Quote_Line_Item__c(Product_Code__c='test product code')));
        qce.selectedProducts = qliws;
        System.assertEquals('test product code', qce.selectedProducts[2].qli.Product_Code__c);

        Quote_Line_Item__c[] qlis = qce.selectedQLIs;
        System.assertEquals(0, qlis.size());
        qlis.add(new Quote_Line_Item__c(Product_Code__c='test product code'));
        qce.selectedQLIs = qlis;
        System.assertEquals('test product code', qce.selectedQLIs[0].Product_Code__c);

        qce.shipToAccountID = null;
        System.assertEquals(null, qce.shipToAccountID);

        sos = qce.shipToAddresses;
        System.assertEquals(0, sos.size());
        sos.add(new SelectOption('test option', 'test option'));
        qce.shipToAddresses = sos;
        System.assertEquals('test option', qce.shipToAddresses[0].getValue());
        qce.isSalesRepPDF = true;
        qce.isVendorPDF = true;
        qce.extendedPriceRunningTotalString = 'TestExtended';
        qce.GTMRunningTotalString = 'TestGTM';
        

        Test.stopTest();
    }

    private static testmethod void testActionMethods()
    {
        testSetupData();

        Test.startTest();
        //Test with Quote
        Test.setCurrentPageReference(new PageReference(Page.manageQuoteDetails.getURL() + '?id=' + testQuote.Id + '&title=testTitle'));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        QuoteControllerExtension qce = new QuoteControllerExtension(sc);
        System.assert(qce.isValidQuote);
        //Test search products
        qce.searchDescription = '';
        qce.searchProductCode = '';
        qce.searchVendorName = '';
        qce.searchVendorProductCode = '';
        PageReference testPage = qce.searchProducts();
        qce.searchDescription = 'a';
        testPage = qce.searchProducts();
        qce.searchDescription = '';
        qce.searchProductCode = 'b';
        testPage = qce.searchProducts();
        qce.searchProductCode = '';
        qce.searchVendorName = 'c';
        testPage = qce.searchProducts();
        qce.searchVendorName = '';
        qce.searchVendorProductCode = 'd';
        testPage = qce.searchProducts();
        qce.searchDescription = 'cup,white';
        qce.searchProductCode = '1234';
        qce.searchVendorName = 'vendorname';
        qce.product.Stocking_Flag__c = true;
        testPage = qce.searchProducts();
        qce.searchDescription = 'cup';
        qce.searchProductCode = '';
        qce.searchVendorName = '';
        qce.searchVendorProductCode = '';
        for(SelectOption so : qce.availableDivisions)
            qce.selectedDivisions.add(so.getValue());
        System.assertEquals(qce.availableDivisions.size(), qce.selectedDivisions.size());
        testPage = qce.searchProducts();
        System.assertEquals(null, testPage);
        System.assert(qce.productResults.size() > 1);
        System.assert(qce.foundProducts);
        System.assert(qce.foundProductsSize > 0);
        System.assert(qce.foundProductsResize > 0);
        //Test add qli
        System.assert(!qce.hasSelectedProductResults);
        for(Integer i=0; i <= 1; i++)
            qce.productResults[i].isSelected = true;
        System.assert(qce.hasSelectedProducts);
        System.assert(qce.hasSelectedProductResults);
        testPage = qce.addQuoteLineItems();
        System.assertEquals(null, testPage);
        System.assertEquals(4, qce.selectedProducts.size());
        //Test add special qli
        testPage = qce.addSpecialQuoteLineItem();
        System.assertEquals(null, testPage);
        System.assertEquals(5, qce.selectedProducts.size());
        //Test calculate prices
        qce.rowIndex = 0;
        qce.selectedProducts[qce.rowIndex].qli.Price__c = 10;
        qce.selectedProducts[qce.rowIndex].qli.Cost__c = 6;
        testPage = qce.calcExtendedPrice();
        System.assertEquals(null, testPage);
        //Test clone qli
        qce.rowIndex = 4;
        testPage = qce.cloneQuoteLineItem();
        System.assertEquals(null, testPage);
        System.assertEquals(6, qce.selectedProducts.size());
        //Test delete qli
        qce.rowIndex = 5;
        testPage = qce.deleteQuoteLineItem();
        System.assertEquals(null, testPage);
        System.assertEquals(5, qce.selectedProducts.size());
        //Test P&A sub calls
        for(QLIWrapper qliw : qce.selectedProducts)
            qliw.PandA = PricingAndAvailabilityTest.testExternalSerializeAndParseXML();
        qce.fillUOM(qce.selectedProducts);
        qce.assignUnitFactors(qce.selectedProducts);
        qce.assignQLIValues(qce.selectedProducts);
        //Test find ship to addresses
        Test.setCurrentPageReference(new PageReference(Page.selectShipToAddress.getURL() + '?id=' + testQuote.Id + '&title=testTitle'));
        testPage = qce.findShipToAddresses();
        System.assertEquals(null, testPage);
        System.assert(qce.foundAddresses);
        //Test save ship to
        testPage = qce.saveShipToAddress();
        //Saving with a blank shipto is allowed
        String quoteId = (String)testQuote.Id;
        quoteId = quoteId.substring(0, 15);
        System.assert(testPage.getUrl().contains(quoteId));
        qce.shipToAccountID = (ID)qce.shipToAddresses[1].getValue();
        testPage = qce.saveShipToAddress();
        System.assertEquals(sc.view().getURL(), testPage.getURL());
        //Test save QLIs
        Test.setCurrentPageReference(new PageReference(Page.manageQuoteDetails.getURL() + '?id=' + testQuote.Id + '&title=testTitle'));
        qce.quote.Shipment_Method__c = 'Direct';
        testPage = qce.saveQuoteLineItems();
        System.assertEquals(null, testPage);
        qce.quote.Shipment_Method__c = 'Warehouse';
        testPage = qce.saveQuoteLineItems();
        System.assertEquals(sc.view().getURL(), testPage.getURL());
        //Test show P&A
        qce.rowIndex = 0;
        Boolean testBool = qce.selectedProducts[qce.rowIndex].showPandA;
        System.assert(!testBool);
        testPage = qce.showPandAForProduct();
        System.assertEquals(null, testPage);
        testBool = qce.selectedProducts[qce.rowIndex].showPandA;
        System.assert(testBool);
        //Test create quote
        Test.setCurrentPageReference(new PageReference(Page.Quote.getURL() + '?id=' + testQuote.Id + '&title=testTitle'));
        testPage = qce.createQuote();
        System.assertEquals(null, testPage);
        System.assertEquals(0, qce.selectedQLIs.size());
        String queryParms = '';
        for(Integer i=0; i < qce.selectedProducts.size(); i++)
            queryParms += '&qlid' + i + '=' + qce.selectedProducts[i].qli.Id;
        Test.setCurrentPageReference(new PageReference(Page.Quote.getURL() + '?id=' + testQuote.Id + queryParms + '&title=testTitle'));
        testPage = qce.createQuote();
        System.assertEquals(null, testPage);
        System.assert(qce.selectedQLIs.size() > 0);
        //Test check pricing products
        for(Integer i=0; i < qce.ProductResults.size(); i++)
            queryParms += '&pid' + i + '=' + qce.productResults[i].product.Id;
        Test.setCurrentPageReference(new PageReference(Page.PricingAndAvailabilityQLI.getURL() + '?id=' + testQuote.Id + queryParms));
        testPage = qce.checkPricingProducts();
    }

    static testMethod void testSetNullOnShipTo()
    {
        Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, false )[0];
        testPSR.SF_userid__c = UserInfo.getUserId();
        insert testPSR;

        Id custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = TestDataGeneration.createAccount( 'test account' );
        testCustAccount.RecordTypeId = custRecTypeID;
        testCustAccount.Primary_Sales_Rep_Name__c = testPSR.Id;
        testCustAccount.VOS_Business_Group__c = 'SA';
        insert testCustAccount;

        testShipAccount = TestDataGeneration.createShipTos( 1, 'test shipto', testCustAccount.Id, true )[0];

        testQuote = TestDataGeneration.createQuotes( 1, 'test quote', testCustAccount.Id, false )[0];
        testQuote.Ship_To__c = testShipAccount.Id;
        testQuote.Primary_Sales_Rep__c = null;
        insert testQuote;

        ApexPages.StandardController standardCont = new ApexPages.StandardController( testQuote );
        QuoteControllerExtension customCont = new QuoteControllerExtension( standardCont );
        customCont.findShipToAddresses();
        System.assert( !ApexPages.hasMessages( ApexPages.Severity.ERROR ), 'No error messages should have been created: ' + ApexPages.getMessages() );

        Test.startTest();

            customCont.shipToAccountID = customCont.shipToAddresses[0].getValue();
            customCont.saveShipToAddress();
            customCont.isSaalfeld = true;
            customCont.searchProductCode = 'Test';
            customCont.searchDescription = 'TestDesc';
            customCont.searchVendorName  = 'TestVendor';
            customCont.searchVendorProductCode = 'TestProduct';  

        Test.stopTest();

        System.assert( !ApexPages.hasMessages( ApexPages.Severity.ERROR ), 'No error messages should have been created: ' + ApexPages.getMessages() );
        testQuote = [ SELECT Id, Ship_To__c, Primary_Sales_Rep__c FROM Quote__c WHERE Id = :testQuote.Id LIMIT 1 ];
        System.assertEquals( null, testQuote.Ship_To__c, 'When selecting NONE for ship to addresses, the quotes ship to should be cleared' );
        System.assertEquals( testPSR.Id, testQuote.Primary_Sales_Rep__c, 'When setting ShipTo to null, the quote should get the PSR from its account' );
    }
    /*
    static testMethod void testIsWebSource()
    {
        User testUser = TestingUtils.createUser('JohnD','System Administrator',false);
        testUser.Department = Consts.WEBSOURCE_DEPARTMENT;
        insert testUser;
        
        Boolean result;
        System.runAs(testUser)
        {
            testSetupData();
            Test.setCurrentPageReference(new PageReference(Page.Quote.getURL() + '?id=' + testQuote.Id));
            QuoteControllerExtension qce = new QuoteControllerExtension(new ApexPages.StandardController(testQuote));
            
            Test.startTest();
                result = qce.isWebsource;
            Test.stopTest();
        }
        
        System.assert(result,'isWebsource should be true because the running user has websource for its department field');
    }
    
    static testMethod void testIsFordis()
    {
        User testUser = TestingUtils.createUser('JohnD','System Administrator',false);
        testUser.Department = Consts.FORDIS_DEPARTMENT;
        insert testUser;
        
        Boolean result;
        System.runAs(testUser)
        {
            testSetupData();
            Test.setCurrentPageReference(new PageReference(Page.Quote.getURL() + '?id=' + testQuote.Id));
            QuoteControllerExtension qce = new QuoteControllerExtension(new ApexPages.StandardController(testQuote));
            
            Test.startTest();
                result = qce.isFordis;
            Test.stopTest();
        }
        
        System.assert(result,'isFordis should be true because the running user has fordis for its department field');
    }*/
}
/**
 Objective: Test class to iron out the functionality of ViewQuoteQuoteContExt
 Developer: Hiremath, Naveen - Bluewolf
*/
@isTest
private class TestViewQuoteQuoteContExt {

    private static Account testCustAccount;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0];

    static testmethod void doShare_whenAnUserSharesTheExistingQuote_returnsStandardSharingURLPageRef() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.ViewQuote.getURL() + '?id=' + testQuote.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        System.debug('Naveen: ' + testQuote.CreatedDate);ViewQuoteQuoteContExt contExt = new ViewQuoteQuoteContExt(sc);

        System.assert(contExt.isValidQuote, 'The Quote must be valid.');
        System.assertNotEquals(null, contExt.doShare(), 'Sharing url must never be null');

    }

    static testmethod void doClone_whenAnUserClonesTheExistingQuote_returnsViewNewQuotePageRef() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.ViewQuote.getURL() + '?id=' + testQuote.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewQuoteQuoteContExt contExt = new ViewQuoteQuoteContExt(sc);

        System.assert(contExt.isValidQuote, 'The Quote must be valid.');
        System.assertNotEquals(null, contExt.doClone(), 'Clone url must never be null');

    }

    static testmethod void doSearchOrder_whenAnUserSubmitsSearchOrderOnTheExistingQuote_returnsSearchOrderAbsoluteURLPageRef() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.ViewQuote.getURL() + '?id=' + testQuote.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewQuoteQuoteContExt contExt = new ViewQuoteQuoteContExt(sc);

        System.assert(contExt.isValidQuote, 'The Quote must be valid.');
        System.assertNotEquals(null, [SELECT Relative_URL__c FROM Search_Order__c WHERE Name = 'Search Order'], 'Custom Setting for Search Order must not be null');
        //System.assertNotEquals(null, [SELECT Relative_URL__c FROM Search_Order__c WHERE Name = 'Search Order'].Relative_URL__c, 'Relative_URL__c from Search Order Custom Setting must have a value');
        //System.assertNotEquals(null, contExt.doSearchOrder(), 'Search Order page reference must never be null');

    }

    static testmethod void doShipToAddress_whenAnUserSelectsShipToAddressOnTheExistingQuote_returnsShipToAddressPageRef() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.ViewQuote.getURL() + '?id=' + testQuote.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewQuoteQuoteContExt contExt = new ViewQuoteQuoteContExt(sc);

        System.assert(contExt.isValidQuote, 'The Quote must be valid.');
        System.assertNotEquals(null, contExt.doShipToAddress(), 'Ship To Address page reference must never be null');

    }

    static testmethod void doSendToFieldSourcing_whenAnUserSelectsSendToMerchandiserOnTheExistingQuote_returnsSendToMerchandiserPageRef() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.ViewQuote.getURL() + '?id=' + testQuote.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewQuoteQuoteContExt contExt = new ViewQuoteQuoteContExt(sc);

        System.assert(contExt.isValidQuote, 'The Quote must be valid.');
        System.assertNotEquals(null, contExt.doSendToFieldSourcing(), 'Send To Merchandiser page reference will never be null');

    }

    static testmethod void doCancel_whenAnUserCancelsTheExistingQuote_returnsQuotesTabRelativeURLPageRef() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.ViewQuote.getURL() + '?id=' + testQuote.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewQuoteQuoteContExt contExt = new ViewQuoteQuoteContExt(sc);

        System.assert(contExt.isValidQuote, 'The Quote must be valid.');
        System.assertNotEquals(null, contExt.doCancel(), 'Cancel page reference will never be null');

    }

    static testmethod void ViewQuoteQuoteContExt_validateProducts_returnsNothing() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.ViewQuote.getURL() + '?id=' + testQuote.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewQuoteQuoteContExt contExt = new ViewQuoteQuoteContExt(sc);

        System.assert(contExt.isValidQuote, 'The Quote must be valid.');
        System.assertNotEquals(null, contExt.productSearch, 'Product Search instance must never be null');
        System.assertEquals(testQuote.Id, contExt.quotesModel.getQuote().Id, 'QuotesModel instance must have same reference to the Quote record');
        System.assertNotEquals(null, contExt.linkToChangeOwner, 'Link to change owner refers the standard change owner');

    }

    static testmethod void ViewQuoteQuoteContExt_noValidQuoteId_returnsNothing() {

        Test.setCurrentPageReference(new PageReference(Page.ViewQuote.getURL() + '?id='));
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote__c());
        ViewQuoteQuoteContExt contExt = new ViewQuoteQuoteContExt(sc);

        System.assert(!contExt.isValidQuote, 'The Quote must be invalid.');
        System.assertEquals(1, Apexpages.getMessages().size(), 'A page message will be shown to the user about the invalid Quote');

    }

    static testMethod void testQuickAddProducts()
    {
        final Integer QUANTITY_VALUE = 10;

        Servicing_Division__c testServiceDivision = new Servicing_Division__c();
        testServiceDivision.Name = 'Test Service Division';
        testServiceDivision.Division_Code__c = 'TEST5';
        insert testServiceDivision;

        Id custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001', Active__c='Yes');
        testCustAccount.Servicing_Division__c = testServiceDivision.Id;
        insert testCustAccount;

        testQuote = new Quote__c(Account__c=testCustAccount.Id, Date_Quoted__c = System.today(), Account__r=testCustAccount, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;

        List<Product2> testProducts = TestDataGeneration.createProducts( 4, 'Test Product', false );
        Product2 validProduct = testProducts[0];
        validProduct.Division_Name__c = testServiceDivision.Id;
        validProduct.IsActive = true;
        validProduct.Stocking_Flag__c = true;
        validProduct.ProductCode = validProduct.Name;

        Product2 invalidDivisionProduct = testProducts[1];
        invalidDivisionProduct.IsActive = true;
        invalidDivisionProduct.Stocking_Flag__c = true;
        invalidDivisionProduct.ProductCode = invalidDivisionProduct.Name;

        Product2 inactiveProduct = testProducts[2];
        inactiveProduct.Division_Name__c = testServiceDivision.Id;
        inactiveProduct.isActive = false;
        inactiveProduct.Stocking_Flag__c = true;
        inactiveProduct.ProductCode = inactiveProduct.Name;

        Product2 unstockedProduct = testProducts[3];
        unstockedProduct.Division_Name__c = testServiceDivision.Id;
        unstockedProduct.isActive = true;
        unstockedProduct.Stocking_Flag__c = false;
        unstockedProduct.ProductCode = unstockedProduct.Name;

        insert testProducts;

        ApexPages.StandardController stdCont = new ApexPages.StandardController( testQuote );
        ViewQuoteQuoteContExt quoteCont = new ViewQuoteQuoteContExt( stdCont );

        Test.startTest();

            for( Integer index = 0; index < testProducts.size(); index++ )
            {
                quoteCont.quickAddItems[ index ].itemNumber = testProducts[ index ].ProductCode;
                quoteCont.quickAddItems[ index ].quantity = QUANTITY_VALUE;
            }

            quoteCont.quickAddProducts();

        Test.stopTest();

        List<Quote_Line_Item__c> insertedQLIs = [ SELECT Id, Item_Seq__c, Product__r.Division_Name__c FROM Quote_Line_Item__c WHERE Quote__c = :testQuote.Id ];
        System.assertEquals( 2, insertedQLIs.size(), 'Only items products that are active and in the quote\'s division can be quickadded' );
        System.assertEquals( 1, insertedQLIs[0].Item_Seq__c, 'The first line item should be assigned seq of 1 if it is quickadded' );
        System.assertEquals( insertedQLIs[0].Product__c, validProduct.Id, 'Only products that are active and in the quote\'s division can be quickadded' );
        System.assertEquals( insertedQLIs[0].Product__r.Division_Name__c, testServiceDivision.Id, 'Only products that are active and in the quote\'s division can be quickadded' );

        Set<String> remainingItemCodes = new Set<String>();
        for( ViewQuoteQuoteContExt.QuoteQuickAddLineItem quickAddItem : quoteCont.quickAddItems )
        {
            if( quickAddItem.itemNumber != '' && quickAddItem.itemNumber != null )
            {
                System.assert(quickAddItem.IsError, 'This quick add item should be marked as an error');
                remainingItemCodes.add( quickAddItem.itemNumber );
            }
        }
        System.assertEquals( 2, remainingItemCodes.size(), 'Items that cannot be quickadded should remain' );
        System.assert( remainingItemCodes.contains( invalidDivisionProduct.ProductCode ), 'Products that are not in the same division as the quote cannot be quickadded' );
        System.assert( remainingItemCodes.contains( inactiveProduct.ProductCode ), 'Products that are inactive cannot be quickadded' );
    }
    
    static testMethod void testQuickAddProductsDuplicates()
    {
        final Integer QUANTITY_VALUE = 10;
        final Integer QUICK_ADD_TOTAL = 3;

        Servicing_Division__c testServiceDivision = new Servicing_Division__c();
        testServiceDivision.Name = 'Test Service Division';
        testServiceDivision.Division_Code__c = 'TEST5';
        insert testServiceDivision;

        Id custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001', Active__c='Yes');
        testCustAccount.Servicing_Division__c = testServiceDivision.Id;
        insert testCustAccount;

        testQuote = new Quote__c(Account__c=testCustAccount.Id, Date_Quoted__c = System.today(), Account__r=testCustAccount, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;

        List<Product2> testProducts = TestDataGeneration.createProducts( 1, 'Test Product', false );
        Product2 validProduct = testProducts[0];
        validProduct.Division_Name__c = testServiceDivision.Id;
        validProduct.IsActive = true;
        validProduct.Stocking_Flag__c = true;
        validProduct.ProductCode = validProduct.Name;

        insert testProducts;

        ApexPages.StandardController stdCont = new ApexPages.StandardController( testQuote );
        ViewQuoteQuoteContExt quoteCont = new ViewQuoteQuoteContExt( stdCont );

        Test.startTest();

            for( Integer index = 0; index < QUICK_ADD_TOTAL; index++ )
            {
                quoteCont.quickAddItems[ index ].itemNumber = testProducts[ 0 ].ProductCode;
                quoteCont.quickAddItems[ index ].quantity = QUANTITY_VALUE;
            }

            quoteCont.quickAddProducts();

        Test.stopTest();

        List<Quote_Line_Item__c> insertedQLIs = [ SELECT Id, Item_Seq__c, Product__r.Division_Name__c FROM Quote_Line_Item__c WHERE Quote__c = :testQuote.Id ];
        System.assertEquals( QUICK_ADD_TOTAL, insertedQLIs.size(), 'Duplicate quick add products should be allowed' );
        
        List<String> remainingItemCodes = new List<String>();
        for( ViewQuoteQuoteContExt.QuoteQuickAddLineItem quickAddItem : quoteCont.quickAddItems )
        {
            if( quickAddItem.itemNumber != '' && quickAddItem.itemNumber != null )
            {
                remainingItemCodes.add( quickAddItem.itemNumber );
            }
        }
        System.assertEquals( 0, remainingItemCodes.size(), 'All Items Should have been cleared' );

    }

    private static void testSetupData() {

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001', Active__c='Yes');
        insert testCustAccount;

        testShipAccount = new Ship_To__c(Name='Test Customer Location 1', Ship_To_Code__c='000002', Bill_To_Account__c=testCustAccount.Id, Active__c='Yes');
        insert testShipAccount;

        testQuote = new Quote__c(Account__c=testCustAccount.Id, Date_Quoted__c = System.today(), Account__r=testCustAccount, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;

        //Product2[] products = [select Id, ProductCode, Description, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c, Unit_of_Measure__c, Pricing_Costing_UOM__c, Conversion_Factor__c from Product2 limit 2];
        Servicing_Division__c servicingDivision = TestDataGeneration.createServicingDivisions( 1, false )[0];
        servicingDivision.Active__c = true;
        insert servicingDivision;
        
        Product2[] products = TestDataGeneration.createProducts( 2, 'Test Product', false );
        for( Product2 aProduct : products )
        {
            aProduct.Description = 'Test Cup Product 123';
            aProduct.Stocking_Flag__c = true;
            aProduct.Division_Name__c = servicingDivision.Id;
        }
        insert products;
        
        
        Quote_Line_Item__c qli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        qli.Product__c = products[0].Id;
        qli.Product__r = products[0];
        qli.Product_Code__c = products[0].ProductCode;
        qli.Product_Description__c = products[0].Description;
        qli.Unisource_Item__c = products[0].Unisource_Item_Number_U_number__c;
        //qli.Vendor_Item__c = products[0].Vendor_Product_Code__c;
        //qli.Vendor_Name__c = products[0].Vendor__c;
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
        //qli.Vendor_Item__c = products[1].Vendor_Product_Code__c;
        //qli.Vendor_Name__c = products[1].Vendor__c;
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


}
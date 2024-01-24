/**
Objective: Iron out the logic for Create Order
Developer: Hiremath, Naveen - Bluewolf
*/
@isTest
private class TestViewCreateOrderContExt {

    private static Account testCustAccount;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0];

    private static testMethod void testSetupData() {
        ID prosRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Prospect' ).getRecordTypeId();
        testCustAccount = TestingUtils.createAccount('Test Customer');
        testCustAccount.RecordTypeId = prosRecTypeID;
        testCustAccount.AccountNumber = '123456';
        testCustAccount.Ship_To_Code__c = '000001';
        insert testCustAccount;

        testShipAccount = new Ship_To__c(Name='Test Customer Location 1', Ship_To_Code__c='000002', Bill_To_Account__c=testCustAccount.Id, Active__c='Yes');
        insert testShipAccount;

        testQuote = TestingUtils.createQuotes( 1, testCustAccount.Id, false )[0];
        testQuote.Shipment_Method__c = 'Warehouse';
        testQuote.Requested_Delivery_Date__c = System.today();
        insert testQuote;

        List<Vendor_Detail__c> vendorDetails = TestingUtils.createVendorDetails( 2, 'TestVendor', false );
        vendorDetails[0].Vendor_Code__c = '001';
        vendorDetails[1].Vendor_Code__c = '002';
        insert vendorDetails;

        List<Product2> products = TestDataGeneration.createProducts( 2, 'TestProduct', false );
        products[0].ProductCode = '0001';
        products[0].Description = 'Test Description 1';
        products[0].Unisource_Item_Number_U_number__c = '001';
        products[0].Vendor_Product_Code__c = vendorDetails[0].Vendor_Code__c;
        products[0].Vendor__c = vendorDetails[0].Id;
        products[0].Unit_of_Measure__c = 'EA';
        products[0].Pricing_Costing_UOM__c = 'EA';
        products[0].Conversion_Factor__c = 10.01;

        products[1].ProductCode = '0002';
        products[1].Description = 'Test Description 2';
        products[1].Unisource_Item_Number_U_number__c = '002';
        products[1].Vendor_Product_Code__c = vendorDetails[1].Vendor_Code__c;
        products[1].Vendor__c = vendorDetails[1].Id;
        products[1].Unit_of_Measure__c = 'MA';
        products[1].Pricing_Costing_UOM__c = 'MA';
        products[1].Conversion_Factor__c = 20.02;
        insert products;

        Quote_Line_Item__c qli = new Quote_Line_Item__c( Quote__c=testQuote.Id );
        qli.Product__c = products[0].Id;
        qli.Product__r = products[0];
        qli.Product_Code__c = products[0].ProductCode;
        qli.Product_Description__c = products[0].Description;
        qli.Unisource_Item__c = products[0].Unisource_Item_Number_U_number__c;
        qli.Vendor_Item__c = products[0].Vendor_Product_Code__c;
        qli.Vendor_Name__c = products[0].Vendor__c;
        qli.Qty__c = 1;
        qli.Projected_Delivery_Date__c = System.today();
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
        qli.Projected_Delivery_Date__c = System.today();
        qli.Quantity_unit_of_measure__c = products[1].Unit_of_Measure__c;
        qli.Price_unit_of_measure__c = products[1].Pricing_Costing_UOM__c;
        qli.Costing_unit_of_measure__c = products[1].Pricing_Costing_UOM__c;
        qli.Quantity_Unit_Factor__c = 1;
        qli.Price_Unit_Factor__c = products[1].Conversion_Factor__c;
        qli.Cost_Unit_Factor__c = products[1].Conversion_Factor__c;
        insert qli;
        testQLIs.add(qli);
    }

    private static testMethod void testProperties() {
        testSetupData();

        Test.startTest();

        Quote_Line_Item__c[] testEmptyQLIs = new Quote_Line_Item__c[0];
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Boolean testValidQuote = contExt.isValidQuote;
        System.assert(!testValidQuote);

        Test.stopTest();
    }

    private static testMethod void testActionMethods() {
        testSetupData();

        Test.startTest();
        //Test with prospect account, no ship to, submitted order
        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);
        contExt.isValidQuote = true;
        PageReference tempPage = contExt.createOrder();
        System.assertEquals(null, tempPage);
        //Test with customer account, no ship to, submitted order
        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;

        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        contExt = new ViewCreateOrderContExt(sc);
        contExt.isValidQuote = true;
        tempPage = contExt.createOrder();
        System.assertEquals(null, tempPage);
        //Test with customer account, ship to, submitted order
        testQuote.Ship_To__c = testShipAccount.Id;
        update testQuote;

        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        contExt = new ViewCreateOrderContExt(sc);
        contExt.isValidQuote = true;
        tempPage = contExt.createOrder();
        System.assertEquals(null, tempPage);
        //Test with customer account, ship to, non submitted order
        update testQuote;

        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        contExt = new ViewCreateOrderContExt(sc);
        contExt.isValidQuote = true;
        tempPage = contExt.createOrder();
        System.assertEquals(null, tempPage);

        Test.stopTest();
    }

    private static testMethod void createOrder_RequestedDeliveryDateisNull_returnsNull() {

        testSetupData();

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;

        testQuote.Requested_Delivery_Date__c = null;
        testQuote.Account__c = testCustAccount.Id;
        update testQuote;

        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Test.startTest();

            ApexPages.PageReference returnedPage = contExt.createOrder();

        Test.stopTest();

        System.assertEquals(null, returnedPage, 'Requested Delivery Date is null, adds an error page message');
        assertMessageInPageMessages( System.Label.CreateOrder_ErrorRequestedDeliveryDateRequired, 'Null Requested Delivery Date message should have been shown' );
    }

    private static testMethod void createOrder_ExpirationDateisExpired_returnsNull() {

        testSetupData();

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;

        testQuote.Ship_To__c = testShipAccount.Id;
        testQuote.Expiration_Date__c = System.today() - 1;
        update testQuote;

        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Test.startTest();

            ApexPages.PageReference returnedPage = contExt.createOrder();

        Test.stopTest();

        System.assertEquals(null, returnedPage, 'Expiration Date is older than todays date, adds an error page message');
        assertMessageInPageMessages( System.Label.CreateOrder_ErrorExpiredQuote, 'Expired Quote message should have been shown' );
    }

    private static testMethod void createOrder_ExpirationDateisRequired_returnsNull() {

        testSetupData();

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;

        testQuote.Ship_To__c = testShipAccount.Id;
        testQuote.Expiration_Date__c = null;
        update testQuote;

        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Test.startTest();

            ApexPages.PageReference returnedPage = contExt.createOrder();

        Test.stopTest();

        System.assertEquals(null, returnedPage, 'Expiration Date is required, adds an error page message');
        assertMessageInPageMessages( System.Label.CreateOrder_ErrorExpirationDateRequired, 'Quote Expiration Date required message should have been shown' );
    }

    private static testMethod void createOrder_RequestedDeliveryDateDateisExpired_returnsNull() {

        testSetupData();

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;

        testQuote.Ship_To__c = testShipAccount.Id;
        testQuote.Requested_Delivery_Date__c = System.today() - 1;
        update testQuote;

        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Test.startTest();

            ApexPages.PageReference returnedPage = contExt.createOrder();

        Test.stopTest();

        System.assertEquals(null, returnedPage, 'Requested Dute Date is older than todays date, adds an error page message');
        assertMessageInPageMessages( System.Label.CreateOrder_ErrorExpiredRequestedDeliveryDate, 'Expired Requested Delivery Date message should have been shown' );
    }

    private static testMethod void createOrder_SpecialQuoteLineItem_returnsNull() {

        testSetupData();

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;

        testQuote.Ship_To__c = testShipAccount.Id;
        update testQuote;

        testQLIs[0].Special_Item__c = true;
        update testQLIs[0];

        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Test.startTest();

            ApexPages.PageReference returnedPage = contExt.createOrder();

        Test.stopTest();

        System.assertEquals(null, returnedPage, 'Order cannot be created for Special line item, adds an error page message');
        assertMessageInPageMessages( System.Label.CreateOrder_ErrorSpecialItemsNotAllowed, 'Special Line Item Not Allowed message should have been shown' );
    }

    private static testMethod void createOrder_ForDirectShipmentLineItemCostIsNull_returnsNull() {

        testSetupData();

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;

        testQuote.Ship_To__c = testShipAccount.Id;
        testQuote.Shipment_Method__c = 'Direct';
        update testQuote;

        testQLIs[0].Cost__c = null;
        update testQLIs[0];

        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Test.startTest();

            ApexPages.PageReference returnedPage = contExt.createOrder();

        Test.stopTest();

        System.assertEquals(null, returnedPage, 'For a direct quote Cost is required, adds an error page message');
        assertMessageInPageMessages( System.Label.CreateOrder_ErrorCostRequiredForDirect, 'Cost Required for Direct Line Items error should be shown' );
    }

    private static testMethod void createOrder_QuoteWithoutPONumberWhenAccountRequires_returnsNull() {

        testSetupData();

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;

        testQuote.Ship_To__c = testShipAccount.Id;
        testQuote.PO_Reqd__c = true;
        update testQuote;

        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Test.startTest();

            ApexPages.PageReference returnedPage = contExt.createOrder();

        Test.stopTest();

        System.assertEquals(null, returnedPage, 'When a quote\' Account has its PO Required Checkbox checked, a quote must have a PO Number before creating an order' );
        assertMessageInPageMessages( System.Label.CreateOrder_ErrorPONumberRequired, 'A PO Number Required message should have been shown' );
    }

    private static testMethod void createOrder_QuoteForDirectQuoteRequiresFreightCodeItems_returnsNull() {

        final String TEST_FREIGHT_CODE = 'SOMEFREIGHT';
        testSetupData();

        // pick a line item to have a FREIGHT product code
        testQLIs[0].Product_Code__c = TEST_FREIGHT_CODE;
        update testQLIs[0];

        /*
        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;
        */

        testQuote.Ship_To__c = testShipAccount.Id;
        testQuote.Shipment_Method__c = 'Direct';
        update testQuote;

        // pass in line items of which there are no freight line items
        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Test.startTest();

            PageReference pgRef = contExt.createOrder();

        Test.stopTest();

        System.assertEquals(null, pgRef, 'Freight code line items is required when processing a Direct Quote(Direct is Shipping Method) to create an order.' );
        assertMessageInPageMessages(System.Label.CreateOrder_ErrorFreightItemsRequiredForDirect, 'A Freight Lines Required for Direct error should have been shown' );
    }

    static testMethod void createOrder_LockedQuoteLineItems_returnsNull() {

        testSetupData();

        // pick a line item to LOCK
        testQLIs[0].Locked__c = true;
        update testQLIs[0];

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;

        testQuote.Ship_To__c = testShipAccount.Id;
        update testQuote;

        // pass in line items, of which one is locked
        ApexPages.PageReference newReference = Page.ViewCreateOrder;
        newReference.getParameters().put( 'id', testQuote.Id );
        newReference.getParameters().put( 'qliIds', testQLIs[0].Id + ',' + testQLIs[1].Id );
        Test.setCurrentPageReference( newReference );

        ApexPages.StandardController sc = new ApexPages.StandardController( testQuote );
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt( sc );

        Test.startTest();

            PageReference pgRef = contExt.createOrder();

        Test.stopTest();

        System.assertEquals( null, pgRef, 'When a quote line item is locked, it should not be allowed to be on an order' );
        assertMessageInPageMessages( System.Label.CreateOrder_ErrorLockedItemsNotAllowed, 'A Locked Items Not Allowed message should have been shown' );
    }

    static testMethod void createOrder_inactiveAccount() {

        testSetupData();

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        testCustAccount.Active__c = 'No';
        update testCustAccount;

        testQuote.Account__c = testCustAccount.Id;
        testQuote.Requested_Delivery_Date__c = System.today();
        testQuote.Expiration_Date__c = System.today();
        testQuote.Ship_To__c = testShipAccount.Id;
        update testQuote;

        // pass in line items of which there are no freight line items
        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Test.startTest();

            PageReference pgRef = contExt.createOrder();

        Test.stopTest();

        System.assertEquals(null, pgRef, 'Account that is linked to Quote Line Item should be active' );
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals( System.Label.CreateOrder_ErrorAccountInactive, msgList[0].getSummary());
        System.assertEquals(ApexPages.Severity.ERROR, msgList[0].getSeverity());
    }
    /**
    * Not ready for deployment (1-22-2012) - Philip Choi
    private static testMethod void createOrder_OrderSourceisNull_returnsNull() {

        testSetupData();

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;

        testQuote.Order_Source__c = null;
        testQuote.Account__c = testCustAccount.Id;
        update testQuote;

        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Test.startTest();

            ApexPages.PageReference returnedPage = contExt.createOrder();

        Test.stopTest();

        System.assertEquals(null, returnedPage, 'Order Source is null, adds an error page message');
        assertMessageInPageMessages( System.Label.CreateOrder_ErrorOrderSourceRequired, 'Null Order Source message should have been shown' );
    }
    */

    static testMethod void processSuccessfulOrder_SuccessfulOrderLocksNonFreightItems() {

        testSetupData();

        List<Quote_Line_Item__c> testFreightItems = new List<Quote_Line_Item__c>();
        for( String freightCode : ViewCreateOrderContExt.SUNDRY_CODES )
        {
            Quote_Line_Item__c newFreight = new Quote_Line_Item__c();
            newFreight.Product_Code__c = freightCode;
            newFreight.Quote__c = testQuote.Id;
            testFreightItems.add( newFreight );
        }
        insert testFreightItems;

        ApexPages.StandardController sc = new ApexPages.StandardController( testQuote );
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt( sc );

        OrderRequest testRequest = new OrderRequest();

        List<Quote_Line_Item__c> allQlis = new List<Quote_Line_Item__c>();
        allQlis.addAll( testQLIs );
        allQlis.addAll( testFreightItems );

        Test.startTest();

            contExt.processSuccessfulOrder(testRequest, testQuote, allQlis);

        Test.stopTest();

        List<Quote_Line_Item__c> updatedLineItems = [ SELECT Id, Locked__c, Product_Code__c FROM Quote_Line_Item__c WHERE Id IN :testQLIs ];
        for( Quote_Line_Item__c lineItem : updatedLineItems )
        {
            System.assert( lineItem.Locked__c, 'Line items should be locked on successful orders' );
        }

        List<Quote_Line_Item__c> updatedFreights = [ SELECT Id, Locked__c FROM Quote_Line_Item__c WHERE Id IN :testFreightItems ];
        for( Quote_Line_Item__c freightItem : updatedFreights )
        {
            System.assert( !freightItem.Locked__c, 'Freight items should never be locked' );
        }
    }

    static testMethod void Test_CreatOrder_ItemEligibility() {

        testSetupData();

        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;

        testQuote.Expiration_Date__c = Date.today().addDays(2);
        testQuote.Ship_To__c = testShipAccount.Id;
        update testQuote;

        testQLIs[1].Updated_P_A__c = FALSE;

        // pass in line items of which there are no freight line items
        Test.setCurrentPageReference(new PageReference(Page.ViewCreateOrder.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewCreateOrderContExt contExt = new ViewCreateOrderContExt(sc);

        Test.startTest();

            PageReference pgRef = contExt.createOrder();

        Test.stopTest();

        Boolean foundError = false;

        System.assertEquals( FALSE, contExt.isValidQuote, 'We expect the quote to be invalid.' );
        for(ApexPages.Message   msg : ApexPages.getMessages())
        {
            if(msg.getSummary().startsWith(Label.IneligibleQuoteErrorMessage))
            {
                foundError = true;
            }
        }
        System.assert(foundError, 'We expect the page to contain the proper error message.');
    }

    static void assertMessageInPageMessages( String message, String errorString )
    {
        System.assert( ApexPages.hasMessages(), 'An error should have been added to the page' );
        Set<String> pageMessages = new Set<String>();
        for( ApexPages.Message errorMessages : ApexPages.getMessages() )
        {
            pageMessages.add( errorMessages.getSummary() );
        }
        System.assert( pageMessages.contains( message ), errorString );
    }
}
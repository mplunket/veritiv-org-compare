/**
 Objective: Test class to validate the functionality for QuoteLineItemsCont
 Developer: Hiremath, Naveen - Bluewolf
*/
@isTest
private class TestQuoteLineItemsCont {

    
    private static Account testCustAccount;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Product2[] products;
    private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0];

    private static void populateProducts() {

        //products = [select Id, ProductCode, Description, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c, Unit_of_Measure__c, Pricing_Costing_UOM__c, Conversion_Factor__c from Product2 limit 2];
        Servicing_Division__c servicingDivision = TestDataGeneration.createServicingDivisions( 1, false )[0];
        servicingDivision.Active__c = true;
        insert servicingDivision;
        
        products = TestDataGeneration.createProducts( 2, 'Test Product', false );
        for( Product2 aProduct : products )
        {
            aProduct.Description = 'Test Cup Product 123';
            aProduct.Stocking_Flag__c = true;
            aProduct.Division_Name__c = servicingDivision.Id;
        }
        insert products;
    }

    private static void testSetupData() {
        ID prosRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Prospect'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=prosRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001');
        insert testCustAccount;

        testShipAccount = new Ship_To__c(Name='Test Customer Location 1', Ship_To_Code__c='000002', Bill_To_Account__c=testCustAccount.Id, Active__c='Yes');
        insert testShipAccount;

        testQuote = new Quote__c(Account__c=testCustAccount.Id, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;

        populateProducts();

        Quote_Line_Item__c qli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        qli.Product__c = products[0].Id;
        qli.Product__r = products[0];
        qli.Product_Code__c = products[0].ProductCode;
        qli.Product_Description__c = products[0].Description;
        qli.Unisource_Item__c = products[0].Unisource_Item_Number_U_number__c;
        qli.Vendor_Item__c = products[0].Vendor_Product_Code__c;
        //qli.Vendor_Name__c = products[0].Vendor__c;
        qli.Qty__c = 1;
        qli.Quantity_unit_of_measure__c = products[0].Unit_of_Measure__c;
        qli.Price_unit_of_measure__c = products[0].Pricing_Costing_UOM__c;
        qli.Costing_unit_of_measure__c = products[0].Pricing_Costing_UOM__c;
        qli.Quantity_Unit_Factor__c = 1;
        qli.Price_Unit_Factor__c = products[0].Conversion_Factor__c;
        qli.Cost_Unit_Factor__c = products[0].Conversion_Factor__c;
        qli.Projected_Delivery_Date__c = System.today();
        insert qli;
        testQLIs.add(qli);

        qli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        qli.Product__c = products[1].Id;
        qli.Product__r = products[1];
        qli.Product_Code__c = products[1].ProductCode;
        qli.Product_Description__c = products[1].Description;
        qli.Unisource_Item__c = products[1].Unisource_Item_Number_U_number__c;
        qli.Vendor_Item__c = products[1].Vendor_Product_Code__c;
        //qli.Vendor_Name__c = products[1].Vendor__c;
        qli.Qty__c = 1;
        qli.Quantity_unit_of_measure__c = products[1].Unit_of_Measure__c;
        qli.Price_unit_of_measure__c = products[1].Pricing_Costing_UOM__c;
        qli.Costing_unit_of_measure__c = products[1].Pricing_Costing_UOM__c;
        qli.Quantity_Unit_Factor__c = 1;
        qli.Price_Unit_Factor__c = products[1].Conversion_Factor__c;
        qli.Cost_Unit_Factor__c = products[1].Conversion_Factor__c;
        qli.Projected_Delivery_Date__c = System.today();
        insert qli;
        testQLIs.add(qli);
    }
    /*
    private static testMethod void doCreate_AddASearchedProductToTheQuote_returnsNothing() {

        Boolean NO_CLONE = false;

        testSetupData();
        String singleProductSelected = simulateSingleProductSelection(NO_CLONE);

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItemsCreate.getURL() + '?results=' + singleProductSelected));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

        cont.doCreate();
        System.assertNotEquals(null, cont.json, 'A JSON string response must be generated');

        JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(cont.json) );
        System.assertEquals(true, Boolean.valueOf(jsonObject.get('success')), 'Only a single QLI must be created and the success will be true');
        System.assertEquals(Consts.EMPTY_STRING, String.valueOf(jsonObject.get('message')), 'A single QLI must be created, the message will be empty');
        System.assertEquals(1, Integer.valueOf(jsonObject.getValue('results').values.size()), 'Results must have a single record');

    }

    private static testMethod void doCreate_CloneAnExistingQLI_returnsNothing() {

        Boolean DO_CLONE = true;

        testSetupData();
        String singleProductSelected = simulateSingleProductSelection(DO_CLONE);

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItemsCreate.getURL() + '?results=' + singleProductSelected));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

        cont.doCreate();
        System.assertNotEquals(null, cont.json, 'A JSON string response must be generated');

        JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(cont.json) );
        System.assertEquals(true, Boolean.valueOf(jsonObject.get('success')), 'A single QLI must be created and the success will be true');
        System.assertEquals(Consts.EMPTY_STRING, String.valueOf(jsonObject.get('message')), 'A single QLI must be created, the message will be empty');
        System.assertEquals(1, Integer.valueOf(jsonObject.getValue('results').values.size()), 'Results must have a single record');

    }

    private static testMethod void doUpdate_ASingleQLI_returnsNothing() {

        Boolean ALWAYS_A_SINGLE_RECORD_WILL_BE_UPDATED_AT_A_GIVEN_TIME = true;

        testSetupData();
        String singleUpdateRecord = simulateSingleProductSelection(ALWAYS_A_SINGLE_RECORD_WILL_BE_UPDATED_AT_A_GIVEN_TIME);

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItemsUpdate.getURL() + '?results=' + singleUpdateRecord));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

        cont.doUpdate();
        System.assertNotEquals(null, cont.json, 'A JSON string response must be generated');

        JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(cont.json) );

        System.assertEquals(1, Integer.valueOf(jsonObject.get('total')), 'A single QLI must be updated');
        System.assertEquals(true, Boolean.valueOf(jsonObject.get('success')), 'Always a single QLI will be updated and the success will be true');
        System.assertEquals(Consts.EMPTY_STRING, String.valueOf(jsonObject.get('message')), 'Always a single QLI will be updated, the message will be empty');
        System.assertEquals(1, Integer.valueOf(jsonObject.getValue('results').values.size()), 'Results must have a single record');

    }
    */
    private static testMethod void testQLICalculationsStandardQTYUOM() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItems.getURL() + '?quoteId=' + testQuote.Id));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

       //Create a qli with some test values
        Quote_Line_Item__c testQli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        testQli.Qty__c = 1;
        testQli.Quantity_Unit_Factor__c = 1;
        testQli.Price__c = 1.00;
        testQli.Price_Unit_Factor__c = 1;
        testQli.Cost__c = 1.00;
        testQli.Cost_Unit_Factor__c = 1;

       QuoteLineItemModel qliModel = new QuoteLineItemModel( new QuotesModel( new Quote__c (Id=testQuote.Id)), testQli );

       Test.startTest();

           cont.calcExtendedPrice( qliModel );

       Test.stopTest();

       System.assertEquals( 1, testQli.Extended_Price__c );
       System.assertEquals( 1, testQli.Extended_Cost__c );
    }

    private static testMethod void testQLICalculationsNegativeQTYandNegativePriceUOM() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItems.getURL() + '?quoteId=' + testQuote.Id));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

       //Create a qli with some test values
        Quote_Line_Item__c testQli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        testQli.Qty__c = 100;
        testQli.Quantity_Unit_Factor__c = 1;
        testQli.Price__c = 1.00;
        testQli.Price_Unit_Factor__c = -500;
        testQli.Cost__c = 1.00;
        testQli.Cost_Unit_Factor__c = 1;

       //Create a qli with some test values
        Quote_Line_Item__c testQli2 = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        testQli2.Qty__c = 20;
        testQli2.Quantity_Unit_Factor__c = -500;
        testQli2.Price__c = 1.00;
        testQli2.Price_Unit_Factor__c = 1;
        testQli2.Cost__c = 1.00;
        testQli2.Cost_Unit_Factor__c = 1;

        QuoteLineItemModel qliModel = new QuoteLineItemModel( new QuotesModel( new Quote__c (Id=testQuote.Id)), testQli );
        QuoteLineItemModel qliModel2 = new QuoteLineItemModel( new QuotesModel( new Quote__c (Id=testQuote.Id)), testQli2 );

        Test.startTest();

           cont.calcExtendedPrice( qliModel );
           cont.calcExtendedPrice( qliModel2 );

        Test.stopTest();

        System.assertEquals( 50000, testQli.Extended_Price__c );
        System.assertEquals( 100, testQli.Extended_Cost__c );

        System.assertEquals( 0.04, testQli2.Extended_Price__c );
        System.assertEquals( 0.04, testQli2.Extended_Cost__c );
    }

    private static testMethod void testIsUpdateableQuote() {

        testSetupData();
        Quote__c testQuote2 = testQuote.clone(false, false, false, false);
        testQuote2.Shipment_Method__c = null;

        Test.startTest();
            Boolean testQuoteIsUpdateable = QuoteLineItemsCont.isUpdateableQuote(testQuote);
            Boolean testQuote2IsUpdateable = QuoteLineItemsCont.isUpdateableQuote(testQuote2);
        Test.stopTest();

        System.assert(testQuoteIsUpdateable, 'We expect the Quote with a Shipment Method to be updateable');
        System.assert(!testQuote2IsUpdateable, 'We expect the Quote without a Shipment Method to not be updateable');
    }

    private static testMethod void testQLICalculationsPositiveQTYandPositivePriceUOM() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItems.getURL() + '?quoteId=' + testQuote.Id));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

       //Create a qli with some test values
        Quote_Line_Item__c testQli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        testQli.Qty__c = 100;
        testQli.Quantity_Unit_Factor__c = 1;
        testQli.Price__c = 1.00;
        testQli.Price_Unit_Factor__c = 2;
        testQli.Cost__c = 1.00;
        testQli.Cost_Unit_Factor__c = 1;

       //Create a qli with some test values
        Quote_Line_Item__c testQli2 = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        testQli2.Qty__c = 20;
        testQli2.Quantity_Unit_Factor__c = 2;
        testQli2.Price__c = 1.00;
        testQli2.Price_Unit_Factor__c = 1;
        testQli2.Cost__c = 1.00;
        testQli2.Cost_Unit_Factor__c = 1;

        QuoteLineItemModel qliModel = new QuoteLineItemModel( new QuotesModel( new Quote__c (Id=testQuote.Id)), testQli );
        QuoteLineItemModel qliModel2 = new QuoteLineItemModel( new QuotesModel( new Quote__c (Id=testQuote.Id)), testQli2 );

        Test.startTest();

            cont.calcExtendedPrice( qliModel );
            cont.calcExtendedPrice( qliModel2 );

        Test.stopTest();

        System.assertEquals( 50, testQli.Extended_Price__c );
        System.assertEquals( 100, testQli.Extended_Cost__c );

        System.assertEquals( 40, testQli2.Extended_Price__c );
        System.assertEquals( 40, testQli2.Extended_Cost__c );
    }

    private static testMethod void testQLICalculationsPLPositiveQTYandPositivePriceUOM() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItems.getURL() + '?quoteId=' + testQuote.Id));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

       //Create a qli with some test values
        Quote_Line_Item__c testQli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        testQli.Qty__c = 100;
        testQli.Quantity_Unit_Factor__c = 1;
        testQli.Price__c = 1.00;
        testQli.Price_Unit_Factor__c = 50;
        testQli.Cost__c = 1.00;
        testQli.Cost_Unit_Factor__c = 1;

       //Create a qli with some test values
        Quote_Line_Item__c testQli2 = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        testQli2.Qty__c = 20;
        testQli2.Quantity_Unit_Factor__c = 50;
        testQli2.Price__c = 1.00;
        testQli2.Price_Unit_Factor__c = 1;
        testQli2.Cost__c = 1.00;
        testQli2.Cost_Unit_Factor__c = 1;

        QuoteLineItemModel qliModel = new QuoteLineItemModel( new QuotesModel( new Quote__c (Id=testQuote.Id)), testQli );
        QuoteLineItemModel qliModel2 = new QuoteLineItemModel( new QuotesModel( new Quote__c (Id=testQuote.Id)), testQli2 );

        Test.startTest();

            cont.calcExtendedPrice( qliModel );
            cont.calcExtendedPrice( qliModel2 );

        Test.stopTest();

        System.assertEquals( 2, testQli.Extended_Price__c );
        System.assertEquals( 100, testQli.Extended_Cost__c );

        System.assertEquals( 1000, testQli2.Extended_Price__c );
        System.assertEquals( 1000, testQli2.Extended_Cost__c );
    }

    private static testMethod void doRead_AllQLIOnAQuote_returnsNothing() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItems.getURL() + '?quoteId=' + testQuote.Id));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

        cont.doRead();
        System.assertNotEquals(null, cont.json, 'A JSON string response must be generated');

        JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(cont.json) );
        System.assertEquals(true, Boolean.valueOf(jsonObject.get('success')), '2 QLIs must be fetched and the success will be true');
        System.assertEquals(Consts.EMPTY_STRING, String.valueOf(jsonObject.get('message')), '2 QLIs must be fetched and the message will be empty');
        System.assertEquals(2, Integer.valueOf(jsonObject.get('total')), '2 QLIs must be present in JSON response');
        System.assertEquals(2, Integer.valueOf(jsonObject.getValue('results').values.size()), 'Results must have a two records');
    }

    private static testMethod void doReload_AllQLIOnAQuote_returnsNothing() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItemsReload.getURL() + '?quoteId=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id + '&itemSeq=1,2'));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

        cont.doReload();
        System.assertNotEquals(null, cont.json, 'A JSON string response must be generated');

        JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(cont.json) );
        System.assertEquals(true, Boolean.valueOf(jsonObject.get('success')), '2 QLIs must be reloaded and the success will be true');
        System.assertEquals(Consts.EMPTY_STRING, String.valueOf(jsonObject.get('message')), '2 QLIs must be reloaded, the message will be empty');
        System.assertEquals(2, Integer.valueOf(jsonObject.get('total')), '2 QLIs must be present in JSON response');
        System.assertEquals(2, Integer.valueOf(jsonObject.getValue('results').values.size()), 'Results must have a two records');
    }
    
    private static testMethod void doDelete_ASingleQLI_returnsNothing() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItemsDelete.getURL() + '?results=' + testQLIs[0].Id));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

        cont.doDelete();
        System.assertNotEquals(null, cont.json, 'A JSON string response must be generated');

        JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(cont.json) );
        System.assertEquals(1, Integer.valueOf(jsonObject.get('total')), 'A single QLI must be deleted');
        System.assertEquals(true, Boolean.valueOf(jsonObject.get('success')), 'A single QLI must be deleted and the success will be true');
        System.assertEquals(Consts.EMPTY_STRING, String.valueOf(jsonObject.get('message')), 'A single QLI must be deleted, the message will be empty');

    }

    private static testMethod void doCalc_OnMultipleQLI_returnsNothing() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItemsCalc.getURL() + '?quoteId=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id + '&qliCloned=1,2'));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

        cont.doCalc();
        System.assertNotEquals(null, cont.json, 'A JSON string response must be generated');

        JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(cont.json) );
        System.assertEquals(2, Integer.valueOf(jsonObject.get('total')), 'Two records must be calculated');
        System.assertEquals(true, Boolean.valueOf(jsonObject.get('success')), 'Calc Operation must be a success');
        System.assertEquals(2, Integer.valueOf(jsonObject.getValue('results').values.size()), 'Results must have a 2 records');

    }
    
    /*
    This test is not a comprehensive unit test of the assignqlivalues function. We will only test for the following:
    
    1) 11/5 - Map ItemPriceCode to Contract_Price_Cd__c
    2) 9/25 - Ensuring that the mappings of CustomerItemNumber to Cust_Item_Code__c are successful when the values in the P&A call are not empty
    3) 11/18 - Removed testing of Copr_Acct__c value
    */
    private static testMethod void testAssignQLIValues()
    {
        testSetupData();
        
        final String SAMPLE_CODE = 'code'; 
        final String SAMPLE_IS_NATIONAL_ACCOUNTS_PRICE = 'Y';
        final String SAMPLE_CUSTOMER_ITEM_NUMBER = '10036509';
        
        QuoteLineItemModel testQLIModel = new QuoteLineItemModel(new QuotesModel(testQuote),QuoteLineItemServices.getQuoteLineItems(testQuote.ID)[0]); 
        
        PricingAndAvailability.ItemDetailsClass itemDetails = new PricingAndAvailability.ItemDetailsClass();
        itemDetails.CustomerItemNumber = SAMPLE_CUSTOMER_ITEM_NUMBER; 
        itemDetails.ItemPriceCode=SAMPLE_CODE;
        
        testQLIModel.getPAndA().Response.ItemDetails.add(itemDetails);
        
        Test.startTest();
            QuoteLineItemsCont testController = new QuoteLineItemsCont();
            testController.assignQLIValues(testQLIModel, testQuote);
        Test.stopTest();
        
        System.assertEquals(SAMPLE_CODE,testQLIModel.getQuoteLineItem().Contract_Price_Cd__c,'We expect to map the ItemPriceCode from the P&A call to the Contract_Price_Cd__c');
        System.assertEquals(SAMPLE_CUSTOMER_ITEM_NUMBER,testQLIModel.getQuoteLineItem().Cust_Item_Code__c,'We expect to map the CustomerItemNumber from the P&A call to the Cust_Item_Code__c');
    }

    private static testMethod void testAssignQLIValues_WhenShipmentMethodDirect()
    {
        testSetupData();
        testQuote.Shipment_Method__c = Consts.SHIP_METHOD_DIRECT;

        QuoteLineItemModel testQLIModel = new QuoteLineItemModel(new QuotesModel(testQuote),QuoteLineItemServices.getQuoteLineItems(testQuote.ID)[0]); 
        
        PricingAndAvailability.ItemDetailsClass itemDetails = new PricingAndAvailability.ItemDetailsClass();
        itemDetails.ItemCostStandard = '24.40';
        itemDetails.ItemPricePerUOM = '24.14';

        testQLIModel.getPAndA().Response.ItemDetails.add(itemDetails);        

        Test.startTest();
            QuoteLineItemsCont testController = new QuoteLineItemsCont();
            testController.assignQLIValues(testQLIModel, testQuote);
        Test.stopTest();
        //Sujitha Damidi: commented on 1/11/2019 for Backlog#00683
        // Objective:Direct shipment method not to default to zero and to pull Warehouse pricing 
        //System.assertEquals(0, testQLIModel.getQuoteLineItem().Cost__c , 'We expect the Cost to be set to 0 when the Shipment Method is Direct');
       // System.assertEquals(0, testQLIModel.getQuoteLineItem().Price__c , 'We expect the Price to be set to 0 when the Shipment Method is Direct');
       // System.assertEquals(0, testQLIModel.getQuoteLineItem().Start_Price__c , 'We expect the Start Price to be set to 0 when the Shipment Method is Direct');
    } 
    
    private static testMethod void testAssignQLIValues_WhenValuesEmptyFromPACALL()
    {
        testSetupData();
        
        QuoteLineItemModel testQLIModel = new QuoteLineItemModel(new QuotesModel(testQuote),QuoteLineItemServices.getQuoteLineItems(testQuote.ID)[0]); 
        
        PricingAndAvailability.ItemDetailsClass itemDetails = new PricingAndAvailability.ItemDetailsClass();
        itemDetails.CustomerItemNumber = QuoteLineItemsCont.EMPTY_NOTE;
        itemDetails.ItemPriceCode = QuoteLineItemsCont.EMPTY_NOTE;
        
        testQLIModel.getPAndA().Response.ItemDetails.add(itemDetails);
        
        Test.startTest();
            QuoteLineItemsCont testController = new QuoteLineItemsCont();
            testController.assignQLIValues(testQLIModel, testQuote);
        Test.stopTest();
        
        System.assertEquals(null, testQLIModel.getQuoteLineItem().Contract_Price_Cd__c, 'We do not expect to directly map ItemPriceCode from the P&A call to the Contract_Price_Cd__c field when the value is tagged as empty. Instead we will map a null value.');
        System.assertEquals(null,testQLIModel.getQuoteLineItem().Cust_Item_Code__c,'We do not expect to directly map CustomerItemNumber from the P&A call to the Cust_Item_Code__c field when the value is tagged as empty. Instead we will map a null value.');    
    } 
        
    
    private static testMethod void testReturnNullIfEmptyLikeString_PositiveTest()
    {
        Test.startTest(); 
            String result = QuoteLineItemsCont.returnNullIfEmptyLikeString(QuoteLineItemsCont.EMPTY_NOTE);
        Test.stopTest();
        
        System.assertEquals(null,result,'When the specified string matches the string the P&A call returns when the field value is empty, we do not want to store that string. Instead we want to store a null value');
    }
    
    private static testMethod void testReturnNullIfEmptyLikeString_NegativeTest()
    {
        final String sampleString = 'TEST';
        
        Test.startTest();
            String result = QuoteLineItemsCont.returnNullIfEmptyLikeString(sampleString);
        Test.stopTest();
        
        System.assertEquals(sampleString,result,'When the specified string does not match the string the P&A call returns when the field value is empty, we want to store that string.');
    } 

    private static testMethod void doUpdatePA_OnMultipleQLI_returnsNothing() {

        testSetupData();

        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItemsUpdatePA.getURL() + '?quoteId=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id + '&itemSeq=1,2'));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

        cont.doUpdatePA();
        System.assert(String.isNotBlank(cont.errorMessage) && 
                      cont.errorMessage.contains(
                            QuoteLineItemsCont.ELIGIBILITY_ERROR.substring(3,
                                                                           QuoteLineItemsCont.ELIGIBILITY_ERROR.length())
                            ),
                      'We expect an Eligibility Error message: ' + cont.errorMessage
                      );
        System.assertNotEquals(null, cont.json, 'A JSON string response must be generated');

        JSONObject jsonObject = new JSONObject( new JSONObject.JSONTokener(cont.json) );
        System.assertEquals(2, Integer.valueOf(jsonObject.get('total')), 'Two records must be calculated');
        System.assertEquals(true, Boolean.valueOf(jsonObject.get('success')), 'Calc Operation must be a success');
        System.assertEquals(2, Integer.valueOf(jsonObject.getValue('results').values.size()), 'Results must have a 2 records');

    }

    private static testMethod void doQtyUOM_AlwaysOnASingleQLI_returnsNothing() {

        testSetupData();

        //'%26' url encoded code for '&'
        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItemsQtyUOM.getURL() + '?query=' + testQuote.Id + '%26' + testQLIs[0].Id));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

        cont.doQtyUOM();
        System.assertNotEquals(Consts.EMPTY_STRING, cont.json, 'A JSON string array must be generated');

    }

    private static testMethod void doPriceUOM_AlwaysOnASingleQLI_returnsNothing() {

        testSetupData();

        //'%26' url encoded code for '&'
        Test.setCurrentPageReference(new PageReference(Page.QuoteLineItemsPriceUOM.getURL() + '?query=' + testQuote.Id + '%26' + testQLIs[0].Id));
        QuoteLineItemsCont cont = new QuoteLineItemsCont();

        cont.doPriceUOM();
        System.assertNotEquals(Consts.EMPTY_STRING, cont.json, 'A JSON string array must be generated');

    }

    private static testMethod void testSpecialCharacters_SuchAsQuote()
    {
        testSetupData();
        
        testQLIs[0].Type_Of_Quote__c = 'test with quote "';
        
        update testQLIs[0];
        
        QuoteLineItemsCont cont = new QuoteLineItemsCont();
        
        String generatedJson = cont.generateJSONForLineItem( testQLIs[0], testQuote.Id, false );
    
        System.assert( generatedJson.contains('\"')); 
    }
    
    private static testMethod void testSpecialCharacters_SuchAsLineBreak()
    {
        testSetupData();
        
        testQLIs[0].Product_Code__c = 'test \r with \n quote "';
        
        update testQLIs[0];
        
        QuoteLineItemsCont cont = new QuoteLineItemsCont();
        
        String generatedJson = cont.generateJSONForLineItem( testQLIs[0], testQuote.Id, false );
    
        System.assert( generatedJson.contains('test   with   quote')); 
    }

    private static String simulateSingleProductSelection(Boolean isCloned_isUpdate) {

        String jsonObject = '{';
        jsonObject += '\"quoteId\":\"' + testQuote.Id + '\",';
        jsonObject += '\"itemSeq\":\"' + '1' + '\",';
        jsonObject += '\"qliSpecialItem\":' + false + ',';
        jsonObject += '\"qliSpecialProduct\":' + false + ',';
        jsonObject += '\"qliQty\":\"' + '1' + '\",';
        jsonObject += '\"qliProdId\":\"' + products[0].Id + '\",';
        jsonObject += '\"qliProdCode\":\"' + products[0].ProductCode + '\",';
        jsonObject += '\"qliProdDesc\":\"' + products[0].Description + '\",';
        jsonObject += '\"qliUOM\":\"' + products[0].Unit_of_Measure__c + '\",';
        jsonObject += '\"qliPrice\":\"' + '0' + '\",';
        jsonObject += '\"qliPriceUOM\":\"' + products[0].Pricing_Costing_UOM__c + '\",';
        jsonObject += '\"qliPriceCode\":\"' + 'null' + '\",';
        jsonObject += '\"qliExtendedPrice\":\"' + '0' + '\",';
        jsonObject += '\"qliExtendedCost\":\"' + '0' + '\",';
        jsonObject += '\"qliGTMPercent\":\"' + '0' + '\",';
        jsonObject += '\"qliVendor\":\"' + products[0].Vendor__c + '\",';
        jsonObject += '\"qliComments\":\"' + 'null' + '\",';
        jsonObject += '\"qliBid\":\"' + 'null' + '\",';
        jsonObject += '\"qliMinMfgQty\":\"' + 'null' + '\",';
        jsonObject += '\"qliCost\":\"' + '0' + '\",';
        jsonObject += '\"qliProjDel\":\"' + 'null' + '\",';
        jsonObject += '\"qliVendorItem\":\"' + products[0].Vendor_Product_Code__c + '\",';
        jsonObject += '\"qliMfgTol\":\"' + 'null' + '\",';
        jsonObject += '\"qliLDC\":\"' + 'null' + '\",';
        jsonObject += '\"qliGTMDollar\":\"' + '0' + '\",';
        jsonObject += '\"qliVendorContact\":\"' + 'null' + '\",';
        jsonObject += '\"qliUnisourceItem\":\"' + products[0].Unisource_Item_Number_U_number__c + '\",';
        jsonObject += '\"qliPriceUnitFactor\":\"' + products[0].Conversion_Factor__c + '\",';
        jsonObject += '\"qliCostUnitFactor\":\"' + products[0].Conversion_Factor__c + '\",';
        if(isCloned_isUpdate)
            jsonObject += '\"id\":\"' + testQLIs[0].Id + '\",';
        jsonObject += '\"qliCloned\":' + isCloned_isUpdate;
        jsonObject += '}';

        return jsonObject;

    }
    
    /*
    This test is not a comprehensive unit test of the generateJSONForLineItem function. We will only test for the following:
        1) Whether the ID field, and the Quote__c field are captured in the resulting JSON (existing functionality as of 10/1/2013)
        2) Whether the Future Dev Cost field is captured in the resulting JSON (new functionality as of 10/1/2013)
    */
    private static testMethod void testGenerateJSONForLineItem()
    {
        final Decimal sampleDevCost = 3.1;
        
        testSetupData();
        testQLIs[0].Future_Dev_Cost__c = sampleDevCost;
        
        Test.startTest();
            QuoteLineItemsCont testController = new QuoteLineItemsCont();   
            String resultingJSON = testController.generateJSONForLineItem(testQLIs[0], testQLIs[0].Quote__c, false).removeEnd(',');
        Test.stopTest();
        JSONParser parser = JSON.createParser(resultingJSON);
        Boolean idEncountered = false;
        Boolean quoteIDEncountered = false;
        Boolean qliFutureDevCostEncountered = false;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'id') {
                   System.assertEquals(testQLIs[0].Id,parser.getText(),'We expect to get store the right qli ID in the JSON');
                   idEncountered = true;
                } else if(fieldName == 'quoteID'){
                    System.assertEquals(testQLIs[0].Quote__c,parser.getText(),'We expect to get store the right quote ID in the JSON');
                    quoteIDEncountered = true;
                }
                else if(fieldName == 'qliFutDevCost'){
                    System.assertEquals(sampleDevCost,Decimal.valueOf(parser.getText()),'We expect to get store the right dev cost in the JSON');
                    qliFutureDevCostEncountered = true;
                }
            }
        }
        
        System.assert(idEncountered,'We expect to store the qli ID in the JSON');
        System.assert(quoteIDEncountered,'We expect to store the quote ID in the JSON');
        System.assert(qliFutureDevCostEncountered,'We expect to store the qli future dev ID in the JSON');
    }


    private static testMethod void testcheckEligibility_True()
    {
        testSetupData();
        Boolean expectedValue = true;
        QuoteLineItemModel testQLIModel = new QuoteLineItemModel(new QuotesModel(testQuote),QuoteLineItemServices.getQuoteLineItems(testQuote.ID)[0]); 
        
        PricingAndAvailability.ItemEligibilityClass itemEligibility = new PricingAndAvailability.ItemEligibilityClass();
        itemEligibility.EligibilityFlag = 'Y';
        itemEligibility.ExceptionFlag = 'N';
        
        testQLIModel.getPAndA().Response.ItemEligibility.add(itemEligibility);
        
        Test.startTest();
            QuoteLineItemsCont testController = new QuoteLineItemsCont();
            Boolean returnedValue = testController.checkEligibility(testQLIModel);
        Test.stopTest();
        
        System.assertEquals(expectedValue, returnedValue, 'We expect the correct value to be returned');
        System.assertEquals(expectedValue, testQLIModel.getQuoteLineItem().Updated_P_A__c, 'We expect the Updated P&A field to match the expected value.');
    }

    private static testMethod void testcheckEligibility_False()
    {
        testSetupData();
        Boolean expectedValue = false;
        QuoteLineItemModel testQLIModel = new QuoteLineItemModel(new QuotesModel(testQuote),QuoteLineItemServices.getQuoteLineItems(testQuote.ID)[0]); 
        
        PricingAndAvailability.ItemEligibilityClass itemEligibility = new PricingAndAvailability.ItemEligibilityClass();
        itemEligibility.EligibilityFlag = 'N';
        itemEligibility.ExceptionFlag = 'N';
        
        testQLIModel.getPAndA().Response.ItemEligibility.add(itemEligibility);
        
        Test.startTest();
            QuoteLineItemsCont testController = new QuoteLineItemsCont();
            Boolean returnedValue = testController.checkEligibility(testQLIModel);
        Test.stopTest();
        
        System.assertEquals(expectedValue, returnedValue, 'We expect the correct value to be returned');
        System.assertEquals(expectedValue, testQLIModel.getQuoteLineItem().Updated_P_A__c, 'We expect the Updated P&A field to match the expected value.');
    }


}
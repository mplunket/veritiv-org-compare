/**
 Objective: Test class to iron out the functionality of ViewAdditionalDetailsContExt
 Developer: Hiremath, Naveen - Bluewolf     
*/
@isTest
private class TestViewAdditionalDetailsQuoteContExt {

    private static Account testCustAccount;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0];
    
    private static testMethod void ViewAdditionalDetailsQuoteContExt_whenNoQuoteIdAndQLIIdIsSent_returnsNothing() {
        
        testSetupData();
        
        Test.setCurrentPageReference(new PageReference(Page.ViewAdditionalDetails.getURL()));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewAdditionalDetailsQuoteContExt contExt = new ViewAdditionalDetailsQuoteContExt(sc);
        
        System.assertEquals(contExt.quote.Id, testQuote.Id, 'ViewAdditionalDetailsQuoteContExt is not refereing to the same quote.');
        System.assert(!contExt.isValidQuote, 'No parameters passed and this is an invalid quote.');
        System.assertEquals(contExt.qliModel, null, 'For an invalid quote QliModel instance must be null.');
        
    }
    
    private static testMethod void ViewAdditionalDetailsQuoteContExt_whenQuoteIdIsEmptyAndNoQLIId_returnsNothing() {
        
        testSetupData();
        
        Test.setCurrentPageReference(new PageReference(Page.ViewAdditionalDetails.getURL() + '?id='));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewAdditionalDetailsQuoteContExt contExt = new ViewAdditionalDetailsQuoteContExt(sc);
        
        System.assertEquals(contExt.quote.Id, testQuote.Id, 'ViewAdditionalDetailsQuoteContExt is not refereing to the same quote.');
        System.assert(!contExt.isValidQuote, 'When Quote Id is empty this must be treated as an invalid quote.');
        System.assertEquals(contExt.qliModel, null, 'For an invalid quote QliModel instance must be null.');
        
    }
    
    private static testMethod void ViewAdditionalDetailsQuoteContExt_whenQuoteIdAndQLIIdsIsPresent_returnsNothing() {
        
        testSetupData();
        
        Test.setCurrentPageReference(new PageReference(Page.ViewAdditionalDetails.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewAdditionalDetailsQuoteContExt contExt = new ViewAdditionalDetailsQuoteContExt(sc);
        
        System.assertEquals(contExt.quote.Id, testQuote.Id, 'ViewAdditionalDetailsQuoteContExt is not refereing to the same quote.');
        System.assert(contExt.isValidQuote, 'For a valid Quote and QLI Id this must be treated as a valid quote.');
        System.assertNotEquals(contExt.qliModel, null, 'For an valid quote QliModel instance must not be null.');
        
        System.assertEquals(contExt.qliModel.getSelectedProducts().size(), 2, 'The size of selected products must represent the 2 QLIs on the quote.');
        
    }
    
    private static testMethod void saveQLI_whenQLIsAreUpdated_returnsNothing() {
        
        testSetupData();
        
        Test.setCurrentPageReference(new PageReference(Page.ViewAdditionalDetails.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewAdditionalDetailsQuoteContExt contExt = new ViewAdditionalDetailsQuoteContExt(sc);
        
        System.assertEquals(contExt.quote.Id, testQuote.Id, 'ViewAdditionalDetailsQuoteContExt is not refereing to the same quote.');
        System.assert(contExt.isValidQuote, 'For a valid Quote and QLI Id this must be treated as a valid quote.');
        System.assertNotEquals(contExt.qliModel, null, 'For an valid quote QliModel instance must not be null.');
        System.assertEquals(contExt.qliModel.getSelectedProducts().size(), 2, 'The size of selected products must represent the 2 QLIs on the quote.');
        
        Quote_Line_Item__c qliToBeUpdated = contExt.qliModel.getSelectedProducts()[0].getQuoteLineItem();
        qliToBeUpdated.Color__c = 'Test Color';
        contExt.saveQLI();
        
        String afterUpdateColor = [Select Color__c FROM Quote_Line_Item__c WHERE Id = :testQLIs[0].Id].Color__c;
        System.assertEquals(afterUpdateColor, 'Test Color', 'A successful save must be executed.');
        
        contExt.isValidQuote = false;
        System.assert(!contExt.isValidQuote, 'isValidQuote should have a public setter');
        
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
}
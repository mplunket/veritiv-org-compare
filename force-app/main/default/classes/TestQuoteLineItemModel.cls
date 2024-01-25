/**
 Objective: Test class to valiate the functionality that hasn't been covered in TestQuoteLineItemsCont
 Developer: Hiremath, Naveen - Bluewolf     
*/
@isTest
private class TestQuoteLineItemModel {

	private static Account testCustAccount;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Product2[] products;
    private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0];
    
    static testMethod void valdiateAccessors() {
        
        testSetUpData();
        
        QuotesModel qm = new QuotesModel(testQuote);
        QuoteLineItemModel qlim = new QuoteLineItemModel(qm, testQLIs[0]);
		
		System.assertEquals(qm, qlim.getQuotesModel(), 'References must be the same');
		System.assertNotEquals(null, qlim.getExtendedCost(), 'Extended Cost must never be null');
		System.assertEquals(Consts.DISABLE, qlim.getShowPandA(), 'Must be disabled by default');
		System.assertEquals(Consts.DISABLE, qlim.getEnableUOM(), 'Must be disabled by default');
		
		System.assertEquals(null, qlim.getItemSequence(), 'Defaulted to null');
		System.assertNotEquals(null, qlim.getNextItemSequence(), 'Must never be null');
		System.assertNotEquals(null, qlim.getCount(), 'Must never be null');
		
		System.assertEquals(0.0, qlim.getExtendedPriceRunningTotal(), 'Must be defaulted to 0.0');
        System.assertEquals(0.0, qlim.getGTMRunningTotal(), 'Must be defaulted to 0.0');
    }
    
    static testMethod void validateMutators() {
    	
    	testSetUpData();
    	
    	QuotesModel qm = new QuotesModel(testQuote);
        QuoteLineItemModel qlim = new QuoteLineItemModel(qm, testQLIs[0]);
        
        //qlim.setExtendedCost([Select Id From Opportunity limit 1]);
        qlim.setShowPandA(Consts.ENABLE);
        qlim.setENableUOM(Consts.ENABLE);
        qlim.setPriceUOMs(new SelectOption[]{});
        qlim.setQuantityUOMs(new SelectOption[]{});
        qlim.setGtmPercent('1');
        qlim.setItemSequence(1);
    	
    }
    
	private static void populateProducts() {
	
		products = [select Id, ProductCode, Description, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c, Unit_of_Measure__c, Pricing_Costing_UOM__c, Conversion_Factor__c from Product2 limit 2];
			
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
        
        Product2 prd = new product2();
        prd.name = 'test';
        insert prd;
        
        product2 prd1 = new product2();
        prd1.Name = 'test1';
        insert prd1;
        
        products.add(prd);
        products.add(prd1);
        
        
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
        qli.Projected_Delivery_Date__c = System.today();
        insert qli;
        testQLIs.add(qli);
        
    }
}
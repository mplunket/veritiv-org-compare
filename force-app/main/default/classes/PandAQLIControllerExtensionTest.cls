@isTest
public class PandAQLIControllerExtensionTest {
	private static Account testCustAccount;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0]; 
    
    public static testmethod void testSetupData()
    {
        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
         testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001');
        insert testCustAccount;

         testShipAccount = new Ship_To__c(Name='Test Customer Location 1', Ship_To_Code__c='000002', Bill_To_Account__c=testCustAccount.Id, Active__c='Yes');
        insert testShipAccount;

         testQuote = new Quote__c(Account__c=testCustAccount.Id, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;

		Product2[] products = TestDataGeneration.createProducts( 2, 'TestProd', true );
		
        //Product2[] products = [select Id, ProductCode, Description, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c, Unit_of_Measure__c, Pricing_Costing_UOM__c, Conversion_Factor__c from Product2 limit 2];
        
        products = [select Id, ProductCode, 
							Description, Unisource_Item_Number_U_number__c, 
							Vendor_Product_Code__c, Vendor__c, 
							Unit_of_Measure__c, Pricing_Costing_UOM__c, 
							Conversion_Factor__c 
					from Product2 
					where id in :products];
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
    
    public static testmethod void testConstructor()
    {
        testSetupData();
        
        Test.startTest();
        //Test no quote
        Quote_Line_Item__c[] testEmptyQLIs = new Quote_Line_Item__c[0];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(testEmptyQLIs);
        PandAQLIControllerExtension qlice = new PandAQLIControllerExtension(ssc);
        System.assert(!qlice.hasSelectedRecords);
        System.assertEquals(0, ssc.getRecords().size());
        //Test no QLIs
        Test.setCurrentPageReference(new PageReference(Page.PricingAndAvailability.getURL() + '?id=' + testQuote.Id));
        testEmptyQLIs = new Quote_Line_Item__c[0];
        ssc = new ApexPages.StandardSetController(testEmptyQLIs);
        qlice = new PandAQLIControllerExtension(ssc);
        System.assert(!qlice.hasSelectedRecords);
        System.assertEquals(0, ssc.getRecords().size());
        //Test with QLIs
        Test.setCurrentPageReference(new PageReference(Page.PricingAndAvailability.getURL() + '?id=' + testQuote.Id));
        ssc = new ApexPages.StandardSetController(testQLIs);
        System.assertEquals(2, ssc.getRecords().size());
        ssc.setSelected(testQLIs);
        qlice = new PandAQLIControllerExtension(ssc);
        System.assert(qlice.hasSelectedRecords);
        
        Test.stopTest();
    }

    public static testmethod void testProperties()
    {
        testSetupData();
        
        Test.startTest();
        Quote_Line_Item__c[] testEmptyQLIs = new Quote_Line_Item__c[0];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(testEmptyQLIs);
        PandAQLIControllerExtension qlice = new PandAQLIControllerExtension(ssc);
        
        Boolean testValidQuote = qlice.isValidQuote;
        System.assert(!testValidQuote);
        qlice.isValidQuote = true; 
        testValidQuote = qlice.isValidQuote;
        System.assert(testValidQuote);

        ProductWrapper[] testPWs = qlice.pricingProducts;
        System.assertNotEquals(null, testPWs);
        testPWs.add(new ProductWrapper(new Product2(Name='test product')));
        qlice.pricingProducts = testPWs;
        System.assertEquals('test product', qlice.pricingProducts[0].product.Name);
        
        Test.stopTest();
    }
}
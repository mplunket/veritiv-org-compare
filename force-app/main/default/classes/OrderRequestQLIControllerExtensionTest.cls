@isTest
public class OrderRequestQLIControllerExtensionTest {
 
    private static Account testCustAccount;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0]; 


    public static testmethod void testSetupData()
    {
        ID prosRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Prospect'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=prosRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001');
        insert testCustAccount;

        testShipAccount = new Ship_To__c(Name='Test Customer Location 1', Ship_To_Code__c='000002', Bill_To_Account__c=testCustAccount.Id, Active__c='Yes');
        insert testShipAccount;

        testQuote = new Quote__c(Account__c=testCustAccount.Id, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;
Product2 pr  = new Product2();
        pr.Name = 'test' ;
        
        insert pr;
        Product2 pr1  = new Product2();
        pr1.Name = 'test1' ;
        
        insert pr1;
        Product2[] products = [select Id, ProductCode, Description, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c,
                               Unit_of_Measure__c, Pricing_Costing_UOM__c, Conversion_Factor__c from Product2 limit 2];
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
        qli.Projected_Delivery_Date__c = System.today();
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
        OrderRequestQLIControllerExtension qlice = new OrderRequestQLIControllerExtension(ssc);
        System.assert(!qlice.hasSelectedRecords);
        System.assertEquals(0, ssc.getRecords().size());
        //Test no QLIs
        Test.setCurrentPageReference(new PageReference(Page.PricingAndAvailability.getURL() + '?id=' + testQuote.Id));
        testEmptyQLIs = new Quote_Line_Item__c[0];
        ssc = new ApexPages.StandardSetController(testEmptyQLIs);
        qlice = new OrderRequestQLIControllerExtension(ssc);
        System.assert(!qlice.hasSelectedRecords);
        System.assertEquals(0, ssc.getRecords().size());
        //Test with QLIs
        Test.setCurrentPageReference(new PageReference(Page.PricingAndAvailability.getURL() + '?id=' + testQuote.Id));
        ssc = new ApexPages.StandardSetController(testQLIs);
        System.assertEquals(2, ssc.getRecords().size());
        ssc.setSelected(testQLIs);
        qlice = new OrderRequestQLIControllerExtension(ssc);
        System.assert(qlice.hasSelectedRecords);
        
        Test.stopTest();
    }

    public static testmethod void testProperties()
    {
        testSetupData();
        
        Test.startTest();

        Quote_Line_Item__c[] testEmptyQLIs = new Quote_Line_Item__c[0];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(testEmptyQLIs);
        OrderRequestQLIControllerExtension qlice = new OrderRequestQLIControllerExtension(ssc);
        
        Boolean testValidQuote = qlice.isValidQuote;
        System.assert(!testValidQuote);
        qlice.isValidQuote = true; 
        testValidQuote = qlice.isValidQuote;
        System.assert(testValidQuote);

        Test.stopTest();
    }
    
    public static testmethod void testActionMethods()
    {
        testSetupData();
        
        Test.startTest();
		//Test with prospect account, no ship to, submitted order
        Test.setCurrentPageReference(new PageReference(Page.OrderRequest.getURL() + '?id=' + testQuote.Id));
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(testQLIs);
        OrderRequestQLIControllerExtension qlice = new OrderRequestQLIControllerExtension(ssc);
        qlice.isValidQuote = true;
        PageReference tempPage = qlice.postOrderRequest();
        System.assertEquals(null, tempPage);
		//Test with customer account, no ship to, submitted order
        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount.RecordTypeId = custRecTypeID;
        update testCustAccount;
        Test.setCurrentPageReference(new PageReference(Page.OrderRequest.getURL() + '?id=' + testQuote.Id));
        ssc = new ApexPages.StandardSetController(testQLIs);
        qlice = new OrderRequestQLIControllerExtension(ssc);
        qlice.isValidQuote = true;
        tempPage = qlice.postOrderRequest();
        System.assertEquals(null, tempPage);
		//Test with customer account, ship to, submitted order
		testQuote.Ship_To__c = testShipAccount.Id;
        update testQuote;
        Test.setCurrentPageReference(new PageReference(Page.OrderRequest.getURL() + '?id=' + testQuote.Id));
        ssc = new ApexPages.StandardSetController(testQLIs);
        qlice = new OrderRequestQLIControllerExtension(ssc);
        qlice.isValidQuote = true;
        tempPage = qlice.postOrderRequest();
        System.assertEquals(null, tempPage);
        System.assert(!qlice.hasSelectedRecords);
		//Test with customer account, ship to, non submitted order
        update testQuote;
        Test.setCurrentPageReference(new PageReference(Page.OrderRequest.getURL() + '?id=' + testQuote.Id));
        ssc = new ApexPages.StandardSetController(testQLIs);
        System.assertEquals(2, ssc.getRecords().size());
        ssc.setSelected(testQLIs);
        qlice = new OrderRequestQLIControllerExtension(ssc);
        System.assert(qlice.hasSelectedRecords);
        qlice.isValidQuote = true;
        tempPage = qlice.postOrderRequest();
        System.assertEquals(null, tempPage);

        Test.stopTest();
    }
}
@isTest
private class ProductWrapperTest{
    public static testmethod void testProductWrapper()
    {
        Test.startTest();
        ProductWrapper pw = new ProductWrapper(null);
        Product2 p = pw.product;
        pw = new ProductWrapper(p);
        
        Boolean testSelect = pw.isSelected;
        System.assert(!testSelect);
        pw.isSelected = true; 
        testSelect = pw.isSelected;
        System.assert(testSelect);
        
        PricingAndAvailability paa = pw.PandA;
        System.assertNotEquals(null, paa);
        pw.PandA = paa;
        System.assertEquals(paa, pw.PandA);
        
        Opportunity opp = pw.cost;
        System.assertEquals(0, opp.Amount);
        String str = pw.uom;
        System.assertEquals('',str);
        
        opp = pw.price;
        System.assertEquals(0, opp.Amount);
        PricingAndAvailability.ItemDetailsClass idc = new PricingAndAvailability.ItemDetailsClass();
        idc.ItemCostStandard = String.valueOf(10.95);
        idc.ItemPricingUOM = 'EA';
        idc.ItemPricePerUOM = String.valueOf(10.95);
        pw.PandA.Response.ItemDetails.add(idc);
        opp = pw.cost;
        System.assertEquals(10.95, opp.Amount);
        str = pw.uom;
        System.assertEquals('EA', str);
        opp = pw.price;
        System.assertEquals(10.95, opp.Amount);
        String[] strs = pw.systemDivisions;
        System.assert(strs.size() == 0);
        strs = pw.quantityOnhand;
        System.assert(strs.size() == 0);
        strs = pw.stockingUOMs;
        System.assert(strs.size() == 0);
        strs = pw.divisions;
        System.assert(strs.size() == 0);
        strs = pw.transferDays;
        System.assert(strs.size() == 0);
        
        PricingAndAvailability.AvailabilityClass ac = new PricingAndAvailability.AvailabilityClass();
        ac.ItemSystemId = 'MA';
        ac.ItemDivisionId = '01';
        ac.ItemQuantityOnhand = '10';
        ac.ItemStockingUOM = 'CS';
        ac.ItemTransferDays = '1';
        pw.PandA.Response.Availability.add(ac);
        strs = pw.systemDivisions;
        System.assert(strs.size() == 1);
        System.assertEquals('MA-01', strs[0]);
        strs = pw.stockingUOMs;
        System.assert(strs.size() == 1);
        System.assertEquals('CS', strs[0]);
        strs = pw.quantityOnhand;
        System.assert(strs.size() == 1);
        System.assertEquals('10', strs[0]);
//        strs = pw.divisions;
//        System.assert(strs.size() == 1);
//        System.assertEquals('UNISOURCE - DES MOINES', strs[0]);
        strs = pw.transferDays;
        System.assert(strs.size() == 1);
        System.assertEquals('1', strs[0]);
        Test.stopTest();
    }
}
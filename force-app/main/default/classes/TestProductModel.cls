/**
 Objective: Test class to valiate the functionality that hasn't been covered in TestProductSearchCont
 Developer: Hiremath, Naveen - Bluewolf     
*/
@isTest
private class TestProductModel {

	private static Product2[] products;
	
    static testMethod void myUnitTest() {
       
       populateProducts();
       
        product2 prd = new product2();
        prd.Name ='test';
        insert prd;
        
        product2 prd1 = new product2();
        prd1.Name = 'test1';
        insert prd1;
        
        products.add(prd);
        products.add(prd1);
        
        
       ProductModel pm = new ProductModel(products[0], Freight_Lines__c.getAll(), ServicingDivisionServices.getActiveServiceDivisions());
       System.assertNotEquals(null, pm.getProductsPixelSize(), 'Default pixel size');
       System.assertNotEquals(null, pm.getFreightCodes(), 'Freight Code values from custom setting cant be null');
       System.assertNotEquals(null, pm.getFreightLines(), 'Freight Code values from custom setting cant be null');
       System.assertNotEquals(null, pm.getAvailableDivisions(), 'Divisions cannot be null');
       System.assertNotEquals(null, pm.getSelectedDivisions(), 'Divisions cannot be null');
       
       System.assert(!pm.getMatches());
       System.assert(pm.getCount() == 0);
       
    }
    
    private static void populateProducts() {
	
		products = [select Id, ProductCode, Description, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c, Unit_of_Measure__c, Pricing_Costing_UOM__c, Conversion_Factor__c from Product2 limit 2];
			
	}
	
}
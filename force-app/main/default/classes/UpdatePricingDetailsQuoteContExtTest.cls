@isTest
private class UpdatePricingDetailsQuoteContExtTest {

	private static Account testCustAccount;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Product2[] products;
    private static List<Quote_Line_Item__c> testQLIs = new List<Quote_Line_Item__c>();
	public static final String SAALFELD_PERMISSION_SET_NAME = 'Saalfeld_Pricing_Access';

	private static Quote_Line_Item__c createQuoteLineItem(Quote__c thisQuote, Product2 prod2)
    {
    	Quote_Line_Item__c qli = (Quote_Line_Item__c) SObjectFactory.build(Quote_Line_Item__c.SObjectType);
    	qli.Quote__c = thisQuote.Id;
    	qli.Product__c = prod2.Id;
        qli.Product__r = prod2;
        qli.Product_Code__c = prod2.ProductCode;
        qli.Product_Description__c = prod2.Description;
        qli.Unisource_Item__c = prod2.Unisource_Item_Number_U_number__c;
        qli.Vendor_Item__c = prod2.Vendor_Product_Code__c;
        qli.Vendor_Name__c = prod2.Vendor__c;
        //qli.Qty__c = quantity;
        qli.Quantity_unit_of_measure__c = prod2.Unit_of_Measure__c;
        qli.Price_unit_of_measure__c = prod2.Pricing_Costing_UOM__c;
        qli.Costing_unit_of_measure__c = prod2.Pricing_Costing_UOM__c;
        //qli.Quantity_Unit_Factor__c = 1;
        qli.Price_Unit_Factor__c = prod2.Conversion_Factor__c;
        qli.Cost_Unit_Factor__c = prod2.Conversion_Factor__c; 
        qli.Projected_Delivery_Date__c = System.today();
        return qli;
    }

	private static void testSetupData() {
        testCustAccount = (Account) SObjectFactory.create(Account.SObjectType,'Prospect');
        testShipAccount = (Ship_To__c) SObjectFactory.create(Ship_To__c.SObjectType, 
	        												 new Map<Schema.SObjectField, Object>
	        												 {
	        												 	Ship_To__c.Name => 'Test Customer Location 1',
	        												 	Ship_To__c.Ship_To_Code__c => '000002',
	        												 	Ship_To__c.Bill_To_Account__c => testCustAccount.Id,
	        												 	Ship_To__c.Active__c => 'Yes'
	        												 });
        
        testQuote = (Quote__c) SObjectFactory.create(Quote__c.SObjectType, 
	        												 new Map<Schema.SObjectField, Object>
	        												 {
	        												 	Quote__c.Account__c => testCustAccount.Id, 
	        												 	Quote__c.Shipment_Method__c => 'Warehouse',
	        												 	Quote__c.Requested_Delivery_Date__c => System.today()
	        												 });
	    
        products = (List<Product2>) SObjectFactory.create(2, Product2.SObjectType); 
        
        List<Quote_Line_Item__c> qlis = (List<Quote_Line_Item__c>) SObjectFactory.build(2, Quote_Line_Item__c.SObjectType);
        qlis[0].Product__c = products[0].Id;
        qlis[0].Product__r = products[0];
        qlis[1].Product__c = products[1].Id;
        qlis[1].Product__r = products[1];
        qlis[0].Quote__c = testQuote.Id;
        qlis[1].Quote__c = testQuote.Id;
        insert qlis;

		testQLIs.add( qlis[0] );
        testQLIs.add( qlis[1] );
    }
    
    private static void setup_QLIModelFields(UpdatePricingDetailsQuoteContExt controller)
    {
    	for(QuoteLineItemModel qliMod : controller.qliModels)
    	{
    		qliMod.matrix.Price_Level_Value__c = 'Item';
    		qliMod.matrix.Policy_Type_Value__c = 'Cost Up';
    		qliMod.quotelineitem.Pricing_Start_Date__c = Date.today().addDays(5);
    	}
    }
    
    private static testMethod void Test_ConvertSegment()
    {
    	List<String> testSegments = new List<String>{'PACKAGING', 'PrIntIng AND imaginG', 'facility supplies', 'some bad EXample'};
    	
    	String resultPK, resultPI, resultFS, resultSU, resultSU_Blank, resultSU_Null;
    	
    	Test.startTest();
    		resultPK = UpdatePricingDetailsQuoteContExt.convertSegment(testSegments[0]);
    		resultPI = UpdatePricingDetailsQuoteContExt.convertSegment(testSegments[1]);
    		resultFS = UpdatePricingDetailsQuoteContExt.convertSegment(testSegments[2]);
    		resultSU = UpdatePricingDetailsQuoteContExt.convertSegment(testSegments[3]);
    		resultSU_Blank = UpdatePricingDetailsQuoteContExt.convertSegment('');
    		resultSU_Null = UpdatePricingDetailsQuoteContExt.convertSegment(null);
    	Test.stopTest();
    	
    	System.assertEquals('PK', resultPK, 'We expect the correct result for Packaging.');
    	System.assertEquals('PI', resultPI, 'We expect the correct result for Printing and Imaging.');
    	System.assertEquals('FS', resultFS, 'We expect the correct result for Facility Supplies.');
    	System.assertEquals('SU', resultSU, 'We expect the correct result for the default.');
    	System.assertEquals('SU', resultSU_Blank, 'We expect the correct result for the blank.');
    	System.assertEquals('SU', resultSU_Null, 'We expect the correct result for the null.');
    }
    
    private static testMethod void Test_convertPricingType()
    {
    	String result_MaintainMargin, result_CWTFixed, result_ListDown, result_CostUp, result_Fixed, result_Other = '';
    	String PT_MaintainMargin = 'RETAIN GTM';
    	String PT_CWTFixed = 'CWT PRICE';
    	String PT_ListDown = 'LIST DOWN';
    	String PT_CostUp = 'COST UP';
    	String PT_Fixed = 'FIXED';
    	String PT_Other = 'Other';
    	
    	Test.startTest();
    		result_MaintainMargin = UpdatePricingDetailsQuoteContExt.convertPricingType('Maintain Margin');
    		result_ListDown = UpdatePricingDetailsQuoteContExt.convertPricingType('List Down');
    		result_CostUp = UpdatePricingDetailsQuoteContExt.convertPricingType('Cost Up');
    		result_CWTFixed = UpdatePricingDetailsQuoteContExt.convertPricingType('CWT Fixed');
    		result_Fixed = UpdatePricingDetailsQuoteContExt.convertPricingType('Fixed');
    		result_Other = UpdatePricingDetailsQuoteContExt.convertPricingType('Other');
    	Test.stopTest();
    	
    	System.assertEquals(PT_MaintainMargin, result_MaintainMargin, 'We expect the correct result for Maintain Margin.');
    	System.assertEquals(PT_CWTFixed, result_CWTFixed, 'We expect the correct result for CWT Fixed');
    	System.assertEquals(PT_ListDown, result_ListDown, 'We expect the correct result for List Down.');
    	System.assertEquals(PT_CostUp, result_CostUp, 'We expect the correct result for Cost Up.');
    	System.assertEquals(PT_Fixed, result_Fixed, 'We expect the correct result for Fixed.');
    	System.assertEquals(PT_Other, result_Other, 'We expect the correct result for the default case.');
    }
    
    private static testMethod void Test_GetCustomerCompositeKey()
    {
    	String CompositeKey_SW = 'SWExB2N';
    	String CompositeKey_Legacy = 'NXExB2N';
    	
    	Quote__c testQuote_SW = (Quote__c) JsonUtils.createSObject(Quote__c.SObjectType, new Map<String, Object>
    		{
    			'Bill_To_Number__c' => 'ExB2N',
    			'Account_Legacy_System_Cd__c' => '03'
    		}
    	);
    	Quote__c testQuote_Legacy = (Quote__c) JsonUtils.createSObject(Quote__c.SObjectType, new Map<String, Object>
    		{
    			'Bill_To_Number__c' => 'ExB2N',
    			'Account_Legacy_System_Cd__c' => 'NX'
    		}
    	);
    	
    	Test.startTest();
    		String result_SW = UpdatePricingDetailsQuoteContExt.getCustomerCompositeKey(testQuote_SW);
    		String result_Legacy = UpdatePricingDetailsQuoteContExt.getCustomerCompositeKey(testQuote_Legacy);
    	Test.stopTest();
    	
    	System.assertEquals(CompositeKey_Legacy, result_Legacy, 'We expect the correct Composite Key to be returned for Legacy.');
    	System.assertEquals(CompositeKey_SW, result_SW, 'We expect the correct Composite Key to be returned for Default.');
    }
    
    private static testMethod void Test_renderSendButton()
    {
    	Integer rowNumber = 0;
    	
    	testSetupData();
    	
    	UpdatePricingDetailsQuoteContExt cont;
    	
    	Test.startTest();
    		Test.setCurrentPageReference(new PageReference(Page.UpdatePricingDetails.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
    		cont = new UpdatePricingDetailsQuoteContExt(new ApexPages.standardController(testQuote));
    		
    		System.assertNotEquals(null, cont.qliModels, 'We expect models to exists.');
    		System.assertEquals(false, cont.renderSendButton, 'We expect false because there are no errors on the models so the button should not be disabled.');
    		
    		cont.qliIntToModel.get(rowNumber).setqliErrors(new List<String>{ 'error1', 'error2' });
    		System.assertEquals(true, cont.renderSendButton, 'We expect true because there are errors on one of the models so be disabled.');
    	Test.stopTest();
    }
    
    private static testMethod void Test_addErrorToPage()
    {
    	String errorMessage = 'This is a test message.';
    	String errorLevelSeverity = 'INFO';
    	Integer rowNumber = 0;
    	Boolean toAdd = true;
    	
    	testSetupData();
    	
    	UpdatePricingDetailsQuoteContExt.errorLevel = errorLevelSeverity; 
    	UpdatePricingDetailsQuoteContExt.message = errorMessage;
    	UpdatePricingDetailsQuoteContExt.qliIndex = rowNumber;
    	UpdatePricingDetailsQuoteContExt.isNewError = toAdd;
    	
    	Test.startTest();
    		Test.setCurrentPageReference(new PageReference(Page.UpdatePricingDetails.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
    		UpdatePricingDetailsQuoteContExt cont = new UpdatePricingDetailsQuoteContExt(new ApexPages.standardController(testQuote));
    		cont.addErrorToPage(); 
    	Test.stopTest();
    	
    	System.assertEquals( false, cont.qliIntToModel.get(rowNumber).getqliErrors().isEmpty(), 'We expect the qli model to contain errors.');
    	System.assertEquals( true, cont.qliIntToModel.get(rowNumber).getqliErrors()[0].contains(errorLevelSeverity), 'We expect the error to contain the accurate text.');
    }
    
    private static testMethod void Test_UpdatePricingDetails_Controller() {

        testSetupData();
        
        UpdatePricingDetailsQuoteContExt cont;
		
		Test.startTest();
	        Test.setCurrentPageReference(new PageReference(Page.UpdatePricingDetails.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
	        cont = new UpdatePricingDetailsQuoteContExt(new ApexPages.standardController(testQuote));
        Test.stopTest();

        System.assert(!cont.qliModels.isEmpty(), 'We expect the map to be populated.');
        System.assertEquals(testQLIs.size(), cont.qliModels.size(), 'We expect the correcct number of ids.');
      //  System.assertEquals(testQuote, cont.quote, 'We expect the quotes to match.');
    }
    
    private static testMethod void Test_UpdatePricingDetails_Controller_LineItemsSent() { 

		List<String> requestResponses = new List<String>{ UpdateZilliantServicesMock.SuccessResponseXML, UpdateZilliantServicesMock.SuccessResponseXML }; 

        testSetupData();
        UpdateZilliantRequestTest.setupWebservice_Zilliant();
    	Test.setMock(HttpCalloutMock.class, new UpdateZilliantServicesMock( requestResponses ));
    	
    	UpdatePricingDetailsQuoteContExt cont;
    	
        Test.setCurrentPageReference(new PageReference(Page.UpdatePricingDetails.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        cont = new UpdatePricingDetailsQuoteContExt(new ApexPages.standardController(testQuote));
		setup_QLIModelFields(cont);

		Test.startTest();
			cont.updatePricingDetails();
		Test.stopTest();

		List<Quote_Line_Item__c> resultQLIs = [SELECT Id, Sent_To_Zilliant_Time__c FROM Quote_Line_Item__c WHERE Quote__c =: testQuote.Id];

        System.assertEquals(resultQLIs.size(), cont.qliModels.size(), 'We expect the correcct number of ids.');
        for(Quote_Line_Item__c qli : resultQLIs)
        {
        	System.assertNotEquals( NULL, qli.Sent_To_Zilliant_Time__c, 'We expect the qli to have been updated.');
        }
    }
    
    private static testMethod void Test_UpdatePricingDetails_Controller_ErrorHandling() { 

		List<String> requestResponses = new List<String>{ UpdateZilliantServicesMock.ErrorResponseXML, UpdateZilliantServicesMock.SuccessResponseXML, UpdateZilliantServicesMock.SuccessResponseXML }; 

        testSetupData();
        
        Quote_Line_Item__c qli = (Quote_Line_Item__c) SObjectFactory.build(Quote_Line_Item__c.SObjectType);
        qli.Product__c = products[0].Id;
        qli.Product__r = products[0];
        qli.Quote__c = testQuote.Id;
        insert qli;

        testQLIs.add( qli );
        
        UpdateZilliantRequestTest.setupWebservice_Zilliant();
    	Test.setMock(HttpCalloutMock.class, new UpdateZilliantServicesMock( requestResponses ));
    	
    	UpdatePricingDetailsQuoteContExt cont;
    	
        Test.setCurrentPageReference(new PageReference(Page.UpdatePricingDetails.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id + ',' + testQLIs[2].Id));
        cont = new UpdatePricingDetailsQuoteContExt(new ApexPages.standardController(testQuote));

		// Overwrite QLI field Quote__c to null to fail update.		
		QuoteLineItemModel tempModel = cont.qliIdToModel.get(testQLIs[1].Id);
		Quote_Line_Item__c blankedQLI = (Quote_Line_Item__c) JSONUtils.setField(tempModel.quoteLineItem, 'Vendor_Contact__c', '0015B000002oYa3');
		QuoteLineItemModel correctModel = new QuoteLineItemModel(null, (Quote_Line_Item__c) blankedQLI); 
		
		cont.qliIdToModel.put(testQLIs[1].Id, correctModel); 
		setup_QLIModelFields(cont);

		Test.startTest();
			cont.updatePricingDetails(); 
		Test.stopTest();

		Map<Id, Quote_Line_Item__c> resultQLIs = new Map<Id, Quote_Line_Item__c>([SELECT Id, Sent_To_Zilliant_Time__c FROM Quote_Line_Item__c WHERE Quote__c =: testQuote.Id]);

        System.assert(!cont.qliModels.isEmpty(), 'We expect the map to be populated.');
        System.assertEquals(resultQLIs.size(), cont.qliModels.size(), 'We expect the correcct number of ids.');
        
    	System.assertNotEquals( NULL, resultQLIs.get(testQLIs[2].Id).Sent_To_Zilliant_Time__c, 'We expect the qli to have been updated.');
    	System.assertEquals( NULL, resultQLIs.get(testQLIs[1].Id).Sent_To_Zilliant_Time__c, 'We expect the qli to not have been updated.');
    	System.assertEquals( NULL, resultQLIs.get(testQLIs[0].Id).Sent_To_Zilliant_Time__c, 'We expect the qli to not have been updated.');
    }

	@isTest private static void checkSaalfeldPropertyFalse() {
		Boolean testValue;
		User runningUser = ((List<User>) new SobjectBuilder(User.SObjectType).count(1).create().getRecords())[0];

		Test.startTest();
			System.runAs(runningUser) {
				testValue = UpdatePricingDetailsQuoteContExt.isSaalfeldUser;
			}
		Test.stopTest();

		System.assertEquals(false, testValue, 'We expect the property to be set as false');
	}

	@isTest private static void checkSaalfeldPropertyTrue() {
		Boolean testValue;
		User runningUser = ((List<User>) new SobjectBuilder(User.SObjectType).count(1).create().getRecords())[0];
		PermissionSet saalfeldPermissionSet= [SELECT Id FROM PermissionSet WHERE Name = :SAALFELD_PERMISSION_SET_NAME LIMIT 1];

		insert new PermissionSetAssignment(AssigneeId = runningUser.Id, PermissionSetId = saalfeldPermissionSet.Id);

		Test.startTest();
			System.runAs(runningUser) {
				testValue = UpdatePricingDetailsQuoteContExt.isSaalfeldUser;
			}
		Test.stopTest();

		System.assertEquals(true, testValue, 'We expect the property to be set as true');
	}

    @isTest private static void checkAccountActivePropertyTrue() {
        testSetupData();

        testCustAccount.Active__c = 'Yes';
        update testCustAccount;

        UpdatePricingDetailsQuoteContExt controller;

        Test.startTest();
            Test.setCurrentPageReference(new PageReference(Page.UpdatePricingDetails.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
            controller = new UpdatePricingDetailsQuoteContExt(new ApexPages.standardController(testQuote));
        Test.stopTest();

        System.assertEquals(true, controller.isAccountActive, 'We expect the property to be instantiated as True');
    }

    @isTest private static void checkAccountActivePropertyFalse() {
        testSetupData();

        testCustAccount.Active__c = 'No';
        update testCustAccount;

        UpdatePricingDetailsQuoteContExt controller;

        Test.startTest();
            Test.setCurrentPageReference(new PageReference(Page.UpdatePricingDetails.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
            controller = new UpdatePricingDetailsQuoteContExt(new ApexPages.standardController(testQuote));
        Test.stopTest();

        System.assertEquals(false, controller.isAccountActive, 'We expect the property to be instantiated as False');
    }
    
}
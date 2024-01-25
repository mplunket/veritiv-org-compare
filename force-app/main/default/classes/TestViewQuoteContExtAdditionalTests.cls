@isTest
public with sharing class TestViewQuoteContExtAdditionalTests {
	
	public static Quote__c testQuote;
	
	public static void setupData(){
	    Account testCustAccount = new Account(Name='Test Customer', AccountNumber='123456', Ship_To_Code__c='000001', Active__c='Yes');
        insert testCustAccount;
		
		Servicing_Division__c testServiceDivision1 = new Servicing_Division__c();
		testServiceDivision1.Name = 'Test Unisource Division';
		testServiceDivision1.Division_Code__c = 'Un1';
		testServiceDivision1.System_Code__c = 'UN';
		insert testServiceDivision1;

		Servicing_Division__c testServiceDivision2 = new Servicing_Division__c();
		testServiceDivision2.Name = 'Test Xpedx Division';
		testServiceDivision2.Division_Code__c = 'Xp1';
		testServiceDivision2.System_Code__c = 'X';
		insert testServiceDivision2;
		
		testQuote = new Quote__c(Account__c=testCustAccount.Id, Date_Quoted__c = System.today(), Account__r=testCustAccount, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;
        
	}
	
	public static testMethod  void testProductSearchDivisions() {
		
		Account testCustAccount = new Account(Name='Test Customer', AccountNumber='123456', Ship_To_Code__c='000001', Active__c='Yes');
        insert testCustAccount;
		
		Servicing_Division__c testServiceDivision1 = new Servicing_Division__c();
		testServiceDivision1.Name = 'Test Unisource Division';
		testServiceDivision1.Division_Code__c = 'Un1';
		testServiceDivision1.System_Code__c = 'UN';
		insert testServiceDivision1;

		Servicing_Division__c testServiceDivision2 = new Servicing_Division__c();
		testServiceDivision2.Name = 'Test Xpedx Division';
		testServiceDivision2.Division_Code__c = 'Xp1';
		testServiceDivision2.System_Code__c = 'X';
		insert testServiceDivision2;
		
		testQuote = new Quote__c(Account__c=testCustAccount.Id, Date_Quoted__c = System.today(), Account__r=testCustAccount, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController( testQuote );
        ViewQuoteQuoteContExt quoteCont = new ViewQuoteQuoteContExt( stdCont );
		
		Test.startTest();
			List<Servicing_Division__c> divisions = ServicingDivisionServices.getActiveServiceDivisions();
		Test.stopTest();
		
		
		
		System.assertEquals(1, divisions.size(), 'We expect back only the division that does not contain an X in the system code field.');
		System.assertEquals('Test Unisource Division', divisions[0].Name, 'We expect back only the division that does not contain an X in the system code field.'); 
	}
	
	
	
	
	public static testMethod  void testRenderSalesOrderNumberField_true() {
		
		setupData();
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController( testQuote );
        stdCont.getRecord().put('Quote_Stage__c', QuoteInformationExt.QUOTE_WON_STAGE);
        ViewQuoteQuoteContExt quoteCont = new ViewQuoteQuoteContExt( stdCont );		
		
		Test.startTest();
			Boolean result = quoteCont.renderSalesOrderNumberField;
		Test.stopTest();
		
		
		
		System.assertEquals(true, result, 'We expect to render the Sales Order number field when the Quote is in stage won.');
	}
	
	public static testMethod  void testRenderSalesOrderNumberField_false() {
		
		setupData();
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController( testQuote );
        stdCont.getRecord().put('Quote_Stage__c', QuoteInformationExt.QUOTE_LOST_STAGE);
        ViewQuoteQuoteContExt quoteCont = new ViewQuoteQuoteContExt( stdCont );
		
		
		Test.startTest();
			Boolean result = quoteCont.renderSalesOrderNumberField;
		Test.stopTest();
		
		
		
		System.assertEquals(false, result, 'We expect to not render the Sales Order number field when the Quote is in stage lost.');
	}
	
	public static testMethod  void testRenderLostReasonCommentsField_true() {
		
		setupData();
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController( testQuote );
		stdCont.getRecord().put('Quote_Stage__c', QuoteInformationExt.QUOTE_LOST_STAGE);
		stdCont.getRecord().put('Lost_Reason__c', QuoteInformationExt.QUOTE_LOST_REASON_OTHER);
		ViewQuoteQuoteContExt quoteCont = new ViewQuoteQuoteContExt( stdCont );
		
		
		Test.startTest();
			Boolean result = quoteCont.renderLostReasonCommentsField;
		Test.stopTest();
		
		
		
		System.assertEquals(true, result, 'We expect to render the Lost Reason Comments field when the Quote is in stage lost.');
	}
	
	public static testMethod  void testRenderLostReasonCommentsField_false() {
		
		setupData();
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController( testQuote );
        stdCont.getRecord().put('Quote_Stage__c', QuoteInformationExt.QUOTE_WON_STAGE);
        ViewQuoteQuoteContExt quoteCont = new ViewQuoteQuoteContExt( stdCont );		
		
		Test.startTest();
			Boolean result = quoteCont.renderLostReasonCommentsField;
		Test.stopTest();
		
		
		
		System.assertEquals(false, result, 'We expect to not render the Lost Reason Comments field when the Quote is in stage won.');
	}
	
	
}
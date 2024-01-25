@isTest
public with sharing class TestFrequentCarrierLinksController {
	
	static testMethod void testCustomCarrierLinks(){
		
		List<Frequent_3PL_Carrier_URLs__c> testCarrierLinks = TestingUtils.createF3PLCarrierUrls('F3PLCarrierUrlName', 'https://www.google.com', 20, true);
		
		FrequentCarrierLinksController testCarrierController = new FrequentCarrierLinksController();
		
		UnitTest.addData(testCarrierLinks).tag('All carriers links');
		
		UnitTest.analyze('All carriers links').assertEquivalence(testCarrierController.carrierLinks, 
						'custom carriers links that are retreived by the controller should match the custom carriers links that exist');
	}
}
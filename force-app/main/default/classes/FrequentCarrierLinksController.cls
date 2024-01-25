public with sharing class FrequentCarrierLinksController {
	
	public List<Frequent_3PL_Carrier_URLs__c> carrierLinks{
		get{
			carrierLinks = Frequent_3PL_Carrier_URLs__c.getAll().values();
			carrierLinks.sort();
			return carrierLinks;
		}
		 set;
	}
}
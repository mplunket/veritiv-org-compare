/**
 Objective: Noninstantiable services class that collects all 
 			static SOQL service methods operating on Servicing_Division__c object
 Developer: Hiremath, Naveen - Bluewolf     
*/
public with sharing class ServicingDivisionServices {

	public static List<Servicing_Division__c> getActiveServiceDivisions() {
	
		return [SELECT 
				Id, 
				Name, 
				Division_Code__c 
				FROM Servicing_Division__c 
				WHERE Active__c = :Consts.ENABLE
				AND System_Code__c != 'X'
            ORDER BY Division_Code__c];
           	
	}
	
	/**
	 Suppress default constructor for noninstantiability
	*/
	private ServicingDivisionServices() { }
	
}
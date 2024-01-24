/**
 *	@Author: Naveen Hiremath
 *	@Company: Bluewolf
 *	@Purpose: Represents core logic for Engineered_Package_Project__c object 
*/
public class AtTaskProjectModel {
	
	public final Engineered_Package_Project__c record { 
		get; 
		private set; 
	}

	public final Id parentId {
		get;
		private set;
	}
	
	public AtTaskProjectModel(Id oppId, Engineered_Package_Project__c project) {
		this.record = project;
		this.parentId = oppId;
	} 
	
}
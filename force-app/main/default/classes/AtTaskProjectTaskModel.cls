/**
 *	@Author: Naveen Hiremath
 *	@Company: Bluewolf
 *	@Purpose: Represents core logic for Project_Task__c object 
*/
public class AtTaskProjectTaskModel {
	
	public final Project_Task__c record { 
		get; 
		private set; 
	}

	public final Id parentId {
		get;
		private set;
	}
	
	public AtTaskProjectTaskModel(Id projectId, Project_Task__c projectTask) {
		this.record = projectTask;
		this.parentId = projectId;
	} 
	
}
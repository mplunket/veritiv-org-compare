/**
 *	@Author: Naveen Hiremath
 *	@Company: Bluewolf
 *	@Purpose: Represents core logic for Opportunity object 
*/
public class OpportunityModel {

	public final Id recordId { 
		get; 
		private set; 
	}	
	
	public final AtTask projectsAndTasks { 
		get; 
		private set; 
	}
	 
	public OpportunityModel(Id oppId) {
		this.recordId = oppId;	
		this.projectsAndTasks = new AtTask(oppId);		
	}
	
}
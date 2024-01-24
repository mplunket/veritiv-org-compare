/**
 *	@Author: Naveen Hiremath
 *	@Company: Bluewolf
 *	@Purpose: Represents columns for displaying AtTask Projects and their tasks 
*/
public class AtTaskColumnModel {
		
	public final List<AtTaskProjectModel> atTaskProjects {
		get;
		private set;
	}
		
	public final Map<Id, List<AtTaskProjectTaskModel>> atTaskProjectToTasks {
		get;
		private set;
	}
		
	public AtTaskColumnModel(List<Engineered_Package_Project__c> atTaskProjects) {
		this.atTaskProjects = new List<AtTaskProjectModel>();
		this.atTaskProjectToTasks = new Map<Id, List<AtTaskProjectTaskModel>>();
	
		this.populateColumnModel(atTaskProjects);		
	}
		
	private void populateColumnModel(List<Engineered_Package_Project__c> atTaskProjects) {
		for(Engineered_Package_Project__c eachProject :atTaskprojects) {				
			final AtTaskProjectModel projectModel = new AtTaskProjectModel(eachProject.Opportunity__c, eachProject);
			this.buildProjects(projectModel);
			
			if(eachProject.Project_Tasks__r.isEmpty()) {
				this.addAnEmptyProjectTask(eachProject.Id);
				continue;
			}
					
			final List<Project_Task__c> projectTasks = new List<Project_Task__c>();
			projectTasks.addAll(eachProject.Project_Tasks__r);

			for(Project_Task__c eachTask :projectTasks) {				
				final AtTaskProjectTaskModel taskModel = new AtTaskProjectTaskModel(eachProject.Id, eachTask);
				this.buildProjectTasks(taskModel);	
			}	
		}
	}
	
	private void addAnEmptyProjectTask(Id projectId) {
		this.buildProjectTasks(new AtTaskProjectTaskModel(projectId, new Project_Task__c()));
	}
	
	private void buildProjects(AtTaskProjectModel project) {
		this.atTaskProjects.add(project);
	}
		
	private void buildProjectTasks(AtTaskProjectTaskModel projectTask) {			
		this.atTaskProjectToTasks.put(projectTask.parentId, associateTaskToItsProject(projectTask));
	}
		
	private List<AtTaskProjectTaskModel> associateTaskToItsProject(AtTaskProjectTaskModel projectTask) {
		List<AtTaskProjectTaskModel> projectTasks;
			
		if(!hasProject(projectTask.parentId)) {
			projectTasks = new List<AtTaskProjectTaskModel>();
			projectTasks.add(projectTask);
		} else {
			projectTasks = this.atTaskProjectToTasks.get(projectTask.parentId);
			projectTasks.add(projectTask);
		}
			
		return projectTasks;
	}
		
	private Boolean hasProject(Id projectId) {
		return this.atTaskProjectToTasks.containsKey(projectId);
	}			
}
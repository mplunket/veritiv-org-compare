/**
 *	@Author: Naveen Hiremath
 *	@Company: Bluewolf
 *	@Purpose: Validates ViewAtTaskOpportunityContExt behavior 
*/
@isTest
private class TestViewAtTaskOpportunityContExt {

	private static Account mockAcc;
	private static Opportunity mockOpp;
	private static Engineered_Package_Project__c mockProject;
	private static Project_Task__c mockProjectTask;	
	private static List<Project_Task__c> mockProjectTasks;
	
	private static ApexPages.StandardController sc;
	private static ViewAtTaskOpportunityContExt contExt;
	
	private static testMethod void viewAtTaskOpportunityContExt_whenOpportunity_thenOppModelMustBeInstantiated() {
		
		givenOpportunity();		
		whenControllerIsInstantiated();
		
		System.assertNotEquals(null, contExt.oppModel, 'Controller engine must have been ignited');
		 
	}
	
	private static testMethod void viewAtTaskOpportunityContExt_whenOpportunity_thenoppModelHaveAReferenceToOppId() {
		
		givenOpportunity();		
		whenControllerIsInstantiated();
		
		System.assertEquals(mockOpp.Id, contExt.oppModel.recordId, 'Standard Opportunity record and model record must be same');
		 
	}
	
	private static testMethod void viewAtTaskOpportunityContExt_whenOpportunityWithNoProject_thenColumnModelMustNotBeInstantiated() {
		
		givenOpportunityWithNoProject();
		whenControllerIsInstantiated();
		
		System.assertEquals(null, contExt.oppModel.projectsAndTasks.columnModel, 'When there is no project associated to an Opportunity no further processing takes place');
		
	}
	
	private static testMethod void viewAtTaskOpportunityContExt_whenOpportunityWithAProject_thenAtTaskProjectsMustNotBeEmpty() {
		
		givenOpportunityWithAProject();
		whenControllerIsInstantiated();
		
		System.assertEquals(1, contExt.oppModel.projectsAndTasks.columnModel.atTaskProjects.size(), 'A single project entry must be present');
		System.assertEquals(1, contExt.oppModel.projectsAndTasks.columnModel.atTaskProjectToTasks.size(), 'Even when there are no tasks to a project project to task dictionary will have a reference to an empty task');
			
	}
	
	private static testMethod void viewAtTaskOpportunityContExt_whenOpportunityWithAProjectAndTask_thenProjectsAndTaskContainersMustNotBeEmpty() {
		
		givenOpportunityWithAProjectAndATask();
		whenControllerIsInstantiated();
		
		System.assertEquals(1, contExt.oppModel.projectsAndTasks.columnModel.atTaskProjectToTasks.get(mockProject.Id).size(), 'A single task entry must be created');
		
	}
	
	private static testMethod void viewAtTaskOpportunityContExt_whenOpportunityWithAProjectAndMultipleTasks_thenAProjectMustHaveMultipleTasks() {
	
		Integer numberOfTasks = 4;
		
		givenOpportunityWithAProjectAndMultipleTasks(numberOfTasks);
		whenControllerIsInstantiated();
		
		System.assertEquals(numberOfTasks, contExt.oppModel.projectsAndTasks.columnModel.atTaskProjectToTasks.get(mockProject.Id).size(), 'A project must support multiple tasks');
			
	}
	
	private static void whenControllerIsInstantiated() {
		
		sc = new ApexPages.StandardController(mockOpp);
		contExt = new ViewAtTaskOpportunityContExt(sc);
		
	} 
	
	private static void givenOpportunityWithNoProject() {
		
		givenOpportunity();
		
	}
	
	private static void givenOpportunityWithAProject() {
		
		givenOpportunity();
		
		mockProject = TestingUtils.createEngineeredPackageProject(mockOpp.Id, 'Test Project');
		insert mockProject;
			
	}
	
	private static void givenOpportunityWithAProjectAndATask() {
		
		givenOpportunityWithAProject();
		
		mockProjectTask = TestingUtils.createProjectTask(mockProject.Id, 'Test Project Task');
		insert mockProjectTask;
		
	}
	
	private static void givenOpportunityWithAProjectAndMultipleTasks(Integer tasksSize) {
		
		givenOpportunityWithAProject();
		
		mockProjectTasks = TestingUtils.createProjectTasks(mockProject.Id, 'Test Project Task', tasksSize);
		insert mockProjectTasks;
			
	}
	
	private static void givenOpportunity() {
		
		mockAcc = TestingUtils.createAccount('Test Account');
		insert mockAcc;	
		
		mockOpp = TestingUtils.createOpportunity(mockAcc.Id, 'Test Opp');
		insert mockOpp;
		
	}
}
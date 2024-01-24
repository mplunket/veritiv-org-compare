public with sharing class TaskTriggerUtils {

	public static void processInstantServiceTasks(List<Task> tasks)
	{
		//SalesforceConstants__c sc = SalesforceConstants__c.getInstance();
		//String URL = sc.ServerURL__c;
		
		String URL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/'; 
		//String URL = '';
		
		// Get Account Id from all Tasks
		// Find latest Chat for those Accounts
		// Add link to Task to that Chat
		Set<Id> accountIds = new Set<Id>();
		
		for(Task t : tasks)
		{
			if(t.WhatId != null && String.valueOf(t.WhatId).startsWith('001'))
			{
				accountIds.add(t.WhatId);
			}
		}
		/* Commented code since this is part of the installed package that is not in use
		Map<Id, is1__Chat__c> accountIdToMostRecentChat = new Map<Id, is1__Chat__c>();
		for(is1__Chat__c chat : [select Id, is1__Account__c, CreatedDate 
									from is1__Chat__c where is1__Account__c in :accountIds])
		{
			if(!accountIdToMostRecentChat.containsKey(chat.is1__Account__c))
				accountIdToMostRecentChat.put(chat.is1__Account__c, chat);
			else
			{
				is1__Chat__c existingChat = accountIdToMostRecentChat.get(chat.is1__Account__c);
				if(chat.CreatedDate > existingChat.CreatedDate)
				{
					accountIdToMostRecentChat.put(chat.is1__Account__c, chat);
				}
			}
		}		
		
		for(Task t : tasks)
		{
			if(accountIdToMostRecentChat.containsKey(t.WhatId))
				t.Related_Chat__c = URL + accountIdToMostRecentChat.get(t.WhatId).Id;
		}*/
	}

	public static void reparentAttachments(List<Task> newTasks) {

		Id recordTypeToReparent = [SELECT Id FROM RecordType WHERE Name = 'Console Case'].Id;

		Map<String, List<Task>> whatIdToTasks = (Map<String, List<Task>>) GroupBy.strings('WhatId', newTasks);
		List<Case> relatedCases = [SELECT Id, RecordTypeId FROM Case WHERE Id IN :whatIdToTasks.keySet()];

		Map<Id, Task> tasksToBeReparented = new Map<Id, Task>();
		for(Case relatedCase : relatedCases) {
			if(relatedCase.RecordTypeId == recordTypeToReparent) {
				for(Task childTask : whatIdToTasks.get(relatedCase.Id)) {
					tasksToBeReparented.put(childTask.Id, childTask);
				}
			}
		}

		List<Attachment> relatedAttachments = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId IN :tasksToBeReparented.keySet()];
		copyAttachments(relatedAttachments, tasksToBeReparented);

	}

	public static void copyAttachments(List<Attachment> attachments, Map<Id, Task> taskMap) {
		List<Attachment> clonesToInsert = new List<Attachment>();
		for(Attachment att : attachments) {
			Attachment clone = att.clone(false, false, true, true);
			clone.ParentId = taskMap.get(att.ParentId).WhatId;
			clonesToInsert.add(clone);
		}

		insert clonesToInsert;
		delete attachments;
	}

}
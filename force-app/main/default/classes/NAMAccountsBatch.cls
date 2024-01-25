global class NAMAccountsBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String Y = 'Yes';
        String query = 'SELECT Id, OwnerId, Is_Owner_Updated__c, Active__c, ParentId, Owner.IsActive, Is_Parent_Updated__c FROM Account' 
            +' WHERE  Active__c = :Y AND Owner.IsActive = true AND (Is_Owner_Updated__c = true OR Is_Parent_Updated__c = true)';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        Map<Id, Id> mapParentIdOwnerId = new Map<Id, Id>();
        Map<Id, Id> mapChildIdOwnerId = new Map<Id, Id>();
		//Map<Id, Id> mapParentIdChildId = new Map<Id, Id>();
        Set<Id> parentIdsSet = new Set<Id>();
        List<Id> listChildId = new List<Id>();
        List<Id> lOwnerId = new List<Id>();
        List<AccountTeamMember> lAcctTeamToDelete = new List<AccountTeamMember>();
        List<AccountTeamMember> lAcctTeamToCreate = new List<AccountTeamMember>();
        List<Account> lAcctParentToUpdate = new List<Account>();
        List<Account> lAcctChildForUpdate = new List<Account>();
        List<Account> lAcctChildToUpdate = new List<Account>();
        
        // Loop through each Account record in the batch scope
        for (Account lAcc : scope) {
            // Check if Account Owner is updated
            if (lAcc.Is_Owner_Updated__c == true) {
            	mapParentIdOwnerId.put(lAcc.Id, lAcc.OwnerId);
				lOwnerId.add(lAcc.OwnerId);    
            }
            // Check if Account parent is updated
            else if (lAcc.Is_Parent_Updated__c == true) {
                listChildId.add(lAcc.Id);
                lAcctChildForUpdate.add(lAcc);
                if (lAcc.ParentId != NULL) {
                    parentIdsSet.add(lAcc.ParentId);
                	//mapParentIdChildId.put(lAcc.ParentId, lAcc.Id); 	  
                } 
            }
        }
                
       	// Query parent Accounts related to child Accounts with updated parent information for Account who's parent is updated
        for (Account lParentAcc : [SELECT Id, ParentId, OwnerId FROM Account WHERE Id IN :parentIdsSet]) {
            // Populate mapChildIdOwnerId with Child Account Id as key and updated parent Owner Id as value
        	mapChildIdOwnerId.put(lParentAcc.Id, lParentAcc.OwnerId);    
        }
        
        // Create AccountTeamMember records for child Accounts with updated parent information
        for (Account key : [SELECT Id, ParentId FROM Account WHERE ParentId IN :parentIdsSet]) {
        	AccountTeamMember createAccTeam = new AccountTeamMember();
            createAccTeam.AccountId = key.Id;
            createAccTeam.UserId = mapChildIdOwnerId.get(key.ParentId);
            createAccTeam.TeamMemberRole = 'National Accts Manager';
            lAcctTeamToCreate.add(createAccTeam);
        }
        
        // Create AccountTeamMember records for child Accounts with updated owner information
        for (Account lChildAcc : [SELECT Id, ParentId FROM Account WHERE ParentId IN :mapParentIdOwnerId.keySet()]) {
            AccountTeamMember createAccTeam = new AccountTeamMember();
            createAccTeam.AccountId = lChildAcc.Id;
            createAccTeam.UserId = mapParentIdOwnerId.get(lChildAcc.ParentId);
            createAccTeam.TeamMemberRole = 'National Accts Manager';
            
            lAcctTeamToCreate.add(createAccTeam);
        	listChildId.add(lChildAcc.Id);    
        }
        
        // Query existing AccountTeamMember records for child Accounts
		List<AccountTeamMember> listAcctTeams = new List<AccountTeamMember>([SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember 
                                                                             WHERE AccountId IN :listChildId AND TeamMemberRole = 'National Accts Manager']);
        	
        // Populate list lAcctTeamToDelete with AccountTeamMember records to be deleted
        for (AccountTeamMember accTeam : listAcctTeams) {
        	AccountTeamMember deleteAccTeam = new AccountTeamMember();
            deleteAccTeam.Id = accTeam.Id;
                    
        	lAcctTeamToDelete.add(deleteAccTeam);    
        }  

		// Prepare parent Account records for update by setting Is_Owner_Updated__c to false        
        for (Id upOwnerAcc : mapParentIdOwnerId.keySet()) {
            Account updateAccount = new Account();
            updateAccount.Id = upOwnerAcc;
            updateAccount.Is_Owner_Updated__c = false;
            
            lAcctParentToUpdate.add(updateAccount); 
        }
        
        // Prepare child Account records for update by setting Is_Parent_Updated__c to false
        for (Account upChildAcc : lAcctChildForUpdate) {
            Account updateAccount = new Account();
            updateAccount.Id = upChildAcc.Id;
            updateAccount.Is_Parent_Updated__c = false;
            
            lAcctChildToUpdate.add(updateAccount); 
        }
        
        if (!lAcctTeamToDelete.IsEmpty()) { 
            delete lAcctTeamToDelete;
        }
        
        if (!lAcctTeamToCreate.IsEmpty()) {
            insert lAcctTeamToCreate;
        }
        
        if (!lAcctParentToUpdate.IsEmpty()) {
        	update lAcctParentToUpdate;     
        }
        
        if (!lAcctChildToUpdate.IsEmpty()) {
        	update lAcctChildToUpdate;     
        }
        
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}
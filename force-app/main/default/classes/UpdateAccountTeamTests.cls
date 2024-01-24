@isTest
private class UpdateAccountTeamTests {

    static testMethod void insertShipTo() {
        Account account = new Account(Name='An Account');
        insert account;
        
        Ship_To__c shipTo = new Ship_To__c(Account_Owner__c = UserInfo.getUserId(),
        								   Bill_To_Account__c = account.Id);
        insert shipTo;
        
        List<AccountTeamMember> atms = [select AccountId, UserId, TeamMemberRole 
	        						from AccountTeamMember
	        						where AccountId = :account.Id 
	        						and UserId = :UserInfo.getUserId()];
	        						
        System.assertEquals(1, atms.size());
        System.assertEquals(account.Id, atms[0].AccountId);
        System.assertEquals(UserInfo.getUserId(), atms[0].UserId);
        System.assertEquals('Ship To - Sales Rep', atms[0].TeamMemberRole);
    }
        
    static testMethod void updateShipTo() {
        Account account = new Account(Name='An Account');
        insert account;
         Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        List<User> users = [select Id from User where IsActive = true AND ProfileId =: p.Id limit 2];
        System.debug('====== '+users);
        Ship_To__c shipTo = new Ship_To__c(Account_Owner__c=users[0].Id, 
        								   Bill_To_Account__c=account.Id);
        insert shipTo;
        
        List<AccountTeamMember> atms = [select AccountId, UserId, TeamMemberRole 
	        						from AccountTeamMember
	        						where AccountId = :account.Id 
	        						and UserId = :users[0].Id];
	        						
        System.assertEquals(1, atms.size());
        System.assertEquals(account.Id, atms[0].AccountId);
        System.assertEquals(users[0].Id, atms[0].UserId);
        System.assertEquals('Ship To - Sales Rep', atms[0].TeamMemberRole);
        
        Test.startTest();						
        shipTo.Account_Owner__c = users[1].Id;
        
        update shipTo;
        
        Test.stopTest();
        atms = [select AccountId, UserId, TeamMemberRole 
	        						from AccountTeamMember
	        						where AccountId = :account.Id 
	        						and UserId = :users[1].Id];
	        						
        System.assertEquals(1, atms.size());
        System.assertEquals(account.Id, atms[0].AccountId);
        System.assertEquals(users[1].Id, atms[0].UserId);
        System.assertEquals('Ship To - Sales Rep', atms[0].TeamMemberRole);        
    }
    
    static testMethod void addATM_Role() {
        Account account = new Account(Name='An Account');
        insert account;
         Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        List<User> users = [select Id from User where IsActive = true AND ProfileId =: p.Id limit 2];
        
        Ship_To__c shipTo = new Ship_To__c(Account_Owner__c=users[0].Id, 
        								   Bill_To_Account__c=account.Id);
        insert shipTo;
        
        List<AccountTeamMember> atms = [select AccountId, UserId, TeamMemberRole 
	        						from AccountTeamMember
	        						where AccountId = :account.Id 
	        						and UserId = :users[0].Id];
	        						
        System.assertEquals(1, atms.size());
        System.assertEquals(account.Id, atms[0].AccountId);
        System.assertEquals(users[0].Id, atms[0].UserId);
        System.assertEquals('Ship To - Sales Rep', atms[0].TeamMemberRole);
        
        
        AccountTeamMember a2u = atms[0];
        a2u.TeamMemberRole = 'Test - Executive';
        update a2u;
        
        Test.startTest();
        Ship_To__c shipTo2 = new Ship_To__c(Account_Owner__c=users[0].Id, 
        								   Bill_To_Account__c=account.Id);
        								   
		insert shipTo2;
        
        Test.stopTest();
        
        atms = [select AccountId, UserId, TeamMemberRole 
				from AccountTeamMember
				where AccountId = :account.Id 
				and UserId = :users[0].Id];
	        						
        System.assertEquals(1, atms.size());
        System.assertEquals(account.Id, atms[0].AccountId);
        System.assertEquals(users[0].Id, atms[0].UserId);
        System.assertEquals('Test - Executive', atms[0].TeamMemberRole);
    }
    
    static testMethod void updateATM_Role() {
        Account account = new Account(Name='An Account');
        insert account;
         Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        List<User> users = [select Id from User where IsActive = true AND ProfileId =: p.Id limit 2];
        
        Ship_To__c shipTo = new Ship_To__c(Account_Owner__c=users[0].Id, 
        								   Bill_To_Account__c=account.Id);
        insert shipTo;
        
        List<AccountTeamMember> atms = [select AccountId, UserId, TeamMemberRole 
	        						from AccountTeamMember
	        						where AccountId = :account.Id 
	        						and UserId = :users[0].Id];
	        						
        System.assertEquals(1, atms.size());
        System.assertEquals(account.Id, atms[0].AccountId);
        System.assertEquals(users[0].Id, atms[0].UserId);
        System.assertEquals('Ship To - Sales Rep', atms[0].TeamMemberRole);
        
        AccountTeamMember a2u = atms[0];
        a2u.TeamMemberRole = 'Test - Executive';
        update a2u;
        
        Test.startTest();
        shipTo.Comments__c = 'foo';
        update shipTo;
        
        
        Test.stopTest();
        atms = [select AccountId, UserId, TeamMemberRole 
				from AccountTeamMember
				where AccountId = :account.Id 
				and UserId = :users[0].Id];
	        						
        System.assertEquals(1, atms.size());
        System.assertEquals(account.Id, atms[0].AccountId);
        System.assertEquals(users[0].Id, atms[0].UserId);
        System.assertEquals('Test - Executive', atms[0].TeamMemberRole);
    }
}
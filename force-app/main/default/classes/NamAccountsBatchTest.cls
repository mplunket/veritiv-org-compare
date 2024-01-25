@isTest
public class NamAccountsBatchTest {
    @testSetup static void setup() {
        
        User u = new User(
            Alias = 'userNAM',
            Email='testuser@test.com',
            EmailEncodingKey='UTF-8',
            LastName='LastName',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userNAM@test.com',
            Country='USA',
            Network_Id__c  = 'userNAM',
            IsActive = true
        );
        insert u;

         System.RunAs(u) {
            List<Account> ListParentAccounts = new List<Account>();
             
             Account accRecord = new Account();
             accRecord.name = 'Parent Account';
             accRecord.Active__c = 'Yes';
             insert accRecord;
            for (Integer i = 0; i < 2; i++) {
                Account acc = new Account();
                acc.name = 'Test Parent ' + i;
                acc.Active__c = 'Yes';
                ListParentAccounts.add(acc);            
            }
            insert ListParentAccounts;
        	
            List<Account> ListChildtAccounts = new List<Account>();
            for (Integer i = 0; i < 4; i++) {
                Account acc = new Account();
                acc.name = 'Test Child ' + i;
                acc.Active__c = 'Yes';
                acc.OwnerId = u.id;
                acc.Parent_Id__c = accRecord.id;
                ListChildtAccounts.add(acc);
            }
            insert ListChildtAccounts;
             
            for (Integer i = 0; i < ListChildtaccounts.size(); i++) {
                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountId = ListChildtAccounts[i].Id;
                atm.UserId = u.id;
                atm.TeamMemberRole = 'National Accts Manager';
                insert atm;    
        	}
        }
        
    }
    
    @isTest static void testBatchClass() {
        User u = new User(
            Alias = 'userNAM2',
            Email='testuser2@test.com',
            EmailEncodingKey='UTF-8',
            LastName='LastName2',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userNAM2@test.com',
            Country='USA',
            Network_Id__c  = 'userNAM2',
            IsActive = true
        );
        insert u;
        
        System.RunAs(u) {
            List<Account> lParentAcc = [SELECT Id, Name, OwnerId FROM Account WHERE Name = 'Parent Account' LIMIT 1];
            List<Account> lParentToUpdate = new List<Account>();
            
            for (Account acc : lParentAcc) {
                Account a = new Account();
                a.Id = acc.Id;
                a.OwnerId = u.Id;
                lParentToUpdate.add(a);
            }
            
            update lParentToUpdate;
            System.debug('lParentToUpdate......'+lParentToUpdate);
            System.debug('lParentToUpdate......'+ [select id, Active__c, Owner.IsActive, Is_Owner_Updated__c, Is_Parent_Updated__c from account where id = :lParentToUpdate[0].Id LIMIT 1]);
        }
        Test.startTest();
        NAMAccountsBatch batch = new NAMAccountsBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Assert that the batch job completed successfully
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'NAMAccountsBatch'];
        System.assertEquals(1, jobs.size());
        System.assertEquals('Completed', jobs[0].Status);
        
    }
    
    @isTest static void testBatchClass2() {
        User u = new User(
            Alias = 'userNAM2',
            Email='testuser2@test.com',
            EmailEncodingKey='UTF-8',
            LastName='LastName2',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey='America/Los_Angeles',
            UserName='userNAM2@test.com',
            Country='USA',
            Network_Id__c  = 'userNAM2',
            IsActive = true
        );
        insert u;
        
        System.RunAs(u) {
            List<Account> lParentAcc = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name LIKE 'Test Parent%' LIMIT 1];
            List<Account> childAcc = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name LIKE 'Test Child%' LIMIT 1];
            List<Account> lChildToUpdate = new List<Account>();
            
            for (Account acc : childAcc) {
                Account a = new Account();
                a.Id = acc.Id;
                a.ParentId = lParentAcc[0].Id;
                lChildToUpdate.add(a);
            }
            
            update lChildToUpdate;
            System.debug('lParentToUpdate......'+lChildToUpdate);
            System.debug('lParentToUpdate......'+ [select id, Active__c, Owner.IsActive, Is_Owner_Updated__c, Is_Parent_Updated__c from account where id = :lChildToUpdate[0].Id LIMIT 1]);
        }
        Test.startTest();
        NAMAccountsBatch batch = new NAMAccountsBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Assert that the batch job completed successfully
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'NAMAccountsBatch'];
        System.assertEquals(1, jobs.size());
        System.assertEquals('Completed', jobs[0].Status);
        
    }
}
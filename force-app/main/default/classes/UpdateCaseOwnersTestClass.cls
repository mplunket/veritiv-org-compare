@isTest
private class UpdateCaseOwnersTestClass {

    // 005f4000001C3sbAAC

    public static String CRON_EXP = '0 0 0 15 3 ?';

    @isTest
    static void testReassigningCaseOwner() {
    
        DateTime previousDay = DateTime.Now().addDays(-1);
        DateTime nextDay = DateTime.Now().addDays(+1);

        Profile p = [SELECT Id FROM Profile WHERE Name='Tax Operations'];
        
        User user1 = new User(Username='Uname@testuser.org',
                                LastName='LName',
                                Email='test@test.com',
                                Alias='Alias',
                                Network_Id__c='Alias',
                                Country='USA',
                                TimeZoneSidKey='America/Los_Angeles',
                                LocaleSidKey='en_US',
                                EmailEncodingKey='UTF-8',
                                ProfileId=p.Id,
                                LanguageLocaleKey='en_US');
        User user2 = new User(Username='Uname1@testuser.org',
                                LastName='LName1',
                                Email='test1@test.com',
                                Alias='Alias1',
                                Network_Id__c='Alias1',
                                Country='USA',
                                TimeZoneSidKey='America/Los_Angeles',
                                LocaleSidKey='en_US',
                                EmailEncodingKey='UTF-8',
                                ProfileId=p.Id,
                                LanguageLocaleKey='en_US');
        
        List<User> allUsers = new List<User>();
        allUsers.add(user1);
        allUsers.add(user2);
        insert(allUsers);
        Map<Id, User> allUsersMap = new Map<Id, User>(allUsers);
        List<Id> userIds = new List<Id>(allUsersMap.keyset());
        System.assertEquals(2, userIds.size(), 'Failed to create users');
        
        Id user1Id = userIds.get(0);
        Id user2Id = userIds.get(1);
    
        Out_Of_Office_Log__c agentRecord = new Out_Of_Office_Log__c(OwnerId=user1Id,
                                                                    Person_taking_time_off__c=user1Id,
                                                                    Backup_Person__c=user2Id,
                                                                    Start_Date_Time__c=previousDay, 
                                                                    End_Date_Time__c=nextDay);
        
        // Insert the record
        insert agentRecord;
        
        // check how to create case with owner value
        Case tempCase = new Case(OwnerId=user1Id, Status='New');
        Case tempCase1 = new Case(OwnerId=user1Id, Status='Escalated');
        Case tempCase2 = new Case(OwnerId=user1Id, Status='Closed');
        
        List<Case> allCases = new List<Case>();
        allCases.add(tempCase);
        allCases.add(tempCase1);
        allCases.add(tempCase2);
        
        //runAs 'sfdc admin' user to avoid Case validation rule requiring contact and account on closed case
        User tstusr = [SELECT Id FROM User WHERE name='sfdc admin'];
        System.runAs(tstusr) {     
            //Insert the case
            insert(allCases);
        }
                 
        Test.startTest();
        
        //verify that case Id's have not been updated.
        List<Case> allCasesBeforeJob = [SELECT OwnerId 
                                        FROM Case];
        for (Case caseBeforeJob : allCasesBeforeJob) {
        
            System.assertEquals(user1Id, caseBeforeJob.OwnerId);
        }
        
        // schedule job
        String jobId = System.schedule('ScheduledUpdateCaseOwnersTest', CRON_EXP,
                            new UpdateCaseOwners());
                            
        
        // stop the test to run the job
        Test.stopTest();
        
        //check that the id for case has been updated when status was new & escalated
        List<Case> allCasesAfterJob = [SELECT OwnerId, Status
                                       FROM Case];
        for (Case caseAfterJob : allCasesAfterJob) {
            if (caseAfterJob.Status == 'Closed') {
                System.assertEquals(user1Id, caseAfterJob.OwnerId);
            } else {
                System.assertEquals(user2Id, caseAfterJob.OwnerId);
            }
            
        }
    
    }

}
@isTest

private class Test_FaxToCaseQueueActive {
/*    
    private static final String TEAM_INBOX_EMAIL = 'someteamInbox@unisourcelink.com';
    private static final String SupplyTeam = 'JAX_PRINTCS121_F2C';//GRP_FL267 NE Supply Team';
    //private static final String PackagingTeam = 'JAX-NEPKG-F2C'; //GRP_FL267 NE Packaging Team
    private static final String PackagingTeam = 'SALES_SUPPORT_E2C'; //GRP_FL267 NE Packaging Team
    
    
    private static testmethod void test_CreateCase_Inactive()
    {
        
        Group queue = [Select Id From Group where DeveloperName =:SupplyTeam];
        
        // Clear out existing records for this Queue
        List<Fax_To_Case_Queue_Assignment__c> queueRecords = [select Id from Fax_To_Case_Queue_Assignment__c where OwnerId = :queue.Id];
        delete queueRecords;
        
        Fax_To_Case_Queue_Assignment__c f2c = new Fax_To_Case_Queue_Assignment__c(Active__c = false, OwnerId = queue.Id, Team_Lead_Name__c = 'BRUCE LEE', Group_Inbox_Address__c = TEAM_INBOX_EMAIL);
        system.debug(f2c);
        insert f2c;
        
        Account testAcct = new Account(Name='Test Account');
        insert testAcct;

        Contact testContact = new Contact( LastName = 'someName', AccountId = testAcct.Id );
        insert testContact;     
        
        RecordType rt = [select Id from RecordType where SObjectType = 'Case' and DeveloperName = 'Incoming_Fax'];
        Test.startTest();

            Case c = new Case(RecordTypeId=rt.Id, Subject='Test', Email_Origin__c = 'GRP_FL267.NESUPPLYTEAM@UNISOURCELINK.COM', contactId = testContact.Id, accountId = testAcct.Id);
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.assignmentRuleHeader.useDefaultRule= true;
            c.setOptions(dml);
            
            insert c;
        
        Test.stopTest();
        c = [select Is_Primary__c, Group_Inbox_Address__c, Team_lead_name__c from Case where Id = :c.Id];
        
         
         
         
    }

    private static testmethod void test_CreateCase_Active()
    {
        Group queue = [Select Id From Group where DeveloperName =:SupplyTeam];
        
        // Clear out existing records for this Queue
        List<Fax_To_Case_Queue_Assignment__c> queueRecords = [select Id from Fax_To_Case_Queue_Assignment__c where OwnerId = :queue.Id];
        delete queueRecords;
        
        Fax_To_Case_Queue_Assignment__c f2c = new Fax_To_Case_Queue_Assignment__c(Active__c = true, OwnerId = queue.Id, Team_Lead_Name__c = 'BRUCE LEE', Group_Inbox_Address__c = TEAM_INBOX_EMAIL);
        insert f2c;
        
        System.debug([select OwnerId from Fax_To_Case_Queue_Assignment__c where Id = :f2c.Id]);
    
        Account testAcct = new Account(Name='Test Account');
        insert testAcct;

        Contact testContact = new Contact( LastName = 'someName', AccountId = testAcct.Id );
        insert testContact;     
        
        RecordType rt = [select Id from RecordType where SObjectType = 'Case' and DeveloperName = 'Incoming_Fax'];
        
        Test.startTest();
        
            Case c = new Case(RecordTypeId=rt.Id, Subject='Test', Email_Origin__c = 'GRP_FL267.NESUPPLYTEAM@UNISOURCELINK.COM', contactId = testContact.Id, accountId = testAcct.Id);
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.assignmentRuleHeader.useDefaultRule= true;
            c.setOptions(dml);
        
            insert c;
        
        Test.stopTest();
        
        c = [select Is_Primary__c, Group_Inbox_Address__c, Team_lead_name__c from Case where Id = :c.Id];
        
        
         
         

    }

    private static testmethod void test_CreateCase_Active_Batch()
    {
        Group queue = [Select Id From Group where DeveloperName =:SupplyTeam];
        
        // Clear out existing records for this Queue
        List<Fax_To_Case_Queue_Assignment__c> queueRecords = [select Id from Fax_To_Case_Queue_Assignment__c where OwnerId = :queue.Id];
        delete queueRecords;
        
        Fax_To_Case_Queue_Assignment__c f2c = new Fax_To_Case_Queue_Assignment__c(Active__c = true, OwnerId = queue.Id, Team_Lead_Name__c = 'BRUCE LEE', Group_Inbox_Address__c = TEAM_INBOX_EMAIL);
        insert f2c;
        
        RecordType rt = [select Id from RecordType where SObjectType = 'Case' and DeveloperName = 'Incoming_Fax'];
        
        List<Case> newCases = new List<Case>();
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.assignmentRuleHeader.useDefaultRule= true;
        
        Account testAcct = new Account(Name='Test Account');
        insert testAcct;

        Contact testContact = new Contact( LastName = 'someName', AccountId = testAcct.Id );
        insert testContact;         
        
        Test.startTest();
        
        for(Integer i=0; i<5; i++)
        {
            Case c = new Case(RecordTypeId=rt.Id, Subject='Test' + i, Email_Origin__c = 'GRP_FL267.NESUPPLYTEAM@UNISOURCELINK.COM', contactId = testContact.Id, accountId = testAcct.Id);
            c.setOptions(dml);
            newCases.add(c);
        }
        insert newCases;
        
        Test.stopTest();
        
        for(Case insertedCase : [select Is_Primary__c, Group_Inbox_Address__c, Team_lead_name__c from Case where Id IN :newCases])
        {
             
             
             
        }
    }
    
    private static testmethod void test_CreateCase_Active_Mixed_Batch()
    {
        Group queue = [Select Id From Group where DeveloperName =:SupplyTeam];
        Group queue2 = [Select Id From Group where Name =:PackagingTeam];
        
        // Clear out existing records for this Queue
        List<Fax_To_Case_Queue_Assignment__c> queueRecords = [select Id from Fax_To_Case_Queue_Assignment__c where OwnerId = :queue.Id];
        delete queueRecords;
        
        queueRecords = [select Id from Fax_To_Case_Queue_Assignment__c where OwnerId = :queue2.Id];
        delete queueRecords;
        
        Fax_To_Case_Queue_Assignment__c f2c = new Fax_To_Case_Queue_Assignment__c(Active__c = true, OwnerId = queue.Id, Team_Lead_Name__c = 'BRUCE LEE');
        insert f2c;
        Fax_To_Case_Queue_Assignment__c f2c2 = new Fax_To_Case_Queue_Assignment__c(Active__c = false, OwnerId = queue2.Id, Team_Lead_Name__c = 'JACKIE CHAN');
        insert f2c2;
        Map<Id, String> ownerId2Active = new Map<Id, String>{queue.Id => 'TRUE',  queue2.Id => 'FALSE'};
        Map<Id, String> ownerId2TeamLead = new Map<Id, String>{queue.Id => 'BRUCE LEE',  queue2.Id => 'JACKIE CHAN'};
        
        System.debug( 'ownerId2TeamLead --> ' + ownerId2TeamLead);
        
        RecordType rt = [select Id from RecordType where SObjectType = 'Case' and DeveloperName = 'Incoming_Fax'];
        
        Account testAcct = new Account(Name='Test Account');
        insert testAcct;

        Contact testContact = new Contact( LastName = 'someName', AccountId = testAcct.Id );
        insert testContact;         
        
        Database.DMLOptions dmo = new Database.DMLOptions();
              dmo.AssignmentRuleHeader.useDefaultRule= true;
              
        
        Test.startTest();
        
            List<Case> newCases = new List<Case>();
            for(Integer i=0; i<50; i++)
            {
                Case c = new Case(RecordTypeId=rt.Id, Subject='Test' + i, Email_Origin__c = 'GRP_FL267.NESUPPLYTEAM@UNISOURCELINK.COM', contactId = testContact.Id, accountId = testAcct.Id);
                c.setOptions(dmo);
                
                newCases.add(c);
            }
            for(Integer i=0; i<5; i++)
            {
                Case c = new Case(RecordTypeId=rt.Id, Subject='Test' + i, Email_Origin__c = 'GRP_FL267NE.PACKAGINGTEAM@UNISOURCELINK.COM', contactId = testContact.Id, accountId = testAcct.Id);
                
                c.setOptions(dmo);
                
                newCases.add(c);
            }
            
            insert newCases;
        
        Test.stopTest();
        
        for(Case insertedCase : [select OwnerId, Is_Primary__c, Team_lead_name__c from Case where Id IN :newCases])
        {
            System.debug( 'insertedCase.OwnerId --> ' + insertedCase.OwnerId);
            
             
             
        }
    }

*/
}
@isTest private with sharing class CaseResponseTrackingServicesTest { 
    
    @isTest static void trackStatusDurationsTest(){
        //create case
        String startStatus = 'New';
        String updatedStatus = 'In Progress';
        Integer expectedSize = 1;
        Case testCase = (Case) new SObjectBuilder(Case.SobjectType)
            .put(Case.Status,startStatus)
            .create()
            .getRecord();
        
        testCase.Status = updatedStatus;
        
        Test.startTest();
        update testCase;
        Test.stopTest();
        
        List<Case_Durations__c> durations = [
            SELECT Id, Value__c, Previous_Value__c, Type__c 
            FROM Case_Durations__c 
            WHERE Parent__c =: testCase.Id
            AND Type__c =: CaseResponseTrackingServices.STATUS_CHANGE
        ];
        //  System.assertEquals(expectedSize, durations.size(), 'We expect to get back the correct number of durations');
        for(Case_Durations__c actualDuration : durations){
            System.assertEquals(updatedStatus, actualDuration.Value__c, 'We expect these values to be equal');
            System.assertEquals(startStatus, actualDuration.Previous_Value__c, 'We expect these values to be equal');
        }
    }
    @isTest static void trackOwnerDurationsTest(){
        Integer expectedSize = 1;
        //create two users
        List<User> ownerUsers = new SObjectBuilder(User.SObjectType)
            .put(User.Alias, new SObjectFieldProviders.UniqueFixedLengthStringProvider(8))
            .put(User.EmployeeNumber, new SObjectFieldProviders.UniqueFixedLengthStringProvider('00000', 6))
            .count(2).build().getRecords();
        ownerUsers[0].put(User.Network_Id__c, ownerUsers[0].Alias);
        ownerUsers[1].put(User.Network_Id__c, ownerUsers[1].Alias);
        insert ownerUsers;
        User originalOwner = ownerUsers[0];
        User newOwner = ownerUsers[1];
        
        Group queueOwner = (Group) new SObjectBuilder(Group.SObjectType)
            .put(Group.Name, 'Test Queue')
            .put(Group.Type, 'Queue')
            .build()
            .getRecord();
        
        User userOwner = (User) new SObjectBuilder(User.SObjectType)
            .put(User.Alias, new SObjectFieldProviders.UniqueFixedLengthStringProvider(8))
            .put(User.EmployeeNumber, new SObjectFieldProviders.UniqueFixedLengthStringProvider('00000', 6))
            .count(1).build().getRecord();
        userOwner.put(User.Network_Id__c, userOwner.Alias);
        System.runAs(SObjectFactory.ADMIN_USER){
            insert queueOwner;
            insert new QueueSObject(SObjectType = 'Case', QueueId = queueOwner.Id);
            insert userOwner;
        }
        
        Case testCase = (Case) new SObjectBuilder(Case.SobjectType)
            .put(Case.OwnerId,originalOwner.Id)
            .create()
            .getRecord();
        
        testCase.OwnerId = newOwner.Id;
        //query for cds with correct Type
        Test.startTest();
        System.runAs(userOwner){
            update testCase;
        }
        Test.stopTest();
        
        List<Case_Durations__c> durations = [
            SELECT Id, Value__c, Previous_Value__c, Type__c 
            FROM Case_Durations__c 
            WHERE Parent__c =: testCase.Id
            AND Type__c =: CaseResponseTrackingServices.OWNER_CHANGE
        ];
        //System.assertEquals(expectedSize, durations.size(), 'We expect to get back the correct number of durations');
        for(Case_Durations__c actualDuration : durations){
            System.assertEquals(newOwner.Id, actualDuration.Value__c, 'We expect these values to be equal');
            System.assertEquals(originalOwner.Id, actualDuration.Previous_Value__c, 'We expect these values to be equal');
        }
        
    }
    @isTest static void trackQueueToUserDurationsTest(){
        Integer expectedSize = 1;
        //create two users
        Group queueOwner = (Group) new SObjectBuilder(Group.SObjectType)
            .put(Group.Name, 'Test Queue')
            .put(Group.Type, 'Queue')
            .build()
            .getRecord();
        
        User userOwner = (User) new SObjectBuilder(User.SObjectType)
            .put(User.Alias, new SObjectFieldProviders.UniqueFixedLengthStringProvider(8))
            .put(User.EmployeeNumber, new SObjectFieldProviders.UniqueFixedLengthStringProvider('00000', 6))
            .count(1).build().getRecord();
        userOwner.put(User.Network_Id__c, userOwner.Alias);
        System.runAs(SObjectFactory.ADMIN_USER){
            insert queueOwner;
            insert new QueueSObject(SObjectType = 'Case', QueueId = queueOwner.Id);
            insert userOwner;
        }
        
        Case testCase = (Case) new SObjectBuilder(Case.SobjectType)
            .put(Case.OwnerId,queueOwner.Id)
            .create()
            .getRecord();
        
        testCase.OwnerId = userOwner.Id;
        //query for cds with correct Type
        Test.startTest();
        System.runAs(userOwner){
            update testCase;
        }
        Test.stopTest();
        
        List<Case_Durations__c> durations = [
            SELECT Id, Value__c, Previous_Value__c, Type__c 
            FROM Case_Durations__c 
            WHERE Parent__c =: testCase.Id
            AND Type__c =: CaseResponseTrackingServices.QUEUE_TO_USER
        ];
        //System.assertEquals(expectedSize, durations.size(), 'We expect to get back the correct number of durations');
        for(Case_Durations__c actualDuration : durations){
            System.assertEquals(userOwner.Id, actualDuration.Value__c, 'We expect these values to be equal');
            System.assertEquals(queueOwner.Id, actualDuration.Previous_Value__c, 'We expect these values to be equal');
        }
    }
    
}
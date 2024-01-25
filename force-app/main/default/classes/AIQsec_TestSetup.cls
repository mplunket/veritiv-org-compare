@IsTest
public with sharing class AIQsec_TestSetup {

    @testSetup
    public static void setConfig(){
        
        AIQZilliantConfiguration__c customConfig = new  AIQZilliantConfiguration__c (BatchJobSize__c = 200);
        upsert customConfig;

        Profile sup = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Profile sap = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User usr = new User(
            Username = 'ztest@zilliant.com',
            LastName = 'ZTest', 
            email='ztest@zilliant.com', 
            Country='USA', 
            Alias='ztest', 
            Network_Id__c = 'ztest', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            localeSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = sup.id, 
            LanguageLocaleKey = 'en_US');
        
        User usr2 = new User(
            Username = 'ztest2@zilliant.com',
            LastName = 'ZTest2', 
            email='ztest2@zilliant.com', 
            Country='USA', 
            Alias='ztest2', 
            Network_Id__c = 'ztest2', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            localeSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = sap.id, 
            LanguageLocaleKey = 'en_US');
        
        List<User> usrs = new List<User>{usr, usr2};
        insert usrs;

        List<AIQZilliantPermissionsConfig__c> secConfigList = new List<AIQZilliantPermissionsConfig__c>();

        secConfigList.add( 
            new AIQZilliantPermissionsConfig__c(
                AssignmentGroupName__c = 'Standard User'
                , AssignmentGroupType__c = 'Profile'
                , PermissionSetsToAssign__c = 'Zilliant AIQ Security Manager \r\n Zilliant Platform User'
                , PermissionSetsToUnassign__c = 'Zilliant Platform Administrator \r\n Zilliant Price Lookup Administrator'
                , IsActivated__c = true
            )
        );
        secConfigList.add( 
            new AIQZilliantPermissionsConfig__c(
                AssignmentGroupName__c = 'System Administrator'
                , AssignmentGroupType__c = 'Profile'
                , PermissionSetsToAssign__c = 'Zilliant AIQ Security Manager \r\n Zilliant Platform User'
                , PermissionSetsToUnassign__c = 'Zilliant Platform Administrator \r\n Zilliant Price Lookup Administrator'
                , IsActivated__c = true
            )
        );
        secConfigList.add( 
            new AIQZilliantPermissionsConfig__c(
                AssignmentGroupName__c = 'ZilliantTestRole'
                , AssignmentGroupType__c = 'UserRole'
                , PermissionSetsToAssign__c = 'Zilliant AIQ Security Manager \r\n Zilliant Platform User'
                , PermissionSetsToUnassign__c = 'Zilliant Platform Administrator \r\n Zilliant Price Lookup Administrator '
                , IsActivated__c = true
            )
        );
        insert secConfigList;

    }
}
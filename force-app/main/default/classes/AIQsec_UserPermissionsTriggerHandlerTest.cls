@isTest
public with sharing class AIQsec_UserPermissionsTriggerHandlerTest {
    /*
* This method prepares the test data of this class.
*/
    @testSetup
    public static void prepareConfig(){
        AIQsec_TestSetup.setConfig();
    }
    
    
    @isTest
    static void testAddNewUser(){
        Test.startTest();
        Profile sap = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr3 = new User(
            Username = 'ztest3@zilliant.com',
            LastName = 'Test3', 
            email='test3@zilliant.com', 
            Country='USA', 
            Alias='ztest3', 
            Network_Id__c = 'ztest3', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            localeSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = sap.id, 
            LanguageLocaleKey = 'en_US');
        
        insert usr3;
        
        PermissionSetAssignment psaUsrPs = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE Assignee.username = 'ztest3@zilliant.com' AND PermissionSet.Label ='Zilliant AIQ Security Manager'][0];
        System.assertEquals('Zilliant AIQ Security Manager', psaUsrPs.PermissionSet.Label);
        
        PermissionSetAssignment psaUsrPs2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE Assignee.username = 'ztest3@zilliant.com' AND PermissionSet.Label ='Zilliant Platform User'][0];
        System.assertEquals('Zilliant Platform User', psaUsrPs2.PermissionSet.Label);
        
        
        Test.stopTest();
    }
    
    @isTest
    static void testChangeUserProfile(){
        Test.startTest();
        User usr = [
            SELECT Id, ProfileId
            FROM User 
            WHERE Username = 'ztest@zilliant.com'][0];
        Profile sap = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        usr.ProfileId = sap.Id;
        update usr;
        
        PermissionSetAssignment psaUsrPs = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.Id AND PermissionSet.Label ='Zilliant AIQ Security Manager'][0];
        System.assertEquals('Zilliant AIQ Security Manager', psaUsrPs.PermissionSet.Label);
        
        PermissionSetAssignment psaUsrPs2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.Id AND PermissionSet.Label ='Zilliant Platform User'][0];
        System.assertEquals('Zilliant Platform User', psaUsrPs2.PermissionSet.Label);
        
        Test.stopTest();
    }
    
    @isTest
    static void testChangeUserRole(){
        Test.startTest();
        User usr = [
            SELECT Id, ProfileId, UserRoleId
            FROM User 
            WHERE Username = 'ztest@zilliant.com'][0];
        UserRole usrRole = AIQsec_TestDataFactory.createUserRole();
        usr.UserRoleId = usrRole.Id;
        update usr;
        
        PermissionSetAssignment psaUsrPs = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.Id AND PermissionSet.Label ='Zilliant AIQ Security Manager'][0];
        System.assertEquals('Zilliant AIQ Security Manager', psaUsrPs.PermissionSet.Label);
        
        PermissionSetAssignment psaUsrPs2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.Id AND PermissionSet.Label ='Zilliant Platform User'][0];
        System.assertEquals('Zilliant Platform User', psaUsrPs2.PermissionSet.Label);
        
        Test.stopTest();
    }
    
    @isTest
    static void testChangeUserProfileAssign(){
        Test.startTest();
        Profile cfup = [SELECT Id FROM Profile WHERE Name='Chatter Free User'];
        User usr4 = new User(
            Username = 'ztest4@zilliant.com',
            LastName = 'Test4', 
            email='test4@zilliant.com', 
            Country='USA', 
            Alias='ztest4', 
            Network_Id__c = 'ztest4', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            localeSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = cfup.id, 
            LanguageLocaleKey = 'en_US');
        
        insert usr4;
        
        List<PermissionSetAssignment> psaUsr4Ps0 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr4.Id AND PermissionSet.Label ='Zilliant AIQ Security Manager'];
        System.assertEquals(0, psaUsr4Ps0.size());
        
        List<PermissionSetAssignment> psaUsr4Ps20 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr4.Id AND PermissionSet.Label ='Zilliant Platform User'];
        System.assertEquals(0, psaUsr4Ps0.size());
        
        Profile sap = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        usr4.ProfileId = sap.Id;
        update usr4;
        
        PermissionSetAssignment psaUsrPs = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr4.Id AND PermissionSet.Label ='Zilliant AIQ Security Manager'][0];
        System.assertEquals('Zilliant AIQ Security Manager', psaUsrPs.PermissionSet.Label);
        
        PermissionSetAssignment psaUsrPs2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr4.Id AND PermissionSet.Label ='Zilliant Platform User'][0];
        System.assertEquals('Zilliant Platform User', psaUsrPs2.PermissionSet.Label);
        
        Test.stopTest();
    }
    
    @isTest
    static void testChangeUserProfileUnassign(){
        Test.startTest();
        Profile cfup = [SELECT Id FROM Profile WHERE Name='Read Only'];
        User usr = [
            SELECT Id, ProfileId, UserRoleId
            FROM User 
            WHERE Username = 'ztest2@zilliant.com'][0];
        List<PermissionSetAssignment> psaRecords = AIQsec_TestDataFactory.createPSARecords(); 
        PermissionSetAssignment psaUsrPs = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.Id AND PermissionSet.Label ='Zilliant Platform Administrator'][0];
        System.assertEquals('Zilliant Platform Administrator', psaUsrPs.PermissionSet.Label);
        
        PermissionSetAssignment psaUsrPs2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.Id AND PermissionSet.Label ='Zilliant Price Lookup Administrator'][0];
        System.assertEquals('Zilliant Price Lookup Administrator', psaUsrPs2.PermissionSet.Label);
        
        usr.ProfileId = cfup.Id;
        usr.UserRoleId = null;
        update usr;
        
        List<PermissionSetAssignment> psaUsr4Ps0 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.Id AND PermissionSet.Label ='Zilliant Platform Administrator'];
        System.assertEquals(0, psaUsr4Ps0.size());
        
        List<PermissionSetAssignment> psaUsr4Ps20 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.Id AND PermissionSet.Label ='Zilliant Price Lookup Administrator'];
        System.assertEquals(0, psaUsr4Ps0.size());
        
        Test.stopTest();
    }
    
    
}
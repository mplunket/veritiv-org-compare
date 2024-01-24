@IsTest
public with sharing class AIQsec_PermissionSetManagerTest {
    /*
    * This method prepares the test data of this class.
    */
    @testSetup
    public static void prepareConfig(){
        AIQsec_TestSetup.setConfig();
    }

    private static User usr {
        get {
            User usr = [
                SELECT Id
                FROM User 
                WHERE Username = 'ztest@zilliant.com'];
            return usr;
        } }

    private static User usr2 {
        get {
            User usr2 = [
                SELECT Id
                FROM User 
                WHERE Username = 'ztest2@zilliant.com' ];
            return usr2;
        } }

    private static PermissionSet ps {
        get {
            PermissionSet ps = [
                SELECT Id
                FROM PermissionSet 
                WHERE Label = 'Zilliant AIQ Security Manager' ];
            return ps;
        } }

    private static PermissionSet ps2 {
        get {
            PermissionSet ps2 = [
                SELECT Id
                FROM PermissionSet 
                WHERE Label = 'Zilliant Platform User' ];
            return ps2;
        } }

    @IsTest
    static void testGetConfigRecordsNotFound() {
        Test.startTest();
        try{
            AIQsec_PermissionSetManager psManger = new AIQsec_PermissionSetManager();
        }catch (Exception e){
            System.assertEquals('There Are No Permission Configurations', e.getMessage());
            System.assertEquals('AIQsec_PermissionSetManager.AIQPermissionConfigNotFoundException', e.getTypeName());
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetConfigRecords() {
        Test.startTest();
        List<PermissionSetAssignment> psaRecords = AIQsec_TestDataFactory.createPSARecords(); 

        AIQsec_PermissionSetManager psManger = new AIQsec_PermissionSetManager();
        System.assertEquals(4, psManger.permissionSetsMap.keySet().size());
        System.assertEquals(2, psManger.profileSecConfigMap.keySet().size());
        Test.stopTest();
    }

    @IsTest
    static void testGetConfigRecordsPlusRole() {
        Test.startTest();
        UserRole usrRole = AIQsec_TestDataFactory.createUserRole();
        AIQsec_PermissionSetManager psManger = new AIQsec_PermissionSetManager();
        System.assertEquals(4, psManger.permissionSetsMap.keySet().size());
        System.assertEquals(3, psManger.profileSecConfigMap.keySet().size());
        Test.stopTest();
        
    }

    @IsTest
    static void testAssignPermissions() {
        Test.startTest();
        List<PermissionSetAssignment> psaRecords = AIQsec_TestDataFactory.createPSARecords(); 
        UserRole usrRole = AIQsec_TestDataFactory.createUserRole();
        AIQsec_PermissionSetManager psManger = new AIQsec_PermissionSetManager();
        List<User> usrs = [SELECT Id, Name, username, ProfileId, UserRoleId, IsActive FROM User WHERE Id =: usr.id OR Id =: usr2.id ];
        for(User usr : usrs){usr.UserRoleId = usrRole.id;}
        psManger.assignPermissions(usrs);

        List<PermissionSetAssignment> psa3Usr = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.id and PermissionSet.Label = 'Zilliant Platform Administrator'];

        System.assertEquals(0, psa3Usr.size());

        List<PermissionSetAssignment> psa4Usr = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.id and PermissionSet.Label = 'Zilliant Price Lookup Administrator'];
        System.assertEquals(0, psa4Usr.size());

        List<PermissionSetAssignment> psa3Usr2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr2.id and PermissionSet.Label = 'Zilliant Platform Administrator'];

        System.assertEquals(0, psa3Usr2.size());

        List<PermissionSetAssignment> psa4Usr2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr2.id and PermissionSet.Label = 'Zilliant Price Lookup Administrator'];
        System.assertEquals(0, psa4Usr2.size());

        PermissionSetAssignment psa5Usr2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr2.id and PermissionSet.Label = 'Zilliant Administrator (Zilliant Price Lookup) (local)'][0];
        System.assertEquals('Zilliant Administrator (Zilliant Price Lookup) (local)', psa5Usr2.PermissionSet.Label);

        PermissionSetAssignment psaUsrPs = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.id AND PermissionSetId =: ps.id][0];
        System.assertEquals('ztest@zilliant.com', psaUsrPs.Assignee.username);
        System.assertEquals('Zilliant AIQ Security Manager', psaUsrPs.PermissionSet.Label);

        PermissionSetAssignment psaUsrPs2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.id AND PermissionSetId =: ps2.id][0];
        System.assertEquals('ztest@zilliant.com', psaUsrPs2.Assignee.username);
        System.assertEquals('Zilliant Platform User', psaUsrPs2.PermissionSet.Label);

        PermissionSetAssignment psaUsr2Ps = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr2.id AND PermissionSetId =: ps.id][0];
        System.assertEquals('ztest2@zilliant.com', psaUsr2Ps.Assignee.username);
        System.assertEquals('Zilliant AIQ Security Manager', psaUsr2Ps.PermissionSet.Label);

        PermissionSetAssignment psaUsr2Ps2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr2.id AND PermissionSetId =: ps2.id][0];
        System.assertEquals('ztest2@zilliant.com', psaUsr2Ps2.Assignee.username);
        System.assertEquals('Zilliant Platform User', psaUsr2Ps2.PermissionSet.Label);
        Test.stopTest();   

    }

    @IsTest
    static void testUnassignPermissions() {
        Test.startTest();
        List<PermissionSetAssignment> psaRecords = AIQsec_TestDataFactory.createPSARecords(); 
        UserRole usrRole = AIQsec_TestDataFactory.createUserRole();
        AIQsec_PermissionSetManager psManger = new AIQsec_PermissionSetManager();
        List<User> usrs = [SELECT Id, Name, username, ProfileId, UserRoleId, IsActive FROM User WHERE Id =: usr.id OR Id =: usr2.id];
        for(User usr : usrs){usr.UserRoleId = usrRole.id;}
        psManger.unassignPermissions(usrs);

        List<PermissionSetAssignment> psa3Usr = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.id and PermissionSet.Label = 'Zilliant Platform Administrator'];
        System.assertEquals(0, psa3Usr.size());

        List<PermissionSetAssignment> psa4Usr = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.id and PermissionSet.Label = 'Zilliant Price Lookup Administrator'];
        System.assertEquals(0, psa4Usr.size());

        List<PermissionSetAssignment> psa1Usr = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.id and PermissionSet.Label = 'Zilliant AIQ Security Manager'];
        System.assertEquals(0, psa1Usr.size());

        List<PermissionSetAssignment> psa2Usr = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr.id and PermissionSet.Label = 'Zilliant Platform User'];
        System.assertEquals(0, psa2Usr.size());

        List<PermissionSetAssignment> psa3Usr2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr2.id and PermissionSet.Label = 'Zilliant Platform Administrator'];
        System.assertEquals(0, psa3Usr2.size());

        List<PermissionSetAssignment> psa4Usr2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr2.id and PermissionSet.Label = 'Zilliant Price Lookup Administrator'];
        System.assertEquals(0, psa4Usr2.size());

        List<PermissionSetAssignment> psa1Usr2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr2.id and PermissionSet.Label = 'Zilliant AIQ Security Manager'];
        System.assertEquals(0, psa1Usr2.size());

        List<PermissionSetAssignment> psa2Usr2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr2.id and PermissionSet.Label = 'Zilliant Platform User'];
        System.assertEquals(0, psa2Usr2.size());

        PermissionSetAssignment psa5Usr2 = [
            SELECT Assignee.username, PermissionSet.Label 
            FROM PermissionSetAssignment 
            WHERE AssigneeId =: usr2.id and PermissionSet.Label = 'Zilliant Administrator (Zilliant Price Lookup) (local)'][0];
        System.assertEquals('Zilliant Administrator (Zilliant Price Lookup) (local)', psa5Usr2.PermissionSet.Label);
        Test.stopTest();
        
    }
}
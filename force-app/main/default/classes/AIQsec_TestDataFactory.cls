@isTest
public with sharing class AIQsec_TestDataFactory {

    public static List<PermissionSetAssignment> createPSARecords(){

        User usr = [SELECT Id FROM User WHERE Username = 'ztest@zilliant.com'];
        User usr2 = [SELECT Id FROM User WHERE Username = 'ztest2@zilliant.com'];

         // Creating the permission set
        PermissionSet permSet1 = [SELECT Id, name, label FROM PermissionSet WHERE Label='Zilliant AIQ Security Manager'];
        PermissionSet permSet2 = [SELECT Id, name, label FROM PermissionSet WHERE Label='Zilliant Platform User'];
        PermissionSet permSet3 = [SELECT Id, name, label FROM PermissionSet WHERE Label='Zilliant Platform Administrator'];
        PermissionSet permSet4 = [SELECT Id, name, label FROM PermissionSet WHERE Label='Zilliant Price Lookup Administrator'];
         PermissionSet permSet5 = [SELECT Id, name, label FROM PermissionSet WHERE Label='Zilliant Administrator (Zilliant Price Lookup) (local)'];
        
        //Assigning to the User
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId=usr.Id,PermissionSetId=permSet3.id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId=usr.Id,PermissionSetId=permSet4.id);
        PermissionSetAssignment psa5 = new PermissionSetAssignment(AssigneeId=usr.Id,PermissionSetId=permSet1.id);
        PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId=usr2.Id,PermissionSetId=permSet3.id);
        PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId=usr2.Id,PermissionSetId=permSet4.id);
        PermissionSetAssignment psa6 = new PermissionSetAssignment(AssigneeId=usr2.Id,PermissionSetId=permSet1.id);
        PermissionSetAssignment psa7 = new PermissionSetAssignment(AssigneeId=usr2.Id,PermissionSetId=permSet5.id);
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>{psa1, psa2, psa3, psa4, psa5, psa6, psa7};

        insert psas;
        return psas;
    }

    public static UserRole createUserRole(){

        UserRole usrRole = new UserRole(DeveloperName = 'ZilliantTestRole', Name = 'ZilliantTestRole');
        insert usrRole; 
        return usrRole;
    }
}
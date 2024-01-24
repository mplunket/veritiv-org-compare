/*
    Created by Haydar Hadi Oct 2, 2019
 */

@IsTest
public class CaseRoutingRecordTriggerTest {

    @IsTest
    public static void Test_OneCase() {

        Contact testContact = (Contact) SObjectFactory.build(Contact.SObjectType);
        testContact.Email = 'abc@gmail.com';
        insert testContact;

        ANI_Routing_Record__c rr = new ANI_Routing_Record__c();
        rr.ANI_Contact__c = testContact.Id;
        rr.Email_To_Address__c = 'abc@gmail.com';
        insert rr;

        Case testCase = (Case) SObjectFactory.build(Case.SObjectType);
        testCase.SuppliedEmail = 'abc@gmail.com';
        testCase.ToAddressRouting__c = 'abc@gmail.com';
        testCase.ContactId = testContact.Id;
        insert testCase;

        Case cs = [SELECT Id, Routing_Record__c FROM Case WHERE Id = :testCase.Id][0];

      //  System.assert(cs.Routing_Record__c!=null);
    }

    @IsTest
    public static void Test_TwoCases() {

        Contact c1 = (Contact) SObjectFactory.build(Contact.SObjectType);
        Contact c2 = (Contact) SObjectFactory.build(Contact.SObjectType);
        c1.Email = 'abc1@gmail.com';
        c2.Email = 'abc2@gmail.com';
        insert new List<Contact>{c1, c2};

        ANI_Routing_Record__c rr1 = new ANI_Routing_Record__c();
        ANI_Routing_Record__c rr2 = new ANI_Routing_Record__c();
        rr1.ANI_Contact__c = c1.Id;
        rr1.Email_To_Address__c = 'abc1@gmail.com';
        rr2.ANI_Contact__c = c2.Id;
        rr2.Email_To_Address__c = 'abc2@gmail.com';
        insert new List<ANI_Routing_Record__c>{rr1, rr2};

        Case cs1 = (Case) SObjectFactory.build(Case.SObjectType);
        Case cs2 = (Case) SObjectFactory.build(Case.SObjectType);
        cs1.SuppliedEmail = 'abc1@gmail.com';
        cs1.ToAddressRouting__c = 'abc1@gmail.com';
        cs1.ContactId = c1.Id;
        cs2.SuppliedEmail = 'abc2@gmail.com';
        cs2.ToAddressRouting__c = 'abc2@gmail.com';
        cs2.ContactId = c2.Id;
        insert new List<Case>{cs1, cs2};

        List<Case> cases = [SELECT Id, Routing_Record__c FROM Case WHERE Id IN (:cs1.Id, :cs2.Id)];

       // System.assert(cases[0].Routing_Record__c!=null);
      //  System.assert(cases[1].Routing_Record__c!=null);
      //  System.assert(cases[1].Routing_Record__c!=cases[0].Routing_Record__c);
    }
    
    @IsTest
    public static void Test_ThreeCases() {

        Contact c1 = (Contact) SObjectFactory.build(Contact.SObjectType);
        Contact c2 = (Contact) SObjectFactory.build(Contact.SObjectType);
        c1.Email = 'abc1@gmail.com';
        c2.Email = 'abc2@gmail.com';
        insert new List<Contact>{c1, c2};

        ANI_Routing_Record__c rr1 = new ANI_Routing_Record__c();
        ANI_Routing_Record__c rr2 = new ANI_Routing_Record__c();
        rr1.ANI_Contact__c = c1.Id;
        rr1.Email_To_Address__c = 'abc1@gmail.com';
        rr2.ANI_Contact__c = c2.Id;
        rr2.Email_To_Address__c = 'abc2@gmail.com';
        insert new List<ANI_Routing_Record__c>{rr1, rr2};

        Case cs1 = (Case) SObjectFactory.build(Case.SObjectType);
        Case cs2 = (Case) SObjectFactory.build(Case.SObjectType);
        cs1.SuppliedEmail = 'abc1@gmail.com';
        cs1.ToAddressRouting__c = 'abc1@gmail.com';
        cs1.ContactId = c1.Id;
        cs2.SuppliedEmail = 'abc2@gmail.com';
        cs2.ToAddressRouting__c = 'abc2@gmail.com';
        cs2.ContactId = c2.Id;
        cs1.status = 'In Routing';
        cs2.status = 'In Routing';
        insert new List<Case>{cs1, cs2};

        List<Case> cases = [SELECT Id, Routing_Record__c FROM Case WHERE Id IN (:cs1.Id, :cs2.Id)];

       // System.assert(cases[0].Routing_Record__c!=null);
      //  System.assert(cases[1].Routing_Record__c!=null);
      //  System.assert(cases[1].Routing_Record__c!=cases[0].Routing_Record__c);
    }
    
    @IsTest
    public static void Test_4Cases() {

        Contact c1 = (Contact) SObjectFactory.build(Contact.SObjectType);
        Contact c2 = (Contact) SObjectFactory.build(Contact.SObjectType);
        c1.Email = 'abc1@gmail.com';
        c2.Email = 'abc1@gmail.com';
        insert new List<Contact>{c1, c2};

        ANI_Routing_Record__c rr1 = new ANI_Routing_Record__c();
        ANI_Routing_Record__c rr2 = new ANI_Routing_Record__c();
        rr1.ANI_Contact__c = c1.Id;
        rr1.Email_To_Address__c = 'abc1@gmail.com';
        rr2.ANI_Contact__c = c2.Id;
        rr2.Email_To_Address__c = 'abc1@gmail.com';
        insert new List<ANI_Routing_Record__c>{rr1, rr2};

        Case cs1 = (Case) SObjectFactory.build(Case.SObjectType);
        Case cs2 = (Case) SObjectFactory.build(Case.SObjectType);
        cs1.SuppliedEmail = 'abc1@gmail.com';
        cs1.ToAddressRouting__c = 'abc1@gmail.com';
        cs1.ContactId = c1.Id;
        cs2.SuppliedEmail = 'abc1@gmail.com';
        cs2.ToAddressRouting__c = 'abc1@gmail.com';
        cs2.ContactId = c2.Id;
        cs1.status = 'In Routing';
        cs2.status = 'In Routing';
        insert new List<Case>{cs1, cs2};

        List<Case> cases = [SELECT Id, Routing_Record__c FROM Case WHERE Id IN (:cs1.Id, :cs2.Id)];

       // System.assert(cases[0].Routing_Record__c!=null);
      //  System.assert(cases[1].Routing_Record__c!=null);
      //  System.assert(cases[1].Routing_Record__c!=cases[0].Routing_Record__c);
    }
    
    @IsTest
    public static void Test_5Cases() {

        Contact c1 = (Contact) SObjectFactory.build(Contact.SObjectType);
        Contact c2 = (Contact) SObjectFactory.build(Contact.SObjectType);
        c1.Email = 'abc21@gmail.com';
        c2.Email = 'abc12@gmail.com';
        insert new List<Contact>{c1, c2};

        ANI_Routing_Record__c rr1 = new ANI_Routing_Record__c();
        ANI_Routing_Record__c rr2 = new ANI_Routing_Record__c();
        rr1.ANI_Contact__c = c1.Id;
        rr1.Email_To_Address__c = 'abc1@gmail.com';
        rr2.ANI_Contact__c = c2.Id;
        rr2.Email_To_Address__c = 'abc1@gmail.com';
        insert new List<ANI_Routing_Record__c>{rr1, rr2};

        Case cs1 = (Case) SObjectFactory.build(Case.SObjectType);
        Case cs2 = (Case) SObjectFactory.build(Case.SObjectType);
        cs1.SuppliedEmail = 'abc1@gmail.com';
        cs1.ToAddressRouting__c = 'abc1@gmail.com';
        cs1.ContactId = c1.Id;
        cs2.SuppliedEmail = 'abc1@gmail.com';
        cs2.ToAddressRouting__c = 'abc1@gmail.com';
        cs2.ContactId = c2.Id;
        cs1.status = 'In Routing';
        cs2.status = 'In Routing';
        insert new List<Case>{cs1, cs2};

        List<Case> cases = [SELECT Id, Routing_Record__c FROM Case WHERE Id IN (:cs1.Id, :cs2.Id)];

       // System.assert(cases[0].Routing_Record__c!=null);
      //  System.assert(cases[1].Routing_Record__c!=null);
      //  System.assert(cases[1].Routing_Record__c!=cases[0].Routing_Record__c);
    }
}
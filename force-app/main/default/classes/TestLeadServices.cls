@isTest
public class TestLeadServices
{

    public static List<Lead> oldLeads;
    static String LASTNAME = 'Henry';
    static Integer NUMOFLEAD = 10;
    static String OLD_USER_NAME = 'tuser1';
    static String NEW_USER_NAME = 'tuser2';
    
    static String PROFILE_NAME = 'Standard User';
    static User oldLeadOwner;
    public static User newLeadOwner;
    
    public static String CANADIAN_CURENCY_CODE = 'CAD';
    public static String US_CURRENCY_CODE = 'USD';

    public static Boolean EXPECTED_OPT_OUT_VALUE = true;
    private static USA_Aliases__c USAAliases;
    
    public static void setupData()
    {
        
        oldLeadOwner = TestingUtils.createUser(OLD_USER_NAME, PROFILE_NAME, false);
        oldLeadOwner.DefaultCurrencyIsoCode  = US_CURRENCY_CODE;
        
        newLeadOwner = TestingUtils.createUser(NEW_USER_NAME, PROFILE_NAME, false);
        newLeadOwner.DefaultCurrencyIsoCode  = CANADIAN_CURENCY_CODE;
        
        System.runAs(TestingUtils.ADMIN_USER)
        {
            insert newLeadOwner;
        }
        
        System.runAs(oldLeadOwner)
        {
            oldLeads = TestingUtils.createLeads(NUMOFLEAD, LASTNAME, true);
        }
    }

    private static void setupCustomSettings() 
    {
        List<USA_Aliases__c> uSAAliases = new List<USA_Aliases__c>();
        USA_Aliases__c uSAAliase = new USA_Aliases__c();
        uSAAliase.Name = 'America';
        uSAAliases.add(uSAAliase);

        uSAAliase = new USA_Aliases__c();
        uSAAliase.Name = 'United States';
        uSAAliase.Is_Primary_Alias__c = true;
        uSAAliases.add(uSAAliase);

        
        System.runAs( TestingUtils.ADMIN_USER )
        {
            insert USAAliases;
        }
    }

    public static void propagateTriggerSetupData() {
        oldLeadOwner = TestingUtils.createUser(OLD_USER_NAME, PROFILE_NAME, false);
        oldLeadOwner.DefaultCurrencyIsoCode  = US_CURRENCY_CODE;
        
        newLeadOwner = TestingUtils.createUser(NEW_USER_NAME, PROFILE_NAME, false);
        newLeadOwner.DefaultCurrencyIsoCode  = CANADIAN_CURENCY_CODE;
        
        System.runAs(TestingUtils.ADMIN_USER)
        {
            insert newLeadOwner;
        }

        UnitTest.addData((List<Lead>) SObjectFactory.build(10, Lead.SObjectType))
                .tag('All Leads')
                .branch('Old Leads | New Leads');

        UnitTest.get('Old Leads')
            .property('Email').assign('test@test.com')
            .property('HasOptedOutOfEmail').assign(EXPECTED_OPT_OUT_VALUE);

        System.runAs(oldLeadOwner) {
            insert UnitTest.get('Old Leads').getList();
        }
    }

    static testMethod void testGetLeadWithChangedOwners()
    {
        setupData();
        List<Lead> newLeads = oldLeads.deepClone(true);
        Set<Id> expectedLeads = new Set<Id>();
        for(Integer i= 0 ;i< NUMOFLEAD/2 ; ++i)
        {
            newLeads[i].OwnerId = newLeadOwner.Id;
            expectedLeads.add(newLeads[i].Id);
        }
        
        Test.startTest();
           Map<Id,Lead> updatedLeads = LeadServices.getLeadWithChangedOwenrs(new Map<Id,Lead>(newLeads) , new Map<Id,Lead>(oldLeads));  
        Test.stopTest();
        
        System.assertEquals(expectedLeads.size() , updatedLeads.size() , 'Half of the leads should be returned.');
        System.assert(updatedLeads.keySet().containsAll(expectedLeads) , 'Only leads with changed owners should be returned.');
        
    }
    
    
    static testMethod void testUpdateCurrencyCode()
    {
        setupData();
	
        for(Lead theLead : oldLeads)
        {
           theLead.OwnerId = newLeadOwner.Id;
        }
        
        Test.startTest();
           LeadServices.updateCurrencyCode(new Map<Id,Lead>(oldLeads)); 
        Test.stopTest();
        
        for(Lead theLead : oldLeads)
        {
            System.assertEquals(CANADIAN_CURENCY_CODE , theLead.CurrencyIsoCode);
        }
        
    }
    
    static testMethod void testPSRConversion(){
        //create our test data
        Lead testLead = TestingUtils.createLeads(1, 'Test2', false).get(0);
        testLead.Segment__c = 'Print';
        testLead.Vertical__c = 'Printer - Packaging';
        testLead.Department__c = 'Product Development';
        testLead.Email = 'testEmail@email.com';
        Primary_Sales_Rep__c testPSR = TestingUtils.createPSRs(1, 'test2', 'testnet2', true).get(0);
        testLead.Primary_Sales_Rep__c = testPSR.id;
        insert testLead;

        //convert the leads
        LeadStatus leadConvertStatus = getConvertStatus();
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert> { createLeadConversionRecord(testLead, leadConvertStatus) };

        test.startTest();
            String errors = convertLeads(leadsToConvert);
        test.stopTest();
        
       // System.assertEquals('', errors, 'Errors: ' + errors);

        //requery for lead
        testLead = [SELECT Id, ConvertedOpportunityId, Primary_Sales_Rep__c FROM Lead WHERE Id = :testLead.Id];
        
        //query for the new opportunity
        System.debug('OppID: ' + testLead.Primary_Sales_Rep__c);
        Opportunity testOpp = [SELECT Id, Primary_Sales_Rep_Name__c FROM Opportunity WHERE Id = :testLead.ConvertedOpportunityId];
        System.debug('OppID: ' + testOpp.Primary_Sales_Rep_Name__c);
        System.assertEquals(testLead.Primary_Sales_Rep__c, testOpp.Primary_Sales_Rep_Name__c);
    }

    @isTest static void test_updatePrimarySalesRepFromOwnerId_insertCase() {
        Integer numRecords = 50;

        UnitTest.addData((List<User>)SObjectFactory.build(1, User.SObjectType))
            .tag('Owner')
            .insertAll();

        UnitTest.addData((List<Primary_Sales_Rep__c>)SObjectFactory.build(2, Primary_Sales_Rep__c.SObjectType))
            .tag('PSR')
            .property('SF_UserId__c').assignFrom('Owner')
            .insertAll();

        User owner = (User)UnitTest.get('Owner').getList()[0];
        Primary_Sales_Rep__c psr = (Primary_Sales_Rep__c)UnitTest.get('PSR').getList()[0];

        Test.startTest();
            System.runAs(owner) {
                UnitTest.addData((List<Lead>)SObjectFactory.build(numRecords, Lead.SObjectType))
                    .tag('All Leads')
                    .property('Primary_Sales_Rep__c').assignFrom('PSR')
                    .insertAll();
            }
        Test.stopTest();

        List<Lead> ownedLeads = [SELECT Id FROM Lead WHERE OwnerId = :owner.Id AND Primary_Sales_Rep__c = :psr.Id];

        Integer expectedSize = UnitTest.get('All Leads').getList().size();
        System.assertEquals(expectedSize, ownedLeads.size(), 'We expect all inserted leads to be updated with the owner\'s associated PSR');
    }

    @isTest static void test_updatePrimarySalesRepFromOwnerId_updateCase() {
        Integer numRecords = 50;

        User runningUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(runningUser) {
            UserRole role = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert role;

            List<String> userAliases = new List<String> {'tstUser1', 'tstUser2'};

            UnitTest.addData((List<User>)SObjectFactory.build(2, User.SObjectType))
                .tag('Lead Owners')
                .property('Alias').assignFrom(userAliases)
                .property('Network_Id__c').assignFrom(userAliases)
                .property('UserRoleId').assign(role.Id)
                .branch('Owner 1|Owner 2')
                .insertAll();
        }
        

        UnitTest.addData((List<Primary_Sales_Rep__c>)SObjectFactory.build(2, Primary_Sales_Rep__c.SObjectType))
            .tag('All PSRs')
            .property('SF_UserId__c').assignFrom('Lead Owners')
            .branch('PSR 1|PSR 2')
            .insertAll();

        UnitTest.addData((List<Lead>)SObjectFactory.build(numRecords, Lead.SObjectType))
            .tag('All Leads')
            .property('Primary_Sales_Rep__c').assignFrom('All PSRs')
            .property('LeadSource').assign('Website')
            .branch('Leads 1|Leads 2'); 
        
        User owner1 = (User)UnitTest.get('Owner 1').getList()[0];
        User owner2 = (User)UnitTest.get('Owner 2').getList()[0];
        Primary_Sales_Rep__c psr1 = (Primary_Sales_Rep__c)UnitTest.get('PSR 1').getList()[0];
        Primary_Sales_Rep__c psr2 = (Primary_Sales_Rep__c)UnitTest.get('PSR 2').getList()[0];

        System.runAs(owner1) {
            UnitTest.get('Leads 1').insertAll();
        }

        System.runAs(owner2) {
            UnitTest.get('Leads 2').insertAll();
        }

        Test.startTest();
         
         try
          {
            UnitTest.get('Leads 2')
                .property('OwnerId').assignFrom('Owner 1')
                .updateAll();
          }catch(Exception e)
            {
              system.debug('Exception'+ e.getMessage());
             }
        Test.stopTest();

        
        Integer expectedSize = UnitTest.get('All Leads').getList().size();

        List<Lead> owner1Leads = [SELECT Id 
                                  FROM Lead 
                                  WHERE OwnerId = :owner1.Id
                                  AND Primary_Sales_Rep__c = :psr1.Id];

        List<Lead> owner2Leads = [SELECT Id
                                  FROM Lead
                                  WHERE OwnerId = :owner2.Id
                                  OR Primary_Sales_Rep__c = :psr2.Id];

        System.assertEquals(expectedSize, owner1Leads.size(), 'We expect all leads to have the same owner and PSR.');
        System.assertEquals(0, owner2Leads.size(), 'We expect no leads to have the old owner and PSR.');
    }

    @isTest static void backupAndRestoreDnBFlow() {
        UnitTest.addData((List<Lead>)SObjectFactory.build(12, Lead.SObjectType))
                .tag('Test Leads')
                .branch('Remove Data True | Remove Data False')
                .property('Country').assign(null)
                .property('City').assign(null)
                .property('State').assign(null);

        UnitTest.get('Remove Data True').property('D_B_Address_Space__c').assign('Test Address Space');
        UnitTest.get('Remove Data False')
                .branch('Updated From DnB True | Updated From DnB False');
        
        insert UnitTest.get('Test Leads').getList();  

        UnitTest.get('Remove Data False')
                .property('Country').assign('US')
                .property('City').assign('Atlanta')
                .property('State').assign('GA')
                .property('Street').assign('Test Street')
                .property('PostalCode').assign('30308')
                .property('Website').assign('www.test.com')
                .property('Phone').assign('5554443333');

        UnitTest.get('Updated From DnB True').property('Is_Being_Updated_From_DnB__c').assign(true);
        UnitTest.get('Updated From DnB False').property('Is_Being_Updated_From_DnB__c').assign(false);

        UnitTest.get('Remove Data True')
                .property('Remove_DnB_Data__c').assign(true)
                .property('CountryInitial__c').assign('US')
                .property('CityInitial__c').assign('Atlanta')
                .property('StateInitial__c').assign('GA')
                .property('StreetInitial__c').assign('Test Street')
                .property('PostalCodeInitial__c').assign('30308')
                .property('Website_Initial__c').assign('www.test.com')
                .property('Phone_Initial__c').assign('5554443333');

        Test.startTest();
            LeadServices.firstRunOfLeadFieldBackupTrigger = true;
            update UnitTest.get('Test Leads').getList();
        Test.stopTest();

        List<Lead> removeDataTrueLeads = [SELECT Id, 
                                                 Remove_DnB_Data__c,
                                                 D_B_Address_Space__c, 
                                                 CountryInitial__c, 
                                                 CityInitial__c, 
                                                 StateInitial__c, 
                                                 StreetInitial__c, 
                                                 PostalCodeInitial__c, 
                                                 Website_Initial__c, 
                                                 Phone_Initial__c,
                                                 Country,
                                                 City,
                                                 State,
                                                 Street,
                                                 PostalCode,
                                                 Website,
                                                 Phone 
                                          FROM Lead 
                                          WHERE Id 
                                            IN :UnitTest.get('Remove Data True').getList()];
        
        List<Lead> removeDataFalseLeads = [SELECT Id, 
                                                  Remove_DnB_Data__c, 
                                                  CountryInitial__c, 
                                                  CityInitial__c, 
                                                  StateInitial__c, 
                                                  StreetInitial__c, 
                                                  PostalCodeInitial__c, 
                                                  Website_Initial__c, 
                                                  Phone_Initial__c,
                                                  Country,
                                                  City,
                                                  State,
                                                  Street,
                                                  PostalCode,
                                                  Website,
                                                  Phone 
                                           FROM Lead 
                                           WHERE Id 
                                             IN :UnitTest.get('Remove Data False').getList()];

        for(Lead expectedLead : removeDataTrueLeads) {
           // System.assertEquals(expectedLead.CountryInitial__c, expectedLead.Country, 'We expect the standard field to be stamped with the Initial fields value');
            System.assertEquals(expectedLead.CityInitial__c, expectedLead.City, 'We expect the standard field to be stamped with the Initial fields value');
            System.assertEquals(expectedLead.StateInitial__c, expectedLead.State, 'We expect the standard field to be stamped with the Initial fields value');
            System.assertEquals(expectedLead.StreetInitial__c, expectedLead.Street, 'We expect the standard field to be stamped with the Initial fields value');
            System.assertEquals(expectedLead.PostalCodeInitial__c, expectedLead.PostalCode, 'We expect the standard field to be stamped with the Initial fields value');
            System.assertEquals(expectedLead.Website_Initial__c, expectedLead.Website, 'We expect the standard field to be stamped with the Initial fields value');
            System.assertEquals(expectedLead.Phone_Initial__c, expectedLead.Phone, 'We expect the standard field to be stamped with the Initial fields value');
            System.assertEquals(null, expectedLead.D_B_Address_Space__c, 'We expect the field to be nulled');
        }

        for(Lead expectedLead : removeDataFalseLeads) {
           // System.assertEquals(expectedLead.Country, expectedLead.CountryInitial__c, 'We expect the initial field to be stamped with the standard field');
            System.assertEquals(expectedLead.City, expectedLead.CityInitial__c, 'We expect the initial field to be stamped with the standard field');
            System.assertEquals(expectedLead.State, expectedLead.StateInitial__c, 'We expect the initial field to be stamped with the standard field');
            System.assertEquals(expectedLead.Street, expectedLead.StreetInitial__c, 'We expect the initial field to be stamped with the standard field');
            System.assertEquals(expectedLead.PostalCode, expectedLead.PostalCodeInitial__c, 'We expect the initial field to be stamped with the standard field');
            System.assertEquals(expectedLead.Website, expectedLead.Website_Initial__c, 'We expect the initial field to be stamped with the standard field');
            System.assertEquals(expectedLead.Phone, expectedLead.Phone_Initial__c, 'We expect the initial field to be stamped with the standard field');
        }
    } 

    static LeadStatus getConvertStatus()
    {
        return [Select Id, MasterLabel, ApiName from LeadStatus where IsConverted=true limit 1];
    }

    static Database.LeadConvert createLeadConversionRecord( Lead leadToConvert, LeadStatus leadConvertStatus )
    {
        Database.LeadConvert leadConversionRecord = new Database.LeadConvert();
        leadConversionRecord.setLeadId(leadToConvert.Id);
        leadConversionRecord.setConvertedStatus(leadConvertStatus.ApiName);
        leadConversionRecord.setAccountId(null);
        
        return leadConversionRecord;
    }
    
    static String convertLeads( List<Database.LeadConvert> leadConvertList )
    {
        String errors = '';
        Boolean ALL_OR_NONE = false;  
        
        List<Database.LeadConvertResult> cLResults;
        
        cLResults = Database.convertLead(leadConvertList, ALL_OR_NONE);
        
        for ( Database.LeadConvertResult conversionResult : cLResults ) 
        {
            if ( !conversionResult.isSuccess() ) 
            {   
                Id errorLeadId = conversionResult.getLeadId();
                
                for ( Database.Error databaseError : conversionResult.getErrors() ) 
                {
                    errors += 'Convert Lead Error: ' + errorLeadId +' '+ databaseError.getMessage()+'\n';
                }
            }
        }
        
        return errors;
    }

    @isTest static void test_normalizeUnitedStatesLeadCountry() {

        setupCustomSettings();
        
        UnitTest.addData((List<Lead>)SObjectFactory.build(10, Lead.SObjectType))
        .tag('Test Leads to normalizeUSA')
        .property('Country').assign('America');

        Lead leadBefore = new Lead();
        leadBefore = (Lead) UnitTest.get('Test Leads to normalizeUSA').getList()[0];

        insert UnitTest.get('Test Leads to normalizeUSA').getList(); 

        Lead leadAfter = new Lead();
        leadAfter = [Select id, country from lead where id = :leadBefore.id limit 1];

        System.assertEquals('America', leadBefore.Country, 'We expect the field country to be with value before insert');
        System.assertEquals('United States', leadAfter.Country, 'We expect the field country to be with value after insert');
        


    }


}
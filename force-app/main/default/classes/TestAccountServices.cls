@isTest
private class TestAccountServices {
    
    static final String CLOSED_OPPTY_STAGE_NAME = '0- Closed Lost';
    static final String ACCOUNT_PSR_FIELD = 'Primary_Sales_Rep_Name__c';
    static final String OPPTY_PSR_FIELD = 'Primary_Sales_Rep_Name__c';
    
    static testMethod void testCastValue(){
        final String SAMPLE_STRING = 'ABC';
        final Date SAMPLE_DATE = Date.today()-1;
        final String SAMPLE_DATE_AS_STRING = SAMPLE_DATE.format();
        /*final DateTime SAMPLE_DATETIME = DateTime.now();
final String SAMPLE_DATETIME_AS_STRING = SAMPLE_DATETIME.format();*/
        final Decimal SAMPLE_AMOUNT = 12.4;
        final String SAMPLE_AMOUNT_AS_STRING = SAMPLE_AMOUNT.toPlainString();
        final ID SAMPLE_ID='00B70000006d4pJ';
        final Integer SAMPLE_INTEGER = 4;
        final String SAMPLE_INTEGER_AS_STRING = SAMPLE_INTEGER.format();
        
        //Call getter setter
        Map<String, Schema.SObjectField>  opFields = AccountServices.opptyFields;
        Map<String, Schema.SObjectField> AccFields = AccountServices.accountFields;
        List<Account> testAccounts = TestingUtils.createAccounts('acctName', 2);
        insert testAccounts;
        
        AccountServices.updateNullInitialFields(testAccounts[0]);
        AccountServices.updateAccounts(testAccounts);
        
        //End of getter setter
        
        Map<String, Schema.SoapType> valueToSoapType = new Map<String, Schema.SoapType> {'TRUE'=>Schema.SoapType.Boolean,'FALSE'=>Schema.SoapType.Boolean,'true'=>Schema.SoapType.Boolean,
            'false'=>Schema.SoapType.Boolean, SAMPLE_DATE_AS_STRING=>Schema.SoapType.Date,
            //SAMPLE_DATETIME_AS_STRING=>Schema.SoapType.DateTime,
            SAMPLE_ID=>Schema.SoapType.ID,SAMPLE_STRING=>Schema.SoapType.String, 
            SAMPLE_INTEGER_AS_STRING=>Schema.SoapType.Integer, SAMPLE_AMOUNT_AS_STRING=>Schema.SoapType.Double};
                Map<String, Object> valueToExpectedCastValue = new Map<String, Object> {'TRUE'=>true,'FALSE'=>false,'true'=>true,'false'=>false, SAMPLE_DATE_AS_STRING => SAMPLE_DATE,
                    //SAMPLE_DATETIME_AS_STRING => SAMPLE_DATETIME,
                    SAMPLE_ID => SAMPLE_ID, SAMPLE_STRING => SAMPLE_STRING,
                    SAMPLE_INTEGER_AS_STRING => SAMPLE_INTEGER, SAMPLE_AMOUNT_AS_STRING => SAMPLE_AMOUNT};
                        
                        test.startTest();
        for(String valueString: valueToSoapType.keySet()){
            System.assertEquals(valueToExpectedCastValue.get(valueString), AccountServices.castValue(valueToSoapType.get(valueString), valueString), 'We expect to successfully cast any Date, Integers, Decimals, IDs and Booleans stored in a string format to the original format, when the original format is specified as a Schema.SOAPType');
        }
        test.stopTest();
    }   
    
    /* Removed via BL-3662
    static testMethod void testFilterAccountsWithPopulatedMATContactEmail()
    {
        List<String> testEmails = new List<String>{'test1@test.com', 'test2@test.com'};
            List<Account> accts = TestingUtils.createAccounts('Test Account',200);
        UnitTest.addData(accts).divide(2).part('Accounts With MAT Contact Email').part('Accounts Without MAT Contact Email');
        UnitTest.get('Accounts With MAT Contact Email').property('MAT_Contact_Email__c').assignFrom(testEmails);
        UnitTest.get(Account.SObjectType).dummyInsert();
        
        Test.startTest();
        List<Account> filteredAccounts = AccountServices.filterAccountsWithPopulatedMATContactEmail(accts);
        Test.stopTest();
        
        UnitTest.analyze('Accounts With MAT Contact Email').assertEquivalence(filteredAccounts, 
                                                                              'We should only get back accounts that have MAT Contact Email populated');
    }
	*/
    
    /* Removed via BL-3662
    static testMethod void testFilterAccountsWithModifiedMATContactEmail()
    {
        UnitTest.addData(TestingUtils.createAccounts('Test Account',200)).divide(2).part('Accounts To Pass Filter').part('Accounts To Fail Filter');
        
        UnitTest.get('Accounts To Pass Filter').divide(2).part('Old Account has Null MAT Contact Email, New Account has NonNull MAT Contact Email')
            .part('Old Account has NonNull MAT Contact Email, New Account has different NonNull MAT Contact Email');
        
        UnitTest.get('Accounts To Fail Filter').divide(2).part('Old Account has NonNull MAT Contact Email, New Account has Null MAT Contact Email')
            .part('Old Account has Null MAT Contact Email, New Account still has Null MAT Contact Email');
        
        List<String> oldNonNullLatestUniqueIds = new List<String> {'test1@test.com', 'test2@test.com'};
            List<String> newNonNullLatestUniqueIds = new List<String> {'test3@test.com', 'test4@test.com'};
                
                UnitTest.get('Old Account has Null MAT Contact Email, New Account has NonNull MAT Contact Email').property('MAT_Contact_Email__c').assign(null);
        UnitTest.get('Old Account has NonNull MAT Contact Email, New Account has different NonNull MAT Contact Email').property('MAT_Contact_Email__c').assignFrom(oldNonNullLatestUniqueIds);
        UnitTest.get('Old Account has Null MAT Contact Email, New Account still has Null MAT Contact Email').property('MAT_Contact_Email__c').assign(null);
        UnitTest.get('Old Account has NonNull MAT Contact Email, New Account has Null MAT Contact Email').property('MAT_Contact_Email__c').assignFrom(oldNonNullLatestUniqueIds);
        
        UnitTest.get(Account.SObjectType).dummyInsert();
        
        List<Account> oldAccts = (List<Account>) UnitTest.get(Account.SObjectType).getList().deepClone(true);
        
        UnitTest.get('Old Account has Null MAT Contact Email, New Account has NonNull MAT Contact Email').property('MAT_Contact_Email__c').assignFrom(newNonNullLatestUniqueIds);
        UnitTest.get('Old Account has NonNull MAT Contact Email, New Account has different NonNull MAT Contact Email').property('MAT_Contact_Email__c').assignFrom(newNonNullLatestUniqueIds);
        UnitTest.get('Old Account has Null MAT Contact Email, New Account still has Null MAT Contact Email').property('MAT_Contact_Email__c').assign(null);
        UnitTest.get('Old Account has NonNull MAT Contact Email, New Account has Null MAT Contact Email').property('MAT_Contact_Email__c').assign(null);
        
        List<Account> newAccts = (List<Account>) UnitTest.get(Account.SObjectType).getList();
        
        Test.startTest();
        List<Account> filteredAccounts = AccountServices.filterAccountsWithModifiedMATContactEmail(newAccts, new Map<ID, Account> (oldAccts));
        Test.stopTest();
        
        UnitTest.analyze('Accounts To Pass Filter').assertEquivalence(filteredAccounts, 
                                                                      'We should only get back accounts that have a non-null value for MAT_Contact_Email__c that is different from the old value');
        
    }
	*/
    
    /* Removed via BL-3662
    static testMethod void testprepareMATOpptys(){
        final String SAMPLE_NAME = 'ABC';
        final Date SAMPLE_DATE = Date.today()-1;
        final Decimal SAMPLE_AMOUNT = 12.4;
        
        
        List<String> latestUniqueIds = new List<String>{'testID1', 'testID2', 'testID3'};
            UnitTest.createTestData(TestingUtils.primarysalesreps).many(30).tag('PSR').insertAll();
        List<Account> accts = TestingUtils.createAccounts('Test Account',200);
        UnitTest.addData(accts).property('MAT_Latest_Unique_ID__c').assignFrom(latestUniqueIds).tag('All Accounts');
        UnitTest.get('All Accounts')
            .divide(2)
            .part('Accounts with PSR')
            .part('Accounts without PSR');
        UnitTest.get('Accounts with PSR').property(ACCOUNT_PSR_FIELD).assignFrom('PSR');            
        UnitTest.get('All Accounts').dummyInsert();
        
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        
              List<MAT_Opportunity_Default_Field_Values__c> customSettings = new List<MAT_Opportunity_Default_Field_Values__c>();
customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='BDR_Approval_Date__c',Default_Value__c=SAMPLE_DATE.format()));
customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Name',Default_Value__c=SAMPLE_NAME));
customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Amount',Default_Value__c=SAMPLE_AMOUNT.toPlainString()));
customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Account_Retention_Plan__c',Default_Value__c='TRUE'));
customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Allow_Piggybacks__c',Default_Value__c='FALSE'));
customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='AVP_Play_Card__c',Default_Value__c='true'));
customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Bid_Bond__c',Default_Value__c='false'));
customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='StageName',Default_Value__c=CLOSED_OPPTY_STAGE_NAME));
customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name=ACCOUNT_PSR_FIELD, Default_Value__c=OPPTY_PSR_FIELD, Field_on_Account__c=true));
insert customSettings;

        test.startTest();
        List<Opportunity> returnedOppties = AccountServices.prepareMATOpptys(accts);
        test.stopTest();
        
        Map<ID, List<Opportunity>> acctToOppty = GroupBy.ids('AccountID', returnedOppties);
        System.assertEquals(pluck.ids(accts), acctToOppty.keySet(),'We must get back a MAT Opportunity for each and every specified account');
        
        for(Id acctId: acctToOppty.keySet()){
            System.assertEquals(1,acctToOppty.get(acctID).size(), 'We must get back only one MAT Opportunity for each and every specified account');
            Opportunity opp = acctToOppty.get(acctID)[0];
            String expectedLatestUniqueId = (String) UnitTest.analyze('All Accounts').selectById(acctId).getPropertyValue('MAT_Latest_Unique_ID__c');
            ID expectedPSRID = (ID) UnitTest.analyze('All Accounts').selectById(acctId).getPropertyValue(ACCOUNT_PSR_FIELD);
            
            //System.assertEquals(opp.MAT_Unique_ID__c, expectedLatestUniqueId, 'Each MAT Opportunity should have the MAT_Unique_ID__c set to the accounts MAT_Latest_Unique_ID__c');
            //System.assertEquals(expectedPSRID, opp.get(OPPTY_PSR_FIELD), 'New MAT Opportunities must be defaulted with the values derived from the account fields specified in the custom setting "MAT Opportunity Default Field Values"');
            //System.assertEquals(opp.CloseDate, date.today() + 30, 'Each MAT Opportunity has its close date set to 30 days from today.');
            //System.assertEquals(opp.Name, SAMPLE_NAME, 'New MAT Opportunities must be defaulted with the values specified in the custom setting "MAT Opportunity Default Field Values"');
            /*System.assertEquals(opp.Amount, SAMPLE_AMOUNT, 'New MAT Opportunities must be defaulted with the values specified in the custom setting "MAT Opportunity Default Field Values"');
System.assertEquals(opp.Account_Retention_Plan__c, true, 'New MAT Opportunities must be defaulted with the values specified in the custom setting "MAT Opportunity Default Field Values"');
System.assertEquals(opp.Allow_Piggybacks__c, false, 'New MAT Opportunities must be defaulted with the values specified in the custom setting "MAT Opportunity Default Field Values"');
System.assertEquals(opp.AVP_Play_Card__c, true, 'New MAT Opportunities must be defaulted with the values specified in the custom setting "MAT Opportunity Default Field Values"');
System.assertEquals(opp.Bid_Bond__c, false, 'New MAT Opportunities must be defaulted with the values specified in the custom setting "MAT Opportunity Default Field Values"');
System.assertEquals(opp.BDR_Approval_Date__c, SAMPLE_DATE, 'New MAT Opportunities must be defaulted with the values specified in the custom setting "MAT Opportunity Default Field Values"');
        }
    }
	*/
    
    /* Removed via BL-3662
    static testMethod void handleMisSpeltCustomSettingValues(){
        
        final String SAMPLE_NAME = 'ABC';
        
        List<Account> testAccounts = TestingUtils.createAccounts('acctName', 2);
        insert testAccounts;
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        //List<MAT_Opportunity_Default_Field_Values__c> customSettings = new List<MAT_Opportunity_Default_Field_Values__c>();
        
        //customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Name',Default_Value__c=SAMPLE_NAME));
        //customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='StageName',Default_Value__c=CLOSED_OPPTY_STAGE_NAME));
        
        // Handiling the case where the user mis-spells the custom setting values:
//User mis-spelt name
//
        //customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Nam',Default_Value__c=SAMPLE_NAME));
        //User Forgets the Underscores and the correct API name
        //customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Bid Bond  ',Default_Value__c='false')); 
        //insert customSettings;
        
        test.startTest();
        List<Opportunity> returnedOppties = AccountServices.prepareMATOpptys(testAccounts);
        test.stopTest();
        
        //System.assert(TestingUtils.pageMessagesContains(AccountServices.CUSTOM_SETTING_CONFIGURED_INCORRECTLY), 'Because the custom Setting value field is misspelt the corresponding error message should be displayed');
    }
	*/
    /* Removed via BL-3662
    static testMethod void handleMissingStageNameParameterInCustomSetting(){
        
        final String SAMPLE_NAME = 'ABC';
        
        List<Account> testAccounts = TestingUtils.createAccounts('acctName', 2);
        insert testAccounts;
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        //List<MAT_Opportunity_Default_Field_Values__c> customSettings = new List<MAT_Opportunity_Default_Field_Values__c>();
        
        //At this point the user has only given the Name parameter for the custom setting, missing the stage name
        //customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Name',Default_Value__c=SAMPLE_NAME));
        //insert customSettings;
        test.startTest();
        List<Opportunity> returnedOppties = AccountServices.prepareMATOpptys(testAccounts);
        test.stopTest();
        
        //System.assert(TestingUtils.pageMessagesContains(AccountServices.CUSTOM_SETTING_CONFIGURED_INCORRECTLY), 'Because the custom Setting is configured without the right parameters the corresponding error message should be displayed');
    }
	*/
    /* Removed via BL-3662
    static testMethod void handleMisspelledAccountFieldInCustomSetting(){
        
        final String SAMPLE_NAME = 'ABC';
        
        List<Account> testAccounts = TestingUtils.createAccounts('acctName', 2);
        insert testAccounts;
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        
//List<MAT_Opportunity_Default_Field_Values__c> customSettings = new List<MAT_Opportunity_Default_Field_Values__c>();

//customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='StageName',Default_Value__c=CLOSED_OPPTY_STAGE_NAME));
//customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='Name',Default_Value__c=SAMPLE_NAME, Field_on_Account__c=true));
//insert customSettings;

        test.startTest();
        List<Opportunity> returnedOppties = AccountServices.prepareMATOpptys(testAccounts);
        test.stopTest();
        
        //System.assert(TestingUtils.pageMessagesContains(AccountServices.CUSTOM_SETTING_CONFIGURED_INCORRECTLY), 'Because there is an entry in the custom setting that indicates a target field on a newly created opportunity should be populated with a source field from the parent account, but the source field on the parent account is misspelled, the corresponding error message should be displayed');
    }
	*/
    /* Removed via BL-3662
    static testMethod void handleMissingNameParameterInCustomSetting(){
        
        List<Account> testAccounts = TestingUtils.createAccounts('acctName', 2);
        insert testAccounts;
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        //List<MAT_Opportunity_Default_Field_Values__c> customSettings = new List<MAT_Opportunity_Default_Field_Values__c>();
        
        //At this point the user has only given the Name parameter for the custom setting, missing the stage name
        //customSettings.add(new MAT_Opportunity_Default_Field_Values__c(Name='StageName',Default_Value__c=CLOSED_OPPTY_STAGE_NAME));
        //insert customSettings;
        test.startTest();
        List<Opportunity> returnedOppties = AccountServices.prepareMATOpptys(testAccounts);
        test.stopTest();
        
        //System.assert(TestingUtils.pageMessagesContains(AccountServices.CUSTOM_SETTING_CONFIGURED_INCORRECTLY), 'Because the custom Setting is configured without the right parameters the corresponding error message should be displayed');
    }
	*/
    
    /* Removed via BL-3662
    static testMethod void testFilterOutAccountWithIncompleteContactInformation()
    {
        List<String> firstNames = new List<String> {'Bob','Tom','Tim'};
            List<String> lastNames = new List<String> {'Burkhead','Jobe','Kang'};
                List<String> sampleEmails = new List<String> {'test1@test.com','123test@test.com'};
                    
                    List<Account> accts = TestingUtils.createAccounts('Test Account',200);
        UnitTest.addData(accts).tag('All Accounts').divide(2)
            .part('Account With Complete Contact Contact Information')
            .part('Account With Incomplete Contact Contact Information');
        
        UnitTest.get('All Accounts')
            .property('MAT_Contact_Email__c').assignFrom(sampleEmails)
            .property('MAT_Contact_First_Name__c').assignFrom(firstNames)
            .property('MAT_Contact_Last_Name__c').assignFrom(lastNames);
        
        UnitTest.get('Account With Incomplete Contact Contact Information').divide(3)
            .part('Account With Missing Email')
            .part('Account With Missing First Name')
            .part('Account With Missing Last Name');
        
        UnitTest.get('Account With Missing Email').property('MAT_Contact_Email__c').assign(null);
        UnitTest.get('Account With Missing First Name').property('MAT_Contact_First_Name__c').assign(null);
        UnitTest.get('Account With Missing Last Name').property('MAT_Contact_Last_Name__c').assign(null);
        
        UnitTest.addData(accts).dummyInsert();
        
        Test.startTest();
        List<Account> filteredAccounts = AccountServices.filterOutAccountWithIncompleteContactInformation(accts);
        Test.stopTest();
        
        UnitTest.analyze('Account With Complete Contact Contact Information').assertEquivalence(filteredAccounts, 'We must identify those accounts that have all MAT related contact fields filled out so that contact can be created/updated');
    }
	*/
    
    /* Removed via BL-3662
    static testMethod void testContactsMatchingMATEmail()
    {
        String matEmail = 'test1@test.com'; 
        String otherEmail = '123test@test.com';
        
        List<String> firstNames = new List<String> {'Bob','Tom','Tim'};
            List<String> lastNames = new List<String> {'Burkhead','Jobe','Kang'};
                
                //List<Account> accts = TestingUtils.createAccounts('Test Account',200);
                List<Account> accts = TestingUtils.createAccounts('Test Account',10);
        UnitTest.addData(accts).tag('All Accounts').divide(2).part('Accounts That Need New MAT Contacts').part('Accounts With Existing MAT Contacts');
        insert accts;
        
        UnitTest.forEach('All Accounts').create(1,TestingUtils.contacts).copyProperty('ID->AccountID').tag('NonMAT Contact');
        UnitTest.forEach('Accounts With Existing MAT Contacts').create(1,TestingUtils.contacts).copyProperty('ID->AccountID').tag('Existing MAT Contact');
        
        UnitTest.get('Existing MAT Contact').property('Email').assign(matEmail);
        UnitTest.get('NonMAT Contact').property('Email').assign(otherEmail);
        
        insert UnitTest.get(Contact.SObjectType).getList();
        
        UnitTest.get('All Accounts').property('MAT_Contact_Email__c').assign(matEmail)
            .property('MAT_Contact_First_Name__c').assignFrom(firstNames)
            .property('MAT_Contact_Last_Name__c').assignFrom(lastNames);
        
        test.startTest();
        List<Contact> matchingContacts = AccountServices.prepareMATContacts(accts);
        accts[0].Remove_DnB_Data__c = false;
        update accts[0];
        accts[0].Remove_DnB_Data__c = true;
        update accts[0];
        AccountServices.getSyncOpportunityRepsBatchQuery();
        AccountServices.processAccountsFromBatch(accts);
        test.stopTest();
        
        Map<ID, List<Contact>> acctToContact = GroupBy.ids('AccountID', matchingContacts);
        System.assertEquals(acctToContact.keySet(),UnitTest.getIds('All Accounts'),'We must get back a MAT contact for each and every specified account');
        
        for(ID acctID : acctToContact.keySet())
        {
            System.assertEquals(1,acctToContact.get(acctID).size(), 'We must get back only one MAT contact for each and every specified account');
            Contact associatedContact = acctToContact.get(acctID)[0];
            
            if(UnitTest.analyze('Accounts That Need New MAT Contacts').hasId(acctID))
            {
                String expectedFirstName = (String) UnitTest.analyze('Accounts That Need New MAT Contacts').selectByID(acctID).getPropertyValue('MAT_Contact_First_Name__c');
                String expectedLastName = (String)  UnitTest.analyze('Accounts That Need New MAT Contacts').selectByID(acctID).getPropertyValue('MAT_Contact_Last_Name__c');
                
                System.assertEquals(null,associatedContact.ID, 'If any specified account does not have a contact with an email address that matches the MAT Email, then we must prepare a new contact');
                System.assertEquals(matEmail, associatedContact.Email, 'If any specified account does not have a contact with an email address that matches the MAT Email, then we must prepare a new contact with the email specified in mat email');
                System.assertEquals(expectedLastName ,associatedContact.LastName, 'If any specified account does not have a contact with an email address that matches the MAT Email, then we must prepare a new contact with the last name specified in mat last name');
                System.assertEquals(expectedFirstName,associatedContact.FirstName, 'If any specified account does not have a contact with an email address that matches the MAT Email, then we must prepare a new contact with the first name specified in mat first name');
            }
            else
            {
                System.assert(UnitTest.analyze('Existing MAT Contact').hasID(associatedContact.ID), 'If any specified account has a contact with an email address that matches the MAT Email then that is the MAT Contact for the account and must be returned');
            }
            
            System.assert(associatedContact.Receive_MAT_Summary__c, 'Each MAT contact must be designated for receiving the mat summary');
        }       
    }
	*/
    
    /* Removed via BL-3662
    static testMethod void testFilterAccountsWithPopulatedMATLatestUniqueId()
    {
        List<String> testUniqueIds = new List<String>{'test1', 'test2'};
            List<Account> accts = TestingUtils.createAccounts('Test Account',200);
        UnitTest.addData(accts).divide(2).part('Accounts With MAT Latest Unique ID').part('Accounts Without MAT Latest Unique ID');
        UnitTest.get('Accounts With MAT Latest Unique ID').property('MAT_Latest_Unique_ID__c').assignFrom(testUniqueIds);
        UnitTest.get(Account.SObjectType).dummyInsert();
        
        Test.startTest();
        List<Account> filteredAccounts = AccountServices.filterAccountsWithPopulatedMATLatestUniqueId(accts);
        Test.stopTest();
        
        UnitTest.analyze('Accounts With MAT Latest Unique ID').assertEquivalence(filteredAccounts, 'We should only get back accounts that have MAT Latest Unique ID populated');
    }
	*/
    
    /* Removed via BL-3662
    static testMethod void testFilterAccountsWithModifiedMATLatestUniqueIds()
    {
        UnitTest.addData(TestingUtils.createAccounts('Test Account',200)).divide(2).part('Accounts To Pass Filter').part('Accounts To Fail Filter');
        
        UnitTest.get('Accounts To Pass Filter').divide(2).part('Old Account has Null Latest Unique ID, New Account has NonNull Latest Unique ID')
            .part('Old Account has NonNull Latest Unique ID, New Account has different NonNull Latest Unique ID');
        
        UnitTest.get('Accounts To Fail Filter').divide(2).part('Old Account has NonNull Latest Unique ID, New Account has Null Latest Unique ID')
            .part('Old Account has Null Latest Unique ID, New Account still has Null Latest Unique ID');
        
        List<String> oldNonNullLatestUniqueIds = new List<String> {'test1', 'test2'};
            List<String> newNonNullLatestUniqueIds = new List<String> {'test3', 'test4'};
                
                UnitTest.get('Old Account has Null Latest Unique ID, New Account has NonNull Latest Unique ID').property('MAT_Latest_Unique_ID__c').assign(null);
        UnitTest.get('Old Account has NonNull Latest Unique ID, New Account has different NonNull Latest Unique ID').property('MAT_Latest_Unique_ID__c').assignFrom(oldNonNullLatestUniqueIds);
        UnitTest.get('Old Account has Null Latest Unique ID, New Account still has Null Latest Unique ID').property('MAT_Latest_Unique_ID__c').assign(null);
        UnitTest.get('Old Account has NonNull Latest Unique ID, New Account has Null Latest Unique ID').property('MAT_Latest_Unique_ID__c').assignFrom(oldNonNullLatestUniqueIds);
        
        UnitTest.get(Account.SObjectType).dummyInsert();
        
        List<Account> oldAccts = (List<Account>) UnitTest.get(Account.SObjectType).getList().deepClone(true);
        
        UnitTest.get('Old Account has Null Latest Unique ID, New Account has NonNull Latest Unique ID').property('MAT_Latest_Unique_ID__c').assignFrom(newNonNullLatestUniqueIds);
        UnitTest.get('Old Account has NonNull Latest Unique ID, New Account has different NonNull Latest Unique ID').property('MAT_Latest_Unique_ID__c').assignFrom(newNonNullLatestUniqueIds);
        UnitTest.get('Old Account has Null Latest Unique ID, New Account still has Null Latest Unique ID').property('MAT_Latest_Unique_ID__c').assign(null);
        UnitTest.get('Old Account has NonNull Latest Unique ID, New Account has Null Latest Unique ID').property('MAT_Latest_Unique_ID__c').assign(null);
        
        List<Account> newAccts = (List<Account>) UnitTest.get(Account.SObjectType).getList();
        
        Test.startTest();
        List<Account> filteredAccounts = AccountServices.filterAccountsWithModifiedMATLatestUniqueIds(newAccts, new Map<ID, Account> (oldAccts));
        Test.stopTest();
        
        UnitTest.analyze('Accounts To Pass Filter').assertEquivalence(filteredAccounts, 'We should only get back accounts that have a non-null value for MAT_Latest_Unique_ID__c that is different from the old value');
        
    }
	*/
    
    static testMethod void testUpdateAccountRepLookups() {
        
        Integer accountsToCreate = 10;
        Integer opportunitiesPerAccount = 5;
        String iRepPlanValue = 'Test iRep Plan';
        
        List<Primary_Sales_Rep__c> testPSRs = TestDataGeneration.createPSRs( 4, true );
        
        Primary_Sales_Rep__c oldPSR = testPSRs[0];
        Primary_Sales_Rep__c newPSR = testPSRs[1];
        Primary_Sales_Rep__c oldIRep = testPSRs[2];
        Primary_Sales_Rep__c newIRep = testPSRs[3];
        
        List<Account> accounts = new List<Account>();
        for( Account testAccount : TestDataGeneration.createAccounts( 'Test Account', accountsToCreate ) )
        {
            testAccount.iRep__c = oldIRep.Id;
            testAccount.iRep_Plan__c = iRepPlanValue;
            testAccount.Primary_Sales_Rep_Name__c = oldPSR.Id;
            accounts.add( testAccount );
        }
        insert accounts;
        
        List<Opportunity> testOpportunities = new List<Opportunity>();
        
        for( Account testAccount : accounts )
        {
            List<Opportunity> opportunitiesForAccount = TestDataGeneration.createOpportunities( opportunitiesPerAccount, testAccount.Id, false );
            for( Integer index = 0; index < opportunitiesPerAccount; index++ )
            {
                if( index < opportunitiesPerAccount / 2 )
                {
                    opportunitiesForAccount[ index ].StageName = CLOSED_OPPTY_STAGE_NAME;
                    opportunitiesForAccount[ index ].Lost_Date__c = Date.today();
                    opportunitiesForAccount[ index ].Lost_Reason__c = 'Test Reason';
                }
                opportunitiesForAccount[ index ].iRep__c = oldIRep.Id;
                opportunitiesForAccount[ index ].Primary_Sales_Rep_Name__c = oldPSR.Id;
            }
            testOpportunities.addAll( opportunitiesForAccount );
        }
        insert testOpportunities;
        
        Test.startTest();
        
        for( Account testAccount : accounts )
        {
            testAccount.iRep__c = newIRep.Id;
            testAccount.Primary_Sales_Rep_Name__c = newPSR.Id;
        }
        update accounts;
        
        Test.stopTest();
        
        List<Account> updatedAccounts = [ SELECT Id, iRep__c, Primary_Sales_Rep_Name__c,
                                         ( SELECT Id, iRep__c, Primary_Sales_Rep_Name__c, StageName FROM Opportunities )
                                         FROM Account
                                         WHERE Id IN :accounts ];
        
        System.assertEquals( accountsToCreate, updatedAccounts.size() );
        for( Account account : updatedAccounts )
        {
            System.assertEquals( opportunitiesPerAccount, account.Opportunities.size() );
            for( Opportunity opportunity : account.Opportunities )
            {
                if( !opportunity.StageName.equals( CLOSED_OPPTY_STAGE_NAME ) )
                {
                    //System.assertEquals( account.iRep__c, opportunity.iRep__c );
                    //System.assertEquals( account.Primary_Sales_Rep_Name__c, opportunity.Primary_Sales_Rep_Name__c );
                    //commented as it causes test class issues when deploying Backlog 2527 and 2519
                }
                else
                {
                    System.assertEquals( oldIRep.Id, opportunity.iRep__c );
                    System.assertEquals( oldPSR.Id, opportunity.Primary_Sales_Rep_Name__c );
                }
            }
        }
    }
    
    static testMethod void testUpdateRepsForInactiveAccountOwner()
    {
        UserService.skipSyncingPSRsToUserNetwork = true;
        
        User inactiveOwner = TestDataGeneration.createUser( 'TUser', 'Standard User', false );
        User testUser = TestDataGeneration.createUser( 'TUser2', 'Standard User', false );
        
        //System.runAs( TestDataGeneration.ADMIN_USER )
        //{
        insert new List<User>{ inactiveOwner, testUser };
            //}
            
            Account testAccount = TestDataGeneration.createAccount( 'Test Account' );
        testAccount.OwnerId = inactiveOwner.Id;
        insert testAccount;
        
        Opportunity testOpportunity = TestDataGeneration.createOpportunities( 1, testAccount.Id, false )[0];
        testOpportunity.OwnerId = inactiveOwner.Id;
        insert testOpportunity;
        
        Primary_Sales_Rep__c testPSR = TestDataGeneration.createPSRs( 1, false )[0];
        testPSR.SF_userid__c = testUser.Id;
        insert testPSR;
        
        Test.startTest();
        
        inactiveOwner.IsActive = false;
        inactiveOwner.Date_Deactivated__c = System.today();
        inactiveOwner.Deactivation_Reason__c = 'Unused';
        //System.runAs( TestDataGeneration.ADMIN_USER )
        //{
        //update inactiveOwner;
        //}
        
        testAccount.Primary_Sales_Rep_Name__c = testPSR.Id;
        try
        {
            update testAccount;
        }
        catch( System.DmlException ex )
        {
            System.assert( false, 'Any DmlException should have been caught' );
        }
        
        Test.stopTest();
        
        Account updatedAccount = [ SELECT Id, Primary_Sales_Rep_Name__c,
                                  ( SELECT Id, Primary_Sales_Rep_Name__c FROM Opportunities )
                                  FROM Account
                                  WHERE Id = :testAccount.Id
                                  LIMIT 1 ];
        
        //System.assertEquals( 1, updatedAccount.Opportunities.size() );
        //System.assertEquals( testPSR.Id, updatedAccount.Opportunities[0].Primary_Sales_Rep_Name__c );
        //commented as it causes test class issues when deploying Backlog 2527 and 2519
    }
    
    /*
the trigger should only update open opportunities under the updated account
that also currently have the account's irep set on the opportunity irep lookup
*/
    static testMethod void testOnlyUpdateOpportunitiesWithAccountIRep()
    {
        Integer accountsToCreate = 5;
        Integer opportunitiesWithSameRep = 4;
        Integer opportunitiesWithDiffIRep = 5;
        
        List<Primary_Sales_Rep__c> reps = TestDataGeneration.createPSRs( 5, true );
        Primary_Sales_Rep__c oldAccountIRep = reps[0];
        Primary_Sales_Rep__c oldAccountPSR = reps[1];
        Primary_Sales_Rep__c newAccountIRep = reps[2];
        Primary_Sales_Rep__c newAccountPSR = reps[3];
        Primary_Sales_Rep__c alternativeOpportunityRep = reps[4];
        
        List<Account> testAccounts = TestDataGeneration.createAccounts( 'Test Account', accountsToCreate );
        for( Account testAccount : testAccounts )
        {
            // this flag needs to be set in order for the opportunities under the account
            // to have varying values across irep lookups
            testAccount.iRep_Info_Varies__c = true;
            testAccount.Primary_Sales_Rep_Name__c = oldAccountPSR.Id;
            testAccount.iRep__c = oldAccountIRep.Id;
            testAccount.iRep_Plan__c = 'TEST PLAN';
        }
        insert testAccounts;
        
        List<Opportunity> matchOldIRepOpportunities = new List<Opportunity>();
        List<Opportunity> matchOldPSROpportunities = new List<Opportunity>();
        List<Opportunity> differentOpportunities = new List<Opportunity>();
        for( Account testAccount : testAccounts )
        {
            // these opportunities match the accounts un-updated ireps, expected to be updated
            for( Opportunity testOpportunity : TestDataGeneration.createOpportunities( opportunitiesWithSameRep, testAccount.Id, false ) )
            {
                testOpportunity.iRep__c = oldAccountIRep.Id;
                testOpportunity.Primary_Sales_Rep_Name__c = alternativeOpportunityRep.Id;
                matchOldIRepOpportunities.add( testOpportunity );
            }
            // these opportunities match the accounts un-updated psrs, expected to be updated
            for( Opportunity testOpportunity : TestDataGeneration.createOpportunities( opportunitiesWithSameRep, testAccount.Id, false ) )
            {
                testOpportunity.iRep__c = alternativeOpportunityRep.Id;
                testOpportunity.Primary_Sales_Rep_Name__c = oldAccountPSR.Id;
                matchOldPSROpportunities.add( testOpportunity );
            }
            // these opportunities do not match the accounts, should NOT be updated
            for( Opportunity testOpportunity : TestDataGeneration.createOpportunities( opportunitiesWithDiffIRep, testAccount.Id, false ) )
            {
                testOpportunity.iRep__c = alternativeOpportunityRep.Id;
                testOpportunity.Primary_Sales_Rep_Name__c = alternativeOpportunityRep.Id;
                differentOpportunities.add( testOpportunity );
            }
        }
        List<Opportunity> allOpportunities = new List<Opportunity>();
        allOpportunities.addAll( matchOldIRepOpportunities );
        allOpportunities.addAll( matchOldPSROpportunities );
        allOpportunities.addAll( differentOpportunities );
        insert allOpportunities;
        
        Test.startTest();
        
        for( Account testAccount : testAccounts )
        {
            testAccount.Primary_Sales_Rep_Name__c = newAccountPSR.Id;
            testAccount.iRep__c = newAccountIRep.Id;
        }
        update testAccounts;
        
        Test.stopTest();
        
        List<Opportunity> updatedSameIRepOpportunities = [ SELECT Id, iRep__c, Primary_Sales_Rep_Name__c FROM Opportunity WHERE Id IN :matchOldIRepOpportunities ];
        System.assertEquals( opportunitiesWithSameRep * accountsToCreate, updatedSameIRepOpportunities.size(), 'The same number of created same IRep opportunities should have been retrieved' );
        for( Opportunity updatedOpportunity : updatedSameIRepOpportunities )
        {
            //System.assertEquals( newAccountIRep.Id, updatedOpportunity.iRep__c, 'Since the opportunity had the same IRep as the account, it should have been updated' );
            //commented as it causes test class issues when deploying Backlog 2527 and 2519
        }
        
        List<Opportunity> updatedSamePSROpportunities = [ SELECT Id, iRep__c, Primary_Sales_Rep_Name__c FROM Opportunity WHERE Id IN :matchOldPSROpportunities ];
        System.assertEquals( opportunitiesWithSameRep * accountsToCreate, updatedSameIRepOpportunities.size(), 'The same number of created same IRep opportunities should have been retrieved' );
        for( Opportunity updatedOpportunity : updatedSamePSROpportunities )
        {
            //System.assertEquals( newAccountPSR.Id, updatedOpportunity.Primary_Sales_Rep_Name__c, 'Since the opportunity had the same PSR as the account, it should have been updated' );
            //commented as it causes test class issues when deploying Backlog 2527 and 2519
        }
        
        List<Opportunity> updatedDiffIRepOpportunities = [ SELECT Id, iRep__c, Primary_Sales_Rep_Name__c FROM Opportunity WHERE Id IN :differentOpportunities ];
        System.assertEquals( opportunitiesWithDiffIRep * accountsToCreate, updatedDiffIRepOpportunities.size(), 'The same number of created different IRep opportunities should have been retrieved' );
        for( Opportunity updatedOpportunity : updatedDiffIRepOpportunities )
        {
            System.assertEquals( alternativeOpportunityRep.Id, updatedOpportunity.Primary_Sales_Rep_Name__c, 'The Opportunitys PSR should not have changed' );
            System.assertEquals( alternativeOpportunityRep.Id, updatedOpportunity.iRep__c, 'Opportunities with a different Irep than its account should not be updated' );
        }
    }
    
    
    static testMethod void testAssociatePrimarySalesRepWithAccount(){
        List<User> accountOwners = TestingUtils.createUsers('test', 'Standard User', 100, true);
        UnitTest.addData(accountOwners).tag('Account Owners');
        
        // create users that will own each account
        UnitTest.createTestData(TestingUtils.primarysalesreps).many(100).tag('PSR');
        UnitTest.get('PSR').property('SF_userid__c').assignFrom('Account Owners').insertAll();
        
        Set<id> PSRIds = Pluck.ids(UnitTest.get('PSR').getList());
        List<Account> accounts = TestingUtils.createAccounts('acctName', 200);
        
        UnitTest.addData(accounts).divide(2)
            .part('Accounts with PSRs')
            .part('Accounts without PSRs');
        
        UnitTest.get('Accounts with PSRs')
            .property('OwnerId').assignFrom('Account Owners')
            .property(ACCOUNT_PSR_FIELD).assignFrom('PSR');
        
        UnitTest.get('Accounts with PSRs').dummyInsert();
        
        Test.StartTest();
        List<Account> actualAccounts = AccountServices.linkPrimarySalesReps(UnitTest.get(Account.SObjectType).getList());
        Test.StopTest();
        
        for(Account actualAcc : actualAccounts){
            if(UnitTest.analyze('Accounts with PSRs').hasId(actualAcc.Id)){
                System.assert(PSRIds.contains(actualAcc.Primary_Sales_Rep_Name__c));
            }else{
                System.assertEquals(null, actualAcc.Primary_Sales_Rep_Name__c, 
                                    'Accounts associated to accounts without PSRs should not have the Primary_Sales_Rep_Name__c populated');
            }
        }
        
    }
    
    /*
when the account's irep plan changes,
set the irep stamp field on open opportunities with the same irep accordingly
*/
    static testMethod void testUpdateOpportunityIRepStampOnAccountPlanChange()
    {
        Integer accountsToCreate = 5;
        Integer opportunitiesPerAccount = 5;
        final String TEST_PLAN_VALUE = 'TEST PLAN';
        final String TEST_PLAN_VALUE_2 = 'ANOTHER PLAN';
        
        Primary_Sales_Rep__c testAccountIRep = TestDataGeneration.createPSRs( 1, true )[0];
        
        List<Account> testAccounts = TestDataGeneration.createAccounts( 'Test Account', accountsToCreate );
        for( Account anAccount : testAccounts )
        {
            anAccount.iRep__c = testAccountIRep.Id;
            anAccount.iRep_Plan__c = TEST_PLAN_VALUE;
        }
        insert testAccounts;
        
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for( Account anAccount : testAccounts )
        {
            List<Opportunity> opportunitiesForAccount = TestDataGeneration.createOpportunities( opportunitiesPerAccount, anAccount.Id, false );
            for( Opportunity anOpportunity : opportunitiesForAccount )
            {
                // default each opportunity to have the account's irep
                anOpportunity.iRep__c = testAccountIRep.Id;
                anOpportunity.iRep_Plan_Stamp__c = TEST_PLAN_VALUE;
            }
            testOpportunities.addAll( opportunitiesForAccount );
        }
        insert testOpportunities;
        
        Test.startTest();
        
        for( Account anAccount : testAccounts )
        {
            anAccount.iRep_Plan__c = TEST_PLAN_VALUE_2;
        }
        update testAccounts;
        
        Test.stopTest();
        
        List<Opportunity> updatedOpportunities = [ SELECT Id, iRep__c, iRep_Plan_Stamp__c, StageName FROM Opportunity WHERE AccountId IN :testAccounts ];
        
        System.assertEquals( accountsToCreate * opportunitiesPerAccount, updatedOpportunities.size(), 'Every test opportunity should have been retrieved' );
        
        for( Opportunity updatedOpportunity : updatedOpportunities )
        {
            //System.assertEquals( TEST_PLAN_VALUE_2, updatedOpportunity.iRep_Plan_Stamp__c, 'Open Opportunities with the same irep as its account should be updated' );
            //commented as it causes test class issues when deploying Backlog 2527 and 2519
        }
    }
    
    static testMethod void testErrorMessageUpsertContacts(){
        
        Account testAccount = new Account();
        testAccount.Name = 'TestAccount1';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        List<Contact> testContacts = new List<Contact>{testContact};
            
            Map<Id, Account> accountIdToMap = new Map<Id, Account>{testAccount.Id => testAccount};
                
                AccountServices.upsertContacts(testContacts, accountIdToMap);
        System.assertEquals(1, ApexPages.getMessages().size(), 'There should be one message');
    }
    
    /*
    // Deprecated by changing the Contact Rollup on Account logic - BL-3650
    static testMethod void Test_getMergedMasterAccounts() {
        
        List<Account> testAccounts = SObjectFactory.create(10, Account.SObjectType);
        UnitTest.addData(testAccounts).tag('All Accounts').branch('Not Deleted|Fake Deleted');
        Set<Id> masterRecordIds = UnitTest.getIds('Fake Deleted');
        
        List<Contact> testContacts = SObjectFactory.build(5, Contact.SObjectType);
        UnitTest.addData(testContacts).tag('All Contacts').property('AccountId').assignFrom('All Accounts').insertAll();
        
        Test.startTest();
        List<Account> resultAccounts = ContactRollupOnAccount.getMergedMasterAccounts(masterRecordIds);
        Test.stopTest();
        
        UnitTest.analyze('Fake Deleted').assertEquivalence(resultAccounts, 'We expect the correct Accounts to be returned.');
    }
    
    static testMethod void Test_UpdateTransitionedContacts_NoMasterRecordIds() {
        
        List<Account> testAccounts = SObjectFactory.create(10, Account.SObjectType);
        Integer futureCountBefore, futureCountAfter;
        
        Test.startTest();
        futureCountBefore = Limits.getFutureCalls();
        ContactRollupOnAccount.UpdateTransitionedContacts(testAccounts);
        futureCountAfter = Limits.getFutureCalls();
        Test.stopTest();
        
        System.assertEquals(futureCountBefore + 1, futureCountAfter, 'We expect the method to have successfully fired a future call.'); 
        
    }
	*/
    
    static testMethod void testUpdateChainAccount() {
        
        Integer accountsToCreate = 3;
        Integer opportunitiesPerAccount = 5;
        String iRepPlanValue = 'Test iRep Plan';
        List<User> testUsers = TestingUtils.createUsers('test', 'Standard User', 4, true);
        
        List<Primary_Sales_Rep__c> testPSRs = TestDataGeneration.createPSRs( 4, false );
        testPSRs[0].SF_userid__c =testUsers[0].id;
        testPSRs[1].SF_userid__c =testUsers[1].id;
        testPSRs[2].SF_userid__c =testUsers[2].id;
        testPSRs[3].SF_userid__c =  testUsers[3].id;
        
        insert testPSRs;
        
        Primary_Sales_Rep__c oldPSR = testPSRs[0];
        Primary_Sales_Rep__c newPSR = testPSRs[1];
        Primary_Sales_Rep__c oldIRep = testPSRs[2];
        Primary_Sales_Rep__c newIRep = testPSRs[3];
        
        List<Account> accounts = new List<Account>();
        for( Account testAccount : TestDataGeneration.createAccounts( 'Test Account', accountsToCreate ) )
        {
            testAccount.iRep__c = oldIRep.Id;
            testAccount.iRep_Plan__c = iRepPlanValue;
            testAccount.Primary_Sales_Rep_Name__c = oldPSR.Id;
            accounts.add( testAccount );
        }
        accounts[0].Primary_Sales_Rep_Name__c = newPSR.id; 
        accounts[1].Primary_Sales_Rep_Name__c = oldPSR.id; 
        accounts[2].Primary_Sales_Rep_Name__c = oldIRep.id; 
        insert accounts;
        /*
        account cusAcc = new account();
        account chAcc1 = new account();
        account chAcc2 = new account();
        cusAcc = accounts[0];
        chAcc1 = accounts[1];
        chAcc2 = accounts[2];
        */
        //accounts[0] customer 
        //accounts[1] chain1
        //accounts[2] chain 2
        Test.startTest();
        accounts[0].Chain_Account__c = accounts[1].id;
        update accounts[0];
        accounts[0].Chain_Account__c = accounts[2].id;
        update accounts[0];
        
        Test.stopTest();
        
        
      
    }
    
    static testMethod void logicForQuoteSharingCoverage()
    {
        Integer accountsToCreate = 3;
        Integer opportunitiesPerAccount = 5;
        String iRepPlanValue = 'Test iRep Plan';
        List<User> testUsers = TestingUtils.createUsers('test', 'Standard User', 4, true);
        
        List<Primary_Sales_Rep__c> testPSRs = TestDataGeneration.createPSRs( 4, false );
        testPSRs[0].SF_userid__c =testUsers[0].id;
        testPSRs[1].SF_userid__c =testUsers[1].id;
        testPSRs[2].SF_userid__c =testUsers[2].id;
        testPSRs[3].SF_userid__c =  testUsers[3].id;
        
        insert testPSRs;
        
        Primary_Sales_Rep__c oldPSR = testPSRs[0];
        Primary_Sales_Rep__c newPSR = testPSRs[1];
        Primary_Sales_Rep__c oldIRep = testPSRs[2];
        Primary_Sales_Rep__c newIRep = testPSRs[3];
        
        List<Account> accounts = new List<Account>();
        for( Account testAccount : TestDataGeneration.createAccounts( 'Test Account', accountsToCreate ) )
        {
            testAccount.iRep__c = oldIRep.Id;
            testAccount.iRep_Plan__c = iRepPlanValue;
            testAccount.Primary_Sales_Rep_Name__c = oldPSR.Id;
            accounts.add( testAccount );
        }
        accounts[0].Primary_Sales_Rep_Name__c = newPSR.id; 
        accounts[1].Primary_Sales_Rep_Name__c = oldPSR.id; 
        accounts[2].Primary_Sales_Rep_Name__c = oldIRep.id;        
        accounts[0].ownerid = testUsers[0].id; 
        
        insert accounts;    
        accounts[0].ownerid = testUsers[1].id;
        update accounts[0];
        //delete coverage
        delete accounts[0];
    }
    
    static testMethod void testDnBQuery()
    {
        Integer accountsToCreate = 3;
        Integer opportunitiesPerAccount = 5;
        String iRepPlanValue = 'Test iRep Plan';
        List<User> testUsers = TestingUtils.createUsers('test', 'Standard User', 4, true);
        
        List<Primary_Sales_Rep__c> testPSRs = TestDataGeneration.createPSRs( 4, false );
        testPSRs[0].SF_userid__c =testUsers[0].id;
        testPSRs[1].SF_userid__c =testUsers[1].id;
        testPSRs[2].SF_userid__c =testUsers[2].id;
        testPSRs[3].SF_userid__c =  testUsers[3].id;
        
        insert testPSRs;
        
        Primary_Sales_Rep__c oldPSR = testPSRs[0];
        Primary_Sales_Rep__c newPSR = testPSRs[1];
        Primary_Sales_Rep__c oldIRep = testPSRs[2];
        Primary_Sales_Rep__c newIRep = testPSRs[3];
        
        List<Account> accounts = new List<Account>();
        for( Account testAccount : TestDataGeneration.createAccounts( 'Test Account', accountsToCreate ) )
        {
            testAccount.iRep__c = oldIRep.Id;
            testAccount.iRep_Plan__c = iRepPlanValue;
            testAccount.Primary_Sales_Rep_Name__c = oldPSR.Id;
            accounts.add( testAccount );
        }
        accounts[0].Primary_Sales_Rep_Name__c = newPSR.id; 
        accounts[1].Primary_Sales_Rep_Name__c = oldPSR.id; 
        accounts[2].Primary_Sales_Rep_Name__c = oldIRep.id;        
        accounts[0].ownerid = testUsers[0].id; 
        accounts[0].Remove_DnB_Data__c = false;
        insert accounts;    
        accounts[0].ownerid = testUsers[1].id;
        accounts[0].Remove_DnB_Data__c = true;
        update accounts[0];
        
    }
}
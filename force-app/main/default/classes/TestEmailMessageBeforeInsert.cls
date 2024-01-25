@isTest
private class TestEmailMessageBeforeInsert {

    static List<Case> testCases;
    static List<EmailMessage> testMessages;
    static Map<Id, String> caseIdToExpectedEmail;
    static RecordType inboundCaseType = CaseModel.getInboundCaseRT();
    static RecordType nonInboundCaseType = [select Id from RecordType where DeveloperName != 'Incoming_Fax' and SObjectType = 'Case' and IsActive=True limit 1];
    static Account testAcct;
    static Contact testContact;
    static final String sampleHighPriorityHeader = 'Return-Path: G.T@unisourceworldwide.com\nFrom: <abc_2010@abcfitness.com>\nTo: <abc@unisourcelink.com>, <uwwabcfitness@unisourceworldwide.com>\nImportance: normal\n' + +EmailMessageServices.PRIORITY_KEY_PREFIX + EmailMessageServices.EMAIL_CRITICAL_PRIORITY_NUMBER + ' (Highest)' + '\nX-MimeOLE: Produced By Microsoft MimeOLE V6.1.7';
    static final String sampleNormalPriorityHeader = 'Return-Path: G.T@unisourceworldwide.com\nFrom: <abc_2010@abcfitness.com>\nTo: <abc@unisourcelink.com>, <uwwabcfitness@unisourceworldwide.com>\nImportance: normal\nX-MimeOLE: Produced By Microsoft MimeOLE V6.1.7';
    
    static
    {
        System.runAs(TestingUtils.ADMIN_USER)
        {
            List<RecordType> caseRecordTypes = [Select ID From RecordType Where SObjectType='Case' And IsActive=True Limit 1];
            insert (new InactiveRecordTypes__c(Name=CaseServices.EBUSINESS_RT_NAME,Record_Type_Id__c=caseRecordTypes[0].ID));
            
            if(Qualified_Email_Addresses__c.getValues('@UNISOURCELINK.COM') == null){
                insert new List<Qualified_Email_Addresses__c>{new Qualified_Email_Addresses__c(name = '@UNISOURCELINK.COM')};
            }
            if(Qualified_Email_Addresses__c.getValues('@UNISOURCEWORLDWIDE.COM') == null){
                insert new List<Qualified_Email_Addresses__c>{new Qualified_Email_Addresses__c(name = '@UNISOURCEWORLDWIDE.COM')};
            }
            
        }
    }
    
    private static void setupData(Integer numCases) 
    {
        testCases = new List<Case>();
        testMessages = new List<EmailMessage>();
        caseIdToExpectedEmail = new Map<Id, String>();
        
        
        testAcct = new Account( Name = 'Test' );
        insert testAcct;

        testContact = new Contact( LastName = 'someName', AccountId = testAcct.Id );
        insert testContact;
        
        for(Integer i = 0; i<numCases; i++)
        {
            Case c = new Case(RecordTypeId=inboundCaseType.Id, contactId = testContact.Id, accountId = testAcct.Id);
            testCases.add(c);
        }
        insert testCases;
        
        CaseNotification.caseTriggerAfterIsRunning = false;
        
        Integer counter = 0;
        for(Case c : testCases)
        {
            EmailMessage em = new EmailMessage(ParentId = c.Id);
            // Trigger expects email from a certain domain, unisourcelink.com is one of them
            em.ToAddress = 'foo' + ++counter + '@unisourcelink.com';
            em.ToAddress = em.ToAddress.ToUpperCase();
            // We set the field to UPPER in the trigger, do same here
            caseIdToExpectedEmail.put(c.Id, em.ToAddress);
            testMessages.add(em);
        }
         
     
     
        
        insert testMessages;
    }
    
    /*
    1) We need to make sure email origins are still populated
    2) If case is a priority case or qualifies for parsing by subject, we still have to do that
    */
    private static testMethod void testContactAssignment()
    {
        final Integer BULK_NUMBER = 50;
        final String sampleEmailNotInCustomSettings = 'normalemail@sample.com';
        final Email_Origins_E2C_Search_Contact__c assignAMBMOrigin = new Email_Origins_E2C_Search_Contact__c(Name='Test', Email__c='assign@UNISOURCELINK.COM', Assign_AM_BM__c=true);
        final Email_Origins_E2C_Search_Contact__c noAssignAMBMOrigin = new Email_Origins_E2C_Search_Contact__c(Name='Test Two', Email__c='dontassign@UNISOURCELINK.COM', Assign_AM_BM__c=false);
     
         
        
        insert new List<Email_Origins_E2C_Search_Contact__c> {assignAMBMOrigin,noAssignAMBMOrigin};
        
        /* Create Two In-Office Primary Sales Reps, and Two Out-of-Office Primary Sales Reps*/
        
        List<User> inOfficeUsers = TestingUtils.createUsers('Test','CSP with Create Order',2,false);
        for(User u : inOfficeUsers)
        {
            u.Working_Status__c = 'In Office';
        }
        
        List<User> outOfOfficeUsers = TestingUtils.createUsers('Test','CSP with Create Order',2,false);
        String outOfOfficeWorkingStatus = (new List<String> (EmailMessageServices.outOfOfficeStatuses))[0];
        for(User u : outOfOfficeUsers)
        {
            u.Working_Status__c = outOfOfficeWorkingStatus;
        }
        
        List<User> allUsers = new List<User>();
        allUsers.addAll(inOfficeUsers);
        allUsers.addAll(outOfOfficeUsers);
        insert allUsers;
        
        List<Primary_Sales_Rep__c> inOfficePSRs = new List<Primary_Sales_Rep__c>();
        for(User u : inOfficeUsers)
        {
            Primary_Sales_Rep__c psr = TestingUtils.createPSRs(1, u.CommunityNickname, u.CommunityNickname, false)[0];
            psr.SF_userid__c = u.ID;
            inOfficePSRs.add(psr);
        }
        
        List<Primary_Sales_Rep__c> outOfOfficePSRs = new List<Primary_Sales_Rep__c>();
        for(User u : outOfOfficeUsers)
        {
            Primary_Sales_Rep__c psr = TestingUtils.createPSRs(1, u.CommunityNickname, u.CommunityNickname, false)[0];
            psr.SF_userid__c = u.ID;
            outOfOfficePSRs.add(psr);
        }
        
        List<Primary_Sales_Rep__c> allPSRs = new List<Primary_Sales_Rep__c>();
        allPSRs.addAll(outOfOfficePSRs);
        allPSRs.addAll(inOfficePSRs);
        insert allPSRs;
        
         
        
        List<Case> cases = TestingUtils.createCases(BULK_NUMBER, false);
        for(Case c : cases)
        {
         
        }
        insert cases;
                
        List<Account> ulsPrimaryAccounts = TestingUtils.createAccounts('Test Account', cases.size());
        for(Account a : ulsPrimaryAccounts)
        {
            a.Is_ULS_Primary_Acct__c = true;
        }
        insert ulsPrimaryAccounts;
        
        Map<ID, ID> accountToExpectedAMBMCaseOwner = new Map<ID, ID>();
        Set<ID> accountsWithoutAMBMOwnerAssignments = new Set<ID>();
        for(Integer i = 0; i < ulsPrimaryAccounts.size(); i++)
        {
            Integer modResult = Math.mod(i,4);
            if(modResult==0)
            {
                ulsPrimaryAccounts[i].Account_Manager__c = inOfficePSRs[0].ID;
                ulsPrimaryAccounts[i].Account_Manager_Backup__c = inOfficePSRs[1].ID;
                accountToExpectedAMBMCaseOwner.put(ulsPrimaryAccounts[i].ID,inOfficePSRs[0].SF_userid__c);
            }
            else if(modResult==1)
            {
                ulsPrimaryAccounts[i].Account_Manager__c = outOfOfficePSRs[0].ID;
                ulsPrimaryAccounts[i].Account_Manager_Backup__c = inOfficePSRs[1].ID;
                accountToExpectedAMBMCaseOwner.put(ulsPrimaryAccounts[i].ID,inOfficePSRs[1].SF_userid__c);
            }
            else if(modResult==2)
            {
                ulsPrimaryAccounts[i].Account_Manager__c = outOfOfficePSRs[0].ID;
                ulsPrimaryAccounts[i].Account_Manager_Backup__c = outOfOfficePSRs[1].ID;
                accountsWithoutAMBMOwnerAssignments.add(ulsPrimaryAccounts[i].ID);
            }
            else if(modResult==3)
            {
                ulsPrimaryAccounts[i].Account_Manager__c = inOfficePSRs[0].ID;
                ulsPrimaryAccounts[i].Account_Manager_Backup__c = outOfOfficePSRs[1].ID;
                accountToExpectedAMBMCaseOwner.put(ulsPrimaryAccounts[i].ID,inOfficePSRs[0].SF_userid__c);
            }
        }
        
        update ulsPrimaryAccounts;
        
        Account childAccount = TestingUtils.createAccount('Child Account');
        childAccount.Is_ULS_Primary_Acct__c = false;
        childAccount.Account_Manager__c = inOfficePSRs[0].ID;
        insert childAccount;
        
        List<Contact> contacts = TestingUtils.createContacts('Test', ulsPrimaryAccounts.size(), false);
        for(Integer i = 0; i < contacts.size(); i ++)
        {
            contacts[i].AccountId = ulsPrimaryAccounts[i].ID;
        }
                
        List<EmailMessage> emails = new List<EmailMessage>();
        
        List<EmailMessage> emailMessages = new List<EmailMessage>();
        for(Integer i = 0; i < contacts.size(); i++)
        {
            contacts[i].Email = 'test'+i+'@unisourcelink.com';
            EmailMessage e = TestingUtils.createEmailMessage(cases[i].ID);
            e.ToAddress = assignAMBMOrigin.Email__c;
            e.FromAddress = contacts[i].Email;
            e.Incoming = true;
            emailMessages.add(e);  
            
        }
        
        /* Note that there is a 1-1-1 relationship between contacts, emails, and cases */
        contacts[1].Email = contacts[0].Email;
        emailMessages[2].toAddress='randomAddressNotInCustomSetting@UNISOURCELINK.COM';
        contacts[3].AccountId = childAccount.ID;
        emailMessages[4].toAddress=noAssignAMBMOrigin.Email__c;
         
        accountsWithoutAMBMOwnerAssignments.add(ulsPrimaryAccounts[4].ID);
        
        final Case caseWithExpectedDuplicateError = cases[0];
        final Case caseWithExpectedNoContactsBecauseNoContact = cases[1];
        final Case caseWithNoErrorOrContactAssignment = cases[2];
        final Case caseWithExpectedNoContactsBecauseNotULSContact = cases[3];
        final Case caseWithInternalDomain = cases[5];
        Set<ID> casesWithoutContactPopulated = new Set<ID> {cases[0].ID,cases[1].ID,cases[2].ID, cases[3].ID, caseWithInternalDomain.ID};
        
        insert contacts;
        
        CaseNotification.caseTriggerAfterIsRunning = false;
        
        Test.startTest();
            insert emailMessages;
        Test.stopTest();
        
        Map<ID, ID> qualifyingCaseToExpectedAccountID = new Map<ID, ID>();
        for(Integer i = 0; i < cases.size(); i++)
        {
            if(!casesWithoutContactPopulated.contains(cases[i].ID))
            {
                qualifyingCaseToExpectedAccountID.put(cases[i].ID,ulsPrimaryAccounts[i].ID);
            }
        }
        
        cases = [SELECT ID, ContactID, AccountID, OwnerID, Routing_Error_Reason__c From Case Where ID IN: cases];
        Set<ID> managerIDs = Pluck.ids(allUsers);
        
        for(Case c : cases)
        {
            if(!casesWithoutContactPopulated.contains(c.ID))
            {
                System.assertEquals(null,c.Routing_Error_Reason__c,'If we have succesfully populated a contact on the case, we will not have a routing error');
                 
                 
                if(accountsWithoutAMBMOwnerAssignments.contains(c.AccountID))
                    System.assert(!managerIDs.contains(c.OwnerID),'If the case does not have an email origin that is configured such that the trigger will assign it to the account manager or backup manager or if the account manager and the backup manager are out of office, then we do not expect this case to be assigned to an account manager or backup manager\n' +  + (new Map<ID,Account>(ulsPrimaryAccounts)).get(c.AccountID) + '\n\n' + c + '\n\n' + allUsers + '\n\n' + allPSRs);
                 
                 
            }
            else
            {
                if(c.ID==caseWithExpectedDuplicateError.ID)
                { 
                    System.assertEquals(null,c.AccountID,'When there is a duplicate contacts routing error on the case, we will not populate the account field of the case');
                    System.assertEquals(null,c.ContactID,'When there is a duplicate contacts routing error on the case, we will not populate the contact field of the case');
                     
                    System.assert(!managerIDs.contains(c.OwnerID),'When there is a duplicate contacts routing error on the case, we will never assign the case to the account manager or backup manager');
                }
                else if(c.ID==caseWithExpectedNoContactsBecauseNoContact.ID)
                {
                     
                    System.assertEquals(null,c.ContactID,'Where there is a contact not found error on the case, we will not populate the contact field of the case');
                    System.assertEquals(null,c.AccountID,'Where there is a contact not found error on the case, we will not populate the account field of the case');
                    System.assert(!managerIDs.contains(c.OwnerID),'Where there is a contact not found error on the case, we will never assign the case to the account manager or backup manager');
                }
                else if(c.ID==caseWithExpectedNoContactsBecauseNotULSContact.ID)
                {
                     
                    System.assertEquals(null,c.ContactID,'When the case that originates from an email message is from an address that belongs to no ULS contact in the system, we will not populate the contact field of the case');
                    System.assertEquals(null,c.AccountID,'When the case that originates from an email message is from an address that belongs to no ULS contact in the system, we will not populate the account field of the case');
                    System.assert(!managerIDs.contains(c.OwnerID),'When the case that originates from an email message is from an address that belongs to no ULS contact in the system, we will never assign the case to the account manager or backup manager');
                }
                else if(c.ID==caseWithNoErrorOrContactAssignment.ID)
                {
                    System.assertEquals(null,c.Routing_Error_Reason__c,'When the case does not have an email origin that would qualify for a contact auto-populate then we do not attempt any contact auto-populating. Consequently we will not record the routing error.');
                    System.assertEquals(null,c.ContactID,'When the case does not have an email origin that would qualify for a contact auto-populate then we will not populate the contact');
                    System.assert(!managerIDs.contains(c.OwnerID),'When the case does not have an email origin that would qualify for a contact auto-populate, we will never assign the case to the account manager or backup manager');
                }
                else if(c.ID==caseWithInternalDomain.ID)
                {
                     
                     
                     
                     
                }
            }
        }
    }
    
    private static testMethod void testCasePriority() 
    {
        final Integer BULK_NUMBER = 40;
        
        testCases = TestingUtils.createCases(inboundCaseType.Id,BULK_NUMBER);
        
        //Ensure that if a case is already critical priority it is not reset to a lesser priority.
        
        testCases[1].Priority = EmailMessageServices.CASE_CRITICAL_PRIORITY;
        Integer expectedHighPriorityCases = 1;
        
        insert testCases;
        
        CaseNotification.caseTriggerAfterIsRunning = false;
        
        Integer counter = 0;
        
        testMessages = new List<EmailMessage>();
        for(Case c : testCases)
        {
            EmailMessage em = TestingUtils.createEmailMessage(c.Id);
            if(Math.mod(counter,2)==0)
            {
                expectedHighPriorityCases++;
                em.Headers = sampleHighPriorityHeader;
            }
            else
            {
                em.Headers = sampleNormalPriorityHeader;
            }
            
            testMessages.add(em);
            
            counter++;
        }
         
    
     
        
        Test.startTest();
            insert testMessages;
        Test.stopTest();
        
        testCases = [SELECT Id, Priority FROM Case WHERE Id in :testCases AND Priority =: EmailMessageServices.CASE_CRITICAL_PRIORITY];
        System.assertEquals(expectedHighPriorityCases,testCases.size(),'We expect as many critical priority cases as there were high priority emails (one-to-one correspondance)');
    }
    
    
    
    private static testMethod void testNullEmail()
    {

        testAcct = new Account( Name = 'Test' );
        insert testAcct;

        testContact = new Contact( LastName = 'someName', AccountId = testAcct.Id );
        insert testContact;

        // Verify no exception is thrown if an EmailMessage is inserted w/out a ToAddress
        Case c = new Case(RecordTypeId=inboundCaseType.Id, contactId = testContact.Id, accountId = testAcct.Id);
        insert c;
        
        EmailMessage em = new EmailMessage(ParentId = c.Id);
        insert em;
        
        c = [select Id, Email_Origin__c from Case where Id = :c.Id];
        
        System.assertEquals(null, c.Email_Origin__c);
    }
    
    private static testMethod void testSingleInsert()
    {
        setupData(1);       
        
        testCases = [select Id, Email_Origin__c from Case where Id in :testCases];
        for(Case c : testCases)
        {
            System.assertEquals(caseIdToExpectedEmail.get(c.Id), c.Email_Origin__c);
        }
    }
    
    private static testMethod void testNonInbound()
    {
        
        testAcct = new Account( Name = 'test' );
        insert testAcct;

        testContact = new Contact( LastName = 'someName', AccountId = testAcct.Id );
        insert testContact;     
        
        Case c = new Case(RecordTypeId=nonInboundCaseType.Id, contactId = testContact.Id, accountId = testAcct.Id);
        insert c;
        
        EmailMessage em = new EmailMessage(ParentId = c.Id);
        insert em;
        
        c = [select Id, Email_Origin__c from Case where Id = :c.Id];
        
        System.assertEquals(null, c.Email_Origin__c);
    }
    
    private static testMethod void testMultipleInsert()
    {
        setupData(20);
                
        testCases = [select Id, Email_Origin__c from Case where Id in :testCases];
        for(Case c : testCases)
        {
            System.assertEquals(caseIdToExpectedEmail.get(c.Id), c.Email_Origin__c);
        }
    }

    // Examining specific failure of solution
    private static testMethod void testCCFieldWithBlankToField() {

        testAcct = new Account( Name = 'Test' );
        insert testAcct;

        testContact = new Contact( LastName = 'someName', AccountId = testAcct.Id );
        insert testContact;


        Case c = new Case( RecordTypeId = inboundCaseType.Id, contactId = testContact.Id, accountId = testAcct.Id );
        insert c;
        
        EmailMessage em = new EmailMessage( ParentId = c.Id );
        em.CcAddress = 'NEPackaging@unisourcelink.com';
        insert em;      
        
        Case resolvedCase = [select Id, Email_Origin__c from Case where Id = :c.Id];
        
        System.assertEquals( 'NEPackaging@unisourcelink.com'.toUpperCase(), resolvedCase.Email_Origin__c );
        
    }
    
    // Examining another specific failure of solution
    private static testMethod void testMultiCCs() {

        testAcct = new Account( Name = 'Test' );
        insert testAcct;

        testContact = new Contact( LastName = 'someName', AccountId = testAcct.Id );
        insert testContact;


        Case c = new Case( RecordTypeId = inboundCaseType.Id, contactId = testContact.Id, accountId = testAcct.Id );
        insert c;
        
        EmailMessage em = new EmailMessage( ParentId = c.Id );
        em.CcAddress = 'NEPackaging@unisourcelink.com; NEPackaging2@unisourcelink.com; NEPackaging3@unisourcelink.com; ';
        insert em;      
        
        Case resolvedCase = [select Id, Email_Origin__c from Case where Id = :c.Id];
        
        System.assert( resolvedCase.Email_Origin__c.contains( 'NEPackaging@unisourcelink.com'.toUpperCase() ) );
        System.assert( resolvedCase.Email_Origin__c.contains( 'NEPackaging2@unisourcelink.com'.toUpperCase() ) );
        System.assert( resolvedCase.Email_Origin__c.contains( 'NEPackaging3@unisourcelink.com'.toUpperCase() ) );
        
    }
    
    private static testMethod void testFreightSubjectParseTrigger() {

        UnitTest.createTestData(TestingUtils.cases).single().tag('PreExisting Master Case').assign('Order_Number__c','12345').insertAll();

        UnitTest.createTestData(TestingUtils.cases).many(100).tag('Incoming Cases').divide(2).part('Cases Originating From UFreight Groupbox').part('Cases With Other Origins');
        UnitTest.get('Cases Originating From UFreight Groupbox').tag('Case With Qualifying Email');
 
        UnitTest.get('Case With Qualifying Email').divide(2).part('Response Cases With Qualifying Email').part('Nonresponse Cases With Qualifying Email');
 
 
        UnitTest.get('Response Cases With Qualifying Email').divide(2).part('Response Cases With Parent And Qualifying Email').part('Response Cases Without Parent And Qualifying Email');
         


        UFreight_Groupbox__c validOriginOne = new UFreight_Groupbox__c(Name='Test', Email_Address__c = 'sample@unisourcelink.com');
        UFreight_Groupbox__c validOriginTwo = new UFreight_Groupbox__c(Name='Test2', Email_Address__c = 'SAMPLE2@UNISOURCELINK.COM');
        insert new List<UFreight_Groupbox__c> {validOriginOne, validOriginTwo};
        List<String> validEmailOrigins = new List<String> {validOriginOne.Email_Address__c, validOriginTwo.Email_Address__c};
        
        final String invalidOrigin = 'invalid@unisourcelink.com';
        
        UnitTest.get('Cases Originating From UFreight Groupbox').newAttribute('*To Address*').assignFrom(validEmailOrigins);
        UnitTest.get('Cases With Other Origins').newAttribute('*To Address*').assign(invalidOrigin)
                                                .newAttribute('*Email Subject*').assign('RE: 01234 ULS sspencer@hbsemail.com 09/13/13 Guaranteed')
                                                .newAttribute('*Email Body*').assign('This is an email body')
                                                .newAttribute('*Expected Order#*').assign(null)
                                                .newAttribute('*Expected Sender Email*').assign(null)
                                                .newAttribute('*Expected Delivery Date*').assign(null)
                                                .newAttribute('*Expected Parent*').assign(null);

        UnitTest.get('Response Cases With Parent And Qualifying Email').newAttribute('*Email Subject*').assign('re: Fwd: 12345 GUARANTEED - WRIGHT PRINTING - 09/13/2013')
                                                                       .newAttribute('*Email Body*').assign('This is an email body')
                                                                       .newAttribute('*Expected Order#*').assign('12345')
                                                                       .newAttribute('*Expected Sender Email*').assign('sspencer@hbsemail.com')
                                                                       .newAttribute('*Expected Delivery Date*').assign(Date.parse('09/13/13'))
                                                                       .newAttribute('*Expected Parent*').assignFrom('PreExisting Master Case');
        UnitTest.get('Response Cases Without Parent And Qualifying Email').newAttribute('*Email Subject*').assign('RE: 98765 Guaranteed - ULS - 09/13/2013')
                                                                       .newAttribute('*Email Body*').assign('This is an email body')
                                                                       .newAttribute('*Expected Order#*').assign('98765')
                                                                       .newAttribute('*Expected Sender Email*').assign('sspencer@hbsemail.com')
                                                                       .newAttribute('*Expected Delivery Date*').assign(Date.parse('09/13/13'))
                                                                       .newAttribute('*Expected Parent*').assign(null);
        UnitTest.get('Nonresponse Cases With Qualifying Email').newAttribute('*Email Subject*').assign('44444 Guaranteed - ULS - 09/13/2013 ')
                                                                       .newAttribute('*Email Body*').assign('This is an email body')
                                                                       .newAttribute('*Expected Order#*').assign('44444')
                                                                       .newAttribute('*Expected Sender Email*').assign('sspencer@hbsemail.com')
                                                                       .newAttribute('*Expected Delivery Date*').assign(Date.parse('09/13/13'))
                                                                       .newAttribute('*Expected Parent*').assign(null);
         
         
        

        UnitTest.get('Incoming Cases').property('RecordTypeId').assign(inboundCaseType.Id);
        UnitTest.get('Incoming Cases').insertAll();
        UnitTest.forEach('Incoming Cases').create(1,TestingUtils.emailMessages).tag('Email Message').copyProperty('ID->ParentID').copyProperty('*To Address*->ToAddress').copyProperty('*Email Subject*->Subject').copyProperty('*Email Body*->TextBody');


        UnitTest.get('Email Message').property('Incoming').assign(true);        
        Test.startTest();
            UnitTest.get(emailMessage.SObjectType).insertAll(); // This fires the trigger we're testing
        Test.stopTest();

        List<Case> casesQueried = [Select Id, Order_Number__c, Delivery_Date__c, ParentID FROM Case WHERE Id in : UnitTest.get('Incoming Cases').getList() ];
        System.assertEquals(UnitTest.get('Incoming Cases').getList().size(), casesQueried.size(), 'The expected size of the queried cases differs from size of inserted cases');
        for (Case c : casesQueried) {
            String expectedOrderNumber = (String) UnitTest.analyze('Incoming Cases').selectById(c.ID).getPropertyValue('*Expected Order#*');
            String expectedSenderEmail = (String) UnitTest.analyze('Incoming Cases').selectById(c.ID).getPropertyValue('*Expected Sender Email*');
            Date expectedDeliveryDate = (Date) UnitTest.analyze('Incoming Cases').selectById(c.ID).getPropertyValue('*Expected Delivery Date*');
            Id expectedParent = (ID) UnitTest.analyze('Incoming Cases').selectById(c.ID).getPropertyValue('*Expected Parent*');
            
            System.assertEquals(expectedOrderNumber, c.Order_Number__c, 'The expected order number was not found in the Order_Number__c field of the created Case');
            System.assertEquals(expectedDeliveryDate, c.Delivery_Date__c, 'The expected delivery date was not found in the Delivery_Date__c field of the created Case');
            System.assertEquals(expectedParent, c.ParentID, 'For any response case with an order number that matches the order number of a preexisting case, we expect to link that case with the master parent case with the same order number');
        }
    }
    
    static testMethod void testStampFromAddress(){
        String TEST_TO_ADDRESS = 'test@unisourcelink.com';
        String TEST_EMAIL = 'test@test.com';
        String TEST_MULTIPLE_EMAIL = 'multiple@test.com';
        List<Case> cases = TestingUtils.createCases(60, false);
        UnitTest.addData(cases).tag('All Cases').divide(3)
                .part('Cases with no Email Message associated to them')
                .part('Cases with Single Email Message associated to them')
                .part('Cases with multiple Email Messages associated to them');
        UnitTest.get('All Cases').property('RecordTypeId').assign(inboundCaseType.Id);
                
        UnitTest.get('All Cases').insertAll();
        
        List<EmailMessage> emails = TestingUtils.createEmailMessages(null, 80);
        
        UnitTest.addData(emails).tag('all emails').divide(2)
                .part('emails inserted before')
                .part('emails inserted after');
                
        UnitTest.get('emails inserted before').divide(2)
                .part('emails for cases with single emails associated')
                .part('emails for cases with multiple emails associated inserted before');
        
        Set<Id> casesWithSingleEMIdsSet = Pluck.Ids(UnitTest.get('Cases with Single Email Message associated to them').getList());
        List<Id> casesWithSingleEMIds = new List<Id>( casesWithSingleEMIdsSet );    
        UnitTest.get('emails for cases with single emails associated')
                .property('parentId').assignFrom(casesWithSingleEMIds)
                .property('FromAddress').assign(TEST_EMAIL)
                .property('ToAddress').assign(TEST_TO_ADDRESS);
                
        Set<Id> casesWithMultipleEMIdsSet = Pluck.Ids(UnitTest.get('Cases with multiple Email Messages associated to them').getList());
        List<Id> casesWithMultipleEMIds = new List<Id>( casesWithMultipleEMIdsSet );    
        UnitTest.get('emails for cases with multiple emails associated inserted before')
                .property('parentId').assignFrom(casesWithMultipleEMIds)
                .property('FromAddress').assign(TEST_MULTIPLE_EMAIL)
                .property('ToAddress').assign(TEST_TO_ADDRESS);
                
        UnitTest.get('emails inserted after')
                .property('parentId').assignFrom(casesWithMultipleEMIds)
                .property('FromAddress').assign(TEST_EMAIL)
                .property('ToAddress').assign(TEST_TO_ADDRESS);

        UnitTest.get('all emails').property('Incoming').assign(true);
        
        Test.startTest();
            UnitTest.get('emails inserted before').InsertAll();
            UnitTest.get('emails inserted after').InsertAll();
        Test.stopTest();
        
        List<Case> actualCases = [SELECT Id, From_Address_of_Originating_Email__c FROM  Case];
        Set<Id> casesWithNoEMIds = Pluck.ids(UnitTest.get('Cases with no Email Message associated to them').getList());
        for(Case eachCase: actualCases)
        {
            if(casesWithNoEMIds.contains(eachCase.Id)){
                System.assertEquals(null, eachCase.From_Address_of_Originating_Email__c, 
                                'the From_Address_of_Originating_Email__c of the case should be blank');
            }
            if(casesWithSingleEMIdsSet.contains(eachCase.Id)){
                System.assertEquals(TEST_EMAIL, eachCase.From_Address_of_Originating_Email__c, 
                                'From_Address_of_Originating_Email__c of the case should be same as the from address of the associated email message'); 
            }
            if(casesWithMultipleEMIdsSet.contains(eachCase.Id)){
                System.assertEquals(TEST_MULTIPLE_EMAIL, eachCase.From_Address_of_Originating_Email__c, 
                                'From_Address_of_Originating_Email__c of the case should be same as the from address of the email message that was used to create the case');
            }
        }
    }
}
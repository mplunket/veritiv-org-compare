public class TestDataGeneration {

    public static final String LEAD_SOURCE = 'Web';
    public static final String LEAD_DEPT = 'Marketing';
    public static final String LEAD_STATUS = '1-Identify';

    public static final String SINGLE_EMAIL = 'bobaa@smsith.com';

    public static final Id TEST_ACCOUNT_ID = createAccount('Test Account', true).Id;

    private static Integer PSRNetworkIdOffSet = 1;

    public static void generateTestLeadBatch( Integer numOfLeads, String testEmail, Boolean initialEmailOpt, List<Lead> testLeads ) {

        generateTestLeadBatch( numOfLeads, testEmail, initialEmailOpt, testLeads, true );

    }

    public static void generateTestLeadBatch( Integer numOfLeads, String testEmail, Boolean initialEmailOpt, List<Lead> testLeads, Boolean willInsert ) {

        for( Integer i = 0; i < numOfLeads; i++ )
            testLeads.add( TestDataGeneration.generateTestLead( testEmail, initialEmailOpt ) );

        if ( willInsert )
            insert testLeads;

    }

    public static void generateTestContactBatch( Integer numOfContacts, String testEmail, Boolean initialEmailOpt, List<Contact> testContacts ) {

        generateTestContactBatch( numOfContacts, testEmail, initialEmailOpt, testContacts, true );
    }

    public static void generateTestContactBatch( Integer numOfContacts, String testEmail, Boolean initialEmailOpt, List<Contact> testContacts, Boolean willInsert ) {

        for( Integer i = 0; i < numOfContacts; i++ )
            testContacts.add( TestDataGeneration.generateTestContact( testEmail, initialEmailOpt ) );

        if ( willInsert )
            insert testContacts;

    }

    public static Lead generateTestLead( String email, String eloquaRating ) {

        return generateTestLead( 'Bob', 'Smith', email, false, eloquaRating, 'Some Company', false );
    }

    public static Lead generateTestLead( String email, Boolean emailOptOut ) {

        return generateTestLead( 'Bob', 'Smith', email, emailOptOut, '', 'Some Company', false );
    }

    public static Lead generateTestLead( String firstName, String lastName, String email, Boolean emailOptOut, String eloquaRating, String companyName, Boolean willInsert ) {

        Lead testLead = new Lead();

        testLead.FirstName = firstName;
        testLead.LastName = lastName;
        testLead.Company = companyName;
        testLead.Department__c = LEAD_DEPT;
        testLead.Status = LEAD_STATUS;
        testLead.LeadSource = LEAD_SOURCE;
        testLead.Email = email;
        testLead.HasOptedOutOfEmail = emailOptOut;
        testLead.Eloqua_Lead_Rating__c = eloquaRating;

        if ( willInsert )
            insert testLead;

        return testLead;

    }

    public static Contact generateTestContact( String email, String eloquaRating ) {

        return generateTestContact( 'Doe', TEST_ACCOUNT_ID, email, false, eloquaRating, false );
    }

    public static Contact generateTestContact( String email, Boolean emailOptOut ) {

        return generateTestContact( 'Doe', TEST_ACCOUNT_ID, email, emailOptOut, '', false );
    }

    public static Contact generateTestContact( String lastName, Id accountId, String email, Boolean emailOptOut, String eloquaRating, Boolean willInsert ) {

        Contact testContact = new Contact();

        testContact.LastName = lastName;
        testContact.Email = email;
        testContact.AccountId = accountId;
        testContact.HasOptedOutOfEmail = emailOptOut;
        testContact.Eloqua_Lead_Rating__c = eloquaRating;

        if ( willInsert )
            insert testContact;

        return testContact;

    }

    public static User getTestUser(String userName, String profileName)
    {
        String profileId;
        try
        {
            profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        }
        catch(Exception ex)
        {
            System.debug(ex);
            System.assert(false, 'No profile exists with name'+ profileName);
        }
        User testUser = new User();
        testUser.LastName = 'test ' + UserName;
        
        Integer aliasLength = Schema.SObjectType.User.fields.Alias.getLength(); 
        testUser.Alias = (String) new SObjectFieldProviders.UniqueFixedLengthStringProvider(aliasLength).getValue();
                                                   
        testUser.Network_Id__c = testUser.Alias;
        testUser.Email = UserName+'@unisourcelink.com';
        testUser.Username = UserName+UserName+'@test.com';
        testUser.CommunityNickname = 'a'+UserName;
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.ProfileId = profileId;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Country = 'USA';
        testUser.IsActive = true;

        return testUser;
    }

    public static User ADMIN_USER = createUser('TestAd', 'System Administrator', false);

    public static User createUser(String userName, String profileName, Boolean insertUser)
    {
           return createUsers(userName, profileName, 1, insertUser)[0];
    }

    public static List<User> createUsers(String userName, String profileName, Integer size, Boolean insertUsers)
    {

           List<User>allUsers = new List<User>();

           String profileId;
            try
            {
                profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
            }
            catch(Exception ex)
            {
                System.debug(ex);
                System.assert(false, 'No profile exists with name'+ profileName);
            }

            for(Integer i = 0; i < size; i++)
            {
                User testUser = getTestUserWithProfileId(userName + i, profileId);

                allUsers.add(testUser);
            }

            if(insertUsers)
            {
               // System.RunAs(ADMIN_USER)
              //  {
                    insert allUsers;
              //  }
            }

            return allUsers;

    }

    private static User getTestUserWithProfileId(String userName, String profileId)
    {
        User testUser = new User();
        testUser.LastName = 'test ' + UserName;
        
        Integer aliasLength = Schema.SObjectType.User.fields.Alias.getLength(); 
        testUser.Alias = (String) new SObjectFieldProviders.UniqueFixedLengthStringProvider(aliasLength).getValue();
                                                   
        testUser.Network_Id__c = testUser.Alias;
        testUser.Email = UserName+'@unisourcelink.com';
        testUser.Username = UserName+UserName+'@test.com';
        testUser.CommunityNickname = 'a'+UserName;
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.ProfileId = profileId;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Country = 'USA';
        testUser.IsActive = true;

        return testUser;
    }

    public static Account createAccount(String acctName)
    {
        return createAccounts(acctName, 1)[0];
    }

    public static Account createAccount(String acctName, Boolean doInsert)
    {
        Account account = createAccounts(acctName, 1)[0];
        if(doInsert)
            insert account;

        return account;
    }

    public static List<Account> createAccounts(String acctName, Integer size)
    {
        List<Account>allAccounts = new List<Account>();

        for(Integer i = 0; i < size; i++)
        {
            allAccounts.add(new Account(Name = acctName+i,Account_Vertical__c='Test'));
        }

        return allAccounts;
    }

    public static Case createCase(Id rTypeId)
    {
        return createCases(rTypeId, 1)[0];
    }

    public static List<Case> createCases(Id rTypeId, Integer size)
    {

        Account testAcct = new Account( Name = 'test' );
        insert testAcct;

        Contact testContact = new Contact( LastName = 'someName', AccountId = testAcct.Id );
        insert testContact;

        List<Case>allCases = new List<Case>();

        for(Integer i = 0; i < size; i++)
        {
            allCases.add(new Case(RecordTypeId = rTypeId, contactId = testContact.Id, accountId = testAcct.Id));
        }

        return allCases;
    }

    public static EmailMessage createEmailMessage(Id parentId)
    {
        return createEmailMessages(parentId, 1)[0];
    }

    public static List<EmailMessage> createEmailMessages(Id parentId, Integer size)
    {
        List<EmailMessage>allEmailMessages = new List<EmailMessage>();

        for(Integer i = 0; i < size; i++)
        {
            allEmailMessages.add(new EmailMessage(ParentId = parentId));
        }

        return allEmailMessages;
    }

    public static Attachment createAttachment(Id parentId)
    {
        return createAttachments(parentId, 1)[0];
    }

    public static List<Attachment> createAttachments(Id parentId, Integer size)
    {
        List<Attachment>allEmailAttachments = new List<Attachment>();

        for(Integer i = 0; i < size; i++)
        {
            Attachment attachment = new Attachment();
            attachment.body = Blob.valueOf( 'this is an attachment test ' + i);
            attachment.name = 'fake attachment ' + i;

            attachment.parentId = parentId;

            allEmailAttachments.add(attachment);
        }

        return allEmailAttachments;
    }

    public static List<Primary_Sales_Rep__c> createPSRs( Integer numToCreate, Boolean doInsert )
    {
        List<Primary_Sales_Rep__c> psrsToInsert = new List<Primary_Sales_Rep__c>();

        for( Integer index = 0; index < numToCreate; index++ )
        {
            Primary_Sales_Rep__c newPSR = new Primary_Sales_Rep__c();
            newPSR.Name = 'Joe Test ' + index;
            newPSR.Network_Id__c = '1234' + PSRNetworkIdOffSet++;
            newPSR.Email__c = 'user' + index + '@domain.com';
            psrsToInsert.add( newPSR );
        }

        if( doInsert )
            insert psrsToInsert;



        return psrsToInsert;
    }

    public static List<Opportunity> createOpportunities( Integer numToCreate, Id accountId, Boolean doInsert )
    {
        List<Opportunity> opptysToInsert = new List<Opportunity>();

        for( Integer index = 0; index < numToCreate; index++ )
        {
            Opportunity newOppty = new Opportunity();
            newOppty.AccountId = accountId;
            newOppty.Name = 'test opp' + index;
            newOppty.StageName = '1- Prospect';
            newOppty.CloseDate = Date.today().addDays(365);
            newOppty.Customer_Selling_Margin_Rate__c = 50;
            newOppty.Prod_Category__c = 'ICE MELTER';
            opptysToInsert.add( newOppty );
        }

        if( doInsert )
            insert opptysToInsert;

        return opptysToInsert;
    }

    public static AccountShare createAccountShare( Id userId, Id accountId, String accountLevel, String opptyLevel )
    {
        AccountShare acctShare = new AccountShare();
        acctShare.UserOrGroupId = userId;
        acctShare.AccountId = accountId;
        acctShare.AccountAccessLevel = accountLevel;
        acctShare.OpportunityAccessLevel = opptyLevel;

        return acctShare;
    }

    public static List<Ship_To__c> createShipTos( Integer numShipTos, String baseName, Id accountId, Boolean doInsert )
    {
        List<Ship_To__c> shipTos = new List<Ship_To__c>();

        for( Integer index = 0; index < numShipTos; index++ )
        {
            Ship_To__c newShipTo = new Ship_To__c();
            newShipTo.Name = baseName + index;
            newShipTo.Bill_To_Account__c = accountId;
            shipTos.add( newShipTo );
        }

        if( doInsert )
        {
            insert shipTos;
        }

        return shipTos;
    }

    public static List<Quote__c> createQuotes( Integer numQuotes, String baseName, Id accountId, Boolean doInsert )
    {
        List<Quote__c> quotes = new List<Quote__c>();

        for( Integer index = 0; index < numQuotes; index++ )
        {
            Quote__c newQuote = new Quote__c();
            newQuote.Account__c = accountId;
            newQuote.Subject__c = baseName + index;
            quotes.add( newQuote );
        }

        if( doInsert )
        {
            insert quotes;
        }

        return quotes;
    }

    public static List<Product2> createProducts( Integer numProducts, String baseName, Boolean doInsert )
    {
        List<Product2> products = new List<Product2>();

        for( Integer index = 0; index < numProducts; index++ )
        {
            Product2 newProduct = new Product2();
            newProduct.Name = baseName + index;
            products.add( newProduct );
        }

        if( doInsert )
        {
            insert products;
        }

        return products;
    }
    
    public static List<Servicing_Division__c> createServicingDivisions( Integer numDivisions, Boolean doInsert )
    {
        List<Servicing_Division__c> servicingDivisions = new List<Servicing_Division__c>();

        for( Integer index = 0; index < numDivisions; index++ )
        {
            Servicing_Division__c sdivision = new Servicing_Division__c();
            servicingDivisions.add( sdivision );
        }

        if( doInsert )
        {
            insert servicingDivisions;
        }

        return servicingDivisions;
    }
    
    
}
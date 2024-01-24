public with sharing class TestingUtils {

    public static Integer uniqueCounter = 0;
    public static UnitTest.DataGenerator primarysalesreps = new PrimarySalesRepDG();
    public static UnitTest.DataGenerator accountTeamMembers = new AccountTeamMemberDG();
    public static UnitTest.DataGenerator emailMessages = new EmailMessageDG();
    public static UnitTest.DataGenerator cases = new CaseDG();
    public static UnitTest.DataGenerator contacts = new ContactDG();
    public static UnitTest.DataGenerator attachments = new AttachmentDG();
    public static UnitTest.DataGenerator opportunities = new OpportunityDG();

    
    
    public static User ADMIN_USER
    {
        get
        {
            if( null == ADMIN_USER )
            {
               return [SELECT Id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
            }
            return ADMIN_USER;
        }
    }

    public static RecordType CUSTOMER_RECORD_TYPE
    {
        get
        {
            if ( CUSTOMER_RECORD_TYPE == null )
            {
                return [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Customer' LIMIT 1];
            }
            return CUSTOMER_RECORD_TYPE;
        }
    }

    public static EntitySubscription createEntitySubscription(Id parentID, Id subscriberID)
    {
        return new EntitySubscription(ParentID=parentID, SubscriberID=subscriberID);
    }

    public static User createUser(String userName, String profileName, Boolean insertUser)
    {
        return createUsers(userName, profileName, 1, insertUser)[0];
    }

    public static Servicing_Division__c createServicingDivision(Boolean toInsert)
    {
        Servicing_Division__c sd = new Servicing_Division__c();
        sd.Name = 'Test Name';
        sd.Division_Country__c = 'USA';
        if(toInsert)
            insert sd;
        return sd;
    }
    
    /*
    //Moved to QuotesForSourcingUtils
    public static Send_To_Sourcing_Quote_Routing__c createSourcingQuoteRouting(String merchSegment, Id sourcingDivision, Id ownerID, Id contactId, Boolean doInsert)
    {
        Send_To_Sourcing_Quote_Routing__c testQuoteRouting = new Send_To_Sourcing_Quote_Routing__c(Merchandising_Segment__c = merchSegment, Servicing_Division__c = sourcingDivision, Queue_Contact__c = contactId);
        
        if(ownerID != null)
            testQuoteRouting.OwnerID = ownerID;
        
        if(doInsert)
            insert testQuoteRouting;
            
        return testQuoteRouting;
    }
    */

    public static List<String> generateUniqueStrings(Integer howMany)
    {
        List<String> strings = new List<String>();
        for(Integer i = 0; i < howMany; i++)
        {
            strings.add('MAT'+(i+uniqueCounter));
            uniqueCounter++;
        }
        return strings;
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
             //   System.assert(false, 'No profile exists with name'+ profileName);
            }

            for(Integer i = 0; i < size; i++)
            {
                uniqueCounter++;
                User testUser = new User();
                testUser.LastName = 'test ' + UserName + 'i';
                testUser.Alias = 'a'+uniqueCounter;
                testUser.Network_Id__c = testUser.Alias;
                testUser.Country = 'USA';
                testUser.Email = UserName+uniqueCounter+'@unisourcelink.com';
                testUser.Username = UserName+uniqueCounter+DateTime.now().getTime()+'@example.com';
                System.debug(testUser.Username);
                testUser.CommunityNickname = 'a'+UserName+uniqueCounter;
                testUser.TimeZoneSidKey = 'America/New_York';
                testUser.LocaleSidKey = 'en_US';
                testUser.EmailEncodingKey = 'ISO-8859-1';
                testUser.ProfileId = profileId;
                testUser.Network_ID__c  = 'a'+uniqueCounter;
                testUser.LanguageLocaleKey = 'en_US';
                testUser.IsActive = true;
                system.debug('testUser.Network_ID__c = '+testUser.Network_ID__c);
                system.debug('testuser = '+testUser);
                allUsers.add(testUser);
            }

            if(insertUsers)
            {
                System.RunAs(ADMIN_USER)
                {
                    insert allUsers;
                }
            }

            return allUsers;
    }

    public static void setupInactiveRecordType()
    {
        // recordtype is NEEDED for test pass
        InactiveRecordTypes__c inactiveRT = new InactiveRecordTypes__c();
        inactiveRT.Name = CaseServices.EBUSINESS_RT_NAME;
        System.runAs( TestingUtils.ADMIN_USER )
        {
            insert inactiveRT; 
        }
    }
    
    public static List<Announcement__c> createCarouselAnnouncements(Integer howMany, Boolean doInsert)
    {
        List<Announcement__c> retList = new List<Announcement__c>();
        for(Integer i = 0; i < howMany; i++)
        {
            retList.add(new Announcement__c( Announcement_HTML__c = 'Content for Announcement '+i, URL_Link__c='test'+i+'.com'));
        }
        if(doInsert) insert retList; 
        return retList;
    }

    public static Contract createContract(ID accountID, ID servicingDivision, Boolean doInsert)
    {
        Contract testContract = new Contract(AccountID = accountID, Division__c = servicingDivision);
        if(doInsert)
            insert testContract;
        return testContract;
    }
    
    public static List<Contract> createContracts( Integer numToCreate, ID accountID, ID servicingDivision, Boolean doInsert)
    {
        List<Contract> testContracts = new List<Contract>();
        for( Integer i = 0; i < numToCreate; i++ )
        {
            Contract testContract = createContract( accountID, servicingDivision, false );
            testContracts.add( testContract );      
        }
        if(doInsert)
            insert testContracts;
        return testContracts;
    }

    public static Group createGroup( String groupName, String typeIn, Boolean doInsert )
    {
        Group testGroup = new Group( Name = groupName, Type = typeIn );

        if( doInsert )
        {
            System.runAs( ADMIN_USER )
            {
                insert testGroup;
            }
        }

        return testGroup;
    }
    
    public static List<Group> createGroups( Integer howMany, String groupName, String typeIn, Boolean doInsert )
    {
        List<Group> groups = new List<Group>();
        for (Integer i = 0 ; i < howMany ; i++){
            groups.add(createGroup(groupName+i, typeIn, false));
        }
        
        if( doInsert )
        {
            System.runAs( ADMIN_USER )
            {
                insert groups;
            }
        }

        return groups;
    }

    public static List<Fax_To_Case_Queue_Assignment__c> createQueueAssignment( Integer numToCreate, String teamLeadName, String teamLeadEmail, Boolean doInsert )
    {
        List<Fax_To_Case_Queue_Assignment__c> testQueueAssignments = new List<Fax_To_Case_Queue_Assignment__c>();
        for( Integer i = 0; i < numToCreate; i++ )
        {
            Fax_To_Case_Queue_Assignment__c queueAssignment = new Fax_To_Case_Queue_Assignment__c();
            queueAssignment.Team_Lead_Name__c = teamLeadName;
            queueAssignment.Team_Lead_Email__c = teamLeadEmail;
            testQueueAssignments.add( queueAssignment );
        }

        if( doInsert )
        {
            insert testQueueAssignments;
        }

        return testQueueAssignments;
    }

    public static Account createAccount(String acctName)
    {
        return createAccounts(acctName, 1)[0];
    }

    public static Account createAccount(String acctName, Boolean doInsert )
    {
        Account testAccount =  createAccounts(acctName, 1)[0];
         if( doInsert )
            insert testAccount;
        return testAccount;
    }

    public static List<Account> createAccounts(String acctName, Integer size)
    {
        
        List<Account>allAccounts = new List<Account>();

        for(Integer i = 0; i < size; i++)
        {
            allAccounts.add(new Account(Name = acctName+i,Account_Vertical__c='Test',Customer_Link_Account__c = true, BillingCountry = 'United States' ));
            
        }

        return allAccounts;
    }
    
    public static List<Account> createAccounts(String acctName, Id owner, Integer size)
    {
        List<Account>allAccounts = new List<Account>();

        for(Integer i = 0; i < size; i++)
        {
            Account acc = new Account(Name = acctName+i,Account_Vertical__c='Test');
            acc.BillingCountry = 'United States';
            if(owner != NULL)
                acc.OwnerId = owner;
                
            allAccounts.add(acc);
        }

        return allAccounts;
    }
    
    public static List<Account> createAccounts(String acctName,Id cust360Id, Integer size, Boolean doInsert)
    {
        List<Account>allAccounts = new List<Account>();

        for(Integer i = 0; i < size; i++)
        {
            allAccounts.add(new Account(Name = acctName+i,C360_Customer_360__c=cust360Id ,Account_Vertical__c='Test', BillingCountry = 'United States'));
            
        }

        if( doInsert )
            insert allAccounts;
            
        return allAccounts;
    }

    public static List<Account> createULSAccounts( Integer numToCreate, String accountName, Boolean doInsert )
    {
        List<Account> allAccounts = new List<Account>();

        for( Integer i = 0; i < numToCreate; i++ )
        {
            Account acc = new Account();
            acc.Name = accountName;
            acc.Account_Vertical__c='Test';
            acc.RecordTypeId = CUSTOMER_RECORD_TYPE.Id;
            allAccounts.add( acc );
        }

        if( doInsert )
            insert allAccounts;

        return allAccounts;
    }

    public static Contact createContact( String firstName, String lastName, Boolean doInsert )
    {
        Contact contact = new Contact();
        contact.FirstName = firstName;
        contact.LastName = lastName;
        contact.MailingState = 'xx';

        if( doInsert )
            insert contact;

        return contact;
    } 
    
    public class ContactDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return TestingUtils.createContacts('test', howMany, false);
        } 
    }
    
    public static List<Contact> createContacts(String lastName, Integer howMany, Boolean doInsert)
    {
        List<Contact> testContacts = new List<Contact>();
        for(Integer i = 0; i <howMany; i++)
        {
            testContacts.add(createContact('Contact'+i,lastName,false));
        }
        
        if(doInsert)
        {
            insert testContacts;
        }
        
        return testContacts;
    }

    public static Opportunity createOpportunity(Id accId, String oppName)
    {
        return createOpportunities( 1, accId, oppName, false )[0];
    }

    public static Opportunity createOpportunity(Id accId, String oppName, Boolean doInsert )
    {
        Opportunity testOpportunity =  createOpportunities( 1, accId, oppName, false )[0];
        
        if( doInsert )
            insert testOpportunity;

        return testOpportunity;
    }

    public static List<Opportunity> createOpportunities( Integer numToCreate, Id accountIdIn, String oppName, Boolean doInsert )
    {
        List<Opportunity> oppties = new List<Opportunity>();
        for( Integer i = 0; i < numToCreate; i++ )
        {
            Opportunity opp = new Opportunity();
            opp.AccountId = accountIdIn;
            opp.Name = oppName + i;
            opp.Customer_Selling_Margin_Rate__c = 10 + i;
            opp.StageName = '1- Prospect';
            opp.CloseDate = Date.today();
            oppties.add( opp );
        }

        if( doInsert )
        {
            insert oppties;
        }

        return oppties;
    }
    
    public class OpportunityDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return TestingUtils.createOpportunities(howMany, null, 'Opp', false);
        } 
    }

    public static Engineered_Package_Project__c createEngineeredPackageProject(Id oppId, String prjName)
    {
        Engineered_Package_Project__c prj = new Engineered_Package_Project__c();
        prj.Name = prjName;
        prj.Opportunity__c = oppId;

        return prj;
    }

    public static Project_Task__c createProjectTask(Id projId, String taskName)
    {

        Project_Task__c prjTask = new Project_Task__c();
        prjTask.Name = taskName;
        prjTask.Project__c = projId;

        return prjTask;
    }

    public static List<Project_Task__c> createProjectTasks(Id projId, String taskName, Integer taskSize)
    {
        List<Project_Task__c> allProjectTasks = new List<Project_Task__c>();
        for(Integer i=0; i < taskSize; ++i)
        {
            allProjectTasks.add(createProjectTask(projId, taskName + i));
        }

        return allProjectTasks;
    }

    public static Case createCase(Id rTypeId)
    {
        return createCases(rTypeId, 1)[0];
    }
    
    public static List<Case> createCases(Integer size, Boolean doInsert)
    {
        List<Case> allCases = new List<Case>();
        for(Integer i = 0; i < size;i++)
        {
            allCases.add(new Case());
        }
        
        if(doInsert)
            insert allCases;
        
        return allCases;
    }
   
    public static List<Case> createCases(Id accId, Integer size,Id rTypeId, Boolean doInsert)
    {
        List<Case>allCases = new List<Case>();

        for(Integer i = 0; i < size; i++)
        {
            allCases.add(new Case(accountId=accId,RecordTypeID=rTypeId));
        }

        if( doInsert )
            insert allCases;
            
        return allCases;
    }
    
    public class CaseDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return TestingUtils.createCases(howMany, false);
        } 
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
            allCases.add(new Case(RecordTypeID=rTypeId, contactId = testContact.Id, accountId = testAcct.Id));
            
        }

        return allCases;
    }
    /*
    public static Case_Record_Type_Mapping__c  createCaseRecordTypeMap(String name, Id id, String subject) 
    {
        Case_Record_Type_Mapping__c crtm = new Case_Record_Type_Mapping__c( Name = name,
                                                                            SFDC_Case_Record_Type_ID__c = id,
                                                                            SFDC_Case_Description__c = subject );
        return crtm;
    }
    */
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
    
    public class EmailMessageDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return TestingUtils.createEmailMessages(null, howMany);
        } 
    }

    public class AttachmentDG implements UnitTest.DataGenerator
    { 
        public List<SObject> generateData(Integer howMany)
        {
            return TestingUtils.createAttachments(null,howMany);
        } 
    }
    
    public static List<Attachment> createAttachments(Id parentId, Integer size)
    {
        List<Attachment>allEmailAttachments = new List<Attachment>();

        for(Integer i = 0; i < size; i++)
        {
            Attachment attachment = new Attachment();
            attachment.body = Blob.valueOf( 'this is an attachment test ' + (uniqueCounter));
            attachment.name = 'fake attachment ' + i+';'+uniqueCounter;
            attachment.ContentType = (Math.mod(i,2) == 1) ? 'text/plain' : 'application/pdf';

            attachment.parentId = parentId;

            allEmailAttachments.add(attachment);
            uniqueCounter++;
        }

        return allEmailAttachments;
    }
    
    public static Attachment createAttachment(Id parentId)
    {
        return createAttachments(parentId, 1)[0];
    }
 
    public static List<Lead> createLeads( Integer numOfLead, String lastName ,  Boolean doInsert )
    {
      
        List<Lead> testLeads = new List<Lead>();

        for ( Integer i = 0; i < numOfLead; i++ )
        {
            Lead theLead = new Lead ();

            theLead.LastName = lastName + i;
            theLead.State__c = '1-Identify';
            theLead.LeadSource = 'Cold Call';
            theLead.CurrencyIsoCode = 'USD';
            theLead.Company = 'Test Company';
            theLead.Country ='United States';

            testLeads.add( theLead );
        }
/*// Added by Sujitha
         TriggerSettings__c mc = new TriggerSettings__c();
       mc.IsVeritivContact__c = true;
       
       try
        {
       insert mc;
         }catch(Exception e)
             {
                system.debug('Error'+ e.getMessage());
              }

       */
       
        if(doInsert)
        {
            insert testLeads;
        }

        return testLeads;
    }

    public static List<Primary_Sales_Rep__c> createPSRs( Integer numToCreate, String nameIn, String networkId, Boolean doInsert )
    {
        List<Primary_Sales_Rep__c> PSRs = new List<Primary_Sales_Rep__c>();
        for( Integer i= 0; i < numToCreate; i++ )
        {
            uniqueCounter++;
            Primary_Sales_Rep__c aPSR = new Primary_Sales_Rep__c();
            if( numToCreate == 1 ) {
                aPSR.Name = nameIn;
                aPSR.Network_ID__c = networkId+uniqueCounter;
            }
            else {
                aPSR.Name = nameIn+i;
                aPSR.Network_ID__c = networkId+i+uniqueCounter;
            }
            PSRs.add( aPSR );
        }

        if( doInsert )
            insert PSRs;

        return PSRs;
    }
    
    public class PrimarySalesRepDG implements UnitTest.DataGenerator
    { 
        /*
        Creates Primary Sales Rep User..
        */
        public List<SObject> generateData(Integer howMany)
        {
            return TestingUtils.createPSRS(howMany, 'tst','n',false);
        } 
    }

    public static List<Case> generateCases( Integer numToCreate, Id accountIdIn, Id contactIdIn, Id recordTypeIdIn, Boolean doInsert )
    {
        List<Case> testCases = new List<Case>();
        for( Integer i = 0; i < numToCreate; i++ )
        {
            Case newCase = new Case( AccountId = accountIdIn, ContactId = contactIdIn, RecordTypeId = recordTypeIdIn );
            testCases.add( newCase );
        }

        if( doInsert )
        {
            insert testCases;
        }

        return testCases;
    }

    public static List<Verticals__c> createVerticals( Integer numToCreate, String nameIn, Boolean doInsert )
    {
        List<Verticals__c> verticals = new List<Verticals__c>();
        for( Integer i= 0; i < numToCreate; i++ )
        {
            Verticals__c aVertical = new Verticals__c();
            aVertical.Name = nameIn;

            verticals.add( aVertical );
        }

        if( doInsert )
            insert verticals;

        return verticals;
    }

    public static List<Vendor_Detail__c> createVendorDetails( Integer numToCreate, String nameIn, Boolean doInsert )
    {
        List<Vendor_Detail__c> vendorDetails = new List<Vendor_Detail__c>();
        for( Integer i= 0; i < numToCreate; i++ )
        {
            Vendor_Detail__c aVendorDetail = new Vendor_Detail__c();
            aVendorDetail.Name = nameIn;
            aVendorDetail.Vendor_Code__c = generateUniqueStrings(1)[0];

            vendorDetails.add( aVendorDetail );
        }

        if( doInsert )
            insert vendorDetails;

        return vendorDetails;
    }

    public static Quote__c createQuote (Account testAcct)
    {
        return createQuotes(testAcct, 1)[0];
    }

    public static List<Quote__c> createQuotes(Account testAcct, Integer size)
    {
        return createQuotes( size, testAcct.id, false );
    }

    public static Ship_To__c createShipTo (Account testAcct, String name)
    {
        return createShipTos(testAcct, name, 1 )[0];
    }

    public static List<Ship_To__c> createShipTos(Account testAcct, String name, Integer size)
    {
        List<Ship_To__c>allShipTos = new List<Ship_To__c>();

        for(Integer i = 0; i < size; i++)
        {
            allShipTos.add(new Ship_To__c(Bill_To_Account__c = testAcct.Id, Name =  name+i));
        }

        return allShipTos;
    }

    //MH : Comment for Deployment on 12/7
    public static AccountTeamMember createAccountTeamMember( Id accountIdIn, Id userIdIn, Boolean doInsert )
    {
        AccountTeamMember anATM = new AccountTeamMember();
        anATM.AccountId = accountIdIn;
        anATM.UserId = userIdIn;

        if( doInsert )
        {
            System.runAs( ADMIN_USER )
            {
                insert anATM;
            }
        }
        return anATM;
    }
    
    public static AccountTeamMember createAccountTeamMember( Id accountIdIn, Id userIdIn, String profileName, Boolean doInsert )
    {
        AccountTeamMember anATM = new AccountTeamMember();
        anATM.AccountId = accountIdIn;
        anATM.UserId = userIdIn;
        anATM.TeamMemberRole = profileName;

        if( doInsert )
        {
            System.runAs( ADMIN_USER )
            {
                insert anATM;
            }
        }
        return anATM;
    }
    
    public class AccountTeamMemberDG implements UnitTest.DataGenerator
    {
        public List<SObject> generateData(Integer howMany)
        {
            List<AccountTeamMember> atms = new List<AccountTeamMember>();
            for(Integer i = 0; i < howMany; i++)
            {
                atms.add(createAccountTeamMember(null,null,false));
            }
            return atms;
        }
    }

    public static OpportunityTeamMember createOpportunityTeamMember( Id opportunityIn, Id userIdIn, Boolean doInsert )
    {
        OpportunityTeamMember anOTM = new OpportunityTeamMember();
        anOTM.OpportunityId = opportunityIn;
        anOTM.UserId = userIdIn;

        if( doInsert )
        {
            System.runAs( ADMIN_USER )
            {
                insert anOTM;
            }
        }
        return anOTM;
    }

    //MH : Comment for Deployment on 12/7
    public static List<Account_Plan__c> createAccountPlans( Integer numToCreate, Id accountIdIn, String nameIn, Boolean doInsert )
    {
        List<Account_Plan__c> acctPlans = new List<Account_Plan__c>();
        for( Integer i = 0; i < numToCreate; i++ )
        {
            Account_Plan__c anAcctPlan = new Account_Plan__c();
            anAcctPlan.Account__c = accountIdIn;
            anAcctPlan.Name = nameIn + i;

            acctPlans.add( anAcctPlan );
        }

        if( doInsert )
            insert acctPlans;

        return acctPlans;
    }

    public static List<Quote__c> createQuotes( Integer numToCreate, Id accountIdIn, Boolean doInsert )
    {
        List<Quote__c> quotes = new List<Quote__c>();
        for( Integer i = 0; i < numToCreate; i++ )
        {
            Quote__c aQuote = new Quote__c();
            aQuote.Account__c = accountIdIn;

            quotes.add( aQuote );
        }

        if( doInsert )
            insert quotes;

        return quotes;
    }
    
    /*
    //Moved to QuotesForSourcingUtils
    public static List<Quote_Line_Item__c> createQuoteLineItems(Quote__c quoteToUse, Integer num, Boolean doInsert)
    {
        List<Quote_Line_Item__c> lineItems = new List<Quote_Line_Item__c>();
        for(Integer i = 0; i < num; i++)
        {
            lineItems.add(new Quote_Line_Item__c(Quote__c = quoteToUse.Id));
        }
        
        if(doInsert)
            insert lineItems;
        
        return lineItems;
    }
    */

    //MH : Comment for Deployment on 12/7
    public static Grant_Access_Level_ATM__c createRelationshipToAccessLevelCS( String nameIn, String accessLevelIn, Boolean doInsert )
    {
        Grant_Access_Level_ATM__c relationshipToAccessLevelCS = new Grant_Access_Level_ATM__c( Name = nameIn, Access_Level__c = accessLevelIn );
        if( doInsert )
        {
            System.runAs( ADMIN_USER )
            {
                insert relationshipToAccessLevelCS;
            }
        }
        return relationshipToAccessLevelCS;
    }
   
    /*Commenting for deployment
    public static List<Customer_Price_List__c> createCustomerPriceLists ( Integer numToCreate, String billTo, String systemName, String divisionName, Boolean doInsert )
    {
        List<Customer_Price_List__c> cpls = new List<Customer_Price_List__c>();
        for( Integer i = 0; i < numToCreate; i++ )
        {
            Customer_Price_List__c aCPL = createCustomerPriceList ( billTo, systemName, divisionName, false );
            cpls.add( aCPL );
        }
        if( doInsert )
            insert cpls;
        return cpls;
    }
    public static Customer_Price_List__c createCustomerPriceList ( String billTo, String systemName, String divisionName, Boolean doInsert )
    {
        Customer_Price_List__c aCPL = new Customer_Price_List__c();
        aCPL.Bill_To__c =  billTo;
        aCPL.System__c =  systemName;
        aCPL.Division__c =  divisionName;
        aCPL.Zilliant_Agreement_ID__c =  '12345' + uniqueCounter++;

        if( doInsert )
            insert aCPL;
        return aCPL;
    }*/

    public static FAP_Specification__c createFAPSpecification(String documentName, Map<String, Object> fieldToValue, Boolean doInsert)
    {
        FAP_Specification__c fap = new FAP_Specification__c(Name=documentName,Stage_Required_At__c=ContractFileManagementCtrl.CLOSED_WON);
        if(fieldToValue!=null) mergeValues(fap,fieldToValue);
        if(doInsert)
            insert fap;
        return fap;
    }  

    /*
        @param SObject - sobject to merge values into. *This object will be modified!
    */
    public static void mergeValues(SObject sobj, Map<String, Object> fieldToValue)
    {
        for ( String fieldName : fieldToValue.keySet()  ){
            sobj.put( fieldName, fieldToValue.get(fieldName) );
        }
    }
    
    public static Boolean pageMessagesContains(String messageNeedle)
    {
        List<ApexPages.Message> messages = ApexPages.getMessages();

        for(ApexPages.Message message : messages)
        {
            if(message.getSummary().contains( messageNeedle))
            return true;
        }
        return false;
    }
    //Commented by sujitha to remove FS Audit Functionality Backlog#702
   /* public static List<App_Domain_Restrictions__c> createDomainRestrictions(String restrictedName, Integer size, String currencyCode, Boolean doInsert){
        
        List<App_Domain_Restrictions__c> newlyCreatedAppDomainRestrictions = new List<App_Domain_Restrictions__c>();
        
        for( Integer i = 0; i < size; i++ )
        {
            App_Domain_Restrictions__c newAppDomainRestriction = new App_Domain_Restrictions__c();
            newAppDomainRestriction.name = 'Site'+i;
            newAppDomainRestriction.domain__c = i + restrictedName;
            newAppDomainRestriction.CurrencyIsoCode = currencyCode;
            
            newlyCreatedAppDomainRestrictions.add(newAppDomainRestriction);
        }
        
        if(doInsert){
            insert newlyCreatedAppDomainRestrictions;
        }
        
        return newlyCreatedAppDomainRestrictions;
    }
    */
    
    public static List<Frequent_3PL_Carrier_URLs__c> createF3PLCarrierUrls(String F3PLCarrierUrlName, String url, Integer howMany, Boolean isInsert){
        List<Frequent_3PL_Carrier_URLs__c> F3PLCarrierUrls = new List<Frequent_3PL_Carrier_URLs__c>();
        
        for(Integer i = 0; i< howMany; i++){
            Frequent_3PL_Carrier_URLs__c FPLCarrierUrl = new Frequent_3PL_Carrier_URLs__c();
            FPLCarrierUrl.Name = F3PLCarrierUrlName + i;
            FPLCarrierUrl.Frequent_Link__c = url;
            F3PLCarrierUrls.add(FPLCarrierUrl);
        }
        
        if(isInsert){
            insert F3PLCarrierUrls;
        }
        
        return F3PLCarrierUrls;
    }
    
    
    public static List<Product2> createProducts(Integer num, Boolean doInsert)
    {
        List<Product2> prods = new List<Product2>();
        for (integer i = 0; i <num; i++)
        {
            prods.add(new Product2(Name = 'Test' + i));
        }
        if (doInsert)
        { 
            insert prods;
        }
        return prods;
    }

    public static EmailConfig__c createEmailConfig(String templateName) {
        EmailConfig__c ec = new EmailConfig__c(EmailTemplateName__c = templateName);
        return ec;
    }
    
    public static C360_Customer_360_Rollup_Mapping__c createCustomer360RollupMappingSetting(String mapToCust360field, String mapFromField, String mapFromObject, String aggregationType, String groupByField, Boolean doInsert )
    {
        C360_Customer_360_Rollup_Mapping__c newCustomer360RollupMapping = new C360_Customer_360_Rollup_Mapping__c();
        newCustomer360RollupMapping.Name = mapToCust360field;
        newCustomer360RollupMapping.C360_Map_from_field__c= mapFromField;
        newCustomer360RollupMapping.C360_Map_from_object__c= mapFromObject;        
        newCustomer360RollupMapping.C360_Aggregation_Type__c= aggregationType;
        newCustomer360RollupMapping.C360_Group_by_field__c = groupByField; 
        if( doInsert )
        {
            System.runAs( ADMIN_USER )
            {
                insert newCustomer360RollupMapping;
            }
        }
        return newCustomer360RollupMapping;
    }
    //C360_Customer_360__c 
    public static List<C360_Customer_360__c> createCustomer360s(Integer size, Boolean doInsert)
    {
        List<C360_Customer_360__c> allCustomer360s = new List<C360_Customer_360__c>();
        for(Integer i = 0; i < size;i++)
        {
            allCustomer360s.add(new C360_Customer_360__c());
        }
        
        if(doInsert)
            insert allCustomer360s;
        
        return allCustomer360s;
    }
    
    public class OpportunityTeamMemberDG implements UnitTest.DataGenerator
    { 
        public List<OpportunityTeamMember> generateData(Integer howMany)
        {
            List<OpportunityTeamMember> otms = new List<OpportunityTeamMember>();
            for(Integer i = 0; i < howMany; i++)
            {
                otms.add(new OpportunityTeamMember());
            }
            return otms;
        } 
    }
    
}
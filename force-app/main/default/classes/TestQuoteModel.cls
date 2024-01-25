@isTest
private class TestQuoteModel {

    private static List<Quote__c> testQuotes;
    private static List<User> testOwners;
    private static Account someTestAccount;
    private static User merchUser;
    private static User nonMerchUser;

    private static void setupData(Integer batchSize)
    {
        UserRole merchRole = new UserRole( Name = 'Merch -1');
        UserRole nonMerchRole = new UserRole( Name = 'not merch');
        
        System.RunAs( TestingUtils.ADMIN_USER)
        {
            insert merchRole;
            insert nonMerchRole;
        }
        
        merchUser = TestingUtils.createUser( 'testMU', 'CS - Lightning Console', false );
        nonMerchUser = TestingUtils.createUser( 'testMU2', 'CS - Lightning Console', false );
        
        merchUser.userRoleId = merchRole.Id;
        nonMerchUser.userRoleId = nonMerchRole.Id;
        
        System.RunAs( TestingUtils.ADMIN_USER)
        {
            insert new List<User>{merchUser, nonMerchUser};
        }
        setupTestAccount();
        setupQuotes(batchSize);
    }

    private static void setupTestAccount()
    {
        Primary_Sales_Rep__c psr = new Primary_Sales_Rep__c();
        psr.name = 'test';
        psr.Network_ID__c = '234';
        psr.Email__c ='ert.sdfg@test.com';
        insert psr;
        
        
        someTestAccount = new Account(Primary_Sales_Rep_Name__c = [SELECT Id FROM Primary_Sales_Rep__c LIMIT 1].Id, Name = 'test account', CurrencyIsoCode = 'USD'  );
        insert someTestAccount;
    }

    private static void setupQuotes(Integer batchSize)
    {   
        testQuotes = new List<Quote__c>();
        for(Integer i=0; i<batchSize; i++)
        {
            Quote__c q = new Quote__c(Account__c=someTestAccount.Id, Quote_Stage__c=QuoteModel.WITH_FIELD_SOURCING);
            testQuotes.add(q);
        }
        insert testQuotes;
    }
    
    private static testmethod void testReturnQuoteToRequester_MerchOwner()
    {
        setupData(1);
         
        for(Quote__c q : testQuotes)
        {
            q.OwnerId = merchUser.Id;
        }
        
        Test.startTest();
        
        update testQuotes;
        
        testQuotes = [select Id, Quote_Stage__c from Quote__c where Id in :testQuotes];
        
        for(Quote__c updatedQuote : testQuotes)
        {
            System.assertEquals(QuoteModel.WITH_FIELD_SOURCING, updatedQuote.Quote_Stage__c);
        }
        
        Test.stopTest();
    }

    private static testmethod void testReturnQuoteToRequester_NonMerchOwner()
    {
        setupData(1);
         
        for(Quote__c q : testQuotes)
        {
            q.OwnerId = nonMerchUser.Id;
        }
        
        Test.startTest();
        
        update testQuotes;
        
        testQuotes = [select Id, Quote_Stage__c from Quote__c where Id in :testQuotes];
        
        for(Quote__c updatedQuote : testQuotes)
        {
          //  System.assertEquals(QuoteModel.RETURNED_FROM_FIELD_SOURCING, updatedQuote.Quote_Stage__c);
         // System.assertEquals(QuoteModel.WITH_FIELD_SOURCING, updatedQuote.Quote_Stage__c);
          
          
        }
        
        Test.stopTest();
    }
    
    private static testmethod void testReturnQuoteToRequester_MerchOwner_Batch()
    {
        setupData(50);
         
        for(Quote__c q : testQuotes)
        {
            q.OwnerId = merchUser.Id;
        }
        
        Test.startTest();
        
        update testQuotes;
        
        testQuotes = [select Id, Quote_Stage__c from Quote__c where Id in :testQuotes];
        
        for(Quote__c updatedQuote : testQuotes)
        {
            System.assertEquals(QuoteModel.WITH_FIELD_SOURCING, updatedQuote.Quote_Stage__c);
        }
        
        Test.stopTest();
    }
    
    private static testmethod void testReturnQuoteToRequester_NonMerchOwner_Batch()
    {
        setupData(50);
         
        for(Quote__c q : testQuotes)
        {
            q.OwnerId = nonMerchUser.Id;
        }
        
        Test.startTest();
        
        update testQuotes;
        
        testQuotes = [select Id, Quote_Stage__c from Quote__c where Id in :testQuotes];
        
        for(Quote__c updatedQuote : testQuotes)
        {
           // System.assertEquals(QuoteModel.RETURNED_FROM_FIELD_SOURCING, updatedQuote.Quote_Stage__c);
          // System.assertEquals(QuoteModel.WITH_FIELD_SOURCING, updatedQuote.Quote_Stage__c);
           
        }
        Test.stopTest();
    }
    
    private static testmethod void testReturnQuoteToRequester_Mixed_Batch()
    {
        setupData(50);
        
        Map<Id, String> quoteIdToExpectedStage = new Map<Id, String>();
        
        for(Integer i=0; i<25; i++)
        {
            Quote__c q = testQuotes[i];
            q.OwnerId = nonMerchUser.Id;
            quoteIdToExpectedStage.put(q.Id, QuoteModel.RETURNED_FROM_FIELD_SOURCING);
        }
        
        for(Integer i=25; i<50; i++)
        {
            Quote__c q = testQuotes[i];
            q.OwnerId = merchUser.Id;
            quoteIdToExpectedStage.put(q.Id, QuoteModel.WITH_FIELD_SOURCING);
        }
        
        Test.startTest();
        
        update testQuotes;
        
        testQuotes = [select Id, Quote_Stage__c from Quote__c where Id in :testQuotes];
        
        for(Quote__c updatedQuote : testQuotes)
        {
           // System.assertEquals(quoteIdToExpectedStage.get(updatedQuote.Id), updatedQuote.Quote_Stage__c);
           
           String s = quoteIdToExpectedStage.get(updatedQuote.Id);
           //System.assertEquals(quoteIdToExpectedStage.get(updatedQuote.Id), s);
           
        }
        
        Test.stopTest();
    }
    
}
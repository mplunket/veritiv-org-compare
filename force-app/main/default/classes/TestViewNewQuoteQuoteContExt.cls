/**
 Objective: Iron out the logic for ViewNewQuoteQuoteContExt
 Developer: Hiremath, Naveen - Bluewolf
*/
@isTest
private class TestViewNewQuoteQuoteContExt {
	private static Account testCustAccount;
	private static Contact testCustContact;
	private static Opportunity testCustOppportunity;

    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static String USD_Currency = 'USD';

    static testMethod void doSave_whenUserInvokesCloneQuoteFromExistingQuotes_returnsPageReference() {

    	 setUpQuoteData();

		 Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?quoteId=' + testQuote.Id +'&isCloned=true'));
		 ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
         ViewNewQuoteQuoteContExt newQuoteRef = new ViewNewQuoteQuoteContExt(sc);

         PageReference pageRef = newQuoteRef.doSave();

         PageReference pgRef = new PageReference(Page.ViewNewQuote.getURL() + '?quoteId=' + testQuote.Id);
         System.assertNotEquals(pgRef, null, 'Page Reference cannot be null after a Save');

         String atr = pgRef.getUrl();
		 String[] res = atr.split('=');
		 Quote__c newQuote = QuoteServices.getQuote(res[1]);
		 System.assertEquals(newQuote.Account__c,testQuote.Account__c,'');
         System.assertEquals(newQuote.OwnerID,testQuote.OwnerID,'');
    }
    
     static testMethod void doSave_whenUserInvokesCloneQuoteFromExistingQuotesCurrencyCopy() {

    	 setUpQuoteData();
    	 testQuote.Currency__c = USD_Currency;
    	 update testQuote;

		 Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?quoteId=' + testQuote.Id +'&isCloned=true'));
		 ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
         ViewNewQuoteQuoteContExt newQuoteRef = new ViewNewQuoteQuoteContExt(sc);

         PageReference pageRef = newQuoteRef.doSave();

         String atr = pageRef.getUrl(); 
		 String[] res = atr.split('=');
		 Quote__c newQuote = QuoteServices.getQuote(res[1]);
		 System.assertEquals(USD_Currency,newQuote.Currency__c);
    }
    
    

    static testMethod void doSave_whenUserInvokesNewQuoteFromContact_returnsPageReference() { 

    	 setUpContactData();

		 Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?contactId=' + testCustContact.Id));
		 ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
         ViewNewQuoteQuoteContExt newQuoteRef = new ViewNewQuoteQuoteContExt(sc);

         PageReference pageRef = newQuoteRef.doSave();
         System.assertNotEquals(pageRef, null, 'Page Reference cannot be null after a Save');
         System.assert(pageRef.getUrl().contains(Page.ViewQuote.getUrl()), 'On success the user must be taken to the Quotes page.');
         /*
         //Added MH - 4/30
         //Ensure that the currency is copied over to the quote from the contact
         Quote__c quoteCreated = [Select Id, Currency__c from Quote__c where Id = :newQuoteRef.quote.Id limit 1];
         System.assertEquals( testCustContact.CurrencyIsoCode, quoteCreated.Currency__c);
         */

    }

    
    static testMethod void doSave_whenUserInvokesNewQuoteFromAccount_returnsPageReference1() {
         setUpAccountData();
        setUpOpportunityData();
         Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?acctId=' + testCustAccount.Id  + '&oppId='+ testCustOppportunity.Id));
    }
    
    
    static testMethod void doSave_whenUserInvokesNewQuoteFromAccount_returnsPageReference() {

    	 setUpAccountData();

		 Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?acctId=' + testCustAccount.Id));
		 ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
         ViewNewQuoteQuoteContExt newQuoteRef = new ViewNewQuoteQuoteContExt(sc);

         PageReference pageRef = newQuoteRef.doSave();
         System.assertNotEquals(pageRef, null, 'Page Reference cannot be null after a Save');
         System.assert(pageRef.getUrl().contains(Page.ViewQuote.getUrl()), 'On success the user must be taken to the Quotes page.');
         /*
         //Added MH - 4/30
         //Ensure that the currency is copied over to the quote from the account
         Quote__c quoteCreated = [Select Id, Currency__c from Quote__c where Id = :newQuoteRef.quote.Id limit 1];
         System.assertEquals( testCustAccount.CurrencyIsoCode, quoteCreated.Currency__c);
         */

    }
    
    	static testMethod void doSave_whenUserInvokesNewQuoteFromOpportunity_returnsPageReference() {

     	setUpOpportunityData();

     	//Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?acctId=' + testCustAccount.Id +'&oppId='+ testCustOppportunity.Id));
Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '&oppId='+ testCustOppportunity.Id));     	
     	ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testQuote);
     	ViewNewQuoteQuoteContExt newQuoteRef = new ViewNewQuoteQuoteContExt(sc);

     	PageReference pageRef = newQuoteRef.doSave();
        /*
        //Added MH - 4/30
        //Ensure that the currency is copied over to the quote from the oppty
        Quote__c quoteCreated = [Select Id, Currency__c from Quote__c where Id = :newQuoteRef.quote.Id limit 1];
        System.assertEquals( testCustOppportunity.CurrencyIsoCode, quoteCreated.Currency__c);
        */
     }
         
    
    
    
    static testMethod void doSave_whenUserInvokesNewQuoteFromOpportunity_returnsPageReference1() {

     	setUpOpportunityData();

     	Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?acctId=' + testCustAccount.Id +'&oppId='+ testCustOppportunity.Id));
//Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '&oppId='+ testCustOppportunity.Id));     	
     	ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testQuote);
     	ViewNewQuoteQuoteContExt newQuoteRef = new ViewNewQuoteQuoteContExt(sc);

     	PageReference pageRef = newQuoteRef.doSave();
        /*
        //Added MH - 4/30
        //Ensure that the currency is copied over to the quote from the oppty
        Quote__c quoteCreated = [Select Id, Currency__c from Quote__c where Id = :newQuoteRef.quote.Id limit 1];
        System.assertEquals( testCustOppportunity.CurrencyIsoCode, quoteCreated.Currency__c);
        */
     }
        
    
    
    
    
    
    
      static testMethod void doSave_whenUserInvokesNewQuoteFromShipTo_returnsPageReference() {

    	 setUpOpportunityData();

		 Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?shipToId=' + testShipAccount.Id));
		 ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
         ViewNewQuoteQuoteContExt newQuoteRef = new ViewNewQuoteQuoteContExt(sc);

         PageReference pageRef = newQuoteRef.doSave();
         System.assertNotEquals(pageRef, null, 'Page Reference cannot be null after a Save');
         System.assert(pageRef.getUrl().contains(Page.ViewQuote.getUrl()), 'On success the user must be taken to the Quotes page.');

         System.assertEquals( testShipAccount.Id, newQuoteRef.quote.Ship_To__c);
         System.assertEquals( testCustAccount.Id, newQuoteRef.quote.Account__c);
         System.assertEquals( UserInfo.getUserId(), newQuoteRef.quote.OwnerID);
         System.assertEquals( testCustAccount.Primary_Sales_Rep_Name__c, newQuoteRef.quote.Primary_Sales_Rep__c);


    }

     static testMethod void doCancel_whenUserInvokesNewQuoteFromAccount_returnsPageReference() {

     	setUpAccountData();

     	ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testQuote);
     	ViewNewQuoteQuoteContExt newQuoteRef = new ViewNewQuoteQuoteContExt(sc);

     	PageReference pageRef = newQuoteRef.doCancel();
        System.assertEquals(Consts.REL_URL_QUOTES_TAB, pageRef.getURL(),'After cancel take the user back to Quotes Tab');

     }

     static testMethod void doCancel_whenUserInvokesNewQuoteFromOpportunity_returnsPageReference() {

     	setUpOpportunityData();

     	ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewNewQuoteQuoteContExt newQuoteRef = new ViewNewQuoteQuoteContExt(sc);

        PageReference pageRef = newQuoteRef.doCancel();
        System.assertEquals(Consts.REL_URL_QUOTES_TAB, pageRef.getURL(),'After cancel take the user back to Quotes Tab');
     }

    static testMethod void doSaveNew_whenUserInvokesNewQuoteFromAccount() {

     	setUpAccountData();

     	Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?acctId=' + testCustAccount.Id));
     	ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testQuote);
     	ViewNewQuoteQuoteContExt newQuoteRef = new ViewNewQuoteQuoteContExt(sc);

     	PageReference pageRef = newQuoteRef.doSaveNew();
        //Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?acctId=' + testCustAccount.Id));
 	    System.assertNotEquals(pageRef.getURL().contains(Page.ViewNewQuote.getURL()),null, 'Save the new Quote and get the user back to the New Quote page');
     }

    static testMethod void doSaveNew_whenUserInvokesNewQuoteFromOpportunity() {

     	setUpOpportunityData();

     	Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?acctId=' + testCustAccount.Id +'&oppId='+ testCustOppportunity.Id));
     	ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testQuote);
     	ViewNewQuoteQuoteContExt newQuoteRef = new ViewNewQuoteQuoteContExt(sc);

     	PageReference pageRef = newQuoteRef.doSaveNew();
        //Test.setCurrentPageReference(new PageReference(Page.ViewNewQuote.getURL() + '?acctId=' + testCustAccount.Id));
 	    System.assertNotEquals(pageRef.getURL().contains(Page.ViewNewQuote.getURL()),null, 'Save the new Quote and get the user back to the New Quote page');
     }

	static testMethod void testCloneWithLineItems()
	{
		Integer numQLIs = 5;

		Account testAccount = TestDataGeneration.createAccount( 'Test Account', true );

		testQuote = TestDataGeneration.createQuotes( 1, 'Test Quote', testAccount.Id, true )[0];

		List<Product2> testProducts = TestDataGeneration.createProducts( numQLIs, 'Test Product', true );

		List<Quote_Line_Item__c> testQLIs = new List<Quote_Line_Item__c>();
		for( Product2 aProduct : testProducts )
		{
			Quote_Line_Item__c newQLI = new Quote_Line_Item__c();
			newQLI.Quote__c = testQuote.Id;
			newQLI.Product__c = aProduct.Id;
			testQLIs.add( newQLI );
		}
		insert testQLIs;

		Test.setCurrentPage( new ApexPages.PageReference( Page.ViewNewQuote.getURL() + '?isCloned=1&quoteId=' + testQuote.Id ) );

		ApexPages.StandardController standardCont = new ApexPages.StandardController( testQuote );
		ViewNewQuoteQuoteContExt newQuoteController = new ViewNewQuoteQuoteContExt( standardCont );

		Test.startTest();

			ApexPages.PageReference returnedPageRef = newQuoteController.doSave();

		Test.stopTest();
        if(returnedPageRef != null){
		Quote__c clonedQuote = [ SELECT Id, ( SELECT Id, Product__c, Qty__c FROM Quote_Line_Items__r ) FROM Quote__c WHERE Id = :returnedPageRef.getParameters().get( 'id' ) LIMIT 1 ];
		System.assertEquals( numQLIs, clonedQuote.Quote_Line_Items__r.size() );

		Set<Id> productIds = new Set<Id>();
		for( Quote_Line_Item__c qli : clonedQuote.Quote_Line_Items__r )
		{
			productIds.add( qli.Product__c );
			System.assertEquals( 1, qli.Qty__c, 'Every cloned quote line item should have quantity defaulted to 1' );
		}

		for( Product2 aProduct : testProducts )
		{
			System.assert( productIds.contains( aProduct.Id ), 'Every product should have had a QLI created, ensuring all QLIs have been cloned' );
		}
            }
	}
	
	
	public static testMethod  void testRenderSalesOrderNumberField_true() {
		
		setUpQuoteData();
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController( testQuote );
        ViewNewQuoteQuoteContExt quoteCont = new ViewNewQuoteQuoteContExt( stdCont );
		quoteCont.quote.Quote_Stage__c = QuoteInformationExt.QUOTE_WON_STAGE;
		
		
		Test.startTest();
			Boolean result = quoteCont.renderSalesOrderNumberField;
		Test.stopTest();
		
		
		
		System.assertEquals(true, result, 'We expect to render the Sales Order number field when the Quote is in stage won.');
	}
	
	public static testMethod  void testRenderSalesOrderNumberField_false() {
		
		setUpQuoteData();
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController( testQuote );
        ViewNewQuoteQuoteContExt quoteCont = new ViewNewQuoteQuoteContExt( stdCont );
		quoteCont.quote.Quote_Stage__c = QuoteInformationExt.QUOTE_LOST_STAGE;
		
		
		Test.startTest();
			Boolean result = quoteCont.renderSalesOrderNumberField;
		Test.stopTest();
		
		
		
		System.assertEquals(false, result, 'We expect to not render the Sales Order number field when the Quote is in stage lost.');
	}
	
	public static testMethod  void testRenderLostReasonCommentsField_true() {
		
		setUpQuoteData();
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController( testQuote );
        ViewNewQuoteQuoteContExt quoteCont = new ViewNewQuoteQuoteContExt( stdCont );
		quoteCont.quote.Quote_Stage__c = QuoteInformationExt.QUOTE_LOST_STAGE;
		quoteCont.quote.Lost_Reason__c = QuoteInformationExt.QUOTE_LOST_REASON_OTHER;
		
		
		Test.startTest();
			Boolean result = quoteCont.renderLostReasonCommentsField;
		Test.stopTest();
		
		
		
		System.assertEquals(true, result, 'We expect to render the Lost Reason Comments field when the Quote is in stage lost.');
	}
	
	public static testMethod  void testRenderLostReasonCommentsField_false() {
		
		setUpQuoteData();
        
        ApexPages.StandardController stdCont = new ApexPages.StandardController( testQuote ); 
        ViewNewQuoteQuoteContExt quoteCont = new ViewNewQuoteQuoteContExt( stdCont );
		quoteCont.quote.Quote_Stage__c = QuoteInformationExt.QUOTE_WON_STAGE;
		
		
		Test.startTest();
			Boolean result = quoteCont.renderLostReasonCommentsField;
		Test.stopTest();
		
		
		
		System.assertEquals(false, result, 'We expect to not render the Lost Reason Comments field when the Quote is in stage won.');
	}
	
	 
	
	

    static void setUpAccountData(){
    	ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001', Active__c='Yes', CurrencyIsoCode = 'USD');
        insert testCustAccount;

        testShipAccount = new Ship_To__c(Name='Test Customer Location 1', Ship_To_Code__c='000002', Bill_To_Account__c=testCustAccount.Id, Active__c='Yes');
        insert testShipAccount;

        testQuote = new Quote__c(Account__c=testCustAccount.Id, Account__r=testCustAccount, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;
    }

    static void setUpContactData() {

    	ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001', Active__c='Yes');
        insert testCustAccount;

		testCustContact = new Contact(FirstName='Test', LastName='Contact', AccountId=testCustAccount.Id, CurrencyIsoCode = 'USD');
		insert testCustContact;

        testQuote = new Quote__c(Account__c=[Select Account.Id From Contact Where Id = :testCustContact.Id].Account.Id, Account__r=testCustAccount, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;

    }

    static void setUpOpportunityData(){
    	ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001', Active__c='Yes');
        insert testCustAccount;

        testCustOppportunity = TestDataGeneration.createOpportunities(1, testCustAccount.Id, false)[0];
        testCustOppportunity.Name = 'Test Customer';
        testCustOppportunity.StageName='8- Closed Won';
        testCustOppportunity.CloseDate=system.today(); 
        testCustOppportunity.Customer_Selling_Margin_Rate__c=20.22;
        testCustOppportunity.CurrencyIsoCode = 'USD';
        		
        		
        System.assertNotEquals(testCustOppportunity,null, '');
        insert testCustOppportunity;

        testShipAccount = new Ship_To__c(Name='Test Customer Location 1', Ship_To_Code__c='000002', Bill_To_Account__c=testCustAccount.Id, Active__c='Yes');
        insert testShipAccount;

        testQuote = new Quote__c(Account__c=testCustAccount.Id,Opportunity__c=testCustOppportunity.Id, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;
    }

    static void setUpQuoteData(){
    	ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001', Active__c='Yes');
        insert testCustAccount;

		 testQuote = new Quote__c (
		 Account__c = testCustAccount.Id,
		 OwnerID = Userinfo.getUserId()
		 

 		);
		insert testQuote;
		
    }
}
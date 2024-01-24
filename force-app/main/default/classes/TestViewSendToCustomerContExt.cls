/**
 Objective: Test class to iron out the functionality of ViewSendToCustomerContExt
 Developer: Hiremath, Naveen - Bluewolf     
*/
@isTest
private class TestViewSendToCustomerContExt {

private static Account testCustAccount;
    private static Account testCustAccount1;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Quote__c testQuote1;
    private static Contact testContact;
    private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0]; 

    @testSetup private static void testSetupData() {
     //private static void testSetupData( Id runningUserId ) {
        //TestPDFEmailServices.setup( runningUserId );
        
        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001');
        insert testCustAccount;

          ID custRecTypeID1 = [select Id from RecordType where SobjectType = 'Account' and Name = 'Prospect'].Id;
        testCustAccount1 = new Account(Name='Test Customer', RecordTypeId=custRecTypeID1, AccountNumber='123455', Ship_To_Code__c='000001');
        insert testCustAccount1;
         
        testShipAccount = new Ship_To__c(Name='Test Customer Location 1', Ship_To_Code__c='000002', Bill_To_Account__c=testCustAccount.Id, Active__c='Yes');
        insert testShipAccount;

        testContact = new Contact();
        testContact.LastName = 'Test Contact';
        testContact.Email = 'test@test.com.test';
        insert testContact;
        
        testQuote = new Quote__c(Account__c=testCustAccount.Id, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;
         
         testQuote1 = new Quote__c(Account__c=testCustAccount1.Id, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote1;

        Product2[] products = TestingUtils.createProducts(2, false);
        List<Vendor_Detail__c> vendors = TestingUtils.createVendorDetails( 2, 'testVend', true );
        
        products[0].Vendor__c = vendors[0].id;        
        products[1].Vendor__c = vendors[1].id;  
        
        insert products;
        
        products = [select Id, ProductCode, Description, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c, Unit_of_Measure__c, Pricing_Costing_UOM__c, Conversion_Factor__c from Product2 where Id in :products limit 2];
        
        //Product2[] products = [select Id, ProductCode, Description, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c, Unit_of_Measure__c, Pricing_Costing_UOM__c, Conversion_Factor__c from Product2 limit 2];
        
        Quote_Line_Item__c qli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        qli.Product__c = products[0].Id;
        qli.Product__r = products[0];
        qli.Product_Code__c = products[0].ProductCode;
        qli.Product_Description__c = products[0].Description;
        qli.Unisource_Item__c = products[0].Unisource_Item_Number_U_number__c;
        qli.Vendor_Item__c = products[0].Vendor_Product_Code__c;
        qli.Vendor_Name__c = products[0].Vendor__c;
        qli.Qty__c = 1;
        qli.Quantity_unit_of_measure__c = products[0].Unit_of_Measure__c;
        qli.Price_unit_of_measure__c = products[0].Pricing_Costing_UOM__c;
        qli.Costing_unit_of_measure__c = products[0].Pricing_Costing_UOM__c;
        qli.Quantity_Unit_Factor__c = 1;
        qli.Price_Unit_Factor__c = products[0].Conversion_Factor__c;
        qli.Cost_Unit_Factor__c = products[0].Conversion_Factor__c;
        qli.Updated_P_A__c = true;
        insert qli;
        testQLIs.add(qli);
        
        qli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        qli.Product__c = products[1].Id;
        qli.Product__r = products[1];
        qli.Product_Code__c = products[1].ProductCode;
        qli.Product_Description__c = products[1].Description;
        qli.Unisource_Item__c = products[1].Unisource_Item_Number_U_number__c;
        qli.Vendor_Item__c = products[1].Vendor_Product_Code__c;
        qli.Vendor_Name__c = products[1].Vendor__c;
        qli.Qty__c = 1;
        qli.Quantity_unit_of_measure__c = products[1].Unit_of_Measure__c;
        qli.Price_unit_of_measure__c = products[1].Pricing_Costing_UOM__c;
        qli.Costing_unit_of_measure__c = products[1].Pricing_Costing_UOM__c;
        qli.Quantity_Unit_Factor__c = 1;
        qli.Price_Unit_Factor__c = products[1].Conversion_Factor__c;
        qli.Cost_Unit_Factor__c = products[1].Conversion_Factor__c;
        qli.Updated_P_A__c = true;
        insert qli;
        testQLIs.add(qli);
    }
    /*
    private static void testSetupData() {
        testSetupData( UserInfo.getUserId() );
    }
    */  
    private static testmethod void testProperties() {
        //testSetupData();
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        Test.startTest();
        //Test with QLIs
        Test.setCurrentPageReference(new PageReference(Page.SendQuoteToCustomer.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        
        ViewSendToCustomerContExt contExt = new ViewSendToCustomerContExt(sc);
        System.assert(contExt.hasSelectedRecords);
        
        Boolean testValidQuote = contExt.isValidQuote;
        System.assert(testValidQuote);
        
        Quote_Line_Item__c testEmail = contExt.email;
        System.assertNotEquals(null, testEmail);
        
        testEmail = contExt.email;
        System.assertNotEquals(null, testEmail);
        testEmail.Product_Description__c = 'Test email';
        contExt.email = testEmail;
        System.assertEquals('Test email', contExt.email.Product_Description__c);

        contExt.emailAdditionalTo = 'test additional';
        System.assertEquals('test additional', contExt.emailAdditionalTo);

        contExt.emailBCC = 'test BCC';
        System.assertEquals('test BCC', contExt.emailBCC);

        contExt.emailCC = 'test CC';
        System.assertEquals('test CC', contExt.emailCC);

        Test.stopTest();
    }
   
    private static testmethod void testActionMethods() {
        //testSetupData();
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        Test.startTest();
        //Test with QLIs
        Test.setCurrentPageReference(new PageReference(Page.SendQuoteToCustomer.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        
        ViewSendToCustomerContExt contExt = new ViewSendToCustomerContExt(sc);
        System.assert(contExt.hasSelectedRecords);
        contExt.emailAdditionalTo = '';
        contExt.emailBCC = '';
        contExt.emailCC = '';
        
        contExt.sendQuote();
        contExt.addAttachment();
        contExt.removeAttachment();
        
        Test.stopTest();
    }
    
    private static testMethod void ViewSendToCustomerContExt_whenQuoteIsAbsent_returnsNothing() {
        
        //testSetupData();
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        
        Test.setCurrentPageReference(new PageReference(Page.SendQuoteToCustomer.getURL()));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewSendToCustomerContExt contExt = new ViewSendToCustomerContExt(sc);
        
        System.assert(!contExt.isValidQuote, 'For no quote id valid Quote flag will be disabled.');
        
    }
    
    private static testMethod void testSendQuote_AsNoDepartmentUser()
    {
        /*User testUser = TestDataGeneration.getTestUser('DUser', 'System Administrator');
        testUser.Department = '';
        */
        ViewSendToCustomerContExt contExt;
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        
        Test.startTest();

        //    System.runAs( testUser )
        //    {
                //testSetupData( testUser.Id );
                Test.setCurrentPageReference(new PageReference(Page.SendQuoteToCustomer.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
                ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        
                contExt = new ViewSendToCustomerContExt(sc);
                contExt.email.Vendor_Contact__c = testContact.id;
                contExt.sendQuote(); 
            //}

        Test.stopTest(); 

        List<Attachment> attachmentsForQuote = [ SELECT Id, Name FROM Attachment WHERE ParentId = :testQuote.Id ];
        System.assertEquals( 1, attachmentsForQuote.size(), 'When sending a quote, an attachment should have been generated');
    //  System.assertEquals( TestPDFEmailServices.customerDefault.PDF_File_Name__c, attachmentsForQuote[0].Name, 'When sending a quote as a Fordis user, the Fordis filename should be used' );
      //  System.assertEquals( TestPDFEmailServices.customerDefault.PDF_Template_Name__c, contExt.templateNameUsed, 'When sending a quote as a Fordis user, the Fordis email template should be used' );
        
        //Id expectedTemplateId = [select Id from EmailTemplate where DeveloperName = :TestPDFEmailServices.customerDefault.PDF_Template_Name__c].Id;
       // System.assertEquals( expectedTemplateId, contExt.templateIdUsed, 'When sending a quote as a no dept user, the default email template should be used' );
    }
    
    private static testMethod void testSendQuote_AsSaalfeldUser()
    {/*
        User testUser = TestDataGeneration.getTestUser('DUser', 'System Administrator');
        testUser.Department = Consts.SAALFELD_DEPARTMENT;
        ViewSendToCustomerContExt contExt;
        Test.startTest();
       */
       
       ViewSendToCustomerContExt contExt;
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id from Quote_Line_Item__c]; 
        testContact = [select id from Contact];  
        
            
            /*
            System.runAs( testUser )
            {*/
                //testSetupData( testUser.Id );
                Test.setCurrentPageReference(new PageReference(Page.SendQuoteToCustomer.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
                ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        
                contExt = new ViewSendToCustomerContExt(sc);
                contExt.email.Vendor_Contact__c = testContact.id;
                contExt.sendQuote(); 
        /*    }

        Test.stopTest(); 
        */
        List<Attachment> attachmentsForQuote = [ SELECT Id, Name FROM Attachment WHERE ParentId = :testQuote.Id ];
        System.assertEquals( 1, attachmentsForQuote.size(), 'When sending a quote, an attachment should have been generated');
    //  System.assertEquals( TestPDFEmailServices.customerSaalFeld.PDF_File_Name__c, attachmentsForQuote[0].Name, 'When sending a quote as a Fordis user, the Fordis filename should be used' );
       // System.assertEquals( TestPDFEmailServices.customerSaalFeld.PDF_Template_Name__c, contExt.templateNameUsed, 'When sending a quote as a Fordis user, the Fordis email template should be used' );
        
        //Id expectedTemplateId = [select Id from EmailTemplate where DeveloperName = :TestPDFEmailServices.customerSaalFeld.PDF_Template_Name__c].Id;
       // System.assertEquals( expectedTemplateId, contExt.templateIdUsed, 'When sending a quote as a no dept user, the default email template should be used' );
    }
    
     private static testMethod void testSendQuoteAsProspect()
    {
        Test.startTest();
        /*
        User testUser = TestDataGeneration.getTestUser('DUser', 'System Administrator');
        testUser.Department = Consts.SAALFELD_DEPARTMENT;
        insert testUser;
        */
        ViewSendToCustomerContExt contExt;
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id from Quote_Line_Item__c]; 
        testContact = [select id from Contact];  
        
        
        
            //System.runAs( testUser )
            //{
                
                //testSetupData( testUser.Id );
                Test.setCurrentPageReference(new PageReference(Page.SendQuoteToCustomer.getURL() + '?id=' + testQuote1.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
                ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        
                contExt = new ViewSendToCustomerContExt(sc);
                contExt.email.Vendor_Contact__c = testContact.id;
                contExt.sendQuote(); 
                
            //}
        Test.stopTest(); 
        

        //List<Attachment> attachmentsForQuote = [ SELECT Id, Name FROM Attachment WHERE ParentId = :testQuote.Id ];
       // System.assertEquals( 1, attachmentsForQuote.size(), 'When sending a quote, an attachment should have been generated');
    //  System.assertEquals( TestPDFEmailServices.customerSaalFeld.PDF_File_Name__c, attachmentsForQuote[0].Name, 'When sending a quote as a Fordis user, the Fordis filename should be used' );
       // System.assertEquals( TestPDFEmailServices.customerSaalFeld.PDF_Template_Name__c, contExt.templateNameUsed, 'When sending a quote as a Fordis user, the Fordis email template should be used' );
        
        //Id expectedTemplateId = [select Id from EmailTemplate where DeveloperName = :TestPDFEmailServices.customerSaalFeld.PDF_Template_Name__c].Id;
       // System.assertEquals( expectedTemplateId, contExt.templateIdUsed, 'When sending a quote as a no dept user, the default email template should be used' );
    }

    
    
    private static testMethod void Test_IneligibleLineItem()
    {
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id, Quote__c from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        
        Quote_Line_Item__c qli2 = testQLIs[0].clone( false, true);
        Product2 testProduct = (Product2) SObjectFactory.create(Product2.SObjectType);
        qli2.Product__c = testProduct.Id;
        qli2.Updated_P_A__c = FALSE;
        insert qli2;
        
        Test.startTest();

            
            Test.setCurrentPageReference( new PageReference(Page.ViewSendToCustomer.getURL() + '?id=' + testQuote.Id + '&qliIds=' + qli2.Id ) );

            ApexPages.Standardcontroller standardCont = new ApexPages.Standardcontroller( testQuote );
            ViewSendToCustomerContExt contExt = new ViewSendToCustomerContExt( standardCont );

        Test.stopTest();

        Boolean foundError = false;

        System.assertEquals( FALSE, contExt.isValidQuote, 'We expect the quote to be invalid.' );
        for(ApexPages.Message   msg : ApexPages.getMessages())
        {
            if(msg.getSummary() == Label.IneligibleQuoteErrorMessage)
            {
                foundError = true;
            }
        }
        System.assert(foundError, 'We expect the page to contain the proper error message.');
    }
    
    /* Websource Test - Doesn't Apply Anymore */
    /*
    private static testMethod void testSendQuote_AsWebsourceUser()
    {
        User testUser = TestDataGeneration.getTestUser('DUser', 'System Administrator');
        testUser.Department = Consts.WEBSOURCE_DEPARTMENT;
        Test.startTest();

            System.runAs( testUser )
            {
                testSetupData();
                Test.setCurrentPageReference(new PageReference(Page.SendQuoteToCustomer.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + testQLIs[1].Id));
                ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        
                ViewSendToCustomerContExt contExt = new ViewSendToCustomerContExt(sc);
                contExt.email.Vendor_Contact__c = testContact.id;
                contExt.sendQuote(); 
            }

        Test.stopTest(); 

        List<Attachment> attachmentsForQuote = [ SELECT Id, Name FROM Attachment WHERE ParentId = :testQuote.Id ];
        System.assertEquals( 1, attachmentsForQuote.size(), 'When sending a quote, an attachment should have been generated');
        System.assertEquals( ViewSendToCustomerContExt.WEBSOURCE_FILENAME, attachmentsForQuote[0].Name, 'When sending a quote as a websource user, the websource filename should be used' );
    }
    */
    
 }
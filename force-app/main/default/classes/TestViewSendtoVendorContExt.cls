@isTest
private class TestViewSendtoVendorContExt {

    private static Account testCustAccount;
    private static Account testCustAccount1;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Quote__c testQuote1;
    private static Contact testContact;
    private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0];
    
    //private static void testSetupData( Id runningUserId ) {
    @testSetup private static void testSetupData() {
        //TestPDFEmailServices.setup( runningUserId );
        
        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account(Name='Test Customer', RecordTypeId=custRecTypeID, AccountNumber='123456', Ship_To_Code__c='000001');
        insert testCustAccount;

                  ID custRecTypeID1 = [select Id from RecordType where SobjectType = 'Account' and Name = 'Prospect'].Id;
        testCustAccount1 = new Account(Name='Test Customer', RecordTypeId=custRecTypeID1, AccountNumber='123455', Ship_To_Code__c='000001');
        insert testCustAccount1;
        
        testShipAccount = new Ship_To__c(Name='Test Customer Location 1', Ship_To_Code__c='000002', Bill_To_Account__c=testCustAccount.Id, Active__c='Yes');
        insert testShipAccount;

        Product2[] products = TestingUtils.createProducts(2, false);
        List<Vendor_Detail__c> vendors = TestingUtils.createVendorDetails( 2, 'testVend', true );
        
        products[0].Vendor__c = vendors[0].id;        
        products[1].Vendor__c = vendors[1].id;  
        
        insert products;
        
        products = [select Id, ProductCode, Description, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c, Unit_of_Measure__c, Pricing_Costing_UOM__c, Conversion_Factor__c from Product2 where Id in :products limit 2];
        
        //Product2[] products = [select Id, ProductCode, Description, Unisource_Item_Number_U_number__c, Vendor_Product_Code__c, Vendor__c, Unit_of_Measure__c, Pricing_Costing_UOM__c, Conversion_Factor__c from Product2 limit 2];
        
        testContact = new Contact();
        testContact.LastName = 'Test Contact';
        testContact.Email = 'test@test.com.test';
        testContact.Vendor_Lookup__c = products[0].Vendor__c;
        insert testContact;

        testQuote = new Quote__c(Account__c=testCustAccount.Id, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote;
        
         testQuote1 = new Quote__c(Account__c=testCustAccount1.Id, Shipment_Method__c='Warehouse',Requested_Delivery_Date__c=System.today());
        insert testQuote1;

        Quote_Line_Item__c qli = new Quote_Line_Item__c(Quote__c=testQuote.Id);
        qli.Product__c = products[0].Id;
        qli.Product__r = products[0];
        qli.Product_Code__c = products[0].ProductCode;
        qli.Product_Description__c = products[0].Description;
        qli.Unisource_Item__c = products[0].Unisource_Item_Number_U_number__c;
        qli.Vendor_Contact__c = testContact.Id;
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
    }
    /*
    private static void testSetupData() {
        testSetupData( UserInfo.getUserId() );
    }
    */
    public static testmethod void testProperties() {
        //testSetupData();
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id, quote__c from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        Test.startTest();
        //Test with QLIs
        Test.setCurrentPageReference(new PageReference(Page.SendQuoteToVendor.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);

        ViewSendToVendorContExt contExt = new ViewSendToVendorContExt(sc);
        System.assert(contExt.hasSelectedRecords);

        Boolean testValidQuote = contExt.isValidQuote;
        System.assert(testValidQuote);

        Quote_Line_Item__c testEmail = contExt.email;
        System.assertNotEquals(null, testEmail);
        //contExt.isValidQuote = true;
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

    public static testmethod void testActionMethods() {

        //testSetupData();
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id, quote__c from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        Test.startTest();
        //Test with QLIs
        Test.setCurrentPageReference(new PageReference(Page.SendQuoteToVendor.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);

        ViewSendToVendorContExt contExt = new ViewSendToVendorContExt(sc);
        System.assert(contExt.hasSelectedRecords);
        contExt.emailAdditionalTo = '';
        contExt.emailBCC = '';
        contExt.emailCC = '';

        contExt.sendQuote();
        contExt.addAttachment();
        contExt.removeAttachment();

        Test.stopTest();
    }

    private static testMethod void ViewSendToVendorContExt_whenQuoteIsAbsent_returnsNothing() {

        //testSetupData();
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id, quote__c from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        
        Test.setCurrentPageReference(new PageReference(Page.SendQuoteToVendor.getURL()));
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ViewSendToVendorContExt contExt = new ViewSendToVendorContExt(sc);

        System.assert(!contExt.isValidQuote, 'For no quote id valid Quote flag will be disabled.');

    }

    /* Webcenter Test - Doesn't Apply Anymore */
    /*
    private static testMethod void testSendQuote_AsWebCenterUser()
    {
        User testWebCenterUser = TestDataGeneration.getTestUser('WCUser', 'System Administrator');
        testWebCenterUser.Department = Consts.WEBCENTER_DEPARTMENT;

        Test.startTest();

            System.runAs( testWebCenterUser )
            {
                testSetupData();
                Test.setCurrentPageReference( new PageReference(Page.ViewSendToVendor.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id) );

                ApexPages.Standardcontroller standardCont = new ApexPages.Standardcontroller( testQuote );
                ViewSendToVendorContExt contExt = new ViewSendToVendorContExt( standardCont );
                contExt.email.Vendor_Contact__c = testContact.id;
                contExt.sendQuote();
            }

        Test.stopTest();

        List<Attachment> attachmentsForQuote = [ SELECT Id, Name FROM Attachment WHERE ParentId = :testQuote.Id ];
        System.assertEquals( 1, attachmentsForQuote.size(), 'When sending a quote, an attachment should have been generated' );
        System.assertEquals( ViewSendToVendorContExt.WEBCENTER_FILENAME, attachmentsForQuote[0].Name, 'When sending a quote as a Webcenter user, the Webcenter filename should be used' );
    }
    */
    
    /* Websource Test - Doesn't Apply Anymore */
    /*
    private static testMethod void testSendQuote_AsWebsourceUser()
    {
        User testWebsourceUser = TestDataGeneration.getTestUser('WSUser', 'System Administrator');
        testWebsourceUser.Department = Consts.WEBSOURCE_DEPARTMENT;

        Test.startTest();

            System.runAs( testWebsourceUser )
            {
                testSetupData();
                Test.setCurrentPageReference( new PageReference(Page.ViewSendToVendor.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id) );

                ApexPages.Standardcontroller standardCont = new ApexPages.Standardcontroller( testQuote );
                ViewSendToVendorContExt contExt = new ViewSendToVendorContExt( standardCont );
                contExt.email.Vendor_Contact__c = testContact.id;
                contExt.sendQuote();
            }

        Test.stopTest();

        List<Attachment> attachmentsForQuote = [ SELECT Id, Name FROM Attachment WHERE ParentId = :testQuote.Id ];
        System.assertEquals( 1, attachmentsForQuote.size(), 'When sending a quote, an attachment should have been generated' );
        System.assertEquals( ViewSendToVendorContExt.WEBSOURCE_FILENAME, attachmentsForQuote[0].Name, 'When sending a quote as a Websource user, the Websource filename should be used' );
    }
    */
    
     private static testMethod void testSendQuote_AsSaalfeldUser()
    {
        //User testSaalfeldUser = TestDataGeneration.getTestUser('WSUser', 'System Administrator');
        //testSaalfeldUser.Department = Consts.SAALFELD_DEPARTMENT;
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id, quote__c from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        ViewSendToVendorContExt contExt;
        Test.startTest();

            //System.runAs( testSaalfeldUser )
            //{
                //testSetupData( testSaalfeldUser.Id );
                Test.setCurrentPageReference( new PageReference(Page.ViewSendToVendor.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id) );

                ApexPages.Standardcontroller standardCont = new ApexPages.Standardcontroller( testQuote );
                contExt = new ViewSendToVendorContExt( standardCont );
                contExt.email.Vendor_Contact__c = testContact.id;
                contExt.sendQuote();
            //}

        Test.stopTest();
        List<Attachment> attachmentsForQuote = [ SELECT Id, Name FROM Attachment WHERE ParentId = :testQuote.Id ];
        System.assertEquals( 1, attachmentsForQuote.size(), 'When sending a quote, an attachment should have been generated' );
    //  System.assertEquals( TestPDFEmailServices.vendorSaalFeld.PDF_File_Name__c, attachmentsForQuote[0].Name, 'When sending a quote as a Fordis user, the Fordis filename should be used' );
     //   System.assertEquals( TestPDFEmailServices.vendorSaalFeld.PDF_Template_Name__c, contExt.templateNameUsed, 'When sending a quote as a Fordis user, the Fordis email template should be used' );
        
        //Id expectedTemplateId = [select Id from EmailTemplate where DeveloperName = :TestPDFEmailServices.vendorSaalFeld.PDF_Template_Name__c].Id;
       // System.assertEquals( expectedTemplateId, contExt.templateIdUsed, 'When sending a quote as a no dept user, the default email template should be used' );
    }

    private static testMethod void testSendQuote_AsNoDepartmentUser()
    {
        //User testUser = TestDataGeneration.getTestUser('DUser', 'System Administrator');
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id, quote__c from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        ViewSendToVendorContExt contExt;
        //testUser.Department = '';

        Test.startTest();

            //System.runAs( testUser )
            //{
                //testSetupData( testUser.Id );
                Test.setCurrentPageReference( new PageReference(Page.ViewSendToVendor.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id) );

                ApexPages.Standardcontroller standardCont = new ApexPages.Standardcontroller( testQuote );
                contExt = new ViewSendToVendorContExt( standardCont );
                contExt.email.Vendor_Contact__c = testContact.id;
                contExt.sendQuote();
            //}

        Test.stopTest();

        List<Attachment> attachmentsForQuote = [ SELECT Id, Name FROM Attachment WHERE ParentId = :testQuote.Id ];
        System.assertEquals( 1, attachmentsForQuote.size(), 'When sending a quote, an attachment should have been generated' );
    //  System.assertEquals( TestPDFEmailServices.vendorDefault.PDF_File_Name__c, attachmentsForQuote[0].Name, 'When sending a quote as a no dept user, the default filename should be used' );
      //  System.assertEquals( TestPDFEmailServices.vendorDefault.PDF_Template_Name__c, contExt.templateNameUsed, 'When sending a quote as a no dept user, the default email template should be used' );
        
        //Id expectedTemplateId = [select Id from EmailTemplate where DeveloperName = :TestPDFEmailServices.vendorDefault.PDF_Template_Name__c].Id;
        //System.assertEquals( expectedTemplateId, contExt.templateIdUsed, 'When sending a quote as a no dept user, the default email template should be used' );
    }
    
    
    private static testMethod void testSendQuote_Prospect()
    {
        //User testUser = TestDataGeneration.getTestUser('DUser', 'System Administrator');
        ViewSendToVendorContExt contExt;
        //testUser.Department = '';
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id, quote__c from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        Test.startTest();

            //System.runAs( testUser )
            //{
                //testSetupData( testUser.Id );
                Test.setCurrentPageReference( new PageReference(Page.ViewSendToVendor.getURL() + '?id=' + testQuote1.Id + '&qliIds=' + testQLIs[0].Id) );

                ApexPages.Standardcontroller standardCont = new ApexPages.Standardcontroller( testQuote );
                contExt = new ViewSendToVendorContExt( standardCont );
                contExt.email.Vendor_Contact__c = testContact.id;
                contExt.sendQuote();
            //}

        Test.stopTest();

        List<Attachment> attachmentsForQuote = [ SELECT Id, Name FROM Attachment WHERE ParentId = :testQuote.Id ];
       // System.assertEquals( 1, attachmentsForQuote.size(), 'When sending a quote, an attachment should have been generated' );
    //  System.assertEquals( TestPDFEmailServices.vendorDefault.PDF_File_Name__c, attachmentsForQuote[0].Name, 'When sending a quote as a no dept user, the default filename should be used' );
      //  System.assertEquals( TestPDFEmailServices.vendorDefault.PDF_Template_Name__c, contExt.templateNameUsed, 'When sending a quote as a no dept user, the default email template should be used' );
        
        //Id expectedTemplateId = [select Id from EmailTemplate where DeveloperName = :TestPDFEmailServices.vendorDefault.PDF_Template_Name__c].Id;
        //System.assertEquals( expectedTemplateId, contExt.templateIdUsed, 'When sending a quote as a no dept user, the default email template should be used' );
    }
    


    private static testMethod void testEmailLookupFilterItemWithNameAndItemWithout()
    {
        //testSetupData();
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id, quote__c from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        Quote_Line_Item__c qli2 = testQLIs[0].clone( false, true);
        
        qli2.Vendor_Contact__c = null;
        qli2.Vendor_Name__c = null;
        
        insert qli2;
        
        Test.startTest();

            
            Test.setCurrentPageReference( new PageReference(Page.ViewSendToVendor.getURL() + '?id=' + testQuote.Id + '&qliIds=' + testQLIs[0].Id + ',' + qli2.Id) );

            ApexPages.Standardcontroller standardCont = new ApexPages.Standardcontroller( testQuote );
            ViewSendToVendorContExt contExt = new ViewSendToVendorContExt( standardCont );

        Test.stopTest();

        System.assertEquals( testQLIs[0].Id, contExt.email.Id, 'The QLI that has a vendor name should be selected' );
    }
    
    private static testMethod void testEmailLookupFilterItemWithNameAndItemWithoutReOrdered()
    {
        //testSetupData();
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id, quote__c from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        Quote_Line_Item__c qli2 = testQLIs[0].clone( false, true);
        
        qli2.Vendor_Contact__c = null;
        qli2.Vendor_Name__c = null;
        
        insert qli2;
        
        Test.startTest();

            
            Test.setCurrentPageReference( new PageReference(Page.ViewSendToVendor.getURL() + '?id=' + testQuote.Id + '&qliIds=' + qli2.Id + ',' + testQLIs[0].Id ) );

            ApexPages.Standardcontroller standardCont = new ApexPages.Standardcontroller( testQuote );
            ViewSendToVendorContExt contExt = new ViewSendToVendorContExt( standardCont );

        Test.stopTest();

        System.assertEquals( testQLIs[0].Id, contExt.email.Id, 'The QLI that has a vendor name should be selected' );
    }
    
    
    private static testMethod void testEmailLookupFilterItemWithoutName()
    {
        //testSetupData();
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id, quote__c from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        Quote_Line_Item__c qli2 = testQLIs[0].clone( false, true);
        
        qli2.Vendor_Contact__c = null;
        qli2.Vendor_Name__c = null;
        
        insert qli2;
        
        Test.startTest();

            
            Test.setCurrentPageReference( new PageReference(Page.ViewSendToVendor.getURL() + '?id=' + testQuote.Id + '&qliIds=' + qli2.Id ) );

            ApexPages.Standardcontroller standardCont = new ApexPages.Standardcontroller( testQuote );
            ViewSendToVendorContExt contExt = new ViewSendToVendorContExt( standardCont );
        Test.stopTest();
        System.assertEquals( qli2.id, contExt.email.Id, 'The QLI that does not have a vendor name should be selected since it is the only one' );
    }

    private static testMethod void Test_IneligibleLineItem()
    {
        //testSetupData();
        list<Quote__c> QuoteList = [select id, account__r.AccountNumber from Quote__c]; 
        for(Quote__c quo:QuoteList){
            if(quo.account__r.AccountNumber =='123456'){
                testQuote = quo;    
            }else{
                testQuote1 = quo;    
            }
            
        }
        testQLIs = [select id, quote__c from Quote_Line_Item__c]; 
        testContact = [select id from Contact]; 
        
        Quote_Line_Item__c qli2 = testQLIs[0].clone( false, true);
        qli2.Product_Code__c = 'Prod Code Required For Updated_P_A__c to be false';
        qli2.Updated_P_A__c = FALSE;
        insert qli2;
        
        Test.startTest();

            
            Test.setCurrentPageReference( new PageReference(Page.ViewSendToVendor.getURL() + '?id=' + testQuote.Id + '&qliIds=' + qli2.Id ) );

            ApexPages.Standardcontroller standardCont = new ApexPages.Standardcontroller( testQuote );
            ViewSendToVendorContExt contExt = new ViewSendToVendorContExt( standardCont );

        Test.stopTest();

        Boolean foundError = false;

        //System.assertEquals( FALSE, contExt.isValidQuote, 'We expect the quote to be invalid.' );
        for(ApexPages.Message   msg : ApexPages.getMessages())
        {
            if(msg.getSummary() == Label.IneligibleQuoteErrorMessage)
            {
                foundError = true;
            }
        }
        //System.assert(foundError, 'We expect the page to contain the proper error message.');
    }
}
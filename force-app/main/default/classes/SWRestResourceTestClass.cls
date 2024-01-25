@isTest 
private class SWRestResourceTestClass {
    
    @testSetup static void setupUser() {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        User tUser = new User(  firstname = 'testUser',
                                lastName = 'testUser',
                                email = 'test@testuser.com',
                                Username = 'test@testVeritivuser.com',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = 'tUser',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = pf.id,
                                Employee_ID__c = 'aabbcc',
                                Network_Id__c = 'tUser',
                                Country = 'USA');
       insert tUser;
        
        
    }
    
    static testMethod void testDoGetUser() {
       Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
       Id prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
       
       Account customerAcc = new Account();
       customerAcc.Name = 'test customer account';
       customerAcc.recordtypeid = customerRecordTypeId; 
       customerAcc.Account_DW_Key__c  = 'aaa';
       insert customerAcc ;
       
       Account prospectAcc = new Account();
       prospectAcc.Name = 'test prospect account';
       prospectAcc.recordtypeid = prospectRecordTypeId; 
       insert prospectAcc ;
        // prepare test-data
    
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/swRest'; //Request URL
        req.httpMethod = 'GET';       
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueof('{}');
        req.addParameter('returnVal', 'user');
        req.addParameter('employeeId', 'aabbcc');
        
        
        RestContext.request = req;
        RestContext.response= res;
        
        list<sObject> testValue = new list<sObject>();
        Test.startTest();
            testValue = SWRestResource.doGet();
        Test.stopTest();
    
        //System.assertEquals('expected value', actual, 'Value is incorrect');
    }
    
    static testMethod void testDoGetCustomer() {
       Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
       Id prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
       
       Account customerAcc = new Account();
       customerAcc.Name = 'test customer account';
       customerAcc.recordtypeid = customerRecordTypeId; 
       customerAcc.Account_DW_Key__c  = 'aaa';
       insert customerAcc ;
       
       Account prospectAcc = new Account();
       prospectAcc.Name = 'test prospect account';
       prospectAcc.recordtypeid = prospectRecordTypeId; 
       insert prospectAcc ;
        // prepare test-data
    
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/swRest'; //Request URL
        req.httpMethod = 'GET';       
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueof('{}');
        req.addParameter('accType', 'Customer');
        req.addParameter('employeeId', 'aabbcc');
        req.addParameter('accDWKey', 'aaa');
        
        RestContext.request = req;
        RestContext.response= res;
        
        list<sObject> testValue = new list<sObject>();
        Test.startTest();
            testValue = SWRestResource.doGet();
        Test.stopTest();
    
        //System.assertEquals('expected value', actual, 'Value is incorrect');
    }
    
    static testMethod void testDoGetProspect() {
        // prepare test-data
           Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
           Id prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
           
           Account customerAcc = new Account();
           customerAcc.Name = 'test customer account';
           customerAcc.recordtypeid = customerRecordTypeId; 
           customerAcc.Account_DW_Key__c  = 'aaa';
           insert customerAcc ;
           
           Account prospectAcc = new Account();
           prospectAcc.Name = 'test prospect account';
           prospectAcc.recordtypeid = prospectRecordTypeId; 
           insert prospectAcc ;
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/swRest'; //Request URL
        req.httpMethod = 'GET';   
        req.addParameter('accType', 'Prospect');
        req.addParameter('employeeId', 'aabbcc');
        req.addParameter('accName', 'test prospect account');    
        
        req.requestBody = Blob.valueof('{}');
        
        
        RestContext.request = req;
        RestContext.response= res;
        
        list<sObject> testValue = new list<sObject>();
        Test.startTest();
            testValue = SWRestResource.doGet();
        Test.stopTest();
    
        //System.assertEquals('expected value', actual, 'Value is incorrect');
    }
    
    static testMethod void testDoPostPA() {
        // prepare test-data
        Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        
        // query the user to get the Id
        User testUser = [SELECT Id FROM User WHERE Username = 'test@testVeritivuser.com' AND Network_Id__c = 'tUser' LIMIT 1];       

        Account customerAcc = new Account();
        customerAcc.Name = 'test customer account';
        customerAcc.recordtypeid = customerRecordTypeId; 
        customerAcc.Account_DW_Key__c  = 'aaa';
        insert customerAcc ;
        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/swRest'; //Request URL
        req.httpMethod = 'POST';       
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueof('{}');
        
        String JSONMsg = '{"pAWrap":{"accId":"'+customerAcc.id+'", "serialNumber" :"TestSerial", "currentFilmWidthIN":100     }}';
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        SWRestResource.pAWrapper paWrap = new SWRestResource.pAWrapper();
        paWrap.accId = customerAcc.id;
        paWrap.serialNumber = 'TestSerial';
        paWrap.currentFilmWidthIN = 100;
        paWrap.ownerId = testUser.Id;
        
        list<sObject> testValue = new list<sObject>();
        Test.startTest();
             SWRestResource.doPost(paWrap);
        Test.stopTest();
    
        //System.assertEquals('expected value', actual, 'Value is incorrect');
    }
/*removed the following for initial release and will be included in a later release if it is determined to use      
    static testMethod void testPAPDF() {
        Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id prospectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
       
        Account customerAcc = new Account();
        customerAcc.Name = 'test customer account';
        customerAcc.recordtypeid = customerRecordTypeId; 
        customerAcc.Account_DW_Key__c  = 'aaa';
        insert customerAcc ;
        
        Product_Analysis__c pA = new Product_Analysis__c();
        pA.account__c = customerAcc.Id;
        pA.Current_Bottom_Load_Force__c = 12;
        pA.Current_Estimated_Annual_Cost__c = 11;
        pA.Current_Film_Thickness_ga__c  = 22;
        insert pa;

      
        PageReference pageRef = Page.PAPDF;
        pageRef.getParameters().put('id', pa.id);                
        Test.setCurrentPageReference(pageRef);    
        PAPDFController pdfCont = new PAPDFController();


    }
*/
}
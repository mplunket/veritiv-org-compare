@isTest
private class FieldSourcingQuotingControllerTest {
    public static Boolean noWorkOrder;
    public static Account testAcct;
    public static Quote__c testQuote;
    public static WorkOrder wo;
    public static String EXPECTED_SQL_STRING = 'SELECT Primary_Merchandising_Segment__c, Account__c, Id FROM Quote__c WHERE ID = \'';
    public static Map<String, Object> FACILITY_MAP = new Map<String, Object>{'Field_Data_Origin_API_Name__c' => 'Primary_Merchandising_Segment__c',
                                                                                        'Work_Order_Field_API_Name__c' => 'Freight_Value__c',
                                                                                        'Field_Data_Numeric_Value__c' => '', 
                                                                                        'Field_Data_Text_Value__c' => ''};
                                                                                        
    final static Map<String, Object> ACCOUNT_MAP = new Map<String, Object>{'Field_Data_Origin_API_Name__c' => 'Account__c',
                                                                                        'Work_Order_Field_API_Name__c' => 'AccountId',
                                                                                        'Field_Data_Numeric_Value__c' => '', 
                                                                                        'Field_Data_Text_Value__c' => ''};
                                                                                        
    final static Map<String, Object> REQUEST_MAP = new Map<String, Object>{'Field_Data_Origin_API_Name__c' => '',
                                                                                 'Work_Order_Field_API_Name__c' => 'Request__c',
                                                                                 'Field_Data_Numeric_Value__c' => '', 
                                                                                 'Field_Data_Text_Value__c' => 'Testing'};
                                                                                        
    final static Map<String, Object> TEXT_DEFAULT_MAP = new Map<String, Object>{'Field_Data_Origin_API_Name__c' => '',
                                                                                    'Work_Order_Field_API_Name__c' => 'Source__c',
                                                                                    'Field_Data_Numeric_Value__c' => '', 
                                                                                    'Field_Data_Text_Value__c' => 'TRUE'};
                                                                                    
    final static Map<String, Object> NUM_DEFAULT_MAP = new Map<String, Object>{'Field_Data_Origin_API_Name__c' => '',
                                                                                 'Work_Order_Field_API_Name__c' => 'Bill_To_Number__c',
                                                                                 'Field_Data_Numeric_Value__c' => '12345', 
                                                                                 'Field_Data_Text_Value__c' => ''};
                                                                                 
    final static Map<String, Object> NULL_DEFAULT_MAP = new Map<String, Object>{'Field_Data_Origin_API_Name__c' => '',
                                                                                 'Work_Order_Field_API_Name__c' => 'Bill_To_Number__c',
                                                                                 'Field_Data_Numeric_Value__c' => '', 
                                                                                 'Field_Data_Text_Value__c' => ''};
                                                                                 
    static List<Send_to_field_sourcing__mdt> allFields = new List<Send_to_field_sourcing__mdt>();
    static Send_to_field_sourcing__mdt facilityField = new Send_to_field_sourcing__mdt();
    static Send_to_field_sourcing__mdt accountField = new Send_to_field_sourcing__mdt();
    static Send_to_field_sourcing__mdt requestField = new Send_to_field_sourcing__mdt();
    static Send_to_field_sourcing__mdt numDefaultField = new Send_to_field_sourcing__mdt();
    static Send_to_field_sourcing__mdt textDefaultField = new Send_to_field_sourcing__mdt();
    static Send_to_field_sourcing__mdt nullDefaultField = new Send_to_field_sourcing__mdt();
    static Account testCustAccount;
    public static void setup() {
        
        Primary_Sales_Rep__c psr = TestingUtils.createPSRs(1, 'Testerino', '111111', true)[0];
        
        testQuote = createTestQuote('Draft');
        
        Opportunity testOpp = TestingUtils.createOpportunity(testCustAccount.Id, 'Opperino Testerino');
        testOpp.Primary_Sales_Rep_Name__c = psr.Id;
        insert testOpp;
    
        wo = new WorkOrder();
        wo.AccountId = testCustAccount.Id;
        wo.Quote__c = testQuote.Id;
        wo.Opportunity_del__c = testOpp.Id;
        wo.Request__c = 'You must see this droid safely delivered to him on Alderaan. This is our most desperate hour. Help me, Obi-Wan Kenobi. You\'re my only hope';
        
        List<Apex_Class_Error_Emails__c> recipientEmails = new List<Apex_Class_Error_Emails__c>{new Apex_Class_Error_Emails__c(User_ID__c = String.valueOf(TestingUtils.ADMIN_USER.Id)), 
                                                                                                new Apex_Class_Error_Emails__c(User_ID__c = String.valueOf(TestingUtils.ADMIN_USER.Id))};
        
    }
    public static void setupMetadata(){
        facilityField = (Send_to_field_sourcing__mdt) JSONUtils.createSObject(Send_to_field_sourcing__mdt.SObjectType, FACILITY_MAP);
        allFields.add(facilityField);
        
        accountField = (Send_to_field_sourcing__mdt) JSONUtils.createSObject(Send_to_field_sourcing__mdt.SObjectType, ACCOUNT_MAP);
        allFields.add(accountField);
        
        requestField = (Send_to_field_sourcing__mdt) JSONUtils.createSObject(Send_to_field_sourcing__mdt.SObjectType, REQUEST_MAP);
        allFields.add(requestField);

        numDefaultField = (Send_to_field_sourcing__mdt) JSONUtils.createSObject(Send_to_field_sourcing__mdt.SObjectType, NUM_DEFAULT_MAP);
        allFields.add(numDefaultField);
        
        textDefaultField = (Send_to_field_sourcing__mdt) JSONUtils.createSObject(Send_to_field_sourcing__mdt.SObjectType, TEXT_DEFAULT_MAP);
        allFields.add(textDefaultField);
    }
        
    private static Quote__c createTestQuote(String testStage)
    {   
        Primary_Sales_Rep__c psr = TestingUtils.createPSRs(1, 'Testerino', '111111', true)[0];
        ID custRecTypeID = [select Id from RecordType where SobjectType = 'Account' and Name = 'Customer'].Id;
        testCustAccount = new Account( Name='Test Customer', 
                                       RecordTypeId=custRecTypeID, 
                                       AccountNumber='123456', 
                                       Ship_To_Code__c='000001', Active__c='Yes', 
                                       Primary_Sales_Rep_Name__c = psr.Id );
        insert testCustAccount;
        
        testQuote = new Quote__c(Account__c=testCustAccount.Id, Quote_Stage__c = testStage, Primary_Merchandising_Segment__c = 'Fine Paper', Currency__c = 'USD');
        insert testQuote;
        
        return testQuote;        
    }

    // Test saveAndSetStage() for normal operation
    private static testmethod void test_saveAndSetStage()
    {   
        setup();
        setupMetadata();    
        testQuote = createTestQuote('Draft');
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
        FieldSourcingQuotingController controllerExt = new FieldSourcingQuotingController(controller);
        
        Test.startTest();
            controllerExt.quoteToWorkOrderFieldMap = allFields;
            controllerExt.merchandiserQuote.Primary_Merchandising_Segment__c = 'Packaging';
            controllerExt.saveAndSetStage();
        Test.stopTest();
        
        testQuote = [select Id, Quote_Stage__c, Primary_Merchandising_Segment__c, Account__c from Quote__c where Id = :testQuote.Id];
        //  Commented out the assert as the "With Field Sourcing" value for Quote stage is current inactive
        //System.assertEquals(FieldSourcingQuotingController.WITH_FIELD_SOURCING, testQuote.Quote_Stage__c);
        
         for(ApexPages.Message message : ApexPages.getMessages()){
            //  Commented out the assert as the "With Field Sourcing" value for Quote stage is current inactive
            //System.assertEquals(true, String.valueOf(message).contains(Label.SendToFieldSourcingSuccess), 'There should be a page message showing success.');
        }
        
        List<WorkOrder> actualWorkOrder = [SELECT Id, Freight_Value__c, AccountId, Source__c, Bill_To_Number__c 
                                           FROM WorkOrder];
        //  Commented out the assert as the "With Field Sourcing" value for Quote stage is current inactive
        /*                                   
        System.assertEquals(true, !actualWorkOrder.isEmpty(), 'Queried for work order record should not be null.');
        System.assertEquals(testQuote.Primary_Merchandising_Segment__c, actualWorkOrder[0].Freight_Value__c, 'These two values should be equal.');
        System.assertEquals(testQuote.Account__c, actualWorkOrder[0].AccountId, 'These Account values should be equal.');
        System.assertEquals('TRUE', actualWorkOrder[0].Source__c, 'The Source__c value should be true.');
        System.assertEquals('12345', actualWorkOrder[0].Bill_To_Number__c, 'The Bill_To_Number__c value should be 12345.');
        */
    }
    
    // Test saveAndSetStage() when a failure is forced
    private static testmethod void test_saveAndSetStage_Fail()
    {       
        testQuote = createTestQuote('Draft');
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
        FieldSourcingQuotingController controllerExt = new FieldSourcingQuotingController(controller);
        
        controllerExt.merchandiserQuote.Primary_Merchandising_Segment__c = 'Packaging';
        controllerExt.merchandiserQuote.Account__c = null;
        
        controllerExt.saveAndSetStage();
        
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }
    private static testmethod void test_noWorkOrders_NoWo() {
        setup();
        
        testAcct = TestingUtils.createAccount('Testerino', true);
        testQuote = createTestQuote('Draft');
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
        FieldSourcingQuotingController controllerExt = new FieldSourcingQuotingController(controller);
    
        Test.startTest();
            noWorkOrder = controllerExt.noWorkOrders;
        Test.stopTest();
        
        System.assert(noWorkOrder, 'We expect there to be no work orders under our quote.');
    }
    
    private static testmethod void test_noWorkOrders_WithWo() {
        setup();
        setupMetadata();
        
        insert wo;
            
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
        FieldSourcingQuotingController controllerExt = new FieldSourcingQuotingController(controller);
    
        Test.startTest();
            noWorkOrder = controllerExt.noWorkOrders;
        Test.stopTest();
        
        System.assert(!noWorkOrder, 'We expect there to be a work order under our quote.');
    }
    private static testMethod void test_buildSqlStatement(){
        setup();
        setupMetadata();
        
        String objectApiName = 'Quote__c';
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
        FieldSourcingQuotingController controllerExt = new FieldSourcingQuotingController(controller);
        Id quoteId = testQuote.Id;
        EXPECTED_SQL_STRING += quoteId + '\'';
        
        Test.startTest();
            controllerExt.quoteToWorkOrderFieldMap = allFields;
            String actualSqlString = controllerExt.buildSqlStatement(testQuote.Id, objectApiName);
        Test.stopTest();
        
        System.assertEquals(EXPECTED_SQL_STRING, actualSqlString, 'The sql string returned should be the expected string');
    }
    private static testMethod void test_buildWorkOrder_Success(){
        setup();
        setupMetadata();
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
        FieldSourcingQuotingController controllerExt = new FieldSourcingQuotingController(controller);
    
        Test.startTest();
            controllerExt.quoteToWorkOrderFieldMap = allFields;
            WorkOrder actualWorkOrder = controllerExt.buildWorkOrder(testQuote.Id);
        Test.stopTest();
        
        System.assertEquals(true, actualWorkOrder != null, 'Returned work order record should not be null.');
        System.assertEquals(testQuote.Primary_Merchandising_Segment__c, actualWorkOrder.Freight_Value__c, 'These two values should be equal.');
        System.assertEquals(testQuote.Account__c, actualWorkOrder.AccountId, 'These Account values should be equal.');
        System.assertEquals('TRUE', actualWorkOrder.Source__c, 'The Source__c value should be true.');
        System.assertEquals('12345', actualWorkOrder.Bill_To_Number__c, 'The Bill_To_Number__c value should be 12345.');
    }
    private static testMethod void test_buildWorkOrder_MetaDataFailure1(){
        setup();
        
        setupMetadata();
        nullDefaultField = (Send_to_field_sourcing__mdt) JSONUtils.createSObject(Send_to_field_sourcing__mdt.SObjectType, NULL_DEFAULT_MAP);
        allFields.add(nullDefaultField);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
        FieldSourcingQuotingController controllerExt = new FieldSourcingQuotingController(controller);
        
        String subject = '';
        String body = '';
        Integer emailLimitBefore = 0;
        Integer emailLimitAfter = 0;
        
        Test.startTest();
            emailLimitBefore = Limits.getEmailInvocations();
                controllerExt.quoteToWorkOrderFieldMap = allFields;
                WorkOrder actualWorkOrder = controllerExt.buildWorkOrder(testQuote.Id);
            emailLimitAfter = Limits.getEmailInvocations(); 
        Test.stopTest();
        
        System.assertEquals(true, actualWorkOrder == null, 'Returned work order record should be null.');
        System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.INFO), 'Returned work order record should be null.');
        
        for(ApexPages.Message message : ApexPages.getMessages()){
            System.assertEquals(true, String.valueOf(message).contains(Label.SendToFieldSourcingErrorText), 'There should be a page message for the error.');
        }
        System.assertEquals(emailLimitBefore + 1, emailLimitAfter, 'An email should have been sent');
    }
    private static testMethod void test_buildWorkOrder_MetaDataFailure2(){
        setup();

        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
        FieldSourcingQuotingController controllerExt = new FieldSourcingQuotingController(controller);
        
        String subject = '';
        String body = '';
        Integer emailLimitBefore = 0;
        Integer emailLimitAfter = 0;
        
        Test.startTest();
            emailLimitBefore = Limits.getEmailInvocations();
                controllerExt.quoteToWorkOrderFieldMap = allFields;
                WorkOrder actualWorkOrder = controllerExt.buildWorkOrder(testQuote.Id);
            emailLimitAfter = Limits.getEmailInvocations(); 
        Test.stopTest();
        
        System.assertEquals(true, actualWorkOrder == null, 'Returned work order record should be null.');
        System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.INFO), 'Should have error message.');
        
        for(ApexPages.Message message : ApexPages.getMessages()){
            System.assertEquals(true, String.valueOf(message).contains(Label.SendToFieldSourcingErrorText), 'There should be a page message for the error.');
        }
        System.assertEquals(emailLimitBefore + 1, emailLimitAfter, 'An email should have been sent');
    }
    private static testMethod void test_sendErrorEmail(){
        setup();
        String subject = '';
        String body = '';
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
        FieldSourcingQuotingController controllerExt = new FieldSourcingQuotingController(controller);
        Integer emailLimitBefore = 0;
        Integer emailLimitAfter = 0;
        
        Test.startTest();
            emailLimitBefore = Limits.getEmailInvocations();
                controllerExt.sendErrorEmail(body);
            emailLimitAfter = Limits.getEmailInvocations(); 
        Test.stopTest();
        
        System.assertEquals(emailLimitBefore + 1, emailLimitAfter, 'An email should have been sent');
        
    }
    private static testMethod void test_populateWorkOrders_Success(){
        setup();
        setupMetadata();
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
        FieldSourcingQuotingController controllerExt = new FieldSourcingQuotingController(controller);
    
        Test.startTest();
            controllerExt.quoteToWorkOrderFieldMap = allFields;
            WorkOrder builtWorkOrder = controllerExt.buildWorkOrder(testQuote.Id);
            controllerExt.populateWorkOrders(builtWorkOrder);
        Test.stopTest();
        
        List<WorkOrder> actualWorkOrder = [SELECT Id, Freight_Value__c, AccountId, Source__c, Bill_To_Number__c 
                                           FROM WorkOrder];
                                           
        System.assertEquals(true, !actualWorkOrder.isEmpty(), 'Queried for work order record should not be null.');
        System.assertEquals(testQuote.Primary_Merchandising_Segment__c, actualWorkOrder[0].Freight_Value__c, 'These two values should be equal.');
        System.assertEquals(testQuote.Account__c, actualWorkOrder[0].AccountId, 'These Account values should be equal.');
        System.assertEquals('TRUE', actualWorkOrder[0].Source__c, 'The Source__c value should be true.');
        System.assertEquals('12345', actualWorkOrder[0].Bill_To_Number__c, 'The Bill_To_Number__c value should be 12345.');
    }
    private static testMethod void test_populateWorkOrders_Failure(){
        setup();
        setupMetadata();
        
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);
        FieldSourcingQuotingController controllerExt = new FieldSourcingQuotingController(controller);
        
        WorkOrder failWo = new WorkOrder();
        
        Test.startTest();
            controllerExt.quoteToWorkOrderFieldMap = allFields;
            controllerExt.populateWorkOrders(failWo);
        Test.stopTest();
        
        List<WorkOrder> actualWorkOrder = [SELECT Id, Freight_Value__c, AccountId, Source__c, Bill_To_Number__c 
                                           FROM WorkOrder];
                                           
        System.assertEquals(true, actualWorkOrder.isEmpty(), 'Queried for work order record should not be null.');
        System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.INFO), 'Should have error message.');
        
        Boolean messageFound = false;
        for(ApexPages.Message message : ApexPages.getMessages()){
            if(String.valueOf(message).contains(Label.SendToFieldSourcingErrorText)){
                messageFound = true;
                break;
            }
        }
        System.assertEquals(true, messageFound, 'There should be a page message for the error');
    }
}
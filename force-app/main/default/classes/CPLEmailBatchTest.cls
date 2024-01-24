@isTest
public with sharing class CPLEmailBatchTest 
{
    @testSetup
    public static void prepareConfig(){
        AIQTestSetup.setConfig();
    }
    
    @isTest
    public static void execute_testFriday_XLS()
    {
        Test.startTest();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(1, Product2.SObjectType))
            .tag('Products');

        insert UnitTest.get('Products').getList();

        UnitTest.addData(SObjectFactory.build(1, zpl__ContractLineItem__c.SObjectType))
            .tag('Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published');

        insert UnitTest.get('Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today())
            .property('Print_Date__c').assign('Per Submit Every Friday')
            .property('Version_Format__c').assign('XLS')
            .property('Customer_Email__c').assign('test@test.com');

        insert UnitTest.get('Customer Price List').getList();

        CPLEmailBatch batch = new CPLEmailBatch();
        batch.today = getNextFriday();

        Database.executeBatch(batch);
        Integer invocations = Limits.getEmailInvocations();

        List<CPL_Batch_Result__c> result = [SELECT Id, Emails_Actually_Sent__c, Emails_With_Error__c FROM CPL_Batch_Result__c LIMIT 1];
        List<CPL_Batch_Email_Error__c> emailErrors = [SELECT Id FROM CPL_Batch_Email_Error__c];

        Test.stopTest();
    }
    
    @isTest
    public static void execute_testFriday_PDF()
    {
        Test.startTest();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(1, Product2.SObjectType))
            .tag('Products');

        insert UnitTest.get('Products').getList();

        UnitTest.addData(SObjectFactory.build(1, zpl__ContractLineItem__c.SObjectType))
            .tag('Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published');

        insert UnitTest.get('Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today())
            .property('Print_Date__c').assign('Per Submit Every Friday')
            .property('Version_Format__c').assign('PDF')
            .property('Customer_Email__c').assign('test@test.com');

        insert UnitTest.get('Customer Price List').getList();

        CPLEmailBatch batch = new CPLEmailBatch();
        batch.today = getNextFriday();

        Database.executeBatch(batch);
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();
    }
    
    
    @isTest
    public static void execute_testFriday_WithTwoCPL()
    {
        Test.startTest();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(1, Product2.SObjectType))
            .tag('Products');

        insert UnitTest.get('Products').getList();

        UnitTest.addData(SObjectFactory.build(1, zpl__ContractLineItem__c.SObjectType))
            .tag('Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published');

        insert UnitTest.get('Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today())
            .property('Print_Date__c').assign('Per Submit Every Friday')
            .property('Last_Successful_Run_Time__c').assign(datetime.newInstance(2014, 9, 15, 13, 30, 0)) // assign old dates
            .property('Customer_Email__c').assign('test@test.com');

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today())
            .property('Print_Date__c').assign('Per Submit Every Friday')
            .property('Customer_Email__c').assign('test@test.com');

        insert UnitTest.get('Customer Price List').getList();

        CPLEmailBatch batch = new CPLEmailBatch();
        batch.today = getNextFriday();

        Database.executeBatch(batch);
        Integer invocations = Limits.getEmailInvocations();

        List<CPL_Batch_Result__c> result = [SELECT Id, Emails_Actually_Sent__c, Emails_With_Error__c FROM CPL_Batch_Result__c LIMIT 1];
        List<CPL_Batch_Email_Error__c> emailErrors = [SELECT Id FROM CPL_Batch_Email_Error__c];


        Test.stopTest();
    }

    @isTest
    public static void execute_testMonthly()
    {
        Test.startTest();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(1, Product2.SObjectType))
            .tag('Products');

        insert UnitTest.get('Products').getList();

        UnitTest.addData(SObjectFactory.build(1, zpl__ContractLineItem__c.SObjectType))
            .tag('Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published');


        insert UnitTest.get('Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today())
            .property('Print_Date__c').assign('Monthly')
            .property('Customer_Email__c').assign('test@test.com');

        insert UnitTest.get('Customer Price List').getList();

        CPLEmailBatch batch = new CPLEmailBatch();
        batch.today = getNext25th();

        Database.executeBatch(batch);
        Integer invocations = Limits.getEmailInvocations();

        List<CPL_Batch_Result__c> result = [SELECT Id, Emails_Actually_Sent__c, Emails_With_Error__c FROM CPL_Batch_Result__c LIMIT 1];
        List<CPL_Batch_Email_Error__c> emailErrors = [SELECT Id FROM CPL_Batch_Email_Error__c];

        Test.stopTest();
    }

    @isTest
    public static void execute_testFailureReporting()
    {
        Test.startTest();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(1, Product2.SObjectType))
            .tag('Products');

        insert UnitTest.get('Products').getList();

        UnitTest.addData(SObjectFactory.build(1, zpl__ContractLineItem__c.SObjectType))
            .tag('Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published');

        insert UnitTest.get('Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today())
            .property('Print_Date__c').assign('Per Submit Every Friday')
            .property('Customer_Email__c').assign('BAD EMAIL');

        insert UnitTest.get('Customer Price List').getList();

        CPLEmailBatch batch = new CPLEmailBatch();
        batch.today = getNextFriday();

        Database.executeBatch(batch);
        Integer invocations = Limits.getEmailInvocations();

        List<CPL_Batch_Result__c> result = [SELECT Id, Emails_Actually_Sent__c, Emails_With_Error__c FROM CPL_Batch_Result__c LIMIT 1];
        List<CPL_Batch_Email_Error__c> emailErrors = [SELECT Id FROM CPL_Batch_Email_Error__c];

        Test.stopTest();
    }

    @isTest
    public static void execute_testNotRunDay()
    {
        Test.startTest();
        CPLEmailBatch batch = new CPLEmailBatch();
        batch.today = getNextNonFridayAnd25th();

        Database.executeBatch(batch);
        Integer invocations = Limits.getEmailInvocations();

        List<CPL_Batch_Result__c> results = [SELECT Id, Emails_Actually_Sent__c, Emails_With_Error__c FROM CPL_Batch_Result__c LIMIT 1];
        List<CPL_Batch_Email_Error__c> emailErrors = [SELECT Id FROM CPL_Batch_Email_Error__c];

        Test.stopTest();
    }

    @isTest
    public static void execute_testSchedulable()
    {
        CPLEmailBatchSchedulable schedulable = new CPLEmailBatchSchedulable();

        Test.startTest();
        try {
            schedulable.execute(null);
        }
        catch(Exception e) {
        
        }
        Test.stopTest();
    }

    private static Date getNextFriday()
    {
        Date currentDate = Date.today();
        DateTime currentDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());

        while (currentDateTime.format('EEEE') != 'Friday')
        {
            currentDate = currentDate.addDays(1);
            currentDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
        }

        return currentDate;
    }

    private static Date getNext25th()
    {
        Date currentDate = Date.today();

        while (currentDate.day() != 25) 
        {
            currentDate = currentDate.addDays(1);
        }

        return currentDate;
    }

    private static Date getNextNonFridayAnd25th()
    {
        Date currentDate = Date.today();
        DateTime currentDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());

        while (currentDate.day() == 25 || currentDateTime.format('EEEE') == 'Friday') 
        {
            currentDate = currentDate.addDays(1);
            currentDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
        }

        return currentDate;
    }
}
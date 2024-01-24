@isTest
public class CPLServicesTest 
{
    @testSetup static void createPolicyType(){
        List<zpl__PolicyType__c> lPolicyType = new List<zpl__PolicyType__c>{new zpl__PolicyType__c(Name = 'CWT Fixed', zpl__PolicyTypeId__c = 'cwtFixed'), 
            																new zpl__PolicyType__c(Name = 'Fixed Price', zpl__PolicyTypeId__c = 'fixedPrice'),
            																new zpl__PolicyType__c(Name = 'List Down', zpl__PolicyTypeId__c = 'listDown'), 
            																new zpl__PolicyType__c(Name = 'Maintain GTM', zpl__PolicyTypeId__c = 'maintainGTM'),
            																new zpl__PolicyType__c(Name = 'Natl Account', zpl__PolicyTypeId__c = 'nationalAccount')};
       insert lPolicyType;
    }
        
    @isTest
    public static void getAgreementLinesFromCPL_testNoFilters() 
    {
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
            .tag('Products');

        insert UnitTest.get('Products').getList();
        List<String> levelValue = new List<String>();
        
        for (Integer i = 0; i < numberOfAgreementLineItems; i++)
        {
            levelValue.add('Test LevelValue ' + i);
        }
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('Net_Price__c').assign(200);

        insert UnitTest.get('Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today());

        Customer_Price_List__c cpl = (Customer_Price_List__c) UnitTest.get('Customer Price List').getList()[0];

        Test.startTest();
        List<CPLServices.AgreementLineItemWrapper> agreementLineItems = CPLServices.getAgreementLineItemsFromCPL(cpl);
        Test.stopTest();

        //System.assertEquals(numberOfAgreementLineItems, agreementLineItems.size(), 'We expect all of the created agreement line items to appear on the CPL.');
    }

    @isTest
    public static void getAgreementLinesFromCPL_testClassificationFilters() 
    {
        Integer numberOfEachClassification = 5;
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(numberOfEachClassification, Servicing_Division__c.SObjectType))
            .tag('Divisions');

        insert UnitTest.get('Divisions').getList();

        List<String> segments = new List<String>();
        List<String> classes = new List<String>();
        List<String> brands = new List<String>();
        for (Integer i = 0; i < numberOfEachClassification; i++)
        {
            segments.add('Test Segment ' + i);
            classes.add('Test Class ' + i);
            brands.add('Test Brand ' + i);
        }
        
        List<String> levelValue = new List<String>();
        for (Integer i = 0; i < numberOfAgreementLineItems; i++)
        {
            levelValue.add('Test LevelValue ' + i);
        }

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
            .tag('Products');

        insert UnitTest.get('Products').getList();

        UnitTest.addData(SObjectFactory.build(1, zpl__ProductSelectorConfiguration__c.SObjectType))
            .tag('Product Selector Configuration to Contract')
            .property('zpl__TargetObject__c').assign('Contract')
            .property('name').assign('Add Contract Products')
            .property('zpl__UniqueNickname__c').assign('DefaultContract');
        insert UnitTest.get('Product Selector Configuration to Contract').getList();
        zpl__ProductSelectorConfiguration__c testPSconfig = (zpl__ProductSelectorConfiguration__c) UnitTest.get('Product Selector Configuration to Contract').getList()[0];
        UnitTest.addData(SObjectFactory.build(1, zpl__LineLevel__c.SObjectType))
            .tag('Set Level')
            .property('Name').assign('SubSet')
            .property('zpl__Position__c').assign(2)
            .property('zpl__ProductSelectorConfiguration__c').assign(testPSconfig.Id);
        insert UnitTest.get('Set Level').getList();
        zpl__LineLevel__c level = (zpl__LineLevel__c) UnitTest.get('Set Level').getList()[0];

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('Division__c').assignFrom('Divisions')
            .property('Segment__c').assignFrom(segments)
            .property('Class__c').assignFrom(classes)
            .property('Brand__c').assignFrom(brands)
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .property('Net_Price__c').assign(200);

        insert UnitTest.get('Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today())
            .property('Division__c').assignFrom('Divisions')
            .property('Segments__c').assignFrom(segments)
            .property('Classes__c').assignFrom(classes)
            .property('Brands__c').assignFrom(brands)
            .property('Level_Filter__c').assign('Item Level (Expand Sets and Subsets)');

        Customer_Price_List__c cpl = (Customer_Price_List__c) UnitTest.get('Customer Price List').getList()[0];

        Test.startTest();
        List<CPLServices.AgreementLineItemWrapper> agreementLineItems = CPLServices.getAgreementLineItemsFromCPL(cpl);
        Map<String, List<CPLServices.AgreementLineItemWrapper>> agreementLineItemsbyDivision = CPLServices.getAgreementLineItemsFromCPLByDivision(cpl, 'External', null);
        Test.stopTest();

        //System.assertEquals(numberOfAgreementLineItems / numberOfEachClassification, agreementLineItems.size(), 'We expect the CPL to contain line items that match only the classifications specified.');
    }

    @isTest
    public static void getAgreementLinesFromCPL_testNewOrChangedOnly() 
    {
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
            .tag('Products');

        insert UnitTest.get('Products').getList();
        
        UnitTest.addData(SObjectFactory.build(1, zpl__ProductSelectorConfiguration__c.SObjectType))
            .tag('Product Selector Configuration to Contract')
            .property('zpl__TargetObject__c').assign('Contract')
            .property('name').assign('Add Contract Products')
            .property('zpl__UniqueNickname__c').assign('DefaultContract');
        insert UnitTest.get('Product Selector Configuration to Contract').getList();
        zpl__ProductSelectorConfiguration__c testPSconfig = (zpl__ProductSelectorConfiguration__c) UnitTest.get('Product Selector Configuration to Contract').getList()[0];
        UnitTest.addData(SObjectFactory.build(1, zpl__LineLevel__c.SObjectType))
            .tag('Set Level')
            .property('Name').assign('Set')
            .property('zpl__Position__c').assign(2)
            .property('zpl__ProductSelectorConfiguration__c').assign(testPSconfig.Id);
        insert UnitTest.get('Set Level').getList();
        zpl__LineLevel__c level = (zpl__LineLevel__c) UnitTest.get('Set Level').getList()[0];
        List<String> levelValue = new List<String>();
        for (Integer i = 0; i < numberOfAgreementLineItems; i++)
        {
            levelValue.add('Test LevelValue ' + i);
        } 
        
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')            
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .property('Net_Price__c').assign(200);

        insert UnitTest.get('Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today())
            .property('New_Or_Changed_Only__c').assign(true)
            .property('Level_Filter__c').assign('Item Level (Expand Sets and Subsets)');

        Customer_Price_List__c cpl = (Customer_Price_List__c) UnitTest.get('Customer Price List').getList()[0];

        Test.startTest();
        List<CPLServices.AgreementLineItemWrapper> agreementLineItems = CPLServices.getAgreementLineItemsFromCPL(cpl);
        Test.stopTest();

        //System.assertEquals(numberOfAgreementLineItems, agreementLineItems.size(), 'We expect all of the newly created agreement line items to appear on the CPL.');
    }

    @isTest
    public static void getAgreementLinesFromCPL_testPurchased() 
    {
        Integer numberOfAgreementLineItems = 40;

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
            .tag('Products');

        insert UnitTest.get('Products').getList();
        
        List<String> levelValue = new List<String>();
        for (Integer i = 0; i < numberOfAgreementLineItems; i++)
        {
            levelValue.add('Test LevelValue ' + i);
        }
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .branch('Purchased|None')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('Net_Price__c').assign(200);

        UnitTest.get('Purchased')
            .property('X12MonthSalesVolume__c').assign(100);

        insert UnitTest.get('Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today())
            .property('Purchased_Stocked_Filter__c').assign('Show Purchased Agreement Lines Only');

        Customer_Price_List__c cpl = (Customer_Price_List__c) UnitTest.get('Customer Price List').getList()[0];

        Test.startTest();
        List<CPLServices.AgreementLineItemWrapper> agreementLineItems = CPLServices.getAgreementLineItemsFromCPL(cpl);
        Test.stopTest();

        //System.assertEquals(numberOfAgreementLineItems / 2, agreementLineItems.size(), 'We expect all of the purchased agreement line items to appear on the CPL.');
    }

    @isTest
    public static void getAgreementLinesFromCPL_testStocked() 
    {
        Integer numberOfAgreementLineItems = 40;

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
            .tag('Products')
            .branch('Stocked Products|Unstocked Products');

        UnitTest.get('Stocked Products')
            .property('Stocking_Flag__c').assign(true);

        insert UnitTest.get('Products').getList();
        
        List<String> levelValue = new List<String>();        
        for (Integer i = 0; i < numberOfAgreementLineItems; i++)
        {
            levelValue.add('Test LevelValue ' + i);
        }

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .branch('Stocked|None')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('Net_Price__c').assign(200);

        UnitTest.get('Stocked')
            .property('zpl__Product__c').assignFrom('Stocked Products');

        UnitTest.get('None')
            .property('zpl__Product__c').assignFrom('Unstocked Products');

        insert UnitTest.get('Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today())
            .property('Purchased_Stocked_Filter__c').assign('Show Stock Agreement Lines Only');

        Customer_Price_List__c cpl = (Customer_Price_List__c) UnitTest.get('Customer Price List').getList()[0];

        Test.startTest();
        List<CPLServices.AgreementLineItemWrapper> agreementLineItems = CPLServices.getAgreementLineItemsFromCPL(cpl);
        Test.stopTest();

        //System.assertEquals(numberOfAgreementLineItems / 2, agreementLineItems.size(), 'We expect all of the purchased agreement line items to appear on the CPL.');
    }

    @isTest
    public static void getAgreementLinesFromCPL_testSorting() 
    {
        Integer numberOfAgreementLineItemsToSort = 100;

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItemsToSort, Product2.SObjectType))
            .tag('Products');

        insert UnitTest.get('Products').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        List<Product2> products = (List<Product2>) UnitTest.get('Products').getList();
        List<zpl__ContractLineItem__c> agreementLineItems = new List<zpl__ContractLineItem__c>();
        String activeRecordType = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByName()
                                                                .get('Active')
                                                                .getRecordTypeId();

        for (Integer i = 0; i < 100; i++)
        {
            zpl__ContractLineItem__c agreementLineItem = new zpl__ContractLineItem__c(
                zpl__Contract__c = agreement.Id,
                zpl__Product__c = products[i].Id,
                zpl__EffectiveDate__c = Date.today().addDays(-1),
                RecordTypeId = activeRecordType,
                SKU__c = 'SKU' + i
            );

            if (i >= numberOfAgreementLineItemsToSort / 10)
            {
                agreementLineItem.Subset__c = 'Test Subset';
            }

            if (i >= 2 * (numberOfAgreementLineItemsToSort / 10))
            {
                agreementLineItem.Set__c = 'Test Set';
            }

            if (i >= 3 * (numberOfAgreementLineItemsToSort / 10))
            {
                agreementLineItem.Brand__c = 'Test Brand';
            }

            if (i >= 4 * (numberOfAgreementLineItemsToSort / 10))
            {
                agreementLineItem.Class__c = 'Test Class';
            }

            if (i >= 5 * (numberOfAgreementLineItemsToSort / 10))
            {
                agreementLineItem.Segment__c = 'Test Segment';
            }

            if (i >= 6 * (numberOfAgreementLineItemsToSort / 10))
            {
                agreementLineItem.CPLSortField__c = '' + i;
            }

            agreementLineItems.add(agreementLineItem);
        }
        
        List<String> levelValue = new List<String>();        
        for (Integer i = 0; i < numberOfAgreementLineItemsToSort; i++)
        {
            levelValue.add('Test LevelValue ' + i);
        }        

        UnitTest.addData(agreementLineItems)
            .tag('Agreement Line Items')            
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('Net_Price__c').assign(200);

        insert UnitTest.get('Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .tag('Customer Price List')
            .property('Agreement__c').assignFrom('Agreement')
            .property('Effective_Date__c').assign(Date.today());

        Customer_Price_List__c cpl = (Customer_Price_List__c) UnitTest.get('Customer Price List').getList()[0];

        Test.startTest();
        List<CPLServices.AgreementLineItemWrapper> sortedAgreementLineItems = CPLServices.getAgreementLineItemsFromCPL(cpl);
        Test.stopTest();

        System.debug(sortedAgreementLineItems);
    }
}
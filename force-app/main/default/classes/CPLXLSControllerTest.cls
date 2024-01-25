@isTest
public class CPLXLSControllerTest 
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
    public static void controller_testExternalWithId()
    {
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')
            .property('VOS_Business_Group__c').assign('SA')
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
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200);
            //.property('Bracket1Value__c').assign(100)
            //.property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200);
            //.property('Bracket1Value__c').assign(100)
            //.property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];

        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('External').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Agreement Line Level');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }
    
    @isTest
    public static void controller_testExternalNoId()
    {
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')
            .property('VOS_Business_Group__c').assign('SA')
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
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200);
            //.property('Bracket1Value__c').assign(100)
            //.property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200);
            //.property('Bracket1Value__c').assign(100)
            //.property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];

        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('External').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Agreement Line Level');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }
    @isTest
    public static void controller_testExternalNoIdNoSA()
    {
        Integer numberOfEachClassification = 5;
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')
            .property('Natl_Acct_Group_ID__c').assign('NACID')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
            .property('Name').assign('00000003')
            .property('productCode').assign('00000003')
            .property('Class__c').assign('CS')
            .property('Brand__c').assign('BD')
            .property('System_ID__c').assign('03')
            .tag('Products');

        insert UnitTest.get('Products').getList();
        
        UnitTest.addData(SObjectFactory.build(1, NationalAccountsPricing__c.SObjectType))
            .property('NationalAccountGroupID__c').assign('NACID')
            .property('Class__c').assign('A')
            .property('Name').assign('00000003')
            .property('CompositeKey__c').assign('SWtestNA')
            .tag('National');
        
        insert UnitTest.get('National').getList();

 
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
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .property('zpl__EffectiveDate__c').assign(Date.today())
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id) 
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];
       
        UnitTest.addData(SObjectFactory.build(numberOfEachClassification, Servicing_Division__c.SObjectType))
            .tag('Divisions');

        insert UnitTest.get('Divisions').getList();   


        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('External').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        //ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Regional Chain AND National Agreement Lines (if any)');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Agreement Line Level');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }

    @isTest
    public static void controller_testExternalNoIdNoSANoBracket()
    {
        Integer numberOfEachClassification = 5;
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
        .tag('Chain Account');
        
        insert UnitTest.get('Chain Account').getList();
        
        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('Chain_Account__c').assignFrom('Chain Account')
            .property('OwnerId').assignFrom('User')
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
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .property('Brand__c').assign('BD')
            .property('Brand_Desc__c').assign('BD')
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id) 
            .property('Brand__c').assign('BD')
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];
       
        UnitTest.addData(SObjectFactory.build(numberOfEachClassification, Servicing_Division__c.SObjectType))
            .tag('Divisions');

        insert UnitTest.get('Divisions').getList();   


        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('External').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Agreement Line Level');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }

    @isTest
    public static void controller_testNewExternalScenario()
    {
        Integer numberOfEachClassification = 5;
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();
        
        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
        .property('RecordTypeId').assign(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Account').getRecordTypeId())
        .tag('Chain Account');
        
        insert UnitTest.get('Chain Account').getList();
        
        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')
            .property('Natl_Acct_Group_ID__c').assign('NACID')
            .property('Legacy_System_Cd__c').assign('SW')
            .property('Chain_Account__c').assignFrom('Chain Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(numberOfEachClassification, Servicing_Division__c.SObjectType))
            .tag('Divisions');

        insert UnitTest.get('Divisions').getList();  
        
        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('Division__c').assignFrom('Divisions')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();
 
        UnitTest.addData(SObjectFactory.build(1, zpl__ProductSelectorConfiguration__c.SObjectType))
            .tag('Product Selector Configuration to Contract')
            .property('zpl__TargetObject__c').assign('Contract')
            .property('name').assign('Add Contract Products')
            .property('zpl__UniqueNickname__c').assign('DefaultContract');
        insert UnitTest.get('Product Selector Configuration to Contract').getList();
        zpl__ProductSelectorConfiguration__c testPSconfig = (zpl__ProductSelectorConfiguration__c) UnitTest.get('Product Selector Configuration to Contract').getList()[0];
        UnitTest.addData(SObjectFactory.build(1, zpl__LineLevel__c.SObjectType))
            .tag('Set Level')
            .property('Name').assign('Subset')
            .property('zpl__Position__c').assign(2)
            .property('zpl__ProductSelectorConfiguration__c').assign(testPSconfig.Id);
        insert UnitTest.get('Set Level').getList();
        zpl__LineLevel__c level = (zpl__LineLevel__c) UnitTest.get('Set Level').getList()[0];
        List<String> levelValue = new List<String>();
        for (Integer i = 0; i < numberOfAgreementLineItems; i++)
        {
            levelValue.add('Test LevelValue ' + i);
        } 
        
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        .property('productCode').assign('00000003')
        .property('Brand__c').assign('BD')
        .property('Subset__c').assign('0001')
        .property('Set__c').assign('0001')
        .property('System_ID__c').assign('03')
        .tag('Products');

        insert UnitTest.get('Products').getList();
        
        UnitTest.addData(SObjectFactory.build(50, NationalAccountsPricing__c.SObjectType))
            .property('NationalAccountGroupID__c').assign('NACID')
            .property('Class__c').assign('A')
            .property('Name').assign('00000003')
            .property('CompositeKey__c').assign('SW')
            .tag('National');
        
        insert UnitTest.get('National').getList();
        /*
        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .property('Customer_Email__c').assign('me@gmail.com')
            .property('Agreement__c').assignFrom('Agreement')
            .tag('cpl');

        insert UnitTest.get('cpl').getList();
        
        Customer_Price_List__c cpl = (Customer_Price_List__c) UnitTest.get('cpl').getList()[0];
        */
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .property('Brand__c').assign('BD')
            .property('Subset__c').assign('0001')
            .property('Class__c').assign('A')
            .property('Class_Desc__c').assign('Desc')
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assignFrom('Set Level') 
            .property('Brand__c').assign('BD')
            .property('Subset__c').assign('0001')
            .property('Class__c').assign('A')
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];    
         
        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        //ApexPages.currentPage().getParameters().put('id', cpl.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('External').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show National Agreement Lines (if any)');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');        
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Agreement Line Level');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }
    
    @isTest
    public static void controller_testInternalNoId()
    {
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')
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
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];

        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show National Agreement Lines (if any)');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Agreement Line Level');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }
    
    @isTest
    public static void controller_testInternalNoIdNoBracket()
    {
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')
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
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];

        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Agreement Line Level');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }

    @isTest
    public static void controller_testExternalNoIdSetSubset()
    {
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')
            .property('VOS_Business_Group__c').assign('SA')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        //UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        //    .tag('Products');
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        .property('productCode').assign('00000003')
        .property('Brand__c').assign('BD')
        .property('Subset__c').assign('0001')
        .property('Set__c').assign('0001')
        .property('System_ID__c').assign('03')
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
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .property('Brand__c').assign('BD')
            .property('Subset__c').assign('0001')
            .property('Set__c').assign('0001')
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];

        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('External').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Item Level (Expand Sets and Subsets)');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }

    @isTest
    public static void getCountsAndHeaders_test()
    {
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')
            .property('VOS_Business_Group__c').assign('SA')
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
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];

        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('External').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Item Level (Expand Sets and Subsets)');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }
    
    @isTest
    public static void controller_testInternalNoIdNoBracketNational()
    {
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')
            .property('Natl_Acct_Group_ID__c').assign('NACID')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
            .property('Name').assign('00000003')
            .property('productCode').assign('00000003')
            .property('Class__c').assign('CS')
            .property('Brand__c').assign('BD')
            .property('System_id__c').assign('03')
            .tag('Products');


        insert UnitTest.get('Products').getList();
        
        UnitTest.addData(SObjectFactory.build(50, NationalAccountsPricing__c.SObjectType))
            .property('NationalAccountGroupID__c').assign('NACID')
            .property('Class__c').assign('A')
            .property('Name').assign('00000003')
            .property('CompositeKey__c').assign('SW')
            .tag('National');
               
        
        insert UnitTest.get('National').getList();


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
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            .property('Bracket1MinQty__c').assign(100)
            .property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];

        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        //ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Regional Chain AND National Agreement Lines (if any)');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Agreement Line Level');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }
    
    @isTest
    public static void rodneyExternalTest()
    {
        Integer numberOfEachClassification = 5;
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')            
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        //UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        //    .tag('Products');
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        .property('productCode').assign('00000003')
        .property('description').assign('00000003 test')
        .property('Brand__c').assign('BD')
        .property('Subset__c').assign('0001')
        .property('Class__c').assign('A')
        .property('Set__c').assign('0001')
        .property('System_ID__c').assign('03')
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
        
        
        UnitTest.addData(SObjectFactory.build(1, zpl__PolicyType__c.SObjectType))
            .tag('Fixed Price Policy')
            .property('Name').assign('Fixed Price')
            .property('zpl__Description__c').assign('Fixed Price');
        insert UnitTest.get('Fixed Price Policy').getList();
        
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__PolicyType__c').assignFrom('Fixed Price Policy')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .property('Brand__c').assign('BD')
            .property('Subset__c').assign('0001')
            .property('Set__c').assign('0001')
            .property('Class__c').assign('A')
            .property('Class_Desc__c').assign('Desc')
            .property('Description__c').assign('00000003 test')
            .property('zpl__PolicyValue__c').assign(10)
            .property('PricingCost__c').assign(5)
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];

        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('External').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Item Level (Expand Sets and Subsets)');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }
    
    /*@isTest
    public static void rodneyInternalTest()
    {
        Integer numberOfEachClassification = 5;
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')            
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        //UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        //    .tag('Products');
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        .property('productCode').assign('00000003')
        .property('description').assign('00000003 test')
        .property('Brand__c').assign('BD')
        .property('Subset__c').assign('0001')
        .property('Class__c').assign('A')
        .property('Set__c').assign('0001')
        .property('System_ID__c').assign('03')
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
        
        
        UnitTest.addData(SObjectFactory.build(1, zpl__PolicyType__c.SObjectType))
            .tag('Fixed Price Policy')
            .property('Name').assign('Fixed Price')
            .property('zpl__Description__c').assign('Fixed Price');
        insert UnitTest.get('Fixed Price Policy').getList();
        
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__PolicyType__c').assignFrom('Fixed Price Policy')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .property('Brand__c').assign('BD')
            .property('Subset__c').assign('0001')
            .property('Set__c').assign('0001')
            .property('Class__c').assign('A')
            .property('Class_Desc__c').assign('Desc')
            .property('Description__c').assign('00000003 test')
            .property('zpl__PolicyValue__c').assign(10)
            .property('PricingCost__c').assign(5)
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];

        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Item Level (Expand Sets and Subsets)');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }*/
    
    @isTest
    public static void rodneySaalfieldTest()
    {
        Integer numberOfEachClassification = 5;
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')        
            .property('VOS_Business_Group__c').assign('SA')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        //UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        //    .tag('Products');
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        .property('productCode').assign('00000003')
        .property('Brand__c').assign('BD')
        .property('Subset__c').assign('0001')
        .property('Class__c').assign('A')
        .property('Set__c').assign('0001')
        .property('System_ID__c').assign('03')
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
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .property('Brand__c').assign('BD')
            .property('Subset__c').assign('0001')
            .property('Set__c').assign('0001')
            .property('Class__c').assign('A')
            .property('Class_Desc__c').assign('Desc')
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];

        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('External').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Item Level (Expand Sets and Subsets)');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }
    
    @isTest
    public static void rodneyExternalSubsetTest()
    {
        Integer numberOfEachClassification = 5;
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();

        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')            
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();

        //UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        //    .tag('Products');
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        .property('productCode').assign('00000003')
        .property('Brand__c').assign('BD')
        .property('Subset__c').assign('0001')
        .property('Class__c').assign('A')
        .property('Set__c').assign('0001')
        .property('System_ID__c').assign('03')
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
            .property('Name').assign('Subset')
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
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .property('Brand__c').assign('BD')
            .property('Subset__c').assign('0001')
            .property('Set__c').assign('0001')
            .property('Class__c').assign('A')
            .property('Class_Desc__c').assign('Desc')
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            //.property('Bracket1MinQty__c').assign(100)
            //.property('Bracket2MinQty__c').assign(200)
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];

        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('External').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show Current and Chain Account Pricing');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Item Level (Expand Sets and Subsets)');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }
    
    @isTest
    public static void controller_testNewInternalScenario()
    {
        Integer numberOfEachClassification = 5;
        Integer numberOfAgreementLineItems = 50;

        UnitTest.addData(SObjectFactory.build(1, User.SObjectType))
            .tag('User');

        insert UnitTest.get('User').getList();
        
        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
        .property('RecordTypeId').assign(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Account').getRecordTypeId())
        .tag('Chain Account');
        
        insert UnitTest.get('Chain Account').getList();
        
        UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
            .tag('Account')
            .property('OwnerId').assignFrom('User')
            .property('Natl_Acct_Group_ID__c').assign('NACID')
            .property('Legacy_System_Cd__c').assign('SW')
            .property('Chain_Account__c').assignFrom('Chain Account')
            .property('Zilliant_Active__c').assign('AI');

        insert UnitTest.get('Account').getList();

        UnitTest.addData(SObjectFactory.build(numberOfEachClassification, Servicing_Division__c.SObjectType))
            .tag('Divisions');

        insert UnitTest.get('Divisions').getList();  
        
        UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
            .tag('Agreement')
            .property('Division__c').assignFrom('Divisions')
            .property('AccountId').assignFrom('Account');

        insert UnitTest.get('Agreement').getList();
 
        UnitTest.addData(SObjectFactory.build(1, zpl__ProductSelectorConfiguration__c.SObjectType))
            .tag('Product Selector Configuration to Contract')
            .property('zpl__TargetObject__c').assign('Contract')
            .property('name').assign('Add Contract Products')
            .property('zpl__UniqueNickname__c').assign('DefaultContract');
        insert UnitTest.get('Product Selector Configuration to Contract').getList();
        zpl__ProductSelectorConfiguration__c testPSconfig = (zpl__ProductSelectorConfiguration__c) UnitTest.get('Product Selector Configuration to Contract').getList()[0];
        UnitTest.addData(SObjectFactory.build(1, zpl__LineLevel__c.SObjectType))
            .tag('Set Level')
            .property('Name').assign('Subset')
            .property('zpl__Position__c').assign(2)
            .property('zpl__ProductSelectorConfiguration__c').assign(testPSconfig.Id);
        insert UnitTest.get('Set Level').getList();
        zpl__LineLevel__c level = (zpl__LineLevel__c) UnitTest.get('Set Level').getList()[0];
        List<String> levelValue = new List<String>();
        for (Integer i = 0; i < numberOfAgreementLineItems; i++)
        {
            levelValue.add('Test LevelValue ' + i);
        } 
        
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, Product2.SObjectType))
        .property('productCode').assign('00000003')
        .property('Brand__c').assign('BD')
        .property('Subset__c').assign('0001')
        .property('Set__c').assign('0001')
        .property('System_ID__c').assign('03')
        .tag('Products');

        insert UnitTest.get('Products').getList();
        
        UnitTest.addData(SObjectFactory.build(50, NationalAccountsPricing__c.SObjectType))
            .property('NationalAccountGroupID__c').assign('NACID')
            .property('Class__c').assign('A')
            .property('Name').assign('00000003')
            .property('CompositeKey__c').assign('SW')
            .tag('National');
        
        insert UnitTest.get('National').getList();
        /*
        UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
            .property('Customer_Email__c').assign('me@gmail.com')
            .property('Agreement__c').assignFrom('Agreement')
            .tag('cpl');

        insert UnitTest.get('cpl').getList();
        
        Customer_Price_List__c cpl = (Customer_Price_List__c) UnitTest.get('cpl').getList()[0];
        */
        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Current Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assign(level.id)
            .property('Brand__c').assign('BD')
            .property('Subset__c').assign('0001')
            .property('Class__c').assign('A')
            .property('Class_Desc__c').assign('Desc')
            .property('isCurrent__c').assign(True)
            .branch('C QTYPriceBreak|C Normal');

        UnitTest.get('C QTYPriceBreak')
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Current Agreement Line Items').getList();

        UnitTest.addData(SObjectFactory.build(numberOfAgreementLineItems, zpl__ContractLineItem__c.SObjectType))
            .tag('Future Agreement Line Items')
            .property('zpl__Contract__c').assignFrom('Agreement')
            .property('zpl__Product__c').assignFrom('Products')
            .property('zpl__EffectiveDate__c').assign(Date.today().addDays(3))
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('zpl__LineLevel__c').assignFrom('Set Level') 
            .property('Brand__c').assign('BD')
            .property('Subset__c').assign('0001')
            .property('Class__c').assign('A')
            .property('isCurrent__c').assign(True)
            .branch('F QTYPriceBreak|F Normal');

        UnitTest.get('F QTYPriceBreak')
            .property('Net_Price__c').assign(200)
            //.property('Bracket1Value__c').assign(100)
            .property('Bracket2Value__c').assign(200);
            
        insert UnitTest.get('Future Agreement Line Items').getList();

        Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
        User salesRep = (User) UnitTest.get('User').getList()[0];    
         
        PageReference cplPage = Page.cplXLS;
        Test.setCurrentPage(cplPage);

        ApexPages.currentPage().getParameters().put('Agreement__c', agreement.Id);
        //ApexPages.currentPage().getParameters().put('id', cpl.Id);
        ApexPages.currentPage().getParameters().put('RecordTypeId', Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId());
        ApexPages.currentPage().getParameters().put('Sales_Rep__c', salesRep.Id);
        ApexPages.currentPage().getParameters().put('Effective_Date__c', String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('Regional_National_Filter__c', 'Show National Agreement Lines (if any)');
        ApexPages.currentPage().getParameters().put('Purchased_Stocked_Filter__c', 'Show All Agreement Lines');        
        ApexPages.currentPage().getParameters().put('TXN_History__c', 'All');
        ApexPages.currentPage().getParameters().put('Level_Filter__c', 'Agreement Line Level');
        ApexPages.currentPage().getParameters().put('New_Or_Changed_Only__c', 'false');

        Test.startTest();
        CPLXLSController CPLXLSController = new CPLXLSController();
        Test.stopTest();
    }
}
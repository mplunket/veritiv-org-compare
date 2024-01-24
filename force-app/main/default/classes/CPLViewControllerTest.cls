@isTest
public class CPLViewControllerTest 
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
	public static void CPLView_Fields_test() 
	{
		Test.startTest();
		List<FieldSetMember> fields = CPLViewController.CPLView_Fields;
		Test.stopTest();

		System.assert(fields != null, 'We expect the field set to not be null.');
		System.assert(fields.size() > 0, 'We expect the field set to be populated.');
	}

	@isTest
	public static void getDefaultCPL_test()
	{
		Id recordTypeId = Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get('External').getRecordTypeId();

		Test.startTest();
		Customer_Price_List__c cpl = CPLViewController.getDefaultCPL(recordTypeId);
		Test.stopTest();

		System.assertEquals(cpl.Id, null, 'We expect there to be no Id on the CPL.');
		System.assert(cpl.Regional_National_Filter__c != null, 'We expect the default fields to be populated.');
	}

	@isTest
	public static void getCPLById_test()
	{
		UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
			.tag('Account')
            .property('Zilliant_Active__c').assign('AI');

		insert UnitTest.get('Account').getList();

		UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
			.tag('Agreement')
			.property('AccountId').assignFrom('Account');

		insert UnitTest.get('Agreement').getList();

		UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
			.tag('Customer Price List')
			.property('Agreement__c').assignFrom('Agreement')
			.property('Regional_National_Filter__c').assign('Show Current and Chain Account Pricing')
            .property('Customer_Email__c').assign('test@test.com');

		insert UnitTest.get('Customer Price List').getList();

		Customer_Price_List__c cpl = (Customer_Price_List__c) UnitTest.get('Customer Price List').getList()[0];

		Test.startTest();
		Customer_Price_List__c actual = CPLViewController.getCPLById(cpl.Id);
		Test.stopTest();

		System.assert(actual != null, 'We expect a valid CPL to be returned.');
		System.assertEquals(cpl.Regional_National_Filter__c, actual.Regional_National_Filter__c, 'We expect the original and the queried record to be the same');
	}

	@isTest
	public static void getRecordTypeById_testSuccess()
	{
		String expectedRecordTypeName = 'External';
		String recordTypeId = Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosByName().get(expectedRecordTypeName).getRecordTypeId();
		
		Test.startTest();
		String actualRecordTypeName = CPLViewController.getRecordTypeById(recordTypeId);
		Test.stopTest();

		System.assertEquals(expectedRecordTypeName, actualRecordTypeName, 'We expect the returned record type name to match the input id.');
	}

	@isTest
	public static void getRecordTypeById_testNull()
	{	
		Test.startTest();
		try 
		{
			String actualRecordTypeName = CPLViewController.getRecordTypeById(null);
		}
		catch (AuraHandledException e)
		{
			System.assertEquals('Attempt to de-reference a null object', e.getMessage(), 'We expect an error to be thrown of the correct type and message.');
		}
		Test.stopTest();
	}

	@isTest
	public static void getSalesRepOptions_testMultiple()
	{
		Integer numberOfShipTos = 5;
		Integer numberOfUsers = numberOfShipTos + 1;

		List<User> users = new List<User>();
		for (Integer i = 0; i < numberOfUsers; i++)
		{
			User user = new User(
				IsActive = true,
				LastName = 'Doe',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				EmailEncodingKey = 'ISO-8859-1',
				Email = 'testxxx000' +'@test.com',
				TimeZoneSidKey = 'America/New_York',
				ProfileId = (Id) SObjectParentProviders.standardProfileProvider.getValue(),
				Country = 'USA',
				Alias = 'ALIAS' + i, //new SObjectFieldProviders.UniqueFixedLengthStringProvider('abc', 7),
				Network_Id__c = 'ALIAS' + i, //User.Alias,
				CommunityNickname = (String) new SObjectFieldProviders.UniqueStringProvider('johndoe').getValue(),
				Username = (String) new SObjectFieldProviders.UniqueStringProvider('test_xyz=test@example.com').getValue()
			);

			users.add(user);
		}

		UnitTest.addData(users)
			.tag('Users');

		insert UnitTest.get('Users').getList();

		UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
			.tag('Account')
			.property('OwnerId').assignFrom('Users')
            .property('Zilliant_Active__c').assign('AI');

		insert UnitTest.get('Account').getList();

		UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
			.tag('Agreement')
			.property('AccountId').assignFrom('Account');

		insert UnitTest.get('Agreement').getList();

		UnitTest.addData(SObjectFactory.build(numberOfShipTos, Ship_To__c.SObjectType))
			.tag('Ship Tos')
			.property('Bill_To_Account__c').assignFrom('Account')
			.property('Account_Owner__c').assignFrom('Users');

		insert UnitTest.get('Ship Tos').getList();

		Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];

		Test.startTest();
		List<User> salesRepOptions = CPLViewController.getSalesRepOptions(agreement.Id);
		Test.stopTest();

		System.assertEquals(1 + numberOfShipTos, salesRepOptions.size(), 'We expect the correct number of sales rep options to be returned.');
	}

	@isTest
	public static void getSalesRepOptions_testSingle()
	{
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

		Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];

		Test.startTest();
		List<User> salesRepOptions = CPLViewController.getSalesRepOptions(agreement.Id);
		Test.stopTest();

		System.assertEquals(1, salesRepOptions.size(), 'We expect the correct number of sales rep options to be returned.');
	}

	@isTest
	public static void getCustomerPriceListName_test()
	{
		String testAccountName = 'Test Account';

		UnitTest.addData(SObjectFactory.build(1, Account.SObjectType))
			.tag('Account')
			.property('Name').assign(testAccountName)
            .property('Zilliant_Active__c').assign('AI');

		insert UnitTest.get('Account').getList();

		UnitTest.addData(SObjectFactory.build(1, Contract.SObjectType))
			.tag('Agreement')
			.property('AccountId').assignFrom('Account');

		insert UnitTest.get('Agreement').getList();

		Contract agreement = (Contract) UnitTest.get('Agreement').getList()[0];
		String expectedCPLName = 'CPL: ' + testAccountName;

		Test.startTest();
		String actualCPLName = CPLViewController.getCustomerPriceListName(agreement.Id);
		Test.stopTest();

		System.assertEquals(expectedCPLName, actualCPLName, 'We expect the generated CPL name to include the correct account name');
	}

	@isTest
	public static void getDependentPicklistValues_testNoFilters()
	{
		Integer numberOfEachClassification = 5;
		Integer numberOfAgreementLineItems = 5;

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
			.property('Effective_Date__c').assign(Date.today());

		Customer_Price_List__c cpl = (Customer_Price_List__c) UnitTest.get('Customer Price List').getList()[0];
		
		Test.startTest();
		Map<String, List<CPLViewController.DependentPicklistOption>> actualOptions = CPLViewController.getDependentPicklistValues(cpl);
		Test.stopTest();

		System.assertEquals(numberOfAgreementLineItems, actualOptions.get('Division__c').size(), 'We expect the correct number of options to be returned for divisions.');
		System.assertEquals(numberOfAgreementLineItems, actualOptions.get('Segments__c').size(), 'We expect the correct number of options to be returned for segments.');
		System.assertEquals(numberOfAgreementLineItems, actualOptions.get('Classes__c').size(), 'We expect the correct number of options to be returned for classes.');
		System.assertEquals(numberOfAgreementLineItems, actualOptions.get('Brands__c').size(), 'We expect the correct number of options to be returned for brands.');
	}

	@isTest
	public static void getDependentPicklistValues_testSingleFilter()
	{
		Integer numberOfEachClassification = 5;
		Integer numberOfAgreementLineItems = 5;

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
			.property('Division__c').assignFrom('Divisions')
			.property('Segment__c').assignFrom(segments)
			.property('Class__c').assignFrom(classes)
			.property('Brand__c').assignFrom(brands)
            .property('zpl__Status__c').assign('Published')
            .property('zpl__LevelValue__c').assignFrom(levelValue)
            .property('Net_Price__c').assign(200)
            .property('zpl__LineLevel__c').assign(level.id);

		insert UnitTest.get('Agreement Line Items').getList();

		UnitTest.addData(SObjectFactory.build(1, Customer_Price_List__c.SObjectType))
			.tag('Customer Price List')
			.property('Agreement__c').assignFrom('Agreement')
			.property('Effective_Date__c').assign(Date.today())
			.property('Brands__c').assign(String.join(brands, ';'));

		Customer_Price_List__c cpl = (Customer_Price_List__c) UnitTest.get('Customer Price List').getList()[0];
		
		Test.startTest();
		Map<String, List<CPLViewController.DependentPicklistOption>> actualOptions = CPLViewController.getDependentPicklistValues(cpl);
		Test.stopTest();

		System.assertEquals(numberOfAgreementLineItems, actualOptions.get('Division__c').size(), 'We expect the correct number of options to be returned for divisions.');
		System.assertEquals(numberOfAgreementLineItems, actualOptions.get('Segments__c').size(), 'We expect the correct number of options to be returned for segments.');
		System.assertEquals(numberOfAgreementLineItems, actualOptions.get('Classes__c').size(), 'We expect the correct number of options to be returned for classes.');
		System.assertEquals(numberOfAgreementLineItems, actualOptions.get('Brands__c').size(), 'We expect the correct number of options to be returned for brands.');
	}
}
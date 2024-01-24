/*

RequiredFieldsCache
    This class defines fields which are required, or very common, between
    different records of the same type. When the SObjectFactory is creating
    a new record, it will first get the fields and values from this class.

    This class, unlike other classes in the SObjectBuilder package, is ment
    to be modified. Whenever a developer tries to create a new record and
    encounters an required field exception, or a failed validation rule, an
    entry should be added to the objectTypeToFields map to prevent that
    error from happening.

    Best practices for adding fields to this map is to add fields only when
    they will be required for all records of that type, or most records of
    that type. Tests which depend on certain values being set on a record
    should always explicitly set them when creating the test data.

    If your org has different types of the same sobject, you can make use
    of the typeSpecificFields map to differentiate between different types
    of the same sobject type. For example, you can have a 'big business'
    account type, and a 'small buisness' type of account, with different
    required fields. When a type is being used, the objectTypeToFields map
    is used first, then the typeSpecificFields map is applied second.
    Passed FieldToValue maps are applied after that.


    Methods:
        get(Schema.SObjectType sObjectType, String type)
            returns Map<Schema.SObjectField, Object>

            Gets the default fields to be set for a given sobject type and
            sub type. This method generally should not be used.

            Throws: RequiredFieldsCacheException when an invalid type is
                passed.


    Members:
        objectTypeToFields
            Map<Schema.SObjectType, Map<Schema.SObjectField, Object>>

            Contains the default values for each field on a given
            SObject type. These values can be primitives, or field
            providers. SObjectTypes do not need to be defind here
            in order to create them with SObjectFactory; any type
            not in this map has no default fields.


        typeSpecificFields
            Map<Schema.SObjectType, Map<String, Map<Schema.SObjectField, Object>>>

            Similar to the objectTypeToFields map, this map contains
            default values for specific types of objects. For example,
            you can define a 'small buisness' and 'big businses'
            account types, and have a different set of default fields
            for each account.

            To use this map, simply add the type parameter to the factory
            call, or use the .type method when calling the builder.

            Any type passed in a factory or builder call must exist in
            the map for that object type, otherwise ane exception will
            be thrown.


*/

@IsTest
public class RequiredFieldsCache {
    public class RequiredFieldsCacheException extends Exception { }
    static final String TYPE_ERROR_MSG = 'The type "{0}" for {1} does not exist in RequiredFieldsCache. Please add it before using it in a test.';
    static final String TEST_ALIAS = 'ALIAS';

    public static Map<Schema.SObjectField, Object> get(Schema.SObjectType sObjectType, String type) {
        Map<Schema.SObjectField, Object> fieldToValue = objectTypeToFields.containsKey(sObjectType) ?
            objectTypeToFields.get(sObjectType).clone() : new Map<Schema.SObjectField, Object>();

        if (String.isNotBlank(type)) {
            if (typeSecificFields.containsKey(sObjectType) && typeSecificFields.get(sObjectType).containsKey(type)) {
                fieldToValue.putAll(typeSecificFields.get(sObjectType).get(type));
            } else {
                String msg = String.format(TYPE_ERROR_MSG, new List<String>{ type, sObjectType.getDescribe().getName() });
                throw new RequiredFieldsCacheException(msg);
            }
        }

        return fieldToValue;
    }

    static final Map<Schema.SObjectType, Map<Schema.SObjectField, Object>> objectTypeToFields =
        new Map<Schema.SObjectType, Map<Schema.SObjectField, Object>>
    {
        Lead.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Lead.State => 'CO',
            Lead.LastName => 'Coyote',
            Lead.Company => 'ACME, Inc.',
            Lead.Country => 'US'
        },
        Group.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Group.Name => 'Some group'
        },
        Account.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Account.Name => 'Some account',
            Account.Primary_Sales_Rep_Name__c => new SObjectParentProviders.UniqueParentProvider(Primary_Sales_Rep__c.SObjectType),
            Account.BillingCountry => 'US',
            Account.Account_Vertical__c => 'Test',
            Account.Prospect_Segment__c => 'Test',
            Account.Active__c => 'Yes'
        },
        Contact.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Contact.LastName => 'Some contact last name'
        },
        Contract.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Contract.Division__c => new SObjectParentProviders.UniqueParentProvider(Servicing_Division__c.SObjectType)
        },
        Opportunity.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Opportunity.StageName => 'Stage',
            Opportunity.Name => 'Some opportunity',
            Opportunity.CloseDate => Date.today().addMonths(1)
        },
        OpportunityTeamMember.sObjectType => new Map<Schema.SObjectField, Object>
        {
            OpportunityTeamMember.UserId => new SObjectParentProviders.UniqueParentProvider(User.SObjectType),
            OpportunityTeamMember.OpportunityAccessLevel => 'Read',
            OpportunityTeamMember.OpportunityId => new SObjectParentProviders.UniqueParentProvider(Opportunity.SObjectType)
        },
        Campaign.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Campaign.Name => new SObjectFieldProviders.UniqueStringProvider('Test Campaign ')
        },
        User.sObjectType => new Map<Schema.SObjectField, Object>
        {
            User.IsActive => true,
            User.LastName => 'Doe',
            User.LocaleSidKey => 'en_US',
            User.LanguageLocaleKey => 'en_US',
            User.EmailEncodingKey => 'ISO-8859-1',
            User.Email => 'testxxx000' +'@test.com',
            User.TimeZoneSidKey => 'America/New_York',
            User.ProfileId => SObjectParentProviders.standardProfileProvider,
            User.Country => 'USA',
            User.Alias => TEST_ALIAS, //new SObjectFieldProviders.UniqueFixedLengthStringProvider('abc', 7),
            User.Network_Id__c => TEST_ALIAS, //User.Alias,
            User.CommunityNickname => new SObjectFieldProviders.UniqueStringProvider('johndoe'),
            User.Username => new SObjectFieldProviders.UniqueStringProvider('test_xyz=test@example.com')
        },
        Quote__c.sObjectType => new Map<Schema.SObjectField, Object>
        {
        },
        Quote_Line_Item__c.sObjectType => new Map<Schema.SObjectField, Object>
        {
        	Quote_Line_Item__c.Qty__c => 1,
        	Quote_Line_Item__c.Quantity_Unit_Factor__c => 1,
        	Quote_Line_Item__c.Projected_Delivery_Date__c => System.today()
        },
        Primary_Sales_Rep__c.sObjectType => new Map<Schema.SObjectField, Object>
        {
            Primary_Sales_Rep__c.Name => 'Test PSR Name',
            Primary_Sales_Rep__c.Network_ID__c => new SObjectFieldProviders.UniqueStringProvider('Test PSR '),
            Primary_Sales_Rep__c.Email__c => 'test@test.com'
        },
        Product2.sObjectType => new Map<Schema.SObjectField, Object>
        {
        	Product2.Name => new SObjectFieldProviders.UniqueStringProvider('Test Product '),
        	Product2.ProductCode => 'Test Product Code',
        	Product2.Description => 'Test Product Description',
        	Product2.Unisource_Item_Number_U_number__c => 'TPUIN',
        	Product2.Vendor_Product_Code__c => 'TVPC',
        	Product2.Unit_of_Measure__c => 'px',
        	Product2.Pricing_Costing_UOM__c => 'pc',
        	Product2.Conversion_Factor__c => 12.50
        	//Product2.Vendor__c => Lookup to a vendor
        },
        Servicing_Division__c.SObjectType => new Map<Schema.SObjectField, Object>
        {
            Servicing_Division__c.Name => new SObjectFieldProviders.UniqueStringProvider('Test Division ')
        },
        EmailTemplate.sObjectType => new Map<Schema.SObjectField, Object>
        {
            EmailTemplate.DeveloperName => new SObjectFieldProviders.UniqueFixedLengthStringProvider('abc', 7),
            EmailTemplate.Name => new SObjectFieldProviders.UniqueFixedLengthStringProvider('abc', 7),
            EmailTemplate.FolderId => UserInfo.getUserId(),
            EmailTemplate.TemplateType => 'Text'
        },
        WorkOrder.sObjectType => new Map<Schema.SObjectField, Object>
        {
            WorkOrder.AccountId => new SObjectParentProviders.UniqueParentProvider(Account.SObjectType),
            WorkOrder.Segment__c => Schema.SObjectType.WorkOrder.Fields.Segment__c.getPicklistValues()[0].getValue(),
            WorkOrder.Prod_Categories__c => Schema.SObjectType.WorkOrder.Fields.Prod_Categories__c.getPicklistValues()[0].getValue(),
            WorkOrder.Region__c => Schema.SObjectType.WorkOrder.Fields.Region__c.getPicklistValues()[0].getValue(),
            WorkOrder.Territory__c => Schema.SObjectType.WorkOrder.Fields.Territory__c.getPicklistValues()[0].getValue(),
            WorkOrder.Request__c => 'Test Request'
        },
        zpl__ContractLineItem__c.sObjectType => new Map<Schema.SObjectField, Object>
        {
            zpl__ContractLineItem__c.zpl__EffectiveDate__c => Date.today().addDays(-1),
            zpl__ContractLineItem__c.zpl__Product__c => new SObjectFieldProviders.DummyIdProvider(),
            zpl__ContractLineItem__c.RecordTypeId => Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByName()
                												.get('Active')
                												.getRecordTypeId(),
            zpl__ContractLineItem__c.SKU__c => new SObjectFieldProviders.UniqueFixedLengthStringProvider(32)
        }
    };

    static final Map<Schema.SObjectType, Map<String, Map<Schema.SObjectField, Object>>> typeSecificFields =
        new Map<Schema.SObjectType, Map<String, Map<Schema.SObjectField, Object>>>
    {
        Account.sObjectType => new Map<String, Map<Schema.SObjectField, Object>>
        {
            'Enterprise_Business' => new Map<Schema.SObjectField, Object>
            {
                Account.Name => 'Some Enterprise Account'
            },
            'Small_Business' => new Map<Schema.SObjectField, Object>
            {
                Account.Name => 'Some Small Business Account',
                Account.NumberOfEmployees => 10
            },
            'Government_Entity' => new Map<Schema.SObjectField, Object>
            {
                Account.Name => 'Some Washington Government Account',
                Account.BillingState => 'WA'
            },
            'Unique Owner' => new Map<Schema.SObjectField, Object>
	        {
	            Account.Name => 'Some account',
	            Account.OwnerId => new SObjectParentProviders.UniqueParentProvider(User.SObjectType, 'Chatter User')
	        },
            'Prospect' => new Map<Schema.SObjectField, Object>
            {
                Account.Name => 'Some Prospect Account',
                Account.AccountNumber => '00123',
    			Account.Legacy_System_Cd__c => '03',
                Account.RecordTypeId => Schema.SObjectType.Account.getRecordTypeInfosByName()
                												.get('Prospect')
                												.getRecordTypeId(),
                Account.AccountNumber => new SObjectFieldProviders.UniqueStringProvider('123456'), 
                Account.Ship_To_Code__c => new SObjectFieldProviders.UniqueStringProvider('000001')
            }
        },
        Opportunity.sObjectType => new Map<String, Map<Schema.SObjectField, Object>>
        {
            'Service' => new Map<Schema.SObjectField, Object>
            {
                Opportunity.Type => 'Service Only'
            },
            'Sales' => new Map<Schema.SObjectField, Object>
            {
                Opportunity.LeadSource => 'Web'
            }
        },
        User.sObjectType => new Map<String, Map<Schema.SObjectField, Object>>
        {
            'Chatter User' => new Map<Schema.SObjectField, Object>
	        {
	            User.IsActive => true,
	            User.LastName => 'Doe',
	            User.LocaleSidKey => 'en_US',
	            User.LanguageLocaleKey => 'en_US',
	            User.EmailEncodingKey => 'ISO-8859-1',
	            User.Email => 'testxxx000' +'@test.com',
	            User.TimeZoneSidKey => 'America/New_York',
	            User.ProfileId => SObjectParentProviders.chatterProfileProvider,
	            User.Country => 'USA',
	            User.Alias => TEST_ALIAS, //new SObjectFieldProviders.UniqueFixedLengthStringProvider('abc', 7),
	            User.Network_Id__c => TEST_ALIAS, //User.Alias,
	            User.CommunityNickname => new SObjectFieldProviders.UniqueStringProvider('johndoe'),
	            User.Username => new SObjectFieldProviders.UniqueStringProvider('test_xyz=test@example.com')
	        },
	        'Admin User' => new Map<Schema.SObjectField, Object>
            {
                User.IsActive => true,
                User.LastName => 'Doe',
                User.LocaleSidKey => 'en_US',
                User.LanguageLocaleKey => 'en_US',
                User.EmailEncodingKey => 'ISO-8859-1',
                User.Email => 'testxxx000' +'@test.com',
                User.TimeZoneSidKey => 'America/New_York',
                User.ProfileId => SObjectParentProviders.adminProfileProvider,
                User.Country => 'USA',
                User.Alias => 'AdmUsr1',
                User.Network_Id__c => 'AdmUsr1',
                User.CommunityNickname => new SObjectFieldProviders.UniqueStringProvider('johndoe'),
                User.Username => new SObjectFieldProviders.UniqueStringProvider('test_xyz=test@example.com')
            }
        }
    };
}
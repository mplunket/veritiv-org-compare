public with sharing class AIQ_GenericSelector {
    /** User fields */
    public static final String USER_OBJECT_TYPE_NAME = Schema.SObjectType.User.getName();
    public static final String USER_ID_FIELD_NAME = Schema.SObjectType.User.fields.Id.getName();
    public static final String NAME_FIELD_NAME = Schema.SObjectType.User.fields.Name.getName();
    public static final String IS_ACTIVE_FIELD_NAME = Schema.SObjectType.User.fields.IsActive.getName();
    public static final String PROFILE_NAME_FIELD_NAME = 'Profile.Name';
    /** Ship To fields */
    public static final String SHIP_TO_OBJECT_TYPE_NAME = Schema.SObjectType.Ship_To__c.getName();
    public static final String SHIP_TO_ID_FIELD_NAME = Schema.SObjectType.Ship_To__c.fields.Id.getName();
    public static final String ACCOUNT_OWNER_FIELD_NAME = Schema.SObjectType.Ship_To__c.fields.Account_Owner__c.getName();
    public static final String BILL_TO_ACCOUNT_FIELD_NAME = Schema.SObjectType.Ship_To__c.fields.Bill_To_Account__c.getName();
    /** Contract fields */
    public static final String CONTRACT_OBJECT_TYPE_NAME = Schema.SObjectType.Contract.getName();
    public static final String CONTRACT_ID_FIELD_NAME = Schema.SObjectType.Contract.fields.Id.getName();
    public static final String ACCOUNT_CHAIN_ACCOUNT_FIELD_NAME = 'Account.Chain_Account__c';
    /** Account fields */
    public static final String ACCOUNT_OBJECT_TYPE_NAME = Schema.SObjectType.Account.getName();
    public static final String ACCOUNT_ID_FIELD_NAME = Schema.SObjectType.Account.fields.Id.getName();
    public static final String ACCOUNT_NAME_FIELD_NAME = Schema.SObjectType.Account.fields.Name.getName();
    public static final String HAS_AGREEMENT_ACCOUNT_FIELD_NAME = Schema.SObjectType.Account.fields.Has_Agreement__c.getName();
    public static final String ZILLIANT_ACTIVE_ACCOUNT_FIELD_NAME = Schema.SObjectType.Account.fields.Zilliant_Active__c.getName();
    public static final String ACCOUNT_RECORD_TYPE_NAME = 'RecordType.Name';
    public static final String ACCOUNT_SERVICING_DIVISION_FIELD_NAME = Schema.SObjectType.Account
        .fields.Servicing_Division__c.getName();
    public static final String ACCOUNT_CUSTOMER_ID_FIELD_NAME = Schema.SObjectType.Account
        .fields.zpl__CustomerId__c.getName();
    public static final String ACCOUNT_LEGACY_CODE_FIELD_NAME = Schema.SObjectType.Account
        .fields.Legacy_System_Cd__c.getName();
    public static final String ACCOUNT_LEGACY_DIVISION_FIELD_NAME = Schema.SObjectType.Account
        .fields.Legacy_Division_Cd__c.getName();
    public static final String ACCOUNT_AUTO_NUMBER_FIELD_NAME = Schema.SObjectType.Account
        .fields.AccountNumber.getName();
    public static final String ACCOUNT_REPRESENTATIVE_DIVISION_FIELD_NAME = Schema.SObjectType.Account
        .fields.Representative_Division__c.getName();
    public static final String ACCOUNT_CHAIN_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Chain_Account')
        .getRecordTypeId();
    /** Servicing Division fields */
    public static final String SERVICING_DIVISION_OBJECT_TYPE_NAME = Schema.SObjectType.Servicing_Division__c.getName();
    public static final String SERVICING_DIVISION_ID_FIELD_NAME = Schema.SObjectType.Servicing_Division__c.fields.Id.getName();
    public static final String SERVICING_DIVISION_NAME_FIELD_NAME = Schema.SObjectType.Servicing_Division__c
        .fields.Name.getName();
    public static final String SERVICING_DIVISION_CODE_FIELD_NAME = Schema.SObjectType.Servicing_Division__c
        .fields.Division_Code__c.getName();
    public static final String SERVICING_DIVISION_COMPOSITE_KEY_FIELD_NAME = Schema.SObjectType.Servicing_Division__c
        .fields.Division_Composite_Key__c.getName();
    /** Account.Servicing_Division__c relationship  fields */
    public static final String ACCOUNT_SERVICING_DIVISION_RELATIONSHIP = Schema.SObjectType.Account
        .fields.Servicing_Division__c.getRelationshipName();
    /** Policy Type fields */
    public static final String POLICY_TYPE_OBJECT_TYPE_NAME = Schema.SObjectType.zpl__PolicyType__c.getName();
    public static final String POLICY_TYPE_ID_FIELD_NAME = Schema.SObjectType.zpl__PolicyType__c.fields.Id.getName();
    public static final String POLICY_TYPE_ID_EXTERNAL_FIELD_NAME = Schema.SObjectType.zpl__PolicyType__c.fields.zpl__PolicyTypeId__c.getName();
    public static final String POLICY_TYPE_NAME_FIELD_NAME = Schema.SObjectType.zpl__PolicyType__c.fields.Name.getName();
    /** Product UOM fields */
    public static final String PRODUCT_UOM_OBJECT_TYPE_NAME = Schema.SObjectType.zpl__ProductUOM__c.getName();
    public static final String PRODUCT_UOM_ID_FIELD_NAME = Schema.SObjectType.zpl__ProductUOM__c.fields.Id.getName();
    public static final String PRODUCT_UOM_CONVERSION_FACTOR_FIELD_NAME = Schema.SObjectType.zpl__ProductUOM__c.fields.zpl__ConversionFactor__c.getName();
    public static final String PRODUCT_UOM_NAME_FIELD = Schema.SObjectType.zpl__ProductUOM__c.fields.Name.getName();
    public static final String PRODUCT_UOM_PRODUCT_RELATION_FIELD_NAME = Schema.SObjectType.zpl__ProductUOM__c.fields.zpl__Product__c.getName();
    public static final String PRODUCT_UOM_IS_PRICING_FIELD_NAME = Schema.SObjectType.zpl__ProductUOM__c.fields.IsPricingUOM__c.getName();
    public static final String PRODUCT_UOM_ALLOW_FOR_PRICING_FIELD_NAME = Schema.SObjectType.zpl__ProductUOM__c.fields.Allow_For_Pricing__c.getName();
    public static final String PRODUCT_UOM_IS_STOCK_OUM_FIELD_NAME = Schema.SObjectType.zpl__ProductUOM__c.fields.IsStockUOM__c.getName();
    public static final String PRODUCT_UOM_ALLOW_FOR_QUANTITY_FIELD_NAME = Schema.SObjectType.zpl__ProductUOM__c.fields.Allow_For_Quantity__c.getName();
    /** Line Level fields */
    public static final String LINE_LEVEL_OBJECT_TYPE_NAME = Schema.SObjectType.zpl__LineLevel__c.getName();
    public static final String LINE_LEVEL_ID_FIELD_NAME = Schema.SObjectType.zpl__LineLevel__c.fields.Id.getName();
    public static final String LINE_LEVEL_NAME_FIELD_NAME = Schema.SObjectType.zpl__LineLevel__c.fields.Name.getName();
    /** CWT Item fields */
    public static final String CWT_ITEM_OBJECT_TYPE_NAME = Schema.SObjectType.AIQ_CWTItem__c.getName();
    public static final String CWT_ITEM_ID_FIELD_NAME = Schema.SObjectType.AIQ_CWTItem__c.fields.Id.getName();
    public static final String CWT_ITEM_CBSSI_KEY_FIELD_NAME = Schema.SObjectType.AIQ_CWTItem__c.fields.CBSSKey__c.getName();
    public static final String CWT_ITEM_PRODUCT_FIELD_NAME = Schema.SObjectType.AIQ_CWTItem__c.fields.Product__c.getName();
    /** National Account Pricing fields */
    public static final String NATIONAL_ACCOUNT_PRICING_OBJECT_TYPE_NAME = Schema.SObjectType.NationalAccountsPricing__c.getName();
    public static final String NATIONAL_ACCOUNT_PRICING_ID_FIELD_NAME = Schema.SObjectType.NationalAccountsPricing__c.fields.Id.getName();
    public static final String NATIONAL_ACCOUNT_PRICING_NAME_FIELD_NAME = Schema.SObjectType.NationalAccountsPricing__c
        .fields.Name.getName();
    public static final String NATIONAL_ACCOUNT_PRICING_GROUP_ID_FIELD_NAME = Schema.SObjectType.NationalAccountsPricing__c
        .fields.NationalAccountGroupID__c.getName();
    public static final String NATIONAL_ACCOUNT_PRICING_SYSTEM_CODE_FIELD_NAME = Schema.SObjectType.NationalAccountsPricing__c
        .fields.SystemCode__c.getName();

    public static final String ACCOUNT_SERVICING_DIVISION_NAME = ACCOUNT_SERVICING_DIVISION_RELATIONSHIP + '.' 
            + SERVICING_DIVISION_NAME_FIELD_NAME;
    public static final String ACCOUNT_SERVICING_DIVISION_CODE = ACCOUNT_SERVICING_DIVISION_RELATIONSHIP + '.' 
            + SERVICING_DIVISION_CODE_FIELD_NAME;

    /**
     * User List fields
     */
    public static final List<String> USER_QUERY_FIELDS = new List<String>{
            USER_ID_FIELD_NAME,
            NAME_FIELD_NAME,
            IS_ACTIVE_FIELD_NAME,
            PROFILE_NAME_FIELD_NAME
    };

    /**
     * Ship To List fields
     */
    public static final List<String> SHIP_TO_QUERY_FIELDS = new List<String>{
            SHIP_TO_ID_FIELD_NAME,
            ACCOUNT_OWNER_FIELD_NAME,
            BILL_TO_ACCOUNT_FIELD_NAME
    };

    /**
     * Contract List fields
     */
    public static final List<String> CONTRACT_QUERY_FIELDS = new List<String>{
            CONTRACT_ID_FIELD_NAME,
            ACCOUNT_CHAIN_ACCOUNT_FIELD_NAME
    };

    /**
    * Account List fields
    */
    public static final List<String> ACCOUNT_QUERY_FIELDS = new List<String>{
        ACCOUNT_ID_FIELD_NAME,
        ACCOUNT_SERVICING_DIVISION_FIELD_NAME,
        ACCOUNT_NAME_FIELD_NAME,
        ACCOUNT_SERVICING_DIVISION_NAME,
        ACCOUNT_SERVICING_DIVISION_CODE,
        ACCOUNT_CUSTOMER_ID_FIELD_NAME,
        ACCOUNT_LEGACY_CODE_FIELD_NAME,
        ACCOUNT_LEGACY_DIVISION_FIELD_NAME,
        ACCOUNT_AUTO_NUMBER_FIELD_NAME,
        ACCOUNT_RECORD_TYPE_NAME,
        ACCOUNT_REPRESENTATIVE_DIVISION_FIELD_NAME
    };

    /**
     * Policy Type List fields
     */
    public static final List<String> POLICY_TYPE_QUERY_FIELDS = new List<String>{
            POLICY_TYPE_ID_FIELD_NAME,
            POLICY_TYPE_ID_EXTERNAL_FIELD_NAME,
            POLICY_TYPE_NAME_FIELD_NAME
    };

    /**
     * Line Level List fields
     */
    public static final List<String> LINE_LEVEL_QUERY_FIELDS = new List<String>{
        LINE_LEVEL_ID_FIELD_NAME,
        LINE_LEVEL_NAME_FIELD_NAME
    };

    /**
     * Product UOM List fields
     */
    public static final List<String> PRODUCT_UOM_QUERY_FIELDS = new List<String>{
            PRODUCT_UOM_ID_FIELD_NAME,
            PRODUCT_UOM_CONVERSION_FACTOR_FIELD_NAME
    };

    public List<Ship_To__c> queryShipToByBillToAccount(String recordId) {
        if (String.isBlank(recordId)) {
            return new List<Ship_To__c>();
        }
        zal.FieldCondition queryCondition = new zal.FieldCondition(BILL_TO_ACCOUNT_FIELD_NAME, zal.Operator.EQUALS, recordId);
        return queryShipToByCondition(SHIP_TO_QUERY_FIELDS, queryCondition);
    }

    public List<Ship_To__c> queryShipToByCondition(List<String> fieldsList, zal.Condition condition) {
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                .selectx(fieldsList)
                .fromx(SHIP_TO_OBJECT_TYPE_NAME)
                .wherex(condition);

        List<Ship_To__c> shipTos = Database.query(soqlBuilder.toSoql());
        return shipTos;
    }

    public User queryCurrentUser() {
        List<User> users = queryUsersByIds(new List<String>{ UserInfo.getUserId() });
        if (users.isEmpty()) { return null; }
        return users[0];
    }

    public List<User> queryUsersByIds(List<String> recordId) {
        if (recordId == null || recordId.isEmpty()) {
            return new List<User>();
        }
        return queryUsersByIds(USER_QUERY_FIELDS, recordId);
    }

    public List<User> queryUsersByIds(List<String> fieldsList, List<String> recordId) {
        zal.SetCondition queryCondition = new zal.SetCondition(USER_ID_FIELD_NAME, zal.Operator.INX, recordId);
        return queryUsersByCondition(fieldsList, queryCondition);
    }

    public List<User> queryUsersByCondition(List<String> fieldsList, zal.Condition condition) {
        zal.AndCondition andCondition = new zal.AndCondition();
        andCondition.add(condition);
        andCondition.add(new zal.FieldCondition(IS_ACTIVE_FIELD_NAME, zal.Operator.EQUALS, true));
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                .selectx(fieldsList)
                .fromx(USER_OBJECT_TYPE_NAME)
                .wherex(andCondition)
                .orderByx(new zal.OrderBy(NAME_FIELD_NAME).ascending());

        List<User> users = Database.query(soqlBuilder.toSoql());
        return users;
    }

    public Contract queryContractById(String recordId) {
        if (String.isBlank(recordId)) {
            return new Contract();
        }
        zal.FieldCondition queryCondition = new zal.FieldCondition(CONTRACT_ID_FIELD_NAME, zal.Operator.EQUALS, recordId);
        return queryContractsByCondition(CONTRACT_QUERY_FIELDS, queryCondition)[0];
    }

    public List<Contract> queryContractsByCondition(List<String> fieldsList, zal.Condition condition) {
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                .selectx(fieldsList)
                .fromx(CONTRACT_OBJECT_TYPE_NAME)
                .wherex(condition);

        List<Contract> contracts = Database.query(soqlBuilder.toSoql());
        return contracts;
    }

    public List<Servicing_Division__c> queryServicingDivisionsByCompositeKey(
        List<String> fields,
        String representativeDivision,
        Integer queryLimit
    ) {
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder();
        zal.AndCondition whereCondition = new zal.AndCondition();
            whereCondition.add(new zal.FieldCondition(SERVICING_DIVISION_COMPOSITE_KEY_FIELD_NAME, zal.Operator.EQUALS, representativeDivision));
        soqlBuilder.selectx(fields);
        soqlBuilder.fromx(SERVICING_DIVISION_OBJECT_TYPE_NAME);
        soqlBuilder.wherex(whereCondition);
        if (queryLimit != null) {
            soqlBuilder.limitx(queryLimit);
        }

        List<Servicing_Division__c> servicingDivisions = Database.query(soqlBuilder.toSoql());

        return servicingDivisions;
    }

    public Account queryAccountById(String recordId) {
        return queryAccountById(ACCOUNT_QUERY_FIELDS, recordId);
    }

    public Account queryAccountById(List<String> fields, String recordId) {
        List<Account> accounts = queryAccountsById(fields, new List<Id>{ recordId });
        if (accounts == null || accounts.isEmpty()) {
            return null;
        }
        return accounts[0];
    }

    public List<Account> queryAccountsById(List<String> fields, List<Id> recordIds) {
        zal.SetCondition queryCondition = new zal.SetCondition(ACCOUNT_ID_FIELD_NAME, zal.Operator.INX, recordIds);
        return queryAccountsByCondition(fields, queryCondition);
    }

    public List<Account> queryAccountsByCondition(zal.Condition queryCondition) {
        return queryAccountsByCondition(ACCOUNT_QUERY_FIELDS, queryCondition);
    }

    public List<Account> queryAccountsByCondition(
        List<String> fields,
        zal.Condition queryCondition
    ) {
        return queryAccountsByCondition(fields, queryCondition, null, null, null);
    }

    public List<Account> queryAccountsByCondition(
        List<String> fields,
        zal.Condition queryCondition,
        Integer queryLimit,
        Integer queryOffset,
        String orderByField
    ) {
        Set<String> allFields = new Set<String>();
        allFields.addAll(ACCOUNT_QUERY_FIELDS);
        if (fields != null && !fields.isEmpty()) {
            allFields.addAll(fields);
        }

        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder();
        soqlBuilder.selectx(allFields);
        soqlBuilder.fromx(ACCOUNT_OBJECT_TYPE_NAME);

        if (queryCondition != null) {
            soqlBuilder.wherex(queryCondition);
        }

        if (queryLimit != null) {
            soqlBuilder.limitx(queryLimit);
        }

        List<zal.OrderBy> orderBy;
        if (orderByField != null) {
            orderBy = new List<zal.OrderBy>{ new zal.OrderBy(orderByField).ascending() };
        } else {
            orderBy = new List<zal.OrderBy>{ new zal.OrderBy(ACCOUNT_NAME_FIELD_NAME).ascending() };
        }
       
        soqlBuilder.orderByx(orderBy);

        String query = soqlBuilder.toSoql();
        if (queryOffset != null) {
            query = query + ' OFFSET ' + queryOffset;
        }

        List<Account> accounts = Database.query(query);

        return accounts;
    }

    public List<zpl__PolicyType__c> queryPolicyTypeByIds(Set<Id> recordIds) {
        if (recordIds == null || recordIds.isEmpty()) {
            return new List<zpl__PolicyType__c>();
        }
        zal.SetCondition condition = new zal.SetCondition(POLICY_TYPE_ID_FIELD_NAME, zal.Operator.INX, AIQ_CommonUtil.setToListIds(recordIds));
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                .selectx(POLICY_TYPE_QUERY_FIELDS)
                .fromx(POLICY_TYPE_OBJECT_TYPE_NAME)
                .wherex(condition);

        List<zpl__PolicyType__c> policyTypes = Database.query(soqlBuilder.toSoql());
        return policyTypes;
    }

    public List <zpl__PolicyType__c> queryAllPolicyType() {
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                .selectx(POLICY_TYPE_QUERY_FIELDS)
                .fromx(POLICY_TYPE_OBJECT_TYPE_NAME);

        List<zpl__PolicyType__c> policyTypes = Database.query(soqlBuilder.toSoql());
        
        return policyTypes;
    }

    public List <zpl__LineLevel__c> queryAllLineLevels() {
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                .selectx(LINE_LEVEL_QUERY_FIELDS)
                .fromx(LINE_LEVEL_OBJECT_TYPE_NAME);

        List<zpl__LineLevel__c> lineLevels = Database.query(soqlBuilder.toSoql());
        
        return lineLevels;
    }

    public List<zpl__ProductUOM__c> queryUOMByIds(Set<Id> recordIds) {
        if (recordIds == null || recordIds.isEmpty()) {
            return new List<zpl__ProductUOM__c>();
        }
        zal.SetCondition condition = new zal.SetCondition(PRODUCT_UOM_ID_FIELD_NAME, zal.Operator.INX, AIQ_CommonUtil.setToListIds(recordIds));
        return queryUOMByCondition(null, condition);
    }

    public Map<Id, zpl__ProductUOM__c> queryUOMMapByCondition(List<String> fields, zal.ConditionGroup queryCondition) {
        Map<Id, zpl__ProductUOM__c> uomMap = new Map<Id, zpl__ProductUOM__c>();
        if (queryCondition.conditions.isEmpty()) {
            return uomMap;
        }
        List<zpl__ProductUOM__c> uomList = queryUOMByCondition(fields, queryCondition);
        for (zpl__ProductUOM__c uom : uomList) {
            uomMap.put(uom.Id, uom);
        }

        return uomMap;
    }

    public List<zpl__ProductUOM__c> queryUOMByCondition(List<String> fields, zal.Condition queryCondition) {
        Set<String> allFields = new Set<String>();
        allFields.addAll(PRODUCT_UOM_QUERY_FIELDS);
        if (fields != null && !fields.isEmpty()) {
            allFields.addAll(fields);
        }
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
            .selectx(allFields)
            .fromx(PRODUCT_UOM_OBJECT_TYPE_NAME)
            .wherex(queryCondition);

        List<zpl__ProductUOM__c> productUOMS = Database.query(soqlBuilder.toSoql());
        return productUOMS;
    }

    public List<NationalAccountsPricing__c> queryNationalAccountsPricingByCondition(List<String> fields, zal.ConditionGroup queryCondition) {
        List<NationalAccountsPricing__c> napList = new  List<NationalAccountsPricing__c>();
        if (queryCondition.conditions.isEmpty()) {
            return napList;
        }
        Set<String> allFields = new Set<String>();
        allFields.addAll(new List<String> { NATIONAL_ACCOUNT_PRICING_ID_FIELD_NAME });
        if (fields != null && !fields.isEmpty()) {
            allFields.addAll(fields);
        }
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
            .selectx(allFields)
            .fromx(NATIONAL_ACCOUNT_PRICING_OBJECT_TYPE_NAME)
            .wherex(queryCondition);

        napList = Database.query(soqlBuilder.toSoql());
        
        return napList;
    }

    public List<AIQ_CWTItem__c> queryCWTItemByCBSSIKey(List<String> fields, Set<String> cbssiKeys) {
        Set<String> allFields = new Set<String>();
        allFields.addAll(new List<String> { CWT_ITEM_ID_FIELD_NAME });
        if (fields != null && !fields.isEmpty()) {
            allFields.addAll(fields);
        }
        zal.SetCondition condition = new zal.SetCondition(CWT_ITEM_CBSSI_KEY_FIELD_NAME, zal.Operator.INX, AIQ_CommonUtil.setToListStrings(cbssiKeys));
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
            .selectx(allFields)
            .fromx(CWT_ITEM_OBJECT_TYPE_NAME)
            .wherex(condition);

        List<AIQ_CWTItem__c> cwtItems = Database.query(soqlBuilder.toSoql());
        return cwtItems;
    }
}
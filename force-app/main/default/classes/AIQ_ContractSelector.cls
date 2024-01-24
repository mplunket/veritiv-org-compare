public with sharing class AIQ_ContractSelector {

    public final static String OBJECT_NAME = Schema.SObjectType.Contract.getName();

    /** Contract fields */
    public static final String ID_FIELD = Schema.SObjectType.Contract.fields.Id.getName();
    public static final String NAME_FIELD = Schema.SObjectType.Contract.fields.Name.getName();
    public static final String ACCOUNT_ID_FIELD = Schema.SObjectType.Contract.fields.AccountId.getName();
    public static final String CONTRACT_EXTERNAL_ID = Schema.SObjectType.Contract.fields.zpl__ContractId__c.getName();

    /**  Account fields */
    public static final String ACCOUNT_OBJECT_TYPE_NAME = Schema.SObjectType.Account.getName();
    public static final String ACCOUNT_ID_FIELD_NAME = Schema.SObjectType.Account.fields.Id.getName();
    public static final String ACCOUNT_NAME_FIELD_NAME = Schema.SObjectType.Account.fields.Name.getName();
    public static final String ACCOUNT_RECORD_TYPE_NAME = 'Account.RecordType.Name';
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

    /** Contract.AccountId relationship  fields */
    public static final String  CONTRACT_ACCOUNT_RELATIONSHIP = Schema.SObjectType.Contract
        .fields.AccountId.getRelationshipName();

    public static final String ACCOUNT_SERVICING_DIVISION = CONTRACT_ACCOUNT_RELATIONSHIP + '.' 
            + ACCOUNT_SERVICING_DIVISION_FIELD_NAME;
    public static final String ACCOUNT_NAME = CONTRACT_ACCOUNT_RELATIONSHIP + '.' 
            + ACCOUNT_NAME_FIELD_NAME;
    public static final String ACCOUNT_CUSTOMER_ID = CONTRACT_ACCOUNT_RELATIONSHIP + '.' 
            + ACCOUNT_CUSTOMER_ID_FIELD_NAME;
    public static final String ACCOUNT_LEGACY_CODE = CONTRACT_ACCOUNT_RELATIONSHIP + '.' 
            + ACCOUNT_LEGACY_CODE_FIELD_NAME;
    public static final String ACCOUNT_LEGACY_DIVISION = CONTRACT_ACCOUNT_RELATIONSHIP + '.' 
            + ACCOUNT_LEGACY_DIVISION_FIELD_NAME;
    public static final String ACCOUNT_AUTO_NUMBER = CONTRACT_ACCOUNT_RELATIONSHIP + '.' 
            + ACCOUNT_AUTO_NUMBER_FIELD_NAME;
    public static final String ACCOUNT_REPRESENTATIVE_DIVISION = CONTRACT_ACCOUNT_RELATIONSHIP + '.' 
            + ACCOUNT_REPRESENTATIVE_DIVISION_FIELD_NAME;

    /** Servicing Division fields */
    public static final String SERVICING_DIVISION_NAME_FIELD_NAME = Schema.SObjectType.Servicing_Division__c.fields.Name.getName();
    public static final String SERVICING_DIVISION_CODE_FIELD_NAME = Schema.SObjectType.Servicing_Division__c.fields.Division_Code__c.getName();
    
    /** Contract.AccountId.Servicing_Division__c relationship  fields */
    public static final String ACCOUNT_SERVICING_DIVISION_RELATIONSHIP = Schema.SObjectType.Account
        .fields.Servicing_Division__c.getRelationshipName();

    public static final String ACCOUNT_SERVICING_DIVISION_NAME = CONTRACT_ACCOUNT_RELATIONSHIP + '.'
            + ACCOUNT_SERVICING_DIVISION_RELATIONSHIP + '.' 
            + SERVICING_DIVISION_NAME_FIELD_NAME;
    public static final String ACCOUNT_SERVICING_DIVISION_CODE = CONTRACT_ACCOUNT_RELATIONSHIP + '.'
            + ACCOUNT_SERVICING_DIVISION_RELATIONSHIP + '.' 
            + SERVICING_DIVISION_CODE_FIELD_NAME;

    static List<String> defaultFields = new List<String>();

    public AIQ_ContractSelector() {
        defaultFields.add(ID_FIELD);
        defaultFields.add(NAME_FIELD);
        defaultFields.add(ACCOUNT_ID_FIELD);
        defaultFields.add(CONTRACT_EXTERNAL_ID);
    }

    public Contract queryContractById(Id recordId) {
        Contract contract = queryContractById(new List<String>(), recordId);
        return contract;
    }

    public List<Contract> queryContractsById(Set<Id> recordIds) {
        List<Id> ids = new List<Id>();
        ids.addAll(recordIds);
        return queryContractsById(ids);
    }

    public Contract queryContractById(List<String> fields, Id recordId) {
        List<Contract> contracts = queryContractsById(fields, new List<Id>{ recordId });
        if (contracts == null || contracts.isEmpty()) {
            return null;
        }
        return contracts[0];
    }

    public List<Contract> queryContractsById(List<String> fields, List<Id> recordIds) {
        return queryContractsById(fields, recordIds, null);
    }

    public List<Contract> queryContractsById(List<String> fields, List<Id> recordIds, List<zal.SoqlBuilder> subqueries) {
        zal.SetCondition queryCondition = new zal.SetCondition(ID_FIELD, zal.Operator.INX, recordIds);
        return queryContractsByCondition(fields, queryCondition, subqueries);
    }

    public List<Contract> queryContractsById(List<Id> recordIds) {
        zal.SetCondition queryCondition = new zal.SetCondition(ID_FIELD, zal.Operator.INX, recordIds);
        return queryContractsByCondition(queryCondition);
    }

    public List<Contract> queryContractByExternalId(List<String> fields, List<String> externalIds) {
        zal.SetCondition queryCondition = new zal.SetCondition(CONTRACT_EXTERNAL_ID, zal.Operator.INX, externalIds);
        return queryContractsByCondition(fields, queryCondition);
    }

    public List<Contract> queryContractsByCondition(zal.Condition queryCondition) {
        return queryContractsByCondition(new List<String>(), queryCondition);
    }

    public List<Contract> queryContractsByCondition(List<String> fields, zal.Condition queryCondition) {
        return queryContractsByCondition(fields, queryCondition, null);
    }

    public List<Contract> queryContractsByCondition(
        List<String> fields,
        zal.Condition queryCondition,
        List<zal.SoqlBuilder> subqueries
    ) {
        Set<String> allFields = new Set<String>();
        allFields.addAll(defaultFields);
        allFields.addAll(fields);

        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder();
        soqlBuilder.selectx(allFields);
        soqlBuilder.fromx(OBJECT_NAME);

        if (queryCondition != null) {
            soqlBuilder.wherex(queryCondition);
        }

        if (subqueries != null && !subqueries.isEmpty()) {
            for (zal.SoqlBuilder subquery : subqueries) {
                soqlBuilder.selectx(subquery);
            }
        }
        List<Contract> contracts = Database.query(soqlBuilder.toSoql());

        return contracts;
    }

    public zal.SoqlBuilder getSubQuery(List<String> fields, String objectName, zal.Condition condtn) {
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder().selectx(fields).fromx(objectName).wherex(condtn);
        return soqlBuilder;
    }
}
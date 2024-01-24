global with sharing class AIQ_ChainAccountLinesFilter implements zpl.ScopedLineItemsFilterer {
    public static final String RECORD_TYPE_ID_FIELD = SObjectType.zpl__ContractLineItem__c.fields.RecordTypeId.getName();
    public static final String IS_CURRENT_FIELD = SObjectType.zpl__ContractLineItem__c.fields.isCurrent__c.getName();
    public static final String CONTRACT_ACCOUNT_ID_FIELD = 'zpl__Contract__r.AccountId';
    public static final String CLI_RT_ACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
            .get('Active')
            .getRecordTypeId();

    @TestVisible
    public AIQ_GenericSelector genericSelector = new AIQ_GenericSelector();

    global zal.Condition getScopedFilterCondition(Id param0, Map<String,Object> scope) {
        String contractId = (String) scope.get('contractId');
        Contract contract = genericSelector.queryContractById(contractId);
        String chainAcctId = null;
        if (contract != null && contract.Account.Chain_Account__c != null) {
            chainAcctId = contract.Account.Chain_Account__c;
        }
        zal.AndCondition condition = new zal.AndCondition();
        condition.add(new zal.FieldCondition(RECORD_TYPE_ID_FIELD, zal.Operator.EQUALS, CLI_RT_ACTIVE_ID));
        condition.add(new zal.FieldCondition(IS_CURRENT_FIELD, zal.Operator.EQUALS, true));
        condition.add(new zal.FieldCondition(CONTRACT_ACCOUNT_ID_FIELD, zal.Operator.EQUALS, chainAcctId));
        return condition;
    }

    global zal.Condition getFilterCondition(Id param0) {
        return null;
    }
}
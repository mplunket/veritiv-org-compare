global with sharing class AIQ_ContractLineItemFilter implements zpl.LineItemsFilterer {
    public static final String RECORD_TYPE_ID_FIELD = SObjectType.zpl__ContractLineItem__c.fields.RecordTypeId.getName();
    public static final String IS_CURRENT_FIELD = SObjectType.zpl__ContractLineItem__c.fields.isCurrent__c.getName();
    public static final String SUPERSEDED_DATE_FIELD = SObjectType.zpl__ContractLineItem__c.fields.SupersededDate__c.getName();
    public static final String CLI_RT_INACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
            .get('Inactive')
            .getRecordTypeId();

    global zal.Condition getFilterCondition(Id param0) {
        zal.AndCondition mainCondition = new zal.AndCondition();
        mainCondition.add(new zal.FieldCondition(RECORD_TYPE_ID_FIELD, zal.Operator.NOT_EQUALS, CLI_RT_INACTIVE_ID));
        zal.OrCondition secondCondition = new zal.OrCondition();
        secondCondition.add(new zal.FieldCondition(IS_CURRENT_FIELD, zal.Operator.EQUALS, true));
        secondCondition.add(new zal.FieldCondition(SUPERSEDED_DATE_FIELD, zal.Operator.EQUALS, null));
        secondCondition.add(new zal.FieldCondition(SUPERSEDED_DATE_FIELD, zal.Operator.LESS_THAN,
                DateTime.newInstance(1900, 2, 1, 0, 0, 0)));
        zal.AndCondition dateCondition = new zal.AndCondition();
        dateCondition.add(new zal.FieldCondition(SUPERSEDED_DATE_FIELD, zal.Operator.LESS_THAN_OR_EQUAL_TO,
                System.now()));
        dateCondition.add(new zal.FieldCondition(SUPERSEDED_DATE_FIELD, zal.Operator.GREATER_THAN_OR_EQUAL_TO,
                System.now().addDays(-7)));
                
        secondCondition.add(dateCondition);
        mainCondition.add(secondCondition);
        return mainCondition;
    }
}
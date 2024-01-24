global with sharing class AIQ_AuditTrailLinesFilter implements zpl.LineItemsFilterer {
    public static final String CLI_STATUS_DRAFT = 'Draft';
    public static final String STATUS_FIELD = SObjectType.zpl__ContractLineItem__c.fields.zpl__Status__c.getName();
    public static final String SUPERSEDED_DATE_FIELD = SObjectType.zpl__ContractLineItem__c.fields.SupersededDate__c.getName();

    global zal.Condition getFilterCondition(Id param0) {
        zal.AndCondition andCondition = new zal.AndCondition();
        andCondition.add(new zal.FieldCondition(STATUS_FIELD, zal.Operator.NOT_EQUALS, CLI_STATUS_DRAFT));
        zal.OrCondition supersededDayCondition = new zal.OrCondition();
        supersededDayCondition.add(new zal.FieldCondition(SUPERSEDED_DATE_FIELD, zal.Operator.GREATER_THAN, System.now().addDays(-365)));
        supersededDayCondition.add(new zal.FieldCondition(SUPERSEDED_DATE_FIELD, zal.Operator.EQUALS, null));
        andCondition.add(supersededDayCondition);

        return andCondition;
    }
}
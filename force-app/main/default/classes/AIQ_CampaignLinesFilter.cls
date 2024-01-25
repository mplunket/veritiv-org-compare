global with sharing class AIQ_CampaignLinesFilter implements zpl.LineItemsFilterer {
    public static final String IS_CAMPAIGN_FIELD = SObjectType.zpl__ContractLineItem__c.fields.IsCampaign__c.getName();
    public static final String STATUS_FIELD = SObjectType.zpl__ContractLineItem__c.fields.zpl__Status__c.getName();
    public static final String EFFECTIVE_DATE_FIELD = SObjectType.zpl__ContractLineItem__c.fields.zpl__EffectiveDate__c.getName();
    public static final String CLI_STATUS_PUBLISHED = 'Published';
    public static final Integer INTERVAL = 
        (Integer) aiq_ParameterSettings__mdt.getInstance('campaignDashboardDisplayInterval').aiq_ParameterValue__c;

    global zal.Condition getFilterCondition(Id param0){
        zal.AndCondition mainCondition = new zal.AndCondition();
        mainCondition.add(new zal.FieldCondition(IS_CAMPAIGN_FIELD, zal.Operator.EQUALS, true));
        mainCondition.add(new zal.FieldCondition(STATUS_FIELD, zal.Operator.EQUALS, CLI_STATUS_PUBLISHED));
        mainCondition.add(new zal.FieldCondition(
                EFFECTIVE_DATE_FIELD,
                zal.Operator.GREATER_THAN_OR_EQUAL_TO,
                System.today().adddays(INTERVAL))
        );
        return mainCondition;
    }
}
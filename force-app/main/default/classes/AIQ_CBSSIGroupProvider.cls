public with sharing class AIQ_CBSSIGroupProvider {
    @TestVisible
    private List<AIQ_CBSSIGroupDomain> cbssiGroups = new List<AIQ_CBSSIGroupDomain>();
    @TestVisible
    private AIQ_ContractLineSelector contractLineSelector;

    public AIQ_CBSSIGroupProvider() {
        contractLineSelector = new AIQ_ContractLineSelector();
    }

    @TestVisible
    private final static List<String> CONTRACT_LINES_QUERY_FIELDS = new List<String>{
        AIQ_ContractLineSelector.ID_FIELD,
        AIQ_ContractLineSelector.NAME_FIELD,
        AIQ_ContractLineSelector.CONTRACT_LINE_RECORD_TYPE_NAME,
        AIQ_ContractLineSelector.CAMPAIGN_APPEALED_LINE_FIELD,
        AIQ_ContractLineSelector.CONTRACT_LINE_ITEM_ID_FIELD,
        AIQ_ContractLineSelector.CONTRACT_FIELD,
        AIQ_ContractLineSelector.CBSS_FIELD,
        AIQ_ContractLineSelector.PRODUCT_FIELD,
        AIQ_ContractLineSelector.STATUS_FIELD,
        AIQ_ContractLineSelector.IS_CURRENT_FIELD,
        AIQ_ContractLineSelector.EFFECTIVE_DATE_FIELD,
        AIQ_ContractLineSelector.CBSS_ITEM_GROUPING_KEY_FIELD,
        AIQ_ContractLineSelector.SEGMENT_FIELD,
        AIQ_ContractLineSelector.DIVISION_FIELD,
        AIQ_ContractLineSelector.VENDORE_CODE_FIELD,
        AIQ_ContractLineSelector.CLASS_FIELD,
        AIQ_ContractLineSelector.BRAND_FIELD,
        AIQ_ContractLineSelector.SET_FIELD,
        AIQ_ContractLineSelector.SUBSET_FIELD,
        AIQ_ContractLineSelector.SKU_FIELD,
        AIQ_ContractLineSelector.SUPERSEDED_DATE_FIELD,
        AIQ_ContractLineSelector.PRICE_DECREASE_FLAG_FIELD,
        AIQ_ContractLineSelector.NET_PRICE_FIELD,
        AIQ_ContractLineSelector.CURRENT_SCORE_FIELD,
        AIQ_ContractLineSelector.UOM_FIELD,
        AIQ_ContractLineSelector.PUBLISH_DATE_FIELD,
        AIQ_ContractLineSelector.PUBLISHED_PRICE_FIELD,
        AIQ_ContractLineSelector.PUBLISHED_COST_FIELD,
        AIQ_ContractLineSelector.POLICY_TYPE_FIELD,
        AIQ_ContractLineSelector.LIST_PRICE_FIELD,
        AIQ_ContractLineSelector.POLICY_VALUE_FIELD,
        AIQ_ContractLineSelector.LINE_LEVEL_FIELD,
        AIQ_ContractLineSelector.CREATED_DATE_FIELD,
        AIQ_ContractLineSelector.X12_MONTH_SALES_VOLUME_FIELD,
        AIQ_ContractLineSelector.PREVIOUS_VALUE_FIELD,
        AIQ_ContractLineSelector.PREVIOUS_PRICE_FIELD,
        AIQ_ContractLineSelector.PREVIOUS_COST_FIELD,
        AIQ_ContractLineSelector.CONTRACT_LINE_UOM_CONVERSION_FACTOR_FIELD_NAME,
        AIQ_ContractLineSelector.CONTRACT_LINE_POLICY_TYPE_POLICY_TYPE_ID_FIELD_NAME,
        AIQ_ContractLineSelector.INACTIVATED_BY_FIELD,
        AIQ_ContractLineSelector.INACTIVATED_DATE_FIELD
    };

    // builds groups for incoming lines and seeks for siblings
    public List<AIQ_CBSSIGroupDomain> provide(List<zpl__ContractLineItem__c> agreementLines, List<Id> recordTypeIds) {
        AIQco_Precondition.checkNotNull(agreementLines, 'List of Contract Line Items is null');
        AIQco_Precondition.checkArgument(agreementLines.isEmpty(), 'List of Contract Line Items is empty');
        AIQco_Precondition.checkNotNull(recordTypeIds, 'List of record type ids is null');
        AIQco_Precondition.checkArgument(recordTypeIds.isEmpty(), 'List of record type ids is empty');

        this.addLinesToGroup(agreementLines, true);
        Set<String> cbssiGroupKeys = new Set<String>();
        for (zpl__ContractLineItem__c agreementLine : agreementLines) {
            cbssiGroupKeys.add(agreementLine.CBSSItemGroupingKey__c);
        }

        return provide(cbssiGroupKeys, recordTypeIds);
    }

    // populates groups with siblings
    public List<AIQ_CBSSIGroupDomain> provide(Set<String> cbssiGroupKeys, List<Id> recordTypeIds) {
        AIQco_Precondition.checkNotNull(cbssiGroupKeys, 'Set of cbssi keys is null');
        AIQco_Precondition.checkArgument(cbssiGroupKeys.isEmpty(), 'Set of cbssi keys is empty');
        AIQco_Precondition.checkNotNull(recordTypeIds, 'List of record type ids is null');
        AIQco_Precondition.checkArgument(recordTypeIds.isEmpty(), 'List of record type ids is empty');

        List<zpl__ContractLineItem__c> lines = contractLineSelector.queryContractLinesByCondition(
            CONTRACT_LINES_QUERY_FIELDS,
            getGroupCondition(cbssiGroupKeys, recordTypeIds)
        );
        this.addLinesToGroup(lines, false);

        return this.cbssiGroups;
    }

    private zal.Condition getGroupCondition(Set<String> cbssiGroupKeys, List<Id> recordTypeIds) {
        zal.AndCondition andCondition = new zal.AndCondition();
        andCondition.add(contractLineSelector.getConditionByCbssiKey(new List<String>(cbssiGroupKeys)));
        andCondition.add(contractLineSelector.getConditionByRecordType(recordTypeIds));
        return andCondition;
    }

    private AIQ_CBSSIGroupDomain getGroup(String cbssiGroupKey) {
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(cbssiGroupKey);
        if (cbssiGroups.contains(cbssiGroup)) {
            cbssiGroup = cbssiGroups.get(cbssiGroups.indexOf(cbssiGroup));
        } else {
            cbssiGroups.add(cbssiGroup);
        }
        return cbssiGroup;
    }

    private void addLinesToGroup(List<zpl__ContractLineItem__c> lines, Boolean isOriginal) {
        for (zpl__ContractLineItem__c line : lines) {
            getGroup(line.CBSSItemGroupingKey__c).addLine(line, isOriginal);
        }
    }
}
public inherited sharing class AIQ_ContractLineCopyUtil {
    public class AIQ_ContractLineCopyUtilException extends Exception {
    }
    private static final String LINE_SOURCE_U = 'U';
    @TestVisible
    private static final String LINE_STATUS_DRAFT = 'Draft';
    private static final Id LINE_RECORD_TYPE_ID_DRAFT = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
        .get('Draft')
        .getRecordTypeId();
    @TestVisible
    private static final String CONTRACT_LINE_ITEM_OBJECT_NAME = Schema.SObjectType.zpl__ContractLineItem__c.getName();

    // fields to exclude
    private static final String APPROVED_BY_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Approved_By__c.getName();
    private static final String APPROVED_DATE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Approved_Date__c.getName();
    private static final String PUBLISHED_BY_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Published_By__c.getName();
    private static final String PUBLISHED_DATE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Publish_Date__c.getName();
    private static final String PUBLISHED_SCORE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.PublishedScore__c.getName();
    private static final String PUBLISHED_PRICE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.PublishedPrice__c.getName();
    private static final String PUBLISHED_COST_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.PublishedCost__c.getName();
    private static final String PUBLISHED_NV_START_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.PublishedNVStart__c.getName();
    private static final String PUBLISHED_NV_TARGET_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.PublishedNVTarget__c.getName();
    private static final String PUBLISHED_NV_FLOOR_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.PublishedNVFloor__c.getName();
    private static final String REJECTED_BY_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Rejected_By__c.getName();
    private static final String REJECTED_DATE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Rejected_Date__c.getName();
    private static final String INACTIVATED_BY_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Inactivated_By__c.getName();
    private static final String INACTIVATED_DATE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Inactivated_Date__c.getName();
    private static final String SUPERSEDED_DATE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.SupersededDate__c.getName();
    private static final String PENDING_APPROVAL_DATE_FROM_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Pending_Approval_Date_From__c.getName();
    private static final String LINE_SOURCE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.LineSource__c.getName();
    private static final String REASON_CODE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Reason_Code__c.getName();
    private static final String COMMENTS_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Comments__c.getName();
    private static final String PREVIOUS_PRICE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.PreviousPrice__c.getName();
    private static final String PREVIOUS_COST_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.PreviousCost__c.getName();
    private static final String PREVIOUS_VALUE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.PreviousValue__c.getName();
    private static final String INITIATIVE_ACTION_ID_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.InitiativeActionId__c.getName();
    private static final String CAMPAIGN_NAME_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.CampaignName__c.getName();
    private static final String CAMPAIGN_EFFECTIVE_DATE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.CampaignEffectiveDate__c.getName();
    private static final String CAMPAIGN_NEW_COST_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.CampaignNewCost__c.getName();
    private static final String CAMPAIGN_PROPOSED_POLICY_TYPE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.CampaignProposedPolicyType__c.getName();
    private static final String CAMPAIGN_PROPOSED_VALUE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.CampaignProposedValue__c.getName();
    private static final String CAMPAIGN_APPEALED_LINE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.CampaignAppealedLine__c.getName();
    private static final String DISCOUNT_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Discount__c.getName();
    private static final String FLOOR_PRICE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Floor_Price__c.getName();
    private static final String INTERNAL_COST_DEVIATION_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.InternalCostDeviation__c.getName();
    private static final String INTERNAL_COST_DEVIATION_DATE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.InternalCostDeviationDate__c.getName();
    private static final String FUTURE_PRICING_COST_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.FuturePricingCost__c.getName();
    private static final String FUTURE_PRICING_COST_DATE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.FuturePricingCostDate__c.getName();
    private static final String MARGIN_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Margin__c.getName();
    private static final String MARKUP_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Markup__c.getName();
    private static final String NET_Price_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Net_Price__c.getName();
    private static final String NV_FLOOR_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.NV_Floor__c.getName();
    private static final String NV_START_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.NV_Start__c.getName();
    private static final String NV_TARGET_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.NV_Target__c.getName();
    private static final String PRICING_COST_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.PricingCost__c.getName();
    private static final String EXTERNAL_COST_DEVIATION_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.ExternalCostDeviation__c.getName();
    private static final String EXTERNAL_COST_DEVIATION_DATE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.ExternalCostDeviationDate__c.getName();
    private static final String OPTIMIZATION_SEGMENT_ID_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.OptimizationSegmentID__c.getName();
    private static final String START_PRICE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Start_Price__c.getName();
    private static final String CURRENT_STANDARD_COST_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Current_Standard_Cost__c.getName();
    private static final String TARGET_PRICE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.Target_Price__c.getName();
    private static final String CONTRACT_LINE_ITEM_ID_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__ContractLineItemId__c.getName();
    private static final String CONTRACT_LINE_PRODUCT_ID_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__Product__c.getName();
    private static final String CONTRACT_LINE_UOM_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__UOM__c.getName();
    private static final String CONTRACT_LINE_POLICY_TYPE_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__PolicyType__c.getName();

    @TestVisible
    private AIQco_SObjectUtil sObjectUtil = new AIQco_SObjectUtil();
    @TestVisible
    private Set<String> excludedFields = new Set<String>();
    private Set<String> requiredFields = new Set<String>();
    private List<zpl__ContractLineItem__c> cloneLines = new List<zpl__ContractLineItem__c>();
    
    public AIQ_ContractLineCopyUtil() {
        excludedFields.add(APPROVED_BY_FIELD_NAME);
        excludedFields.add(APPROVED_DATE_FIELD_NAME);
        excludedFields.add(PUBLISHED_BY_FIELD_NAME);
        excludedFields.add(PUBLISHED_DATE_FIELD_NAME);
        excludedFields.add(PUBLISHED_SCORE_FIELD_NAME);
        excludedFields.add(PUBLISHED_PRICE_FIELD_NAME);
        excludedFields.add(PUBLISHED_COST_FIELD_NAME);
        excludedFields.add(PUBLISHED_NV_START_FIELD_NAME);
        excludedFields.add(PUBLISHED_NV_TARGET_FIELD_NAME);
        excludedFields.add(PUBLISHED_NV_FLOOR_FIELD_NAME);
        excludedFields.add(REJECTED_BY_FIELD_NAME);
        excludedFields.add(REJECTED_DATE_FIELD_NAME);
        excludedFields.add(INACTIVATED_BY_FIELD_NAME);
        excludedFields.add(INACTIVATED_DATE_FIELD_NAME);
        excludedFields.add(SUPERSEDED_DATE_FIELD_NAME);
        excludedFields.add(PENDING_APPROVAL_DATE_FROM_FIELD_NAME);
        excludedFields.add(LINE_SOURCE_FIELD_NAME);
        excludedFields.add(REASON_CODE_FIELD_NAME);
        excludedFields.add(COMMENTS_FIELD_NAME);
        excludedFields.add(PREVIOUS_PRICE_FIELD_NAME);
        excludedFields.add(PREVIOUS_COST_FIELD_NAME);
        excludedFields.add(PREVIOUS_VALUE_FIELD_NAME);
        excludedFields.add(INITIATIVE_ACTION_ID_FIELD_NAME);
        excludedFields.add(CAMPAIGN_NAME_FIELD_NAME);
        excludedFields.add(CAMPAIGN_EFFECTIVE_DATE_FIELD_NAME);
        excludedFields.add(CAMPAIGN_NEW_COST_FIELD_NAME);
        excludedFields.add(CAMPAIGN_PROPOSED_POLICY_TYPE_FIELD_NAME);
        excludedFields.add(CAMPAIGN_PROPOSED_VALUE_FIELD_NAME);
        excludedFields.add(CAMPAIGN_APPEALED_LINE_FIELD_NAME);
        excludedFields.add(DISCOUNT_FIELD_NAME);
        excludedFields.add(FLOOR_PRICE_FIELD_NAME);
        excludedFields.add(INTERNAL_COST_DEVIATION_FIELD_NAME);
        excludedFields.add(INTERNAL_COST_DEVIATION_DATE_FIELD_NAME);
        excludedFields.add(FUTURE_PRICING_COST_FIELD_NAME);
        excludedFields.add(FUTURE_PRICING_COST_DATE_FIELD_NAME);
        excludedFields.add(MARGIN_FIELD_NAME);
        excludedFields.add(MARKUP_FIELD_NAME);
        excludedFields.add(NV_FLOOR_FIELD_NAME);
        excludedFields.add(NV_START_FIELD_NAME);
        excludedFields.add(NV_TARGET_FIELD_NAME);
        excludedFields.add(EXTERNAL_COST_DEVIATION_FIELD_NAME);
        excludedFields.add(EXTERNAL_COST_DEVIATION_DATE_FIELD_NAME);
        excludedFields.add(OPTIMIZATION_SEGMENT_ID_FIELD_NAME);
        excludedFields.add(START_PRICE_FIELD_NAME);
        excludedFields.add(CURRENT_STANDARD_COST_FIELD_NAME);
        excludedFields.add(TARGET_PRICE_FIELD_NAME);
    }

    public AIQ_ContractLineCopyUtil copyLines(Set<Id> recordIds) {
        cloneLines = (List<zpl__ContractLineItem__c>) sObjectUtil.getClone(
            CONTRACT_LINE_ITEM_OBJECT_NAME,
            new List<Id>(recordIds),
            new List<String>(excludedFields),
            true
        );
        return this;
    }

    public AIQ_ContractLineCopyUtil copyLines(Set<Id> recordIds, Boolean preserveId) {
        cloneLines = (List<zpl__ContractLineItem__c>) sObjectUtil.getClone(
            CONTRACT_LINE_ITEM_OBJECT_NAME,
            new List<Id>(recordIds),
            new List<String>(excludedFields),
            preserveId
        );
        return this;
    }

    public AIQ_ContractLineCopyUtil setFieldsToExclude(List<String> fieldsToExclude) {
        this.excludedFields.addAll(fieldsToExclude);
        return this;
    }

    public AIQ_ContractLineCopyUtil setDefaults() {
        for (zpl__ContractLineItem__c line : cloneLines) {
            if (line.zpl__Status__c == LINE_STATUS_DRAFT) {
                continue;
            }
            line.put(CONTRACT_LINE_ITEM_ID_FIELD_NAME, null);
            line.zpl__Status__c = LINE_STATUS_DRAFT;
            line.RecordTypeId = LINE_RECORD_TYPE_ID_DRAFT;
            line.isCurrent__c = true;
            line.PriceDecreaseFlag__c = false;
            line.LineSource__c = LINE_SOURCE_U;
            setClosestEffectiveDate(line);
            setCampaignDefaults(line);
            line.Id = null;
        }

        return this;
    }

    public List<zpl__ContractLineItem__c> getCloneLines() {
        return this.cloneLines;
    }

    private void setCampaignDefaults(zpl__ContractLineItem__c line) {
        if (!line.IsCampaign__c) {
            line.IsCampaignAppealed__c = false;
            return;
        }
        line.CampaignAppealedLine__c = line.Id;
        line.IsCampaignAppealed__c = true;
        line.Recommended_Price__c = line.Net_Price__c;
        line.Recommended_Cost__c = line.PricingCost__c;
        line.PriorConversionFactor__c = line.ConversionFactorCurrent__c;
    }

    private void setClosestEffectiveDate(zpl__ContractLineItem__c line) {
        line.zpl__EffectiveDate__c = (line.zpl__EffectiveDate__c > Date.today() ? line.zpl__EffectiveDate__c : Date.today());
    }
}
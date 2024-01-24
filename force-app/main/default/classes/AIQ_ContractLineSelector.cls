public with sharing class AIQ_ContractLineSelector {

    public final static String OBJECT_NAME = Schema.SObjectType.zpl__ContractLineItem__c.getName();

    /**
    * Contract line item fields
    */
    public static final String ID_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Id.getName();
    public static final String NAME_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Name.getName();
    public static final String CONTRACT_LINE_ITEM_ID_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__ContractLineItemId__c.getName();
    public static final String CONTRACT_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__Contract__c.getName();
    public static final String BRAND_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Brand__c.getName();
    public static final String CLASS_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Class__c.getName();
    public static final String DEFAULT_POLICY_TYPE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.DefaultPolicyType__c.getName();
    public static final String DIVISION_CODE2_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Division_Code2__c.getName();
    public static final String NULLABLE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Nullable__c.getName();
    public static final String SET_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Set__c.getName();
    public static final String SKU_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.SKU__c.getName();
    public static final String SUBSET_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Subset__c.getName();
    public static final String SYSTEM_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.System__c.getName();
    public static final String PRODUCT_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__Product__c.getName();
    public static final String UOM_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__UOM__c.getName();
    public static final String POLICY_TYPE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__PolicyType__c.getName();
    public static final String POLICY_VALUE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__PolicyValue__c.getName();
    public static final String STATUS_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__Status__c.getName();
    public static final String RECORD_TYPE_ID_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.RecordTypeId.getName();
    public static final String CONTRACT_LINE_RECORD_TYPE_NAME = 'RecordType.Name';
    public static final String CONTRACT_LINE_CAMPAIGN_APPEALED_EFFECTIVE_DATE = 'CampaignAppealedLine__r.zpl__EffectiveDate__c';
    public static final String PUBLISHED_BY_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Published_By__c.getName();
    public static final String PUBLISH_DATE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Publish_Date__c.getName();
    public static final String CURRENT_SCORE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.CurrentScore__c.getName();
    public static final String APPROVED_BY_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Approved_By__c.getName();
    public static final String EFFECTIVE_DATE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__EffectiveDate__c.getName();
    public static final String LINE_ITEM_NAME_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Line_Item_Name__c.getName();
    public static final String CBSS_ITEM_GROUPING_KEY_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.CBSSItemGroupingKey__c.getName();
    public static final String CONVERSION_FACTOR_CURRENT_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.ConversionFactorCurrent__c.getName();
    public static final String NET_PRICE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Net_Price__c.getName();
    public static final String AIQ_NET_PRICE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.aiq_Net_Price__c.getName();
    public static final String PRICING_COST_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.PricingCost__c.getName();
    public static final String NV_START_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.NV_Start__c.getName();
    public static final String NV_TARGET_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.NV_Target__c.getName();
    public static final String NV_FLOOR_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.NV_Floor__c.getName();
    public static final String PUBLISHED_SCORE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.PublishedScore__c.getName();
    public static final String LINE_LEVEL_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__LineLevel__c.getName();
    public static final String CAMPAIGN_APPEALED_LINE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.CampaignAppealedLine__c.getName();
    public static final String LIST_PRICE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.ListPrice__c.getName();
    public static final String PREVIOUS_VALUE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.PreviousValue__c.getName();
    public static final String PREVIOUS_PRICE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.PreviousPrice__c.getName();
    public static final String PREVIOUS_COST_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.PreviousCost__c.getName();
    public static final String SUPERSEDED_DATE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.SupersededDate__c.getName();
    public static final String PUBLISHED_PRICE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.PublishedPrice__c.getName();
    public static final String IS_CURRENT_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.isCurrent__c.getName();
    public static final String INACTIVATED_BY_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Inactivated_By__c.getName();
    public static final String INACTIVATED_DATE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Inactivated_Date__c.getName();
    public static final String FUTURE_PRICING_COST_DATE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.FuturePricingCostDate__c.getName();
    public static final String FUTURE_PRICING_COST_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.FuturePricingCost__c.getName();
    public static final String PUBLISHED_COST_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.PublishedCost__c.getName();
    public static final String PENDING_APPROVAL_DATE_FROM_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Pending_Approval_Date_From__c.getName();
    public static final String CBSS_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.CBSS__c.getName();
    public static final String SEGMENT_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Segment__c.getName();
    public static final String DIVISION_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Division__c.getName();
    public static final String VENDORE_CODE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.VendorCode__c.getName();
    public static final String PRICE_DECREASE_FLAG_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.PriceDecreaseFlag__c.getName();
    public static final String CREATED_DATE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.CreatedDate.getName();
    public static final String X12_MONTH_SALES_VOLUME_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.X12MonthSalesVolume__c.getName();
    public static final String ORDER_QTY_UOM_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.OrderQtyUOM__c.getName();
    public static final String QUANTITY_BREAK_UOM_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.QuantityBreakUOM__c.getName();
    public static final String CUSTOMER_BASE_UOM_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.CustomerBaseUOM__c.getName();
    public static final String EXTERNAL_COST_DEVIATION_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.ExternalCostDeviation__c.getName();
    public static final String EXTERNAL_COST_DEVIATION_DATE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.ExternalCostDeviationDate__c.getName();
    public static final String COST_REPLACE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.CostReplace__c.getName();
    public static final String DISPLAY_CC2_COST_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.DisplayCC2Cost__c.getName();
    public static final String CURRENT_STANDARD_COST_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Current_Standard_Cost__c.getName();
    public static final String CONTRACT_PRICE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__ContractPrice__c.getName();
    public static final String RECOMMENDED_PRICE_FIELD = Schema.SObjectType.zpl__ContractLineItem__c.fields.Recommended_Price__c.getName();

     /** Contract line record types */
    public static final String LINE_DRAFT_RECORD_TYPE_ID = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
            .get('Draft')
            .getRecordTypeId();
    public static final String LINE_INACTIVE_RECORD_TYPE_ID = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
            .get('Inactive')
            .getRecordTypeId();
    public static final String LINE_ACTIVE_RECORD_TYPE_ID = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
            .get('Active')
            .getRecordTypeId();

    /**
    * zpl__ContractLineItem__c.zpl__Contract__c relationship  fields
    */
    public static final String CONTRACT_LINE_CONTRACT_RELATIONSHIP = Schema.SObjectType.zpl__ContractLineItem__c
            .fields.zpl__Contract__c.getRelationshipName();

    /**
    * Contract fields
    */
    public static final String CONTRACT_ACCOUNT_ID_FIELD_NAME = Schema.SObjectType.Contract.fields.AccountId.getName();
    public static final String ACCOUNT_SALES_REP_USER_ID_FIELD = 'zpl__Contract__r.Account.Primary_Sales_Rep_Name__r.SF_userid__r.Id'; //refactor

    /**
     * zpl__ContractLineItem__c.zpl__Contract__c relationship fields
     */
    public static final String CONTRACT_LINE_CONTRACT_ACCOUNT_ID_FIELD_NAME = CONTRACT_LINE_CONTRACT_RELATIONSHIP
            + '.' + CONTRACT_ACCOUNT_ID_FIELD_NAME;

    /**
    * Policy Type fields
    */
    public static final String POLICY_TYPE_POLICY_TYPE_ID_FIELD_NAME = Schema.SObjectType.zpl__PolicyType__c.fields.zpl__PolicyTypeId__c.getName();

    /**
    * zpl__ContractLineItem__c.zpl__PolicyType__c relationship  fields
    */
    public static final String CONTRACT_LINE_POLICY_TYPE_POLICY_TYPE_ID_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c
            .fields.zpl__PolicyType__c.getRelationshipName() + '.' + POLICY_TYPE_POLICY_TYPE_ID_FIELD_NAME;

    /**
    * UOM fields
    */
    public static final String UOM_CONVERSION_FACTOR_FIELD_NAME = Schema.SObjectType.zpl__UOM__c.fields.zpl__ConversionFactor__c.getName();

    /**
    * zpl__ContractLineItem__c.zpl__UOM__c relationship  fields
    */
    public static final String CONTRACT_LINE_UOM_CONVERSION_FACTOR_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c
            .fields.zpl__UOM__c.getRelationshipName() + '.' + UOM_CONVERSION_FACTOR_FIELD_NAME;

    /**
    * zpl__ContractLineItem__c.CampaignAppealedLine__c relationship fields
    */
    public static final String CONTRACT_LINE_CAMPAIGN_CONTRACT_LINE_ITEM_ID_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c
            .fields.CampaignAppealedLine__c.getRelationshipName() + '.' + CONTRACT_LINE_ITEM_ID_FIELD;

    static List<String> defaultFields = new List<String>();

    public AIQ_ContractLineSelector() {
        defaultFields.add(ID_FIELD);
        defaultFields.add(NAME_FIELD);
        defaultFields.add(CONTRACT_FIELD);
        defaultFields.add(STATUS_FIELD);
    }

    public zpl__ContractLineItem__c queryContractLineById(Id recordId) {
        zpl__ContractLineItem__c contractLine = queryContractLineById(new List<String>(), recordId);
        if (contractLine == null) {
            return null;
        }
        return contractLine;
    }

    public List<zpl__ContractLineItem__c> queryContractLinesById(Set<Id> recordIds) {
        List<Id> ids = new List<Id>();
        ids.addAll(recordIds);
        return queryContractLinesById(ids);
    }

    public zpl__ContractLineItem__c queryContractLineById(List<String> fields, Id recordId) {
        List<zpl__ContractLineItem__c> contractLines = queryContractLinesById(fields, new List<Id>{ recordId });
        if (contractLines == null || contractLines.isEmpty()) {
            return null;
        }
        return contractLines[0];
    }

    public List<zpl__ContractLineItem__c> queryContractLinesById(List<String> fields, List<Id> recordIds) {
        zal.SetCondition queryCondition = new zal.SetCondition(ID_FIELD, zal.Operator.INX, recordIds);
        return queryContractLinesByCondition(fields, queryCondition);
    }

    public List<zpl__ContractLineItem__c> queryContractLinesById(List<Id> recordIds) {
        zal.SetCondition queryCondition = new zal.SetCondition(ID_FIELD, zal.Operator.INX, recordIds);
        return queryContractLinesByCondition(queryCondition);
    }

    public List<zpl__ContractLineItem__c> queryContractLinesByCondition(zal.Condition queryCondition) {
        return queryContractLinesByCondition(new List<String>(), queryCondition);
    }

    public List<zpl__ContractLineItem__c> queryContractLinesByCondition(
        List<String> fields,
        zal.Condition queryCondition
    ) {
        return queryContractLinesByCondition(fields, queryCondition, null, null);
    }

    public zal.Condition getConditionByCbssiKey(List<String> cbssiGroupKey) {
        return new zal.SetCondition(CBSS_ITEM_GROUPING_KEY_FIELD, zal.Operator.INX, cbssiGroupKey);
    }

    public zal.Condition getConditionByRecordType(List<Id> recordTypeIds) {
        return new zal.SetCondition('RecordTypeId', zal.Operator.INX, recordTypeIds);
    }

    public List<zpl__ContractLineItem__c> queryContractLinesByCondition(
        List<String> fields,
        zal.Condition queryCondition,
        Integer queryLimit,
        Integer queryOffset
    ) {
        Set<String> allFields = new Set<String>();
        allFields.addAll(defaultFields);
        if (fields != null && !fields.isEmpty()) {
            allFields.addAll(fields);
        }

        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder();
        soqlBuilder.selectx(allFields);
        soqlBuilder.fromx(OBJECT_NAME);

        if (queryCondition != null) {
            soqlBuilder.wherex(queryCondition);
        }

        if (queryLimit != null) {
            soqlBuilder.limitx(queryLimit);
        }

        List<zal.OrderBy> orderBy = new List<zal.OrderBy>{ new zal.OrderBy(ID_FIELD).ascending() };
        soqlBuilder.orderByx(orderBy);

        String query = soqlBuilder.toSoql();
        if (queryOffset != null) {
            query = query + ' OFFSET ' + queryOffset;
        }

        List<zpl__ContractLineItem__c> contractLines = Database.query(query);

        return contractLines;
    }
}
public without sharing class AIQ_AgreementLineItemTriggerHandler {
    public class AIQ_AgreementLineItemTriggerHandlerException extends Exception {}
    private final static String SYNC_DOWN_BYPASS_CONFIGURATION_NAME  = Label.aiq_SyncDownBypassConfigName;
    private final static String REASON_CODE_ERROR_MESSAGE = Label.aiq_ReasonCodeErrorMessage;
    private final static String NOT_SELECTED = Label.aiq_DefaultReasonCode;

    private final static String USER_LINE_SCORE = 'U';
    private final static String PRODUCT_UOM_CW = 'CW';
    private final static String SYSTEM_CODE_SW = 'SW';
    private final static String SYSTEM_CODE_03 = '03';
    private final static String NATIONAL_ACCOUNT_POLICY_TYPE_NAME = 'nationalAccount';

    private final static String LINE_LEVEL_ITEM_NAME = 'Item';
    private final static String LINE_SET_LEVEL_NAME = 'Set';
    private final static String LINE_SUBSET_LEVEL_NAME = 'Subset';
    private final static String LINE_CLASS_LEVEL_NAME = 'Class';
    private final static String LINE_CLASS_VENDOR_LEVEL_NAME = 'Class Vendor';
    private final static String LINE_BRAND_LEVEL_NAME = 'Brand';
    private final static String LINE_BRAND_VENDOR_LEVEL_NAME = 'Brand Vendor';

    private final static String DRAFT_STATUS_NAME = 'Draft';
    private final static String PENDING_APPROVAL_STATUS_NAME = 'Pend Appr';
    private final static String PUBLISHED_STATUS_NAME = 'Published';
    private final static String PENDING_CANCEL_STATUS_NAME = 'Pend Cancel';
    public  final static String REASON_CODE_FIELD_NAME = SObjectType.zpl__ContractLineItem__c.fields.Reason_Code__c.getName();

    @TestVisible
    private static final List<String> PRODUCT_UOM_FIELDS = new List<String> {
        AIQ_GenericSelector.PRODUCT_UOM_ID_FIELD_NAME,
        AIQ_GenericSelector.PRODUCT_UOM_NAME_FIELD,
        AIQ_GenericSelector.PRODUCT_UOM_PRODUCT_RELATION_FIELD_NAME,
        AIQ_GenericSelector.PRODUCT_UOM_CONVERSION_FACTOR_FIELD_NAME,
        AIQ_GenericSelector.PRODUCT_UOM_IS_PRICING_FIELD_NAME,
        AIQ_GenericSelector.PRODUCT_UOM_ALLOW_FOR_PRICING_FIELD_NAME,
        AIQ_GenericSelector.PRODUCT_UOM_IS_STOCK_OUM_FIELD_NAME,
        AIQ_GenericSelector.PRODUCT_UOM_ALLOW_FOR_QUANTITY_FIELD_NAME
    };

    @TestVisible
    private static final List<String> NATIONAL_ACCOUNT_PRICING_FIELDS = new List<String> {
        AIQ_GenericSelector.NATIONAL_ACCOUNT_PRICING_ID_FIELD_NAME,
        AIQ_GenericSelector.NATIONAL_ACCOUNT_PRICING_NAME_FIELD_NAME,
        AIQ_GenericSelector.NATIONAL_ACCOUNT_PRICING_GROUP_ID_FIELD_NAME,
        AIQ_GenericSelector.NATIONAL_ACCOUNT_PRICING_SYSTEM_CODE_FIELD_NAME
    };

    @TestVisible
    private static final List<String> CWT_ITEM_FIELDS = new List<String> {
        AIQ_GenericSelector.CWT_ITEM_ID_FIELD_NAME,
        AIQ_GenericSelector.CWT_ITEM_CBSSI_KEY_FIELD_NAME,
        AIQ_GenericSelector.CWT_ITEM_PRODUCT_FIELD_NAME
    };

    @TestVisible
    private static final List<String> NULLED_FIELDS = new List<String> {
        AIQ_ContractLineSelector.PRODUCT_FIELD,
        AIQ_ContractLineSelector.UOM_FIELD,
        AIQ_ContractLineSelector.ORDER_QTY_UOM_FIELD,
        AIQ_ContractLineSelector.QUANTITY_BREAK_UOM_FIELD,
        AIQ_ContractLineSelector.CUSTOMER_BASE_UOM_FIELD,
        AIQ_ContractLineSelector.PRICING_COST_FIELD,
        AIQ_ContractLineSelector.PUBLISHED_COST_FIELD,
        AIQ_ContractLineSelector.FUTURE_PRICING_COST_FIELD,
        AIQ_ContractLineSelector.FUTURE_PRICING_COST_DATE_FIELD,
        AIQ_ContractLineSelector.EXTERNAL_COST_DEVIATION_FIELD,
        AIQ_ContractLineSelector.EXTERNAL_COST_DEVIATION_DATE_FIELD,
        AIQ_ContractLineSelector.COST_REPLACE_FIELD,
        AIQ_ContractLineSelector.DISPLAY_CC2_COST_FIELD,
        AIQ_ContractLineSelector.CURRENT_STANDARD_COST_FIELD,
        AIQ_ContractLineSelector.NET_PRICE_FIELD,
        AIQ_ContractLineSelector.CONTRACT_PRICE_FIELD,
        AIQ_ContractLineSelector.PUBLISHED_PRICE_FIELD,
        AIQ_ContractLineSelector.PUBLISHED_PRICE_FIELD
    };

    private static final Map<String, Id> statusToRecordTypeMap = new Map<String, Id>{
        'Draft' => AIQ_Constants.CLI_RT_DRAFT_ID,
        'Pend Appr' => AIQ_Constants.CLI_RT_DRAFT_ID,
        'Pend Publ' => AIQ_Constants.CLI_RT_ACTIVE_ID,
        'Published' => AIQ_Constants.CLI_RT_ACTIVE_ID,
        'Pend Cancel' => AIQ_Constants.CLI_RT_ACTIVE_ID,
        'Deleted' => AIQ_Constants.CLI_RT_INACTIVE_ID,
        'Cancelled Camp' => AIQ_Constants.CLI_RT_INACTIVE_ID,
        'NA Conflict' => AIQ_Constants.CLI_RT_INACTIVE_ID,
        'Deleted Camp' => AIQ_Constants.CLI_RT_INACTIVE_ID,
        'Deleted By Quote' => AIQ_Constants.CLI_RT_INACTIVE_ID,
        'User Vacated' => AIQ_Constants.CLI_RT_INACTIVE_ID,
        'Camp Vacated' => AIQ_Constants.CLI_RT_INACTIVE_ID
    };

    @TestVisible
    private Map<Id, zpl__LineLevel__c> lineLevelsMap = new Map<Id, zpl__LineLevel__c>();
    @TestVisible
    private Map<Id, zpl__PolicyType__c> policyTypesMap = new Map<Id, zpl__PolicyType__c>();
    private static AIQZilliantConfiguration__c configuration = AIQZilliantConfiguration__c.getInstance();

    @TestVisible
    private String napPolicyTypeId {
        get {
            for (zpl__PolicyType__c policyType : policyTypesMap.values()) {
                if (policyType.zpl__PolicyTypeId__c == NATIONAL_ACCOUNT_POLICY_TYPE_NAME) {
                    return policyType.Id;
                }
            }

            throw new AIQ_AgreementLineItemTriggerHandlerException('Policy type is not available: nationalAccount');
        }
    }

    @TestVisible
    private List<String> itemLevelIds {
        get {
            List<String> itemLevelIds = new List<String>();
            for (zpl__LineLevel__c lineLevel : lineLevelsMap.values()) {
                if (lineLevel.Name == LINE_LEVEL_ITEM_NAME) {
                    itemLevelIds.add(lineLevel.Id);
                }
            }
            return itemLevelIds;
        }
    }

    @TestVisible
    private List<String> setSubsetLevelIds {
        get {
            List<String> setSubsetLevelIds = new List<String>();
            List<String> allowedNames = new List<String>{ LINE_SET_LEVEL_NAME, LINE_SUBSET_LEVEL_NAME };

            for (zpl__LineLevel__c lineLevel : lineLevelsMap.values()) {
                if (allowedNames.contains(lineLevel.Name)) {
                    setSubsetLevelIds.add(lineLevel.Id);
                }
            }
            return setSubsetLevelIds;
        }
    }

    @TestVisible
    private List<String> classBrandVendorLevelIds {
        get {
            List<String> classBrandVendorLevelIds = new List<String>();
            List<String> allowedNames = new List<String> { 
                LINE_CLASS_LEVEL_NAME, 
                LINE_CLASS_VENDOR_LEVEL_NAME, 
                LINE_BRAND_LEVEL_NAME, 
                LINE_BRAND_VENDOR_LEVEL_NAME
            };

            for (zpl__LineLevel__c lineLevel : lineLevelsMap.values()) {
                if (allowedNames.contains(lineLevel.Name)) {
                    classBrandVendorLevelIds.add(lineLevel.Id);
                }
            }
            return classBrandVendorLevelIds;
        }
    }

    @TestVisible 
    private AIQ_ContractLineSelector contractLineSelector;
    @TestVisible
    private AIQ_GenericSelector genericSelector;
    @TestVisible
    private AIQco_DatabaseUtil databaseUtil;
    @TestVisible
    private AIQ_CBSSIService cbssiService;

    public AIQ_AgreementLineItemTriggerHandler() {
        contractLineSelector = new AIQ_ContractLineSelector();
        genericSelector = new AIQ_GenericSelector();
        databaseUtil = new AIQco_DatabaseUtil();
        cbssiService = new AIQ_CBSSIService();
    }

    public void setAllLineLevelsMap() {
        List<zpl__LineLevel__c> lineLevels = genericSelector.queryAllLineLevels();
        
        for (zpl__LineLevel__c lineLevel : lineLevels) {
            this.lineLevelsMap.put(lineLevel.Id, lineLevel);
        }
    }

    public void setAllPolicyTypeMap() {
        List<zpl__PolicyType__c> policyTypes = genericSelector.queryAllPolicyType();
    
        for (zpl__PolicyType__c policyType : policyTypes) {
            this.policyTypesMap.put(policyType.Id, policyType);
        }
    }
    
    public void setDefaults(List<zpl__ContractLineItem__c> agreementLines) {
        for (zpl__ContractLineItem__c line : agreementLines) {
            line.ActiveAlignmentAttemptTime__c = datetime.now();
            if (line.zpl__EffectiveDate__c == null) {
                line.zpl__EffectiveDate__c = Date.today();
            }
            if (String.isBlank(line.LineSource__c)) {
                line.LineSource__c = USER_LINE_SCORE;
            }

            if (classBrandVendorLevelIds.contains(line.zpl__LineLevel__c)) {
                for (String field : NULLED_FIELDS) {
                    line.put(field, null);
                }
            }
        }
    }

    public void syncRecordType(List<zpl__ContractLineItem__c> agreementLines) {
        for (zpl__ContractLineItem__c line : agreementLines) {
            if (statusToRecordTypeMap.containsKey(line.zpl__Status__c)) {
                Id recordTypeId = statusToRecordTypeMap.get(line.zpl__Status__c);
                line.put(AIQ_ContractLineSelector.RECORD_TYPE_ID_FIELD, recordTypeId);
            } else {
                line.zpl__Status__c = AIQ_Constants.CLI_STATUS_DRAFT;
                line.RecordTypeId = AIQ_Constants.CLI_RT_DRAFT_ID;
            }
            if (line.RecordTypeId == AIQ_Constants.CLI_RT_INACTIVE_ID) {
                line.isCurrent__c = false;
            }
        }
    }

    public void setRepresentativeProduct(List<zpl__ContractLineItem__c> agreementLines) {
        if (agreementLines == null && agreementLines.isEmpty()) { return; }

        Map<String, List<zpl__ContractLineItem__c>> updateLinesMap = new Map<String, List<zpl__ContractLineItem__c>>();
        Set<String> cbssiKeys = new Set<String>();

        for (zpl__ContractLineItem__c line : agreementLines) {
            if (!setSubsetLevelIds.contains(line.zpl__LineLevel__c) || line.LineSource__c != USER_LINE_SCORE) { continue; }
            String cbssiKey = buildRepresentativeItemKey(line);

            cbssiKeys.add(cbssiKey);
            if (updateLinesMap.containsKey(cbssiKey)) {
                updateLinesMap.get(cbssiKey).add(line);
            } else {
                updateLinesMap.put(cbssiKey, new List<zpl__ContractLineItem__c> {line});
            }
        }

        if (updateLinesMap.isEmpty()) { return; }

        for (AIQ_CWTItem__c cwtItem : genericSelector.queryCWTItemByCBSSIKey(CWT_ITEM_FIELDS, cbssiKeys)) {
            for (zpl__ContractLineItem__c line : updateLinesMap.get(cwtItem.CBSSKey__c)) {
                line.zpl__Product__c = cwtItem.Product__c;
            }
        }
    }

    public void updateUOMs(List<zpl__ContractLineItem__c> agreementLines) {
        // Build list of required UOMs for query.
        // Need all UOMs for a lines given product id.
        // Need uniq list of each lines various UOMs where I need to check UOMs related product id against line
        List<String> productIds = new List<String>();
        List<Id> uomFilter = new List<Id>();

        for (zpl__ContractLineItem__c line : agreementLines) {
            // If product id is not set, ensure all UOMs with validation are null
            // Pricing UOM (zpl__UOM__c) does not have validation rules and can choose a UOM without a product id
            if (line.zpl__Product__c == null) {
                line.CW_UOM__c = null;
                line.QuantityBreakUOM__c = null;
                line.OrderQtyUOM__c = null;
                line.CustomerBaseUOM__c = null;
                continue;
            }

            // track current product id as we will use to query all UOMs available for the given product id
            productIds.add(line.zpl__Product__c);

            // track a distinct list of any uom across the other fields as product ids could be different
            if (line.CW_UOM__c != null && !uomFilter.contains(line.CW_UOM__c)) {
                uomFilter.add(line.CW_UOM__c);
            }
            if (line.QuantityBreakUOM__c != null && !uomFilter.contains(line.QuantityBreakUOM__c)) {
                uomFilter.add(line.QuantityBreakUOM__c);
            }
            if (line.zpl__UOM__c != null && !uomFilter.contains(line.zpl__UOM__c)) {
                uomFilter.add(line.zpl__UOM__c);
            }
            if (line.OrderQtyUOM__c != null && !uomFilter.contains(line.OrderQtyUOM__c)) {
                uomFilter.add(line.OrderQtyUOM__c);
            }
            if (line.CustomerBaseUOM__c != null && !uomFilter.contains(line.CustomerBaseUOM__c)) {
                uomFilter.add(line.CustomerBaseUOM__c);
            }
        }

        // Get all required UOMs
        Map<Id, zpl__ProductUOM__c> uomMap = genericSelector.queryUOMMapByCondition(
            PRODUCT_UOM_FIELDS,
            getProductUOMCondition(uomFilter, productIds)
        );

        // Create Map of Maps to look up UOMs by product id then UOM suffix (Name field)
        Map<Id, Map<String, zpl__ProductUOM__c>> uomLookup = new Map<Id, Map<String, zpl__ProductUOM__c>>();
        for (zpl__ProductUOM__c uom : uomMap.values()) {
            if (!uomLookup.containsKey(uom.zpl__Product__c)) {
                uomLookup.put(uom.zpl__Product__c, new Map<String, zpl__ProductUOM__c>());
            }
            uomLookup.get(uom.zpl__Product__c).put(uom.Name, uom);
        }

        for (zpl__ContractLineItem__c line : agreementLines) {
            // if no UOMs exist at all for the selected product, reset all UOM fields
            // Pricing UOM (zpl__UOM__c) does not have validation rules and can choose a UOM without a product id
            if (!uomLookup.containsKey(line.zpl__Product__c)) {
                line.CW_UOM__c = null;
                line.QuantityBreakUOM__c = null;
                line.OrderQtyUOM__c = null;
                line.CustomerBaseUOM__c = null;
                continue;
            }

            // Several UOM will follow the same pattern.  If UOM is not null, check to see if its the same base product id as the product id on the line.
            // If the UOM is already set and matches the product id of the line, leave it alone.
            // If its UOM does not match product id try and find the same suffixed\named UOM in new product id. If not found null the value
            // After the above validation\reset, if the UOM is null look for a viable default UOM

            // if qty break uom is populated and does not match the product id of the line, update or null out UOM
            if (line.zpl__UOM__c != null && uomMap.get(line.zpl__UOM__c).zpl__Product__c != line.zpl__Product__c) {
                String uomName = uomMap.get(line.zpl__UOM__c).Name; // Get the current UOM Name part (i.e. CS, M, EA, CW, ...)
                // Get UOM in the current product for same name part
                zpl__ProductUOM__c newUOM = uomLookup.get(line.zpl__Product__c).containsKey(uomName)
                    ? uomLookup.get(line.zpl__Product__c).get(uomName)
                    : null;
                if (newUOM != null && !newUOM.Allow_For_Pricing__c) {
                    newUom = null; // New UOM must be flagged to allow for this field
                }

                line.zpl__UOM__c = newUOM == null ? null : newUom.Id;
            }

            // If zpl__UOM__c is null find a valid uom with the lowest conversion factor
            if (line.zpl__UOM__c == null) {
                for (zpl__ProductUOM__c uom : uomLookup.get(line.zpl__Product__c).values()) {
                    Decimal currentFactor = null;

                    // zpl__UOM__c must be a stocking UOM and Allow_For_Quantity must be true
                    if (uom.Allow_For_Pricing__c) {
                        if (line.zpl__UOM__c == null || (currentFactor != null && uom.zpl__ConversionFactor__c < currentFactor)) {
                            line.zpl__UOM__c = uom.Id;
                            currentFactor = uom.zpl__ConversionFactor__c;
                        }
                    }
                }
            }

            // if qty break uom is populated and does not match the product id of the line, update or null out UOM
            if (line.QuantityBreakUOM__c != null && uomMap.get(line.QuantityBreakUOM__c).zpl__Product__c != line.zpl__Product__c) {
                String uomName = uomMap.get(line.QuantityBreakUOM__c).Name; // Get the current UOM Name part (i.e. CS, M, EA, CW, ...)
                // Get UOM in the current product for same name part
                zpl__ProductUOM__c newUOM = uomLookup.get(line.zpl__Product__c).containsKey(uomName)
                    ? uomLookup.get(line.zpl__Product__c).get(uomName)
                    : null;
                if (newUOM != null && !newUOM.Allow_For_Quantity__c) {
                    newUom = null; // New UOM must be flagged to allow for this field
                }
                line.QuantityBreakUOM__c = newUOM == null ? null : newUom.Id;
            }

            // If QuantityBreakUOM__c is null find a valid uom with the lowest conversion factor
            if (line.QuantityBreakUOM__c == null) {
                for (zpl__ProductUOM__c uom : uomLookup.get(line.zpl__Product__c).values()) {
                    Decimal currentFactor = null;

                    // QuantityBreakUOM__c must be a stocking UOM and Allow_For_Quantity must be true
                    if (uom.Allow_For_Quantity__c) {
                        if (line.QuantityBreakUOM__c == null || (currentFactor != null && uom.zpl__ConversionFactor__c < currentFactor)) {
                            line.QuantityBreakUOM__c = uom.Id;
                            currentFactor = uom.zpl__ConversionFactor__c;
                        }
                    }
                }
            }

            // If CW UOM exists set field, if not set to null
            line.CW_UOM__c = uomLookup.get(line.zpl__Product__c).containsKey(PRODUCT_UOM_CW)
                ? uomLookup.get(line.zpl__Product__c).get(PRODUCT_UOM_CW).Id
                : null;

            // If CustomerBaseUOM__c does not have a default. if it does not match and cannot not find the same uom in new product id, just null it out
            if (line.CustomerBaseUOM__c != null && uomMap.get(line.CustomerBaseUOM__c).zpl__Product__c != line.zpl__Product__c) {
                String uomName = uomMap.get(line.CustomerBaseUOM__c).Name;
                line.CustomerBaseUOM__c = uomLookup.get(line.zpl__Product__c).containsKey(uomName)
                    ? uomLookup.get(line.zpl__Product__c).get(uomName).Id
                    : null;
            }

            // Not sure what OrderQtyUOM__c really is, seems to be the same value as zpl__UOM__c
            // After talking with Andriy we think this is some user driven field. Deal Manager does not use it.
            // Treat like CustomerBaseUOM, update it with the same UOM for new product if exists, otherwise null it out
            if (line.OrderQtyUOM__c != null && uomMap.get(line.OrderQtyUOM__c).zpl__Product__c != line.zpl__Product__c) {
                String uomName = uomMap.get(line.OrderQtyUOM__c).Name;
                line.OrderQtyUOM__c = uomLookup.get(line.zpl__Product__c).containsKey(uomName)
                    ? uomLookup.get(line.zpl__Product__c).get(uomName).Id
                    : null;
            }
        }
    }

    public void setNationalAccountPolicyType(List<zpl__ContractLineItem__c> agreementLines) {
        List<zpl__ContractLineItem__c> targetLines = new List<zpl__ContractLineItem__c>();
        List<String> napGroupIds = new List<String>();
        List<String> skus = new List<String>();
        List<String> systems = new List<String>();

        for (zpl__ContractLineItem__c agrLine : agreementLines) {
            if (itemLevelIds.contains(agrLine.zpl__LineLevel__c) &&
                !String.isBlank(agrLine.SKU__c) &&
                !String.isBlank(agrLine.National_Account__c)
            ) {
                targetLines.add(agrLine);
                napGroupIds.add(agrLine.National_Account__c);
                skus.add(agrLine.SKU__c);
                systems.add(agrLine.System__c == SYSTEM_CODE_SW ? SYSTEM_CODE_03 : agrLine.System__c);
            } else {
                agrLine.IsNAPriced__c = false;
            }
        }
        if (targetLines.size() == 0) {
            return;
        }

        Map<String, NationalAccountsPricing__c> napRecs = new Map<String, NationalAccountsPricing__c>();
        for (NationalAccountsPricing__c nap :  genericSelector.queryNationalAccountsPricingByCondition(
                    NATIONAL_ACCOUNT_PRICING_FIELDS,
                    getNationalAccountPricingCondition(napGroupIds, skus, systems)
                )
            ) {
            napRecs.put((nap.SystemCode__c == SYSTEM_CODE_03 ? SYSTEM_CODE_SW : nap.SystemCode__c) + nap.NationalAccountGroupID__c + nap.Name, nap);
        }

        for (zpl__ContractLineItem__c line : targetLines) {
            String key = line.System__c + line.National_Account__c + line.SKU__c;
            NationalAccountsPricing__c nap = napRecs.get(key);
            if (nap != null) {
                line.IsNAPriced__c = true;
                line.zpl__PolicyValue__c = null;
                line.Net_Price__c = 0;
                line.zpl__PolicyType__c = napPolicyTypeId;
            } else {
                line.IsNAPriced__c = false;
            }
        }
    }

    public void alignLineGroupBeforePublish(List<zpl__ContractLineItem__c> newLines) {
        alignLineGroupBeforePublish(newLines, null);
    }

    public void alignLineGroupBeforePublish(List<zpl__ContractLineItem__c> newLines, Map<Id, zpl__ContractLineItem__c> oldLines) {
        List<zpl__ContractLineItem__c> linesToAlignBeforePublish = new List<zpl__ContractLineItem__c>();
        Set<Id> policyTypeIds = new Set<Id>();
        Set<Id> uomIds = new Set<Id>();
        for (zpl__ContractLineItem__c newLine : newLines) {
            zpl__ContractLineItem__c oldLine = (oldLines == null || oldLines.isEmpty()) ? null : oldLines.get(newLine.Id);
            if (newLine.zpl__Status__c != DRAFT_STATUS_NAME && !lineSubmittedByUser(newLine, oldLine) && !lineExecutedByCampaign(newLine, oldLine)) {
                continue;
            }
            linesToAlignBeforePublish.add(newLine);
            policyTypeIds.add(newLine.zpl__PolicyType__c);
            uomIds.add(newLine.zpl__UOM__c);
        }
        if (linesToAlignBeforePublish.isEmpty()) {
            return;
        }

        addMissedFields(linesToAlignBeforePublish, policyTypeIds, uomIds);
        cbssiService.alignBeforePublish(linesToAlignBeforePublish);
        
    }

    public void alignLineGroupAfterPublish(List<zpl__ContractLineItem__c> newLines) {
        alignLineGroupAfterPublish(newLines, null);
    }

    public void alignLineGroupAfterPublish(List<zpl__ContractLineItem__c> newLines, Map<Id, zpl__ContractLineItem__c> oldLines) {
        List<zpl__ContractLineItem__c> linesToAlignAfterPublish = new List<zpl__ContractLineItem__c>();
        for (zpl__ContractLineItem__c newLine : newLines) {
            zpl__ContractLineItem__c oldLine = (oldLines == null || oldLines.isEmpty()) ? null : oldLines.get(newLine.Id);
            if (!linePublishedByUser(newLine, oldLine) && !lineExecutedByCampaign(newLine, oldLine)) {
                continue;
            }
            linesToAlignAfterPublish.add(newLine);
        }
        if (linesToAlignAfterPublish.isEmpty()) {
            return;
        }
        try {
            if (Trigger.isBefore) {
                cbssiService.alignAfterPublish(linesToAlignAfterPublish);
            } else {
                databaseUtil.updateRecords(cbssiService.alignAfterPublish(linesToAlignAfterPublish));
            }
            
        } catch (Exception e) {
            AIQco_Logger.getInstance().log(e);
            newLines[0].addError(e.getMessage());
            throw new AIQ_AgreementLineItemTriggerHandlerException(e.getMessage());
        }
    }

    public void requireReason(Map<Id, zpl__ContractLineItem__c> newMap, Map<Id, zpl__ContractLineItem__c> oldMap) {
        List<zpl__ContractLineItem__c> contractLineItems = new List<zpl__ContractLineItem__c>();

        for (zpl__ContractLineItem__c contractLineItem : newMap.values()) {
            zpl__ContractLineItem__c contractLineItemOld = oldMap.get(contractLineItem.Id);

            Boolean isReasonCodeNotSelected = contractLineItem.Reason_Code__c == null
                ? true
                : contractLineItem.Reason_Code__c.equals(NOT_SELECTED);
            Boolean isDraft = contractLineItem.zpl__Status__c.equals(AIQ_Constants.CLI_STATUS_DRAFT);
            Boolean isNotRejected = !contractLineItemOld.zpl__Status__c.equals(AIQ_Constants.CLI_STATUS_PEND_APPR);
            Boolean pvChanged = (contractLineItem.zpl__PolicyValue__c == null ||
                contractLineItemOld.zpl__PolicyValue__c == null
                ? true
                : contractLineItem.zpl__PolicyValue__c != contractLineItemOld.zpl__PolicyValue__c);

            Boolean reasonChanged =
                contractLineItemOld.Reason_Code__c != null && !contractLineItem.Reason_Code__c.equals(contractLineItemOld.Reason_Code__c);

            if (isDraft && isNotRejected && isReasonCodeNotSelected) {
                if (isPriceDecrease(contractLineItem) && (pvChanged || reasonChanged)) {
                    if (!Test.isRunningTest()) {
                        contractLineItem.addError(REASON_CODE_FIELD_NAME, REASON_CODE_ERROR_MESSAGE);
                    }
                } else if (String.isNotBlank(contractLineItem.CampaignAppealedLine__c)) {
                    contractLineItems.add(contractLineItem);
                }
            }
        }
        if (contractLineItems.isEmpty()) { return; }
            
        Map<Id, zpl__ContractLineItem__c> campaignAppealedLineMap = getCampaignAppealedLineMap(contractLineItems);
        if (campaignAppealedLineMap == null || campaignAppealedLineMap.isEmpty()) { return; } 

        for (zpl__ContractLineItem__c contractLineItem : contractLineItems) {
            zpl__ContractLineItem__c contractLineItemOld = oldMap.get(contractLineItem.Id);
            if (isStartDateDelayed(contractLineItem, campaignAppealedLineMap.get(contractLineItem.Id), contractLineItemOld)) {
                if (!Test.isRunningTest()) {
                    contractLineItem.addError(REASON_CODE_FIELD_NAME, REASON_CODE_ERROR_MESSAGE);
                }
            }
        }
    }

    public void runSyncDown() {
        if (Test.isRunningTest()) { return; }
        if (!(Boolean) configuration.get(SYNC_DOWN_BYPASS_CONFIGURATION_NAME)) { return; }
        if (UserInfo.getUserName().equals(System.Label.AIQDownSyncBypassIntegrationUser)) { return; }

        zpf.GenericSynchronizedDomainObject.triggerHandler(AIQ_ContractLineSelector.CONTRACT_LINE_ITEM_ID_FIELD); 
    }

    public void deleteDraftLines(Map<Id, zpl__ContractLineItem__c> newMap, Map<Id, zpl__ContractLineItem__c> oldMap) {
        List<zpl__ContractLineItem__c> updateLines = new List<zpl__ContractLineItem__c>();
        List<Id> linesToDelete = new List<Id>();
        List<Id> appealedLines = new List<Id>();

        for (zpl__ContractLineItem__c line : newMap.values()) {
            zpl__ContractLineItem__c oldLine = oldMap.get(line.Id);

            if (line.zpl__Status__c != 'Deleted' && line.RecordTypeId == AIQ_Constants.CLI_RT_INACTIVE_ID && oldLine.RecordTypeId == AIQ_Constants.CLI_RT_DRAFT_ID) {
                if (line.CampaignAppealedLine__c != null) {
                    appealedLines.add(line.CampaignAppealedLine__c);
                }
                linesToDelete.add(line.Id);
            }
        }

        if (appealedLines.size() > 0) {
            for (zpl__ContractLineItem__c line : getAppealedLines(appealedLines)) {
                line.zpl__Status__c = PUBLISHED_STATUS_NAME;
                updateLines.add(line);
            }
        }

        Savepoint sp = Database.setSavepoint();
        try {
            if (linesToDelete.size() > 0) {
                databaseUtil.deleteRecords(this.contractLineSelector.queryContractLinesById(linesToDelete));
            }
            if (updateLines.size() > 0) {
                databaseUtil.updateRecords(updateLines);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw zpf.AuraHandledExceptionUtil.handleException(e);
        }
    }

    private static Boolean lineSubmittedByUser(zpl__ContractLineItem__c newLine, zpl__ContractLineItem__c oldLine) {
        return newLine.zpl__Status__c == PENDING_APPROVAL_STATUS_NAME && oldLine != null && oldLine.zpl__Status__c != newLine.zpl__Status__c;
    }

    private static Boolean linePublishedByUser(zpl__ContractLineItem__c newLine, zpl__ContractLineItem__c oldLine) {
        return newLine.zpl__Status__c == PUBLISHED_STATUS_NAME && oldLine != null && oldLine.zpl__Status__c != newLine.zpl__Status__c;
    }

    private static Boolean lineExecutedByCampaign(zpl__ContractLineItem__c newLine, zpl__ContractLineItem__c oldLine) {
        return newLine.zpl__Status__c == PUBLISHED_STATUS_NAME && oldLine == null && newLine.LineSource__c == 'C';
    }

    private void addMissedFields(List<zpl__ContractLineItem__c> linesToAlignBeforePublish, Set<Id> policyTypeIds, Set<Id> uomIds) {
        Map<Id, zpl__PolicyType__c> policyTypeMap = new Map<Id, zpl__PolicyType__c>(genericSelector.queryPolicyTypeByIds(policyTypeIds));
        Map<Id, zpl__ProductUOM__c> uomMap = new Map<Id, zpl__ProductUOM__c>(genericSelector.queryUOMByIds(uomIds));
        zpl__PolicyType__c policyType;
        zpl__ProductUOM__c uom;
        for (zpl__ContractLineItem__c line : linesToAlignBeforePublish) {
            policyType = policyTypeMap.get(line.zpl__PolicyType__c);
            uom = uomMap.get(line.zpl__UOM__c);
            line.zpl__PolicyType__r = policyType == null ? new zpl__PolicyType__c() : policyType;
            line.zpl__UOM__r = uom == null ? new zpl__ProductUOM__c() : uom;
        }
    }

    private Map<Id, zpl__ContractLineItem__c> getCampaignAppealedLineMap(List<zpl__ContractLineItem__c> contractLineItems) {
        List<Id> linesIds = new List<Id>();
        Map<Id, zpl__ContractLineItem__c> lineMap = new  Map<Id, zpl__ContractLineItem__c>();
        List<zpl__ContractLineItem__c> selectedLines = new List<zpl__ContractLineItem__c>();

        for (zpl__ContractLineItem__c contractLineItem : contractLineItems) {
            linesIds.add(contractLineItem.Id);
        }
        selectedLines = this.contractLineSelector.queryContractLinesById(
            new List<String> {
                AIQ_ContractLineSelector.ID_FIELD,
                AIQ_ContractLineSelector.EFFECTIVE_DATE_FIELD,
                AIQ_ContractLineSelector.CONTRACT_LINE_CAMPAIGN_APPEALED_EFFECTIVE_DATE
            },
            linesIds
        );
        for (zpl__ContractLineItem__c line : selectedLines) {
            lineMap.put(line.Id, line);
        }

        return lineMap;
    }

    private static Boolean isPriceDecrease(zpl__ContractLineItem__c contractLineItem) {
        return contractLineItem.PriceDecreaseFlag__c;
    }

    private static Boolean isStartDateDelayed(
        zpl__ContractLineItem__c contractLineItem,
        zpl__ContractLineItem__c campaignAppealedLine,
        zpl__ContractLineItem__c contractLineItemOld
    ) {
        Boolean isDelay =
            campaignAppealedLine.CampaignAppealedLine__r.zpl__EffectiveDate__c.daysBetween(contractLineItem.zpl__EffectiveDate__c) >
            configuration.StartDateHorizon__c;
        Boolean isCmpStartNotReached = campaignAppealedLine.CampaignAppealedLine__r.zpl__EffectiveDate__c > Date.today();
        Boolean reasonChanged =
            contractLineItemOld.Reason_Code__c != null && !contractLineItem.Reason_Code__c.equals(contractLineItemOld.Reason_Code__c);
        return isDelay && (isCmpStartNotReached || reasonChanged);
    }

    private String buildRepresentativeItemKey(zpl__ContractLineItem__c line) {
        String cbssiKey =
            line.System__c +
            line.Division_Code2__c +
            line.Class__c +
            line.Brand__c +
            line.Set__c +
            (line.Subset__c != null ? line.Subset__c : '');
        return cbssiKey;
    }
    
    private List<zpl__ContractLineItem__c> getAppealedLines(List<Id> appealedLines) {
        if (appealedLines.isEmpty()) {
            return new List<zpl__ContractLineItem__c>();
        }
        zal.Condition condition = getAppealedLinesCondition(appealedLines);
        List<zpl__ContractLineItem__c> lines = this.contractLineSelector.queryContractLinesByCondition(
            new List<String> {AIQ_ContractLineSelector.ID_FIELD, AIQ_ContractLineSelector.STATUS_FIELD},
            condition
        );
        
        return lines;
    }

    private zal.AndCondition getAppealedLinesCondition(List<Id> appealedLines) {
        zal.AndCondition andCondition = new zal.AndCondition();
        andCondition.add(new zal.SetCondition(AIQ_ContractLineSelector.ID_FIELD, zal.Operator.INX,appealedLines));
        andCondition.add(new zal.FieldCondition(AIQ_ContractLineSelector.STATUS_FIELD, zal.Operator.EQUALS, PENDING_CANCEL_STATUS_NAME));
        return andCondition;
    }

    private zal.OrCondition getProductUOMCondition(List<Id> uomFilter, List<String> productIds) {
        zal.OrCondition orCondition = new zal.OrCondition();
        if (uomFilter != null && ! uomFilter.isEmpty()) {
            orCondition.add(new zal.SetCondition('Id', zal.Operator.INX, uomFilter));
        }
        if (productIds != null && ! productIds.isEmpty()) {
            orCondition.add(new zal.SetCondition(AIQ_GenericSelector.PRODUCT_UOM_PRODUCT_RELATION_FIELD_NAME, zal.Operator.INX, productIds));
        }
        return orCondition;
    }

    private zal.AndCondition getNationalAccountPricingCondition(List<String> napGroupIds, List<String> skus, List<String> systems) {
        zal.AndCondition andCondition = new zal.AndCondition();
        if (napGroupIds.isEmpty() || skus.isEmpty() || systems.isEmpty()) {
            return andCondition;
        }
        andCondition.add(new zal.SetCondition(AIQ_GenericSelector.NATIONAL_ACCOUNT_PRICING_GROUP_ID_FIELD_NAME, zal.Operator.INX, napGroupIds));
        andCondition.add(new zal.SetCondition(AIQ_GenericSelector.NATIONAL_ACCOUNT_PRICING_NAME_FIELD_NAME, zal.Operator.INX, skus));
        andCondition.add(new zal.SetCondition(AIQ_GenericSelector.NATIONAL_ACCOUNT_PRICING_SYSTEM_CODE_FIELD_NAME, zal.Operator.INX, systems));
        return andCondition;
    }
}
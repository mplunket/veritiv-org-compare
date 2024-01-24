public with sharing class AIQ_PublishLine extends AIQqa_AbstractQuickAction implements AIQqa_QuickActionInterface {
    @TestVisible
    private static final List<String> CONTRACT_LINES_QUERY_FIELDS = new List<String>{
        AIQ_ContractLineSelector.CONTRACT_FIELD,
        AIQ_ContractLineSelector.STATUS_FIELD,
        AIQ_ContractLineSelector.RECORD_TYPE_ID_FIELD,
        AIQ_ContractLineSelector.PUBLISHED_BY_FIELD,
        AIQ_ContractLineSelector.PUBLISH_DATE_FIELD,
        AIQ_ContractLineSelector.EFFECTIVE_DATE_FIELD,
        AIQ_ContractLineSelector.ACCOUNT_SALES_REP_USER_ID_FIELD,
        AIQ_ContractLineSelector.PRICING_COST_FIELD,
        AIQ_ContractLineSelector.CAMPAIGN_APPEALED_LINE_FIELD,
        AIQ_ContractLineSelector.FUTURE_PRICING_COST_DATE_FIELD,
        AIQ_ContractLineSelector.FUTURE_PRICING_COST_FIELD,
        AIQ_ContractLineSelector.PUBLISHED_COST_FIELD,
        AIQ_ContractLineSelector.PENDING_APPROVAL_DATE_FROM_FIELD,
        AIQ_ContractLineSelector.CBSS_ITEM_GROUPING_KEY_FIELD,
        AIQ_ContractLineSelector.CONTRACT_LINE_ITEM_ID_FIELD,
        AIQ_ContractLineSelector.UOM_FIELD,
        AIQ_ContractLineSelector.POLICY_TYPE_FIELD,
        AIQ_ContractLineSelector.IS_CURRENT_FIELD,
        AIQ_ContractLineSelector.CONTRACT_LINE_UOM_CONVERSION_FACTOR_FIELD_NAME,
        AIQ_ContractLineSelector.CONTRACT_LINE_POLICY_TYPE_POLICY_TYPE_ID_FIELD_NAME,
        AIQ_ContractLineSelector.CONTRACT_LINE_CAMPAIGN_CONTRACT_LINE_ITEM_ID_FIELD_NAME,
        AIQ_ContractLineSelector.NET_PRICE_FIELD,
        AIQ_ContractLineSelector.POLICY_VALUE_FIELD
    };
    @TestVisible
    private static final String SUCCESS = 'success';
    @TestVisible
    private static final String WARNING = 'warning';
    @TestVisible
    private static final String SCREEN_MODE = 'DEFAULT';
    @TestVisible
    private static final String HEADER_TITLE_LABEL = 'AIQPublishLineHeader';
    @TestVisible
    private static final String BODY_MESSAGE_LABEL = 'AIQPublishLineContent';
    @TestVisible
    private static final String SVG_ICON = 'action:update';
    @TestVisible
    private static final String QA_FIELD_NAME = SObjectType.zpl__ContractLineItem__c.fields.Published_By__c.getName();
    @TestVisible
    private static final String QA_FIELD_LABEL = 'On Behalf Of SalesRep Owning Ship To';
    @TestVisible
    private static final String CLI_STATUS_DRAFT = 'Draft';
    @TestVisible
    private static final String CLI_STATUS_PEND_APPR = 'Pend Appr';
    @TestVisible
    private static final String CLI_STATUS_PEND_CANCEL = 'Pend Cancel';
    @TestVisible
    private static final String CLI_RT_DRAFT_ID = Schema.SObjectType.zpl__ContractLineItem__c
        .getRecordTypeInfosByDeveloperName()
        .get('Draft')
        .getRecordTypeId();
    @TestVisible
    private List<zpl__ContractLineItem__c> contractLineItemsToUpdate;
    @TestVisible
    private Integer entireBatchSize;
    @TestVisible
    private Boolean hasPublishedLine = false;
    @TestVisible
    private AIQ_ContractLineSelector contractLineSelector;
    @TestVisible
    private AIQ_GenericSelector genericSelector;
    @TestVisible
    private AIQco_DatabaseUtil databaseUtil;
    @TestVisible
    private AIQ_CBSSIService cbssiService;
    private AIQqa_QuickActionDTO actionDTO;

    public class AIQ_PublishLineException extends Exception {
    }

    public AIQ_PublishLine() {
        contractLineSelector = new AIQ_ContractLineSelector();
        genericSelector = new AIQ_GenericSelector();
        contractLineItemsToUpdate = new List<zpl__ContractLineItem__c>();
        databaseUtil = new AIQco_DatabaseUtil();
        cbssiService = new AIQ_CBSSIService();
    }

    public override AIQqa_QuickActionDTO initialize(List<Id> recordId, String actionName) {
        List<zpl__ContractLineItem__c> contractLineItems = contractLineSelector.queryContractLinesById(
            CONTRACT_LINES_QUERY_FIELDS,
            new List<Id>{ recordId.get(0) }
        );
        AIQco_Precondition.checkArgument(
            contractLineItems.isEmpty() || contractLineItems.get(0).zpl__Contract__r.AccountId == null,
            Label.aiq_InvalidArgumentsErrorMessage
        );
        AIQqa_QuickActionUtil.ActionDtoBuilder dtoBuilder = AIQqa_QuickActionUtil.getDialogActionDtoBuilder(recordId, actionName)
            .setHeaderTitle(HEADER_TITLE_LABEL)
            .setScreenMode(SCREEN_MODE)
            .setBodyMessage(BODY_MESSAGE_LABEL)
            .setSvgIcon(SVG_ICON)
            .setFieldsToReset(getFieldsToReset());

        Id accountId = contractLineItems.get(0).zpl__Contract__r.AccountId;
        List<User> accOwnerUsers = genericSelector.queryUsersByIds(getAccountOwnerIds(accountId));
        User currentUser = genericSelector.queryCurrentUser();

        List<AIQqa_QuickActionDTO.ComboboxOption> comboboxOptions = new List<AIQqa_QuickActionDTO.ComboboxOption>();
        List<String> adminProfiles = getAdminProfiles();
        if (adminProfiles.contains(currentUser.Profile.Name) && !accOwnerUsers.isEmpty()) {
            for (User u : accOwnerUsers) {
                comboboxOptions.add(new AIQqa_QuickActionDTO.ComboboxOption(u.Name, u.Id));
            }
            dtoBuilder.getFieldBuilder(QA_FIELD_NAME).setOptions(comboboxOptions).setIsRendered(true);
        }
        this.actionDTO = dtoBuilder.build();
        return this.actionDTO;
    }

    public override AIQqa_QuickActionDTO runPrimary(AIQqa_QuickActionDTO actionDTO) {
        this.actionDTO = actionDTO;
        AIQco_Precondition.checkArgument(
            this.actionDTO.recordId == null || this.actionDTO.recordId.isEmpty(),
            Label.aiq_InvalidArgumentsErrorMessage
        );
        Savepoint sp = Database.setSavepoint();
        try {
            setLinesForUpdate(contractLineSelector.queryContractLinesById(CONTRACT_LINES_QUERY_FIELDS, this.actionDTO.recordId));
            if (contractLineItemsToUpdate.size() > 0) {
                databaseUtil.updateRecords(contractLineItemsToUpdate);
            }
            setCustomMessage();
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AIQ_PublishLineException(e.getMessage());
        }
        return this.actionDTO;
    }

    private void setLinesForUpdate(List<zpl__ContractLineItem__c> contractLineItems) {
        AIQco_Precondition.checkArgument(contractLineItems == null || contractLineItems.isEmpty(), Label.aiq_InvalidArgumentsErrorMessage);
        Set<Id> campAppealedLineIds = new Set<Id>();
        Id publisherId = this.actionDTO.getField(QA_FIELD_NAME)?.defaultValue;
        for (zpl__ContractLineItem__c line : contractLineItems) {
            if (line.zpl__Status__c != CLI_STATUS_DRAFT) {
                hasPublishedLine = true;
                continue;
            }
            setPendingApproveLine(line, publisherId);
            if (line.CampaignAppealedLine__c != null && !campAppealedLineIds.contains(line.CampaignAppealedLine__c)) {
                setPendingCancelLine(line);
                campAppealedLineIds.add(line.CampaignAppealedLine__c);
            }
        }
    }

    private void setPendingApproveLine(zpl__ContractLineItem__c line, Id publisherId) {
        line.RecordTypeId = CLI_RT_DRAFT_ID;
        line.zpl__Status__c = CLI_STATUS_PEND_APPR;
        line.Published_By__c = (publisherId == null
            ? line.zpl__Contract__r.Account.Primary_Sales_Rep_Name__r.SF_userid__r.Id
            : publisherId);
        line.Publish_Date__c = System.now();
        line.PricingCost__c = (line.FuturePricingCostDate__c != null &&
            AIQ_CommonUtil.nullToZero(line.FuturePricingCost__c) != 0 &&
            line.zpl__EffectiveDate__c >= line.FuturePricingCostDate__c
            ? line.FuturePricingCost__c
            : line.PricingCost__c);
        line.PublishedCost__c = line.PricingCost__c;
        line.Pending_Approval_Date_From__c = System.now();
        line.Rejected_By__c = null;
        line.Rejected_Date__c = null;
        if (line.zpl__EffectiveDate__c == null || line.zpl__EffectiveDate__c < System.today()) {
            line.zpl__EffectiveDate__c = System.today();
        }
        contractLineItemsToUpdate.add(line);
    }

    private void setPendingCancelLine(zpl__ContractLineItem__c campAppealedLine) {
        zpl__ContractLineItem__c line = new zpl__ContractLineItem__c();
        line.CBSSItemGroupingKey__c = campAppealedLine.CBSSItemGroupingKey__c;
        line.Id = campAppealedLine.CampaignAppealedLine__c;
        line.zpl__ContractLineItemId__c = campAppealedLine.CampaignAppealedLine__r.zpl__ContractLineItemId__c;
        line.zpl__Status__c = CLI_STATUS_PEND_CANCEL;
        line.Inactivated_By__c = UserInfo.getUserId();
        line.Inactivated_Date__c = System.now();
        contractLineItemsToUpdate.add(line);
    }

    private void setCustomMessage() {
        AIQqa_QuickActionUtil.CustomMessageBuilder buildMsg = new AIQqa_QuickActionUtil.CustomMessageBuilder();
        buildMsg.setType(SUCCESS);
        if (contractLineItemsToUpdate.isEmpty()) {
            buildMsg.setMessages(new Set<String>{ Label.AIQPublishRejected }).setType(WARNING);
        } else if (hasPublishedLine) {
            buildMsg.setMessages(new Set<String>{ Label.AIQ_PublishOnlyDraft });
        } else {
            buildMsg.setMessages(new Set<String>{ Label.AIQPublishSuccess });
        }
        new AIQqa_QuickActionUtil.ActionDtoBuilder(this.actionDTO).setCustomMessage(buildMsg.build()).build();
    }

    private List<String> getAdminProfiles() {
        String rawAdminProfiles = AIQZilliantConfiguration__c.getInstance().SalesAdminProfiles__c;
        String adminProfiles = '';
        if (!String.isBlank(rawAdminProfiles)) {
            adminProfiles = rawAdminProfiles.replaceAll('(\\r|\\n)+', ',');
        }
        String[] adminProfilesList = adminProfiles.trim().split(',');
        return adminProfilesList;
    }

    private List<Id> getAccountOwnerIds(Id accountId) {
        List<Ship_To__c> shipTos = genericSelector.queryShipToByBillToAccount(accountId);
        List<Id> accOwnerIds = new List<Id>();
        for (Ship_To__c shipTo : shipTos) {
            if (!accOwnerIds.contains(shipTo.Account_Owner__c)) {
                accOwnerIds.add(shipTo.Account_Owner__c);
            }
        }
        return accOwnerIds;
    }

    private List<AIQqa_QuickActionDTO.FieldToReset> getFieldsToReset() {
        return new List<AIQqa_QuickActionDTO.FieldToReset>{
            new AIQqa_QuickActionUtil.FieldBuilder(AIQqa_DisplayMode.COMBOBOX_DISPLAY_MODE)
                .setApiFieldName(QA_FIELD_NAME)
                .setFieldLabel(QA_FIELD_LABEL)
                .setIsRendered(false)
                .setPosition('1.1')
                .build()
        };
    }
}
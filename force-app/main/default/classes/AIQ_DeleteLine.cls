public with sharing class AIQ_DeleteLine extends AIQqa_AbstractQuickAction implements AIQqa_QuickActionInterface {

    public class AIQ_DeleteLineException extends Exception {}

    @TestVisible
    private final static String SUCCESS = 'success';    
    @TestVisible
    private final static String ERROR = 'error';    
    @TestVisible
    private final static String ACTIVE = 'Active';
    @TestVisible
    private final static String PENDING_CANCEL = 'Pend Cancel';
    @TestVisible
    private final static String INACTIVE = 'Inactive';   
    @TestVisible
    private final static String DRAFT = 'Draft';
    @TestVisible
    private final static String PUBLISHED = 'Published';
    @TestVisible
    private final static String USER_VACATED = 'User Vacated';    
    @TestVisible
    private final static String HEADER_TITLE_LABEL = 'AIQDeleteLineHeader';    
    @TestVisible
    private final static String BODY_MESSAGE_LABEL = 'AIQVacatePricingContent';
    @TestVisible
    private static final String SVG_ICON = 'action:delete';
    @TestVisible
    private static final String SCREEN_MODE = 'DEFAULT';
    @TestVisible
    private static final Id DRAFT_RECORD_TYPE_ID = Schema.SObjectType.zpl__ContractLineItem__c
    .getRecordTypeInfosByDeveloperName()
    .get('Draft')
    .getRecordTypeId();
    @TestVisible
    private static final Id ACTIVE_RECORD_TYPE_ID = Schema.SObjectType.zpl__ContractLineItem__c
    .getRecordTypeInfosByDeveloperName()
    .get('Active')
    .getRecordTypeId();

    @TestVisible
    private final static List<String> CONTRACT_LINES_QUERY_FIELDS = new List<String>{
        AIQ_ContractLineSelector.ID_FIELD,
        AIQ_ContractLineSelector.NAME_FIELD,
        AIQ_ContractLineSelector.RECORD_TYPE_ID_FIELD,
        AIQ_ContractLineSelector.CONTRACT_LINE_RECORD_TYPE_NAME,
        AIQ_ContractLineSelector.CAMPAIGN_APPEALED_LINE_FIELD,
        AIQ_ContractLineSelector.STATUS_FIELD,
        AIQ_ContractLineSelector.IS_CURRENT_FIELD,
        AIQ_ContractLineSelector.EFFECTIVE_DATE_FIELD,
        AIQ_ContractLineSelector.INACTIVATED_BY_FIELD,
        AIQ_ContractLineSelector.INACTIVATED_DATE_FIELD,
        AIQ_ContractLineSelector.CBSS_ITEM_GROUPING_KEY_FIELD
    };

    @TestVisible
    private Contract contract = new Contract();
    @TestVisible
    private Set<Id> appealedLines = new Set<Id>();
    @TestVisible
    Map<Id, zpl__ContractLineItem__c> deleteLines = new Map<Id, zpl__ContractLineItem__c>();
    @TestVisible
    Map<Id, zpl__ContractLineItem__c> updateLines = new Map<Id, zpl__ContractLineItem__c>();
    @TestVisible
    private AIQ_ContractLineSelector contractLineSelector; 
    @TestVisible
    private AIQ_ContractSelector contractSelector;
    @TestVisible
    private AIQco_DatabaseUtil databaseUtil;
    @TestVisible
    AIQqa_QuickActionDTO actionDTO = new AIQqa_QuickActionDTO ();
    @TestVisible
    private Set<String> cbss = new Set<String>(); 

    public AIQ_DeleteLine() {
        contractLineSelector = new AIQ_ContractLineSelector();
        contractSelector = new AIQ_ContractSelector();
        databaseUtil = new AIQco_DatabaseUtil();
    }

    public override AIQqa_QuickActionDTO initialize(List<Id> recordId, String actionName) {
        AIQqa_QuickActionUtil.ActionDtoBuilder dtoBuilder = AIQqa_QuickActionUtil.getDialogActionDtoBuilder(recordId, actionName);
        dtoBuilder
                .setHeaderTitle(HEADER_TITLE_LABEL)
                .setScreenMode(SCREEN_MODE)
                .setBodyMessage(BODY_MESSAGE_LABEL)
                .setSvgIcon(SVG_ICON);
        this.actionDTO = dtoBuilder.build();
        return actionDTO;
    }

    public override AIQqa_QuickActionDTO runPrimary(AIQqa_QuickActionDTO actionDTO) {
        Savepoint sp = Database.setSavepoint();
        this.actionDTO = actionDTO;
        List<zpl__ContractLineItem__c> lineList;

        try {
            setDeleteLinesMap();
            setPublishedLines();
            if (!this.cbss.isEmpty()) {
                lineList = getLinesToBeVacated();
                setUpdateAndDeleteLines(lineList);
            }

            if (deleteLines.size() > 0) {
                databaseUtil.deleteRecords(deleteLines.values());
            }

            if (updateLines.size() > 0) {
                databaseUtil.updateRecords(updateLines.values());
                contract = contractSelector.queryContractById(actionDTO.parentId);
                AIQRollupCalculation calc = new AIQRollupCalculation(new List<Contract> {contract});
                calc.saveUpdatedContracts();
            }
            
            setCustomMessage(actionDTO);
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AIQ_DeleteLineException(String.format(Label.aiq_PublishError, new List<String> {e.getMessage()}));
        }
        return actionDTO;
    }

    private void setDeleteLinesMap() {
        for (zpl__ContractLineItem__c contractLine : contractLineSelector.queryContractLinesById(
            CONTRACT_LINES_QUERY_FIELDS,
            this.actionDTO.recordId)
        ) {
            if (contractLine.RecordTypeId == DRAFT_RECORD_TYPE_ID) {
                deleteLines.put(contractLine.Id, contractLine);
                setAppealedLines(contractLine);
            } else if (contractLine.RecordTypeId == ACTIVE_RECORD_TYPE_ID) {
                this.cbss.add(contractLine.CBSSItemGroupingKey__c);
            }
        }
    }

    private void setAppealedLines(zpl__ContractLineItem__c contractLine) {
        if (contractLine.CampaignAppealedLine__c != null){
            this.appealedLines.add(contractLine.CampaignAppealedLine__c);
        }
    }

    private void setPublishedLines() {
        if (this.appealedLines.isEmpty()) {return;}
        zal.Condition condition = this.getPublishLineCondition();
        List<zpl__ContractLineItem__c> lines = contractLineSelector.queryContractLinesByCondition(
            CONTRACT_LINES_QUERY_FIELDS,
            condition);
        for (zpl__ContractLineItem__c line : lines) {
            line.zpl__Status__c = PUBLISHED;
            updateLines.put(line.Id, line);
        }
    }

    @TestVisible
    private zal.Condition getPublishLineCondition() {
        AIQco_Precondition.checkArgument(this.appealedLines.isEmpty(), Label.aiq_InvalidArgumentsErrorMessage);
        zal.AndCondition andCondition = new zal.AndCondition();
        andCondition.add(new zal.SetCondition(
            AIQ_ContractLineSelector.ID_FIELD,
            zal.Operator.INX,
            new List<Id> (this.appealedLines))
        );
        andCondition.add(new zal.FieldCondition(
            AIQ_ContractLineSelector.STATUS_FIELD,
            zal.Operator.EQUALS,
            PENDING_CANCEL)
        );

        return andCondition;
    }

    private List<zpl__ContractLineItem__c> getLinesToBeVacated() {
        zal.Condition condition = this.getLinesToBeVacatedCondition();
        List<zpl__ContractLineItem__c> allLines = contractLineSelector.queryContractLinesByCondition(
            CONTRACT_LINES_QUERY_FIELDS, 
            condition
        );
        return allLines;
    }

    @TestVisible
    private zal.AndCondition getLinesToBeVacatedCondition() {
        AIQco_Precondition.checkArgument(this.actionDTO.recordId.isEmpty(), Label.aiq_InvalidArgumentsErrorMessage);
        AIQco_Precondition.checkArgument(this.actionDTO.parentId == null, Label.aiq_InvalidArgumentsErrorMessage);
        zal.AndCondition andCondition = new zal.AndCondition();

        andCondition.add(new zal.SetCondition(
            AIQ_ContractLineSelector.CONTRACT_FIELD,
            zal.Operator.INX,
            new List<Id> {this.actionDTO.parentId})
        );
        andCondition.add(new zal.FieldCondition(
            AIQ_ContractLineSelector.CONTRACT_LINE_RECORD_TYPE_NAME,
            zal.Operator.NOT_EQUALS,
            INACTIVE)
        );
        andCondition.add(new zal.SetCondition(
            AIQ_ContractLineSelector.CBSS_ITEM_GROUPING_KEY_FIELD,
            zal.Operator.INX,
            new List<String> (this.cbss))
        );

        return andCondition;
    }

    private void setUpdateAndDeleteLines(List<zpl__ContractLineItem__c> allLines) {
        for (zpl__ContractLineItem__c line : allLines) {
            if (line.RecordTypeId == DRAFT_RECORD_TYPE_ID) {
                if (deleteLines.containsKey(line.Id)) {continue;}
                deleteLines.put(line.Id, line);
            } else if (line.RecordTypeId == ACTIVE_RECORD_TYPE_ID) {
                line.zpl__Status__c = USER_VACATED;
                line.RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
                    .get(INACTIVE)
                    .getRecordTypeId();
                line.isCurrent__c = false;
                line.Inactivated_By__c = UserInfo.getUserId();
                line.Inactivated_Date__c = system.now();
                line.SupersededDate__c = system.now();
                updateLines.put(line.Id, line);
            } 
        }
    }

    private void setCustomMessage(AIQqa_QuickActionDTO actionDTO) {
        AIQqa_QuickActionUtil.CustomMessageBuilder buildMsg = new AIQqa_QuickActionUtil.CustomMessageBuilder();
        buildMsg.setType(SUCCESS);
        if (deleteLines.size() == 0 && updateLines.size() == 0) {
            buildMsg.setMessages(new Set<String>{Label.AIQVacatePricingRejected})
                    .setType(ERROR);
        } else if (deleteLines.size() > 0 && updateLines.size() == 0) {
            buildMsg.setMessages(new Set<String>{Label.AIQHardDeleteSuccess});
        } else if (deleteLines.size() == 0 && updateLines.size() > 0) {
            buildMsg.setMessages(new Set<String>{Label.AIQVacatePricingSuccess});
        } else {
            buildMsg.setMessages(new Set<String>{Label.aiq_DeleteAndVacatePricing});
        }
        new AIQqa_QuickActionUtil.ActionDtoBuilder(actionDTO)
                .setCustomMessage(buildMsg.build())
                .build();
    }
}
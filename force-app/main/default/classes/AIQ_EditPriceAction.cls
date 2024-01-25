public with sharing class AIQ_EditPriceAction extends AIQqa_AbstractQuickAction implements AIQqa_QuickActionInterface {
    public class AIQ_EditPriceActionException extends Exception {
    }
    @TestVisible
    private static final Schema.SObjectType CONTRACT_LINE_ITEM_OBJECT_TYPE = Schema.SObjectType.zpl__ContractLineItem__c.getSObjectType();
    @TestVisible
    private static final String IQA_CONFIGURATION_NAME = AIQZilliantConfiguration__c.getInstance().GetPriceDataFormula__c;
    private static final Id LINE_RECORD_TYPE_ID_DRAFT = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();
    private static final String CONTRACT_LINE_ITEM_OBJECT_NAME = Schema.SObjectType.zpl__ContractLineItem__c.getName();
    private static final String CONTRACT_LINE_ITEM_ID_FIELD_NAME = Schema.SObjectType.zpl__ContractLineItem__c.fields.zpl__ContractLineItemId__c.getName();
    private static final String LINE_STATUS_DRAFT = 'Draft';
    private static final String LINE_SOURCE_U = 'U';

    @TestVisible
    private AIQ_ContractLineCopyUtil copyUtil = new AIQ_ContractLineCopyUtil();
    @TestVisible
    private AIQ_FormulaEvaluatorUtil evaluator = new AIQ_FormulaEvaluatorUtil();
    @TestVisible
    private AIQco_DatabaseUtil databaseUtil = new AIQco_DatabaseUtil();
    @TestVisible
    private AIQ_ContractLineSelector lineSelector = new AIQ_ContractLineSelector();
    private List<String> fields = new List<String>();

    public AIQ_EditPriceAction() {
        fields.add(AIQ_ContractLineSelector.LINE_LEVEL_FIELD);
    }

    public override AIQqa_QuickActionDTO initialize(AIQqa_QuickActionDTO actionDTO) {
        if (actionDTO.recordId.contains(actionDTO.parentId)) {
            return AIQqa_QuickActionUtil.getDialogActionDtoBuilder(actionDTO.recordId, actionDTO.configName)
            .setHeaderTitle('AIQCopyLineHeader')
            .setBodyMessage('AIQCopyLineContent')
            .setSvgIcon('utility:copy')
            .build();
        }else {
            return AIQqa_QuickActionUtil.getAutolaunchedActionDtoBuilder(actionDTO.recordId, actionDTO.configName).build();
        }
    }

    public override AIQqa_QuickActionDTO runPrimary(AIQqa_QuickActionDTO actionDTO) {
        AIQqa_QuickActionUtil.ActionDTOBuilder actionDTOBuilder = new AIQqa_QuickActionUtil.ActionDTOBuilder(actionDTO);
        try {
            AIQco_Precondition.checkArgument(actionDTO.recordId.isEmpty(), 'Received empty list');
            List<zpl__ContractLineItem__c> lines = copyUtil.copyLines(new Set<Id>(actionDTO.recordId)).setDefaults().getCloneLines();
            if (lines.isEmpty()) {
                actionDTOBuilder.setCustomMessage(getErrorMessage('No Lines Found'));
            }

            databaseUtil.insertRecords(new List<zpl__ContractLineItem__c>(getLinesForInsert(lines)));
            actionDTOBuilder
                .setRecordId(AIQ_CommonUtil.toIdList(lines))
                .setCustomMessage(getRecursiveMessage())
                .setRefreshView(false);
        } catch (Exception e) {
            actionDTOBuilder.setCustomMessage(getErrorMessage(e.getMessage()));
            throw e;
        }

        return actionDTOBuilder.build();
    }

    public override AIQqa_QuickActionDTO runSecondary(AIQqa_QuickActionDTO actionDTO) {
        AIQqa_QuickActionUtil.ActionDTOBuilder actionDTOBuilder = new AIQqa_QuickActionUtil.ActionDTOBuilder(actionDTO);
        try {
            List<zpl__ContractLineItem__c> lines = lineSelector.queryContractLinesById(this.fields, actionDTO.recordId);
            databaseUtil.updateRecords(this.evaluateLines(lines));
            actionDTOBuilder.setCustomMessage(getSuccessMessage()).setRefreshView(false);
        } catch (Exception e) {
            actionDTOBuilder.setCustomMessage(getErrorMessage(e.getMessage()));
            throw e;
        }

        return actionDTOBuilder.build();
    }

    private List<zpl__ContractLineItem__c> evaluateLines(List<zpl__ContractLineItem__c> lines) {
        try {
            return evaluator.evaluateLines(IQA_CONFIGURATION_NAME, CONTRACT_LINE_ITEM_OBJECT_TYPE, lines);
        } catch (Exception e) {
            throw new AIQ_EditPriceActionException('IQA request failed: ' + e.getMessage() + '. ' + e.getStackTraceString());
        }
    }

    private List<zpl__ContractLineItem__c> getLinesForInsert(List<zpl__ContractLineItem__c> lines) {
        List<zpl__ContractLineItem__c> linesToInsert = new List<zpl__ContractLineItem__c>();
        for (zpl__ContractLineItem__c line : lines) {
            if (line.Id == null) {
                linesToInsert.add(line);
            }
        }
        return linesToInsert;
    }

    private AIQqa_CustomMessage getRecursiveMessage() {
        return new AIQqa_QuickActionUtil.CustomMessageBuilder()
            .setStopExecution(false)
            .setProcessingType(AIQqa_CustomMessage.ChildProcessingType.RECURSIVE)
            .setType('Success')
            .setFinalMessage(Label.AIQCopySuccess)
            .build();
    }

    private AIQqa_CustomMessage getSuccessMessage() {
        return new AIQqa_QuickActionUtil.CustomMessageBuilder()
            .setStopExecution(true)
            .setType('Success')
            .setFinalMessage(Label.AIQCopySuccess)
            .build();
    }

    private AIQqa_CustomMessage getErrorMessage(String messageText) {
        return new AIQqa_QuickActionUtil.CustomMessageBuilder()
            .setType('Error')
            .setFinalMessage(messageText)
            .setStopExecution(true)
            .build();
    }
}
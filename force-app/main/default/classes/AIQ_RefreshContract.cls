public with sharing class AIQ_RefreshContract extends AIQqa_AbstractQuickAction implements AIQqa_QuickActionInterface {
    public class AIQ_RefreshContractException extends Exception {
    }

    @TestVisible
    private static final Schema.SObjectType CONTRACT_LINE_ITEM_OBJECT_TYPE = Schema.SObjectType.zpl__ContractLineItem__c.getSObjectType();
    @TestVisible
    private static final String IQA_CONFIGURATION_NAME = AIQZilliantConfiguration__c.getInstance().GetPriceDataFormula__c;
    @TestVisible
    private final static String INACTIVE = 'Inactive';

    @TestVisible
    private final static List<String> CONTRACT_LINES_QUERY_FIELDS = new List<String>{
        AIQ_ContractLineSelector.ID_FIELD,
        AIQ_ContractLineSelector.LINE_LEVEL_FIELD
    };

    @TestVisible
    private AIQ_ContractLineSelector contractLineSelector;
    @TestVisible
    private AIQ_FormulaEvaluatorUtil evaluator;
    @TestVisible
    private AIQco_DatabaseUtil databaseUtil;

    public AIQ_RefreshContract() {
        contractLineSelector = new AIQ_ContractLineSelector();
        databaseUtil = new AIQco_DatabaseUtil();
        evaluator = new AIQ_FormulaEvaluatorUtil();
    }

    public override AIQqa_QuickActionDTO runPrimary(AIQqa_QuickActionDTO actionDTO) {
        AIQqa_QuickActionUtil.ActionDTOBuilder actionDTOBuilder = new AIQqa_QuickActionUtil.ActionDTOBuilder(actionDTO);
        AIQtr_TriggerHandler.bypassBeforeUpdate('AIQtr_AgreementLineItemTriggerHandler');
        List<zpl__ContractLineItem__c> lines = getLinesToBeRefreshed(actionDTO);
        lines = this.evaluateLines(lines);
        Savepoint sp = Database.setSavepoint();
        try {
            AIQco_Precondition.checkArgument(actionDTO.recordId.isEmpty(), 'Received empty list');
            if (!lines.isEmpty()) {
                databaseUtil.updateRecords(lines);
                AIQRollupCalculation calc = new AIQRollupCalculation(new List<Contract>{ new Contract(Id = actionDTO.parentId) });
                databaseUtil.updateRecords(calc.getUpdatedContracts());
            }
            if (lines.size() < actionDTO.recursiveBatchSize) {
                actionDTOBuilder.setCustomMessage(getSuccessMessage());
            } else {
                actionDTOBuilder.setPayLoad('0');
            }
        } catch (Exception e) {
            throw new AIQ_RefreshContractException(String.format(Label.aiq_PublishError, new List<String>{ e.getMessage() }));
        }

        actionDTO.customMessage = setCustomMessageRecursive();
        return actionDTOBuilder.build();
    }

    public override AIQqa_QuickActionDTO runSecondary(AIQqa_QuickActionDTO actionDTO) {
        AIQtr_TriggerHandler.bypassBeforeUpdate('AIQtr_AgreementLineItemTriggerHandler');
        AIQqa_QuickActionUtil.ActionDTOBuilder actionDTOBuilder = new AIQqa_QuickActionUtil.ActionDTOBuilder(actionDTO);
        Integer iterationCounter;
        if (actionDTO.payload != null) {
            iterationCounter = Integer.valueOf(actionDTO.payload);
            actionDTOBuilder.setPayLoad(String.valueOf(++iterationCounter));
        }
        List<zpl__ContractLineItem__c> lines = getLinesToBeRefreshed(actionDTO);
        lines = this.evaluateLines(lines);
        Savepoint sp = Database.setSavepoint();
        try {
            AIQco_Precondition.checkArgument(actionDTO.recordId.isEmpty(), 'Received empty list');
            if (!lines.isEmpty()) {
                databaseUtil.updateRecords(lines);
                AIQRollupCalculation calc = new AIQRollupCalculation(new List<Contract>{ new Contract(Id = actionDTO.parentId) });
                databaseUtil.updateRecords(calc.getUpdatedContracts());
            }
            if (lines.size() < actionDTO.recursiveBatchSize) {
                actionDTOBuilder.setCustomMessage(getSuccessMessage());
            }
        } catch (Exception e) {
            actionDTOBuilder.setCustomMessage(getErrorMessage(e.getMessage()));
            Database.rollback(sp);
            throw new AIQ_RefreshContractException(e.getMessage());
        }

        return actionDTOBuilder.build();
    }

    private List<zpl__ContractLineItem__c> evaluateLines(List<zpl__ContractLineItem__c> lines) {
        try {
            return evaluator.evaluateLines(IQA_CONFIGURATION_NAME, CONTRACT_LINE_ITEM_OBJECT_TYPE, lines);
        } catch (Exception e) {
            throw new AIQ_RefreshContractException('IQA request failed: ' + e.getMessage() + '. ' + e.getStackTraceString());
        }
    }

    private List<zpl__ContractLineItem__c> getLinesToBeRefreshed(AIQqa_QuickActionDTO actionDTO) {
        AIQco_Precondition.checkArgument(actionDTO.recursiveBatchSize == null, 'Property batch size is empty');
        zal.Condition condition = this.getLinesToBeRefreshedCondition(actionDTO.parentId);
        List<zpl__ContractLineItem__c> allLines = contractLineSelector.queryContractLinesByCondition(
            CONTRACT_LINES_QUERY_FIELDS,
            condition,
            actionDTO.recursiveBatchSize,
            actionDTO.payload == null ? 0 : actionDTO.recursiveBatchSize * Integer.valueOf(actionDTO.payload)
        );

        return allLines;
    }

    private zal.AndCondition getLinesToBeRefreshedCondition(Id parentId) {
        zal.AndCondition andCondition = new zal.AndCondition();
        andCondition.add(new zal.SetCondition(AIQ_ContractLineSelector.CONTRACT_FIELD, zal.Operator.INX, new List<Id>{ parentId }));
        andCondition.add(
            new zal.FieldCondition(AIQ_ContractLineSelector.CONTRACT_LINE_RECORD_TYPE_NAME, zal.Operator.NOT_EQUALS, INACTIVE)
        );
        return andCondition;
    }

    private AIQqa_CustomMessage getSuccessMessage() {
        return new AIQqa_QuickActionUtil.CustomMessageBuilder()
            .setStopExecution(true)
            .setType('Success')
            .setFinalMessage('Refreshed successfully!')
            .build();
    }

    private AIQqa_CustomMessage getErrorMessage(String messageText) {
        return new AIQqa_QuickActionUtil.CustomMessageBuilder()
            .setType('Error')
            .setFinalMessage(messageText)
            .setStopExecution(true)
            .build();
    }

    private AIQqa_CustomMessage setCustomMessageRecursive() {
        return new AIQqa_QuickActionUtil.CustomMessageBuilder()
            .setProcessingType(AIQqa_CustomMessage.ChildProcessingType.RECURSIVE)
            .setType('Success')
            .setFinalMessage('Refreshing')
            .build();
    }
}
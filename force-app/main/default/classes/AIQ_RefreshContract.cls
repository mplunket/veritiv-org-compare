public with sharing class AIQ_RefreshContract extends AIQqa_AbstractQuickAction implements AIQqa_QuickActionInterface {
    public class AIQ_RefreshContractException extends Exception {
    }

    @TestVisible
    private static final Schema.SObjectType CONTRACT_LINE_ITEM_OBJECT_TYPE = Schema.SObjectType.zpl__ContractLineItem__c.getSObjectType();
    @TestVisible
    private static final String IQA_CONFIGURATION_NAME = AIQZilliantConfiguration__c.getInstance().GetPriceDataFormula__c;
    @TestVisible
    private final static String INACTIVE = 'Inactive';
    private final static String WORKFLOW_ERROR_MESSAGE  = Label.aiq_WorkflowJobFailError;
    @TestVisible
    private static Integer secondaryTimeout = (Integer) aiq_ParameterSettings__mdt.getInstance('secondaryTimeout').aiq_ParameterValue__c;

    @TestVisible
    private final static List<String> CONTRACT_LINES_QUERY_FIELDS = new List<String>{
        AIQ_ContractLineSelector.ID_FIELD,
        AIQ_ContractLineSelector.LINE_LEVEL_FIELD
    };

    @TestVisible
    private AIQ_ContractLineSelector contractLineSelector;
    @TestVisible
    private AIQ_ContractSelector contractSelector;
    @TestVisible
    private AIQ_FormulaEvaluatorUtil evaluator;
    @TestVisible
    private AIQco_DatabaseUtil databaseUtil;
    @TestVisible
    private AIQqa_QuickActionDTO actionDTO;
    @TestVisible
    private AIQ_WorkflowServiceInvoker workflowInvoker;

    public AIQ_RefreshContract() {
        contractLineSelector = new AIQ_ContractLineSelector();
        contractSelector = new AIQ_ContractSelector();
        databaseUtil = new AIQco_DatabaseUtil();
        evaluator = new AIQ_FormulaEvaluatorUtil();
        workflowInvoker = new AIQ_WorkflowServiceInvoker();
    }

    public override AIQqa_QuickActionDTO runPrimary(AIQqa_QuickActionDTO actionDTO) {
        this.actionDTO = actionDTO;
        AIQqa_QuickActionUtil.ActionDtoBuilder actionDTOBuilder = new AIQqa_QuickActionUtil.ActionDtoBuilder(actionDTO);
        try {
            Contract contract = contractSelector.queryContractById(actionDTO.parentId);
            submitJob(actionDTOBuilder, contract.zpl__ContractId__c);
            actionDTOBuilder.setCustomMessage(setCustomMessageRecursive());
        } catch (Exception e) {
            throw new AIQ_RefreshContractException(String.format(Label.aiq_PublishError, new List<String>{ e.getMessage() }));
        }

        return actionDTOBuilder.build(); 
    }

    public override AIQqa_QuickActionDTO runSecondary(AIQqa_QuickActionDTO actionDTO) {
        AIQqa_QuickActionUtil.ActionDtoBuilder actionDTOBuilder = new AIQqa_QuickActionUtil.ActionDtoBuilder(actionDTO);
        try {
            switch on actionDTOBuilder.getPayloadStep() {
                when 1 {
                    processJobStatus(actionDTOBuilder);
                }
                when 2 {
                    actionDTOBuilder = updateEvaluatedLines(actionDTO);
                }
            }      
        } catch (Exception e) {
            AIQco_Logger.getInstance(actionDTO.configName, actionDTO.parentId).log(e);
            actionDTOBuilder.setCustomMessage(getErrorMessage(e.getMessage()));
        }

        return actionDTOBuilder.build();
    }

    private AIQqa_QuickActionUtil.ActionDTOBuilder updateEvaluatedLines(AIQqa_QuickActionDTO actionDTO) {
        AIQtr_TriggerHandler.bypassBeforeUpdate('AIQtr_AgreementLineItemTriggerHandler');
        AIQqa_QuickActionUtil.ActionDTOBuilder actionDTOBuilder = new AIQqa_QuickActionUtil.ActionDTOBuilder(actionDTO);
        List<zpl__ContractLineItem__c> lines = getLinesToBeRefreshed(actionDTO);
        Integer offsetCounter = actionDTOBuilder.getOffsetCounter();
        actionDTOBuilder.setPayloadOffset(++offsetCounter, null);
        actionDTOBuilder.setPayloadStep(2);
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

        return actionDTOBuilder;
    }

    private void submitJob(AIQqa_QuickActionUtil.ActionDtoBuilder actionDTOBuilder, String contractId) {
        actionDTOBuilder.createPayloadWrapper();
        System.debug('!!! actionDTOBuilder ' + actionDTOBuilder);
        try {
            String jobId = workflowInvoker.submitJob(
                contractId,
                null
            );
            System.debug('!!! jobId ' + jobId);
            actionDTOBuilder.setSecondaryTimeout(secondaryTimeout);
            actionDTOBuilder.setPayloadAdditionalInfo(jobId);
        } catch (Exception e) {
            AIQco_Logger.getInstance(actionDTO.configName, actionDTO.parentId).log(e);
            actionDTOBuilder.setCustomMessage(getErrorMessage(e.getMessage()));
        }
    }

    @TestVisible
    private void processJobStatus(AIQqa_QuickActionUtil.ActionDtoBuilder actionDTOBuilder) {
        try {
            AIQ_WorkflowServiceInvoker.ResponseBodyDTO statusResponseBody =
                checkJobStatus(actionDTOBuilder.getPayloadAdditionalInfo());
            if (!String.isBlank(statusResponseBody.closeStatus)) {
                if (statusResponseBody.closeStatus == 'COMPLETED') {
                    actionDTOBuilder.nextStep();
                    actionDTOBuilder.setPayloadOffset(0, null);
                } else if (statusResponseBody.closeStatus == 'FAILED') {
                    AIQco_Logger.getInstance(actionDTO.configName, actionDTO.parentId)
                                .log('AIQ_RefreshContract failed',
                                    'failed jobId ' + actionDTOBuilder.getPayloadAdditionalInfo()
                                );
                    actionDTOBuilder.setCustomMessage(getErrorMessage(WORKFLOW_ERROR_MESSAGE));
                }
            }
        } catch (Exception e) {
            System.debug('!!! e ' + e.getStackTraceString());
            AIQco_Logger.getInstance(actionDTO.configName, actionDTO.parentId).log(e);
            actionDTOBuilder.setCustomMessage(getErrorMessage(e.getMessage()));
        }
    }

    private List<zpl__ContractLineItem__c> evaluateLines(List<zpl__ContractLineItem__c> lines) {
        try {
            return evaluator.evaluateLines(IQA_CONFIGURATION_NAME, CONTRACT_LINE_ITEM_OBJECT_TYPE, lines);
        } catch (Exception e) {
            throw new AIQ_RefreshContractException('IQA request failed: ' + e.getMessage() + '. ' + e.getStackTraceString());
        }
    }

    @TestVisible
    private AIQ_WorkflowServiceInvoker.ResponseBodyDTO checkJobStatus(String jobId) {
        AIQ_WorkflowServiceInvoker.ResponseBodyDTO responseBody = workflowInvoker.checkJobStatus(jobId);
        return responseBody;
    }

    private List<zpl__ContractLineItem__c> getLinesToBeRefreshed(AIQqa_QuickActionDTO actionDTO) {
        AIQco_Precondition.checkArgument(actionDTO.recursiveBatchSize == null, 'Property batch size is empty');
        AIQqa_QuickActionUtil.ActionDTOBuilder actionDTOBuilder = new AIQqa_QuickActionUtil.ActionDTOBuilder(actionDTO);

        zal.Condition condition = this.getLinesToBeRefreshedCondition(actionDTO.parentId);
        List<zpl__ContractLineItem__c> allLines = contractLineSelector.queryContractLinesByCondition(
            CONTRACT_LINES_QUERY_FIELDS,
            condition,
            actionDTO.recursiveBatchSize,
            actionDTO.recursiveBatchSize * Integer.valueOf(actionDTOBuilder.getOffsetCounter())
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
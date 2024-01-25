public with sharing class AIQ_DeepCopy extends AIQqa_AbstractQuickAction implements AIQqa_QuickActionInterface{
    public class AIQ_DeepCopyException extends Exception{}

    @TestVisible
    private static final Schema.SObjectType CONTRACT_LINE_ITEM_OBJECT_TYPE = Schema.SObjectType.zpl__ContractLineItem__c.getSObjectType();
    @TestVisible
    private static final String IQA_CONFIGURATION_NAME = AIQZilliantConfiguration__c.getInstance().GetPriceDataFormula__c;
    @TestVisible
    private static final Integer LINE_BATCH_SIZE = 
        (Integer) aiq_ParameterSettings__mdt.getInstance('copyLinesBatchSize').aiq_ParameterValue__c;
    @TestVisible
    private static final Integer QUERY_LIMIT = 
        (Integer) aiq_ParameterSettings__mdt.getInstance('copyLinesAccountsBatchSize').aiq_ParameterValue__c;
    @TestVisible
    private static final String ACTION_DTO_ACCOUNT_ID_API_NAME = 'AccountId';
    @TestVisible
    private static final String NAME_FIELD = 'Name';
    @TestVisible
    private static final String ZILLIANT_ACTIVE_ACCOUNT_VALUE = 'AI';
    @TestVisible
    private static final Schema.SObjectType SCHEMA_CONTRACT_LINE_OBJ_TYPE = Schema.getGlobalDescribe().get(AIQ_ContractLineSelector.OBJECT_NAME);
    @TestVisible
    private static final Schema.SObjectType SCHEMA_CONTRACT_OBJ_TYPE = Schema.getGlobalDescribe().get(AIQ_ContractSelector.OBJECT_NAME);

    @TestVisible
    private final static List<String> CONTRACT_LINES_QUERY_FIELDS = new List<String>{
        AIQ_ContractLineSelector.ID_FIELD,
        AIQ_ContractLineSelector.LINE_LEVEL_FIELD
    };

    @TestVisible
    public static final List<String> CONTRACT_ACCOUNT_QUERY_FIELDS = new List<String> {
        AIQ_ContractSelector.ID_FIELD,
        AIQ_ContractSelector.ACCOUNT_SERVICING_DIVISION,
        AIQ_ContractSelector.ACCOUNT_NAME,
        AIQ_ContractSelector.ACCOUNT_SERVICING_DIVISION_NAME,
        AIQ_ContractSelector.ACCOUNT_SERVICING_DIVISION_CODE,
        AIQ_ContractSelector.ACCOUNT_CUSTOMER_ID,
        AIQ_ContractSelector.ACCOUNT_LEGACY_CODE,
        AIQ_ContractSelector.ACCOUNT_LEGACY_DIVISION,
        AIQ_ContractSelector.ACCOUNT_AUTO_NUMBER,
        AIQ_ContractSelector.ACCOUNT_RECORD_TYPE_NAME,
        AIQ_ContractSelector.ACCOUNT_REPRESENTATIVE_DIVISION
    };

    @TestVisible
    private AIQqa_QuickActionDTO actionDTO;
    @TestVisible
    private AIQ_ContractCopyUtil contractCopyUtil;
    @TestVisible
    private AIQ_ContractLineCopyUtil contractLineCopyUtil;
    @TestVisible
    private AIQ_ContractSelector contractSelector;
    @TestVisible
    private AIQ_ContractLineSelector contractLineSelector;
    @TestVisible
    private AIQco_DatabaseUtil databaseUtil;
    @TestVisible
    private AIQ_FormulaEvaluatorUtil evaluator;
    @TestVisible
    private AIQ_GenericSelector genericSelector;

    public AIQ_DeepCopy() {
        contractSelector = new AIQ_ContractSelector();
        contractLineSelector = new AIQ_ContractLineSelector();
        databaseUtil = new AIQco_DatabaseUtil();
        evaluator = new AIQ_FormulaEvaluatorUtil();
        genericSelector = new AIQ_GenericSelector();
        contractCopyUtil = new AIQ_ContractCopyUtil();
        contractLineCopyUtil = new AIQ_ContractLineCopyUtil();
    }

    public override AIQqa_QuickActionDTO initialize(List<Id> recordId, String actionName) {
        AIQqa_QuickActionDTO actionDTO = super.initialize(recordId, actionName);
      
        return actionDTO;
    }

    public  override AIQqa_QuickActionDTO handleLookupSearch(AIQqa_QuickActionDTO actionDTO) {
        AIQqa_QuickActionUtil.ActionDTOBuilder actionDTOBuilder = new AIQqa_QuickActionUtil.ActionDTOBuilder(actionDTO);
        setOptions(actionDTO);

        return actionDTOBuilder.build();
    }

    public override AIQqa_QuickActionDTO runPrimary(AIQqa_QuickActionDTO actionDTO) {
        AIQco_Precondition.checkArgument(actionDTO.recordId.isEmpty(), 'Received empty list');
        AIQqa_QuickActionUtil.ActionDTOBuilder actionDTOBuilder = new AIQqa_QuickActionUtil.ActionDTOBuilder(actionDTO);
        setActionDTO(actionDTO);
        Contract newContract = setNewContract();
        Contract insertedContract;
        if (newContract == null) {throw new AIQ_DeepCopyException('Copy contract error');}
        PayloadContainer payloadContainer = new PayloadContainer();
        Savepoint sp = Database.setSavepoint();
        try {
            insertedContract = (Contract) databaseUtil.insertRecord(newContract);
            actionDTOBuilder.setNewRecordId(insertedContract.Id);
            List<zpl__ContractLineItem__c> linesToInsert = getNewLines(actionDTO?.newRecordId);
            databaseUtil.insertRecords(linesToInsert);
            if (linesToInsert.size() == LINE_BATCH_SIZE) {
                payloadContainer.operation = 'Insert';
                payloadContainer.step = 1;

            } else if (linesToInsert.size() < LINE_BATCH_SIZE) {
                payloadContainer.operation = 'Evaluate';
                payloadContainer.step = 0;
            }
            actionDTOBuilder.setPayLoad(JSON.serialize(payloadContainer));
            actionDTO.customMessage = setCustomMessageRecursive();
        } catch(Exception e) {
            Database.rollback(sp);
            throw new AIQ_DeepCopyException(e.getMessage());
        }

        return actionDTOBuilder.build();
    }

    public override AIQqa_QuickActionDTO runSecondary(AIQqa_QuickActionDTO actionDTO) {
        AIQqa_QuickActionUtil.ActionDTOBuilder actionDTOBuilder = new AIQqa_QuickActionUtil.ActionDTOBuilder(actionDTO);
        setActionDTO(actionDTO);
        PayloadContainer payloadContainer = (PayloadContainer) JSON.deserialize(this.actionDTO.payload, PayloadContainer.class);
        String operationType = payloadContainer.operation;
        List<zpl__ContractLineItem__c> linesToInsert;
        List<zpl__ContractLineItem__c> linesToEvaluate;
        
        try {
            switch on operationType {
                when 'Insert' {
                    linesToInsert = getNewLines(actionDTO?.newRecordId);
                    if (linesToInsert.size() == LINE_BATCH_SIZE) {
                        payloadContainer.operation = 'Insert';
                        payloadContainer.step++;
                    } else if (linesToInsert.size() < LINE_BATCH_SIZE) {
                        payloadContainer.operation = 'Evaluate';
                        payloadContainer.step = 0;

                    }
                    actionDTOBuilder.setPayLoad(JSON.serialize(payloadContainer));
                    if (linesToInsert.size() != 0) {
                        databaseUtil.insertRecords(linesToInsert);
                    }
                }
                when 'Evaluate' {
                    linesToEvaluate = getLinesToBeEvaluated();
                    if (linesToEvaluate.isEmpty()) {
                        setCustomMessageStopExecution();
                        return actionDTOBuilder.build();
                    } 

                    if (linesToEvaluate.size() == this.actionDTO.recursiveBatchSize) {
                        payloadContainer.operation = 'Evaluate';
                        payloadContainer.step++;
                        databaseUtil.updateRecords(evaluateLines(linesToEvaluate));
                        actionDTOBuilder.setPayLoad(JSON.serialize(payloadContainer));
                    } else if (linesToEvaluate.size() < this.actionDTO.recursiveBatchSize) {
                        databaseUtil.updateRecords(evaluateLines(linesToEvaluate));
                        setCustomMessageStopExecution();
                    }
                }
            }
        } catch (Exception e) {
            throw new AIQ_DeepCopyException(String.format(Label.aiq_PublishError, new List<String> {e.getMessage()}));
        }

        return actionDTOBuilder.build();
    }

    private Contract setNewContract() {
        Account acct = genericSelector.queryAccountById(actionDTO.getField(ACTION_DTO_ACCOUNT_ID_API_NAME).defaultValue);
        Contract newContract = contractCopyUtil.copyContract(actionDTO.recordId, this.actionDTO.FieldsToExclulde).setClonedContract(acct).getCloneContract();

        return newContract;
    }

    private List<SObject> getNewLines(Id newContractId) {
        List<SObject> recordsToInsert = new List<SObject>();
        for(AIQqa_QuickActionDTO child : this.actionDTO.ChildObjects) {
            List<zpl__ContractLineItem__c> lines = getLinesToBeCopied();
            if (lines.isEmpty()) { return new List<SObject>();}
            
            List<SObject> newChildRecords = setNewContractId(
                newContractId,
                contractLineCopyUtil
                    .copyLines(AIQ_CommonUtil.toIdSet(lines), false)
                    .setFieldsToExclude(child.FieldsToExclulde)
                    .getCloneLines()
            );
            
            Contract contract = contractSelector.queryContractById(CONTRACT_ACCOUNT_QUERY_FIELDS, newContractId); 
            
            AIQ_AgreementLineManipulator.stripAgreementLine(newChildRecords);
            for (Integer i = 0; i < newChildRecords.size(); i++) {
                if (contract.Account.RecordTypeId != AIQ_GenericSelector.ACCOUNT_CHAIN_ACCOUNT_RECORD_TYPE_ID) {
                    newChildRecords.get(i).put(AIQ_ContractLineSelector.DIVISION_CODE2_FIELD, contract.Account.Servicing_Division__r.Division_Code__c);
                }
            }
            recordsToInsert.addAll(newChildRecords);
        }

        return recordsToInsert;
    }

    private List<zpl__ContractLineItem__c> getLinesToBeEvaluated() {
        AIQco_Precondition.checkArgument(this.actionDTO.recursiveBatchSize == null, 'Property batch size is empty');
        PayloadContainer payloadContainer;
        if (this.actionDTO.payload != null) {
            payloadContainer = (PayloadContainer) JSON.deserialize(this.actionDTO.payload, PayloadContainer.class);
        }
        AIQco_Precondition.checkArgument(payloadContainer == null, 'Payload container step is unknown');
        zal.Condition condition = this.getLinesToBeEvaluatedCondition(this.actionDTO.newRecordId);
        List<zpl__ContractLineItem__c> allLines = contractLineSelector.queryContractLinesByCondition(
            CONTRACT_LINES_QUERY_FIELDS,
            condition,
            this.actionDTO.recursiveBatchSize,
            this.actionDTO.recursiveBatchSize * payloadContainer.step
        );

        return allLines;
    }

    private zal.AndCondition getLinesToBeEvaluatedCondition(Id newParentId) {
        zal.AndCondition andCondition = new zal.AndCondition();
        andCondition.add(new zal.SetCondition(
            AIQ_ContractLineSelector.CONTRACT_FIELD,
            zal.Operator.INX,
            new List<Id> {newParentId})
        );

        return andCondition;
    }

    private List<Account> getAccounts() {
        AIQco_Precondition.checkArgument(this.actionDTO.recursiveBatchSize == null, 'Property batch size is empty');
        zal.Condition condition = this.getAccountsCondition();
        List<Account> accounts = genericSelector.queryAccountsByCondition(
            null,
            condition,
            QUERY_LIMIT,
            this.actionDTO.searchOffset == null ? 0 : this.actionDTO.searchOffset,
            null
        );

        return accounts;
    }

    private zal.AndCondition getAccountsCondition() {
        zal.AndCondition whereCondition = new zal.AndCondition();
        whereCondition.add(new zal.FieldCondition(AIQ_GenericSelector.HAS_AGREEMENT_ACCOUNT_FIELD_NAME, zal.Operator.EQUALS, false));
        whereCondition.add(new zal.FieldCondition(AIQ_GenericSelector.ZILLIANT_ACTIVE_ACCOUNT_FIELD_NAME, zal.Operator.EQUALS, ZILLIANT_ACTIVE_ACCOUNT_VALUE));
        if (String.isNotBlank(this.actionDTO.searchQuery)) {
            whereCondition.add(new zal.FieldCondition(NAME_FIELD, zal.Operator.LIKEX, this.actionDTO.searchQuery + '%'));
        }

        return whereCondition;
    }

    private List<zpl__ContractLineItem__c> getLinesToBeCopied() {
        zal.Condition condition = this.getLinesToBeCopiedCondition();
        PayloadContainer payloadContainer;
        if (this.actionDTO.payload != null) {
            payloadContainer = (PayloadContainer) JSON.deserialize(this.actionDTO.payload, PayloadContainer.class);
        }
        List<zpl__ContractLineItem__c> lines = contractLineSelector.queryContractLinesByCondition(
            null, 
            condition,
            LINE_BATCH_SIZE,
            this.actionDTO.payload == null ? 0 : LINE_BATCH_SIZE * payloadContainer.step
        );

        return lines;
    }

    private zal.AndCondition getLinesToBeCopiedCondition() {
        zal.AndCondition whereCondition = new zal.AndCondition();
        whereCondition.add(new zal.SetCondition(AIQ_ContractLineSelector.CONTRACT_FIELD, zal.Operator.INX, this.actionDTO.recordId));
        whereCondition.add(new zal.SetCondition(
            AIQ_ContractLineSelector.RECORD_TYPE_ID_FIELD,
            zal.Operator.NOT_IN,
            new List<String> {
                AIQ_ContractLineSelector.LINE_INACTIVE_RECORD_TYPE_ID, 
                AIQ_ContractLineSelector.LINE_DRAFT_RECORD_TYPE_ID
                }
            )
        );
        whereCondition.add(new zal.FieldCondition(AIQ_ContractLineSelector.SUPERSEDED_DATE_FIELD, zal.Operator.EQUALS, null));

        return whereCondition;
    }

    private List<zpl__ContractLineItem__c> evaluateLines(List<zpl__ContractLineItem__c> lines) {
        try {
            return evaluator.evaluateLines(IQA_CONFIGURATION_NAME, CONTRACT_LINE_ITEM_OBJECT_TYPE, lines);
        } catch (Exception e) {
            throw new AIQ_DeepCopyException('IQA request failed: ' + e.getMessage() + '. ' + e.getStackTraceString());
        }
    }

    private void setCustomMessageStopExecution() {
        new AIQqa_QuickActionUtil.CustomMessageBuilder(this.actionDTO.customMessage)
        .setType('Success')
        .setFinalMessage(Label.AIQCopySuccess)
        .setStopExecution(true)
        .build();
    }

    private AIQqa_CustomMessage setCustomMessageRecursive() {
        return new AIQqa_QuickActionUtil.CustomMessageBuilder()
        .setProcessingType(AIQqa_CustomMessage.ChildProcessingType.RECURSIVE)
        .setType('Warning')
        .setFinalMessage('Something went wrong, calculation process was interrupted')
        .build();
    }

    private void setOptions(AIQqa_QuickActionDTO actionDTO) {
        setActionDTO(actionDTO);
        List<AIQqa_QuickActionDTO.LookupOption> options = new List<AIQqa_QuickActionDTO.LookupOption>();
        for (Account acct : this.getAccounts()) {
            options.add(new AIQqa_QuickActionDTO.LookupOption(acct.Name + ' / ' + acct.zpl__CustomerId__c, '', acct.Id));
        }
        AIQqa_QuickActionDTO.FieldToReset field = actionDto.getField(ACTION_DTO_ACCOUNT_ID_API_NAME);
        AIQqa_QuickActionUtil.FieldBuilder builder = new AIQqa_QuickActionUtil.FieldBuilder(field);
        builder.setOptions(options);
        builder.build();
    }

    private void setActionDTO(AIQqa_QuickActionDTO actionDTO) {
        this.actionDTO = actionDTO;
    }

    private List<zpl__ContractLineItem__c> setNewContractId(Id newContractId, List<zpl__ContractLineItem__c> cloneLines) {
        for (zpl__ContractLineItem__c line : cloneLines) {
            line.zpl__Contract__c = newContractId;
        }

        return cloneLines;
    }
    @TestVisible
    private class PayloadContainer {
        public Integer step{get; set;}
        public String operation{get; set;}
    }
}
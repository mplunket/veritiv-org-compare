@IsTest
public with sharing class AIQ_RefreshContractTest {
    private static final String ACTION_NAME = 'AIQ_DeleteLine';
    private static final String TEST_NAME = 'Test Name';

    private static List<Contract> contracts;
    private static List<zpl__ContractLineItem__c> draftContractLines;
    private static AIQ_RefreshContract refreshContractAction = new AIQ_RefreshContract();

    static {
        contracts = AIQ_TestDataFactory.initializeContracts(new Contract(Name = TEST_NAME), 1, true);
        draftContractLines = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                Name = 'TestContractLine',
                zpl__Contract__c = contracts[0].Id,
                RecordTypeId = AIQ_DeleteLine.DRAFT_RECORD_TYPE_ID,
                CBSSItemGroupingKey__c = '123',
                zpl__Status__c = 'Draft'
            ),
            10,
            true
        );
    }

    @IsTest
    private static void testRunPrimary() {
        mockDependencies(draftContractLines);
        AIQqa_QuickActionDTO actionDto;
        Test.startTest();
            actionDto = refreshContractAction.runPrimary(getActionDTO(draftContractLines));
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.areEqual(draftContractLines.size(), actionDto.recordId.size(), 'list of the records is not empty');
        Assert.areEqual(AIQ_RefreshContract.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    @IsTest
    private static void testRunSecondary() {
        mockDependencies(draftContractLines);
        AIQqa_QuickActionDTO actionDto = getActionDTO(draftContractLines);
        Integer dtoPayload = Integer.valueOf(actionDto.payload);
        Test.startTest();
            actionDto = refreshContractAction.runSecondary(actionDto);
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.areEqual(draftContractLines.size(), actionDto.recordId.size(), 'list of the records is not empty');
        Assert.areEqual(AIQ_RefreshContract.class.getName(), actionDto.configName, 'the name of the action matches');
        Assert.areEqual(dtoPayload+1, Integer.valueOf(actionDto.payload), 'expected payload');
    }

    @IsTest
    private static void testRunSecondaryNegative() {
        mockDependencies(draftContractLines);
        AIQqa_QuickActionDTO actionDto = getActionDTOWithEmptyRecordIds(draftContractLines);
        Test.startTest();
        try {
            actionDto = refreshContractAction.runSecondary(actionDto);
            Assert.fail('should not be here');
        } catch (Exception e) {
            Assert.isInstanceOfType(
                e,
                AIQ_RefreshContract.AIQ_RefreshContractException.class,
                'Exception thrown is of type AIQ_RefreshContract'
            );
        } 
        Test.stopTest();
    }

    private static void mockDependencies(List<zpl__ContractLineItem__c> lines) {
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQ_FormulaEvaluatorUtil evaluator = (AIQ_FormulaEvaluatorUtil) mocks.mock(AIQ_FormulaEvaluatorUtil.class);
        AIQ_ContractLineSelector contractLineSelector = (AIQ_ContractLineSelector) mocks.mock(AIQ_ContractLineSelector.class);
        AIQco_DatabaseUtil databaseUtil = (AIQco_DatabaseUtil) mocks.mock(AIQco_DatabaseUtil.class);

        mocks.startStubbing();
        mocks.when(
                contractLineSelector.queryContractLinesById(
                    AIQ_RefreshContract.CONTRACT_LINES_QUERY_FIELDS,
                    AIQ_CommonUtil.toIdList(lines)
                )
            )
            .thenReturn(lines);
        mocks.when(
                evaluator.evaluateLines(
                    AIQ_RefreshContract.IQA_CONFIGURATION_NAME,
                    AIQ_RefreshContract.CONTRACT_LINE_ITEM_OBJECT_TYPE,
                    lines
                )
            )
            .thenReturnForAny(lines);    
        mocks.when(contractLineSelector.queryContractLinesByCondition(
                AIQ_RefreshContract.CONTRACT_LINES_QUERY_FIELDS,
                new zal.AndCondition(),
                30,
                0)
            )
            .thenReturnForAny(lines);

        mocks.when(databaseUtil.updateRecords(lines)).thenReturnForAny(lines);
        mocks.stopStubbing();

        refreshContractAction.contractLineSelector = contractLineSelector;
        refreshContractAction.evaluator = evaluator;
        refreshContractAction.databaseUtil = databaseUtil;
    }

    private static AIQqa_QuickActionDTO getActionDTO(List<zpl__ContractLineItem__c> lines) {
        return AIQqa_QuickActionUtil.getAutolaunchedActionDtoBuilder(
                AIQ_CommonUtil.toIdList(lines),
                AIQ_RefreshContract.class.getName()
            )
            .setParentId(contracts[0].Id)
            .setRecursiveBatchSize(30)
            .setPayLoad('0')
            .build();
    }

    private static AIQqa_QuickActionDTO getActionDTOWithEmptyRecordIds(List<zpl__ContractLineItem__c> lines) {
        return AIQqa_QuickActionUtil.getAutolaunchedActionDtoBuilder(
                AIQ_CommonUtil.toIdList(lines),
                AIQ_RefreshContract.class.getName()
            )
            .setParentId(contracts[0].Id)
            .setRecursiveBatchSize(30)
            .setPayLoad('0')
            .setRecordId(new List<Id> {})
            .build();
    }
}
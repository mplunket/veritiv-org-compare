@IsTest
public with sharing class AIQ_RefreshContractTest {
    private static final String ACTION_NAME = 'AIQ_DeleteLine';
    private static final String TEST_NAME = 'Test Name';

    private static List<Contract> contracts;
    private static List<zpl__ContractLineItem__c> draftContractLines;
    private static AIQ_RefreshContract refreshContractAction = new AIQ_RefreshContract();

    static {
        contracts = AIQ_TestDataFactory.initializeContracts(new Contract(Name = TEST_NAME, zpl__ContractId__c = 'testId'), 1, true);
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
        mockDependencies(draftContractLines, false);
        AIQqa_QuickActionDTO actionDto;
        Test.startTest();
            actionDto = refreshContractAction.runPrimary(getActionDTO(draftContractLines, 0));
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.areEqual(draftContractLines.size(), actionDto.recordId.size(), 'list of the records is not empty');
        Assert.areEqual(AIQ_RefreshContract.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    @IsTest
    private static void testRunSecondaryFirstStep() {
        mockDependencies(draftContractLines, false);
        AIQqa_QuickActionDTO actionDto = getActionDTO(draftContractLines, 1);
        Test.startTest();
            actionDto = refreshContractAction.runSecondary(actionDto);
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.areEqual(draftContractLines.size(), actionDto.recordId.size(), 'list of the records is not empty');
        Assert.areEqual(AIQ_RefreshContract.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    @IsTest
    private static void testRunSecondarySecondStep() {
        mockDependencies(draftContractLines, false);
        AIQqa_QuickActionDTO actionDto = getActionDTO(draftContractLines, 2);
        Test.startTest();
            actionDto = refreshContractAction.runSecondary(actionDto);
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.areEqual(draftContractLines.size(), actionDto.recordId.size(), 'list of the records is not empty');
        Assert.areEqual(AIQ_RefreshContract.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    @IsTest
    private static void testProcessJobStatus() {
        mockDependencies(draftContractLines, false);
        AIQqa_QuickActionDTO actionDTO = getActionDTO(draftContractLines, 1);

        Test.startTest();
            refreshContractAction.runSecondary(actionDTO);
        Test.stopTest();

        System.assertEquals(2, actionDTO.PayLoadWrapper.step, 'payload step should be set correctly');
    }

    @IsTest
    private static void testProcessJobStatusNegative() {
        mockDependencies(draftContractLines, true);
        AIQqa_QuickActionDTO actionDTO = getActionDTO(draftContractLines, 1);

        Test.startTest();
            refreshContractAction.runSecondary(actionDTO);
        Test.stopTest();

        System.assertEquals(1, actionDTO.PayLoadWrapper.step, 'payload step should be set correctly');
    }

    private static void mockDependencies(List<zpl__ContractLineItem__c> lines, Boolean isResponseFailed) {
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQ_FormulaEvaluatorUtil evaluator = (AIQ_FormulaEvaluatorUtil) mocks.mock(AIQ_FormulaEvaluatorUtil.class);
        AIQ_ContractLineSelector contractLineSelector = (AIQ_ContractLineSelector) mocks.mock(AIQ_ContractLineSelector.class);
        AIQ_ContractSelector contractSelector = (AIQ_ContractSelector) mocks.mock(AIQ_ContractSelector.class);
        AIQco_DatabaseUtil databaseUtil = (AIQco_DatabaseUtil) mocks.mock(AIQco_DatabaseUtil.class);

        AIQ_WorkflowServiceInvoker.ResponseBodyDTO responseBodyDTO = new AIQ_WorkflowServiceInvoker.ResponseBodyDTO();
        if(isResponseFailed) {
            responseBodyDTO.closeStatus = 'FAILED';
        } else {
            responseBodyDTO.closeStatus = 'COMPLETED';
        }
        AIQ_WorkflowServiceInvoker workflowInvoker = (AIQ_WorkflowServiceInvoker) mocks.mock(
                AIQ_WorkflowServiceInvoker.class
        );

        mocks.startStubbing();
        mocks.when(contractSelector.queryContractById(contracts[0].Id)).thenReturnForAny(contracts[0]);
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
        mocks.when(workflowInvoker.checkJobStatus('0')).thenReturnForAny(responseBodyDTO);
        mocks.stopStubbing();

        refreshContractAction.contractLineSelector = contractLineSelector;
        refreshContractAction.contractSelector = contractSelector;
        refreshContractAction.evaluator = evaluator;
        refreshContractAction.databaseUtil = databaseUtil;
        refreshContractAction.workflowInvoker = workflowInvoker;
    }

    private static AIQqa_QuickActionDTO getActionDTO(List<zpl__ContractLineItem__c> lines, Integer subStep) {
        AIQqa_QuickActionDTO actionDto = new AIQqa_QuickActionDTO();
        AIQqa_QuickActionDTO.PayLoadWrapper payload = new AIQqa_QuickActionDTO.PayLoadWrapper();

        actionDto = AIQqa_QuickActionUtil.getAutolaunchedActionDtoBuilder(
                AIQ_CommonUtil.toIdList(lines),
                AIQ_RefreshContract.class.getName()
            )
            .setParentId(contracts[0].Id)
            .setRecursiveBatchSize(30)
            .createPayloadWrapper()
            .build();

        payLoad.step = subStep;
        actionDto.PayLoadWrapper = payload;

        return actionDto;
    }
}
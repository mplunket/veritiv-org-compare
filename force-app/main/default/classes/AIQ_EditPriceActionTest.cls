@IsTest
public without sharing class AIQ_EditPriceActionTest {
    private static List<zpl__ContractLineItem__c> contractLinesDraft;
    private static List<zpl__ContractLineItem__c> contractLinesPublished;
    private static List<zpl__ContractLineItem__c> contractLinesCampaign;
    private static AIQ_ContractLineCopyUtil lineCopyUtil = new AIQ_ContractLineCopyUtil();

    static {
        contractLinesDraft = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(zpl__Status__c = 'Draft', zpl__EffectiveDate__c = Date.today().addDays(2)),
            10,
            true
        );
        contractLinesPublished = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(zpl__Status__c = 'Published', zpl__EffectiveDate__c = Date.today().addDays(-2)),
            20,
            true
        );
        contractLinesCampaign = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(zpl__Status__c = 'Published', LineSource__c = 'C'),
            30,
            true
        );
    }

    @IsTest
    private static void testInitializeAutolaunched() {
        AIQ_EditPriceAction editPriceAction = new AIQ_EditPriceAction();
        mockDependencies(editPriceAction);

        Test.startTest();
        AIQqa_QuickActionDTO actionDto = editPriceAction.initialize(getAutolaunchedActionDTO());
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.areEqual(contractLinesDraft.size(), actionDto.recordId.size(), 'list of the records in not empty');
        Assert.areEqual(AIQ_EditPriceAction.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    @IsTest
    private static void testInitializeDialog() {
        AIQ_EditPriceAction editPriceAction = new AIQ_EditPriceAction();
        mockDependencies(editPriceAction);

        Test.startTest();
        AIQqa_QuickActionDTO actionDto = editPriceAction.initialize(getDialogActionDTO());
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.areEqual(1, actionDto.recordId.size(), 'dialog is renders from CLI record page');
        Assert.areEqual(AIQ_EditPriceAction.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    @IsTest
    private static void testRunPrimary() {
        AIQ_EditPriceAction editPriceAction = new AIQ_EditPriceAction();
        mockDependencies(editPriceAction);

        Test.startTest();
        AIQqa_QuickActionDTO actionDto = editPriceAction.runPrimary(getAutolaunchedActionDTO());
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.areEqual(contractLinesDraft.size(), actionDto.recordId.size(), 'list of the records in not empty');
        Assert.areEqual(AIQ_EditPriceAction.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    @IsTest
    private static void testRunSecondary() {
        AIQ_EditPriceAction editPriceAction = new AIQ_EditPriceAction();
        mockDependencies(editPriceAction);

        Test.startTest();
        AIQqa_QuickActionDTO actionDto = editPriceAction.runSecondary(getAutolaunchedActionDTO());
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.areEqual(contractLinesDraft.size(), actionDto.recordId.size(), 'list of the records in not empty');
        Assert.areEqual(AIQ_EditPriceAction.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    private static void mockDependencies(AIQ_EditPriceAction editPriceAction) {
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQ_ContractLineCopyUtil copyUtil = (AIQ_ContractLineCopyUtil) mocks.mock(AIQ_ContractLineCopyUtil.class);
        AIQ_FormulaEvaluatorUtil evaluator = (AIQ_FormulaEvaluatorUtil) mocks.mock(AIQ_FormulaEvaluatorUtil.class);
        AIQ_ContractLineSelector lineSelector = (AIQ_ContractLineSelector) mocks.mock(AIQ_ContractLineSelector.class);
        AIQco_DatabaseUtil databaseUtil = (AIQco_DatabaseUtil) mocks.mock(AIQco_DatabaseUtil.class);

        mocks.startStubbing();
        mocks.when(copyUtil.copyLines(AIQ_CommonUtil.toIdSet(contractLinesDraft))).thenReturnForAny(copyUtil);
        mocks.when(copyUtil.setDefaults()).thenReturnForAny(copyUtil);
        mocks.when(copyUtil.getCloneLines()).thenReturnForAny(contractLinesDraft);
        mocks.when(
                evaluator.evaluateLines(
                    AIQ_EditPriceAction.IQA_CONFIGURATION_NAME,
                    AIQ_EditPriceAction.CONTRACT_LINE_ITEM_OBJECT_TYPE,
                    contractLinesDraft
                )
            )
            .thenReturnForAny(contractLinesDraft);
        mocks.when(lineSelector.queryContractLinesById(new List<String>(), AIQ_CommonUtil.toIdList(contractLinesDraft)))
            .thenReturnForAny(contractLinesDraft);
        mocks.when(databaseUtil.insertRecords(contractLinesDraft)).thenReturnForAny(contractLinesDraft);
        mocks.when(databaseUtil.updateRecords(contractLinesDraft)).thenReturnForAny(contractLinesDraft);
        mocks.stopStubbing();

        editPriceAction.copyUtil = copyUtil;
        editPriceAction.evaluator = evaluator;
        editPriceAction.lineSelector = lineSelector;
        editPriceAction.databaseUtil = databaseUtil;
    }

    private static AIQqa_QuickActionDTO getAutolaunchedActionDTO() {
        return AIQqa_QuickActionUtil.getAutolaunchedActionDtoBuilder(
                AIQ_CommonUtil.toIdList(contractLinesDraft),
                AIQ_EditPriceAction.class.getName()
            )
            .build();
    }

    private static AIQqa_QuickActionDTO getDialogActionDTO() {
        return AIQqa_QuickActionUtil.getDialogActionDtoBuilder(
                new List<Id>{contractLinesDraft[0].Id},
                AIQ_EditPriceAction.class.getName()
            )
            .setParentId(contractLinesDraft[0].Id)
            .build();
    }
}
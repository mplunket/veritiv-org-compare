@IsTest
public with sharing class AIQ_DeleteLineTest {
    private static final String ACTION_NAME = 'AIQ_DeleteLine';
    private static final String TEST_NAME = 'Test Name';

    private static List<Contract> contracts;
    private static zpl__ContractLineItem__c campaignContractLine;
    private static List<zpl__ContractLineItem__c> draftContractLines;
    private static List<zpl__ContractLineItem__c> publishedContractLines;
    private static List<zpl__ContractLineItem__c> draftContractWithoutAppealedLines;

    static {
        contracts = AIQ_TestDataFactory.initializeContracts(new Contract(Name = TEST_NAME), 1, true);
        campaignContractLine = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                Name = 'TestContractLine',
                zpl__Contract__c = contracts[0].Id,
                RecordTypeId = AIQ_DeleteLine.ACTIVE_RECORD_TYPE_ID,
                CBSSItemGroupingKey__c = '123',
                zpl__Status__c = 'Published',
                LineSource__c = 'C'
            ),
            1,
            true
        )[0];
        draftContractLines = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                Name = 'TestContractLine',
                zpl__Contract__c = contracts[0].Id,
                RecordTypeId = AIQ_DeleteLine.DRAFT_RECORD_TYPE_ID,
                CBSSItemGroupingKey__c = '123',
                zpl__Status__c = 'Draft',
                CampaignAppealedLine__c = campaignContractLine.Id
            ),
            10,
            true
        );
        draftContractWithoutAppealedLines = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                Name = 'TestContractLine',
                zpl__Contract__c = contracts[0].Id,
                RecordTypeId = AIQ_DeleteLine.ACTIVE_RECORD_TYPE_ID,
                CBSSItemGroupingKey__c = '123',
                zpl__Status__c = 'Published'
            ),
            10,
            true
        );
        publishedContractLines = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                Name = 'TestContractLine',
                zpl__Contract__c = contracts[0].Id,
                RecordTypeId = AIQ_DeleteLine.ACTIVE_RECORD_TYPE_ID,
                CBSSItemGroupingKey__c = '123',
                zpl__Status__c = 'Published'
            ),
            20,
            true
        );
       
    }

    @IsTest
    private static void testInitialize() {
        List<Id> recordIds = new List<Id>{ draftContractLines[0].Id };
        AIQ_DeleteLine deleteLine = new AIQ_DeleteLine();

        Test.startTest();
        AIQqa_QuickActionDTO dto = deleteLine.initialize(recordIds, ACTION_NAME);
        Test.stopTest();
        System.assertEquals(ACTION_NAME, dto.configName, 'the name of the action matches');
    }

    @IsTest
    private static void testRunPrimaryWithDraftWithoutAppealedLines() {
        AIQ_DeleteLine deleteLineAction = new AIQ_DeleteLine();
        mockDependencies(deleteLineAction, draftContractWithoutAppealedLines);

        Test.startTest();
        AIQqa_QuickActionDTO actionDto = deleteLineAction.runPrimary(getActionDTO(draftContractWithoutAppealedLines));
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.isTrue(actionDto.customMessage.messages.contains(Label.AIQVacatePricingSuccess), 'custom message is set');
        Assert.areEqual(draftContractWithoutAppealedLines.size(), actionDto.recordId.size(), 'list of the records in not empty');
        Assert.areEqual(AIQ_DeleteLine.class.getName(), actionDto.configName, 'the name of the action matches');
    }
    
    @IsTest
    private static void testRunPrimaryWithDraftWithAppealedLines() {
        AIQ_DeleteLine deleteLineAction = new AIQ_DeleteLine();
        mockDependencies(deleteLineAction, draftContractLines);

        Test.startTest();
        AIQqa_QuickActionDTO actionDto = deleteLineAction.runPrimary(getActionDTO(draftContractLines));
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.isTrue(actionDto.customMessage.messages.contains(Label.aiq_DeleteAndVacatePricing), 'custom message is set');
        Assert.areEqual(draftContractLines.size(), actionDto.recordId.size(), 'list of the records in not empty');
        Assert.areEqual(AIQ_DeleteLine.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    @IsTest
    private static void testRunPrimaryWithPublishedLines() {
        AIQ_DeleteLine deleteLineAction = new AIQ_DeleteLine();
        mockDependencies(deleteLineAction, publishedContractLines);

        Test.startTest();
        AIQqa_QuickActionDTO actionDto = deleteLineAction.runPrimary(getActionDTO(publishedContractLines));
        Test.stopTest(); 
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.isTrue(actionDto.customMessage.messages.contains(Label.AIQVacatePricingSuccess), 'custom message is set');
        Assert.areEqual(publishedContractLines.size(), actionDto.recordId.size(), 'list of the records in not empty');
        Assert.areEqual(AIQ_DeleteLine.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    @IsTest
    private static void testRunPrimaryWithCombinedLines() {
        List<zpl__ContractLineItem__c> combined = new List<zpl__ContractLineItem__c>();
        combined.addAll(draftContractLines);
        combined.addAll(publishedContractLines);
        AIQ_DeleteLine deleteLineAction = new AIQ_DeleteLine();
        mockDependencies(deleteLineAction, combined);
        Test.startTest();
        AIQqa_QuickActionDTO actionDto = deleteLineAction.runPrimary(getActionDTO(combined));
        Test.stopTest();

        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.isTrue(actionDto.customMessage.messages.contains(Label.aiq_DeleteAndVacatePricing), 'custom message is set');
        Assert.areEqual(combined.size(), actionDto.recordId.size(), 'list of the records in not empty');
        Assert.areEqual(AIQ_DeleteLine.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    private static void mockDependencies(AIQ_DeleteLine deleteLineAction, List<zpl__ContractLineItem__c> lines) {
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQ_ContractSelector contractSelector = (AIQ_ContractSelector) mocks.mock(AIQ_ContractSelector.class);
        AIQ_ContractLineSelector contractLineSelector = (AIQ_ContractLineSelector) mocks.mock(AIQ_ContractLineSelector.class);
        AIQco_DatabaseUtil databaseUtil = (AIQco_DatabaseUtil) mocks.mock(AIQco_DatabaseUtil.class);

        mocks.startStubbing();
        mocks.when(contractSelector.queryContractById(contracts[0].Id)).thenReturn(contracts[0]);
        mocks.when(
                contractLineSelector.queryContractLinesById(
                    AIQ_DeleteLine.CONTRACT_LINES_QUERY_FIELDS,
                    AIQ_CommonUtil.toIdList(lines)
                )
            )
            .thenReturn(lines);
        mocks.when(contractLineSelector.queryContractLinesByCondition(AIQ_DeleteLine.CONTRACT_LINES_QUERY_FIELDS, null))
            .thenReturnForAny(lines);
        mocks.when(databaseUtil.deleteRecords(lines)).thenReturnForAny(lines);
        mocks.when(databaseUtil.updateRecords(lines)).thenReturnForAny(lines);
        mocks.stopStubbing();

        deleteLineAction.contractSelector = contractSelector;
        deleteLineAction.contractLineSelector = contractLineSelector;
        deleteLineAction.databaseUtil = databaseUtil;
    }

    private static AIQqa_QuickActionDTO getActionDTO(List<zpl__ContractLineItem__c> lines) {
        return AIQqa_QuickActionUtil.getAutolaunchedActionDtoBuilder(
                AIQ_CommonUtil.toIdList(lines),
                AIQ_DeleteLine.class.getName()
            )
            .setParentId(contracts[0].Id)
            .build();
    }
}
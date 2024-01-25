@IsTest
public class AIQ_DeepCopyTest {
    private static final String ACTION_NAME = 'AIQ_DeepCopy';
    private static final String TEST_NAME = 'Test Name';

    private static List<Account> accounts;
    private static List<Contract> contracts;
    private static List<zpl__ContractLineItem__c> contractLines;
    private static zpl__QuickActionConfig__c actionConfig;
    private static zpl__QuickActionField__c actionField;

    static {
        accounts = AIQ_TestDataFactory.initializeAccounts(
            new Account(
                Name = 'TestAccount',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Customer')
                .getRecordTypeId(),
                zpl__CustomerId__c = (String) AIQts_ApexMocks.generateId(new Account().getSObjectType())
            ),
            1,
            true
        );
        actionConfig = AIQ_TestDataFactory.initializeQuickActionConfig(
            new zpl__QuickActionConfig__c(
                Name = ACTION_NAME,
                SObjectType__c = 'Contract',
                ActionType__c = 'DIALOG',
                RecursiveBatchSize__c = 30
            ),
            false
        );
        actionField = AIQ_TestDataFactory.initializeQuickActionField(
            new zpl__QuickActionField__c(
                Name = 'AccountId',
                QuickActionConfig__c = actionConfig.Id,
                Position__c = '1.1',
                Field_Action__c = 'Reset',
                DisplayMode__c = 'ADVANCED LOOKUP'
            ),
            null,
            false
        );
        contracts = AIQ_TestDataFactory.initializeContracts(new Contract(Name = TEST_NAME), 1, true);
        contractLines = AIQ_TestDataFactory.initializeContractsLines(
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
    private static void testInitialize() {
        AIQ_DeepCopy deepCopyAction = new AIQ_DeepCopy();
        mockDependencies(deepCopyAction, accounts);
        Test.startTest();
        AIQqa_QuickActionDTO dto = deepCopyAction.initialize(new List<Id>{ contracts[0].Id }, ACTION_NAME);
        Test.stopTest();
        Assert.areEqual(ACTION_NAME, dto.configName, 'the name of the action matches');
        Assert.areEqual(0, dto.getField('AccountId').lookupOptions.size(), 'set lookup option');
    }

    @IsTest
    private static void testHandleLookupSearch() {
        AIQ_DeepCopy deepCopyAction = new AIQ_DeepCopy();
        AIQqa_QuickActionDTO actionDto = getActionDTO(contractLines);
        mockDependencies(deepCopyAction, accounts);
        Test.startTest();
        AIQqa_QuickActionDTO dto = deepCopyAction.handleLookupSearch(actionDto);
        Test.stopTest();
        Assert.areEqual(ACTION_NAME, dto.configName, 'the name of the action matches');
        Assert.areEqual(accounts.size(), dto.getField('AccountId').lookupOptions.size(), 'set lookup option');
    }

    @IsTest
    private static void testRunPrimary() {
        AIQ_DeepCopy deepCopyAction = new AIQ_DeepCopy();
        AIQqa_QuickActionDTO actionDto = getActionDTO(contractLines);
        mockDependencies(deepCopyAction, accounts);
        Test.startTest();
        AIQqa_QuickActionDTO dto = deepCopyAction.runPrimary(actionDto);
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.isNotNull(actionDto.newRecordId, 'new record Id created');
        Assert.areEqual(AIQ_DeepCopy.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    @IsTest
    private static void testRunSecondary() {
        AIQ_DeepCopy deepCopyAction = new AIQ_DeepCopy();
        AIQqa_QuickActionDTO actionDto = getActionDTO(contractLines);
        mockDependencies(deepCopyAction, accounts);
        Test.startTest();
        AIQqa_QuickActionDTO dto = deepCopyAction.runSecondary(actionDto);
        Test.stopTest();
        Assert.isNotNull(actionDto, 'action DTO is initialized');
        Assert.isNotNull(actionDto.payload, 'payload set');
        Assert.areEqual(AIQ_DeepCopy.class.getName(), actionDto.configName, 'the name of the action matches');
    }

    private static void mockDependencies(AIQ_DeepCopy deepCopyAction, List<Account> accountList) {
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQ_FormulaEvaluatorUtil evaluator = (AIQ_FormulaEvaluatorUtil) mocks.mock(AIQ_FormulaEvaluatorUtil.class);
        AIQ_GenericSelector genericSelector = (AIQ_GenericSelector) mocks.mock(AIQ_GenericSelector.class);
        AIQ_ContractSelector contractSelector = (AIQ_ContractSelector) mocks.mock(AIQ_ContractSelector.class);
        AIQ_ContractLineSelector contractLineSelector = (AIQ_ContractLineSelector) mocks.mock(AIQ_ContractLineSelector.class);
        AIQco_DatabaseUtil databaseUtil = (AIQco_DatabaseUtil) mocks.mock(AIQco_DatabaseUtil.class);
        AIQ_ContractCopyUtil contractCopyUtil = (AIQ_ContractCopyUtil) mocks.mock(AIQ_ContractCopyUtil.class);
        AIQ_ContractLineCopyUtil contractLineCopyUtil = (AIQ_ContractLineCopyUtil) mocks.mock(AIQ_ContractLineCopyUtil.class);

        mocks.startStubbing();
        mocks.when(databaseUtil.insertRecord(contracts[0])).thenReturnForAny(contracts[0]);
        mocks.when(genericSelector.queryAccountById(accountList[0].Id)).thenReturnForAny(accountList[0]);
        mocks.when(contractCopyUtil.setClonedContract(accountList[0])).thenReturnForAny(contracts[0]);
        mocks.when(contractCopyUtil.copyContract(new List<Id> {contracts[0].Id}, new List<String>()))
            .thenReturnForAny(new AIQ_ContractCopyUtil());
        mocks.when(contractCopyUtil.getCloneContract()).thenReturnForAny(contracts[0]);
        mocks.when(contractSelector.queryContractById(new List<String>(), contracts[0].Id)).thenReturnForAny(contracts[0]);
        mocks.when(contractLineCopyUtil.copyLines(AIQ_CommonUtil.toIdSet(contractLines)))
            .thenReturnForAny(contractLineCopyUtil);
        mocks.when(contractLineCopyUtil.setFieldsToExclude(new List<String>()))
            .thenReturnForAny(contractLineCopyUtil);
        mocks.when(contractLineCopyUtil.getCloneLines()) 
            .thenReturnForAny(getCopiedLines());
        mocks.when(contractLineSelector.queryContractLinesByCondition(AIQ_DeepCopy.CONTRACT_LINES_QUERY_FIELDS, null))
            .thenReturnForAny(contractLines);
        mocks.when(
                evaluator.evaluateLines(
                    AIQ_DeepCopy.IQA_CONFIGURATION_NAME,
                    AIQ_DeepCopy.CONTRACT_LINE_ITEM_OBJECT_TYPE,
                    contractLines
                )
            )
            .thenReturnForAny(contractLines);   
        mocks.when(
            genericSelector.queryAccountsByCondition(
                    null,
                    new zal.AndCondition(),
                    10,
                    0,
                    null
                )
            )
            .thenReturnForAny(accountList);
        mocks.when(contractLineSelector.queryContractLinesByCondition(
                null,
                new zal.AndCondition(),
                null,
                null
                )
            )
            .thenReturnForAny(contractLines);
        
        mocks.stopStubbing();
        
        deepCopyAction.contractSelector = contractSelector;
        deepCopyAction.contractLineSelector = contractLineSelector;
        deepCopyAction.evaluator = evaluator;
        deepCopyAction.genericSelector = genericSelector;
        deepCopyAction.databaseUtil = databaseUtil;
        deepCopyAction.contractCopyUtil = contractCopyUtil;
        deepCopyAction.contractLineCopyUtil = contractLineCopyUtil;
    }

    private static AIQqa_QuickActionDTO getActionDTO(List<zpl__ContractLineItem__c> lines) {
        AIQ_DeepCopy.PayloadContainer payloadContainer = new AIQ_DeepCopy.PayloadContainer();
        payloadContainer.operation = 'Evaluate';
        payloadContainer.step = 0;
        AIQqa_QuickActionDTO.FieldToReset field = new AIQqa_QuickActionUtil.FieldBuilder(AIQqa_DisplayMode.ADVANCED_LOOKUP_DISPLAY_MODE)
                .setApiFieldName('AccountId')
                .setFieldLabel('Account ID')
                .setIsRendered(false)
                .setPosition('1.1')
                .build();
        AIQqa_QuickActionDTO actionDTO = AIQqa_QuickActionUtil.getAutolaunchedActionDtoBuilder(
                AIQ_CommonUtil.toIdList(lines),
                AIQ_DeepCopy.class.getName()
            )
            .setParentId(contracts[0].Id)
            .setRecordId(new List<Id> {contracts[0].Id})
            .setNewRecordId(contracts[0].Id)
            .setPayLoad(JSON.serialize(payloadContainer))
            .setRecursiveBatchSize(5)
            .build();
        actionDTO.FieldsToReset.add(field);
        actionDTO.SObjectType = Schema.SObjectType.Contract.getName();
        actionDTO.ChildObjects = new List<AIQqa_QuickActionDTO> {actionDTO};
        return actionDTO;
    }

    private static List<zpl__ContractLineItem__c> getCopiedLines() {
        List<zpl__ContractLineItem__c> copiedLineList = new List<zpl__ContractLineItem__c>();
        for (Integer i = 0; i < contractLines.size(); i++) {
            copiedLineList.add(
                new zpl__ContractLineItem__c(
                    Name = 'TestContractLine ' + i,
                    zpl__Contract__c = contracts[0].Id,
                    RecordTypeId = AIQ_DeleteLine.DRAFT_RECORD_TYPE_ID,
                    CBSSItemGroupingKey__c = '123',
                    zpl__Status__c = 'Draft'
                )
            );
        }
        return copiedLineList;
    }
}
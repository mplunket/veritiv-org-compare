@IsTest
public  class AIQ_CBSSIServiceTest {
    private static final String CBSSI_GROUPING_KEY = 'SW000001 (Item):0000001';

    private static List<zpl__ContractLineItem__c> lines;
    private static zpl__PolicyType__c policyTypeFixedPrice;
    private static AIQZilliantConfiguration__c zilliantConfiguration;

    private static Contract contract;

    static {
        zilliantConfiguration = AIQ_TestDataFactory.initializeZilliantConfiguration();
        policyTypeFixedPrice = AIQ_TestDataFactory.initializePolicyType(
            new zpl__PolicyType__c(
                    zpl__PolicyTypeId__c = AIQ_CBSSIDecreaseFinder.FIXED_PRICE
            ),
            true
        );

        contract = AIQ_TestDataFactory.initializeContracts(
            new Contract(
                    Name = 'Test Contract'
            ),
            1,
            true
        )[0];

        lines = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                    Name = 'Current Line 1',
                    CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
                    zpl__EffectiveDate__c = Date.today().addDays(3),
                    zpl__Status__c = 'Draft',
                    RecordTypeId = AIQ_CBSSIGroupDomain.LINE_DRAFT_RECORD_TYPE_ID,
                    zpl__ContractLineItemId__c = AIQ_CommonUtil.getGuid(),
                    zpl__Contract__r = contract,
                    zpl__PolicyType__r = policyTypeFixedPrice,
                    PreviousPrice__c = 7.23,
                    Net_Price__c = 2.24,
                    PriceDecreaseFlag__c = false
            ),
            1,
            true,
            false
        );
    }

    @IsTest
    private static void testAlignBeforePublish() {
        AIQ_CBSSIGroupProvider cbssiGroupProvider = new AIQ_CBSSIGroupProvider();
        AIQ_CBSSIService cbssiGroupService = new AIQ_CBSSIService();
        cbssiGroupService.cbssiGroupProvider = cbssiGroupProvider;
        mockDependencies(cbssiGroupProvider, lines);
        Test.startTest();
        List<zpl__ContractLineItem__c> alignedLinesBeforePublish = cbssiGroupService.alignBeforePublish(lines);
        Test.stopTest();
        Assert.isNotNull(alignedLinesBeforePublish, 'list of the records is not null');
        Assert.areEqual(lines.size(), alignedLinesBeforePublish.size(), 'list of the records is not empty');
    }

    @IsTest
    private static void testAlignAfterPublish() {
        AIQ_CBSSIGroupProvider cbssiGroupProvider = new AIQ_CBSSIGroupProvider();
        AIQ_CBSSIService cbssiGroupService = new AIQ_CBSSIService();
        cbssiGroupService.cbssiGroupProvider = cbssiGroupProvider;
        mockDependencies(cbssiGroupProvider, lines);
        Test.startTest();
        List<zpl__ContractLineItem__c> alignedLinesAfterPublish = cbssiGroupService.alignAfterPublish(lines);
        Test.stopTest();
        Assert.isNotNull(alignedLinesAfterPublish, 'list of the records is not null');
        Assert.areEqual(0, alignedLinesAfterPublish.size(), 'list is e,pty as line didn`t change');
    }

    private static void mockDependencies(AIQ_CBSSIGroupProvider cbssiGroupProvider, List<zpl__ContractLineItem__c> lines) {
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQ_ContractLineSelector contractLineSelector = (AIQ_ContractLineSelector) mocks.mock(AIQ_ContractLineSelector.class);
    
        mocks.startStubbing();
        mocks.when(contractLineSelector.queryContractLinesByCondition(
            AIQ_CBSSIGroupProvider.CONTRACT_LINES_QUERY_FIELDS,
            new zal.AndCondition()
            )
        ).thenReturnForAny(lines);
        mocks.when(contractLineSelector.getConditionByCbssiKey(new List<String> {CBSSI_GROUPING_KEY})).thenReturnForAny(new zal.AndCondition());
        mocks.when(contractLineSelector.getConditionByRecordType(new List<Id> {lines[0].RecordTypeId})).thenReturnForAny(new zal.AndCondition());
        mocks.stopStubbing();
        
        cbssiGroupProvider.contractLineSelector = contractLineSelector;
    }
    
}
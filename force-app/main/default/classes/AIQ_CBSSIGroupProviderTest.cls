@IsTest
public class AIQ_CBSSIGroupProviderTest {
    private static final String CBSSI_GROUPING_KEY = 'SW000001 (Item):0000001';
    private static final String CBSSI_GROUPING_KEY2 = 'SW000001 (Set):0000002';
    private static List<zpl__ContractLineItem__c> lines = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
            zpl__EffectiveDate__c = Date.today().addDays(3),
            zpl__Status__c = 'Draft',
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_DRAFT_RECORD_TYPE_ID,
            IsCurrent__c = true,
            SupersededDate__c = null
        ),
        2,
        true
    );
    private static List<zpl__ContractLineItem__c> linesWithSetKey = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY2,
            zpl__EffectiveDate__c = Date.today().addDays(3),
            zpl__Status__c = 'Draft',
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_DRAFT_RECORD_TYPE_ID,
            IsCurrent__c = true,
            SupersededDate__c = null,
            zpl__ContractLineItemId__c = AIQ_CommonUtil.getGuid()
        ),
        1,
        true
    );

    @IsTest
    private static void testProvideUsingListLines() {
        AIQ_CBSSIGroupProvider cbssiGroupProvider = new AIQ_CBSSIGroupProvider();
        mockDependencies(cbssiGroupProvider, lines);
        Test.startTest();
        List<AIQ_CBSSIGroupDomain> cbssiGroupDomains = cbssiGroupProvider.provide(lines, new List<Id> {AIQ_ContractLineSelector.LINE_DRAFT_RECORD_TYPE_ID});
        Test.stopTest();
        Assert.isNotNull(cbssiGroupDomains, 'cbssiGroupDomains are not null');
        Assert.areEqual(1, cbssiGroupDomains.size(), 'cbssiGroupDomains have one group');
    }

    @IsTest
    private static void testProvideUsingListLinesWithDifferentGroupKey() {
        AIQ_CBSSIGroupProvider cbssiGroupProvider = new AIQ_CBSSIGroupProvider();
        List<zpl__ContractLineItem__c> linesList = new List<zpl__ContractLineItem__c>(lines);
        linesList.addAll(linesWithSetKey);
        mockDependencies(cbssiGroupProvider, linesList);
        Test.startTest();
        List<AIQ_CBSSIGroupDomain> cbssiGroupDomains = cbssiGroupProvider.provide(lines, new List<Id> {AIQ_ContractLineSelector.LINE_DRAFT_RECORD_TYPE_ID});
        Test.stopTest();
        Assert.isNotNull(cbssiGroupDomains, 'cbssiGroupDomains are not null');
        Assert.areEqual(2, cbssiGroupDomains.size(), 'cbssiGroupDomains have one group');
    }

    @IsTest
    private static void testProvideUsingGroupKeys() {
        AIQ_CBSSIGroupProvider cbssiGroupProvider = new AIQ_CBSSIGroupProvider();
        mockDependencies(cbssiGroupProvider, lines);
        Test.startTest();
        List<AIQ_CBSSIGroupDomain> cbssiGroupDomains = cbssiGroupProvider.provide(
            new Set<String> {CBSSI_GROUPING_KEY},
            new List<Id> {AIQ_ContractLineSelector.LINE_DRAFT_RECORD_TYPE_ID}
        );
        Test.stopTest();
        Assert.isNotNull(cbssiGroupDomains, 'cbssiGroupDomains are not null');
        Assert.areEqual(1, cbssiGroupDomains.size(), 'cbssiGroupDomains have one group');
    }
    
    @IsTest
    private static void testProvideWithoutRecordTypeId() {
        AIQ_CBSSIGroupProvider cbssiGroupProvider = new AIQ_CBSSIGroupProvider();
        mockDependencies(cbssiGroupProvider, lines);
        Test.startTest();
        try {
            List<AIQ_CBSSIGroupDomain> cbssiGroupDomains = cbssiGroupProvider.provide(lines, new List<Id> {});
            Assert.fail('should not be here');
        } catch (Exception e) {
            Assert.areEqual('List of record type ids is empty', e.getMessage(), 'line group ket mismatch error message');
            Assert.isInstanceOfType(e, IllegalArgumentException.class, 'error type matches');
        }
       
        Test.stopTest();
    }

    @IsTest
    private static void testProvideWithNullRecordTypeId() {
        AIQ_CBSSIGroupProvider cbssiGroupProvider = new AIQ_CBSSIGroupProvider();
        mockDependencies(cbssiGroupProvider, lines);
        Test.startTest();
        try {
            List<AIQ_CBSSIGroupDomain> cbssiGroupDomains = cbssiGroupProvider.provide(lines, null);
            Assert.fail('should not be here');
        } catch (Exception e) {
            Assert.areEqual('List of record type ids is null', e.getMessage(), 'line group ket mismatch error message');
        }
       
        Test.stopTest();
    }

    @IsTest
    private static void testProvideWithoutLines() {
        AIQ_CBSSIGroupProvider cbssiGroupProvider = new AIQ_CBSSIGroupProvider();
        mockDependencies(cbssiGroupProvider, lines);
        Test.startTest();
        try {
            List<AIQ_CBSSIGroupDomain> cbssiGroupDomains = cbssiGroupProvider.provide(new List<zpl__ContractLineItem__c> (), new List<Id> {AIQ_ContractLineSelector.LINE_DRAFT_RECORD_TYPE_ID});
            Assert.fail('should not be here');
        } catch (Exception e) {
            Assert.areEqual('List of Contract Line Items is empty', e.getMessage(), 'line group ket mismatch error message');
            Assert.isInstanceOfType(e, IllegalArgumentException.class, 'error type matches');
        }

        Test.stopTest();
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
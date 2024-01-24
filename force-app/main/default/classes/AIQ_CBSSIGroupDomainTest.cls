@IsTest
public without sharing class AIQ_CBSSIGroupDomainTest {
    private static final String CBSSI_GROUPING_KEY = 'SW000001 (Item):0000001';
    private static final String CBSSI_GROUPING_KEY_MISMATCHING = 'SW000001 (Item):0000002';
    private static List<zpl__ContractLineItem__c> draftLines = AIQ_TestDataFactory.initializeContractsLines(
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
    private static List<zpl__ContractLineItem__c> activeLines = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
            zpl__EffectiveDate__c = Date.today().addDays(-3),
            zpl__Status__c = 'Published',
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID,
            IsCurrent__c = true,
            SupersededDate__c = null
        ),
        1,
        true
    );
    private static List<zpl__ContractLineItem__c> activeNextLines = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                    CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
                    zpl__EffectiveDate__c = Date.today(),
                    zpl__Status__c = 'Published',
                    RecordTypeId = AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID,
                    IsCurrent__c = true,
                    SupersededDate__c = null
            ),
            1,
            true
    );
    private static List<zpl__ContractLineItem__c> activeLinesForRealign = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
            zpl__EffectiveDate__c = Date.today().addDays(3),
            zpl__Status__c = 'Published',
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID,
            IsCurrent__c = false,
            SupersededDate__c = System.today().addDays(-1)
        ),
        1,
        true
    );
    private static List<zpl__ContractLineItem__c> activeDuplicatedLines = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
            zpl__EffectiveDate__c = Date.today().addDays(-3),
            zpl__Status__c = 'Published',
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID,
            IsCurrent__c = true,
            SupersededDate__c = null,
            zpl__ContractLineItemId__c = AIQ_CommonUtil.getGuid()
        ),
        2,
        true
    );
    private static List<zpl__ContractLineItem__c> activeSupersededDuplicatedLines = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
            zpl__EffectiveDate__c = Date.today().addDays(-3),
            zpl__Status__c = 'Published',
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID,
            IsCurrent__c = false,
            SupersededDate__c = Date.today(),
            zpl__ContractLineItemId__c = AIQ_CommonUtil.getGuid()
        ),
        2,
        true
    );
    private static List<zpl__ContractLineItem__c> inactiveLines = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
            zpl__EffectiveDate__c = Date.today().addMonths(-1),
            zpl__Status__c = 'Deleted',
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_INACTIVE_RECORD_TYPE_ID,
            IsCurrent__c = false,
            SupersededDate__c = System.today().addDays(-3)
        ),
        2,
        true
    );
    private static List<zpl__ContractLineItem__c> inactiveLinesForRealign = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
            zpl__EffectiveDate__c = Date.today().addMonths(-1),
            zpl__Status__c = 'Deleted',
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_INACTIVE_RECORD_TYPE_ID,
            IsCurrent__c = true,
            SupersededDate__c = null
        ),
        2,
        true
    );
    private static List<zpl__ContractLineItem__c> supersededLines = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = CBSSI_GROUPING_KEY,
            zpl__EffectiveDate__c = Date.today().addMonths(-2),
            zpl__Status__c = 'Published',
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID,
            IsCurrent__c = false,
            SupersededDate__c = System.today().addMonths(-1)
        ),
        1,
        true
    );

    @IsTest
    private static void testAddLinesWithUniqueId() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        List<AIQ_CBSSILine> cbssiLines = cbssiGroup.addLines(activeLines, false).addLines(draftLines, false).getGroupLines();
        Test.stopTest();
        Assert.areEqual(activeLines.size() + draftLines.size(), cbssiLines.size(), 'number of lines matches');
        Assert.isTrue(
            cbssiLines[0].line.zpl__EffectiveDate__c > cbssiLines[cbssiLines.size() - 1].line.zpl__EffectiveDate__c,
            'lines are sorted by Effective Date in DESC order'
        );
    }

    @IsTest
    private static void testAddLinesWithDuplicatedId() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        List<AIQ_CBSSILine> cbssiLines = cbssiGroup.addLines(activeDuplicatedLines, false).getGroupLines();
        Test.stopTest();
        Assert.areEqual(1, cbssiLines.size(), 'number of lines matches, duplicates removed');
    }

    @IsTest
    private static void testAddLinesWithMismatchingGroupKey() {
        Test.startTest();
        try {
            AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY_MISMATCHING);
            List<AIQ_CBSSILine> cbssiLines = cbssiGroup.addLines(activeDuplicatedLines, false).getGroupLines();
            Assert.fail('should not be here');
        } catch (Exception e) {
            Assert.areEqual(AIQ_CBSSIGroupDomain.LINE_GROUP_KEY_MISMATCH_ERROR, e.getMessage(), 'line group ket mismatch error message');
            Assert.isInstanceOfType(e, IllegalArgumentException.class, 'error type matches');
        }
        Test.stopTest();
    }

    @IsTest
    private static void testGetEffectiveLine() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        zpl__ContractLineItem__c effectiveLine = cbssiGroup.addLines(draftLines, false)
            .addLines(activeLines, false)
            .addLines(inactiveLines, false)
            .addLines(supersededLines, false)
            .getEffectiveLine();
        Test.stopTest();
        Assert.areEqual(Date.today().addDays(-3), effectiveLine.zpl__EffectiveDate__c, 'match start date of the effective line');
        Assert.isTrue(effectiveLine.isCurrent__c, 'the effective line is always current one');
        Assert.isNull(effectiveLine.SupersededDate__c, 'the effective line does not have superseded date');
    }

    @IsTest
    private static void testGetNextActiveLineExists() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        zpl__ContractLineItem__c nextEffectiveLine = cbssiGroup.addLines(draftLines, false)
            .addLines(inactiveLines, false)
            .addLines(supersededLines, false)
            .addLines(activeLines, false)
            .getNextActiveLine(supersededLines[0]);
        Test.stopTest();
        Assert.areEqual(Date.today().addDays(-3), nextEffectiveLine.zpl__EffectiveDate__c, 'match start date of the next effective line');
        Assert.isTrue(nextEffectiveLine.isCurrent__c, 'the next effective line is always current one');
        Assert.isNull(nextEffectiveLine.SupersededDate__c, 'the next effective line does not have superseded date');
    }

    @IsTest
    private static void testGetNextActiveLineNull() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        zpl__ContractLineItem__c nextEffectiveLine = cbssiGroup
            .addLines(inactiveLines, false)
            .addLines(supersededLines, false)
            .getNextActiveLine(inactiveLines[0]);
        Test.stopTest();
        Assert.isNull(nextEffectiveLine, 'the next effective line does not exist');
    }

    @IsTest
    private static void testGetPriorLineExists() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        zpl__ContractLineItem__c priorEffectiveLine = cbssiGroup.addLines(draftLines, false)
            .addLines(inactiveLines, false)
            .addLines(supersededLines, false)
            .addLines(activeLines, false)
            .getPriorLine(activeLines[0], null);
        Test.stopTest();
        Assert.areEqual(supersededLines[0].zpl__EffectiveDate__c, priorEffectiveLine.zpl__EffectiveDate__c, 'match start date of the prior effective line');
        Assert.isFalse(priorEffectiveLine.isCurrent__c, 'the prior effective line is no longer current one');
        Assert.isNotNull(priorEffectiveLine.SupersededDate__c, 'the prior effective line has superseded date');
    }

    @IsTest
    private static void testGetPriorLineNull() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        zpl__ContractLineItem__c priorEffectiveLine = cbssiGroup.addLines(draftLines, false)
            .addLines(inactiveLines, false)
            .addLines(activeLines, false)
            .getPriorLine(activeLines[0], null);
        Test.stopTest();
        Assert.isNull(priorEffectiveLine, 'the prior effective line does not exist');
    }

    @IsTest
    private static void testGetPriorLineNullWithoutInactiveLines() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        zpl__ContractLineItem__c priorEffectiveLine = cbssiGroup.addLines(draftLines, false)
            .addLines(activeLines, false)
            .getPriorLine(activeLines[0], null);
        Test.stopTest();
        Assert.isNull(priorEffectiveLine, 'the prior effective line does not exist');
    }

    @IsTest
    private static void testSetOfCbssiGroups() {
        Test.startTest();
        Set<AIQ_CBSSIGroupDomain> groupSet = new Set<AIQ_CBSSIGroupDomain>();
        groupSet.add(new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY));
        groupSet.add(new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY_MISMATCHING));
        Test.stopTest();
        Assert.isTrue(groupSet.contains(new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY)), 'group with such CBSSI group key exists');
        Assert.isFalse(groupSet.contains(new AIQ_CBSSIGroupDomain('some fake group key')), 'group with such CBSSI group key does not exist');
    }

    @IsTest
    private static void testListOfCbssiGroups() {
        Test.startTest();
        List<AIQ_CBSSIGroupDomain> groupList = new List<AIQ_CBSSIGroupDomain>();
        groupList.add(new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY));
        groupList.add(new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY_MISMATCHING));
        Test.stopTest();
        Assert.isTrue(groupList.contains(new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY)), 'group with such CBSSI group key exists');
        Assert.isFalse(groupList.contains(new AIQ_CBSSIGroupDomain('some fake group key')), 'group with such CBSSI group key does not exist');
    }

    @IsTest
    private static void testGetLine() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        List<AIQ_CBSSILine> cbssiLines = cbssiGroup.addLines(activeLines, false).getGroupLines();
        zpl__ContractLineItem__c line = cbssiGroup.getLine(activeLines[0]);
        Test.stopTest();
        Assert.areEqual(activeLines[0], line, 'get expected line');
    }

    @IsTest
    private static void testGetLineNegative() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        zpl__ContractLineItem__c line = cbssiGroup.getLine(activeLines[0]);
        Test.stopTest();
        Assert.areEqual(null, line, 'get line negative scenario');
    }

    @IsTest
    private static void testInactivateDuplicates() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        List<AIQ_CBSSILine> cbssiLines = cbssiGroup.addLines(activeLines, false).addLines(activeDuplicatedLines, false).getGroupLines();
        zpl__ContractLineItem__c line = cbssiGroup.getLine(activeDuplicatedLines[0]);
        Assert.areEqual('Published', line.zpl__Status__c, 'value reset as expected');
        cbssiGroup = cbssiGroup.realign(activeLines[0]);
        line = cbssiGroup.getLine(activeDuplicatedLines[0]);
        Test.stopTest();
        Assert.areEqual(2, cbssiLines.size(), 'number of lines matches');
        Assert.areEqual('Deleted', line.zpl__Status__c, 'value reset as expected');
    }

    @IsTest
    private static void testInactivateSupersededDuplicates() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        List<AIQ_CBSSILine> cbssiLines = cbssiGroup.addLines(activeLines, false).addLines(activeSupersededDuplicatedLines, false).getGroupLines();
        zpl__ContractLineItem__c supersededLine = cbssiGroup.getLine(activeSupersededDuplicatedLines[0]);
        Assert.areEqual('Published', supersededLine.zpl__Status__c, 'value reset as expected');
        cbssiGroup = cbssiGroup.realign(activeSupersededDuplicatedLines[0]);
        supersededLine = cbssiGroup.getLine(activeSupersededDuplicatedLines[0]);
        Test.stopTest();
        Assert.areEqual(2, cbssiLines.size(), 'Number of lines matches');
        Assert.areEqual('Published', supersededLine.zpl__Status__c, 'Fast fail check work as expected, status did not change');
    }

    @IsTest
    private static void testGetChangedLinesNegative() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        List<AIQ_CBSSILine> cbssiLines = cbssiGroup.addLines(activeLines, false).getGroupLines();
        list<zpl__ContractLineItem__c> changedLines = cbssiGroup.getChangedLines();
        Test.stopTest();
        Assert.areEqual(0, changedLines.size(), 'get expected line');
    }

    @IsTest
    private static void testGetChangedLinesWithoutOriginalNagative() {
        Test.startTest();
        AIQ_CBSSIGroupDomain cbssiGroup = new AIQ_CBSSIGroupDomain(CBSSI_GROUPING_KEY);
        List<AIQ_CBSSILine> cbssiLines = cbssiGroup.addLines(activeLines, false).getGroupLines();
        list<zpl__ContractLineItem__c> changedLines = cbssiGroup.getChangedLinesWithoutOriginal();
        Test.stopTest();
        Assert.areEqual(0, changedLines.size(), 'get expected line');
    }
}
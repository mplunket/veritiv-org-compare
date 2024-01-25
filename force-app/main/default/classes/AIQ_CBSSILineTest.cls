@IsTest
public without sharing class AIQ_CBSSILineTest {
    private static final String guid1 = AIQ_CommonUtil.getGuid();
    private static zpl__ContractLineItem__c line1 = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = 'composite key 1',
            zpl__EffectiveDate__c = Date.valueOf('2023-01-01'),
            zpl__Status__c = 'Published',
            zpl__ContractLineItemId__c = guid1,
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID,
            IsCurrent__c = true
        ),
        1,
        true
    )[0];
    private static zpl__ContractLineItem__c line2 = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = 'composite key 2',
            zpl__EffectiveDate__c = Date.valueOf('2023-02-01'),
            zpl__Status__c = 'Published',
            zpl__ContractLineItemId__c = AIQ_CommonUtil.getGuid(),
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID,
            IsCurrent__c = true
        ),
        1,
        true
    )[0];
    private static zpl__ContractLineItem__c line3 = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = 'composite key 3',
            zpl__EffectiveDate__c = Date.valueOf('2023-03-01'),
            zpl__Status__c = 'Published',
            zpl__ContractLineItemId__c = AIQ_CommonUtil.getGuid(),
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID,
            IsCurrent__c = true
        ),
        1,
        true
    )[0];
    private static zpl__ContractLineItem__c line4 = AIQ_TestDataFactory.initializeContractsLines(
        new zpl__ContractLineItem__c(
            CBSSItemGroupingKey__c = 'composite key 4',
            zpl__EffectiveDate__c = Date.valueOf('2023-04-01'),
            zpl__Status__c = 'Published',
            zpl__ContractLineItemId__c = guid1,
            RecordTypeId = AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID,
            IsCurrent__c = true
        ),
        1,
        true
    )[0];

    private static zpl__ContractLineItem__c prototype5 = new zpl__ContractLineItem__c(
        CBSSItemGroupingKey__c = 'composite key 5',
        zpl__EffectiveDate__c = Date.valueOf('2023-03-01'),
        zpl__Status__c = 'Draft',
        zpl__ContractLineItemId__c = guid1,
        IsCurrent__c = false,
        zpl__PolicyValue__c = -99
    );

    private static zpl__ContractLineItem__c line5 = AIQ_TestDataFactory.initializeContractsLines(prototype5, 1, true)[0];

    private static List<AIQ_CBSSILine> listOfLines = new List<AIQ_CBSSILine>{ new AIQ_CBSSILine(line1), new AIQ_CBSSILine(line2) };
    private static Set<AIQ_CBSSILine> setOfLines = new Set<AIQ_CBSSILine>{ new AIQ_CBSSILine(line1), new AIQ_CBSSILine(line2) };

    @IsTest
    private static void testListContains() {
        Test.startTest();
        Assert.isTrue(listOfLines.contains(new AIQ_CBSSILine(line1)), 'list contains line1');
        Assert.isFalse(listOfLines.contains(new AIQ_CBSSILine(line3)), 'list does not contain line3');
        Test.stopTest();
    }

    @IsTest
    private static void testSetContains() {
        Test.startTest();
        Assert.isTrue(setOfLines.contains(new AIQ_CBSSILine(line1)), 'set contains line1');
        Assert.isFalse(setOfLines.contains(new AIQ_CBSSILine(line3)), 'set does not contain line3');
        Test.stopTest();
    }

    @IsTest
    private static void testListIndexOf() {
        Test.startTest();
        Assert.areEqual(0, listOfLines.indexOf(new AIQ_CBSSILine(line1)), 'list index of the line1 is 0');
        Assert.areEqual(1, listOfLines.indexOf(new AIQ_CBSSILine(line2)), 'list index of the line2 is 1');
        Assert.areEqual(-1, listOfLines.indexOf(new AIQ_CBSSILine(line3)), 'list index of the line3 is -1');
        Test.stopTest();
    }

    @IsTest
    private static void testSortedListIndexOf() {
        Test.startTest();
        listOfLines.sort();
        Assert.areEqual(0, listOfLines.indexOf(new AIQ_CBSSILine(line2)), 'list index of the line2 is 0');
        Assert.areEqual(1, listOfLines.indexOf(new AIQ_CBSSILine(line1)), 'list index of the line1 is 1');
        Assert.areEqual(-1, listOfLines.indexOf(new AIQ_CBSSILine(line3)), 'list index of the line3 is -1');
        Test.stopTest();
    }

    @IsTest
    private static void testSortedListWithAddingLineViaSet() {
        Test.startTest();
        Boolean hasChanged = setOfLines.add(new AIQ_CBSSILine(line4));
        List<AIQ_CBSSILine> innerListOfLines = new List<AIQ_CBSSILine>(setOfLines);
        innerListOfLines.sort();
        Assert.isFalse(hasChanged, 'set did not change since the line with this key is present');
        Assert.areEqual(listOfLines.size(), innerListOfLines.size(), 'list size matches');
        Assert.areEqual(0, innerListOfLines.indexOf(new AIQ_CBSSILine(line2)), 'list index of the line2 is 0');
        Assert.areEqual(line2.zpl__EffectiveDate__c, innerListOfLines[0].line.zpl__EffectiveDate__c, 'most recent line goes first');
        Assert.areEqual(1, innerListOfLines.indexOf(new AIQ_CBSSILine(line1)), 'list index of the line1 is 1');
        Test.stopTest();
    }

    @IsTest
    private static void testReplaceElementViaSet() {
        Test.startTest();
        Boolean hasChanged = setOfLines.remove(new AIQ_CBSSILine(line4));
        setOfLines.add(new AIQ_CBSSILine(line4));
        List<AIQ_CBSSILine> innerListOfLines = new List<AIQ_CBSSILine>(setOfLines);
        innerListOfLines.sort();
        Assert.isTrue(hasChanged, 'set changed since the line with this key is replaced');
        Assert.areEqual(listOfLines.size(), innerListOfLines.size(), 'list size matches');
        Assert.areEqual(0, innerListOfLines.indexOf(new AIQ_CBSSILine(line4)), 'list index of the line4 is 0');
        Assert.areEqual(line4.zpl__EffectiveDate__c, innerListOfLines[0].line.zpl__EffectiveDate__c, 'most recent line goes first');
        Assert.areEqual(1, innerListOfLines.indexOf(new AIQ_CBSSILine(line2)), 'list index of the line2 is 1');
        Test.stopTest();
    }

    @IsTest
    private static void testMergeLines() {
        Test.startTest();
        AIQ_CBSSILine cbssiLine = new AIQ_CBSSILine(line4);
        cbssiLine.mergeTo(line5);
        Test.stopTest();
        Assert.areNotEqual(line5.get('zpl__Status__c'), line4.get('zpl__Status__c'), 'The existing field on target remains intact');
        Assert.areEqual(true, line4.get('IsCurrent__c'), 'The existing field on target remains intact');
        Assert.isNotNull(line4.get('zpl__PolicyValue__c'), 'New field is added to the target from the source');
    }
}
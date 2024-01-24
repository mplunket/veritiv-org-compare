@IsTest
private class AIQ_CBSSIPriorToCurrentConvertorTest {
    private static final String CWT_FIXED = 'cwtFixed';
    private static zpl__ProductUOM__c uom1;
    private static zpl__ProductUOM__c uom2;
    private static zpl__PolicyType__c policyType1;
    private static zpl__PolicyType__c policyType2;
    private static zpl__PolicyType__c policyType3;
    private static Contract contract;
    private static zpl__ContractLineItem__c lineToUpdate;
    private static zpl__ContractLineItem__c currentLine1;
    private static zpl__ContractLineItem__c currentLine2;
    private static zpl__ContractLineItem__c currentLine3;
    private static zpl__ContractLineItem__c priorLine1;
    private static zpl__ContractLineItem__c priorLine2;

    static {
        uom1 = AIQ_TestDataFactory.initializeProductUOM(
                new zpl__ProductUOM__c(
                        Name = 'M',
                        zpl__ConversionFactor__c = 1
                ),
                true
        );
        uom2 = AIQ_TestDataFactory.initializeProductUOM(
                new zpl__ProductUOM__c(
                        Name = 'M',
                        zpl__ConversionFactor__c = -1
                ),
                true
        );
        policyType1 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = AIQ_CBSSIPriorToCurrentConvertor.MAINTAIN_GTM
                ),
                true
        );
        policyType2 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = AIQ_CBSSIPriorToCurrentConvertor.LIST_DOWN
                ),
                true
        );
        policyType3 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = CWT_FIXED
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
        lineToUpdate = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Line To Update',
                        zpl__Contract__r = contract,
                        zpl__PolicyType__r = policyType1,
                        zpl__UOM__r = uom1,
                        PublishedPrice__c = 5.58,
                        PublishedCost__c = 3.45,
                        PreviousPrice__c = 7.23,
                        PreviousCost__c = 1.56,
                        X12MonthSalesVolume__c = 6.00
                ),
                1,
                true,
                false
        )[0];
        currentLine1 = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Current Line 1',
                        zpl__Contract__r = contract,
                        zpl__PolicyType__r = policyType1,
                        zpl__UOM__r = uom1,
                        PublishedPrice__c = 5.58,
                        PublishedCost__c = 3.45,
                        PreviousPrice__c = 7.23,
                        PreviousCost__c = 1.56,
                        X12MonthSalesVolume__c = 6.00
                ),
                1,
                true,
                false
        )[0];
        currentLine2 = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Current Line 2',
                        zpl__Contract__r = contract,
                        zpl__PolicyType__r = policyType2,
                        PublishedPrice__c = 5.58,
                        PublishedCost__c = 3.45,
                        PreviousPrice__c = 7.23,
                        PreviousCost__c = 1.56,
                        X12MonthSalesVolume__c = 6.00
                ),
                1,
                true,
                false
        )[0];
        currentLine3 = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Current Line 3',
                        zpl__Contract__r = contract,
                        zpl__PolicyType__r = policyType3,
                        PublishedPrice__c = 5.58,
                        PublishedCost__c = 3.45,
                        PreviousPrice__c = 7.23,
                        PreviousCost__c = 1.56,
                        X12MonthSalesVolume__c = 6.00
                ),
                1,
                true,
                false
        )[0];
        priorLine1 = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Prior Line 1',
                        zpl__Contract__r = contract,
                        zpl__PolicyType__r = policyType1,
                        zpl__UOM__r = uom2,
                        PublishedPrice__c = 9.15,
                        PublishedCost__c = 6.56,
                        PreviousPrice__c = 4.23,
                        PreviousCost__c = 2.56,
                        ListPrice__c = 3.55,
                        X12MonthSalesVolume__c = 7.00
                ),
                1,
                true,
                false
        ))[0];
        priorLine2 = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Prior Line 2',
                        zpl__Contract__r = contract,
                        zpl__PolicyType__r = policyType2,
                        zpl__UOM__r = uom2,
                        PublishedPrice__c = 9.15,
                        PublishedCost__c = 6.56,
                        PreviousPrice__c = 4.23,
                        PreviousCost__c = 2.56,
                        ListPrice__c = 3.55,
                        X12MonthSalesVolume__c = 7.00
                ),
                1,
                true,
                false
        ))[0];
    }

    @IsTest
    private static void testPriorFactorEqualsCurrentFactor() {
        priorLine1.zpl__UOM__r.zpl__ConversionFactor__c = 1;
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine1, priorLine1);
        Test.stopTest();

        Decimal expectedCurrentPrice = priorLine1.PublishedPrice__c;
        Decimal expectedCurrentCost = priorLine1.PublishedCost__c;
        Assert.areEqual(expectedCurrentPrice, lineToUpdate.PreviousPrice__c, 'Should be equal');
        Assert.areEqual(expectedCurrentCost, lineToUpdate.PreviousCost__c, 'Should be equal');
    }

    @IsTest
    private static void testPriorLessAndCurrentMoreThanZero() {
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine1, priorLine1);
        Test.stopTest();

        Decimal expectedCurrentPrice = (priorLine1.PublishedPrice__c *
                Math.abs(priorLine1.zpl__UOM__r.zpl__ConversionFactor__c) * Math.abs(currentLine1.zpl__UOM__r.zpl__ConversionFactor__c)).setScale(4);
        Decimal expectedCurrentCost = (priorLine1.PublishedCost__c *
                Math.abs(priorLine1.zpl__UOM__r.zpl__ConversionFactor__c) * Math.abs(currentLine1.zpl__UOM__r.zpl__ConversionFactor__c)).setScale(4);
        Assert.areEqual(expectedCurrentPrice, lineToUpdate.PreviousPrice__c, 'Should be equal');
        Assert.areEqual(expectedCurrentCost, lineToUpdate.PreviousCost__c, 'Should be equal');
    }

    @IsTest
    private static void testPriorLessAndCurrentLessThanZero() {
        currentLine1.zpl__UOM__r.zpl__ConversionFactor__c = -2;
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine1, priorLine1);
        Test.stopTest();

        Decimal expectedCurrentPrice = (priorLine1.PublishedPrice__c *
                Math.abs(priorLine1.zpl__UOM__r.zpl__ConversionFactor__c) / Math.abs(currentLine1.zpl__UOM__r.zpl__ConversionFactor__c)).setScale(4);
        Decimal expectedCurrentCost = (priorLine1.PublishedCost__c *
                Math.abs(priorLine1.zpl__UOM__r.zpl__ConversionFactor__c) / Math.abs(currentLine1.zpl__UOM__r.zpl__ConversionFactor__c)).setScale(4);
        Assert.areEqual(expectedCurrentPrice, lineToUpdate.PreviousPrice__c, 'Should be equal');
        Assert.areEqual(expectedCurrentCost, lineToUpdate.PreviousCost__c, 'Should be equal');
    }

    @IsTest
    private static void testPriorMoreAndCurrentLessThanZero() {
        currentLine1.zpl__UOM__r.zpl__ConversionFactor__c = -1;
        priorLine1.zpl__UOM__r.zpl__ConversionFactor__c = 2;
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine1, priorLine1);
        Test.stopTest();

        Decimal expectedCurrentPrice = (priorLine1.PublishedPrice__c /
                Math.abs(priorLine1.zpl__UOM__r.zpl__ConversionFactor__c) / Math.abs(currentLine1.zpl__UOM__r.zpl__ConversionFactor__c)).setScale(4);
        Decimal expectedCurrentCost = (priorLine1.PublishedCost__c /
                Math.abs(priorLine1.zpl__UOM__r.zpl__ConversionFactor__c) / Math.abs(currentLine1.zpl__UOM__r.zpl__ConversionFactor__c)).setScale(4);
        Assert.areEqual(expectedCurrentPrice, lineToUpdate.PreviousPrice__c, 'Should be equal');
        Assert.areEqual(expectedCurrentCost, lineToUpdate.PreviousCost__c, 'Should be equal');
    }

    @IsTest
    private static void testPriorMoreAndCurrentMoreThanZero() {
        priorLine1.zpl__UOM__r.zpl__ConversionFactor__c = 2;
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine1, priorLine1);
        Test.stopTest();

        Decimal expectedCurrentPrice = (priorLine1.PublishedPrice__c /
                Math.abs(priorLine1.zpl__UOM__r.zpl__ConversionFactor__c) * Math.abs(currentLine1.zpl__UOM__r.zpl__ConversionFactor__c)).setScale(4);
        Decimal expectedCurrentCost = (priorLine1.PublishedCost__c /
                Math.abs(priorLine1.zpl__UOM__r.zpl__ConversionFactor__c) * Math.abs(currentLine1.zpl__UOM__r.zpl__ConversionFactor__c)).setScale(4);
        Assert.areEqual(expectedCurrentPrice, lineToUpdate.PreviousPrice__c, 'Should be equal');
        Assert.areEqual(expectedCurrentCost, lineToUpdate.PreviousCost__c, 'Should be equal');
    }

    @IsTest
    private static void testConvertPriceAndCostWithoutAnyConditions() {
        currentLine1.zpl__UOM__r.zpl__ConversionFactor__c = 0;
        priorLine1.zpl__UOM__r.zpl__ConversionFactor__c = 0;
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine1, priorLine1);
        Test.stopTest();

        Assert.areEqual(priorLine1.PublishedPrice__c, lineToUpdate.PreviousPrice__c, 'Should be equal');
        Assert.areEqual(priorLine1.PublishedCost__c, lineToUpdate.PreviousCost__c, 'Should be equal');
    }

    @IsTest
    private static void testConvertRevenueCase1() {
        currentLine1.X12MonthSalesVolume__c = null;
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine1, priorLine1);
        Test.stopTest();

        Decimal expectedRevenue = priorLine1.X12MonthSalesVolume__c;
        Assert.areEqual(expectedRevenue, lineToUpdate.X12MonthSalesVolume__c, 'Should be equal');
    }

    @IsTest
    private static void testConvertRevenueCase2() {
        currentLine1.X12MonthSalesVolume__c = null;
        priorLine1.X12MonthSalesVolume__c = null;
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine1, priorLine1);
        Test.stopTest();

        Decimal expectedResult = 0;
        Assert.areEqual(expectedResult, lineToUpdate.X12MonthSalesVolume__c, 'Should be equal');
    }

    @IsTest
    private static void testGetPublishedMarginCase1() {
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine1, priorLine1);
        Test.stopTest();

        Decimal expectedResult = (1 - priorLine1.PublishedCost__c / priorLine1.PublishedPrice__c).setScale(6);
        Assert.areEqual(expectedResult, lineToUpdate.PreviousValue__c, 'Should be equal');
    }

    @IsTest
    private static void testGetPublishedMarginCase2() {
        priorLine1.PublishedPrice__c = 0;
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine1, priorLine1);
        Test.stopTest();

        Decimal expectedResult = priorLine1.zpl__PolicyValue__c;
        Assert.areEqual(expectedResult, lineToUpdate.PreviousValue__c, 'Should be equal');
    }

    @IsTest
    private static void testGetPublishedMarginCase3() {
        priorLine2.PublishedPrice__c = 0;
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine1, priorLine2);
        Test.stopTest();

        Decimal expectedResult = 0;
        Assert.areEqual(expectedResult, lineToUpdate.PreviousValue__c, 'Should be equal');
    }

    @IsTest
    private static void testGetPublishedDiscountCase1() {
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine2, priorLine2);
        Test.stopTest();

        Decimal expectedResult = (priorLine2.PublishedPrice__c / priorLine2.ListPrice__c - 1).setScale(6);
        Assert.areEqual(expectedResult, lineToUpdate.PreviousValue__c, 'Should be equal');
    }

    @IsTest
    private static void testGetPublishedDiscountCase2() {
        priorLine2.ListPrice__c = 0;
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine2, priorLine2);
        Test.stopTest();

        Decimal expectedResult = priorLine2.zpl__PolicyValue__c;
        Assert.areEqual(expectedResult, lineToUpdate.PreviousValue__c, 'Should be equal');
    }

    @IsTest
    private static void testGetPublishedDiscountCase3() {
        priorLine1.ListPrice__c = 0;
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine2, priorLine1);
        Test.stopTest();

        Decimal expectedResult = 0;
        Assert.areEqual(expectedResult, lineToUpdate.PreviousValue__c, 'Should be equal');
    }

    @IsTest
    private static void testLineWithInappropriatePolicyType() {
        Test.startTest();
            AIQ_CBSSIPriorToCurrentConvertor.convert(lineToUpdate, currentLine3, priorLine1);
        Test.stopTest();

        Decimal expectedValue = lineToUpdate.PreviousPrice__c;
        Assert.areEqual(expectedValue, lineToUpdate.PreviousValue__c, 'Should be equal');
    }
}
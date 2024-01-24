@IsTest
private class AIQ_CBSSIDecreaseFinderTest {
    private static AIQZilliantConfiguration__c zilliantConfiguration;
    private static zpl__PolicyType__c policyType1;
    private static zpl__PolicyType__c policyType2;
    private static zpl__PolicyType__c policyType3;
    private static zpl__PolicyType__c policyType4;
    private static zpl__PolicyType__c policyType5;
    private static Contract contract;
    private static zpl__ContractLineItem__c currentLine1;
    private static zpl__ContractLineItem__c currentLine2;
    private static zpl__ContractLineItem__c currentLine3;
    private static zpl__ContractLineItem__c currentLine4;
    private static zpl__ContractLineItem__c currentLine5;

    static {
        zilliantConfiguration = AIQ_TestDataFactory.initializeZilliantConfiguration();
        policyType1 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = AIQ_CBSSIDecreaseFinder.FIXED_PRICE
                ),
                true
        );
        policyType2 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = AIQ_CBSSIDecreaseFinder.MAINTAIN_GTM
                ),
                true
        );
        policyType3 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = AIQ_CBSSIDecreaseFinder.LIST_DOWN
                ),
                true
        );
        policyType4 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = AIQ_CBSSIDecreaseFinder.NATIONAL_ACCOUNT
                ),
                true
        );
        policyType5 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'Unknown Policy Type'
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
        currentLine1 = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Current Line 1',
                        zpl__Contract__r = contract,
                        zpl__PolicyType__r = policyType1,
                        PreviousPrice__c = 7.23,
                        Net_Price__c = 2.24,
                        PriceDecreaseFlag__c = false
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
                        PreviousValue__c = 3.67,
                        zpl__PolicyValue__c = 1.22,
                        PriceDecreaseFlag__c = false
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
                        PreviousValue__c = 3.67,
                        zpl__PolicyValue__c = 4.22,
                        PriceDecreaseFlag__c = false
                ),
                1,
                true,
                false
        )[0];
        currentLine4 = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Current Line 4',
                        zpl__Contract__r = contract,
                        zpl__PolicyType__r = policyType4,
                        Net_Price__c = 0,
                        zpl__PolicyValue__c = null,
                        IsNAPriced__c = true
                ),
                1,
                true,
                false
        )[0];
        currentLine5 = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Current Line 5',
                        zpl__Contract__r = contract,
                        zpl__PolicyType__r = policyType5,
                        PreviousPrice__c = 7.23,
                        Net_Price__c = 2.24,
                        PriceDecreaseFlag__c = false
                ),
                1,
                true,
                false
        )[0];
    }

    @IsTest
    private static void testFixedDecreaseFinderCase1() {
        currentLine1.Net_Price__c = 0;
        Test.startTest();
            AIQ_CBSSIDecreaseFinder.getInstance(currentLine1.zpl__PolicyType__r.zpl__PolicyTypeId__c).hasDecrease(currentLine1);
        Test.stopTest();

        Assert.isTrue(currentLine1.PriceDecreaseFlag__c, 'Price Decrease should be equal to true');
    }

    @IsTest
    private static void testFixedDecreaseFinderCase2() {
        Test.startTest();
            AIQ_CBSSIDecreaseFinder.getInstance(currentLine1.zpl__PolicyType__r.zpl__PolicyTypeId__c).hasDecrease(currentLine1);
        Test.stopTest();

        Assert.isTrue(currentLine1.PriceDecreaseFlag__c, 'Price Decrease should be equal to true');
    }

    @IsTest
    private static void testFixedDecreaseFinderCase3() {
        currentLine1.Net_Price__c = 12;
        Test.startTest();
            AIQ_CBSSIDecreaseFinder.getInstance(currentLine1.zpl__PolicyType__r.zpl__PolicyTypeId__c).hasDecrease(currentLine1);
        Test.stopTest();

        Assert.isFalse(currentLine1.PriceDecreaseFlag__c, 'Price Decrease should be equal to false');
    }

    @IsTest
    private static void testMarginDecreaseFinderCase1() {
        Test.startTest();
            AIQ_CBSSIDecreaseFinder.getInstance(currentLine2.zpl__PolicyType__r.zpl__PolicyTypeId__c).hasDecrease(currentLine2);
        Test.stopTest();

        Assert.isTrue(currentLine2.PriceDecreaseFlag__c, 'Margin Decrease should be equal to true');
    }

    @IsTest
    private static void testMarginDecreaseFinderCase2() {
        currentLine2.zpl__PolicyValue__c = 5.22;
        Test.startTest();
            AIQ_CBSSIDecreaseFinder.getInstance(currentLine2.zpl__PolicyType__r.zpl__PolicyTypeId__c).hasDecrease(currentLine2);
        Test.stopTest();

        Assert.isFalse(currentLine2.PriceDecreaseFlag__c, 'Margin Decrease should be equal to false');
    }

    @IsTest
    private static void testDiscountDecreaseFinderCase1() {
        Test.startTest();
            AIQ_CBSSIDecreaseFinder.getInstance(currentLine3.zpl__PolicyType__r.zpl__PolicyTypeId__c).hasDecrease(currentLine3);
        Test.stopTest();

        Assert.isFalse(currentLine3.PriceDecreaseFlag__c, 'Discount Decrease should be equal to false');
    }

    @IsTest
    private static void testDiscountDecreaseFinderCase2() {
        currentLine3.zpl__PolicyValue__c = 1.22;
        Test.startTest();
            AIQ_CBSSIDecreaseFinder.getInstance(currentLine3.zpl__PolicyType__r.zpl__PolicyTypeId__c).hasDecrease(currentLine3);
        Test.stopTest();

        Assert.isTrue(currentLine3.PriceDecreaseFlag__c, 'Discount Decrease should be equal to true');
    }

    @IsTest
    private static void testNationalAccountFinder() {
        Test.startTest();
            AIQ_CBSSIDecreaseFinder.getInstance(currentLine4.zpl__PolicyType__r.zpl__PolicyTypeId__c).hasDecrease(currentLine4);
        Test.stopTest();

        Assert.areEqual('nationalAccount', currentLine4.zpl__PolicyType__r.zpl__PolicyTypeId__c, 'Policy Type should be equal');
        Assert.isFalse(currentLine4.PriceDecreaseFlag__c, 'National Account should be equal to false by default');
    }

    @IsTest
    private static void testNoDecreaseFinder() {
        String errorMsg;
        Test.startTest();
            Boolean decreaseFlag = AIQ_CBSSIDecreaseFinder.getInstance(currentLine5.zpl__PolicyType__r.zpl__PolicyTypeId__c).hasDecrease(currentLine5);
        Test.stopTest();

        Assert.areEqual('Unknown Policy Type', currentLine5.zpl__PolicyType__r.zpl__PolicyTypeId__c, 'No any price deacrease');
        Assert.isFalse(decreaseFlag, 'Should be equal to false');
    }
}
@IsTest
public without sharing class AIQ_FormulaEvaluatorUtilTest {
    private static final Schema.SObjectType CLI_SOBJECT_TYPE = Schema.zpl__ContractLineItem__c.SObjectType;
    private static AIQZilliantConfiguration__c configuration = AIQ_TestDataFactory.initializeZilliantConfiguration();
    private static zpl__ProductSelectorConfiguration__c productSelector;
    private static Map<String, zpl__LineLevel__c> lineLevels;
    private static List<zpl__ContractLineItem__c> contractLinesFesActive = new List<zpl__ContractLineItem__c>();
    private static List<zpl__ContractLineItem__c> contractLinesFesInactive = new List<zpl__ContractLineItem__c>();

    static {
        productSelector = AIQ_TestDataFactory.initializeProductSelectorConfiguration(null, false);
        lineLevels = AIQ_TestDataFactory.initializeAllLineLevels(
            new zpl__LineLevel__c(zpl__ProductSelectorConfiguration__c = productSelector.Id),
            false
        );

        contractLinesFesActive.addAll(
            AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(zpl__Status__c = 'Draft', zpl__LineLevel__c = lineLevels.get('Item').Id),
                1,
                true
            )
        );
        contractLinesFesActive.addAll(
            AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(zpl__Status__c = 'Draft', zpl__LineLevel__c = lineLevels.get('Subset').Id),
                1,
                true
            )
        );
        contractLinesFesActive.addAll(
            AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(zpl__Status__c = 'Draft', zpl__LineLevel__c = lineLevels.get('Set').Id),
                1,
                true
            )
        );

        contractLinesFesInactive.addAll(
            AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(zpl__Status__c = 'Draft', zpl__LineLevel__c = lineLevels.get('Class').Id),
                1,
                true
            )
        );
        contractLinesFesInactive.addAll(
            AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(zpl__Status__c = 'Draft', zpl__LineLevel__c = lineLevels.get('Brand').Id),
                1,
                true
            )
        );
    }
    

    @IsTest
    private static void testEvaluateFesActiveLines() {
        AIQ_FormulaEvaluatorUtil formulaEvaluatorUtil = new AIQ_FormulaEvaluatorUtil();
        mockFormulaEvaluatorUtilWithFesActiveLines(formulaEvaluatorUtil);
        Test.startTest();
        List<zpl__ContractLineItem__c> lines = formulaEvaluatorUtil.evaluateLines(
            configuration.GetPriceDataFormula__c,
            CLI_SOBJECT_TYPE,
            contractLinesFesActive
        );
        Test.stopTest();
        Assert.areEqual(contractLinesFesActive.size(), lines.size(), 'All FES active lines are evaluated');
    }

    @IsTest
    private static void testEvaluateFesInactiveLines() {
        AIQ_FormulaEvaluatorUtil formulaEvaluatorUtil = new AIQ_FormulaEvaluatorUtil();
        mockFormulaEvaluatorUtilWithFesInactiveLines(formulaEvaluatorUtil);
        Test.startTest();
        List<zpl__ContractLineItem__c> lines = formulaEvaluatorUtil.evaluateLines(
            configuration.GetPriceDataFormula__c,
            CLI_SOBJECT_TYPE,
            contractLinesFesInactive
        );
        Test.stopTest();
        Assert.areEqual(0, lines.size(), 'FES inactive lines are not evaluated');
    }

    private static void mockFormulaEvaluatorUtilWithFesActiveLines(AIQ_FormulaEvaluatorUtil formulaEvaluatorUtil) {
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQco_FormulaEvaluator evaluator = (AIQco_FormulaEvaluator) mocks.mock(AIQco_FormulaEvaluator.class);

        mocks.startStubbing();
        mocks.when(
                evaluator.evaluate(
                    configuration.GetPriceDataFormula__c,
                    CLI_SOBJECT_TYPE,
                    AIQ_CommonUtil.toIdList(contractLinesFesActive)
                )
            )
            .thenReturnForAny(contractLinesFesActive);
        mocks.stopStubbing();

        formulaEvaluatorUtil.evaluator = evaluator;
    }

    private static void mockFormulaEvaluatorUtilWithFesInactiveLines(AIQ_FormulaEvaluatorUtil formulaEvaluatorUtil) {
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQco_FormulaEvaluator evaluator = (AIQco_FormulaEvaluator) mocks.mock(AIQco_FormulaEvaluator.class);

        mocks.startStubbing();
        mocks.when(
                evaluator.evaluate(
                    configuration.GetPriceDataFormula__c,
                    Schema.zpl__ContractLineItem__c.SObjectType,
                    AIQ_CommonUtil.toIdList(contractLinesFesInactive)
                )
            )
            .thenReturnForAny(new List<zpl__ContractLineItem__c>());
        mocks.stopStubbing();

        formulaEvaluatorUtil.evaluator = evaluator;
    }
}
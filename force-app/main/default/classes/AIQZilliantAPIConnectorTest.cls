@IsTest
private class AIQZilliantAPIConnectorTest {
	private static AIQZilliantAPIConnector instance = null;
    private static String result = null;

    @IsTest
    private static void testGetInstance() {
        Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new AIQMockOAuthToken());
            instance = AIQZilliantAPIConnector.getInstance();
        Test.stopTest();
        Assert.areNotEqual(null, instance.authorizationHeader);
    }

    @IsTest
    private static void testEvaluateFormulaSuccess() {
        Test.startTest();
            String formula = 'testFormula';
            String queryParms = 'account=test&product=test&UOM=test';
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            result = AIQZilliantAPIConnector.evaluateFormulas(formula, queryParms, null);
        Test.stopTest();
        Assert.areNotEqual(null, result);
    }

    @IsTest
    private static void testEvaluateFormulaError() {
        Test.startTest();
            String formula = 'testFormula';
            String queryParms = '';
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            result = AIQZilliantAPIConnector.evaluateFormulas(formula, queryParms, null);
        Test.stopTest();
        Assert.areNotEqual(null, result);
    }

    @IsTest
    private static void testEvaluateFormulaException() {
        Test.startTest();
            String formula = null;
            String queryParms = null;
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            result = AIQZilliantAPIConnector.evaluateFormulas(formula, queryParms, null);
        Test.stopTest();
        Assert.areNotEqual(null, result);
    }

    @IsTest
    private static void testEvaluateFormulaSuccessBatch() {
        Test.startTest();
            String formula = 'testFormula';
            String queryParms = null;
            String reqBody = '{"account":"testAcct"}';

            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            result = AIQZilliantAPIConnector.evaluateFormulas(formula, queryParms, reqBody);
        Test.stopTest();
        Assert.areNotEqual(null, result);
    }
}
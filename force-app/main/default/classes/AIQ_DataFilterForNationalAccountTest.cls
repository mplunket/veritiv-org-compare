@IsTest
public with sharing class AIQ_DataFilterForNationalAccountTest {

    @IsTest
    private static void testGetScopedFilterCondition() {
        AIQ_DataFilterForNationalAccount nationalAccountFilter = new AIQ_DataFilterForNationalAccount();
        zal.Condition conditions;
        Test.startTest();
            conditions = nationalAccountFilter.getScopedFilterCondition(
                (String) AIQts_ApexMocks.generateId(new Contract().getSObjectType()),
                new Map<String, Object> ()
            );
        Test.stopTest();
        System.assert(conditions != null, 'getScopedFilterCondition return null');
    }

    @IsTest
    private static void testGetFilterCondition() {
        AIQ_DataFilterForNationalAccount nationalAccountFilter = new AIQ_DataFilterForNationalAccount();
        zal.Condition conditions;
        Test.startTest();
            conditions = nationalAccountFilter.getFilterCondition(
                (String) AIQts_ApexMocks.generateId(new Contract().getSObjectType())
            );
        Test.stopTest();
        System.assert(conditions != null, 'getFilterCondition return null');
    }
}
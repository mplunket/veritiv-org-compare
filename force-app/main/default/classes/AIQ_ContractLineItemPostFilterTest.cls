@isTest
private class AIQ_ContractLineItemPostFilterTest {
    private static List<zpl__DMReferenceObject1__c> dmReferenceObject1s;

    static {
        dmReferenceObject1s = new List<zpl__DMReferenceObject1__c>{
                new zpl__DMReferenceObject1__c(Name = 'Draft'),
                new zpl__DMReferenceObject1__c(Name = 'Published'),
                new zpl__DMReferenceObject1__c(Name = 'Pend Appr'),
                new zpl__DMReferenceObject1__c(Name = 'NA Conflict'),
                new zpl__DMReferenceObject1__c(Name = 'Deleted Camp'),
                new zpl__DMReferenceObject1__c(Name = 'Cancelled Camp'),
                new zpl__DMReferenceObject1__c(Name = 'User Vacated'),
                new zpl__DMReferenceObject1__c(Name = 'Pend Cancel'),
                new zpl__DMReferenceObject1__c(Name = 'Deleted'),
                new zpl__DMReferenceObject1__c(Name = 'Camp Vacated')
        };
        insert dmReferenceObject1s;
    }

    @isTest
    private static void testGetFilterCondition() {
        Test.startTest();
        zal.AndCondition expectedCondition = new zal.AndCondition();
        expectedCondition.add(new zal.FieldCondition('zpl__Status__c', zal.Operator.EQUALS, 'Draft'));

        AIQ_ContractLineItemPostFilter contractlineitempostfilter = new AIQ_ContractLineItemPostFilter();

        zal.Condition actualCondition = contractlineitempostfilter.getFilterCondition(null, dmReferenceObject1s[0].Id);
        Test.stopTest();

        System.assertEquals(expectedCondition.toSoql(), actualCondition.toSoql(), 'The result should be equal');
    }
}
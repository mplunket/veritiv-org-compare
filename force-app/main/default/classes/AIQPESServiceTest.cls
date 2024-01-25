@IsTest
private class AIQPESServiceTest {
    private static final String CLI_STATUS_DRAFT = 'Draft';
    private static final String CLI_STATUS_PEND_APPR = 'Pend Appr';
    private static final String CLI_STATUS_PUBLISHED = 'Published';
    private static final String CLI_STATUS_DELETED_BY_QUOTE = 'Deleted By Quote';
    private static final String CLI_RT_DRAFT_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();
    private static final String CLI_RT_ACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId();
    private static List<zpl__ContractLineItem__c> contractLinesDraft;
    private static List<zpl__ContractLineItem__c> contractLinesActive;

    static {
        contractLinesDraft = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Contract Line Draft',
                        zpl__Status__c = CLI_STATUS_DRAFT,
                        RecordTypeId = CLI_RT_DRAFT_ID,
                        LineSource__c = 'U'
                ),
                1,
                true,
                false
        );
        contractLinesActive = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Contract Line Active',
                        zpl__Status__c = CLI_STATUS_PUBLISHED,
                        RecordTypeId = CLI_RT_ACTIVE_ID,
                        LineSource__c = 'U'
                ),
                1,
                true,
                false
        ));
    }

    @IsTest
    private static void testPublishAgrLine() {
        Assert.areEqual(CLI_STATUS_DRAFT, contractLinesDraft[0].zpl__Status__c, 'The status should be equal to Draft');

        Test.startTest();
        AIQPESService.publish(UserInfo.getUserId(), contractLinesDraft[0]);
        Test.stopTest();

        Assert.areEqual(CLI_STATUS_PEND_APPR, contractLinesDraft[0].zpl__Status__c, 'The status will be changed to Pend Appr');
    }

    @IsTest
    private static void testCancelAgrLine() {
        Assert.areEqual(CLI_STATUS_PUBLISHED, contractLinesActive[0].zpl__Status__c, 'The status should be equal to Published');

        Test.startTest();
            AIQPESService.cancel(UserInfo.getUserId(), contractLinesActive);
        Test.stopTest();

        Assert.areEqual(CLI_STATUS_DELETED_BY_QUOTE, contractLinesActive[0].zpl__Status__c, 'The status will be changed to Deleted By Quote');
    }
}
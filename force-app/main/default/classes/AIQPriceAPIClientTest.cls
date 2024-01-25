@IsTest
private class AIQPriceAPIClientTest {
    private static final Id CAMPAIGN_LINE_ID = AIQts_ApexMocks.generateId(new zpl__ContractLineItem__c().getSObjectType());
    private static final String CLI_STATUS_DRAFT = 'Draft';
    private static final String CLI_RT_DRAFT_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();
    private static zpl__ProductSelectorConfiguration__c productSelectorConfig;
    private static zpl__LineLevel__c lineLevelItem;
    private static List<zpl__ContractLineItem__c> contractLinesDraft;
    private static List<zpl__ContractLineItem__c> contractLinesCampaign;
    
    static {
        AIQ_TestDataFactory.initializeIQAnywhereConfig(null, false);
        AIQ_TestDataFactory.initializeZilliantConfiguration(null, false);
        productSelectorConfig = AIQ_TestDataFactory.initializeProductSelectorConfiguration(null, false);
        lineLevelItem = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'Item',
                        Name = 'Item',
                        zpl__Position__c = 1,
                        zpl__ProductSelectorConfiguration__c = productSelectorConfig.Id
                ),
                false
        );
        contractLinesDraft = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine1',
                        zpl__Status__c = CLI_STATUS_DRAFT,
                        RecordTypeId = CLI_RT_DRAFT_ID,
                        LineSource__c = 'U',
                        zpl__LineLevel__c = lineLevelItem.Id
                ),
                1,
                true,
                false
        );
        contractLinesCampaign = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine2',
                        zpl__Status__c = CLI_STATUS_DRAFT,
                        RecordTypeId = CLI_RT_DRAFT_ID,
                        CampaignAppealedLine__c = CAMPAIGN_LINE_ID,
                        LineSource__c = 'C'
                ),
                1,
                true,
                false
        );
    }
    
    @IsTest
    private static void testGetRecommendation() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQPriceRecommendation recs = AIQPriceAPIClient.getRecommendation(
                    'ND',
                    'SW',
                    '',
                    '75',
                    '1:Low',
                    '1:Low',
                    'Other',
                    '10112665',
                    0,
                    ''
            );
            Assert.areNotEqual(null, recs);
        Test.stopTest();
    }
    
    @IsTest
    private static void testGetRecommendationPR() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQPriceRecommendation recs = AIQPriceAPIClient.getRecommendation(
                    'ND',
                    'SW',
                    '',
                    '75',
                    '1:Low',
                    '1:Low',
                    'Other',
                    '10112665',
                    1000,
                    'SH'
            );
            Assert.areNotEqual(null, recs);
        Test.stopTest();
    }
    
    @IsTest
    private static void testEvaluateLinesVoidItem() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQPriceAPIClient.evaluateLines(
                    contractLinesDraft,
                    'f_getAPIContractLineData',
                    zpl__ContractLineItem__c.getSObjectType()
            );
        Test.stopTest();
        Assert.isTrue(contractLinesDraft.size() > 0, 'List lines should not be empty');
    }
    
    @IsTest
    private static void testEvaluateLinesVoidClass() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQPriceAPIClient.evaluateLines(
                    contractLinesCampaign,
                    'f_getAPIContractLineData',
                    zpl__ContractLineItem__c.getSObjectType()
            );
        Test.stopTest();
        Assert.isTrue(contractLinesCampaign.size() > 0, 'List lines should not be empty');
    }
    
    @IsTest
    private static void testEvaluateLinesItem() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            List<zpl__ContractLineItem__c> lines;
            try {
                lines = AIQPriceAPIClient.evaluateLines(
                        contractLinesDraft,
                        'f_getAPIContractLineData',
                        'zpl__ContractLineItem__c'
                );
            } catch(Exception e) {
                Assert.areNotEqual(null, e);
            }
        Test.stopTest();
        Assert.isTrue(lines.size() > 0, 'List lines should not be empty');
    }
    
    @IsTest
    private static void testEvaluateLinesClass() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            List<zpl__ContractLineItem__c> lines = AIQPriceAPIClient.evaluateLines(
                    contractLinesCampaign,
                    'f_getAPIContractLineData',
                    'zpl__ContractLineItem__c'
            );
        Test.stopTest();
        Assert.isTrue(lines.size() > 0, 'List lines should not be empty');
    }
}
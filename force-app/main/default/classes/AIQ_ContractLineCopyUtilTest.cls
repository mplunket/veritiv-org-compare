@IsTest
public without sharing class AIQ_ContractLineCopyUtilTest {

    private static List<Contract> contracts;
    private static List<zpl__ContractLineItem__c> contractLinesDraft;
    private static List<zpl__ContractLineItem__c> contractLinesPublished;
    private static List<zpl__ContractLineItem__c> contractLinesCampaign;
    private static AIQ_ContractLineCopyUtil lineCopyUtil = new AIQ_ContractLineCopyUtil();

    static {
        contracts = AIQ_TestDataFactory.initializeContracts(new Contract(Name = 'Test Name'), 1, true);
        contractLinesDraft = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(zpl__Status__c = 'Draft', zpl__EffectiveDate__c = Date.today().addDays(2)),
            10,
            true
        );
        contractLinesPublished = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(
                zpl__Status__c = 'Published',
                zpl__EffectiveDate__c = Date.today().addDays(-2)
            ),
            20,
            true
        );
        contractLinesCampaign = AIQ_TestDataFactory.initializeContractsLines(
            new zpl__ContractLineItem__c(zpl__Status__c = 'Published', LineSource__c = 'C'),
            30,
            true
        );
    }

    @IsTest
    private static void testCopyDraftLines() {
        Test.startTest();
        List<zpl__ContractLineItem__c> lines = mockCopyDraftLines()
            .copyLines(new Map<Id, zpl__ContractLineItem__c>(contractLinesDraft).keySet())
            .setDefaults()
            .getCloneLines();
        Test.stopTest();
        Assert.areEqual(contractLinesDraft.size(), lines.size(), 'number of cloned Draft lines matches');
        Assert.isNotNull(lines[0].Id, 'draft lines are cloned with Id populated');
        Assert.areEqual(
            AIQ_ContractLineCopyUtil.LINE_STATUS_DRAFT,
            lines[0].zpl__Status__c,
            'lines are cloned as Draft'
        );
    }

    @IsTest
    private static void testCopyPublishedLines() {
        Test.startTest();
        List<zpl__ContractLineItem__c> lines = mockCopyPublishedLines()
            .copyLines(new Map<Id, zpl__ContractLineItem__c>(contractLinesPublished).keySet())
            .setDefaults()
            .getCloneLines();
        Test.stopTest();
        Assert.areEqual(contractLinesPublished.size(), lines.size(), 'number of cloned Published lines matches');
        Assert.isNull(lines[0].Id, 'published lines are cloned without Id populated');
        Assert.isNull(contractLinesCampaign[0].CampaignAppealedLine__c, 'non-campaign lines are never appealed');
        Assert.areEqual(
            AIQ_ContractLineCopyUtil.LINE_STATUS_DRAFT,
            lines[0].zpl__Status__c,
            'lines are cloned as Draft'
        );
    }

    @IsTest
    private static void testCopyPublishedLinesWithoutPreserveId() {
        Test.startTest();
        List<zpl__ContractLineItem__c> lines = mockCopyPublishedLines()
            .copyLines(new Map<Id, zpl__ContractLineItem__c>(contractLinesPublished).keySet(), false)
            .setFieldsToExclude(new List<String> {'Name'})
            .getCloneLines();
        Test.stopTest();
        Assert.areEqual(contractLinesPublished.size(), lines.size(), 'number of cloned Published lines matches');
    }

    @IsTest
    private static void testCopyCampaignLines() {
        Test.startTest();
        List<zpl__ContractLineItem__c> lines = mockCopyCampaignLines()
            .copyLines(new Map<Id, zpl__ContractLineItem__c>(contractLinesCampaign).keySet())
            .setDefaults()
            .getCloneLines();
        Test.stopTest();
        Assert.areEqual(contractLinesCampaign.size(), lines.size(), 'number of cloned Campaign lines matches');
        Assert.isNull(lines[0].Id, 'published lines are cloned without Id populated');
        Assert.isNotNull(lines[0].CampaignAppealedLine__c, 'draft lines do appeal the campaign');
        Assert.areEqual(
            AIQ_ContractLineCopyUtil.LINE_STATUS_DRAFT,
            lines[0].zpl__Status__c,
            'lines are cloned as Draft'
        );
    }

    private static AIQ_ContractLineCopyUtil mockCopyDraftLines() {
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQco_SObjectUtil sobjectUtilMock = (AIQco_SObjectUtil) mocks.mock(AIQco_SObjectUtil.class);

        mocks.startStubbing();
        mocks.when(
                sobjectUtilMock.getClone(
                    AIQ_ContractLineCopyUtil.CONTRACT_LINE_ITEM_OBJECT_NAME,
                    new List<Id>(new Map<Id, SObject>(contractLinesDraft).keySet()),
                    new List<String>(),
                    true
                )
            )
            .thenReturnForAny(contractLinesDraft);
        mocks.stopStubbing();

        lineCopyUtil.sObjectUtil = sobjectUtilMock;
        return lineCopyUtil;
    }

    private static AIQ_ContractLineCopyUtil mockCopyPublishedLines() {

        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQco_SObjectUtil sobjectUtilMock = (AIQco_SObjectUtil) mocks.mock(AIQco_SObjectUtil.class);

        mocks.startStubbing();
        mocks.when(
                sobjectUtilMock.getClone(
                    AIQ_ContractLineCopyUtil.CONTRACT_LINE_ITEM_OBJECT_NAME,
                    new List<Id>(new Map<Id, SObject>(contractLinesPublished).keySet()),
                    new List<String>(),
                    true
                )
            )
            .thenReturnForAny(contractLinesPublished);
        mocks.stopStubbing();

        lineCopyUtil.sObjectUtil = sobjectUtilMock;
        return lineCopyUtil;
    }

    private static AIQ_ContractLineCopyUtil mockCopyCampaignLines() {
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQco_SObjectUtil sobjectUtilMock = (AIQco_SObjectUtil) mocks.mock(AIQco_SObjectUtil.class);

        mocks.startStubbing();
        mocks.when(
                sobjectUtilMock.getClone(
                    AIQ_ContractLineCopyUtil.CONTRACT_LINE_ITEM_OBJECT_NAME,
                    new List<Id>(new Map<Id, SObject>(contractLinesCampaign).keySet()),
                    new List<String>(),
                    true
                )
            )
            .thenReturnForAny(contractLinesCampaign);
        mocks.stopStubbing();

        lineCopyUtil.sObjectUtil = sobjectUtilMock;
        return lineCopyUtil;
    }
}
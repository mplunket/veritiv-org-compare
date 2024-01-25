@IsTest
private with sharing class AIQ_PublishLineTest {
    private static final Id PRICING_USER_ID = AIQts_ApexMocks.generateId(new User().getSObjectType());
    private static final Id CAMPAIGN_LINE_ID = AIQts_ApexMocks.generateId(new zpl__ContractLineItem__c().getSObjectType());
    private static final String ACTION_NAME = 'AIQ_PublishLine';
    private static final String CLI_STATUS_PUBLISHED = 'Published';
    private static final String CLI_RT_ACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId();
    private static AIQZilliantConfiguration__c zilliantConfiguration;
    private static List<Account> accounts;
    private static List<Contract> contracts;
    private static List<zpl__ContractLineItem__c> contractLinesAll;
    private static List<zpl__ContractLineItem__c> contractLinesDraft;
    private static List<zpl__ContractLineItem__c> contractLinesCampaign;
    private static List<zpl__ContractLineItem__c> contractLinesPublished;
    private static List<Servicing_Division__c> divisions;
    private static List<Ship_To__c> shipTos;

    static {
        zilliantConfiguration = AIQ_TestDataFactory.initializeZilliantConfiguration();
        accounts = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'Test Account',
                        OwnerId = PRICING_USER_ID
                ),
                1,
                true
        );
        divisions = AIQ_TestDataFactory.initializeDivisions(
                new Servicing_Division__c(
                        Name = 'TestDiv2',
                        Division_Code__c = '70',
                        Division_Composite_Key__c = '0370'
                ),
                1,
                true
        );
        contracts = AIQ_TestDataFactory.initializeContracts(
                new Contract(
                        Name = 'TestContract',
                        AccountId = accounts[0].Id,
                        Division__c = divisions[0].Id
                ),
                1,
                true
        );
        contractLinesDraft = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine1',
                        zpl__Contract__r = contracts[0],
                        zpl__Status__c = AIQ_PublishLine.CLI_STATUS_DRAFT,
                        RecordTypeId = AIQ_PublishLine.CLI_RT_DRAFT_ID,
                        LineSource__c = 'U'
                ),
                1,
                true,
                false
        );
        contractLinesPublished = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine2',
                        zpl__Contract__r = contracts[0],
                        zpl__Status__c = CLI_STATUS_PUBLISHED,
                        RecordTypeId = CLI_RT_ACTIVE_ID,
                        LineSource__c = 'C'
                ),
                1,
                true,
                false
        ));
        contractLinesCampaign = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine1',
                        zpl__Contract__r = contracts[0],
                        zpl__Status__c = AIQ_PublishLine.CLI_STATUS_DRAFT,
                        RecordTypeId = AIQ_PublishLine.CLI_RT_DRAFT_ID,
                        CampaignAppealedLine__c = CAMPAIGN_LINE_ID,
                        LineSource__c = 'U'
                ),
                1,
                true,
                false
        );
        contractLinesAll = new List<zpl__ContractLineItem__c>{contractLinesDraft[0], contractLinesPublished[0], contractLinesCampaign[0]};
        shipTos = AIQ_TestDataFactory.initializeShipTo(
                new Ship_To__c(
                        Name = 'Test Ship',
                        Bill_To_Account__c = accounts[0].Id,
                        Account_Owner__c = accounts[0].OwnerId
                ),
                2,
                true
        );
    }

    @IsTest
    private static void testInitComboboxIsRendered() {
        User adminUser = [SELECT Id, Profile.Name FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.runAs(adminUser) {
            AIQ_PublishLine publishLine = initMocks(adminUser, 'All');
            Test.startTest();
                AIQqa_QuickActionDTO dto = publishLine.initialize(new List<Id>{contractLinesDraft[0].Id}, ACTION_NAME);
            Test.stopTest();

            Assert.isTrue(dto.getField(AIQ_PublishLine.QA_FIELD_NAME).isRendered, 'The drop down should be rendered');
        }
    }

    @IsTest
    private static void testInitComboboxIsHidden() {
        User pricingUser = [SELECT Id, Profile.Name FROM User WHERE IsActive = true AND Profile.Name = 'Pricing - Lightning' LIMIT 1];
        System.runAs(pricingUser) {
            AIQ_PublishLine publishLine = initMocks(pricingUser, 'All');
            Test.startTest();
                AIQqa_QuickActionDTO dto = publishLine.initialize(new List<Id>{contractLinesDraft[0].Id}, ACTION_NAME);
            Test.stopTest();

            Assert.isFalse(dto.getField(AIQ_PublishLine.QA_FIELD_NAME).isRendered, 'The drop down should be hidden');
        }
    }

    @IsTest
    private static void testRunPrimaryDraftLines() {
        User adminUser = [SELECT Id, Profile.Name FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.runAs(adminUser) {
            AIQ_PublishLine publishLine = initMocks(adminUser, 'Draft');
            Test.startTest();
                AIQqa_QuickActionDTO dto = publishLine.runPrimary(initQuickActionDTO());
            Test.stopTest();

            Assert.isTrue(dto.customMessage.messages.contains(Label.AIQPublishSuccess), 'The logic should publish the Draft Lines');
        }
    }

    @IsTest
    private static void testRunPrimaryPublishedLines() {
        User adminUser = [SELECT Id, Profile.Name FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.runAs(adminUser) {
            AIQ_PublishLine publishLine = initMocks(adminUser, 'Published');
            Test.startTest();
                AIQqa_QuickActionDTO dto = publishLine.runPrimary(initQuickActionDTO());
            Test.stopTest();

            Assert.isTrue(dto.customMessage.messages.contains(Label.AIQPublishRejected), 'The logic should reject Published Lines');
        }
    }

    @IsTest
    private static void testRunPrimaryDraftWithPublishedLines() {
        User adminUser = [SELECT Id, Profile.Name FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.runAs(adminUser) {
            AIQ_PublishLine publishLine = initMocks(adminUser, 'All');
            Test.startTest();
                AIQqa_QuickActionDTO dto = publishLine.runPrimary(initQuickActionDTO());
            Test.stopTest();

            Assert.isTrue(dto.customMessage.messages.contains(Label.AIQ_PublishOnlyDraft), 'The logic should publish only Draft Lines');
        }
    }

    @IsTest
    private static void testRunPrimaryNegative() {
        User adminUser = [SELECT Id, Profile.Name FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.runAs(adminUser) {
            AIQ_PublishLine publishLine = initMocks(adminUser, '');
            Test.startTest();
                try {
                    AIQqa_QuickActionDTO dto = publishLine.runPrimary(initQuickActionDTO());
                } catch(Exception e) {
                    Assert.isInstanceOfType(
                            e,
                            AIQ_PublishLine.AIQ_PublishLineException.class,
                            'Exception thrown is of type AIQ_PublishLine');
                }
            Test.stopTest();
        }
    }

    private static AIQqa_QuickActionDTO initQuickActionDTO() {
        AIQqa_QuickActionUtil.ActionDtoBuilder dtoBuilder = AIQqa_QuickActionUtil.getDialogActionDtoBuilder(new List<Id>{contractLinesDraft[0].Id}, ACTION_NAME);
        List<AIQqa_QuickActionDTO.FieldToReset> fieldToResets = new List<AIQqa_QuickActionDTO.FieldToReset>{
                new AIQqa_QuickActionUtil.FieldBuilder(AIQqa_DisplayMode.COMBOBOX_DISPLAY_MODE)
                        .setApiFieldName(AIQ_PublishLine.QA_FIELD_NAME)
                        .setFieldLabel(AIQ_PublishLine.QA_FIELD_LABEL)
                        .setPosition('1.1')
                        .build()
        };
        return dtoBuilder
                .setScreenMode(AIQ_PublishLine.SCREEN_MODE)
                .setFieldsToReset(fieldToResets)
                .build();
    }

    private static AIQ_PublishLine initMocks(User runAs, String typeTestLine) {
        List<Id> recordIds = new List<Id>{contractLinesDraft[0].Id};
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQ_ContractLineSelector contractLineSelector = (AIQ_ContractLineSelector) mocks.mock(AIQ_ContractLineSelector.class);
        AIQ_GenericSelector genericSelector = (AIQ_GenericSelector) mocks.mock(AIQ_GenericSelector.class);
        AIQ_CBSSIService cbssiService = (AIQ_CBSSIService) mocks.mock(AIQ_CBSSIService.class);
        AIQco_DatabaseUtil databaseUtil = (AIQco_DatabaseUtil) mocks.mock(AIQco_DatabaseUtil.class);

        mocks.startStubbing();
        if (typeTestLine.equalsIgnoreCase('Draft')) {
            mocks.when(contractLineSelector.queryContractLinesById(AIQ_PublishLine.CONTRACT_LINES_QUERY_FIELDS, recordIds))
                    .thenReturn(contractLinesDraft);
        } else if (typeTestLine.equalsIgnoreCase('Published')) {
            mocks.when(contractLineSelector.queryContractLinesById(AIQ_PublishLine.CONTRACT_LINES_QUERY_FIELDS, recordIds))
                    .thenReturn(contractLinesPublished);
        } else {
            mocks.when(contractLineSelector.queryContractLinesById(AIQ_PublishLine.CONTRACT_LINES_QUERY_FIELDS, recordIds))
                    .thenReturn(contractLinesAll);
        }
        mocks.when(genericSelector.queryShipToByBillToAccount(contractLinesDraft[0].zpl__Contract__r.AccountId)).thenReturn(shipTos);
        mocks.when(genericSelector.queryUsersByIds(new List<Id>{shipTos[0].Account_Owner__c}))
                .thenReturn(new List<User>{new User(Id = PRICING_USER_ID)});
        mocks.when(genericSelector.queryCurrentUser()).thenReturn(runAs);
        if (!String.isBlank(typeTestLine)) {
            mocks.when(cbssiService.alignBeforePublish(contractLinesAll)).thenReturnForAny(contractLinesAll);
        }
        mocks.when(databaseUtil.updateRecords(contractLinesAll)).thenReturn(contractLinesAll);
        mocks.stopStubbing();

        AIQ_PublishLine publishLine = new AIQ_PublishLine();
        publishLine.contractLineSelector = contractLineSelector;
        publishLine.genericSelector = genericSelector;
        publishLine.cbssiService = cbssiService;
        publishLine.databaseUtil = databaseUtil;

        return publishLine;
    }
}
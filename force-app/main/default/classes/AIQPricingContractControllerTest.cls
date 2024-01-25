@IsTest
private class AIQPricingContractControllerTest {
    private static final String ACCOUNT_RT_CHAIN_ACCOUNT_ID = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('Chain_Account')
            .getRecordTypeId();
    private static final String CONTRACT_RT_PRICING_ID = Schema.SObjectType.Contract
            .getRecordTypeInfosByDeveloperName()
            .get('PricingContract')
            .getRecordTypeId();
    private static final String CLI_RT_ACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName()
            .get('Active')
            .getRecordTypeId();
    private static final String CLI_STATUS_PUBLISHED = 'Published';
    private static zpl__ProductSelectorConfiguration__c productSelectorConfig;
    private static List<Servicing_Division__c> divisions;
    private static List<Account> chainAccounts;
    private static List<Contract> chainContracts;
    private static zpl__LineLevel__c lineLevelItem;
    private static zpl__PolicyType__c policyType;
    private static zpl__ProductUOM__c uom;
    private static List<Product2> products;
    private static List<zpl__ContractLineItem__c> contractLinesActiveCampaign;

    static {
        AIQ_TestDataFactory.initializeZilliantConfiguration();
        AIQ_TestDataFactory.initializeIQAnywhereConfig(null, false);
        productSelectorConfig = AIQ_TestDataFactory.initializeProductSelectorConfiguration(null, false);
        divisions = AIQ_TestDataFactory.initializeDivisions(
                new Servicing_Division__c(
                        Name = 'TestDiv2',
                        Division_Code__c = '70',
                        Division_Composite_Key__c = '0370'
                ),
                1,
                false
        );
        chainAccounts = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'Zilliant Test Chain Acct',
                        Active__c = 'Yes',
                        Suspect__c = '2. Prospect',
                        Zilliant_Active__c = 'AI',
                        RecordTypeId = ACCOUNT_RT_CHAIN_ACCOUNT_ID,
                        Representative_Division__c = '0370',
                        OwnerId = UserInfo.getUserId(),
                        Servicing_Division__c = divisions[0].Id
                ),
                1,
                false
        );
        chainContracts = AIQ_TestDataFactory.initializeContracts(
                new Contract(
                        Name = 'Test Contract Chain',
                        AccountId = chainAccounts[0].Id,
                        Division__c = divisions[0].Id,
                        RecordTypeId = CONTRACT_RT_PRICING_ID
                ),
                1,
                false
        );
        lineLevelItem = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'Item',
                        Name = 'Item',
                        zpl__Position__c = 1,
                        zpl__ProductSelectorConfiguration__c = productSelectorConfig.Id
                ),
                false
        );
        policyType = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'fixedPrice'
                ),
                false
        );
        uom = AIQ_TestDataFactory.initializeProductUOM(
                new zpl__ProductUOM__c(
                        Name = 'M',
                        zpl__ConversionFactor__c = 1,
                        zpl__ProductUOMId__c = 'SW0100000001SH'
                ),
                false
        );
        products = AIQ_TestDataFactory.initializeProduct2s(null, 1, false);
        contractLinesActiveCampaign = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Contract Line Active Camp',
                        zpl__Status__c = CLI_STATUS_PUBLISHED,
                        zpl__Contract__c = chainContracts[0].Id,
                        RecordTypeId = CLI_RT_ACTIVE_ID,
                        LineSource__c = 'C',
                        zpl__EffectiveDate__c = System.today().addDays(-11),
                        zpl__PolicyType__c = policyType.Id,
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id,
                        zpl__LineLevel__c = lineLevelItem.Id,
                        isCurrent__c = false,
                        Approved_Date__c = System.today().addDays(-1),
                        Publish_Date__c = System.today().addDays(-1),
                        InitiativeActionId__c = 1000,
                        DisallowCampaignsThroughDate__c = System.today(),
                        SupersededDate__c = null
                ),
                1,
                false,
                false
        ));
    }
    
    @IsTest
    private static void testAddPricingContractSuccess() {
        Test.startTest();
            Contract contract = AIQPricingContractController.addPricingContract(chainAccounts[0].Id);
        Test.stopTest();
        Assert.areEqual(contract.AccountId, chainAccounts[0].Id, 'Ids should be equal');
    }
    
    @IsTest
    private static void testAddPricingContractError() {
        Test.startTest();
            Contract contract = AIQPricingContractController.addPricingContract(null);
        Test.stopTest();
        Assert.isTrue(String.isEmpty(contract.Name), 'The Contract should not be created');
    }
   
    @IsTest
    private static void testValidateUser() {
        Test.startTest();
            AIQPricingContractController.UserValidationResult authorized = AIQPricingContractController.ValidateUser();
        Test.stopTest();
        Assert.areEqual(false, authorized.getIsPricingManager(), 'Should be equal to false');
        Assert.areNotEqual(null, authorized.getUserAlias(), 'Should not be equal to null');
    }
    
    @IsTest
    private static void testCopyPricingContractSuccess() {
        Test.startTest();
        String error = '';
            try {
                Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
                AIQPricingContractController.CustomMessage msg = AIQPricingContractController.copyContract(chainAccounts[0].Id, chainContracts[0].Id);
            } catch (Exception e) {
                error = e.getMessage();
            }
        Test.stopTest();
        Assert.isTrue(String.isNotBlank(error), 'Should not be blank');
    }

    @IsTest
    private static void testCopyPricingContractErrorCase1() {
        Test.startTest();
            chainAccounts[0].Representative_Division__c = null;
            update chainAccounts;
            AIQPricingContractController.CustomMessage msg = AIQPricingContractController.copyContract(chainAccounts[0].Id, chainContracts[0].Id);
        Test.stopTest();
        Assert.areEqual(true, msg.isError, 'Should be equal to true');
    }

    @IsTest
    private static void testCopyPricingContractErrorCase2() {
        Test.startTest();
            String error;
            try {
                AIQPricingContractController.CustomMessage msg = AIQPricingContractController.copyContract(chainAccounts[0].Id, chainContracts[0].Id);
            } catch (Exception e) {
                error = e.getMessage();
            }
        Test.stopTest();
        Assert.isTrue(String.isNotEmpty(error), 'The error message should not be empty');
    }
    
    @IsTest
    private static void testCopyPricingContractErrorCase3() {
        Test.startTest();
            AIQPricingContractController.CustomMessage msg = AIQPricingContractController.copyContract(null, chainContracts[0].Id);
        Test.stopTest();
        Assert.areEqual(true, msg.isError, 'Should be equal to true');
    }
    
    @IsTest
    private static void testCopyPricingContractException() {
        Test.startTest();
            String error;
            try {
                AIQPricingContractController.getReportURL('Username__c');
            } catch (Exception e) {
                error = e.getMessage();
            }
        Test.stopTest();
        Assert.isTrue(String.isNotEmpty(error), 'The error message should not be empty');
    }
}
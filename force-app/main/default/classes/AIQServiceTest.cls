@IsTest
private class AIQServiceTest {
    private static final String ACCOUNT_RT_PROSPECT_ID = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('Prospect')
            .getRecordTypeId();
    private static final String CONTRACT_RT_PRICING_ID = Schema.SObjectType.Contract
            .getRecordTypeInfosByDeveloperName()
            .get('PricingContract')
            .getRecordTypeId();
    private static final String CLI_RT_DRAFT_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName()
            .get('Draft')
            .getRecordTypeId();
    private static final String CLI_RT_ACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName()
            .get('Active')
            .getRecordTypeId();
    private static final String CLI_STATUS_DRAFT = 'Draft';
    private static final String CLI_STATUS_PEND_APPR = 'Pend Appr';
    private static final String CLI_STATUS_PUBLISHED = 'Published';
    private static AIQServiceInterface service;
    private static zpl__ProductSelectorConfiguration__c productSelectorConfig;
    private static List<Account> accounts;
    private static List<Servicing_Division__c> divisions;
    private static List<Contract> contracts;
    private static zpl__LineLevel__c lineLevelItem;
    private static zpl__LineLevel__c lineLevelSubset;
    private static zpl__LineLevel__c lineLevelSet;
    private static zpl__LineLevel__c lineLevelBrand;
    private static zpl__LineLevel__c lineLevelClass;
    private static zpl__LineLevel__c lineLevelBrandVendor;
    private static zpl__LineLevel__c lineLevelClassVendor;
    private static zpl__LineLevel__c lineLevelVendor;
    private static zpl__PolicyType__c policyType;
    private static zpl__PolicyType__c policyType2;
    private static zpl__PolicyType__c policyType3;
    private static zpl__PolicyType__c policyType4;
    private static zpl__PolicyType__c policyType5;
    private static zpl__ProductUOM__c uom;
    private static List<Product2> products;
    private static List<zpl__ContractLineItem__c> contractLinesDraft;
    private static List<zpl__ContractLineItem__c> contractLinesPendAppr;
    private static List<zpl__ContractLineItem__c> contractLinesActiveCampaign;
    private static List<zpl__ContractLineItem__c> contractLinesDraftCampaign;

    static {
        service = AIQController.getAIQService();
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
        accounts = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'Test Account',
                        Active__c = 'Yes',
                        Suspect__c = '2. Prospect',
                        Zilliant_Active__c = 'AI',
                        zpl__CustomerId__c = 'SW000001',
                        RecordTypeId = ACCOUNT_RT_PROSPECT_ID,
                        OwnerId = UserInfo.getUserId(),
                        Servicing_Division__c = divisions[0].Id,
                        Natl_Acct_Group_ID__c = 'testNA'
                ),
                1,
                false
        );
        contracts = AIQ_TestDataFactory.initializeContracts(
                new Contract(
                        Name = 'TestContract',
                        RecordTypeId = CONTRACT_RT_PRICING_ID,
                        AccountId = accounts[0].Id,
                        Division__c = divisions[0].Id
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
        lineLevelSubset = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'Subset',
                        Name = 'Subset',
                        zpl__Position__c = 2,
                        zpl__ProductSelectorConfiguration__c = productSelectorConfig.Id
                ),
                false
        );
        lineLevelSet = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'Set',
                        Name = 'Set',
                        zpl__Position__c = 3,
                        zpl__ProductSelectorConfiguration__c = productSelectorConfig.Id
                ),
                false
        );
        lineLevelClass = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'Class',
                        Name = 'Class',
                        zpl__Position__c = 4,
                        zpl__ProductSelectorConfiguration__c = productSelectorConfig.Id
                ),
                false
        );
        lineLevelBrand = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'Brand',
                        Name = 'Brand',
                        zpl__Position__c = 5,
                        zpl__ProductSelectorConfiguration__c = productSelectorConfig.Id
                ),
                false
        );
        lineLevelClassVendor = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'ClassVendor',
                        Name = 'ClassVendor',
                        zpl__Position__c = 6,
                        zpl__ProductSelectorConfiguration__c = productSelectorConfig.Id
                ),
                false
        );
        lineLevelBrandVendor = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'BrandVendor',
                        Name = 'BrandVendor',
                        zpl__Position__c = 7,
                        zpl__ProductSelectorConfiguration__c = productSelectorConfig.Id
                ),
                false
        );
        lineLevelVendor = AIQ_TestDataFactory.initializeLineLevel(
                new zpl__LineLevel__c(
                        zpl__LineLevelId__c = 'Vendor',
                        Name = 'Vendor',
                        zpl__Position__c = 8,
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
        policyType2 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'nationalAccount'
                ),
                false
        );
        policyType3 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'cwtFixed'
                ),
                false
        );
        policyType4 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'listDown'
                ),
                false
        );
        policyType5 = AIQ_TestDataFactory.initializePolicyType(
                new zpl__PolicyType__c(
                        zpl__PolicyTypeId__c = 'maintainGTM'
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
        products = AIQ_TestDataFactory.initializeProduct2s(
            new Product2(
                Name = 'Product ',
                System_id__c = '03',
                ProductCode = '00000001',
                isActive = true,
                Division_Code__c = '01',
                List_Price__c = 1.0,
                Pricing_Costing_UOM__c= 'SH',
                WMS_UOM__c = 'SH'
            ),
            1, 
            false
        );
        contractLinesDraft = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine Draft',
                        zpl__Contract__c = contracts[0].Id,
                        zpl__Status__c = CLI_STATUS_DRAFT,
                        RecordTypeId = CLI_RT_DRAFT_ID,
                        LineSource__c = 'U',
                        zpl__PolicyType__c = policyType.Id,
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id,
                        zpl__LineLevel__c = lineLevelItem.Id
                ),
                1,
                false,
                false
        );
        contractLinesPendAppr = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine PendAppr',
                        zpl__Contract__c = contracts[0].Id,
                        zpl__Status__c = CLI_STATUS_PEND_APPR,
                        RecordTypeId = CLI_RT_DRAFT_ID,
                        LineSource__c = 'U',
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id
                ),
                1,
                false,
                false
        );
        contractLinesActiveCampaign = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'Contract Line Active Camp',
                        zpl__Status__c = CLI_STATUS_PUBLISHED,
                        zpl__Contract__c = contracts[0].Id,
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
                        DisallowCampaignsThroughDate__c = System.today()
                ),
                1,
                false,
                false
        ));
        contractLinesDraftCampaign = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine Camp',
                        zpl__Contract__c = contracts[0].Id,
                        zpl__Status__c = CLI_STATUS_PEND_APPR,
                        RecordTypeId = CLI_RT_DRAFT_ID,
                        LineSource__c = 'C',
                        zpl__EffectiveDate__c = System.today().addDays(1),
                        zpl__PolicyType__c = policyType.Id,
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id,
                        zpl__LineLevel__c = lineLevelItem.Id,
                        CampaignAppealedLine__c = contractLinesActiveCampaign[0].Id,
                        IsCampaignAppealed__c = true
                ),
                1,
                false,
                false
        );
    }

    @IsTest
    private static void testAddItemLine() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQAddLineResponse resultItem = service.addAgreementLine(
                '000001',	//customerId,
                'Item',     //level
                '',				//vendorId,
                '01', 			//divisionId,
                'SW', 			//systemId,
                'PI', 			//segmentId,
                '01', 			//classId,
                '0101', 		//brandId,
                '0001',			//setId,
                '0001',			//subsetId,
                '00000001',		//productCode,
                'maintainGTM',		//policyType,
                0.2,			//policyValue,
                'SH',			//priceUnit,
                Date.today()		//effectiveDate
            );
        Test.stopTest();
        Assert.areNotEqual(null, resultItem, 'Should not be equal to null');
    }

    @IsTest
    private static void testAddSubsetLine() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            String error;
            try {
                AIQAddLineResponse resultSubset = service.addAgreementLine(
                        '000001',	//customerId,
                        'Subset',     //level
                        '',				//vendorId,
                        '01', 			//divisionId,
                        'SW', 			//systemId,
                        'PI', 			//segmentId,
                        '01', 			//classId,
                        '0101', 		//brandId,
                        '0001',			//setId,
                        '0001',			//subsetId,
                        '00000001',		//productCode,
                        'maintainGTM',		//policyType,
                        0.2,			//policyValue,
                        'SH',			//priceUnit,
                        Date.today()		//effectiveDate
                );
            } catch (Exception e) {
                error = e.getMessage();
            }
        Test.stopTest();
        Assert.isTrue(String.isBlank(error), 'The error should be blank');
    }

    @IsTest
    private static void testAddSetLine() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            String error;
            try {
                AIQAddLineResponse resultSet = service.addAgreementLine(
                    '000001',	//customerId,
                    'Set',     //level
                    '',				//vendorId,
                    '01', 			//divisionId,
                    'SW', 			//systemId,
                    'PI', 			//segmentId,
                    '01', 			//classId,
                    '0101', 		//brandId,
                    '0001',			//setId,
                    '0001',			//subsetId,
                    '00000001',		//productCode,
                    'maintainGTM',		//policyType,
                    0.2,			//policyValue,
                    'SH',			//priceUnit,
                    Date.today()		//effectiveDate
                );
            } catch (Exception e) {
                error = e.getMessage();
            }
        Test.stopTest();
        Assert.isTrue(String.isBlank(error), 'The error should be blank');
    }

    @IsTest
    private static void testAddBrandLine() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            String error;
            try {
                AIQAddLineResponse resultBrand = service.addAgreementLine(
                    '000001',	//customerId,
                    'Brand',     //level
                    '',				//vendorId,
                    '01', 			//divisionId,
                    'SW', 			//systemId,
                    'PI', 			//segmentId,
                    '01', 			//classId,
                    '0101', 		//brandId,
                    '0001',			//setId,
                    '0001',			//subsetId,
                    '00000001',		//productCode,
                    'maintainGTM',		//policyType,
                    0.2,			//policyValue,
                    'SH',			//priceUnit,
                    Date.today()		//effectiveDate
                );
            } catch (Exception e) {
                error = e.getMessage();
            }
        Test.stopTest();
        Assert.isTrue(String.isBlank(error), 'The error should be blank');
    }

    @IsTest
    private static void testAddClassLine() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            String error;
            try {
                AIQAddLineResponse resultClass = service.addAgreementLine(
                    '000001',	//customerId,
                    'Class',     //level
                    '',				//vendorId,
                    '01', 			//divisionId,
                    'SW', 			//systemId,
                    'PI', 			//segmentId,
                    '01', 			//classId,
                    '0101', 		//brandId,
                    '0001',			//setId,
                    '0001',			//subsetId,
                    '00000001',		//productCode,
                    'maintainGTM',		//policyType,
                    0.2,			//policyValue,
                    'SH',			//priceUnit,
                    Date.today()		//effectiveDate
                );
            } catch (Exception e) {
                error = e.getMessage();
            }
        Test.stopTest();
        Assert.isTrue(String.isBlank(error), 'The error should be blank');
    }

    @IsTest
    private static void testAddBrandVendorLine() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQAddLineResponse resultBrandVendor = service.addAgreementLine(
                '000001',	//customerId,
                'BrandVendor',     //level
                '',				//vendorId,
                '01', 			//divisionId,
                'SW', 			//systemId,
                'PI', 			//segmentId,
                '01', 			//classId,
                '0101', 		//brandId,
                '0001',			//setId,
                '0001',			//subsetId,
                '00000001',		//productCode,
                'maintainGTM',		//policyType,
                0.2,			//policyValue,
                'SH',			//priceUnit,
                Date.today()		//effectiveDate
            );
        Test.stopTest();
        Assert.areNotEqual(null, resultBrandVendor, 'Should not be equal to null');
    }

    @IsTest
    private static void testAddClassVendorLine() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQAddLineResponse resultClassVendor = service.addAgreementLine(
                '000001',	//customerId,
                'ClassVendor',     //level
                '',				//vendorId,
                '01', 			//divisionId,
                'SW', 			//systemId,
                'PI', 			//segmentId,
                '01', 			//classId,
                '0101', 		//brandId,
                '0001',			//setId,
                '0001',			//subsetId,
                '00000001',		//productCode,
                'maintainGTM',		//policyType,
                0.2,			//policyValue,
                'SH',			//priceUnit,
                Date.today()		//effectiveDate
            );
        Test.stopTest();
        Assert.areNotEqual(null, resultClassVendor, 'Should not be equal to null');
    }

    @IsTest
    private static void testAddNoLevelLine() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQAddLineResponse resultVendor = service.addAgreementLine(
                '000001',	//customerId,
                'Vendor',     //level
                '',				//vendorId,
                '01', 			//divisionId,
                'SW', 			//systemId,
                'PI', 			//segmentId,
                '01', 			//classId,
                '0101', 		//brandId,
                '0001',			//setId,
                '0001',			//subsetId,
                '00000001',		//productCode,
                'maintainGTM',		//policyType,
                0.2,			//policyValue,
                'SH',			//priceUnit,
                Date.today()		//effectiveDate
            );
        Test.stopTest();
        Assert.areNotEqual(null, resultVendor, 'Should not be equal to null');
    }

    @IsTest
    private static void testAddLineWOAccount() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQAddLineResponse result = service.addAgreementLine(
                '',	//customerId,
                'Item',     //level
                '',				//vendorId,
                '01', 			//divisionId,
                'SW', 			//systemId,
                'PI', 			//segmentId,
                '01', 			//classId,
                '0101', 		//brandId,
                '0001',			//setId,
                '0001',			//subsetId,
                '00000001',		//productCode,
                'maintainGTM',		//policyType,
                0.2,			//policyValue,
                'SH',			//priceUnit,
                Date.today()		//effectiveDate
            );
        Test.stopTest();
        Assert.areEqual(4, result.getResponseCode(), 'Response Code should be equal to 4');
    }

    @IsTest
    private static void testAddLineWithPastDate() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQAddLineResponse result = service.addAgreementLine(
                '000001',	//customerId,
                'Item',     //level
                '',				//vendorId,
                '01', 			//divisionId,
                'SW', 			//systemId,
                'PI', 			//segmentId,
                '01', 			//classId,
                '0101', 		//brandId,
                '0001',			//setId,
                '0001',			//subsetId,
                '00000001',		//productCode,
                'maintainGTM',		//policyType,
                0.2,			//policyValue,
                'SH',			//priceUnit,
                Date.parse('1/1/2018')		//effectiveDate
            );
        Test.stopTest();
        Assert.areEqual(5, result.getResponseCode(), 'Response Code should be equal to 5');
    }

    @IsTest
    private static void testAddLineAndContract() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQAddLineResponse result = service.addAgreementLine(
                '000002',	//customerId,
                'Item',     //level
                '',				//vendorId,
                '01', 			//divisionId,
                'SW', 			//systemId,
                'PI', 			//segmentId,
                '01', 			//classId,
                '0101', 		//brandId,
                '0001',			//setId,
                '0001',			//subsetId,
                '00000001',		//productCode,
                'maintainGTM',	//policyType,
                0.2,			//policyValue,
                'SH',			//priceUnit,
                Date.today()		//effectiveDate
            );
        Test.stopTest();
        Assert.areNotEqual(null, result, 'Should not be equal to null');
    }

    @IsTest
    private static void testAddLineNAItem() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQAddLineResponse result = service.addAgreementLine(
                '000001',	    //customerId,
                'Item',         //level
                '',				//vendorId,
                '01', 			//divisionId,
                'SW', 			//systemId,
                'PI', 			//segmentId,
                '01', 			//classId,
                '0101', 		//brandId,
                '0001',			//setId,
                '0001',			//subsetId,
                '00000003',		//productCode,
                'maintainGTM',	//policyType,
                0.2,			//policyValue,
                'SH',			//priceUnit,
                Date.today()	//effectiveDate
            );
        Test.stopTest();
        Assert.areNotEqual(null, result.getMessage(), 'Message should not be equal to null');
    }

    @IsTest
    private static void testAddLineWoProduct() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQAddLineResponse result = service.addAgreementLine(
                '000001',	    //customerId,
                'Item',         //level
                '',				//vendorId,
                '01', 			//divisionId,
                'SW', 			//systemId,
                'PI', 			//segmentId,
                '01', 			//classId,
                '0101', 		//brandId,
                '0001',			//setId,
                '0001',			//subsetId,
                '',		        //productCode,
                'maintainGTM',	//policyType,
                0.2,			//policyValue,
                'SH',			//priceUnit,
                Date.today()	//effectiveDate
            );
        Test.stopTest();
        Assert.areEqual(7, result.getResponseCode(), 'Response Code should be equal to 7');
        Assert.areNotEqual(null, result.getMessage(), 'Message should not be equal to null');
    }

    @IsTest
    private static void testAddLineWithNoAccount() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQAddLineResponse result = service.addAgreementLine(
                '000000',	    //customerId,
                'Item',         //level
                '',				//vendorId,
                '01', 			//divisionId,
                'SW', 			//systemId,
                'PI', 			//segmentId,
                '01', 			//classId,
                '0101', 		//brandId,
                '0001',			//setId,
                '0001',			//subsetId,
                '00000001',		//productCode,
                'maintainGTM',	//policyType,
                0.2,			//policyValue,
                'SH',			//priceUnit,
                Date.today()	//effectiveDate
            );
        Test.stopTest();
        Assert.areEqual(4, result.getResponseCode(), 'Response Code should be equal to 4');
        Assert.areNotEqual(null, result.getMessage(), 'Message should not be equal to null');
    }

    @IsTest
    private static void testGetRecommendationForProspectIsNotNull() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AIQMockAPIResponseGenerator());
            AIQPriceRecommendation rec = service.getRecommendationForProspect(
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
        Test.stopTest();
        Assert.areNotEqual(null, rec.getStatus(), 'Status should not be equal to null');
    }

    @IsTest
    private static void testResolveNAConflict() {
        Test.startTest();
            List<zpl__ContractLineItem__c> contractLineItems = AIQService.resolveNAConflict(contractLinesDraft);
        Test.stopTest();
        Assert.isTrue(contractLineItems.isEmpty(), 'List should be empty');
    }

    @IsTest
    private static void testApproveAgrLine() {
        Test.startTest();
            List<AIQApproveRejectLineResponse> responses = AIQService.approveAgrLine(contractLinesPendAppr[0].Id);
        Test.stopTest();
        Assert.isTrue(!responses.isEmpty(), 'List should not be empty');
    }

    @IsTest
    private static void testApproveAgrLineCase2() {
        Test.startTest();
            List<AIQApproveRejectLineResponse> responses = AIQService.approveAgrLine(new List<Id>{contractLinesDraftCampaign[0].Id});
        Test.stopTest();
        Assert.isTrue(!responses.isEmpty(), 'List should not be empty');
    }

    @IsTest
    private static void testRejectAgrLine() {
        Test.startTest();
            List<AIQApproveRejectLineResponse> responses = AIQService.rejectAgrLine(contractLinesPendAppr[0].Id);
        Test.stopTest();
        Assert.isTrue(!responses.isEmpty(), 'List should not be empty');
    }

    @IsTest
    private static void testRejectAgrLineCase2() {
        Test.startTest();
        List<AIQApproveRejectLineResponse> responses = AIQService.rejectAgrLine(new List<Id>{contractLinesDraftCampaign[0].Id});
        Test.stopTest();
        Assert.isTrue(!responses.isEmpty(), 'List should not be empty');
    }

    @IsTest
    private static void testGetAgrLine() {
        Test.startTest();
            List<zpl__ContractLineItem__c> contractLines = AIQService.getAgrLine(
                    new List<Id>{contractLinesDraft[0].Id, contractLinesDraftCampaign[0].Id}
            );
        Test.stopTest();
        Assert.isTrue(!contractLines.isEmpty(), 'Contract Line list should not be empty');
    }

    @IsTest
    private static void testGetAgrLineException() {
        Test.startTest();
            String error;
            try {
                AIQService.getAgrLine(null);
            } catch(Exception e) {
                error = e.getMessage();
            }
        Test.stopTest();
        Assert.isTrue(String.isNotBlank(error), 'The error message should not be blank');
    }

    @IsTest
    private static void testUpdateAgreementLinesPositive() {
        List<AIQApproveRejectLineResponse> responses = new List<AIQApproveRejectLineResponse>();
        Test.startTest();
            responses = AIQService.updateAgreementLines(contractLinesDraft);  
        Test.stopTest();
        Assert.areEqual(0, responses.size(), 'The lines should be updated successfully, responses size should be 0');
    }

    @IsTest
    private static void testGetFailedResponsesAndAsyncRetry() {
        List<AIQApproveRejectLineResponse> responses = new List<AIQApproveRejectLineResponse>();
        Map<Id, String> failedRecordsMap = new Map<Id, String>();
        failedRecordsMap.put(contractLinesDraft[0].Id, 'Some error');
        Test.startTest();
            responses = AIQService.getFailedResponsesAndAsyncRetry(contractLinesDraft, failedRecordsMap);  
        Test.stopTest();
        Assert.areEqual(1, responses.size(), 'Error should be logged to response');
    }
}
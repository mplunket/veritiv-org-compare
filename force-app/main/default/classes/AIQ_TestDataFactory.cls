@IsTest
public class AIQ_TestDataFactory {
    private static final List<String> LINE_LEVEL_NAMES = new List<String>{
        'Item',
        'Subset',
        'Set',
        'BrandVendor',
        'Brand',
        'ClassVendor',
        'Class'
    };

    public static List<Account> initializeAccounts(Account prototype, Integer numberOfRecords, Boolean isMock) {
        Map<String, Object> populatedFields = prototype == null ? new Map<String, Object>() : prototype.getPopulatedFieldsAsMap();

        system.debug('Data factory start for Accounts');
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Account acct = prototype == null ? new Account() : prototype.clone(false, true);
            if (isMock) {
                acct.Id = (String) AIQts_ApexMocks.generateId(new Account().getSObjectType());
            }
            acct.Name = 'zTestData' + i;
            accounts.add(acct);
        }
        if (!isMock) {
            insert accounts;
        }
        system.debug('Data factory end for Accounts. Output size => ' + accounts.size());
        return accounts;
    }

    public static List<Servicing_Division__c> initializeDivisions(
        Servicing_Division__c prototype,
        Integer numberOfRecords,
        Boolean isMock
    ) {
        Map<String, Object> populatedFields = prototype == null ? new Map<String, Object>() : prototype.getPopulatedFieldsAsMap();

        system.debug('Data factory start for Division');
        List<Servicing_Division__c> divisions = new List<Servicing_Division__c>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Servicing_Division__c div = prototype == null ? new Servicing_Division__c() : prototype.clone(false, true);
            if (isMock) {
                div.Id = (String) AIQts_ApexMocks.generateId(new Servicing_Division__c().getSObjectType());
            }
            div.Name = 'TestDiv' + i;
            divisions.add(div);
        }
        if (!isMock) {
            insert divisions;
        }
        system.debug('Data factory end for Divisions. Output size => ' + divisions.size());
        return divisions;
    }

    public static List<Contract> initializeContracts(Contract prototype, Integer numberOfRecords, Boolean isMock) {
        List<Contract> objectList = new List<Contract>();
        prototype.recalculateFormulas();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Contract entityObj = prototype == null ? new Contract() : prototype.clone(false, true);
            if (isMock) {
                entityObj.Id = (String) AIQts_ApexMocks.generateId(new Contract().getSObjectType());
            }
            objectList.add(entityObj);
        }
        if (!isMock) {
            insert objectList;
        }
        return objectList;
    }

    public static List<zpl__ContractLineItem__c> initializeContractsLines(
        zpl__ContractLineItem__c prototype,
        Integer numberOfRecords,
        Boolean isMock
    ) {
        return initializeContractsLines(prototype, numberOfRecords, isMock, true);
    }

    public static List<zpl__ContractLineItem__c> initializeContractsLines(
        zpl__ContractLineItem__c prototype,
        Integer numberOfRecords,
        Boolean isMock,
        Boolean isRecalculateFormulas
    ) {
        List<zpl__ContractLineItem__c> objectList = new List<zpl__ContractLineItem__c>();
        if (isRecalculateFormulas) {
            prototype.recalculateFormulas();
        }
        for (Integer i = 0; i < numberOfRecords; i++) {
            zpl__ContractLineItem__c entityObj = prototype == null ? new zpl__ContractLineItem__c() : prototype.clone(false, true);
            if (isMock) {
                entityObj.Id = (String) AIQts_ApexMocks.generateId(new zpl__ContractLineItem__c().getSObjectType());
                entityObj.zpl__ContractLineItemId__c = entityObj.zpl__ContractLineItemId__c == null
                    ? AIQ_CommonUtil.getGuid()
                    : entityObj.zpl__ContractLineItemId__c;
            }
            objectList.add(entityObj);
        }
        if (!isMock) {
            insert objectList;
        }
        return objectList;
    }

    public static AIQZilliantConfiguration__c initializeZilliantConfiguration() {
        return initializeZilliantConfiguration(null, false);
    }

    public static AIQZilliantConfiguration__c initializeZilliantConfiguration(AIQZilliantConfiguration__c prototype, Boolean isMock) {
        AIQZilliantConfiguration__c entity = prototype == null ? new AIQZilliantConfiguration__c() : prototype.clone(false, true);
        entity.GetPriceDataFormula__c = 'f_getAPIContractLineData';
        entity.GetRecommendationsFormula__c = 'testFormula';
        entity.ManagersPermissionSet__c = 'TestPermSet';
        entity.SalesAdminProfiles__c = 'System Administrator\n' + 'Pricing\n' + 'Sales Admin - Lightning\n';
        entity.BatchJobSize__c = 200;
        entity.EffectiveDateHorizon__c = 180;
        entity.LineScoreThreshold__c = 101;
        entity.FESEnabledLineLevel__c = 'Item\nSet\nSubset';
        entity.FESRequestSize__c = 20;
        entity.NotificationGroup__c = 'andriy.sukh@zilliant.com \n andriy.sukh@zilliant.com';
        entity.GetPriceDataFormulaEE__c = 'f_getAPIContractLineData';
        entity.FESThreads__c = 1;
        entity.runZcloudSync__c = true;
        entity.runCLIZcloudSync__c = true;
        entity.runContractZcloudSync__c = true;
        entity.runProductZCloudSync__c = true;
        entity.LineSourceSyncExclusions__c = 'C';
        entity.UserSyncExclusions__c = 'andriy.sukh@zilliant.com';
        entity.ComparisonPrecision__c = 0.001;

        if (!isMock) {
            insert entity;
        }
        return entity;
    }

    public static NationalAccountsPricing__c initializeNationalAccountsPricing(NationalAccountsPricing__c prototype, Boolean isMock) {
        NationalAccountsPricing__c entity = prototype == null ? new NationalAccountsPricing__c() : prototype.clone(false, true);
        if (prototype == null) {
            entity.Name = '00000003';
            entity.NationalAccountGroupID__c = 'testNA';
            entity.Class__c = 'A';
            entity.Price__c = 1;
            entity.CompositeKey__c = 'SWtestNA';
        }
        if (!isMock) {
            insert entity;
        }
        return entity;
    }

    public static zpl__ProductSelectorConfiguration__c initializeProductSelectorConfiguration(
        zpl__ProductSelectorConfiguration__c prototype,
        Boolean isMock
    ) {
        zpl__ProductSelectorConfiguration__c entity = prototype == null
            ? new zpl__ProductSelectorConfiguration__c()
            : prototype.clone(false, true);
        if (prototype == null) {
            entity.Name = 'Add Contract Products';
            entity.zpl__TargetObject__c = 'Contract';
            entity.zpl__UniqueNickname__c = 'DefaultContract';
        }
        if (!isMock) {
            insert entity;
        }
        return entity;
    }

    public static Map<String, zpl__LineLevel__c> initializeAllLineLevels(zpl__LineLevel__c prototype, Boolean isMock) {
        Map<String, zpl__LineLevel__c> allLineLevels = new Map<String, zpl__LineLevel__c>();
        for (Integer i = 0; i < LINE_LEVEL_NAMES.size(); i++) {
            String levelName = LINE_LEVEL_NAMES[i];
            zpl__LineLevel__c lineLevel = prototype == null ? new zpl__LineLevel__c() : prototype.clone(false, true);
            lineLevel.Name = levelName;
            lineLevel.zpl__LineLevelId__c = levelName;
            lineLevel.zpl__Position__c = i;
            if (isMock) {
                lineLevel.Id = (String) AIQts_ApexMocks.generateId(new zpl__LineLevel__c().getSObjectType());
            }
            allLineLevels.put(levelName, lineLevel);
        }
        if (!isMock) {
            Database.insert(allLineLevels.values());
        }
        return allLineLevels;
    }

    public static List<AIQ_CWTItem__c> initializeCWTItems(AIQ_CWTItem__c prototype,Integer numberOfRecords, Boolean isMock) {
        List<AIQ_CWTItem__c> objectList = new List<AIQ_CWTItem__c>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            AIQ_CWTItem__c entityObj = prototype == null ? new AIQ_CWTItem__c() : prototype.clone(false, true);
            if (isMock) {
                entityObj.Id = (String) AIQts_ApexMocks.generateId(new AIQ_CWTItem__c().getSObjectType());
            }
            objectList.add(entityObj);
        }
        if (!isMock) {
            insert objectList;
        }
        return objectList;
    }

    public static zpl__LineLevel__c initializeLineLevel(zpl__LineLevel__c prototype, Boolean isMock) {
        zpl__LineLevel__c entity = prototype == null ? new zpl__LineLevel__c() : prototype.clone(false, true);
        if (isMock) {
            entity.Id = (String) AIQts_ApexMocks.generateId(new zpl__LineLevel__c().getSObjectType());
        }

        if (prototype == null) {
            entity.Name = 'Item';
            entity.zpl__LineLevelId__c = 'Item';
            entity.zpl__Position__c = 1;
            entity.zpl__ProductSelectorConfiguration__c = (String) AIQts_ApexMocks.generateId(
                new zpl__ProductSelectorConfiguration__c().getSObjectType()
            );
        }
        if (!isMock) {
            insert entity;
        }
        return entity;
    }

    public static zpl__QuickActionConfig__c initializeQuickActionConfig(zpl__QuickActionConfig__c prototype, Boolean isMock) {
        zpl__QuickActionConfig__c entity = prototype == null ? new zpl__QuickActionConfig__c() : prototype.clone(false, true);
        if (prototype == null) {
            entity.Name = 'Test Name';
            entity.SObjectType__c = 'zpl__ContractLineItem__c';
        }
        if (!isMock) {
            insert entity;
        }
        return entity;
    }

    public static zpl__QuickActionField__c initializeQuickActionField(
        zpl__QuickActionField__c prototype,
        Id quickActionConfigId,
        Boolean isMock
    ) {
        zpl__QuickActionField__c entity = prototype == null ? new zpl__QuickActionField__c() : prototype.clone(false, true);
        if (prototype == null) {
            entity.Name = 'Test field';
            entity.DisplayMode__c = 'COMBOBOX';
            entity.QuickActionConfig__c = quickActionConfigId;
            entity.Position__c = '1.1';
            entity.Field_Action__c = 'Reset';
        }
        if (!isMock) {
            insert entity;
        }
        return entity;
    }

    public static List<Ship_To__c> initializeShipTo(Ship_To__c prototype, Integer numberOfRecords, Boolean isMock) {
        List<Ship_To__c> objectList = new List<Ship_To__c>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Ship_To__c entityObj = prototype == null ? new Ship_To__c() : prototype.clone(false, true);
            if (isMock) {
                entityObj.Id = (String) AIQts_ApexMocks.generateId(new Ship_To__c().getSObjectType());
            }
            entityObj.Name = 'Test Ship' + i;
            objectList.add(entityObj);
        }
        if (!isMock) {
            insert objectList;
        }
        return objectList;
    }

    public static zpl__ProductUOM__c initializeProductUOM(
            zpl__ProductUOM__c prototype,
            Boolean isMock
    ) {
        zpl__ProductUOM__c entityObj = prototype == null ? new zpl__ProductUOM__c() : prototype.clone(false, true);
        if (isMock) {
            entityObj.Id = (String) AIQts_ApexMocks.generateId(new zpl__ProductUOM__c().getSObjectType());
        }

        if (!isMock) {
            insert entityObj;
        }
        return entityObj;
    }

    public static zpl__PolicyType__c initializePolicyType(
            zpl__PolicyType__c prototype,
            Boolean isMock
    ) {
        zpl__PolicyType__c entityObj = prototype == null ? new zpl__PolicyType__c() : prototype.clone(false, true);
        if (isMock) {
            entityObj.Id = (String) AIQts_ApexMocks.generateId(new zpl__PolicyType__c().getSObjectType());
        }

        if (!isMock) {
            insert entityObj;
        }
        return entityObj;
    }

    public static zpl__IQAnywhereConfiguration__c initializeIQAnywhereConfig(
            zpl__IQAnywhereConfiguration__c prototype,
            Boolean isMock
    ) {
        zpl__IQAnywhereConfiguration__c entity = prototype == null ? new zpl__IQAnywhereConfiguration__c() : prototype.clone(false, true);
        if (prototype == null) {
            entity.Name = 'f_getAPIContractLineData';
            entity.zpl__SourceObject__c = 'zpl__ContractLineItem__c';
        }

        if (isMock) {
            entity.Id = (String) AIQts_ApexMocks.generateId(new zpl__IQAnywhereConfiguration__c().getSObjectType());
        }

        if (!isMock) {
            upsert entity;
        }
        return entity;
    }

    public static List<Product2> initializeProduct2s(
            Product2 prototype,
            Integer numberOfRecords,
            Boolean isMock
    ) {
        List<Product2> product2s = new List<Product2>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Product2 product2 = prototype == null ? new Product2() : prototype.clone(false, true);
            product2.Name = 'Product ' + i;
            product2.System_id__c = '03';
            product2.ProductCode = '00000001';
            product2.isActive = true;
            product2.Division_Code__c = '01';
            product2.List_Price__c = 1.0;
            product2.Pricing_Costing_UOM__c= 'SH';
            product2.WMS_UOM__c = 'X';
            if (isMock) {
                product2.Id = AIQts_ApexMocks.generateId(new Product2().getSObjectType());
            }
            product2s.add(product2);
        }
        if (!isMock) {
            insert product2s;
        }
        return product2s;
    }
}
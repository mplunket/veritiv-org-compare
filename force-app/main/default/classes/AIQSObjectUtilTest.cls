@IsTest
private class AIQSObjectUtilTest {
    private static final String CLI_STATUS_DRAFT = 'Draft';
    private static final String CLI_RT_DRAFT_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName()
            .get('Draft')
            .getRecordTypeId();
    private static List<Account> accounts;
    private static List<Servicing_Division__c> divisions;
    private static List<Contract> contracts;
    private static zpl__ProductUOM__c uom;
    private static List<Product2> products;
    private static List<zpl__ContractLineItem__c> contractLinesDraft1;
    private static List<zpl__ContractLineItem__c> contractLinesDraft2;

    static {
        AIQ_TestDataFactory.initializeZilliantConfiguration();
        accounts = AIQ_TestDataFactory.initializeAccounts(
                new Account(
                        Name = 'Test Account',
                        Active__c = 'Yes'
                ),
                1,
                false
        );
        divisions = AIQ_TestDataFactory.initializeDivisions(
                new Servicing_Division__c(
                        Name = 'TestDiv2',
                        Division_Code__c = '70',
                        Division_Composite_Key__c = '0370'
                ),
                1,
                false
        );
        contracts = AIQ_TestDataFactory.initializeContracts(
                new Contract(
                        Name = 'TestContract',
                        AccountId = accounts[0].Id,
                        Division__c = divisions[0].Id
                ),
                1,
                false
        );
        uom = AIQ_TestDataFactory.initializeProductUOM(
                new zpl__ProductUOM__c(
                        Name = 'M',
                        zpl__ConversionFactor__c = 1
                ),
                false
        );
        products = AIQ_TestDataFactory.initializeProduct2s(null, 1, false);
        contractLinesDraft1 = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine 1',
                        zpl__Contract__c = contracts[0].Id,
                        zpl__Status__c = CLI_STATUS_DRAFT,
                        RecordTypeId = CLI_RT_DRAFT_ID,
                        LineSource__c = 'U',
                        zpl__EffectiveDate__c = System.today(),
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id
                ),
                1,
                false,
                false
        );
        contractLinesDraft2 = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine 2',
                        zpl__Contract__c = contracts[0].Id,
                        zpl__Status__c = CLI_STATUS_DRAFT,
                        RecordTypeId = CLI_RT_DRAFT_ID,
                        LineSource__c = 'U',
                        zpl__EffectiveDate__c = System.today().addDays(-1),
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id
                ),
                1,
                false,
                false
        );
    }

    @IsTest
    private static void testAscSortObjsList() {
        Test.startTest();
            List<zpl__ContractLineItem__c> linesListSorted = AIQSObjectUtil.sortObjsList(
                    new List<zpl__ContractLineItem__c>{contractLinesDraft1[0], contractLinesDraft2[0]},
                    'zpl__EffectiveDate__c',
                    'Date',
                    'ASC'
            );
        Test.stopTest();
        Assert.areEqual('ContractLine 2', linesListSorted[0].Name, 'Should be equal');
    }

    @IsTest
    private static void testDescSortObjsList() {
        Test.startTest();
            List<zpl__ContractLineItem__c> linesListSorted = AIQSObjectUtil.sortObjsList(
                    new List<zpl__ContractLineItem__c>{contractLinesDraft1[0], contractLinesDraft2[0]},
                    'zpl__EffectiveDate__c',
                    'Date',
                    'DESC'
            );
        Test.stopTest();
        Assert.areEqual('ContractLine 2', linesListSorted[1].Name, 'Should be equal');
    }

    @IsTest
    private static void testSortContractLineItems() {
        Test.startTest();
        List<zpl__ContractLineItem__c> linesListSorted = AIQSObjectUtil.sortContractLineItems(
                new List<zpl__ContractLineItem__c>{
                        contractLinesDraft1[0],
                        contractLinesDraft2[0]
                }
        );
        Test.stopTest();
        Assert.areEqual(2, linesListSorted.size(), 'Size should be equal');
    }

    @IsTest
    private static void testGetClone() {
        Test.startTest();
            List<String> excludeFields = new List<String>();
            List<zpl__ContractLineItem__c> linesListCopy = AIQSObjectUtil.getClone(
                    'zpl__ContractLineItem__c',
                    new List<Id>{ contractLinesDraft1[0].Id },
                    excludeFields
            );
        Test.stopTest();
        Assert.areEqual(contractLinesDraft1.size(), linesListCopy.size(), 'Size should be equal');
        Assert.areNotEqual(null, linesListCopy[0].zpl__Contract__c, 'Should not be equal to null');
    }

    @IsTest
    private static void testGetCloneExtensive() {
        Test.startTest();
            List<String> excludeFields = new List<String>();
            List<zpl__ContractLineItem__c> linesListCopy = AIQSObjectUtil.getClone(
                    'zpl__ContractLineItem__c',
                    new List<Id>{ contracts[0].Id },
                    excludeFields, 'zpl__Contract__c',
                    true,
                    true
            );
        Test.stopTest();
        Assert.areEqual(2, linesListCopy.size(), 'Size should be equal');
        Assert.areNotEqual(null, linesListCopy[0].zpl__Contract__c, 'Should not be equal to null');
    }
}
@IsTest
public without sharing class AIQ_ContractCopyUtilTest {

    private static final String TEST_NAME = 'Test Name';
    private static final String EXCEPTION_FAILURE_ERROR_MESSAGE = 'Exception failure';
    private static final String ACCOUNT_CHAIN_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Chain_Account')
        .getRecordTypeId();
    private static List<Account> accounts;
    private static List<Account> chainAccounts;
    private static List<Account> chainAccountsWithoutDivision;
    private static List<Contract> contracts;
    private static List<Servicing_Division__c> divisions;
    private static AIQ_ContractCopyUtil contractCopyUtil = new AIQ_ContractCopyUtil();
   
    static {
        contracts = AIQ_TestDataFactory.initializeContracts(new Contract(Name = TEST_NAME), 1, true);
        divisions = AIQ_TestDataFactory.initializeDivisions(null,1,true);
        accounts = AIQ_TestDataFactory.initializeAccounts(
            new Account(Name = 'TestAccount'),
            1,
            true
        );
        chainAccounts = AIQ_TestDataFactory.initializeAccounts(
            new Account(Name = 'TestAccount',
                        recordTypeId = ACCOUNT_CHAIN_ACCOUNT_RECORD_TYPE_ID,
                        Representative_Division__c = divisions[0].Id
            ),
            1,
            true
        );
        chainAccountsWithoutDivision = AIQ_TestDataFactory.initializeAccounts(
            new Account(Name = 'TestAccount',
                        recordTypeId = ACCOUNT_CHAIN_ACCOUNT_RECORD_TYPE_ID
            ),
            1,
            true
        );
    }

    @IsTest
    private static void testCopyContract() {
        mockCopyDraftLines();
        Test.startTest();
        Contract contract = contractCopyUtil
            .copyContract(new List<Id>{contracts[0].Id}, new List<String>())
            .getCloneContract();
        Test.stopTest();
        Assert.isNotNull(contract, 'contract is created');
        Assert.areEqual(contract, contracts[0], 'contract is cloned');
    }

    @IsTest
    private static void testSetClonedContract() {
        mockCopyDraftLines();
        Test.startTest();
        Contract contract = contractCopyUtil
            .copyContract(new List<Id>{contracts[0].Id}, new List<String>())
            .setClonedContract(accounts[0])
            .getCloneContract();
        Test.stopTest();
        Assert.isNotNull(contract, 'contract is created');
        Assert.areEqual(contract.Name, accounts[0].Name, 'contract reset with new values');
    }

    @IsTest
    private static void testSetClonedContractFromChainAccount() {
        mockCopyDraftLines();
        Test.startTest();
        Contract contract = contractCopyUtil
            .copyContract(new List<Id>{contracts[0].Id}, new List<String>())
            .setClonedContract(chainAccounts[0])
            .getCloneContract();
        Test.stopTest();
        Assert.isNotNull(contract, 'contract is created');
        Assert.areEqual(accounts[0].Name, contract.Name, 'contract reset with new values');
        Assert.areEqual(contract.Division__c, divisions[0].Id, 'contract reset with servicing division new values');
    }

    @IsTest
    private static void testSetClonedContractFromChainAccountNegative() {
        mockCopyDraftLines();
        Test.startTest();
        Contract contract;
            try {
                contract = contractCopyUtil
                    .copyContract(new List<Id>{contracts[0].Id}, new List<String>())
                    .setClonedContract(chainAccountsWithoutDivision[0])
                    .getCloneContract();
                Assert.fail(EXCEPTION_FAILURE_ERROR_MESSAGE);
            } catch (Exception e) {
                Assert.areEqual('Representative division not found', e.getMessage(), 'set error message');
            }
        Test.stopTest();
    }

    private static void mockCopyDraftLines() {
        AIQts_ApexMocks mocks = new AIQts_ApexMocks();
        AIQco_SObjectUtil sobjectUtilMock = (AIQco_SObjectUtil) mocks.mock(AIQco_SObjectUtil.class);
        AIQ_GenericSelector genericSelectorMock = (AIQ_GenericSelector) mocks.mock(AIQ_GenericSelector.class);

        mocks.startStubbing();
        mocks.when(
                sobjectUtilMock.getClone(
                    AIQ_ContractCopyUtil.CONTRACT_OBJECT_NAME,
                    new List<Id>(new Map<Id, SObject>(contracts).keySet()),
                    new List<String>(),
                    false
                )
            )
            .thenReturnForAny(contracts);
 
        mocks.when(
            genericSelectorMock.queryServicingDivisionsByCompositeKey(
                    new List<String>(),
                    chainAccounts[0].Representative_Division__c,
                    1
                )
            )
            .thenReturnForAny(divisions);
        mocks.stopStubbing();

        contractCopyUtil.sObjectUtil = sobjectUtilMock;
        contractCopyUtil.genericSelector = genericSelectorMock;
    }
}
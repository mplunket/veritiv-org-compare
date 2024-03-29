@IsTest
private class AIQAgrLineRejectionTest {
    private static final String CLI_STATUS_PEND_APPR = 'Pend Appr';
    private static final String CLI_STATUS_DELETED = 'Deleted';
    private static final String CLI_RT_DRAFT_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();
    private static final String CLI_RT_INACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c
            .getRecordTypeInfosByDeveloperName().get('Inactive').getRecordTypeId();
    private static List<Account> accounts;
    private static List<Servicing_Division__c> divisions;
    private static List<Contract> contracts;
    private static zpl__ProductUOM__c uom;
    private static List<Product2> products;
    private static List<zpl__ContractLineItem__c> contractLinesPendAppr;
    private static List<zpl__ContractLineItem__c> contractLinesDeleted;

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
        contractLinesPendAppr = AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine1',
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
        contractLinesDeleted = (AIQ_TestDataFactory.initializeContractsLines(
                new zpl__ContractLineItem__c(
                        Name = 'ContractLine2',
                        zpl__Contract__c = contracts[0].Id,
                        zpl__Status__c = CLI_STATUS_DELETED,
                        RecordTypeId = CLI_RT_INACTIVE_ID,
                        LineSource__c = 'U',
                        zpl__UOM__c = uom.Id,
                        zpl__Product__c = products[0].Id
                ),
                1,
                false,
                false
        ));
    }

    @IsTest
    private static void testRejectAgrLineListSuccess() {
        Test.startTest();
            List<AIQApproveRejectLineResponse> result = AIQAgrLineRejection.rejectAgrLine(new List<Id>{contractLinesPendAppr[0].Id});
        Test.stopTest();

        Assert.areNotEqual(null, result.get(0).getLineId(), 'Line Id should not be null');
        Assert.areNotEqual(null, result.get(0).getMessage(), 'Message should not be null');
    }

    @IsTest
    private static void testRejectAgrLineError() {
        Test.startTest();
            List<AIQApproveRejectLineResponse> result = AIQAgrLineRejection.rejectAgrLine(new List<Id>{contractLinesDeleted[0].Id});
        Test.stopTest();

        Assert.areEqual('1', result.get(0).getResponseCode(), 'Response Code should be equal to 1');
    }

    @IsTest
    private static void testRejectAgrLineException() {
        Test.startTest();
            List<AIQApproveRejectLineResponse> result = AIQAgrLineRejection.rejectAgrLine(new List<Id>{contractLinesPendAppr[0].Id});
        Test.stopTest();

        Assert.areNotEqual('1', result.get(0).getResponseCode(), 'Response Code should not be equal to 1');
    }
}
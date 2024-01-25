@IsTest
public class AIQtr_AccountTriggerHandlerTest {
    private static final String ACCOUNT_RT_PROSPECT_ID = Schema.SObjectType.Account
    .getRecordTypeInfosByDeveloperName()
    .get('Prospect')
    .getRecordTypeId();

private static List<Servicing_Division__c> divisions;
private static List<Account> accounts;

static {
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
                    RecordTypeId = ACCOUNT_RT_PROSPECT_ID,
                    OwnerId = UserInfo.getUserId(),
                    Servicing_Division__c = divisions[0].Id
            ),
            1,
            false
    );

}
     
    @IsTest
    private static void testAfterInsert() {
        List<Account> accountList;
        Test.startTest();
        accountList = AIQ_TestDataFactory.initializeAccounts(null, 1, false);
        Test.stopTest();

        Assert.areEqual(2, [SELECT count() FROM Account], 'The amount should be equal to 1');

    }

    @IsTest
    private static void testAfterUpdate() {
        List<Account> accBeforeUpdate = [SELECT Id, Name FROM Account WHERE Id =: accounts[0].Id];
        Test.startTest(); 
        accBeforeUpdate[0].Name = 'Test Account updated';
        update accBeforeUpdate;
        Test.stopTest();
        List<Account> accAfterUpdate = [SELECT Id, Name FROM Account WHERE Id =: accounts[0].Id];

        Assert.areEqual('Test Account updated', accAfterUpdate[0].Name, 'Account Name should be updated');
    }

    @IsTest
    private static void testDelete() {
        AIQtr_AccountTriggerHandler handler = new AIQtr_AccountTriggerHandler();
        Test.startTest(); 
        handler.beforeDelete();
        handler.afterDelete();
        Test.stopTest();
    }
}
@isTest
public class myAddPrefAgentToCaseControllerTest{

    private static final Integer NUM_OF_OBJs = 5;
    
    private static Id customerRTId;
    private static Id testRecordTypeId;
    
    private static Account testAccount;
    private static Contact testContact;
    
    private static List<Case> testCases;
    
    private static void setup()
    {
        TestingUtils.setupInactiveRecordType();
        
        testRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get( '20. F2C - Inbound Case' ).getRecordTypeId();
        customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Customer' ).getRecordTypeId();

        testAccount = TestingUtils.createAccount( 'Test Account' );
        testAccount.RecordTypeId = customerRTId;
        insert testAccount;
        
        testContact = TestingUtils.createContact( 'John', 'Doe', true );
        testCases = TestingUtils.generateCases( NUM_OF_OBJs, testAccount.Id, testContact.Id, testRecordTypeId, true );
        
    }
    
    private static testMethod void testValidCaseId()
    {
        setup();
        Case c = [Select Id From Case Limit 1];
        
        PageReference bsreplypage = Page.BS_ReplyEmailToExistingCase;
        Test.setCurrentPage(bsreplypage);
        
        Test.startTest();
            myAddPrefAgentToCaseController.addPrefAgentToCase(c.Id, '12345');
        Test.stopTest();
        
    }
    
    private static testMethod void testNoCaseId()
    {
        setup();
        
        PageReference bsreplypage = Page.BS_ReplyEmailToExistingCase;
        Test.setCurrentPage(bsreplypage);
        
        Test.startTest();
            myAddPrefAgentToCaseController.addPrefAgentToCase('5002', '12345');
        Test.stopTest();
        
    }
    
}
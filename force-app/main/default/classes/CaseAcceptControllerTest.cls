@isTest 
public class CaseAcceptControllerTest 
{
    static testMethod void testMethod1() 
    {
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        Case testCase= new Case();
        testCase.accountid = testAccount.id;
        insert testCase;
        
        Test.StartTest(); 
            ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
            ApexPages.currentPage().getParameters().put('id', String.valueOf(testCase.Id));
            CaseAcceptController CACont = new CaseAcceptController (sc); 
            CACont.init();
            
        Test.StopTest();
        
    }
    
    
    
}
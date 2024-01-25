@isTest 
public class WOAcceptControllerTest 
{
    static testMethod void testMethod1() 
    {
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        WorkOrder testWO= new WorkOrder();
        testWO.accountid = testAccount.id;
        insert testWO;
        
        Test.StartTest(); 
            ApexPages.StandardController sc = new ApexPages.StandardController(testWO);
            ApexPages.currentPage().getParameters().put('id', String.valueOf(testWO.Id));
            WOAcceptController WOCont = new WOAcceptController(sc); 
            WOCont.init();
            
        Test.StopTest();
        
    }
    
    
    
}
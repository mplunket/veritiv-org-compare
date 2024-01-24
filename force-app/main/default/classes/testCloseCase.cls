@isTest
public class testCloseCase {
    @isTest
    public static void closeCaseMethod(){
                 // create a Case
        Case aCase = new Case( Subject = 'Test Subject',
                               Status = 'New',
                               Priority = 'Medium',
                               Case_Type__c = 'POD');
        insert aCase;       
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(aCase);
        CloseCase testAccPlan = new CloseCase(sc);
        
        PageReference reference = Page.closecase;
        reference.getParameters().put('caseId', aCase.Id);
        Test.setCurrentPage(reference);
        testAccPlan.CloseCaseMethod();
        testAccPlan.goBack();
    }
}
@isTest
public class testMassUpdateAccountReassignmentCls {
    
    @isTest
    public static void testmassUpdateAccountReassignmentCls(){
        
        List<User> testUsers = TestDataGeneration.createUsers( 'Test3', 'Standard User', 2, true );
        List<Primary_Sales_Rep__c> psrs = new List<Primary_Sales_Rep__c>();
        List<Primary_Sales_Rep__c> iReps = new List<Primary_Sales_Rep__c>();
        
        for( User user : testUsers )
        {
            for( Primary_Sales_Rep__c psr : TestDataGeneration.createPSRs( 2, false ) )
            {
                psr.SF_userid__c = user.Id;
                psrs.add( psr );
            }
            
            for( Primary_Sales_Rep__c psr : TestDataGeneration.createPSRs( 2, false ) )
            {
                psr.SF_userid__c = user.Id;
                iReps.add( psr );
            }
        }
        
        insert psrs;
        insert iReps;
                
        Account_Reassignment__c testAccountReassignment = new Account_Reassignment__c(Name='Test Company Name123',Account_Owner_Primary_Sales_Rep__c = psrs[0].id);
        List<Account_Reassignment__c> newTestList = new List<Account_Reassignment__C>();
        newTestList.add(testAccountReassignment);
        insert newTestList;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(newTestList);
        massUpdateAccountReassignmentCls testAccPlan = new massUpdateAccountReassignmentCls(sc);
        
        testAccPlan.ReassignmentNotes = 'testing';
        testAccPlan.NoReassignmentNeededExplanation = 'testing';
        testAccPlan.selectedStage = 'CLosed';
        
        testAccPlan.aRListing = newTestList.deepclone();
        testAccPlan.aRe = new Account_Reassignment__c(Name='Test Company Name123',Account_Owner_Primary_Sales_Rep__c = psrs[0].id);
       // aRListing.add(newTestList);
        
         List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Account_Reassignment__c.Reassignment_Stage__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
         system.assertEquals(options, testAccPlan.reassignmentStages);
      
        testAccPlan.massUpdateRecords();
        testAccPlan.getproposedLookup();
        testAccPlan.massUpdateRecords();
        testAccPlan.updateSelected();
        testAccPlan.aRe = [select id,Proposed_New_Owner_Primary_Sales_Rep__c,Reassignment_Notes__c,No_Reassignment_Needed_Explanation__c,Reassignment_Stage__c from account_reassignment__c where id =:newTestList[0].id];
        testAccPlan.aRListing = [select id,Proposed_New_Owner_Primary_Sales_Rep__c,Reassignment_Notes__c,No_Reassignment_Needed_Explanation__c,Reassignment_Stage__c from account_reassignment__c where id =:newTestList[0].id];
        testAccPlan.ReassignmentNotes = 'test';
        testAccPlan.NoReassignmentNeededExplanation = 'test';
        testAccplan.selectedStage = 'test';
        testAccPlan.updateSelected();
        
        
    }
}
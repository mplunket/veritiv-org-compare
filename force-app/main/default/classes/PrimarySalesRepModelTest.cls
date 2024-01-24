@isTest
public class PrimarySalesRepModelTest {

    
    private static List<Primary_Sales_Rep__c> testReps = new List<Primary_Sales_Rep__c>();
    private static Map<Id, List<Primary_Sales_Rep__c>> testReps2drs = new Map<Id, List<Primary_Sales_Rep__c>>();
    private static List<Primary_Sales_Rep__c> testDirectReports = new List<Primary_Sales_Rep__c>();
    PrimarySalesRepModel obj = new PrimarySalesRepModel();
     primary_sales_rep__c psr = obj.record ;
   
    private static List<Primary_Sales_Rep__c> createTestDirectReports(Primary_Sales_Rep__c reportsTo, Integer batch)
    {
        List<Primary_Sales_Rep__c> tempDrs = new List<Primary_Sales_Rep__c>();
        for(Integer i=0; i<5; i++)
        {
            tempDrs.add(new Primary_Sales_Rep__c(Name='Joe Test2', Network_Id__c= batch + '000' + i, Email__c='user@domain.com', Reports_To__c=reportsTo.Id, Include_in_Reporting_Hierarchy__c=true));
        }
        insert tempDrs;
        return tempDrs;
    }

    
     private static void testSetupData(Integer batchSize)
    {   
        
        testReps.clear();
        testReps2drs.clear();
        
        for(Integer i=0; i<batchSize; i++)
        {
            Primary_Sales_Rep__c testRep = new Primary_Sales_Rep__c(Name='Joe Test', Network_Id__c='1234' + i, Email__c='user@domain.com');
            
            testReps.add(testRep);          
        }
        
        insert testReps;
        for(Integer i=0; i<batchSize; ++i)
        {
            testReps2drs.put(testReps[i].Id, createTestDirectReports(testReps[i], i));
        }
            
    }
    
        public static testmethod void testgetDirectReports_Id()
    {
        testSetupData(1);
        System.assertEquals(testReps2drs.get(testReps[0].Id).size(), PrimarySalesRepModel.getDirectReports(testReps[0]).size());
        primary_sales_rep__c psr = new primary_sales_rep__c();
        PrimarySalesRepModel.getDirectReports( psr);
    }
    
    public static testmethod void testgetDirectReports_List()
    {
        testSetupData(25);
        
        for(Id psrId : testReps2drs.keySet())
        {
            testDirectReports.addAll(testReps2drs.get(psrId));
        }
        System.assertEquals(testDirectReports.size(), PrimarySalesRepModel.getDirectReports(testReps2drs.keySet()).size());
        
    }
}
@isTest
public class SegmentBudgetsControllerTest {


   
/***************************************************************************************************/
/*                 TEST METHODS                                                                    */
/***************************************************************************************************/

    private static User testUser;
    private static User testSalesRepUser;
    private static Primary_Sales_Rep__c testPsr;    
    private static List<Primary_Sales_Rep__c> testDirectReports;
    
    private static Id BM_PROFILE;
    
    public static void testSetupData()
    {
       
        testUser = TestingUtils.createUser('John', 'Sales Manager - lightning', true);
        BM_PROFILE = testUser.ProfileId;
        
        testPsr = TestingUtils.createPSRs(1, 'Jimmy', 'networkid', false)[0];
        testPsr.SF_userid__c = testUser.Id;
        
        System.runAs(TestingUtils.ADMIN_USER){
        	
        	insert testPsr;
        }
        
      /*  testDirectReports = [select Id, Name from Primary_Sales_Rep__c where Reports_To__c = :testPsr.Id 
                            and (user_profile__c like 'Ind and Core Zone Manager%' or user_profile__c like 'Specialist%' or Include_in_Reporting_Hierarchy__c = true)
                            and deactivated_user__c != true];*/
                           
    }
    
    public static testmethod void testConstructor()
    {
        testSetupData();
        
        Test.startTest();                      
        SegmentBudgetsController sbc = new SegmentBudgetsController();
        
        System.assert(!sbc.isTotal);
        System.assert(sbc.isDraft);
        System.assertEquals('Paper', sbc.selectedSegment);
        System.assertEquals('2010', sbc.selectedYear);
        
        Test.stopTest();
    }
    
    public static testmethod void testConstructor_RunAs()
    {
        testSetupData();
        
        System.runAs(testUser)
        {   
            Test.startTest();                          
            SegmentBudgetsController sbc = new SegmentBudgetsController();
            
            System.assert(!sbc.isTotal);
            System.assert(sbc.isDraft);
            System.assertEquals('Paper', sbc.selectedSegment);
            System.assertEquals('2010', sbc.selectedYear);
           
           /*
           	NOTE -- COMMENTING OUT DUE TO REORG -- NEED TO UPDATE BASED ON NEW HIERARCHY 
           
            // Add 1 to testDirectReports, as in the Controller we add the BM to the list of reports as well
            System.assertEquals(testDirectReports.size() + 1, sbc.directReports.size());
            */
            Test.stopTest();
        }
    }
    
    public static testmethod void testConstructorError_RunAs_No_PSR()
    {
        testSetupData();
        
        System.runAs(new User(FirstName='John', LastName='Doe', Email='test@unisourcelink.com', 
                                Username='test@unisourcelink.com', ProfileId=BM_PROFILE,
                                Alias='tuni', Network_Id__c='tuni', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US',
                                EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', Country='USA'))
        {   
            Test.startTest();                          
            SegmentBudgetsController sbc = new SegmentBudgetsController();
            
            System.assertEquals('Error: You do not have a Primary Sales Rep record.', sbc.messageBlock);            
            Test.stopTest();
        }
    }
    
    public static testmethod void testSave()
    {
    	testSetupData();
    	
    	System.runAs(testUser)
        {   
	        Test.startTest();
	                                   
	        SegmentBudgetsController sbc = new SegmentBudgetsController();
	        
	        sbc.saveAll();                  
	        Test.stopTest();
        }
    }
    
    public static testmethod void testSaveAndSendEmail()
    {
    	
        testSetupData();
        
        System.runAs(testUser)
        {    
	        Test.startTest();                          
	        SegmentBudgetsController sbc = new SegmentBudgetsController();
	                    
	        sbc.isDraft = false;
	        
	        System.debug(sbc.isDraft);
	        
	        sbc.saveAll();
	        Test.stopTest();
        }
    }

    public static testmethod void testWrapperClass()
    {
        testSetupData();
        
        System.runAs(testUser)
        {   
            Test.startTest();                          
            SegmentBudgetsController sbc = new SegmentBudgetsController();
            /*
           	NOTE -- COMMENTING OUT DUE TO REORG -- NEED TO UPDATE BASED ON NEW HIERARCHY
            // Add 1 to testDirectReports, as in the Controller we add the BM to the list of reports as well
            System.assertEquals(testDirectReports.size() + 1, sbc.directReports.size());
            */         
            //SegmentBudgetsController.PSRwrapper sbcWrap = new SegmentBudgetsController.PSRwrapper();
            for(String testSegment : new List<String>{'FS', 'Packaging', 'Paper', 'Unknown', 'Total'})
            {
                sbc.selectedSegment = testSegment;
                sbc.findSelectedBudgets();
                
                for(SegmentBudgetsController.PSRWrapper wrapper : sbc.directReports)
                {
                    Double testActiveBudget;
                    Double testGtmActiveBudget;
                    String testActiveBudgetString;
                    String testGtmActiveBudgetString;
                    
                    if(testSegment == 'FS')
                    {
                        testActiveBudget = wrapper.budget.FS_Sales_Budget__c != null ? wrapper.budget.FS_Sales_Budget__c : 0;
                        testGtmActiveBudget = wrapper.budget.FS_GTM_Budget__c != null ? wrapper.budget.FS_GTM_Budget__c : 0;
                    }
                    else if(testSegment == 'Packaging')
                    {
                        testActiveBudget = wrapper.budget.Packaging_Sales_Budget__c != null ? wrapper.budget.Packaging_Sales_Budget__c : 0;
                        testGtmActiveBudget = wrapper.budget.Packaging_GTM_Budget__c != null ? wrapper.budget.Packaging_GTM_Budget__c : 0;
                    }
                    else if(testSegment == 'Paper')
                    {
                        testActiveBudget = wrapper.budget.Paper_Sales_Budget__c != null ? wrapper.budget.Paper_Sales_Budget__c : 0;
                        testGtmActiveBudget = wrapper.budget.Paper_GTM_Budget__c != null ? wrapper.budget.Paper_GTM_Budget__c : 0;
                    }
                    else if(testSegment == 'Unknown')
                    {
                        testActiveBudget = wrapper.budget.Unknown_Sales_Budget__c != null ? wrapper.budget.Unknown_Sales_Budget__c : 0;
                        testGtmActiveBudget = wrapper.budget.Unknown_GTM_Budget__c != null ? wrapper.budget.Unknown_GTM_Budget__c : 0;
                    }
                    else if(testSegment == 'Total')
                    {
                        testActiveBudget = wrapper.budget.Total_Sales_Budget__c != null ? wrapper.budget.Total_Sales_Budget__c : 0;
                        testGtmActiveBudget = wrapper.budget.Total_GTM_Budget__c != null ? wrapper.budget.Total_GTM_Budget__c : 0;
                    }
                    
                    testActiveBudgetString = testActiveBudget.format();
                    testGtmActiveBudgetString = testGtmActiveBudget.format();
                    
                    System.assertEquals(testActiveBudget, wrapper.activeBudgetDecimal);
                    System.assertEquals(testActiveBudgetString, wrapper.activeBudget);
                    System.assertEquals(testGtmActiveBudget, wrapper.activeGTMBudgetDecimal);
                    System.assertEquals(testGtmActiveBudgetString, wrapper.activeGTMBudget);
                }
            }
            
            Test.stopTest();
        }
    }
    
    public static testmethod void testWrapperClass_baseFormattedContent()
    {
        testSetupData();
        System.runAs(testUser)
        {   
            Test.startTest();                          
            SegmentBudgetsController sbc = new SegmentBudgetsController();
            
            for(SegmentBudgetsController.PSRWrapper wrapper : sbc.directReports)
            {
            	System.assertNotEquals(null, wrapper.baseFormattedContent);
            }
            Test.stopTest();
        }
    }
    
    public static testmethod void testWrapperClass_bmFormattedContent()
    {
        testSetupData();
        System.runAs(testUser)
        {   
            Test.startTest();                          
            SegmentBudgetsController sbc = new SegmentBudgetsController();
        	System.assertNotEquals(null, sbc.currentUser.bmFormattedContent);
        	Test.stopTest();
        }
    }
}
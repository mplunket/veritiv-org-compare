@isTest
private class Cust360ToCaseAggregatorBatchTest {

  static List<C360_Customer_360__c> testCustomer360s;
  static List<Case> testCases;
  static List<Account> testAccounts; 
  static User testUser;
  static C360_Customer_360_Rollup_Mapping__c testCustomer360RollupMapping;
  static Final String mapToCust360field = 'C360_Issues_Last_30_Days__c'; //Total_Cases__c
  static Final String mapFromField = 'Email_Counter__c'; //Open_Case_Count__c
  static Final String mapFromObject = 'Case';
  static Final String aggregationType = 'SUM'; //AVG
  static Final String groupByField = 'Account.C360_Customer_360__r.Id';

    
    //Case
    static
	{
		InactiveRecordTypes__c testCustomSetting = new InactiveRecordTypes__c();
		testCustomSetting.Name = CaseServices.EBUSINESS_RT_NAME;

		System.runAs( TestingUtils.ADMIN_USER )
		{
			insert testCustomSetting;
		}
	}
	
	/* Used to Avoid Running Relationship Batch */
	public class Test_AggregatorBatchInterface implements Cust360ToCaseAggregatorBatch.BatchInterface {
    	
    	public void runRelationshipBatch()
    	{
    		
    	}
    }
    
  static testMethod void testPSRBatch()
  {
    setup(false);
    
    Test.startTest();
      Cust360ToCaseAggregatorBatch batch = new Cust360ToCaseAggregatorBatch();
      batch.strategyInterface = new Test_AggregatorBatchInterface();
      Database.executeBatch(batch);
    Test.stopTest();
     //String query = 'SELECT '+mapToCust360field+', Id FROM C360_Customer_360__c';
    for(C360_Customer_360__c cust360: [SELECT C360_Issues_Last_30_Days__c, Id FROM C360_Customer_360__c])
    {
        System.assertEquals(6, cust360.C360_Issues_Last_30_Days__c,'Total cases should have been equal to sum of count__c field of the associated cases');
    }
    
    System.assertEquals(false, [SELECT Name, C360_Order__c, C360_Is_Processed__c FROM C360_Customer_360_SObjects__c WHERE Name = 'Account'][0].C360_Is_Processed__c, 'Account should be processed' );
    System.assertEquals(false, [SELECT Name, C360_Order__c, C360_Is_Processed__c FROM C360_Customer_360_SObjects__c WHERE Name = 'Case'][0].C360_Is_Processed__c, 'Case should be processed' );

  }
   
   
   
   static testMethod void testPSRBatch_OneSObjectCustomSetting()
  {
    setup(true);
    
    Test.startTest();
      Cust360ToCaseAggregatorBatch batch = new Cust360ToCaseAggregatorBatch();
      batch.strategyInterface = new Test_AggregatorBatchInterface();
      Database.executeBatch(batch);
    Test.stopTest();
     //String query = 'SELECT '+mapToCust360field+', Id FROM C360_Customer_360__c';
    for(C360_Customer_360__c cust360: [SELECT C360_Issues_Last_30_Days__c, Id FROM C360_Customer_360__c])
    {
        System.assertEquals(6, cust360.C360_Issues_Last_30_Days__c,'Total cases should have been equal to sum of count__c field of the associated cases');
    }
    
    System.assertEquals(false, [SELECT Name, C360_Order__c, C360_Is_Processed__c FROM C360_Customer_360_SObjects__c WHERE Name = 'Case'][0].C360_Is_Processed__c, 'Case should be processed' );

  }
  
  static testMethod void testPSRBatch_NoSObjectCustomSetting()
  {
    setupData();
    
    Test.startTest();
      Cust360ToCaseAggregatorBatch batch = new Cust360ToCaseAggregatorBatch();
      batch.strategyInterface = new Test_AggregatorBatchInterface();
      Database.executeBatch(batch);
    Test.stopTest();
     

  }
   @TestVisible
    static void setupData(){
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND IsActive = True LIMIT 1 ];
    testCustomer360s = TestingUtils.createCustomer360s(2, true);
    Account testAccount1 = TestingUtils.createAccounts('testAccount',testCustomer360s[0].id , 2, true)[0];
    Account testAccount2 = TestingUtils.createAccounts('testAccount',testCustomer360s[1].id , 2, true)[0];
    List<Case> testCases1 = TestingUtils.createCases(testAccount1.id, 2, rt.id, false);
    for( Case aCase : testCases1 )
    {
      //aCase.Customer_360_ID__c = testCustomer360s[0].id;
      aCase.Email_Counter__c = 3;
    }
    insert testCases1;
    List<Case> testCases2 = TestingUtils.createCases(testAccount2.id, 2, rt.id, false);
     for( Case aCase : testCases2 )
    {
      //aCase.Customer_360_ID__c = testCustomer360s[1].id;
      aCase.Email_Counter__c = 3;
    }
    insert testCases2;
    testCustomer360RollupMapping = TestingUtils.createCustomer360RollupMappingSetting(mapToCust360field, mapFromField, mapFromObject, aggregationType, groupByField, true);

	testUser = TestingUtils.createUser('MarkyZ', 'Sales Professional - Lightning', /*doInsert*/ false);
	testUser.Email = 'test@example.com';
	insert testUser; 
	
	Apex_Class_Error_Emails__c newCs = new Apex_Class_Error_Emails__c();
	newCs.Name = 'TEST CS NAME';
	newCs.User_ID__c = testUser.Id;
	insert newCs;

    }
  
  
    static void setup(Boolean oneCustomSetting) 
  {
      setupData();
    C360_Customer_360_SObjects__c newCS1 = new C360_Customer_360_SObjects__c( Name = 'Case', C360_Order__c = 1, C360_Is_Processed__c = false );
    insert newCS1;
    
    if (!oneCustomSetting){
        C360_Customer_360_SObjects__c newCS2 = new C360_Customer_360_SObjects__c( Name = 'Account', C360_Order__c = 2, C360_Is_Processed__c = false );
        insert newCS2;
    }
     
  }
  
}
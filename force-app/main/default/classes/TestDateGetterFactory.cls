@isTest
public with sharing class TestDateGetterFactory {
	private static String sampleText = 'sampleText';
	private static Date sampleDate = Date.today()-5;
	private static Account testAccount;
	private static Opportunity testOpportunity;
	
	static testMethod void testFactoryMethodForTestingDateGetter() 
    {
		test.startTest();
			DateGetters.DateGetter returnedInstance = DateGetterFactory.getDateGetter( DateGetterFactory.GETTER_UNIT_TESTING );
		test.stopTest();
		System.assert(returnedInstance InstanceOf DateGetters.TestingDateGetter,'It should have returned the right instance');
		
    }
    
    static testMethod void testFactoryMethodForLastModifiedDateGetter() 
    {
		test.startTest(); 
			DateGetters.DateGetter returnedInstance = DateGetterFactory.getDateGetter( DateGetterFactory.GETTER_LAST_MODIFIED_DATE );
		test.stopTest();
		System.assert(returnedInstance InstanceOf DateGetters.LastModifiedDateGetter,'It should have returned the right instance');
		
    }
    
    private static void setup()
    {
    	testAccount = TestingUtils.createAccount(sampleText);
    	insert testAccount;
    	
    	testOpportunity =  TestingUtils.createOpportunity(testAccount.ID, sampleText);
    	insert testOpportunity;
    }
    
    static testMethod void test_getFieldName_TestingDateGetter_ForAccount() 
    {
    	DateGetters.DateGetter dateGetter = DateGetterFactory.getDateGetter( DateGetterFactory.GETTER_UNIT_TESTING );
    	Test.startTest();
    		String result = dateGetter.getFieldName(Account.SObjectType);
    	Test.stopTest();
    	
    	System.assertEquals(DateGetters.FIELD_FOR_TESTING_IN_ACCOUNT,result,'It should have returned the right name of the field');
    } 
    
    static testMethod void test_getFieldName_TestingDateGetter_ForOpportunity() 
    {
    	DateGetters.DateGetter dateGetter = DateGetterFactory.getDateGetter( DateGetterFactory.GETTER_UNIT_TESTING );
    	Test.startTest();
    		String result = dateGetter.getFieldName(Opportunity.SObjectType);
    	Test.stopTest();
    	
    	System.assertEquals(DateGetters.FIELD_FOR_TESTING_IN_OPPORTUNITY,result,'It should have returned the right name of the field');
    } 
    
    static testMethod void test_getDate_TestingDateGetter_ForAccount()
    {
    	setup();
    	testAccount.put(DateGetters.FIELD_FOR_TESTING_IN_ACCOUNT,sampleDate);
    	
    	DateGetters.DateGetter dateGetter = DateGetterFactory.getDateGetter( DateGetterFactory.GETTER_UNIT_TESTING  );
   		
   		Test.startTest();
    		Date result = dateGetter.getDateTime(testAccount).dateGMT();
    	Test.stopTest();
    	
    	System.assertEquals(sampleDate,result,'The date in the field for testing in account should be returned');
    }
    
    static testMethod void test_getDate_TestingDateGetter_ForOpportunity()
    {
    	setup();
    	testOpportunity.put(DateGetters.FIELD_FOR_TESTING_IN_OPPORTUNITY,sampleDate);
    	
    	DateGetters.DateGetter dateGetter = DateGetterFactory.getDateGetter( DateGetterFactory.GETTER_UNIT_TESTING  );
   		
   		Test.startTest();
    		Date result = dateGetter.getDateTime(testOpportunity).dateGMT();
    	Test.stopTest();
    	
    	System.assertEquals(sampleDate,result,'The date in the field for testing in opportunity should be returned');
    }
    
    static testMethod void test_getFieldName_LastModifiedDateGetter_ForAccount() 
    {
    	DateGetters.DateGetter dateGetter = DateGetterFactory.getDateGetter( DateGetterFactory.GETTER_LAST_MODIFIED_DATE );
    	Test.startTest();
    		String result = dateGetter.getFieldName(Account.SObjectType);
    	Test.stopTest();
    	
    	System.assertEquals(DateGetters.FIELD_FOR_LAST_MODIFIED_DATE,result,'It should have returned the right name of the field');
    } 
    
    static testMethod void test_getFieldName_LastModifiedDateGetter_ForOpportunity() 
    {
    	DateGetters.DateGetter dateGetter = DateGetterFactory.getDateGetter( DateGetterFactory.GETTER_LAST_MODIFIED_DATE );
    	Test.startTest();
    		String result = dateGetter.getFieldName(Opportunity.SObjectType);
    	Test.stopTest();
    	
    	System.assertEquals(DateGetters.FIELD_FOR_LAST_MODIFIED_DATE,result,'It should have returned the right name of the field');
    } 
    
    static testMethod void test_getDate_LastModifiedDateGetter_ForAccount()
    {
    	setup();
    	DateTime lastModifiedDate = testAccount.LastModifiedDate;
    	
    	DateGetters.DateGetter dateGetter = DateGetterFactory.getDateGetter( DateGetterFactory.GETTER_LAST_MODIFIED_DATE  );
   		
   		Test.startTest();
    		DateTime result = dateGetter.getDateTime(testAccount);
    	Test.stopTest();
    	
    	System.assertEquals(lastModifiedDate,result,'The lastmodifieddate for account should be returned');
    }
    
    static testMethod void test_getDate_LastModifiedDateGetter_ForOpportunity()
    {
    	setup();
    	DateTime lastModifiedDate = testOpportunity.LastModifiedDate;
    	
    	DateGetters.DateGetter dateGetter = DateGetterFactory.getDateGetter( DateGetterFactory.GETTER_LAST_MODIFIED_DATE  );
   		
   		Test.startTest();
    		DateTime result = dateGetter.getDateTime(testOpportunity);
    	Test.stopTest();
    	
    	System.assertEquals(lastModifiedDate,result,'The lastmodifieddate for opportunity should be returned');
    }
}
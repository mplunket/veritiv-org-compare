@isTest
public class Test_Cust360RelationshipBatchServices {
	
	static C360_Customer_360_SObjects__c csOpportunity;
	static C360_Customer_360_SObjects__c csCase;
	static C360_Customer_360_SObjects__c csAccount;
	static C360_Customer_360_SObjects__c csQuote;

    static Apex_Class_Error_Emails__c csUser1;
    static Apex_Class_Error_Emails__c csUser2;
    
    static C360_Customer_360__c test360_1;
    static C360_Customer_360__c test360_2;
    static C360_Customer_360__c test360_3;
    static Account testAcc;
    
    static List<Quote__c> testQuotes;
    static List<Case> testCases;
    static List<Opportunity> testOpps;
    
    static RecordType caseRecordType;
    
    final static Integer RECORD_COUNT = 200;
    final static Integer OPPORTUNITY_RECORD_COUNT = 5;
    
    /* Used to Overwrite Recursive Call */
    public class Test_RelationshipBatchInterface implements Cust360RelationshipBatch.BatchInterface {
    	
    	public void reRunBatch(String sObjectToUse)
    	{
    		
    	}
    }
    
    static void setupBatchTestData(Boolean doInsert)
    {
    	//setupCustomSettingObjects(doInsert);
    	
    	csOpportunity = new C360_Customer_360_SObjects__c( Name = 'Opportunity', C360_Order__c = 3.0, C360_Is_Processed__c = false );
    	insert csOpportunity;
    	
    	setupCustomSettingEmailUser(doInsert);
    	setupData(true);
    }
    
    static void setupData(Boolean doInsert)
    {
    	caseRecordType = [SELECT Id, Name , DeveloperName FROM RecordType WHERE IsActive = true AND SObjectType = 'Case'][0];
    	
    	test360_1 = TestingUtils.createCustomer360s(1, /*doInsert*/ doInsert)[0];
    	test360_2 = TestingUtils.createCustomer360s(1, /*doInsert*/ doInsert)[0]; 
        testAcc = TestingUtils.createAccounts('Test Account', test360_1.Id, 1, /*doInsert*/ doInsert)[0];
        
        testQuotes = TestingUtils.createQuotes(RECORD_COUNT, testAcc.Id, doInsert); 
        //testCases = TestingUtils.createCases(testAcc.Id, RECORD_COUNT, caseRecordType.Id, doInsert);
        testOpps = TestingUtils.createOpportunities(RECORD_COUNT, testAcc.Id, 'Test Oppty', /*doInsert*/ doInsert);
    }
	
	static void setupCustomSettingObjects(Boolean toInsert)
	{
	    csCase = new C360_Customer_360_SObjects__c( Name = 'Case', C360_Order__c = 1.0, C360_Is_Processed__c = false );
	    csAccount = new C360_Customer_360_SObjects__c( Name = 'Account', C360_Order__c = 2.0, C360_Is_Processed__c = false );
	    csOpportunity = new C360_Customer_360_SObjects__c( Name = 'Opportunity', C360_Order__c = 3.0, C360_Is_Processed__c = false );
	    csQuote = new C360_Customer_360_SObjects__c( Name = 'Quote__c', C360_Order__c = 4.0, C360_Is_Processed__c = false );
	    
	    if (toInsert)
	        insert new List<C360_Customer_360_SObjects__c>{csCase, csAccount, csOpportunity, csQuote} ;
	}

    static void setupCustomSettingEmailUser(Boolean toInsert)
    {
        User user1 = TestingUtils.createUser('User1', 'Sales Professional - Lightning', /*doInsert*/ false);
        user1.Email = 'test@example.com';
        User user2 = TestingUtils.createUser('User2', 'Sales Professional - Lightning', /*doInsert*/ false);
        user2.Email = 'test2@example.com';
        if (toInsert)
            insert new List<User>{user1, user2};

        csUser1 = new Apex_Class_Error_Emails__c( Name = 'User1', User_ID__c = user1.Id);
        csUSer2 = new Apex_Class_Error_Emails__c( Name = 'User2', User_ID__c = user2.Id);
        
        if (toInsert)
            insert new List<Apex_Class_Error_Emails__c>{csUser1, csUSer2};
    }

    static testMethod void testGetUnprocessedObject() 
    {
    	setupCustomSettingObjects(false);
    	C360_Customer_360_SObjects__c csActivity = new C360_Customer_360_SObjects__c( Name = 'Activity', C360_Order__c = 5.0, C360_Is_Processed__c = true );
    	insert new List<C360_Customer_360_SObjects__c>{ csCase, csAccount, csOpportunity, csActivity } ;
    	
    	String expectedObjects = 'Case';
    	
    	Test.startTest();
    		String actualObjects = Cust360RelationshipBatchServices.getUnprocessedObject();
    	Test.stopTest();
    	
    	System.assert(!String.isBlank(actualObjects), 'We expect an object to be returned.');
    	System.assertEquals(expectedObjects, actualObjects, 'We expect only certain objects to be returned.');
        
    }
    
    static testMethod void testResetProcessedSobjects()
    {
    	setupCustomSettingObjects(false);
    	csCase.C360_Is_Processed__c = true;
    	csAccount.C360_Is_Processed__c = true;
    	csOpportunity.C360_Is_Processed__c = true;
    	insert new List<C360_Customer_360_SObjects__c>{csCase, csAccount, csOpportunity} ;
    	
    	Test.startTest();
    		Cust360RelationshipBatchServices.resetProcessedSobjects();
    	Test.stopTest();
    	
    	List<C360_Customer_360_SObjects__c> updatedSObjects = C360_Customer_360_SObjects__c.getall().values();
    	for(C360_Customer_360_SObjects__c obj : updatedSObjects)
    		System.assertEquals( false, obj.C360_Is_Processed__c, 'We expect the ' + obj.Name + '\'s isProcessed to be set to false.');
    }
    
    static testMethod void testBuildQuery_RealObject()
    {
    	final String CASE_OBJ = 'Case';
    	
    	Test.startTest();
    		String resultQuery = Cust360RelationshipBatchServices.buildQuery(CASE_OBJ);
    	Test.stopTest();
    	    	
    	System.assert(resultQuery.contains(Cust360RelationshipBatchServices.C360_ID_FIELD), 'We expect the query to contain the 360 lookup field.');
    	System.assert(resultQuery.contains(Cust360RelationshipBatchServices.C360_FORMULA_FIELD), 'We expect the query to contain the 360 ID formula field.');
    	System.assert(resultQuery.contains(CASE_OBJ), 'We expect the query to contain the object being searched for.');
    }
    
    static testMethod void testBuildQuery_BogusObject()
    {
    	final String BOGUS_OBJ = 'Bogus';
    	
    	Test.startTest();
    		String resultQuery = Cust360RelationshipBatchServices.buildQuery(BOGUS_OBJ);
    		
    		List<Account> actualResults = Database.query(resultQuery);
    	Test.stopTest();
    	    	
    	System.assert( actualResults.isEmpty(), 'We expect the results returned from the bogus to be empty.');
    	System.assertEquals( resultQuery, Cust360RelationshipBatchServices.EMPTY_RESULTS_QUERY, 'We expect the result query to match the empty results query.');
    }

    static testMethod void testProcessFields_WithResults(){
        
        C360_Customer_360__c c360 = TestingUtils.createCustomer360s(1, /*doInsert*/ true)[0];
        Account newAcc = TestingUtils.createAccounts('Test Account', c360.Id, 1, /*doInsert*/ true)[0];
        List<Opportunity> optys = TestingUtils.createOpportunities(OPPORTUNITY_RECORD_COUNT, newAcc.Id, 'Test Oppty', /*doInsert*/ true);
        
        List<SObject> actualOptys = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Opportunity WHERE Id IN :optys];
        Test.startTest();
            List<Opportunity> actualResults = Cust360RelationshipBatchServices.processFields(Cust360RelationshipBatchServices.C360_FORMULA_FIELD, 
                                                                                    Cust360RelationshipBatchServices.C360_ID_FIELD, 
                                                                                    actualOptys);
        Test.stopTest();

        System.assertEquals(OPPORTUNITY_RECORD_COUNT, actualResults.size(), 'We expect the same number of Ids as Objects being tested.');
        for(Opportunity opt : actualResults){
            System.assertEquals(c360.Id, opt.C360_Customer_360__c, 'We expect the lookup field to match the 360 Id field.');
        }
    }

    static testMethod void testProcessFields_EmptyResults(){

        C360_Customer_360__c c360 = TestingUtils.createCustomer360s(1, /*doInsert*/ true)[0];
        Account newAcc = TestingUtils.createAccounts('Test Account', c360.Id, 1, /*doInsert*/ true)[0];
        List<Opportunity> optys = TestingUtils.createOpportunities(OPPORTUNITY_RECORD_COUNT, newAcc.Id, 'Test Oppty', /*doInsert*/ false);
        for(Opportunity opt : optys){
            opt.C360_Customer_360__c = c360.Id;
        }
        insert optys;
        
        List<SObject> actualOptys = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Opportunity WHERE Id IN :optys];
        
        Test.startTest();
            List<SObject> actualResults = Cust360RelationshipBatchServices.processFields(Cust360RelationshipBatchServices.C360_FORMULA_FIELD, 
                                                                                    Cust360RelationshipBatchServices.C360_ID_FIELD,
                                                                                    actualOptys);
        Test.stopTest();

        System.assert(actualResults.isEmpty(), 'We expect our results to be empty');
    }

    static testMethod void testProcessFields_BadObject(){
        List<Product2> products = TestingUtils.createProducts(5, /*doInsert*/ false);
        
        Test.startTest();
            List<SObject> actualResults = Cust360RelationshipBatchServices.processFields(Cust360RelationshipBatchServices.C360_FORMULA_FIELD, 
                                                                                    Cust360RelationshipBatchServices.C360_ID_FIELD,
                                                                                    products);
        Test.stopTest();

        System.assert(actualResults.isEmpty(), 'We expect our results to be empty since the object does not have the required fields.');
    }

    static testMethod void testUpdateC360s_withUpdates(){
        setupCustomSettingEmailUser(/*doInsert*/ true);
        C360_Customer_360__c c360 = TestingUtils.createCustomer360s(1, /*doInsert*/ true)[0];
        Account newAcc = TestingUtils.createAccounts('Test Account', c360.Id, 1, /*doInsert*/ true)[0];

        List<Opportunity> optys = TestingUtils.createOpportunities(OPPORTUNITY_RECORD_COUNT, newAcc.Id, 'Test Oppty', /*doInsert*/ true);
		optys = [SELECT Id, C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Opportunity WHERE Id IN :optys];
		
        Test.startTest();
            List<String> errors = Cust360RelationshipBatchServices.updateC360s(optys);
        Test.stopTest();

        List<Opportunity> actualResults = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Opportunity WHERE Id IN :optys];

        System.assert(!actualResults.isEmpty(), 'We expect our results to not be empty since some of the object fields should not match.');
        System.assert(errors.isEmpty(), 'We should not see any errors on our current data.');
        for(Opportunity opt : actualResults){
            System.assertEquals(c360.Id, opt.C360_Customer_360__c, 'We expect the lookup field to match the 360 Id field.');
        }
    }

    static testMethod void testUpdateC360s_withErrorBadData(){
        setupCustomSettingEmailUser(/*doInsert*/ true);
        C360_Customer_360__c c360 = TestingUtils.createCustomer360s(1, /*doInsert*/ true)[0];
        Account newAcc = TestingUtils.createAccounts('Test Account', c360.Id, 1, /*doInsert*/ true)[0];

        List<Opportunity> optys = TestingUtils.createOpportunities(OPPORTUNITY_RECORD_COUNT, newAcc.Id, 'Test Oppty', /*doInsert*/ true);
        
        List<Opportunity> updatedOptys = [SELECT Id, C360_Customer_360_ID_Formula__c, C360_Customer_360__c, AccountId FROM Opportunity WHERE Id IN :optys];
                
        for(Opportunity opt : updatedOptys)
        	opt.AccountId = c360.Id;

        Test.startTest();
            List<String> errors = Cust360RelationshipBatchServices.updateC360s(updatedOptys);
        Test.stopTest();

        List<Opportunity> actualResults = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Opportunity WHERE Id IN :updatedOptys];

        System.assert(!actualResults.isEmpty(), 'We expect our results to not be empty since some of the object fields should not match.');
        System.assert(!errors.isEmpty(), 'We should see errors on our current data.');
        for(Opportunity opt : actualResults){
            System.assertNotEquals(c360.Id, opt.C360_Customer_360__c, 'We expect the lookup field to not match the 360 Id field.');
        }
    }
    
    static testMethod void testRelationshipBatch_Alone()
    {
    	setupBatchTestData(true);
    	    	
    	//testCases = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Case WHERE Id IN :testCases];
    	//testQuotes = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Quote__c WHERE Id IN :testQuotes];
    	//testOpps = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Opportunity WHERE Id IN :testOpps];
    	
    	Test.startTest();
    		Cust360RelationshipBatch batch = new Cust360RelationshipBatch();
    		batch.strategyInterface = new Test_RelationshipBatchInterface();
    		Database.executeBatch(batch);
    	Test.stopTest();
    	
    	List<Opportunity> updatedOpps = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Opportunity WHERE Id IN :testOpps];
    	//List<Case> updatedCases = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Case WHERE Id IN :testCases];
    	//List<Quote__c> updatedQuotes = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Quote__c WHERE Id IN :testQuotes];
    	
    	List<C360_Customer_360_SObjects__c> updatedSObjects = C360_Customer_360_SObjects__c.getall().values();
    	for(C360_Customer_360_SObjects__c obj : updatedSObjects)
    		System.assertEquals( false, obj.C360_Is_Processed__c, 'We expect the ' + obj.Name + '\'s isProcessed to be set to false.'); 
    		
    	for(Opportunity opp : updatedOpps)
    		System.assertEquals( test360_1.Id, opp.C360_Customer_360__c, 'We expect each opportunity to have a 360 lookup be the same as the related 360.');
    	
    	//for(Case exCase : updatedCases)
    	//	System.assertEquals( test360_1.Id, exCase.C360_Customer_360__c, 'We expect each case to have a 360 lookup be the same as the related 360.');
    		
		//for(Quote__c qt : updatedQuotes)
    	//	System.assertEquals( test360_1.Id, qt.C360_Customer_360__c, 'We expect each quote to have a 360 lookup be the same as the related 360.');
    }
    
    static testMethod void testRelationshipBatch_Existing360()
    {
    	setupBatchTestData(true);
    	
    	//for(Quote__c qt : testQuotes)
    	//	qt.C360_Customer_360__c = test360_2.Id;
    	//update testQuotes;
    		
    	for(Opportunity opp : testOpps)
    		opp.C360_Customer_360__c = test360_2.Id;
    	update testOpps;
    	
    	Test.startTest();
    		Cust360RelationshipBatch batch = new Cust360RelationshipBatch();
    		batch.strategyInterface = new Test_RelationshipBatchInterface();
    		Database.executeBatch(batch);
    	Test.stopTest();
    	
    	List<Opportunity> updatedOpps = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Opportunity WHERE Id IN :testOpps];
    	//List<Quote__c> updatedQuotes = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Quote__c WHERE Id IN :testQuotes];
    	
    	List<C360_Customer_360_SObjects__c> updatedSObjects = C360_Customer_360_SObjects__c.getall().values();
    	for(C360_Customer_360_SObjects__c obj : updatedSObjects)
    		System.assertEquals( false, obj.C360_Is_Processed__c, 'We expect the ' + obj.Name + '\'s isProcessed to be set to false.'); 
    		
    	for(Opportunity opp : updatedOpps)
    		System.assertEquals( test360_1.Id, opp.C360_Customer_360__c, 'We expect each opportunity to have a 360 lookup be the same as the related 360.');
    		
		//for(Quote__c qt : updatedQuotes)
    	//	System.assertEquals( test360_1.Id, qt.C360_Customer_360__c, 'We expect each quote to have a 360 lookup be the same as the related 360.');
    }
    
    static testMethod void testRelationshipBatch_DummyObjects()
    {
    	//setupBatchTestData(true);
    	setupCustomSettingEmailUser(true);
    	
    	C360_Customer_360_SObjects__c csBogus = new C360_Customer_360_SObjects__c( Name = 'Bogus', C360_Order__c = 5.0, C360_Is_Processed__c = false );
    	insert csBogus;

    	Test.startTest();
    		Cust360RelationshipBatch batch = new Cust360RelationshipBatch();
    		Database.executeBatch(batch);
    	Test.stopTest();
    	
    	//List<Opportunity> updatedOpps = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Opportunity WHERE Id IN :testOpps];
    	//List<Quote__c> updatedQuotes = [SELECT C360_Customer_360_ID_Formula__c, C360_Customer_360__c FROM Quote__c WHERE Id IN :testQuotes];
    	
    	//System.assert(!Cust360RelationshipBatch.globalErrors.isEmpty(), 'We expect the list of global errors to not be empty. ' + Cust360RelationshipBatch.globalErrors);
    	
    	List<C360_Customer_360_SObjects__c> updatedSObjects = C360_Customer_360_SObjects__c.getall().values();
    	for(C360_Customer_360_SObjects__c obj : updatedSObjects)
    		System.assertEquals( false, obj.C360_Is_Processed__c, 'We expect the ' + obj.Name + '\'s isProcessed to be set to false.'); 
    		
    	//for(Opportunity opp : updatedOpps)
    	//	System.assertEquals( test360_1.Id, opp.C360_Customer_360__c, 'We expect each opportunity to have a 360 lookup be the same as the related 360.');
    		
		//for(Quote__c qt : updatedQuotes)
    	//	System.assertEquals( test360_1.Id, qt.C360_Customer_360__c, 'We expect each quote to have a 360 lookup be the same as the related 360.');
    }
    
}
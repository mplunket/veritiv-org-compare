@isTest
public with sharing class TestCaseListServiceConsoleCtrl {
	static
	{
		System.runAs(TestingUtils.ADMIN_USER)
		{
			List<RecordType> caseRecordTypes = [Select ID From RecordType Where SObjectType='Case' And IsActive=True Limit 1];
			insert (new InactiveRecordTypes__c(Name=CaseServices.EBUSINESS_RT_NAME,Record_Type_Id__c=caseRecordTypes[0].ID));
		}
	}
	
	public static testMethod void testGetCaseExistingViews() 
	{
		Case_Custom_List_Views__c allCases = new Case_Custom_List_Views__c(Name='1', Display_Name__c = 'All Cases', SOQL_Filter__c='Order By LastModifiedDate DESC');
		Case_Custom_List_Views__c someCases = new Case_Custom_List_Views__c(Name='2', Display_Name__c = 'Some Cases',SOQL_Filter__c='Where Status!=\'Closed\' Order By LastModifiedDate DESC');
		Case_Custom_List_Views__c myCases = new Case_Custom_List_Views__c(Name='3', Display_Name__c = 'My Cases',SOQL_Filter__c='Where OwnerID=$User.ID Order By LastModifiedDate DESC');
		List<Case_Custom_List_Views__c> listViews = new List<Case_Custom_List_Views__c> {allCases, someCases, myCases};
		insert listViews;
		
		Map<String,String> nameToExpectedSOQLFilter = new Map<String,String>(); 
		nameToExpectedSOQLFilter.put(allCases.Display_Name__c, allCases.SOQL_Filter__c + ' LIMIT ' + CaseListServiceConsoleCtrl.listViewLimit);
		nameToExpectedSOQLFilter.put(someCases.Display_Name__c, someCases.SOQL_Filter__c + ' LIMIT ' + CaseListServiceConsoleCtrl.listViewLimit);
		nameToExpectedSOQLFilter.put(myCases.Display_Name__c, 'Where OwnerID=\''+ UserInfo.getUserID() + '\' Order By LastModifiedDate DESC LIMIT ' + CaseListServiceConsoleCtrl.listViewLimit);
		
		List<String> expectedDisplayNames = new List<String> {allCases.Display_Name__c,myCases.Display_Name__c,someCases.Display_Name__c};
		
		CaseListServiceConsoleCtrl testController = new CaseListServiceConsoleCtrl();
		
		Test.startTest();
			List<SelectOption> options = CaseListServiceConsoleCtrl.caseExistingViews;
		Test.stopTest();
		
		System.assertEquals(listViews.size(),options.size(),'We expect to get back as many options as there are listviews');
		
		List<String> selectOptionLabels = new List<String>();
		for(SelectOption o : options)
			selectOptionLabels.add(o.getLabel());
		
		System.assertEquals(expectedDisplayNames, selectOptionLabels, 'We must get a select option for each custom list view, as defined in the custom settings. The label of the select option must match to the name of the custom list view');
		
		for(SelectOption o : options)
		{
			System.assertEquals(nameToExpectedSOQLFilter.get(o.getLabel()), o.getValue(), 'The value of each select option must correspond to the SOQL Filter that relates to the respective custom list view');
		}
		
		System.assertEquals(options[0].getValue(), testController.CaseFilter, 'The default list view upon the page loading is the first list view in the list view picklist');
		System.assertEquals(false,testController.areThereCases, 'If there are no cases matching the list view, then the property indicating whether or not there are any cases should be false');
	} 
	
	public static testMethod void testGetCaseExistingViews_CustomSettingNotPopulated()
	{
		CaseListServiceConsoleCtrl testController = new CaseListServiceConsoleCtrl();
		
		Test.startTest();
			List<SelectOption> options = CaseListServiceConsoleCtrl.caseExistingViews;
		Test.stopTest();
		
		System.assertNotEquals(null,options,'If the Case Custom List Views custom setting has no records, then there are no list views for the user to select.');
		System.assertEquals(0,options.size(),'If the Case Custom List Views custom setting has no records, then there are no list views for the user to select');
		System.assert(testController.getCases().isEmpty(),'If the Case Custom List Views custom setting has no records, then there are no cases to show');
		System.assertEquals(false,testController.areThereCases, 'If the Case Custom List Views custom setting has no records, no cases should display');
	}
	 
	public static testMethod void testNavigation()
	{	
		Case_Custom_List_Views__c someCases = new Case_Custom_List_Views__c(Name='Some Cases', Display_Name__c = 'Some Cases', SOQL_Filter__c='WHERE SUBJECT != \'A\' AND SUBJECT!= \'B\' ORDER BY SUBJECT DESC');
		insert someCases;
		
		UnitTest.createTestData(TestingUtils.cases).single().tag('Cases on Third Page of Default View').assign('Subject','Incoming Fax Type 1');
		UnitTest.createTestData(TestingUtils.cases).many(CaseListServiceConsoleCtrl.pageSize).tag('Cases on First Page of Default View').assign('Subject','Incoming Fax Type 3');
		UnitTest.createTestData(TestingUtils.cases).many(CaseListServiceConsoleCtrl.pageSize).tag('Cases on Second Page of Default View').assign('Subject','Incoming Fax Type 2');
		
		UnitTest.createTestData(TestingUtils.cases).many(CaseListServiceConsoleCtrl.pageSize).tag('Cases on First Page of Second View').assign('Subject','A');
		UnitTest.createTestData(TestingUtils.cases).single().tag('Cases on Second Page of Second View').assign('Subject','B');
		UnitTest.get(Case.SObjectType).insertAll();
		
		CaseListServiceConsoleCtrl testController = new CaseListServiceConsoleCtrl();
		
		Test.startTest();
			System.assertEquals(true,testController.areThereCases, 'We must correctly indicate if there are any cases matching the listview');
			UnitTest.analyze('Cases on First Page of Default View').assertEquivalence(testController.getCases(), 'We expect to show the right subset of cases, as specified by the custom list view and the current page');
			testController.CaseSetController.next();
			UnitTest.analyze('Cases on Second Page of Default View').assertEquivalence(testController.getCases(), 'We expect to show the right subset of cases, as specified by the custom list view and the current page');
			testController.CaseSetController.next();
			UnitTest.analyze('Cases on Third Page of Default View').assertEquivalence(testController.getCases(), 'We expect to show the right subset of cases, as specified by the custom list view and the current page');
			System.assert(!testController.CaseSetController.getHasNext(), 'We expect to show the right subset of cases, as specified by the custom list view and the current page');
			
			testController.CaseFilter = 'WHERE SUBJECT = \'A\' OR SUBJECT= \'B\' ORDER BY SUBJECT ASC';
			testController.resetFilter();
			UnitTest.analyze('Cases on First Page of Second View').assertEquivalence(testController.getCases(), 'We expect to show the right subset of cases, as specified by the custom list view and the current page');
			testController.CaseSetController.next();
			UnitTest.analyze('Cases on Second Page of Second View').assertEquivalence(testController.getCases(), 'We expect to show the right subset of cases, as specified by the custom list view and the current page');
			System.assert(!testController.CaseSetController.getHasNext(), 'We expect to show the right subset of cases, as specified by the custom list view and the current page');
			
		Test.stopTest();
	}
}
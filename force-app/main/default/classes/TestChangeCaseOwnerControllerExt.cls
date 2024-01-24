@isTest
private class TestChangeCaseOwnerControllerExt {

	static User outOfOfficeUser;
	static User nonOutOfOfficeUser;
	static List<User> newUsers;
	static RecordType inboundCaseRT;

	static {

		// create out of office user and non-out of office user
	//	System.runAs( TestDataGeneration.ADMIN_USER ) {

			newUsers = TestDataGeneration.createUsers( 'nusers', 'CSP with Create Order', 2, false );

			outOfOfficeUser = newUsers[0];
			outOfOfficeUser.Working_Status__c = 'Lunch';

			nonOutOfOfficeUser = newUsers[1];

			insert newUsers;
	//	}

		inboundCaseRT = CaseModel.getInboundCaseRT();
	}

	static testMethod void testChangeCaseToOutOfOfficeUser() {

		Case testCase = TestDataGeneration.createCase( inboundCaseRT.Id );
		insert testCase;

		ApexPages.Standardcontroller standardController = new ApexPages.Standardcontroller( testCase );
		ChangeCaseOwnerControllerExt changeOwnerController = new ChangeCaseOwnerControllerExt( standardController );

		Test.startTest();

        //create record of InactiveRecordTypes object
        InactiveRecordTypes__c inRec = new InactiveRecordTypes__c();
        inRec.name = 'eBusiness';
        inRec.Record_Type_Id__c = '012700000009YpU';
        insert inRec;
        
			changeOwnerController.changeOwnerCase.OwnerId = outOfOfficeUser.Id;
			ApexPages.PageReference returnedPage = changeOwnerController.beforeSave();

			Case updatedCase = [ SELECT Id, OwnerId FROM Case WHERE Id = :testCase.Id ];

			// make sure an error was displayed and the controller noted the failed save
			System.assertEquals( null, returnedPage );
			System.assertEquals( 1, ApexPages.getMessages().size(), 'Incorrect amount of error messages displayed' );
			System.assert( ApexPages.getMessages()[0].getSummary().contains( ChangeCaseOwnerControllerExt.OUT_OF_OFFICE_USER_MESG ), 'Error messages do not contain expected error' );
			System.assert( changeOwnerController.failedSave, 'Controller needed to acknowledge failed save' );

			// make sure the owner is still the running user
			System.assertEquals( UserInfo.getUserId(), updatedCase.OwnerId );

			// ignore owner status and change owner
			changeOwnerController.overrideUserStatus = true;
			returnedPage = changeOwnerController.beforeSave();

		Test.stopTest();

		System.assert( ( '/' + testCase.Id ).contains( returnedPage.getUrl() ), 'Case id should have been returned in URL' );

		updatedCase = [ SELECT Id, OwnerId, Last_Assigner__c FROM Case WHERE Id = :testCase.Id ];

		System.assertEquals( outOfOfficeUser.Id, updatedCase.OwnerId, 'New owner should be set to out of office user' );
		System.assertEquals( UserInfo.getUserId(), updatedCase.Last_Assigner__c, 'Last Assigner should be assigning user' );
	}

	static testMethod void testChangeCaseToInOfficeUser() {

		Case testCase = TestDataGeneration.createCase( inboundCaseRT.Id );
		insert testCase;

		ApexPages.Standardcontroller standardController = new ApexPages.Standardcontroller( testCase );
		ChangeCaseOwnerControllerExt changeOwnerController = new ChangeCaseOwnerControllerExt( standardController );

		Test.startTest();

        //create record of InactiveRecordTypes object
        InactiveRecordTypes__c inRec = new InactiveRecordTypes__c();
        inRec.name = 'eBusiness';
        inRec.Record_Type_Id__c = '012700000009YpU';
        insert inRec;
        
			changeOwnerController.changeOwnerCase.OwnerId = nonOutOfOfficeUser.Id;
			ApexPages.PageReference returnedPage = changeOwnerController.beforeSave();

		 

        
		System.assert( ( '/' + testCase.Id ).contains( returnedPage.getUrl() ), 'Case id should have been returned in URL' );

		// make sure that the owner was changed
		Case updatedCase = [ SELECT Id, OwnerId, Last_Assigner__c FROM Case WHERE Id = :testCase.Id ];

		System.assertEquals( nonOutOfOfficeUser.Id, updatedCase.OwnerId );
		System.assertEquals( UserInfo.getUserId(), updatedCase.Last_Assigner__c, 'Last Assigner should be assigning user' );
        Test.stopTest();
	}

    // eBisuness RecordType is removed and we do not need this code below
	/*static testMethod void testChangeEBusinessCaseToOutOfOfficeUser() {


        //create record of InactiveRecordTypes object
        InactiveRecordTypes__c inRec = new InactiveRecordTypes__c();
        inRec.name = 'eBusiness';
        inRec.Record_Type_Id__c = '012700000009YpU';
        insert inRec;
        
		System.assertNotEquals( null, CaseServices.eBusiness_RecordType_Id, 'The eWeb record type does not exist in the system' );
        account acc = new account();
        acc.name = 'test';
        insert acc;
        
		Case testCase1 = new case();
        testCase1.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('eBusiness').getRecordTypeId();
        testCase1.accountId = acc.id;
        testCase1.Status = 'Open';

		insert testCase1;

		//Case testCase = [Select Id,OwnerId FROM Case WHERE RecordTypeId = : CaseServices.eBusiness_RecordType_Id limit 1];

		//ApexPages.Standardcontroller standardController = new ApexPages.Standardcontroller( testCase );
		//ChangeCaseOwnerControllerExt changeOwnerController = new ChangeCaseOwnerControllerExt( standardController );

		//ignore status and override
		//changeOwnerController.overrideUserStatus = true;
		//changeOwnerController.changeOwnerCase.OwnerId = outOfOfficeUser.Id;

		Test.startTest();

			//ApexPages.PageReference returnedPage = changeOwnerController.beforeSave();

		Test.stopTest();
		//System.assert( ( '/' + testCase.Id ).contains( returnedPage.getUrl() ), 'Case id should have been returned in URL' );

		// make sure that the owner was changed
		//Case updatedCase = [ SELECT Id, OwnerId, Last_Assigner__c FROM Case WHERE Id = :testCase.Id ];

		//System.assertEquals( outOfOfficeUser.Id, updatedCase.OwnerId );
		//System.assertEquals( UserInfo.getUserId(), updatedCase.Last_Assigner__c, 'Last Assigner should be assigning user' );

	} */

}
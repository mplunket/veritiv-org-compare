@isTest
private class TestOutOfOfficeController {

	static final String IN_OFFICE_STATUS = 'In Office';
	static final String OUT_OF_OFFICE_STATUS = 'Lunch';

    static testMethod void toggleTest() {

		User salesRep = TestDataGeneration.createUser( 'Bill', 'Sales Professional - Lightning', false );
		salesRep.LastName = 'Reese';

		Test.startTest();

		System.runAs( salesRep ) {

			User testUser = [ SELECT Id, Working_Status__c FROM User WHERE Id = :salesRep.Id ];
			System.assertEquals( IN_OFFICE_STATUS, testUser.Working_Status__c, 'User default status should be In Office' );

			Test.setCurrentPageReference( Page.OutOfOffice );

			OutOfOfficeController controller = new OutOfOfficeController();

			controller.selectedWorkingStatus = OUT_OF_OFFICE_STATUS;

			controller.toggle();

		}

		Test.stopTest();

		User updatedUser = [ SELECT Id, Working_Status__c FROM User WHERE Id = :salesRep.Id ];

		System.assertEquals( OUT_OF_OFFICE_STATUS, updatedUser.Working_Status__c, 'User working status should have been set to another status' );
    }
}
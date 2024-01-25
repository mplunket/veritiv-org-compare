@isTest
private class TestGenericHistoryComponentController {

	static SObject testObject ;


	/*
		Note :
		Please instantiate an object that have the History tracking activate 
	*/
	static testMethod void testObjectHistoryConfiguration (){
		
		testObject = new Quote__c(  ) ;
		
		String expectedHistoryTable =  'Quote__History';
		
		String expectedObjectLadel =  'Quote';
		
		GenericHistoryComponentController historyController = new GenericHistoryComponentController();
        historyController.myObject = testObject;
        
        Test.startTest();
        	Boolean resul = historyController.initSObjectDescribe();
        Test.stopTest();
        
        System.assert( resul, 'History traking is not active for ' + testObject.getSObjectType().getDescribe().getLabel() );
	
        System.assertEquals( expectedHistoryTable , GenericHistoryComponentController.objectHistoryTableName );
        
        System.assertEquals( expectedObjectLadel , GenericHistoryComponentController.objectLabel );
        
        System.assertNotEquals( null ,  GenericHistoryComponentController.historyFieldPicklistValues );
	
	}
	
	
	
	static testMethod void testCreateHistoryLinesFromHistory (){
		
		List<GenericHistoryComponentController.ObjectHistoryWrapper> wrapper = new List<GenericHistoryComponentController.ObjectHistoryWrapper>();
		
		GenericHistoryComponentController.ObjectHistoryWrapper	ohw = new GenericHistoryComponentController.ObjectHistoryWrapper ();
		//ohw.createdById = '005700000017z2H';
        ohw.createdById = '005700000016aec';
		ohw.createdDate =  Datetime.now() ;
		ohw.newValue    = 'RandomNewValue';
		ohw.oldValue    = null;
		ohw.field       = 'created';
		wrapper.add ( ohw );
		
		ohw = new GenericHistoryComponentController.ObjectHistoryWrapper ();
		//ohw.createdById = '005700000017z2H';
        ohw.createdById = '005700000016aec';
		ohw.createdDate =  Datetime.now().addHours( 5 ) ;
		ohw.newValue    = 'AnotherValue';
		ohw.oldValue    = 'RandomNewValue';
		ohw.field       = 'field_name';
		ohw.fieldLabel  = 'Field Label';
		wrapper.add ( ohw );
		
		ohw = new GenericHistoryComponentController.ObjectHistoryWrapper ();
		//ohw.createdById = '005700000017z2H';
        ohw.createdById = '005700000016aec';
		ohw.createdDate =  Datetime.now().addHours( 10 ) ;
		ohw.newValue    = null;
		ohw.oldValue    = 'AnotherValue';
		ohw.field       = 'field_name';
		ohw.fieldLabel  = 'Field Label';

		wrapper.add ( ohw );
		
		GenericHistoryComponentController historyController = new GenericHistoryComponentController();
		
		Test.startTest();
			List<GenericHistoryComponentController.ObjectHistoryLine> objHistoryLineItems = historyController.createHistoryLinesFromHistory ( wrapper );		
		Test.stopTest();
		
		System.assertEquals( 3 , objHistoryLineItems.size() );

		System.assertEquals( 'Created.' , objHistoryLineItems[0].action );

		System.assertEquals( 'Changed <b>Field Label</b> from RandomNewValue to <b>AnotherValue</b>.' ,  objHistoryLineItems[1].action );

		System.assertEquals( 'Deleted AnotherValue in <b>Field Label</b>.' ,  objHistoryLineItems[2].action );
	
	} 
    
}
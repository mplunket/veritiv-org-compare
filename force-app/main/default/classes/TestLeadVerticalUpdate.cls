/**

 */
@isTest
private class TestLeadVerticalUpdate {
	// In a static block Create custom settings from scratch
    // CHecking for existing custom settings if they exist we delete them and create our own
static {
	system.runAs(testingUtils.admin_User){
        
        /*
        // Not Needed after API version 23
        Map<String,Industry_to_Vertical_Custom_Setting__c> settingsToDelete = Industry_to_Vertical_Custom_Setting__c.getAll();
        if (!settingsToDelete.isEmpty()){
        	delete settingsToDelete.values();
        	
        	}
        */
        	Industry_to_Vertical_Custom_Setting__c testIndustryToVertical1 = new Industry_to_Vertical_Custom_Setting__c (Name = 'Healthcare', Vertical__c = 'Healthcare');
        	Industry_to_Vertical_Custom_Setting__c testIndustryToVertical2 = new Industry_to_Vertical_Custom_Setting__c (Name = 'Government', Vertical__c = 'Government');
        	insert new List<Industry_to_Vertical_Custom_Setting__c> {testIndustryToVertical1, testIndustryToVertical2};
        	
        }
}
    static testMethod void testLeadCreation() {
        // TO DO: implement unit test
        
        // Create a Lead with reported industry set to a value
        // ensure value copies over to vertical field
        
        Lead testLead = testingUtils.createLeads(1, 'TestName', false).get(0);
        testLead.Industry = 'Healthcare';
                
        test.startTest();
        	insert testLead;
        test.stopTest();
        
        testLead = [SELECT Id, Vertical__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        
       // system.assertEquals ('Healthcare', testLead.Vertical__c);
        
    }
    
     static testMethod void testLeadModify() {
        
        // Create a Lead with reported industry set to a value
        // ensure value copies over to vertical field
        // Modify existing Lead
        // ensure value copies over to vertical field
        
        Lead testLead = testingUtils.createLeads(1, 'TestName', false).get(0);
        testLead.Industry = 'Healthcare';
        insert testLead;       
        testLead.Industry = 'Government';
        
        test.startTest();
        	update testLead;
        test.stopTest();
        
        testLead = [SELECT Id, Vertical__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
        
       // system.assertEquals('Government', testLead.Vertical__c);
        
    }
    
        
        
        
        
    }
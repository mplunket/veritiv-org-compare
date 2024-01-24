@isTest
private class WorkOrderDurationsTest {
    
    @isTest
    static void testTriggerInsertAndUpdate() {
        Primary_Sales_Rep__c rep = new Primary_Sales_Rep__c(Name='Test Name', Network_ID__c='TestTest', Email__c='test@test.com');
        insert rep;
        
        Account testAccount = new Account(Name='Test', Primary_Sales_Rep_Name__c=rep.Id, Account_Vertical__c='Education',Prospect_Segment__c='Print');
        insert testAccount;
        
        WorkOrder testWorkOrder = new WorkOrder(AccountId=testAccount.Id, Request__c='Test Work Order');
        insert testWorkOrder;
        
    	Work_Order_Durations__c wod = new Work_Order_Durations__c(Parent__c=testWorkOrder.Id, Status__c='Insert');        

        try {
            insert wod;
        } catch (Exception e) {
            System.assert(false, 'Before insert trigger should successfully run, but failed with this error: ' + e.getMessage());
        }
        
        wod.Status__c = 'Update';
        
        try {
            update wod;
        } catch (Exception e) {
            System.assert(false, 'Before update trigger should successfully run, but failed with this error: ' + e.getMessage());
        }
    }
}
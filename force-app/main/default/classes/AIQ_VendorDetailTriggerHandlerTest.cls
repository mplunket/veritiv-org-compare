@isTest
private class AIQ_VendorDetailTriggerHandlerTest {
    
    @TestSetup
    private static void testSetup() {
        Vendor_Detail__c vendorObject = getVendorDetail();
        insert vendorObject;
    }
    
    @isTest
    private static void insertVendorDetail() {
        Id vendorAccountId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Vendor'].Id;
        
        System.assert([SELECT count() 
        			   FROM Account 
        			   WHERE Name = 'Best Buy' 
        			   AND Vendor_Code__c = 'VC-12345'
        			   AND Client_Number__c = '123456'
        			   AND RecordTypeId = :vendorAccountId] >= 1, 'Should be equal 1');         
    }
    
    @isTest
    private static void updateVendorDetail() {
        Vendor_Detail__c vendorObject = [SELECT Id, Name, Vendor_Code__c 
                                         FROM Vendor_Detail__c 
                                         WHERE Name = 'Best Buy'];
        vendorObject.Name = 'Best Buy is updated';
        update vendorObject;
        
        System.assert([SELECT Name 
        			   FROM Vendor_Detail__c 
        			   WHERE Name = 'Best Buy is updated'].Name == 'Best Buy is updated', 'Should be equal');
    }
    
    @isTest
    private static void deleteVendorDetail() {
        Vendor_Detail__c vendorObject = [SELECT Id, Name, Vendor_Code__c 
                                         FROM Vendor_Detail__c 
                                         WHERE Name = 'Best Buy'];
        vendorObject.Name = 'Best Buy is deleted';
        delete vendorObject;
        
        System.assert([SELECT Id, Name 
        			   FROM Vendor_Detail__c 
        			   WHERE Name = 'Best Buy is deleted'].isEmpty(), 'Should be empty');
        
    }
    
    private static Vendor_Detail__c getVendorDetail() {
        return new Vendor_Detail__c(Name = 'Best Buy',
                                    Vendor_Code__c = 'VC-12345',
                                    Vendor_Client_Number__c = '123456');
    }
}
/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class VendorObjectToVendorAccountTests 
{
    static testMethod void insertOneVendorObject() 
    {
        Vendor_Detail__c vendorObject = new Vendor_Detail__c(Name='Best Buy',
        													 Vendor_Code__c = 'VC-12345',
        													 Vendor_Client_Number__c = '123456');
        
        insert vendorObject;
        
        Id vendorAccountId = [select Id from RecordType where SObjectType = 'Account' and Name = 'Vendor'].Id;
        
        System.assert([select count() 
        			   from Account 
        			   where Name = :vendorObject.Name 
        			   and Vendor_Code__c = :vendorObject.Vendor_Code__c
        			   and Client_Number__c = :vendorObject.Vendor_Client_Number__c
        			   and RecordTypeId = :vendorAccountId] >= 1);         
    }
}
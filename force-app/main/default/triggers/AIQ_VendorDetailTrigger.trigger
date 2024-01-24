trigger AIQ_VendorDetailTrigger on Vendor_Detail__c (before insert, before update, after insert, after update, after delete) {
    new AIQ_VendorDetailTriggerHandler().run();
}
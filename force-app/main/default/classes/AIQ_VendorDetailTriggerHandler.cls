public class AIQ_VendorDetailTriggerHandler extends AIQtr_TriggerHandler {
    private static final String VENDOR_ID_EXTERNAL_FIELD_NAME = Schema.SObjectType.Vendor_Detail__c.fields.AIQ_VendorId__c.getName();

    protected override void beforeInsert() {
        List<Vendor_Detail__c> newVendorDetails = Trigger.new;
        generateVendorId(newVendorDetails);
    }

    protected override void beforeUpdate() {
        List<Vendor_Detail__c> newVendorDetails = Trigger.new;
        generateVendorId(newVendorDetails);
    }

    protected override void afterInsert() {
        /* Next line must be in all after Trirrers!!! */
        syncDownVendor();
    }

    protected override void afterUpdate() {
        /* Next line must be in all after Trirrers!!! */
        syncDownVendor();
    }

    protected override void afterDelete() {
       /* Next line must be in all after Trirrers!!! */
        syncDownVendor();
    }

    private void syncDownVendor() {
        zpf.GenericSynchronizedDomainObject.triggerHandler(VENDOR_ID_EXTERNAL_FIELD_NAME);
    }

    private void generateVendorId(List<Vendor_Detail__c> vendorDetails) {
        AIQtr_TriggerHelper.addId(vendorDetails, VENDOR_ID_EXTERNAL_FIELD_NAME);
    }
}
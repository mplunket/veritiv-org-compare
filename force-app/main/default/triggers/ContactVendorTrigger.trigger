trigger ContactVendorTrigger on Contact (after insert, after update) {

	ContactServices.populateContactVendors( ContactServices.filterContactsAttachedToVendors(trigger.new, trigger.oldMap) );
}
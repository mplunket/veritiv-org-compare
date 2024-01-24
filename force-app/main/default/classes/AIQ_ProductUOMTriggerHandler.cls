public without sharing class AIQ_ProductUOMTriggerHandler {
    public static void updateHidden(List<zpl__ProductUOM__c> uoms) {
        for (zpl__ProductUOM__c puom : uoms) {
            if (!puom.Allow_For_Pricing__c) {
                puom.zpl__Hidden__c = true;
            } else {
                puom.zpl__Hidden__c = false;
            }
        }
    }

    public static void runSyncDown() {
        Boolean hasToRun = true;
        if (!Test.isRunningTest()) {
            hasToRun = (Boolean) AIQZilliantConfiguration__c.getInstance().get(AIQ_Constants.PRODUCT_UOM_EXTERNAL_ID);
        }

        if (hasToRun) {
            zpf.GenericSynchronizedDomainObject.triggerHandler(
                new AIQ_SyncUOMFilter('zpl__ProductUOM__c', 'SyncDownFieldSet'),
                'zpl__ProductUOMId__c'
            );
        }
    }
}
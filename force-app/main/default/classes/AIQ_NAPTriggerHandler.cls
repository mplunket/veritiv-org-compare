public without sharing class AIQ_NAPTriggerHandler {

    private static Set<String> deletedLines;

    static{
        deletedLines = new Set<String>();
    }

    public static void handleDelete() {
        List<NationalAccountsPricing__c> newNAP = new List<NationalAccountsPricing__c>((List<NationalAccountsPricing__c>)Trigger.new);
        List<NationalAccountsPricing__c> linesToDelete = new List<NationalAccountsPricing__c>();
        Set<String> deleteLineSet = new Set<String>();
        for(NationalAccountsPricing__c nap : newNAP){
            if (nap.Action__c == 'D' && ! deletedLines.contains(nap.Id) && ! deleteLineSet.contains(nap.Id)){
                linesToDelete.add(new NationalAccountsPricing__c(Id = nap.Id));
                deleteLineSet.add(nap.Id);
            }
        }

        try{
            delete linesToDelete;
            deletedLines.addAll(deleteLineSet);
        }catch(Exception e){
            system.debug(e.getMessage());
            linesToDelete[0].addError(e.getMessage());
        }
    }
}
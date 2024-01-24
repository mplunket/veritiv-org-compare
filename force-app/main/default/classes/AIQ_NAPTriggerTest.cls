@IsTest
public class AIQ_NAPTriggerTest {

    @TestSetup
    static void creteTestData(){
        List<NationalAccountsPricing__c> newNaps = new List<NationalAccountsPricing__c>();
        for(Integer i=0; i<201; i++){
            NationalAccountsPricing__c na = new NationalAccountsPricing__c (NationalAccountGroupID__c = 'NA'+i, NationalAccountPricingId__c = 'NA'+i, NationalAccountsPricingKey__c = 'NA'+i);
            newNaps.add(na);
        }
        insert newNaps;
    }

    @IsTest
    static void testHandleDelete() {
        system.assertEquals(201,  new List<NationalAccountsPricing__c>([SELECT Id, Name FROM NationalAccountsPricing__c]).size());
        List<NationalAccountsPricing__c> newNaps = new List<NationalAccountsPricing__c>();
        for(NationalAccountsPricing__c nap : [SELECT Id, Name FROM NationalAccountsPricing__c LIMIT 201]){
            NationalAccountsPricing__c newNap = new NationalAccountsPricing__c(id = nap.Id, Action__c = 'D');
            newNaps.add(newNap);
        }

        update newNaps;
        system.assertEquals(0,  new List<NationalAccountsPricing__c>([SELECT Id, Name FROM NationalAccountsPricing__c]).size());


    }
}
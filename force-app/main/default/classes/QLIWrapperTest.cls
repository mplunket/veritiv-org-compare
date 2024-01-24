@isTest
public class QLIWrapperTest {
public static testmethod void testQLIWrapper()
    {
        Test.startTest();
        QLIWrapper qw = new QLIWrapper(null);
        Quote_Line_Item__c qli = qw.qli;
        qw = new QLIWrapper(qli);
        
        Boolean testShow = qw.showPandA;
        System.assert(!testShow);
        qw.showPandA = true; 
        testShow = qw.showPandA;
        System.assert(testShow);
        
        Boolean testEnableUOM = qw.enableUOM;
        System.assert(!testEnableUOM);
        qw.enableUOM = true; 
        testEnableUOM = qw.enableUOM;
        System.assert(testEnableUOM);
        
        PricingAndAvailability paa = qw.PandA;
        System.assertNotEquals(null, paa);
        qw.PandA = paa;
        System.assertEquals(paa, qw.PandA);

        SelectOption[] sos = qw.quantityUOMs;
        System.assertNotEquals(null, sos);
        qw.quantityUOMs = sos;
        System.assertEquals(sos, qw.quantityUOMs);

        sos = qw.priceUOMs;
        System.assertNotEquals(null, sos);
        qw.priceUOMs = sos;
        System.assertEquals(sos, qw.priceUOMs);

        Opportunity opp = qw.extendedCost;
        System.assertEquals(0, opp.Amount);
        opp.Amount = 10;
        qw.extendedCost = opp;
        System.assertEquals(10, qw.extendedCost.Amount);

        Test.stopTest();
    }
}
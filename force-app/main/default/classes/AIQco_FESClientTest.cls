@IsTest
public class AIQco_FESClientTest {

    private static String testName = 'TestName';
    private static String testPriceLookUpName = 'TestPLName';
    private static String configName = 'TestConfig';
    /*
    * This method prepares the test data of this class.
    */
   
    @testSetup
    public static void prepareConfig(){
        AIQts_AbstractTestDataFactory.buildQuickActionConfiguration(configName, configName);
        Account acc = new Account(Name = 'Test account');
        insert acc;
        
        zpl__PriceLookup__c priceLookup = new zpl__PriceLookup__c();
        priceLookup.Name = testPriceLookUpName;
        priceLookup.zpl__Account__c = acc.Id;
        List<zpl__PriceLookup__c> priceLookups = AIQts_TestFactory.createSObjectList(priceLookup, 1, true);
        
        zpl__PriceLookupLine__c priceLookUpLine = new zpl__PriceLookupLine__c();
        priceLookUpLine.zpl__PriceLookup__c = priceLookups.get(0).Id;
        AIQts_TestFactory.createSObjectList(priceLookUpLine, 100, true);
    }

    private static List<Id> getPriceLookupIds() {
        Map<Id, zpl__PriceLookup__c> idPriceLookupMap = new Map<Id, zpl__PriceLookup__c>([
                SELECT Id
                FROM zpl__PriceLookup__c
        ]);
        List<Id> recordIds = new List<Id>();
        recordIds.addAll(idPriceLookupMap.keySet());
        return  recordIds;
    }

    private static List<zpl__PriceLookupLine__c> contrLines {
        get {
            List<zpl__PriceLookupLine__c> contrLines = [
                    SELECT Id, zpl__PriceLookup__c, zpl__Error__c, zpl__Price__c
                    FROM zpl__PriceLookupLine__c
                    LIMIT 50
            ];
            return contrLines;
        }
    }

    private static List<Id> contrIds {
        get {
            List<Id> contrIds = new List<Id>();
            for(zpl__PriceLookupLine__c contr : [
                    SELECT Id
                    FROM zpl__PriceLookupLine__c
                    LIMIT 50
            ]){
                contrIds.add(contr.Id);
            }
            return contrIds;
        }
    }


    @IsTest
    static void testEvaluateLinesByIdNegativeVoid(){

        Test.startTest();
        try{
            AIQco_FESClient.evaluateLinesVoid(new List<String>{}, 'f_', zpl__PriceLookupLine__c.getSobjectType());
            system.debug('Error - '+contrLines[0].zpl__Error__c);
        }catch(Exception e){
            system.assertEquals('AIQco_FESClient.AIQco_FESClientException', e.getTypeName());
        }

        Test.stopTest();
    }

    @IsTest
    static void testEvaluateLinesByIdPositiveVoid(){

        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new AIQts_MockAPIResponseGenerator(200, 'SUCCESS', '{}', new Map<String,String>{'Content-Type'=> 'application/json'}));
            AIQco_FESClient.evaluateLinesVoid(contrIds, configName, zpl__PriceLookupLine__c.getSobjectType());
            system.debug('Error - '+contrLines[0].zpl__Error__c);
        }catch(Exception e){
            system.assertEquals('AIQco_FESClient.AIQco_FESClientException', e.getTypeName());
        }

        Test.stopTest();
    }

    @IsTest
    static void testEvaluateLinesNegativeVoid(){

        Test.startTest();
        try{
            AIQco_FESClient.evaluateLinesVoid(new List<zpl__PriceLookupLine__c>{}, 'f_', zpl__PriceLookupLine__c.getSobjectType());
            system.debug('Error - '+contrLines[0].zpl__Error__c);
        }catch(Exception e){
            system.assertEquals('AIQco_FESClient.AIQco_FESClientException', e.getTypeName());
        }

        Test.stopTest();
    }

    @IsTest
    static void testEvaluateLinesPositiveVoid(){

        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new AIQts_MockAPIResponseGenerator(200, 'SUCCESS', '{}', new Map<String,String>{'Content-Type'=> 'application/json'}));
            AIQco_FESClient.evaluateLinesVoid(contrLines, configName, zpl__PriceLookupLine__c.getSobjectType());
            system.debug('Error - '+contrLines[0].zpl__Error__c);
        }catch(Exception e){
            system.assertEquals('AIQco_FESClient.AIQco_FESClientException', e.getTypeName());
        }

        Test.stopTest();
    }

    @IsTest
    static void testEvaluateLinesNegative(){

        Test.startTest();
        try{
            List<SObject> records = AIQco_FESClient.evaluateLines(new List<zpl__PriceLookupLine__c>{}, 'f_', zpl__PriceLookupLine__c.getSobjectType());
            system.debug('Error - '+contrLines[0].zpl__Error__c);
        }catch(Exception e){
            system.assertEquals('AIQco_FESClient.AIQco_FESClientException', e.getTypeName());
        }

        Test.stopTest();
    }

    @IsTest
    static void testEvaluateLinesPositive(){

        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new AIQts_MockAPIResponseGenerator(200, 'SUCCESS', '{}', new Map<String,String>{'Content-Type'=> 'application/json'}));
            List<SObject> records = AIQco_FESClient.evaluateLines(contrLines, configName, zpl__PriceLookupLine__c.getSobjectType());
            system.debug('Error - '+contrLines[0].zpl__Error__c);
        }catch(Exception e){
            system.assertEquals('AIQco_FESClient.AIQco_FESClientException', e.getTypeName());
        }

        Test.stopTest();
    }

}
@isTest
public with sharing class AIQsec_PermissionSetBatchProcessorTest {
    /*
	* This method prepares the test data of this class.
	*/
    @testSetup
    public static void prepareConfig(){
        AIQsec_TestSetup.setConfig();
    }
    
     private static User usr  {
        get {
            User usr = [
            SELECT Id, ProfileId, UserRoleId, isActive, Name, Username
            FROM User 
            WHERE Username = 'ztest@zilliant.com'][0];
            return usr ;
        } 
    }
    
    private static User usrError  {
        get {
            User usr = [
            SELECT Id, ProfileId, UserRoleId
            FROM User 
            WHERE Username = 'ztest@zilliant.com'][0];
            return usr ;
        } 
    }
    
    
    @isTest
    public static void testPermSetRecurringSch()
    {
        Test.startTest();
        AIQsec_PermissionSetBatchProSchedule.scheduleJob('0 0 7 1 * ? *', 200);
        CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name='AIQ Security - Permission Set Assignment Recurring Job - test job'];
        system.assertNotEquals(null, ct);
        Test.stopTest();
    }
    
    @isTest
    public static void testPermSetOneTimeSch()
    {
        Test.startTest();
        AIQsec_PermissionSetBatchProSchedule.scheduleJob(200);
        CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name='AIQ Security - Permission Set Assignment One Time Job - test job'];
        system.assertNotEquals(null, ct);
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false)
    public static void testPermissionSetBatchProcessorAll()
    {
        Test.startTest();
        AIQsec_PermissionSetBatchProcessor batchProcess = new AIQsec_PermissionSetBatchProcessor();
        batchProcess.getUsersForUpdateAll();
        
        Test.stopTest();
    }
    
    
    @isTest
    public static void testPermissionSetBatchProcessor()
    {
        Test.startTest();
        AIQsec_PermissionSetBatchProcessor batchProcess = new AIQsec_PermissionSetBatchProcessor(new List<User>{usr});
        ID batchProcId = Database.executeBatch(batchProcess);
        Test.stopTest();
    }
    /*
    @isTest
    public static void testPermissionSetBatchProcessorException()
    {
        Test.startTest();
        try{
            AIQsec_PermissionSetBatchProcessor batchProcess = new AIQsec_PermissionSetBatchProcessor(new List<User>{usrError});
        	ID batchProcId = Database.executeBatch(batchProcess);
        }catch(Exception e){
            system.assertEquals('AIQsec_PermissionSetBatchProcessor.AIQPermissionSetBatchProcessorException', e.getTypeName());
        }      
       
        Test.stopTest();
    }
	*/
}
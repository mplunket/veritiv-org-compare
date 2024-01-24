@IsTest
private class AIQasync_AbstractJobScheduleTest {
    
    @IsTest
    private static void testAbsatrctJobSchedule() {
        Test.startTest();
            AIQasync_AbstractJobSchedule schedule = new AIQasync_AbstractJobSchedule();
            System.schedule('TestAbstractSchedule', '0 0 2 * * ? *', schedule);
            CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'TestAbstractSchedule'];
            Assert.areNotEqual(null, ct, 'Should not be equal to null');
            schedule.execute(null);

            schedule.abortSchedule('TestAbstractSchedule');
            List<CronTrigger> ctList = new List<CronTrigger>([SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'TestAbstractSchedule']);
            Assert.areEqual(0, ctList.size(), 'Size should be equal to zero');
        Test.stopTest();
    }
    
    @IsTest
    private static void testAbsatrctJobScheduleAbort() {
        Test.startTest();
            AIQasync_AbstractJobSchedule schedule = new AIQasync_AbstractJobSchedule();
            System.schedule('TestAbstractSchedule1', '0 0 2 * * ? *', schedule);
            System.schedule('TestAbstractSchedule2', '0 0 3 * * ? *', schedule);
            CronTrigger ct1 = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'TestAbstractSchedule1'];
            Assert.areNotEqual(null, ct1, 'Should not be equal to null');

            schedule.abortSchedule('TestAbstractSchedule1');

            CronTrigger ct2 = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'TestAbstractSchedule2'];
            Assert.areNotEqual(null, ct2, 'Should not be equal to null');
        Test.stopTest();
    }
}
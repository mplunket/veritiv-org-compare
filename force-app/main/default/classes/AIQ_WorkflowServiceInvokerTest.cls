//package api.zCloud
@IsTest
private class AIQ_WorkflowServiceInvokerTest {

    @TestSetup
    private static void createZMicroServicesConfiguration() {
        zpf.DatabaseUtil.insertObjects(new zpf__ZMicroServicesConfiguration__c(zpf__ZMicroServicesHost__c = 'https://someHost'));
    }

    @IsTest
    private static void testHandleError() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(400);
        response.setStatus('');
        Test.startTest();
        try {
            new AIQ_WorkflowServiceInvoker().handleError(response, '');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Error message is not null');
        }
        Test.stopTest();
    }

    @IsTest
    private static void testHandleErrorJobRunning() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(400);
        response.setBody('job is running');
        Test.startTest();
        try {
            new AIQ_WorkflowServiceInvoker().handleError(response, '');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Error message is not null');
        }
        Test.stopTest();
    }

    @IsTest
    private static void testSubmitJobError() {
        Test.startTest();
        try {
            Test.setMock(
                HttpCalloutMock.class,
                new AIQts_MockAPIResponseGenerator(
                    200,
                    'SUCCESS',
                    '{}',
                    new Map<String, String>{ 'Content-Type' => 'application/json' }
                )
            );
            String response = new AIQ_WorkflowServiceInvoker().submitJob('testContract', 'testProduct');
        } catch (Exception e) {
            System.assertEquals('Argument 2 cannot be null', e.getMessage(), 'Wrong error message');
        }
        Test.stopTest();
    }

    @IsTest
    private static void testCheckJobStatusErrorJobNotProvided() {
        Test.startTest();
        try {
            new AIQ_WorkflowServiceInvoker().checkJobStatus('');
        } catch (Exception e) {
            System.assertEquals('Job id is not provided', e.getMessage(), 'Wrong error message');
        }
        Test.stopTest();
    }

    @IsTest
    private static void testCheckJobStatusErrorServerNameNotFound() {
        Test.startTest();
        try {
            Test.setMock(
                HttpCalloutMock.class,
                new AIQts_MockAPIResponseGenerator(
                    200,
                    'SUCCESS',
                    '{}',
                    new Map<String, String>{ 'Content-Type' => 'application/json' }
                )
            );
            new AIQ_WorkflowServiceInvoker().checkJobStatus('1111');
        } catch (Exception e) {
            System.assertEquals('Argument 2 cannot be null', e.getMessage(), 'Wrong error message');
        }
        Test.stopTest();
    }

    @IsTest
    private static void testResponseBodyDTO() {
        AIQ_WorkflowServiceInvoker.ResponseBodyDTO responseBodyDTO = new AIQ_WorkflowServiceInvoker.ResponseBodyDTO();
        responseBodyDTO.closeStatus = 'testStatus';
        responseBodyDTO.closeTimestamp = 'testTimestamp';
        responseBodyDTO.executionStatus = 'testExecutionStatus';
        responseBodyDTO.startTimestamp = 'testStartTimestamp';

        System.assertEquals('testStatus', responseBodyDTO.closeStatus, 'ResponseBodyDTO data set not correct');
    }

    @IsTest
    private static void testGetBaseURL() {
        AIQ_WorkflowServiceInvoker invoker = new AIQ_WorkflowServiceInvoker();

        String expectedBaseUrl = '/v1/JobWorkflow';

        Test.startTest();
        String actualBaseUrl = invoker.getBaseURL();
        Test.stopTest();

        System.assertEquals(expectedBaseUrl, actualBaseUrl, 'URL should match');
    }

}
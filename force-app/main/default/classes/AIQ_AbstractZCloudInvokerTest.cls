@IsTest
private class AIQ_AbstractZCloudInvokerTest {
    private static final String TEST_URL = 'https://test.com';
    private static final String TEST_RESPONSE_BODY = 'test response body';
    private static final String TEST_MICRO_SERVER_NAME = 'zpf__ZMicroServicesHost__c';
    private static final String TEST_FORWARDED_HOST_NAME = 'aiq_XForwardedHost__c';

    @IsTest
    private static void testGetEndpoint() {
        setConfigs();
        AIQ_AbstractZCloudInvoker invoker = new ServiceInvoker();
        Test.startTest();
            String actualBaseUrl = invoker.getEndpoint();
        Test.stopTest();

        System.assertEquals(actualBaseUrl, TEST_MICRO_SERVER_NAME + TEST_URL, 'URL should match');
    }

    @IsTest
    private static void testGetHeaders() {
        setConfigs();
        Test.setMock(HttpCalloutMock.class, new HttpResponseMock());
        Test.startTest();
            AIQ_AbstractZCloudInvoker invoker = new ServiceInvoker();
            invoker.authorize(new AIQio_HttpRequestBuilder('POST', TEST_URL));
            Map<String, String> headersMap = invoker.getHeaders();
        Test.stopTest();
        System.assertEquals('application/json', headersMap.get('Content-Type'), 'The header map should be configured correctly');
    }

    public class HttpResponseMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(TEST_RESPONSE_BODY);
            res.setStatusCode(AIQio_HTTPUtils.SUCCESS_STATUS_CODE);
            return res;
        }
    }

    private class ServiceInvoker extends AIQ_AbstractZCloudInvoker {
        public override String getBaseURL() {
            return TEST_URL;
        }

        protected override void handleError(HttpResponse res, String method) {
            System.assert(false, 'Should not have been called');
        }
    }

    private static void setConfigs() {
        zpf__ZMicroServicesConfiguration__c servicesConfiguration = new zpf__ZMicroServicesConfiguration__c();
        servicesConfiguration.zpf__ZMicroServicesHost__c = TEST_MICRO_SERVER_NAME;
        insert servicesConfiguration;
    }
}
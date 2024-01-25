//package api.zCloud
public abstract with sharing class AIQ_AbstractZCloudInvoker extends AIQio_RetryableServiceInvoker {
    private class AIQ_AbstractZCloudInvokerException extends Exception {}

    private final static String SERVER_NAME = (String) zpf__ZMicroServicesConfiguration__c.getInstance().get('zpf__ZMicroServicesHost__c');
    private final static String ENVIRONMENT_ID_KEY = 'zilliant-tenant-environment-id';
    private final static String ENVIRONMENT_ID_VALUE = (String) AIQZilliantConfiguration__c.getInstance().get('aiq_EnvironmentId__c');
    private final static String HTTP_PREFIX = 'https://';
    private final static Integer PREFIX_LENGTH = HTTP_PREFIX.length();
    private final static String FORWARDED_HOST = SERVER_NAME != null ? SERVER_NAME.substring(PREFIX_LENGTH) : null;

    public abstract String getBaseURL();

    @TestVisible
    protected override void authorize(AIQio_HttpRequestBuilder httpBuilder) {
        HttpRequest req = new HttpRequest(); req.setEndpoint('callout:ZIQA_Creds');
        req.setMethod('POST');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        httpBuilder.setHeader(AIQio_HTTPUtils.AUTHORIZATION, 'OAuth ' + EncodingUtil.base64Encode(Blob.valueOf(res.getBody()))); 
    }

    @TestVisible
    protected override Map<String, String> getHeaders() {
        Map<String, String> headers = new Map<String, String>();
        headers.put(AIQio_HTTPUtils.X_FORWARDED_HOST, FORWARDED_HOST);
        headers.put(AIQio_HTTPUtils.CONTENT_TYPE, AIQio_HTTPUtils.APPLICATION_JSON);
        headers.put(ENVIRONMENT_ID_KEY, ENVIRONMENT_ID_VALUE);

        return headers;
    }

    @TestVisible
    protected override String getEndpoint() {
        if (String.isBlank(SERVER_NAME)) {
            throw new AIQ_AbstractZCloudInvokerException('Server name not found');
        }

        return SERVER_NAME + getBaseURL();
    }
}
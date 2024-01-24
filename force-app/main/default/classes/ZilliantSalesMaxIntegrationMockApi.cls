@isTest
public class ZilliantSalesMaxIntegrationMockApi implements HttpCalloutMock {

    public static final String TEST_BATCH_ID = 'Test Id';
    public static final String TEST_ZILLIANT_URL = 'test.zilliant.com';
    public static final String INSERT_ENDPOINT = TEST_ZILLIANT_URL + 
                                  '?type=' + ZilliantSalesMaxIntegrationServices.OPPORTUNITY_ACTIVITY_RESOURCE_TYPE + 
                                  '&operation=' + ZilliantSalesMaxIntegrationServices.INSERT_OPERATION_TYPE;

    public static String STATUS_ENDPOINT
    {
        get
        {
            return ZilliantSalesMaxIntegrationServices.ZILLIANT_BASE_REQUEST_URL
                                + '/' + TEST_BATCH_ID + '/' + ZilliantSalesMaxIntegrationServices.STATUS_ENDPOINT;
        }
        set;
    }

    public Integer code;
    public String body;
    public HttpRequest request;
    public Boolean throwException = false;

    public ZilliantSalesMaxIntegrationMockApi()
    {

    }

    public HTTPResponse respond(HTTPRequest req)
    {
        this.request = req;
        
        if(throwException)
        {
            CalloutException ex = (CalloutException) CalloutException.class.newInstance();
            ex.setMessage('Test callout exception');
            throw ex;
        }

        else
        {
            if(String.isBlank(this.body) && this.code == NULL)
            {
                if(req.getEndpoint() == ZilliantSalesMaxIntegrationServices.AUTH_URL)
                {
                    this.body = buildAuthorizationResponse();
                    this.code = ZilliantSalesMaxIntegrationServices.SF_RESPONSE_STATUS_OK;
                }

                else if(req.getEndpoint() == INSERT_ENDPOINT)
                {
                    this.body = buildJobRequestResponse();
                    this.code = ZilliantSalesMaxIntegrationServices.ZIL_RESPONSE_STATUS_OK;
                }

                else if(req.getEndpoint() == STATUS_ENDPOINT)
                {
                    this.body = buildStatusRequestResponse();
                    this.code = ZilliantSalesMaxIntegrationServices.ZIL_RESPONSE_STATUS_OK;
                }
            }

            System.debug('###Response body: ' + this.body);
            System.debug(STATUS_ENDPOINT);

            HttpResponse res = new HttpResponse();
            res.setBody(this.body);
            res.setStatusCode(this.code);

            this.body = null;
            this.code = null;

            return res;
        }

    }

    private String buildAuthorizationResponse()
    {
        String testBody = '{';
        testBody        +=     '"access_token" : "Test Access Token",';
        testBody        +=     '"instance_url" : "http://test.testinstanceurl.com",';
        testBody        +=     '"id" : "test.salesforce.com/testid",';
        testBody        +=     '"token_type" : "Bearer",';
        testBody        +=     '"issued_at" : "1970-01-01",';
        testBody        +=     '"signature" : "Test Access Signature"';
        testBody        += '}';

        return testBody;
    }

    private String buildJobRequestResponse()
    {
        String testBody  = '{';
        testBody        +=     '"bulkDataJobId": "' + TEST_BATCH_ID + '",';
        testBody        +=     '"status": "Submitted"';
        testBody        += '}';

        return testBody;
    }

    private String buildStatusRequestResponse()
    {

        String testBody  = '{';
        testBody        +=     '"Status": "' + ZilliantSalesMaxIntegrationServices.BATCH_STATUS_COMPLETED + '"';
        testBody        += '}';

        return testBody;
    }

}
@isTest
public class AIQMockOAuthToken implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ '
                    +'"access_token":"test_token",'
                    +'"instance_url":"https://testURL.com",'
                    +'"id":"0000",'
                    +'"token_type":"test",'
                    +'"issued_at":"000000000000",'
                    +'"signature":"test_signature"'
                    +'}');
        res.setStatusCode(200);
        return res;      
    }
}
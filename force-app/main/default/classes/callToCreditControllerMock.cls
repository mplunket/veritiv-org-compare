@isTest
global class callToCreditControllerMock implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {

        // Create a fake response
        String username = 'soauser';
        String password = 'soapassword';
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        String authValue = username + ':' + password;
        Blob headerValue = Blob.valueOf(username +':'+password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        response.setHeader('Authorization',authorizationHeader);
        response.setHeader('Content-Type','text/xml');
        response.setBody('<?xml version="1.0"?><Response><OutputParameters><CODE>1</CODE><MESSAGE>New Customer</MESSAGE><BILLTOID/><PARTYID/></OutputParameters></Response>');
        response.setStatusCode(200);
        return response;      
    }
}
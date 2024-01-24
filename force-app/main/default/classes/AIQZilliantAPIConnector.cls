public class AIQZilliantAPIConnector
{
    // private static variable referencing the class
    private static AIQZilliantAPIConnector instance = null;
    private static String FORMULA_EVAL_URL = 
        zpf__ZMicroServicesConfiguration__c.getInstance().get('zpf__ZMicroServicesHost__c')!=null 
        ? zpf__ZMicroServicesConfiguration__c.getInstance().get('zpf__ZMicroServicesHost__c')+'/v1/FormulaEvaluation/' : '';
    // contains the header to add in API calls
    public String authorizationHeader { get; private set; }
    
    // The constructor is private and initializes the id of the record type
    private AIQZilliantAPIConnector()
    {
        // get the header
        authorizationHeader = getAuthorizationHeader();
    }
    
    // a static method that returns the instance of the record type
    public static AIQZilliantAPIConnector getInstance()
    {
        // lazy load the record type - only initialize if it doesn't already exist
        if (instance == null) instance = new AIQZilliantAPIConnector();
        return instance;
    }
    
    public String getAuthorizationHeader()
    {        
		HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ZIQA_Creds');
        req.setMethod('POST');
        Http http = new Http();
        HTTPResponse res = http.send(req);        
        
        // encode the response ... we have the authorization key to use for API calls        
        return 'OAuth ' + EncodingUtil.base64Encode(Blob.valueOf(res.getBody()));
    }
    
    public static String evaluateFormulas(String formula, String queryParms, String reqBody) {
        // lazy load the record type - only initialize if it doesn't already exist
        if (instance == null) instance = new AIQZilliantAPIConnector();
        String result; 
        if (instance != null) {
            String url = FORMULA_EVAL_URL + (queryParms != null ? formula : '');
            if (queryParms != null) {
                url += '?' + queryParms;
            }
            // make the API call
            Long startTime = DateTime.now().getTime();
            
            Integer responseCode;
            try {
                HttpResponse res = new HttpResponse();
                
                system.debug('url: ' + url);
                system.debug('req body: ' + reqBody);
                
                if(reqBody!=null){
                    res = instance.callAPIout(url, reqBody);
                } else{
                    res = instance.callAPIout(url);
                }
                system.debug('orig res: ' + res.getBody());
                responseCode = res.getStatusCode();
                if(responseCode==200)
                {
                    result = JSON.serializePretty(res.getBody());
                } else
                {
                    result = JSON.serializePretty('{"Status": ["'+res.getStatus()+'"], "StatusCode": ["'+ responseCode +'"]}');
                }
            } catch (Exception e) 
            {
                result = JSON.serializePretty('{"Error": ["'+e.getMessage()+'"], "StackTraceString": ["'+ e.getStackTraceString() +'"]}');
            }
            
            //if (result.length() > 90000) {result = result.substring(0, 90000) + ' ...';}
            result = result.replace('\\', '').replace('"{', '{').replace('}"', '}');
        }
        system.debug(result);
        return result;
    }
    
    public HttpResponse callAPIout (String url)
    {
        // build the request
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('GET');
        req.setTimeout(120000);
        req.setEndpoint(url);
        // send the request and grab the Location header with the trusted ticket URL
        HTTPResponse res = new Http().send(req);
        system.debug('initiated GET request');
        return res;
    }
    
    public HttpResponse callAPIout (String url, String body)
    {
        // build the request
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setEndpoint(url);
        req.setBody(body);
        // send the request and grab the Location header with the trusted ticket URL
        HTTPResponse res = new Http().send(req);
        system.debug('initiated POST request');
        return res;
    }
    
}
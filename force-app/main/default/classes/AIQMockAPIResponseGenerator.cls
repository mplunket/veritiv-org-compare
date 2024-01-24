@isTest
public class AIQMockAPIResponseGenerator implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String url = req.getEndpoint();
        
        if(req.getMethod()=='GET' && url.subString(url.indexOf('?')).length()>1)
        {        
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ '
                        +'"f_getDiscount":["0"],'
                        +'"f_getFloorPrice":["0"],'
                        +'"f_getFutureDevCost":["0"],'
                        +'"f_getFuturePricingCost":["0"],'
                        +'"f_getMargin":["0"],'
                        +'"f_getMarkup":["0"],'
                        +'"f_getNetPrice":["0"],'
                        +'"f_getPolicyValue":["0"],'
                        +'"f_getPricingCost":["0"],'
                        +'"f_getRebateAmount":["0"],'
                        +'"f_getRecOptSegID":["0000"],'
                        +'"f_getStartPrice":["0"],'
                        +'"f_getSystemStdUnitCost":["0"],'
                        +'"f_getTargetPrice":["0"],'
                        +'"f_getRecOptSegID":["SEGMENTID"],'
                        +'"f_getNVStart":["1.3"],'
                        +'"f_getNVTarget":["1.2"],'
                        +'"f_getNVFloor":["1.1"]'                        
                        +'}');
            res.setStatusCode(200);
        } else if(req.getMethod()=='POST'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ '
                        + '"outputResults": ['
                        +'{'
                        +'"ZSecretLineId" : ["1"],'
                        +'"f_getDiscount":["0"],'
                        +'"f_getFloorPrice":["0"],'
                        +'"f_getFutureDevCost":["0"],'
                        +'"f_getFuturePricingCost":["0"],'
                        +'"f_getMargin":["0"],'
                        +'"f_getMarkup":["0"],'
                        +'"f_getNetPrice":["0"],'
                        +'"f_getPolicyValue":["0"],'
                        +'"f_getPricingCost":["0"],'
                        +'"f_getRebateAmount":["0"],'
                        +'"f_getRecOptSegID":["0000"],'
                        +'"f_getStartPrice":["0"],'
                        +'"f_getSystemStdUnitCost":["0"],'
                        +'"f_getTargetPrice":["0"],'
                        +'"f_getRecOptSegID":["SEGMENTID"],'
                        +'"f_getNVStart":["1.3"],'
                        +'"f_getNVTarget":["1.2"],'
                        +'"f_getNVFloor":["1.1"]' 
                        +'},'
                        +'{'
                        +'"ZSecretLineId" : ["2"],'
                        +'"f_getDiscount":["0"],'
                        +'"f_getFloorPrice":["0"],'
                        +'"f_getFutureDevCost":["0"],'
                        +'"f_getFuturePricingCost":["0"],'
                        +'"f_getMargin":["0"],'
                        +'"f_getMarkup":["0"],'
                        +'"f_getNetPrice":["0"],'
                        +'"f_getPolicyValue":["0"],'
                        +'"f_getPricingCost":["0"],'
                        +'"f_getRebateAmount":["0"],'
                        +'"f_getRecOptSegID":["0000"],'
                        +'"f_getStartPrice":["0"],'
                        +'"f_getSystemStdUnitCost":["0"],'
                        +'"f_getTargetPrice":["0"],'
                        +'"f_getRecOptSegID":["SEGMENTID"],'
                        +'"f_getNVStart":["1.3"],'
                        +'"f_getNVTarget":["1.2"],'
                        +'"f_getNVFloor":["1.1"]'
                        +'},'
                        +'{'
                        +'"ZSecretLineId" : ["3"],'
                       +'"f_getDiscount":["0"],'
                        +'"f_getFloorPrice":["0"],'
                        +'"f_getFutureDevCost":["0"],'
                        +'"f_getFuturePricingCost":["0"],'
                        +'"f_getMargin":["0"],'
                        +'"f_getMarkup":["0"],'
                        +'"f_getNetPrice":["0"],'
                        +'"f_getPolicyValue":["0"],'
                        +'"f_getPricingCost":["0"],'
                        +'"f_getRebateAmount":["0"],'
                        +'"f_getRecOptSegID":["0000"],'
                        +'"f_getStartPrice":["0"],'
                        +'"f_getSystemStdUnitCost":["0"],'
                        +'"f_getTargetPrice":["0"],'
                        +'"f_getRecOptSegID":["SEGMENTID"],'
                        +'"f_getNVStart":["1.3"],'
                        +'"f_getNVTarget":["1.2"],'
                        +'"f_getNVFloor":["1.1"]' 
                        +'}'
                        +']'
                        +'}');
            res.setStatusCode(200);
        } else if (req.getMethod()=='GET' && url.subString(url.indexOf('?')).length() == 1)
        {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ '
                        +'"Error":"Bad request",'
                        +'}');
            res.setStatusCode(400);
        } else if (req.getMethod()=='GET' && url.contains('?') == false)
        {
            throw new System.CalloutException();
        }
        
        return res;      
    }
}
public class VIQOppurtunityVisualizationsController {
    private final Opportunity opp; 

    // The extension constructor initializes the private member 
    // variable acct by using the getRecord method from the standard 
    // controller. 
    public VIQOppurtunityVisualizationsController(ApexPages.StandardController stdController) { 
        Id oppId = ((Opportunity)stdController.getRecord()).Id;
        List<Opportunity> opps = [ SELECT viq_insight_key__c, name FROM Opportunity WHERE Id = :oppId LIMIT 1];
        if (opps.size() > 0)
           this.opp = opps.get(0);
    } 
    
   	public String getSalesIqVisualizations() {
        HttpRequest req = new HttpRequest();
        String URL = 'https://veritiv.zilliant.com/salesmax/CustomerInsight/v1/'+opp.viq_insight_key__c+'/visualizations';
        req.setEndpoint(URL); 
        req.setMethod('GET');
        String authorizationHeader = 'OAuth ' + ZilliantSalesMaxIntegrationServices.getSalesMaxAuthorizationString();
        req.setHeader('Authorization', authorizationHeader);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getBody();
    }
}
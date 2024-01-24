public class VIQIntegratedAnalyticsDashboard {
    private User user;
    
    public String dashboardEmbeddedUrl { get; private set; }
        
    public VIQIntegratedAnalyticsDashboard(ApexPages.StandardController controller) {}

    public VIQIntegratedAnalyticsDashboard(){}
    
    public User getUser() { return user; }
    
    public PageReference getDashboardUrl() {
		Id userId = UserInfo.getUserId();
		List<User> users = [SELECT Id, Name, Title, Network_Id__c, ProfileId FROM User WHERE Id =: userId LIMIT 1];
		//List<User> users = [SELECT Id, Name, Title, Network_Id__c, ProfileId FROM User WHERE Name =: 'Tory Cruse' LIMIT 1];
		//List<User> users = [SELECT Id, Name, Title, Network_Id__c, ProfileId FROM User WHERE Network_Id__c =: 'BCONNER' LIMIT 1];
		if(users.size() > 0){
			user = users.get(0);
		}
        System.debug(user);
        
        HttpRequest req = new HttpRequest();
        String URL = 'https://veritiv.zilliant.com/platform/Report/v1/Veritiv_SalesMax_Opportunity_Management/OverviewDashboard_1';
        req.setEndpoint(URL); 
        req.setMethod('GET');
        String authorizationHeader = 'OAuth ' + ZilliantSalesMaxIntegrationServices.getSalesMaxAuthorizationString();
        req.setHeader('Authorization', authorizationHeader);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String redirectUrl = res.getHeader('Location');
        dashboardEmbeddedUrl = redirectUrl + '&managerNetworkId=' + user.Network_Id__c + '&:tabs=yes&:toolbar=no&:customViews=no';
        System.debug('dashboardEmbeddedUrl:'+dashboardEmbeddedUrl);
        return null; 
    }
}
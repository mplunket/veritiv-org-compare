public class HomePageLinksController {
	@AuraEnabled
    public static HomePageLink__c getHomePageLinks(String name) {
        List<HomePageLink__c> homePageLinks = [SELECT Component_Rich_Text__c, Component_Title__c FROM HomePageLink__c WHERE Name = :name LIMIT 1];
        if (homePageLinks.size() > 0) {
            return homePageLinks[0];   
        }

        return null;
    }
}
public class DnBLeadSyncQuickActionController {

    @AuraEnabled
    public static Lead getLead(String id) {
        return [SELECT Id, Company, Phone, Website, Street, City, 
                State, PostalCode, Country FROM Lead WHERE Id =: id];
    }
    
    @AuraEnabled
    public static String getMatches(Lead lead) {
        try {
            return DnBLeadIdentityResolutionAPIService.dnbIdentityResolutionCallout(lead);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static void syncLeadWithDnB(String leadId, String duns, Integer confidenceCode) {
        try {
            DnBLeadCompanyProfileAPIService.dnbCompanyProfileCallout(leadId, duns, confidenceCode);   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getUITheme() {
        return UserInfo.getUiThemeDisplayed();
    }
}
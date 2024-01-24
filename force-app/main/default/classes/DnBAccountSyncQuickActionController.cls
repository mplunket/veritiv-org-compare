public class DnBAccountSyncQuickActionController {

    @AuraEnabled
    public static Account getAccount(String id) {
        return [SELECT Id, Name, Phone, Website, BillingStreet, BillingCity, 
                BillingState, BillingPostalCode, BillingCountry FROM Account WHERE Id =: id];
    }
    
    @AuraEnabled
    public static String getMatches(Account acc) {
        try {
            return DnBAccountIdentityResolutionAPIService.dnbIdentityResolutionCallout(acc);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static void syncAccountWithDnB(String accountId, String duns, Integer confidenceCode, string accName) {
        system.debug('testtest'+ accountId+'-' +duns+'-' + confidenceCode); 
        try {
            DnBAccountCompanyProfileAPIService.dnbCompanyProfileCallout(accountId, duns, confidenceCode, accName);  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
      
    }

    @AuraEnabled
    public static String getUITheme() {
        return UserInfo.getUiThemeDisplayed();
    }
}
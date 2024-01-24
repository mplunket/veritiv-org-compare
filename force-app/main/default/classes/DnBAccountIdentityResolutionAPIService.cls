public class DnBAccountIdentityResolutionAPIService {
    private static DnB_API_Settings__c dnbAPISettings {
        get {
            if (dnbAPISettings == null) {
                dnbAPISettings = DnB_API_Settings__c.getOrgDefaults();
            }
            return dnbAPISettings;
        }
        set;
    }

    public static String dnbIdentityResolutionCallout(Account acc) {        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(dnbAPISettings.Identity_Resolution_URL__c + '?' + buildIdentityResolutionURLParams(acc));
        request.setMethod('GET');
        request.setHeader('accept', 'application/json');
        request.setHeader('authorization', 'Bearer ' + dnbAPISettings.DnB_API_Token__c);
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() != 200) {
            Map<String, Object> errorResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> error = (Map<String, Object>)errorResponse.get('error');

            String errorCode = (String)error.get('errorCode');
            String rawErrorMessage = (String)error.get('errorMessage');
            String labelErrorMessage;

            if (errorCode == '00040') {
                labelErrorMessage = Label.DnB_API_Error_00040;
            } else if (errorCode == '20502') {
                labelErrorMessage = Label.DnB_API_Error_20502;
            } else if (errorCode == '20504') {
                labelErrorMessage = Label.DnB_API_Error_20504;
            } else if (errorCode == '20505') {
                labelErrorMessage = Label.DnB_API_Error_20505;
            }
            
            if (labelErrorMessage != null) {
                throw new CalloutException(labelErrorMessage);
            } else {
                throw new CalloutException(errorCode + ': ' + rawErrorMessage);   
            }
        }
        
        return response.getBody();
    }
    
    @TestVisible
    private static String buildIdentityResolutionURLParams(Account acc) {
        List<String> parameters = new List<String>();
        
        parameters.add('name=' + EncodingUtil.urlEncode(acc.Name, 'UTF-8'));
        parameters.add('confidenceLowerLevelThresholdValue=' + Integer.valueOf(dnbAPISettings.Account_Minimum_Confidence_Code__c));
        
        if (acc.Website != null) {
            parameters.add('url=' + EncodingUtil.urlEncode(acc.Website, 'UTF-8'));
        }
        
        if (acc.Phone != null) {
            parameters.add('telephoneNumber=' + EncodingUtil.urlEncode(acc.Phone, 'UTF-8'));
        }
        
        if (acc.BillingStreet != null) {
            parameters.add('streetAddressLine1=' + EncodingUtil.urlEncode(acc.BillingStreet, 'UTF-8'));
        }
        
        if (acc.BillingCity != null) {
            parameters.add('addressLocality=' + EncodingUtil.urlEncode(acc.BillingCity, 'UTF-8'));
        }
        
        if (acc.BillingState != null) {
            parameters.add('addressRegion=' + EncodingUtil.urlEncode(acc.BillingState, 'UTF-8'));
        }
        
        if (acc.BillingPostalCode != null) {
            parameters.add('postalCode=' + EncodingUtil.urlEncode(acc.BillingPostalCode, 'UTF-8'));
        }
        
        if (acc.BillingCountry != null) {
            parameters.add('countryISOAlpha2Code=' + EncodingUtil.urlEncode(acc.BillingCountry, 'UTF-8'));
        }
        
        return String.join(parameters, '&');
    }
}
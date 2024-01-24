public class DnBLeadIdentityResolutionAPIService {
    private static DnB_API_Settings__c dnbAPISettings {
        get {
            if (dnbAPISettings == null) {
                dnbAPISettings = DnB_API_Settings__c.getOrgDefaults();
            }
            return dnbAPISettings;
        }
        set;
    }

    public static String dnbIdentityResolutionCallout(Lead lead) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(dnbAPISettings.Identity_Resolution_URL__c + '?' + buildIdentityResolutionURLParams(lead));
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
    private static String buildIdentityResolutionURLParams(Lead lead) {
        List<String> parameters = new List<String>();
        
        parameters.add('name=' + EncodingUtil.urlEncode(lead.Company, 'UTF-8'));
        parameters.add('confidenceLowerLevelThresholdValue=' + Integer.valueOf(dnbAPISettings.Lead_Minimum_Confidence_Code__c));
        
        if (lead.Website != null) {
            parameters.add('url=' + EncodingUtil.urlEncode(lead.Website, 'UTF-8'));
        }
        
        if (lead.Phone != null) {
            parameters.add('telephoneNumber=' + EncodingUtil.urlEncode(lead.Phone, 'UTF-8'));
        }
        
        if (lead.Street != null) {
            parameters.add('streetAddressLine1=' + EncodingUtil.urlEncode(lead.Street, 'UTF-8'));
        }
        
        if (lead.City != null) {
            parameters.add('addressLocality=' + EncodingUtil.urlEncode(lead.City, 'UTF-8'));
        }
        
        if (lead.State != null) {
            parameters.add('addressRegion=' + EncodingUtil.urlEncode(lead.State, 'UTF-8'));
        }
        
        if (lead.PostalCode != null) {
            parameters.add('postalCode=' + EncodingUtil.urlEncode(lead.PostalCode, 'UTF-8'));
        }
        
        if (lead.Country != null) {
            parameters.add('countryISOAlpha2Code=' + EncodingUtil.urlEncode(lead.Country, 'UTF-8'));
        }
        
        return String.join(parameters, '&');
    }
}
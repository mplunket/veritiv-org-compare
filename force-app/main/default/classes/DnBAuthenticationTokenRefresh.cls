global class DnBAuthenticationTokenRefresh implements Schedulable {
	public class DnBTokenRefreshJob implements Queueable, Database.AllowsCallouts {
		public void execute(QueueableContext qc) {
			try {
				DnB_API_Settings__c dnbSettings = DnB_API_Settings__c.getOrgDefaults();

				HttpRequest request = new HttpRequest();
				request.setEndpoint(dnbSettings.AUthentication_URL__c);

				request.setMethod('POST');
				request.setHeader('Content-Type', 'application/json');
				request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(dnbSettings.Consumer_Key__c + ':' + dnbSettings.Consumer_Secret__c)));

				request.setBody('{ "grant_type": "client_credentials" }');

				Http http = new Http();
				HttpResponse response = http.send(request);

				if (response.getStatusCode() != 200) {
					System.debug('Error in authentication callout. Returned status ' + response.getStatusCode() + ' with message: ' + response.getStatus());
					CalloutException ex = new CalloutException(response.getBody());
					throw ex;
				}
				
				Map<String, String> responseBody = (Map<String, String>) System.JSON.deserialize(response.getBody(), Map<String, String>.class);

				dnbSettings.DnB_API_Token__c = responseBody.get('access_token');
				dnbSettings.DnB_API_Token_Expiration__c = System.now().addSeconds(Integer.valueOf(responseBody.get('expiresIn')));

				update dnbSettings;
			} catch (Exception e) {
				// Do something to notify of failure.
				System.debug('Error while generating new D&B Token: ' + e.getMessage());
			}
		}
	}

	global void execute(SchedulableContext sc) {
		System.enqueueJob(new DnBTokenRefreshJob());
	}
}
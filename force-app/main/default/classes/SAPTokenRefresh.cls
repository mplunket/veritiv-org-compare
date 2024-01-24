global class SAPTokenRefresh implements Schedulable {

    public class RefreshJob implements Queueable, Database.AllowsCallouts {
		private final Integer MAX_ENCODED_TOKEN_LENGTH = 255;
        
        @TestVisible
        private List<String> emailsForErrors {
            get {
                if(emailsForErrors == null) {

                    emailsForErrors = new List<String>();

                    Map<String, List<SObject>> userIdToSettings = GroupBy.strings('User_ID__c', 
                        Apex_Class_Error_Emails__c.getAll().values());

                    Set<String> userIds = userIdToSettings.keySet();

                    Map<String, List<SObject>> emailToUserMap = GroupBy.strings('Email', 
                        [SELECT Email FROM User WHERE Id IN :userIds]);
                    emailsForErrors.addAll(emailToUserMap.keySet());
                }
                return emailsForErrors;
            } set;
        }

        public void execute(QueueableContext context) {
            try {
                SAP_BI_Reports_Setting__c sapSettings = SAP_BI_Reports_Setting__c.getOrgDefaults();
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint(sapSettings.Login_URL__c);
                req.setHeader('Accept', 'application/json');
                req.setHeader('Content-Type', 'application/json');
                req.setTimeout(12000);

                String body = '{';
                body        += '"userName":"' + sapSettings.Username__c + '",';
                body        += '"password":"' + sapSettings.Password__c + '",';
                body        += '"auth":"' + sapSettings.Auth__c + '"';
                body        += '}';

                req.setBody(body);
                HttpResponse res = (new Http()).send(req);

                if(res.getStatusCode() != 200) {
                    CalloutException ex = new CalloutException(res.getBody());
                    throw ex;
                }

                Map<String, String> resMap = (Map<String, String>) JSON.deserialize(res.getBody(), Map<String, String>.class);
                String token = resMap.get('logonToken');
                sapSettings.SAP_Login_Token__c = token;
                
                String encodedToken = EncodingUtil.urlEncode(token, 'UTF-8');
                if (encodedToken.length() > MAX_ENCODED_TOKEN_LENGTH) {
                    sapSettings.Encoded_Token__c = encodedToken.substring(0, MAX_ENCODED_TOKEN_LENGTH);
                    sapSettings.Encoded_Token_Overflow__c = encodedToken.substring(MAX_ENCODED_TOKEN_LENGTH);
                } else {
                    sapSettings.Encoded_Token__c = encodedToken;
                    sapSettings.Encoded_Token_Overflow__c = '';
                }
                
                sapSettings.SAP_Login_Token_Last_Update__c = DateTime.now();

                update sapSettings;
            }
            catch(Exception ex) {
                Messaging.SingleEmailMessage errorEmail = new Messaging.SingleEmailMessage();
                errorEmail.setToAddresses(emailsForErrors);
                errorEmail.setSubject('SAP Token Refresh Error');
                errorEmail.setHtmlBody('An error has occurred while refreshing SAP Token<br />'
                    + ex.getMessage() + '<br />' + ex.getStackTraceString());
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{errorEmail});
            }
        }
    }

    global void execute(SchedulableContext sc) {
        System.enqueueJob(new RefreshJob());
    }
}
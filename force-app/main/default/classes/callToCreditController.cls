public class callToCreditController {
    
    @AuraEnabled
    public static Account getAccount(Id accountId) {
        // Perform isAccessible() checks here
        return [SELECT Id,Name,Legacy_System_Cd__c,Servicing_Division__r.System_Code__c,Legacy_Division_Cd__c,
                Parent_Duns_Number__c,Domestic_Ultimate_Duns_Number__c,Global_Ultimate_Duns_Number__c,Servicing_Division__r.Division_Composite_key__c,
                Servicing_Division__c,Sales_Rep_Code__c,D_U_N_S__c, recordTypeId, Credit_Action_for_Setup__c, Credit_Submitted_Date__c,owner.Employee_ID__c FROM Account WHERE Id = :accountId];
    }
    
    public static Servicing_Division__c getServicing(Id servId) {
        // Perform isAccessible() checks here
        return [SELECT Id,System_Code__c,Division_Composite_key__c FROM Servicing_Division__c WHERE Id = :servId];
    }
    
    @AuraEnabled
    public static void callOut(string accId, string servicingid, string sRepCode, Boolean equipmentAcc, String prospectSegment) {
        
        Credit_Application_Credential__c caCredential = Credit_Application_Credential__c.getOrgDefaults();
        system.debug(caCredential);
        system.debug(caCredential.Oracle_AR_Endpoint__c);
        String username = 'soauser';
        String password = 'soapassword';
        String endpoint = 'https://esbwebtst.veritivcorp.com/SFDC/AR';
        if(caCredential != null){
            if(caCredential.Username__c != null){
                username = caCredential.Username__c;
            }
            
            if(caCredential.Password__c != null){
                password = caCredential.Password__c;
            }
            
            if(caCredential.Oracle_AR_Endpoint__c != null){
                endpoint = caCredential.Oracle_AR_Endpoint__c;
            }
        }
        
        account acc = getAccount(accId);
        Servicing_Division__c servDivision = getServicing(servicingid);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String authValue = username + ':' + password;
        Blob headerValue = Blob.valueOf(username +':'+password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization',authorizationHeader);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setHeader('Content-Type','text/xml');
        String requestBody = '<Request><DUNS>'+acc.D_U_N_S__c
            +'</DUNS><BusinessSegment>'+prospectSegment+
            '</BusinessSegment><SystemID>'+servDivision.System_Code__c+
            '</SystemID><DivisionID>'+servDivision.Division_Composite_key__c+
            '</DivisionID><SalesRepCode>'+sRepCode+'</SalesRepCode><EmployeeID>'+acc.owner.Employee_ID__c+
            '</EmployeeID><ProspectID>'+acc.id+
            '</ProspectID><ParentDUNS>'+acc.Parent_Duns_Number__c+
            '</ParentDUNS><DomesticUltimateDUNS>'+acc.Domestic_Ultimate_Duns_Number__c+
            '</DomesticUltimateDUNS><GlobalUltimateDUNS>'+acc.Global_Ultimate_Duns_Number__c+
            '</GlobalUltimateDUNS><EquipmentCustomer>'+equipmentAcc+'</EquipmentCustomer></Request>';
        request.setBody(requestBody);
        System.debug('requestBody' +requestBody);
        HttpResponse response = http.send(request);
        // Parse the JSON response~
        system.debug(response.getStatusCode());
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
            Dom.Document doc = response.getBodyDocument();
            //Retrieve the root element for this document.
            System.debug('Elseeeee');
            Dom.XMLNode root = doc.getRootElement();
            system.debug('getChildElement'+root.getChildElements());
            system.debug(root.getChildElement('OutputParameters', null));
            Dom.XMLNode restXMLRes = root.getChildElement('OutputParameters', null);
            //system.debug(restXMLRes.getChildElement('CODE', null).getText());
            string code = restXMLRes.getChildElement('CODE', null).getText();
            string message = restXMLRes.getChildElement('MESSAGE', null).getText();
            string billToId = restXMLRes.getChildElement('BILLTOID', null).getText();
            string partyId = restXMLRes.getChildElement('PARTYID', null).getText();
            acc.Credit_Action_for_Setup__c =  code;
            Acc.Credit_Reason_Code__c = message;
            acc.Bill_To_Number_to_Merge_With__c  = billToId;   
            acc.Credit_Party_ID__c  = partyId;
            acc.Credit_Submitted_By__c = UserInfo.getUserId();
            acc.Credit_Submitted_Date__c = Datetime.now();
            update acc;
        }     
    }     
}
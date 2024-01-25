public class CredAppTriggerHandler {
    public static void afterInsert(List<Credit_Application__c> newList){
        credidAppGetId(newList, null);
    }

    public static void afterUpdate(List<Credit_Application__c> newList, Map<Id,Credit_Application__c> oldMap){
        credidAppGetId(newList, oldMap);
    }

    public static void credidAppGetId(List<Credit_Application__c> newList, Map<Id,Credit_Application__c> oldMap ){
        List<string> credIdString = new List<string>();
        for(Credit_Application__c credApp : newList){
            if(Trigger.isInsert|| (Trigger.isUpdate && credApp.Resend_Credit_Application__c))
                credIdString.add(credApp.id);
        }

        if(!credIdString.isEmpty()){
            sendCreditAppDataAPI(credIdString);
        }
    }
    
    @future (callout=true)
    public static void sendCreditAppDataAPI(List<String> credId){
        List<Account> accToUpdate =  new List<Account>();
        List<Credit_Application__c> lCreditApplications = getCreditApplications(credId);
        List<Credit_Application__c> lCreditApplicationsToUpdate = new List<Credit_Application__c>();
        List<Id> lAccountId = new List<Id>();
        Map<Id, Account> mAccountIdToAccount = new Map<Id, Account>();

        for(Credit_Application__c ca : lCreditApplications){
            lAccountId.add(ca.Account__c);
        }

        mAccountIdToAccount = new Map<Id, Account>([SELECT Name,Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, Credit_Party_ID__c, 
        Bill_To_Number_to_Merge_With__c, Credit_Reason_Code__c, Servicing_Division__r.Division_Composite_Key__c, Servicing_Division__r.System_Code__c,  
        Credit_Action_for_Setup__c,D_U_N_S__c,Sales_Rep_Code__c,Legacy_Division_Cd__c,Legacy_System_Cd__c,Prospect_Segment__c,Equipment_Account__c, 
        Global_Ultimate_Duns_Number__c,Domestic_Ultimate_Duns_Number__c,D_B_Doing_Business_As__c,Credit_Submitted_By__r.Name, Owner.Name, 
        Credit_Action_from_Credit_Dept__c, Internal_Comments_to_Credit__c, Link_to_Prospect__c  
                            FROM Account 
                            WHERE Id IN :lAccountId]);

        Credit_Application_Credential__c caCredential = Credit_Application_Credential__c.getOrgDefaults();
        String username = 'soauser';
        String password = 'soapassword';
        String endpoint = 'https://esbwebtst.veritivcorp.com/SFDC/emailAccts';
        if(caCredential != null){
            if(caCredential.Username__c != null){
                username = caCredential.Username__c;
            }
            
            if(caCredential.Password__c != null){
                password = caCredential.Password__c;
            }
            
            if(caCredential.Email_Accounts_Endpoint__c != null){
                endpoint = caCredential.Email_Accounts_Endpoint__c;
            }
        }
        
        //username and password to be set as blank to prevent errors
        username = '';
        password = '';        
        for(Credit_Application__c credApp: lCreditApplications){
            Account acc = mAccountIdToAccount.get(credApp.Account__c);
            Credit_Application__c tempCreditApplication = new Credit_Application__c();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            /*String authValue = username + ':' + password;
            Blob headerValue = Blob.valueOf(username +':'+password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);*/
            //request.setHeader('Authorization',authorizationHeader);
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setTimeout(120000);
            request.setHeader('Content-Type','text/xml');
            String requestBody = '<?xml version="1.0" encoding="utf-8"?><Message><Header></Header><Body><CustomerAccount>'
            +'<Action>'+acc.Credit_Action_for_Setup__c+'</Action>'
            +'<Message>'+acc.Credit_Reason_Code__c+'</Message>'
            +'<DUNS>'+escapeText(acc.D_U_N_S__c)+'</DUNS>'
            +'<SalesRepCode>'+escapeText(acc.Sales_Rep_Code__c)+'</SalesRepCode>'
            +'<SalesRepName>'+escapeText(acc.Owner.Name)+'</SalesRepName>'
            +'<SubmittedBy>'+escapeText(acc.Credit_Submitted_By__r.Name)+'</SubmittedBy>'
            +'<Division>'+escapeText(acc.Servicing_Division__r.Division_Composite_Key__c )+'</Division>'
            +'<SystemID>'+escapeText(acc.Servicing_Division__r.System_Code__c)+'</SystemID>'
            +'<BusinessSegment>'+acc.Prospect_Segment__c+'</BusinessSegment>'
            +'<EquipmentAccount>'+acc.Equipment_Account__c+'</EquipmentAccount>'
            +'<CreditInformation>'
            +'<CreditLine>'+credApp.Monthly_Credit_Limit_Currency__c+'</CreditLine>'
            +'<FedId>'+escapeText(credApp.Federal_ID_Number__c)+'</FedId>'
            +'<GlobalUltimateDUNS>'+escapeText(acc.Global_Ultimate_Duns_Number__c)+'</GlobalUltimateDUNS>'
            +'<DomesticUltimateDUNS>'+escapeText(acc.Domestic_Ultimate_Duns_Number__c)+'</DomesticUltimateDUNS>'
            +'<W9Flag>'+credApp.W_9__c+'</W9Flag>'
            +'<BankReferences><BankReference>'
            +'<BankName>'+escapeText(credApp.Bank_Name__c)+'</BankName>'
            +'<BankContact>'+escapeText(credApp.Bank_Contact__c)+'</BankContact>'
            +'<BankContactEmail>'+escapeText(credApp.Bank_Contact_Email__c)+'</BankContactEmail>'
            +'<AccountNumber>'+escapeText(credApp.Bank_Account_Number__c)+'</AccountNumber>'
            +'<AccountType>'+credApp.Bank_Account_Type__c+'</AccountType>'
            +'<City>'+escapeText(credApp.Bank_City__c)+'</City>'
            +'<State>'+escapeText(credApp.Bank_State__c)+'</State>'
            +'<Zip>'+escapeText(credApp.Bank_Zip__c)+'</Zip>'
            +'<Telephone>'+escapeText(credApp.Bank_Phone__c)+'</Telephone>'
            +'<Fax>'+credApp.Bank_Fax__c+'</Fax>'
            +'</BankReference></BankReferences></CreditInformation>'
            +'<BillTos><BillTo>'
            +'<BillToID>'+acc.Bill_To_Number_to_Merge_With__c+'</BillToID>'+
            +'<PartyID>'+acc.Credit_Party_ID__c+'</PartyID>'+
            +'<BusinessName>'+escapeText(acc.Name)+'</BusinessName>'
            +'<DBAName>'+escapeText(acc.D_B_Doing_Business_As__c)+'</DBAName>'
            +'<Address1>'+escapeText(acc.BillingStreet)+'</Address1>'
            +'<Address2>'+escapeText(credApp.Shipto_Street2__c)+'</Address2>'
            +'<City>'+escapeText(acc.BillingCity)+'</City>'
            +'<State>'+escapeText(acc.BillingState)+'</State>'
            +'<Postal>'+acc.BillingPostalCode+'</Postal>'
            +'<Telephone>'+acc.Phone+'</Telephone>'
            +'<Tax><TaxStatus>'+credApp.Tax_Status__c+'</TaxStatus>'
            +'<TaxContactName>'+escapeText(credApp.Tax_Contact_Name__c)+'</TaxContactName>'
            +'<Tax_Dept_Phone>'+credApp.Tax_Dept_Phone__c+'</Tax_Dept_Phone>'
            +'<Tax_Dept_Email>'+escapeText(credApp.Tax_Dept_Email__c)+'</Tax_Dept_Email>'
            +'<Tax_Exempt_Type>'+credApp.Tax_Exempt_Type__c+'</Tax_Exempt_Type>'
            +'<Tax_Exempt_Products>'+credApp.Tax_Exempt_Products__c+'</Tax_Exempt_Products>'
            +'<Tax_Exempt_Other>'+escapeText(credApp.Tax_Exempt_Other__c)+'</Tax_Exempt_Other>'
            +'<Tax_Exempt_States>'+escapeText(credApp.Tax_Exempt_States__c)+'</Tax_Exempt_States></Tax>'
            +'<APSetup><APContact>'+escapeText(credApp.A_P_Contact__c)+'</APContact>'
            +'<APEmail>'+escapeText(credApp.A_P_Email__c)+'</APEmail>'
            +'<APPhone>'+credApp.A_P_Phone__c+'</APPhone></APSetup>'
            +'<BillToSetup><InvoiceReq>'+credApp.Invoice_Requirements__c+'</InvoiceReq>'
            +'<BackOrders>'+credApp.Back_Orders_Accepted__c+'</BackOrders>'
            +'<PurchaseOrder>'+credApp.Purchase_Order_Required__c+'</PurchaseOrder>'
            +'<InvoiceDelivery>'+credApp.Method_of_Invoice_Delivery__c+'</InvoiceDelivery>'
            +'<DeliveryEmail>'+escapeText(credApp.Delivery_Email_Address__c)+'</DeliveryEmail>'
            +'<WebsiteAddress>'+escapeText(credApp.Portal_Website_Address__c)+'</WebsiteAddress></BillToSetup>'
            +'<ShipTos><ShipTo>'+
            +'<BusinessName>'+escapeText(credApp.Shipto_Name__c)+'</BusinessName>'
            +'<DBAName>'+escapeText(credApp.Shipto_Trade_Name__c)+'</DBAName>'
            +'<Address1>'+escapeText(credApp.Shipto_Street__c)+'</Address1>'
            +'<Address2>'+escapeText(credApp.Shipto_Street2__c)+'</Address2>'
            +'<City>'+escapeText(credApp.Shipto_City__c)+'</City>'
            +'<State>'+escapeText(credApp.Shipto_State__c)+'</State>'
            +'<Postal>'+credApp.Shipto_Postal_Zip__c+'</Postal>'
            +'<Telephone>'+credApp.Shipto_Phone__c+'</Telephone>'
            +'<Tax><TaxStatus>'+credApp.Tax_Status__c+'</TaxStatus>'
            +'<TaxContactName>'+escapeText(credApp.Tax_Contact_Name__c)+'</TaxContactName>'
            +'<Tax_Dept_Phone>'+escapeText(credApp.Tax_Dept_Phone__c)+'</Tax_Dept_Phone>'
            +'<Tax_Dept_Email>'+escapeText(credApp.Tax_Dept_Email__c)+'</Tax_Dept_Email>'
            +'<Tax_Exempt_Type>'+credApp.Tax_Exempt_Type__c+'</Tax_Exempt_Type>'
            +'<Tax_Exempt_Products>'+credApp.Tax_Exempt_Products__c+'</Tax_Exempt_Products>'
            +'<Tax_Exempt_Other>'+credApp.Tax_Exempt_Other__c+'</Tax_Exempt_Other>'
            +'<Tax_Exempt_States>'+escapeText(credApp.Tax_Exempt_States__c)+'</Tax_Exempt_States></Tax>'
            +'</ShipTo></ShipTos></BillTo></BillTos>'
            +'<Action_from_Credit_Dept>'+escapetext(acc.Credit_Action_from_Credit_Dept__c)+'</Action_from_Credit_Dept>'
            +'<Type_of_Link>'+escapetext(credApp.Type_of_Account__c)+'</Type_of_Link>'
            +'<Link_to_Prospects>'+escapetext(acc.Link_to_Prospect__c)+'</Link_to_Prospects>'
            +'<Internal_Comments>'+escapetext(acc.Internal_Comments_to_Credit__c)+'</Internal_Comments>'
            +'</CustomerAccount></Body></Message>';
            request.setBody(requestBody);

            HttpResponse response = http.send(request);
            System.debug('Endpoint: '+ endpoint);
            System.debug('Request Body: ' + request.getBody());
            // Parse the JSON response
            system.debug(response.getStatusCode());
            tempCreditApplication.Id = credApp.Id;
            tempCreditApplication.Response_code__c = String.valueOf(response.getStatusCode());
            tempCreditApplication.Resend_Credit_Application__c = false;
            lCreditApplicationsToUpdate.add(tempCreditApplication);
            if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
        }

        if(!lCreditApplicationsToUpdate.isEmpty()){
            update lCreditApplicationsToUpdate;
        }
    }

    public static String escapeText(String str){
        if(str != null){
            str = str.replace('&', '&amp;');
            str = str.replace('"', '&quot;');
            str = str.replace('<', '&lt;');
            str = str.replace('>', '&gt;');
            str = str.replace('\'', '&apos;');
            
            return str;
        }

        return null;
    }

    public static List<Credit_Application__c> getCreditApplications(List<String> lCreditId){
        // Perform isAccessible() checks here
        return [SELECT Id, Global_Duns_from_Form__c, Domestic_Duns_from_Form__c, Monthly_Credit_Limit_Currency__c, Account__c,Federal_ID_Number__c,W_9__c,Bank_Name__c,Bank_Contact__c,Bank_Contact_Email__c,Bank_Account_Number__c,Bank_Account_Type__c,
                Bank_City__c, Bank_State__c, Bank_Zip__c, Bank_Phone__c, Bank_Fax__c, Shipto_Name__c, Shipto_Street__c, Shipto_Street2__c,Shipto_City__c,
                Shipto_Postal_Zip__c, Shipto_Phone__c, Tax_Contact_Name__c, Tax_Status__c, Tax_Dept_Phone__c, Tax_Exempt_Type__c,
                Tax_Exempt_Products__c, Tax_Exempt_Other__c, Tax_Exempt_States__c, A_P_Contact__c, A_P_Email__c, A_P_Phone__c, Invoice_Requirements__c,
                Back_Orders_Accepted__c, Purchase_Order_Required__c, Method_of_Invoice_Delivery__c, Delivery_Email_Address__c,Portal_Website_Address__c,
                Shipto_State__c,Tax_Dept_Email__c, Shipto_Trade_Name__c, Type_of_Account__c FROM Credit_Application__c WHERE Id IN :lCreditId];
    }
}
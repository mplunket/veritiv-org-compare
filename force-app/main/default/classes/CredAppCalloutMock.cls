@isTest
global class CredAppCalloutMock implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {

        // Create a fake response
        String username = 'soauser';
        String password = 'soapassword';
        HttpResponse response = new HttpResponse();
        String authValue = username + ':' + password;
        Blob headerValue = Blob.valueOf(username +':'+password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        response.setHeader('Authorization',authorizationHeader);
        response.setHeader('Content-Type', 'text/xml');
        String requestBody = '<?xml version="1.0" encoding="utf-8"?><Message><Header></Header><Body><CustomerAccount>'
        +'<Action>'+'1'+'</Action>'
        +'<DUNS>'+'111'+'</DUNS>'
        +'<SalesRepCode>'+'111'+'</SalesRepCode>'
        +'<SalesRepName>'+'Simplus Mills'+'</SalesRepName>'
        +'<SubmittedBy>'+'Simplus Mills'+'</SubmittedBy>'
        +'<Division>'+'111'+'</Division>'
        +'<SystemID>'+'03'+'</SystemID>'
        +'<BusinessSegment>'+'Print'+'</BusinessSegment>'
        +'<EquipmentAccount>'+true+'</EquipmentAccount>'
        +'<CreditInformation>'
        +'<CreditLine></CreditLine>'
        +'<FedId>'+'111'+'</FedId>'
        +'<GlobalUltimateDUNS>'+'111'+'</GlobalUltimateDUNS>'
        +'<DomesticUltimateDUNS>'+'111'+'</DomesticUltimateDUNS>'
        +'<W9Flag>'+'Yes'+'</W9Flag>'
        +'<BankReferences><BankReference>'
        +'<BankName>'+'test'+'</BankName>'
        +'<BankContact>'+'test'+'</BankContact>'
        +'<BankContactEmail>'+'test@gmail.com'+'</BankContactEmail>'
        +'<AccountNumber>'+'111'+'</AccountNumber>'
        +'<AccountType>'+'Checking'+'</AccountType>'
        +'<City>'+'Atlanta'+'</City>'
        +'<State>'+'GA'+'</State>'
        +'<Zip>'+'30332'+'</Zip>'
        +'<Telephone>'+'6784929393'+'</Telephone>'
        +'<Fax>'+'6784929393'+'</Fax>'
        +'</BankReference></BankReferences></CreditInformation>'
        +'<BillTos><BillTo>'
        +'<BillToID></BillToID>'+
        +'<PartyID></PartyID>'+
        +'<BusinessName>'+'test'+'</BusinessName>'
        +'<DBAName>'+'test'+'</DBAName>'
        +'<Address1>'+'123 main st'+'</Address1>'
        +'<Address2>'+'unit A'+'</Address2>'
        +'<City>'+'Atlanta'+'</City>'
        +'<Postal>'+'30332'+'</Postal>'
        +'<Telephone>'+'6784929393'+'</Telephone>'
        +'<Tax><TaxStatus>'+'Exempt'+'</TaxStatus>'
        +'<TaxContactName>'+'test'+'</TaxContactName>'
        +'<Tax_Dept_Phone>'+'6784929393'+'</Tax_Dept_Phone>'
        +'<Tax_Dept_Email>'+'test@gmail.com'+'</Tax_Dept_Email>'
        +'<Tax_Exempt_Type>'+'Resale'+'</Tax_Exempt_Type>'
        +'<Tax_Exempt_Products>'+'Equipment'+'</Tax_Exempt_Products>'
        +'<Tax_Exempt_Other>'+'test'+'</Tax_Exempt_Other>'
        +'<Tax_Exempt_States>'+'Alabama'+'</Tax_Exempt_States></Tax>'
        +'<APSetup><APContact>'+'test'+'</APContact>'
        +'<APEmail>'+'test@gmail.com'+'</APEmail>'
        +'<APPhone>'+'6784929393'+'</APPhone></APSetup>'
        +'<BillToSetup><InvoiceReq>'+'Other'+'</InvoiceReq>'
        +'<BackOrders>'+true+'</BackOrders>'
        +'<PurchaseOrder>'+true+'</PurchaseOrder>'
        +'<InvoiceDelivery>'+'Mail'+'</InvoiceDelivery>'
        +'<DeliveryEmail>'+'test@gmail.com'+'</DeliveryEmail>'
        +'<WebsiteAddress>'+'www.test.com'+'</WebsiteAddress></BillToSetup>'
        +'<ShipTos><ShipTo>'+
        +'<BusinessName>'+'test'+'</BusinessName>'
        +'<Address1>'+'123 main st'+'</Address1>'
        +'<Address2>'+'unit A'+'</Address2>'
        +'<City>'+'Atlanta'+'</City>'
        +'<State>'+'GA'+'</State>'
        +'<Postal>'+'30332'+'</Postal>'
        +'<Telephone>'+'6784929393'+'</Telephone>'
        +'<Tax><TaxStatus>'+'Exempt'+'</TaxStatus>'
        +'<TaxContactName>'+'test'+'</TaxContactName>'
        +'<Tax_Dept_Phone>'+'6784929393'+'</Tax_Dept_Phone>'
        +'<Tax_Dept_Email>'+'test@gmail.com'+'</Tax_Dept_Email>'
        +'<Tax_Exempt_Type>'+'Resale'+'</Tax_Exempt_Type>'
        +'<Tax_Exempt_Products>'+'Equipment'+'</Tax_Exempt_Products>'
        +'<Tax_Exempt_Other>'+'test'+'</Tax_Exempt_Other>'
        +'<Tax_Exempt_States>'+'Alabama'+'</Tax_Exempt_States></Tax>'
        +'</ShipTo></ShipTos></BillTo></BillTos></CustomerAccount></Body></Message>';
        response.setBody(EncodingUtil.urlEncode(requestBody, 'UTF-8'));
        response.setStatusCode(200);
        return response; 

    }
}
public with sharing class FieldSourcingQuotingController {
    public List<WorkOrder> workOrdersWithQuoteId;
    public final String EMAIL_SUBJECT = Label.SendToFieldSourcingErrorEmailSubject;
    public Quote__c merchandiserQuote {get; private set;}
    public static final String WITH_FIELD_SOURCING = 'With Field Sourcing';
    
    public List<Send_to_field_sourcing__mdt> quoteToWorkOrderFieldMap{
        get{
            if(quoteToWorkOrderFieldMap == null){
                quoteToWorkOrderFieldMap = [SELECT Id, Field_Data_Origin_API_Name__c, Field_Data_Numeric_Value__c, Field_Data_Text_Value__c, Work_Order_Field_API_Name__c
                                       FROM Send_to_field_sourcing__mdt];
            }
            return quoteToWorkOrderFieldMap;
        }
        set;
    }
    public FieldSourcingQuotingController(ApexPages.StandardController stdController)
    {   
        merchandiserQuote = (Quote__c)stdController.getRecord();

    }
    public WorkOrder thisWorkOrder{get;set;}
    public Boolean noWorkOrders {
        get{
            if(noWorkOrders == null){
                workOrdersWithQuoteId = [SELECT Id, WorkOrderNumber  FROM WorkOrder WHERE Quote__c =: merchandiserQuote.Id];
                
                if(workOrdersWithQuoteId.isEmpty()){
                    noWorkOrders = true;
                }
                else{
                    noWorkOrders = false;
                    thisWorkOrder = workOrdersWithQuoteId[0];
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Work Order ' + workOrdersWithQuoteId[0].WorkOrderNumber + ' ' + Label.SendToFieldSourcingExistingWorkOrder));
                }
            }
            return noWorkOrders;
        
        }set;
    }
    
    public String buildSqlStatement(Id objectId, String objectApiName){
        String sqlString = 'SELECT ';
                                                                         
        for(Send_to_field_sourcing__mdt field : quoteToWorkOrderFieldMap ){
            if(String.isNotBlank(field.Field_Data_Origin_API_Name__c)){
                sqlString += field.Field_Data_Origin_API_Name__c + ', ';
                
            }
            
        }
        sqlString += 'Id FROM ' 
                        + objectApiName + ' WHERE ID = \'' + objectId + '\'';
        
        return sqlString;
    }
    
    public WorkOrder buildWorkOrder(Id quoteId){
        
        WorkOrder newWorkOrder = new WorkOrder();
        
        List<Quote__c> requestFields = [SELECT Id, Name, Servicing_Division_Name__c, Count_of_Line_Items__c, Shipment_Method__c, Requested_Delivery_Date__c, Subject__c, Vendor_Comments__c, Internal_Comments__c 
                                            FROM Quote__c WHERE Id =: quoteId];
                                            
        String requestFieldValue = 'Quote Number: ' + requestFields[0].Name + '\n'
                                        + ' Servicing Division Name: ' + requestFields[0].Servicing_Division_Name__c + '\n'
                                        + ' Shipment Method: ' + requestFields[0].Shipment_Method__c + '\n'
                                        + ' Number of Line Items: ' + requestFields[0].Count_of_Line_Items__c + '\n'
                                        + ' Possible Expected Delivery Date: ' + requestFields[0].Requested_Delivery_Date__c + '\n'
                                        + ' Subject: ' + requestFields[0].Subject__c + '\n'
                                        + ' Internal Comments: ' + requestFields[0].Internal_Comments__c + '\n'
                                        + ' Vendor Comments: ' + requestFields[0].Vendor_Comments__c;
        
        List<Quote__c> recapturedQuote = Database.query(buildSqlStatement(quoteId, 'Quote__c'));
        
        if(!quoteToWorkOrderFieldMap.isEmpty() && !recapturedQuote.isEmpty()){
            for(Send_to_field_sourcing__mdt field : quoteToWorkOrderFieldMap ){
                if(!String.isBlank(String.valueOf(field.Field_Data_Origin_API_Name__c))){
                    newWorkOrder.put('Quote__c', quoteId);
                    newWorkOrder.put('Request__c', requestFieldValue);
                    newWorkOrder.put(field.Work_Order_Field_API_Name__c, recapturedQuote[0].get(field.Field_Data_Origin_API_Name__c));
                }
                else{
                     if(!String.isBlank(String.valueOf(field.Field_Data_Text_Value__c))){
                        newWorkOrder.put('Quote__c', quoteId);
                        newWorkOrder.put('Request__c', requestFieldValue);
                        newWorkOrder.put(field.Work_Order_Field_API_Name__c, field.Field_Data_Text_Value__c);
                    }
                    else if(!String.isBlank(String.valueOf(field.Field_Data_Numeric_Value__c))){
                        newWorkOrder.put('Quote__c', quoteId);
                        newWorkOrder.put('Request__c', requestFieldValue);
                        newWorkOrder.put(field.Work_Order_Field_API_Name__c, field.Field_Data_Numeric_Value__c);
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.SendToFieldSourcingErrorText)); 
                        String body = 'Quote Id: ' + quoteId + 'message';
                        sendErrorEmail(body);
                        newWorkOrder = null;
                        break;
                    }
                }
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.SendToFieldSourcingErrorText));
            Quote__c quoteForEmail = [SELECT Id, Account__r.Name FROM Quote__c WHERE Id =: merchandiserQuote.Id];
            String body = Label.SendToFieldSourcingErrorEmailBody 
                            + '\n Quote Id: ' + merchandiserQuote.Id 
                            + '\n Account Name: ' + quoteForEmail.Account__r.Name 
                            + '\n User Name: ' + UserInfo.getName();
            sendErrorEmail(body);
            newWorkOrder = null;
        }
        return newWorkOrder;
    }
    
    public void populateWorkOrders(WorkOrder wo) {
        try{
            upsert wo;
            thisWorkOrder = wo;
            noWorkOrders = false;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.SendToFieldSourcingSuccess));
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.SendToFieldSourcingErrorText)); 
            
            Quote__c quoteForEmail = [SELECT Id, Account__r.Name FROM Quote__c WHERE Id =: merchandiserQuote.Id];       
            String body = Label.SendToFieldSourcingErrorEmailBody 
                            + '\n Quote Id: ' + merchandiserQuote.Id 
                            + '\n Account Name: ' + quoteForEmail.Account__r.Name 
                            + '\n User Name: ' + UserInfo.getName();
            sendErrorEmail(body);
        }
    }
    public void sendErrorEmail(String body){
        List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();
        Map<String, Apex_Class_Error_Emails__c> emailRecipients = Apex_Class_Error_Emails__c.getAll();
        
        for(Apex_Class_Error_Emails__c adminRecord : emailRecipients.values()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId((Id) adminRecord.User_ID__c);
            mail.setSubject(EMAIL_SUBJECT);
            mail.setPlainTextBody(body);
            allMail.add(mail);
        }
        try{
            Messaging.sendEmail( allMail ); 
        }
        catch(Exception ex){
            
        }
    }
    public void saveAndSetStage()
    {
        merchandiserQuote.Quote_Stage__c = WITH_FIELD_SOURCING;
        try
        {
            update merchandiserQuote;
            WorkOrder workOrderToCreate = buildWorkOrder(merchandiserQuote.Id);

            if(workOrderToCreate != null){
                populateWorkOrders(workOrderToCreate);
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
    }
    
    public PageReference returnToQuote()
    {
        return new PageReference('/' + merchandiserQuote.Id);
    }
    public PageReference goToWorkOrder()
    {
        return new PageReference('/' + thisWorkOrder.Id);
    }
}
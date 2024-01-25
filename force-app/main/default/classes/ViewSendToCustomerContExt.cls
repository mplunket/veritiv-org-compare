public with sharing class ViewSendToCustomerContExt {
    
    @TestVisible
    private String templateNameUsed;
    @TestVisible
    private String templateIdUsed;
    
    private String qliIds;
    
    public Quote__c quote {get; set;}
    public Attachment attachment {get; set;}
    public List<Attachment> existingAttachments {get; set;}
    public Set<Id> attIds {get; set;}
    public Boolean hasExistingAttachments {get; set;}
    public String currentAttId {get; set;}
    
    public Quote_Line_Item__c email
    {
        get
        {
            if(email == null && isValidQuote)
                email = new Quote_Line_Item__c(Vendor_Contact__c = quote.Customer_Contact__c);
            
            return email;
        }
        set {email = value;}
    }
    
    public String emailAdditionalTo {get; set;}
    
    public String emailCC {get; set;}
    
    public String emailBCC {get; set;}
    
    public boolean isValidQuote
    {
        get
        {
            if(isValidQuote == null)
            {
                if(ApexPages.currentPage().getParameters().get('id') == null)
                {
                    isValidQuote = false;
                    return isValidQuote;
                }
                else
                {
                    isValidQuote = true;
                    return isValidQuote;
                }
            }
            return isValidQuote;
        }
        private set
        {
            isValidQuote = value;
        }
    }
    
    
    public Boolean hasSelectedRecords
    {
        get
        {
            return true;
            /*
if(this.qliSetController.getSelected().size() > 0)
return true;
else
return false;
*/
        }
    }
    
    public void initNewAttachment()
    {
        attachment = new Attachment(ParentId = ApexPages.currentPage().getParameters().get('id'));
        hasExistingAttachments = false;
        existingAttachments = new List<Attachment>();
    }
    
    public void addAttachment()
    {
        
        if (attachment.Body != null)
        {
            insert attachment;
            existingAttachments.add(attachment);
            attIds.add(attachment.id);
        }
        initNewAttachment();
        existingAttachments = [SELECT Id, ParentId, Name, BodyLength, LastModifiedDate FROM Attachment WHERE Id in :attIds];
        hasExistingAttachments = true;
        
    }
    
    public void removeAttachment()
    {
        
        attIds.remove(currentAttId);
        delete [SELECT Id FROM Attachment WHERE Id = :currentAttId];
        initNewAttachment();
        existingAttachments = [SELECT Id, ParentId, Name, BodyLength, LastModifiedDate FROM Attachment WHERE Id in :attIds];
        if (attIds.size()>0)
            hasExistingAttachments = true;
        else
            hasExistingAttachments = false;
        
    }
    
    public List<Attachment> updateExistingAttachmentsList()
    {
        List<Attachment> attchList = [SELECT Id, Body, ParentId, Name, BodyLength, LastModifiedDate FROM Attachment WHERE Id in :attIds];
        if (attachment != null)
        {
            attchList.add(attachment);
        }
        return attchList;
    }
    
    public PageReference sendQuote() {
        
        //Add title query parm and file name
        // changes made by sujitha
        String fileName = '';
        string dep = '';
        id quoteID = ApexPages.currentPage().getParameters().get('id');
        System.debug('quoteID'+quoteID);
        if(quoteID != null){
            Quote__c qt = [select id, account__c,account__r.VOS_Business_Group__c from Quote__c where id = : quoteID limit 1];
            System.debug('qt'+qt.account__r.VOS_Business_Group__c);
            
            Account ac = [select id,name,recordtype.name,VOS_Business_Group__c from account where id =:qt.account__c limit 1];
            if(ac.recordtype.name == 'Prospect'){
                String department = [Select Department From User Where Id = : UserInfo.getUserId() Limit 1].Department;
                if(department == 'Saalfeld'){
                    dep = 'Saalfeld';
                }else{
                    dep = 'Default';
                }
                
            }else{
                if(ac.VOS_Business_Group__c =='SA'){
                    dep = 'Saalfeld';
                }else{
                    dep = 'Default';
                }
            }
            
            
            PDF_Name_Setting__mdt pdfSett = [SELECT DeveloperName, Id, Label, PDF_File_Name__c, PDF_Template_Name__c,pdf_department_name__c,
                                             Email_Type__c FROM PDF_Name_Setting__mdt where Email_Type__c = 'Customer' AND pdf_department_name__c =: dep limit 1];
            string tempName = pdfSett.PDF_Template_Name__c;
            templateIdUsed = [select Id from EmailTemplate where DeveloperName = :tempName].Id;
            fileName = pdfsett.PDF_File_Name__c;
            
        }
        
        //End of changes
        
        //Prepare URL for PDF page
        String quoteURL = Page.Quote.getURL() + '?id=' + quote.Id;
        
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        emailMsg.setTargetObjectId(email.Vendor_Contact__c);
        emailMsg.setWhatId(quote.Id);
        
        /* Removing Websource Templates -> Falling back to Defaults */
        /*
if(department == Consts.WEBSOURCE_DEPARTMENT)
{
emailMsg.setTemplateId([select Id from EmailTemplate where DeveloperName = :WEBSOURCE_TEMPLATE].Id);
fileName = WEBSOURCE_FILENAME;
}
else */
        
        //Commented/modified by sujitha
        
        /*PDF_Name_Setting__mdt templateSetting = PDFEmailServices.getTemplateSetting( 'Customer' );
System.debug('templateSetting'+templateSetting);
templateNameUsed = templateSetting.PDF_Template_Name__c;
System.debug('templateNameUsed'+templateNameUsed);
fileName = templateSetting.PDF_File_Name__c;
System.debug('fileName'+fileName);

templateIdUsed = [select Id from EmailTemplate where DeveloperName = :templateNameUsed].Id;
System.debug('templateIdUsed'+templateIdUsed);*/
        
        //End of changes
        
        
        emailMsg.setTemplateId( templateIdUsed );
        
        String[] emailAddresses = emailAdditionalTo.split(';');
        emailMsg.setToAddresses(removeBlanks(emailAddresses));
        
        emailAddresses = emailCC.split(';');
        emailMsg.setCcAddresses(removeBlanks(emailAddresses));
        
        emailAddresses = emailBCC.split(';');
        emailMsg.setBccAddresses(removeBlanks(emailAddresses));
        
        String[] selectedIds;
        selectedIds = this.qliIds.split(',');
        
        for(Integer i=0; i < selectedIds.size(); ++i)
            quoteURL += '&qlid' + i + '=' + selectedIds[i];
        
        quoteURL += '&title=' + QuoteControllerExtension.CUSTOMER_TITLE;
        
        //Instantitiate PDF page
        PageReference quotePage = new PageReference(quoteURL);
        //Prepare attachment to quote
        Attachment quoteAttachment = new Attachment();
        System.debug('SFDC: Page: [' + quotePage.getURL() + ']');
        Blob blobContent;
        if(!Test.isRunningTest()){
            blobContent = quotePage.getContent();
            quoteAttachment.Body = blobContent; 
            //quoteAttachment.Body = quotePage.getContent();
            }
        else
            quoteAttachment.Body = Blob.valueOf( 'Test Content' );
        quoteAttachment.Name = fileName;
        quoteAttachment.ParentId = quote.Id;
        //Insert attachment to email
        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
        emailAttachment.setFileName(fileName);
        if(!Test.isRunningTest())
            //emailAttachment.setBody(quotePage.getContent());
            emailAttachment.setBody(blobContent); 
        else
            emailAttachment.setBody(Blob.valueOf( 'Test Content' ));
        
        List<Messaging.EmailFileAttachment>  fileAttachmentList = new List<Messaging.EmailFileAttachment> ();
        Messaging.EmailFileAttachment[]  fileAttachments = new Messaging.EmailFileAttachment[]{};
        List<Attachment>  attchList = new list<Attachment>();
        if(attIds.size()>0){
            attchList = updateExistingAttachmentsList();
        }
        for (Attachment att : attchList)
        {
            if (att.Body != null)
            {
                Messaging.EmailFileAttachment myAtt = new Messaging.EmailFileAttachment();
                myAtt.setFileName(att.Name);
                myAtt.setBody(att.Body);
                fileAttachmentList.add(myAtt);
            }
        }
        
        fileAttachments.addAll(fileAttachmentList);
        fileAttachments.add(emailAttachment);
        
        emailMsg.setFileAttachments(fileAttachments);
        
        
        Savepoint sp = Database.setSavepoint();
        Messaging.SendEmailResult[] sers;
        
        //Insert PDF as quote attachment & send email
        try
        {
            insert quoteAttachment;
            sers = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg});
        }
        catch(DmlException dmle)
        {
            for (Integer i=0; i < dmle.getNumDml(); i++)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmle.getDmlMessage(i)));
            
            Database.rollback(sp);
            return null;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return null;
        }
        
        Boolean allSuccessful = true;
        for(Messaging.SendEmailResult ser : sers)
        {
            if(!ser.isSuccess())
            {
                allSuccessful = false;
                break;
            }
        }
        if(allSuccessful) {
            
            // Take the user back to the Quote page
            PageReference pageRef = Page.ViewQuote;
            pageRef.getParameters().put('id', this.quote.Id);
            
            return pageRef;
            
        }
        else
        {
            for(Messaging.SendEmailResult ser : sers)
            {
                for(Database.Error de : ser.getErrors())
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getMessage()));
            }
            return null;
        }
        
        //return null;
    }
    
    private String[] removeBlanks(String[] emailAddresses)
    {
        String[] returnAddresses = new String[0];
        for(Integer i=0; i < emailAddresses.size(); i++)
        {
            emailAddresses[i] = emailAddresses[i].trim();
            if(emailAddresses[i].length() > 0) returnAddresses.add(emailAddresses[i]);
        }
        return returnAddresses;
    }
    
    public ViewSendToCustomerContExt(ApexPages.StandardController controller) {
        
        this.quote = [SELECT Id, CreatedDate FROM Quote__c WHERE Id = :((Quote__c)controller.getRecord()).Id];
        
        initNewAttachment();
        attIds = new Set<Id>();
        
        //Validation rules
        if(!isValidQuote)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This page cannot be accessed directly.  It can only be reached from the "Send to Customer" button on a quote record.'));
            return;
        }
        
        qliIds = ApexPages.currentPage().getParameters().get('qliIds');
        
        List<String> errorSummary = new List<String>();
        List<String> errorInformation = new List<String>();
        
        Set<Id> selectedQLISet = new Set<Id>();
        for(String selectedId :qliIds.split(','))
        {
            selectedQLISet.add(selectedId);
        }
        
        for(Quote_Line_Item__c qli :[SELECT Id, Product_Code__c, Updated_P_A__c FROM Quote_Line_Item__c WHERE Id IN :selectedQLISet])
        {
            if(qli.Updated_P_A__c == FALSE)
            {
                errorInformation.add('Item Product Code: ' + qli.Product_Code__c + ' (Id: ' + qli.Id + ')');
            }
        }
        
        if (this.quote.CreatedDate < Consts.LEGACY_QUOTE_CUTOFF_DATE)
        {
            errorSummary.add(Label.LegacyQuoteErrorMessage);
        }
        
        if(!errorInformation.isEmpty())
        {
            isValidQuote = FALSE;
            errorSummary.add(Label.IneligibleQuoteErrorMessage);
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.join(errorSummary, '<br/>'), String.join(errorInformation, '<br/>')));
            return;
        }
        
        this.quote = [select Name, Account__r.Name, Account__r.RecordType.Name, Servicing_Division__c, Servicing_Division_Name__c, Account__r.AccountNumber, Account__r.Primary_Sales_Rep_Name__r.Contact__c, Ship_To_Number__c, Customer_Contact__c, Shipment_Method__c from Quote__c where Id = :ApexPages.currentPage().getParameters().get('id')];        
        
        emailAdditionalTo = '';
        emailCC = '';
        emailBCC = '';
        
        
    }
}
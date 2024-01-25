public class SendToVendorQLIControllerExtension
{
    private final ApexPages.StandardSetController qliSetController;

    //Properties
    public Quote__c quote {get; set;}
    public Attachment attachment {get; set;}
	public List<Attachment> existingAttachments {get; set;}
	public Set<Id> attIds {get; set;}
	public Boolean hasExistingAttachments {get; set;}
	public String currentAttId {get; set;}
	
	public SendToVendorQLIControllerExtension(ApexPages.StandardSetController stdSetController)
    {
        qliSetController = stdSetController;
        initNewAttachment();
        attIds = new Set<Id>();
        //Validation rules
        if(!isValidQuote)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This page cannot be accessed directly.  It can only be reached from the "Send to Vendor" button on a quote record.'));
            return;
        }
        if(!hasSelectedRecords)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Quote Line Items have been selected. Please click the "Back" button and select at least one record.'));
            return;
        }
	
	    
        Map<ID, Vendor_Detail__c> allVendors = new Map<ID, Vendor_Detail__c>();
        ID sundryVendorID = null;
        for(Integer i=0; i < this.qliSetController.getSelected().size(); i++)
        {
            Quote_Line_Item__c qli = (Quote_Line_Item__c)this.qliSetController.getSelected()[i];
            //Save Sundry Vendor ID to memory
            if(qli.Vendor_Name__r.Name == 'SUNDRY VENDOR')
                sundryVendorID = qli.Vendor_Name__c;
            //Get distinct vendors by putting into map
            allVendors.put(qli.Vendor_Name__c, qli.Vendor_Name__r);
        }
        //Remove Sundry Vendor from allVendors map
        allVendors.remove(sundryVendorID);
        if(allVendors.size() > 1)
        {
            isValidQuote = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Multiple vendors cannot be selected for a vendor quote.'));
            return;
        }
        //Validation rules passed, continue
        quote = [select Name, Account__r.Name, Account__r.RecordType.Name, Servicing_Division__c, Servicing_Division_Name__c, Account__r.AccountNumber, Account__r.Primary_Sales_Rep_Name__r.Contact__c, Ship_To_Number__c, Customer_Contact__c, Shipment_Method__c from Quote__c where Id = :ApexPages.currentPage().getParameters().get('id')];
        
        emailAdditionalTo = '';
        emailCC = '';
        emailBCC = '';
        
    }
	

    public Quote_Line_Item__c email
    {
        get
        {
            if(email == null && isValidQuote)
            {
                email = new Quote_Line_Item__c();
                if(this.qliSetController.getSelected()[0].get('Vendor_Contact__c') != null)
                    email.Vendor_Contact__c = (ID)this.qliSetController.getSelected()[0].get('Vendor_Contact__c');
            }

            return email;
        }
        set
        {
            email = value;
        }
    }
    
    public String emailAdditionalTo {get; set;}
    
    public String emailCC {get; set;}
    
    public String emailBCC {get; set;}
    
    @TestVisible
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
            if(this.qliSetController.getSelected().size() > 0)
                return true;
            else
                return false;
        }
    }
    //Methods
    @testVisible
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
		
    public PageReference sendQuote()
    {
		Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        emailMsg.setTargetObjectId(email.Vendor_Contact__c);
        emailMsg.setWhatId(quote.Id);
                
        String department = [Select Department From User Where Id = :UserInfo.getUserId() Limit 1].Department;
        String fileName = '';
        
        /* Removing Websource Templates -> Falling back to Defaults */
        /*
        if(department == 'Websource')
        {
        	emailMsg.setTemplateId([select Id from EmailTemplate where DeveloperName = 'Vendor_Quote_Template_Websource'].Id);
        	fileName = 'Websource Vendor Quote.pdf';
        }
    	else
    	*/
    	{
    		emailMsg.setTemplateId([select Id from EmailTemplate where DeveloperName = 'Vendor_Quote_Template'].Id);
    		fileName = 'Unisource Vendor Quote.pdf';
    	}
        
        
        String[] emailAddresses = emailAdditionalTo.split(';');
        emailMsg.setToAddresses(removeBlanks(emailAddresses));
        
        emailAddresses = emailCC.split(';');
        emailMsg.setCcAddresses(removeBlanks(emailAddresses));
        
        emailAddresses = emailBCC.split(';');
        emailMsg.setBccAddresses(removeBlanks(emailAddresses));
        
        //Prepare URL for PDF page
        String quoteURL = Page.Quote.getURL() + '?id=' + quote.Id;
        //Add QLI Ids query parms
        for(Integer i=0; i < this.qliSetController.getSelected().size(); i++)
        {
            if(this.qliSetController.getSelected()[i].get('Id') == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The information required to send this email has been reset due to a previous error message.  Please recreate the email by going back to the quote and clicking the "Send to Vendor" button again.'));
                return null;
            }
            quoteURL += '&qlid' + i + '=' + this.qliSetController.getSelected()[i].get('Id');
        }
        //Add title query parm
        quoteURL += '&title=Vendor';
		
        //Instantitiate PDF page
        PageReference quotePage = new PageReference(quoteURL);
        //Prepare attachment to quote
        Attachment quoteAttachment = new Attachment();
        if(test.isrunningTest()){
            quoteAttachment.Body  = blob.valueOf('hello');
        }else{
            quoteAttachment.Body = quotePage.getContent();
        }
        
        quoteAttachment.Name = fileName;
        quoteAttachment.ParentId = quote.Id;        
     
        //Insert attachment to email
        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
        emailAttachment.setFileName(fileName);
        
        if(test.isrunningTest()){
            emailAttachment.setBody(blob.valueOf('hello'));
        }else{
             emailAttachment.setBody(quotePage.getContent());
        }
        
       
   
      	List<Messaging.EmailFileAttachment>  fileAttachmentSet = new List<Messaging.EmailFileAttachment> ();
     	Messaging.EmailFileAttachment[]  fileAttachments = new Messaging.EmailFileAttachment[]{};
      	List<Attachment>  attchList = updateExistingAttachmentsList();
	
	   	for (Attachment att : attchList)
      	{
	       if (att.Body != null)
	       {
	       		Messaging.EmailFileAttachment myAtt = new Messaging.EmailFileAttachment();
	       		myAtt.setFileName(att.Name);
	        	myAtt.setBody(att.Body);
	        	fileAttachmentSet.add(myAtt);
	    	}      	
	    }
	     
		fileAttachments.addAll(fileAttachmentSet);
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
        if(allSuccessful)       
            return qliSetController.cancel();
        else
        {
            for(Messaging.SendEmailResult ser : sers)
            {
                for(Database.Error de : ser.getErrors())
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, de.getMessage()));
            }
            return null;
        }
    }
   /* 
    private static Account testCustAccount;
    private static Ship_To__c testShipAccount;
    private static Quote__c testQuote;
    private static Quote_Line_Item__c[] testQLIs = new Quote_Line_Item__c[0]; */

}
global class CPLEmailBatch implements Database.Batchable<sObject>, Database.Stateful 
{   
    String query;
    public List<CPLEmail> emails;

    public Date today {
        get {
            return (today == null) ? Date.today() : today;
        }
        set;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        emails = new List<CPLEmail>();

        Date d = today;
        System.debug(d);
        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());

        String dayOfWeek = dt.format('EEEE');
        Integer dayOfMonth = d.day();

        query = 'SELECT Id, Customer_Email__c, Version_Format__c, Agreement__c,Last_Successful_Run_Time__c FROM Customer_Price_List__c '
            + 'WHERE ';

        if (dayOfWeek == 'Friday'){
            query += ' Print_Date__c = ' + '\'Per Submit Every Friday\'';
        } 
        else if (dayOfMonth == 25){
            query += ' Print_Date__c = ' + '\'Monthly\'';
        }
        else{
            query = '';
        }

        if (String.isNotBlank(query)) {
            query += ' ORDER BY Agreement__c, Last_Successful_Run_Time__c DESC';
            return Database.getQueryLocator(query);
        } else {
            System.abortJob(bc.getJobId());
        }
        
        return null;
    }

    global void execute(Database.BatchableContext context, List<sObject> scope){
        List<Customer_Price_List__c> cpls = (List<Customer_Price_List__c>) scope;
        Map<Id, DateTime> mContractIdToLastSuccesfulRun = new Map<Id, DateTime>();
        Map<Id, Customer_Price_List__c> mCPLIdToCPLRecord = new Map<Id, Customer_Price_List__c>();
        Map<Id, Boolean> mAgreementToModifiedCLIFlag = new Map<Id, Boolean>();
        List<zpl__ContractLineItem__c> lContractLineItem = new List<zpl__ContractLineItem__c>();
        List<Id> lContractId = new List<Id>();
        DateTime earliestCreatedDate;


        for (Customer_Price_List__c cpl : cpls) {
            if(!mContractIdToLastSuccesfulRun.containsKey(cpl.Agreement__c)){
                mContractIdToLastSuccesfulRun.put(cpl.Agreement__c, null); //instantiate
            }
            if(cpl.Last_Successful_Run_Time__c > mContractIdToLastSuccesfulRun.get(cpl.Agreement__c) || mContractIdToLastSuccesfulRun.get(cpl.Agreement__c)  == null){ 
                System.debug('mContractIdToLastSuccesfulRun.get(cpl.Agreement__c)' + mContractIdToLastSuccesfulRun.get(cpl.Agreement__c));
                System.debug('cpl.Last_Successful_Run_Time__c' + cpl.Last_Successful_Run_Time__c);
                //grab the latest succesful run per contract/agreement
                //this will be used as a checker for CLI records that has been modified beyond their CPL's last successful run.
                mContractIdToLastSuccesfulRun.put(cpl.Agreement__c, cpl.Last_Successful_Run_Time__c);
            }

            if(!mCPLIdToCPLRecord.containsKey(cpl.Agreement__c) && cpl.Last_Successful_Run_Time__c == null ){
                mCPLIdToCPLRecord.put(cpl.Id, cpl); //only CPLs with null Last_Successful_Run_Time__c will be part of the batch
                lContractId.add(cpl.Agreement__c); // used for querying cli's
            }
        }

        //mCPLIdToCPLRecord for filtering the query.
        for(zpl__ContractLineItem__c cli : [SELECT Id, zpl__Status__c, zpl__Contract__c, LastModifiedDate FROM zpl__ContractLineItem__c WHERE zpl__Status__c = 'Published' AND zpl__Contract__c IN :lContractId]){
            if(mContractIdToLastSuccesfulRun.get(cli.zpl__Contract__c) != null ){
                //instantiate
                if(!mAgreementToModifiedCLIFlag.containsKey(cli.zpl__Contract__c)){ 
                    mAgreementToModifiedCLIFlag.put(cli.zpl__Contract__c, false); 
                }

                //LastModified Beyond Contract's Last Succesful Run and
                //if mAgreementToModifiedCLIFlag.get() is false
                if(cli.LastModifiedDate >= mContractIdToLastSuccesfulRun.get(cli.zpl__Contract__c) && !mAgreementToModifiedCLIFlag.get(cli.zpl__Contract__c)){
                    //check if at least 1 CLI's lastmodified is beyond the contract's last successful run
                    System.debug('cli.LastModifiedDate' +cli.LastModifiedDate);
                    System.debug('map' +  mContractIdToLastSuccesfulRun.get(cli.zpl__Contract__c));
                    mAgreementToModifiedCLIFlag.put(cli.zpl__Contract__c, true);
                } 
            }
        }

        // FIRST CONDITION: if it's the First CPL record, then it will be included in the batch OR
        // SECOND CONDITION: if it is not the First CPL record, then check if there are modification in it's CLIs based on the Last Successful run of the CPL of a contact
        for(Id cplId : mCPLIdToCPLRecord.keySet()){
            System.debug('mAgreementToModifiedCLIFlag' + mAgreementToModifiedCLIFlag);
            System.debug('mCPLIdToCPLRecord.get(cplId).Agreement__c' + mCPLIdToCPLRecord.get(cplId).Agreement__c);
            if(mContractIdToLastSuccesfulRun.get(mCPLIdToCPLRecord.get(cplId).Agreement__c) == null || //if this map is null, then it means that this is the first CPL record of the contract
                mAgreementToModifiedCLIFlag.get(mCPLIdToCPLRecord.get(cplId).Agreement__c) //if this is true, then there are modification in its line items
            ) { 
                System.debug('mContractIdToLastSuccesfulRun.get(mCPLIdToCPLRecord.get(cplId).Agreement__c)' + mContractIdToLastSuccesfulRun.get(mCPLIdToCPLRecord.get(cplId).Agreement__c));
                System.debug('mAgreementToModifiedCLIFlag.get(mCPLIdToCPLRecord.get(cplId).Agreement__c)' +mAgreementToModifiedCLIFlag.get(mCPLIdToCPLRecord.get(cplId).Agreement__c));
                CPLEmail email = new CPLEmail(
                    mCPLIdToCPLRecord.get(cplId).Customer_Email__c.split('\n'),
                    mCPLIdToCPLRecord.get(cplId).Version_Format__c,
                    mCPLIdToCPLRecord.get(cplId).Id
                );
                emails.add(email);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        CPL_Batch_Result__c batchResult = new CPL_Batch_Result__c(
            Completion_Time__c = DateTime.now(),
            Total_Emails_to_be_Sent__c = 0,
            Emails_Actually_Sent__c = 0,
            Emails_With_Error__c = 0
        );

        List<Messaging.SingleEmailMessage> messages = generateEmails();

        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();

        try{
            results = Messaging.sendEmail(messages, false);
        } catch (EmailException e) {
            batchResult.Exception_Before_Completion__c = true;
            batchResult.Exception_Text__c = e.getMessage();
        }
        
        List<Customer_Price_List__c> cpls = new List<Customer_Price_List__c>();

        List<CPL_Batch_Email_Error__c> emailErrors = new List<CPL_Batch_Email_Error__c>();

        for (Integer i = 0; i < emails.size(); i++){
            CPLEmail email = emails[i];
            Messaging.SendEmailResult result; 
            if (results.size() > i){ 
                 result = results[i];
            }

            Customer_Price_List__c cpl = new Customer_Price_List__c(
                Id = email.cplId
            );

            batchResult.Total_Emails_to_be_Sent__c++;

            if (result != null && result.isSuccess()){
                batchResult.Emails_Actually_Sent__c++;
                cpl.Last_Successful_Run_Time__c = DateTime.now();
            } 
            else if (result != null){
                batchResult.Emails_With_Error__c++;

                CPL_Batch_Email_Error__c emailError = new CPL_Batch_Email_Error__c(
                    Customer_Price_List__c = email.cplId
                );

                List<String> errorMessages = new List<String>();

                List<Messaging.SendEmailError> errors = result.getErrors();
                for (Messaging.SendEmailError error : errors){
                    errorMessages.add(error.getMessage());
                }

                emailError.Error__c = String.join(errorMessages, '\n');

                emailErrors.add(emailError);
            } 
            else{
                batchResult.Emails_With_Error__c++;

                CPL_Batch_Email_Error__c emailError = new CPL_Batch_Email_Error__c(
                    Customer_Price_List__c = email.cplId,
                    Error__c = 'Exception occured before sending. Check exceptions on the Batch Result.'
                );

                emailErrors.add(emailError);
            }

            cpls.add(cpl);
        }

        insert batchResult;

        if (emailErrors.size() > 0) {
            for (CPL_Batch_Email_Error__c emailError : emailErrors){
                emailError.CPL_Batch_Result__c = batchResult.Id;
            }

            insert emailErrors;
        }

        if (cpls.size() > 0){
            for (Customer_Price_List__c cpl : cpls){
                cpl.Most_Recent_CPL_Batch_Result__c = batchResult.Id;
            }

            update cpls;
        }
    }

    public List<Messaging.SingleEmailMessage> generateEmails(){
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for (CPLEmail email : emails){
            messages.add(email.generateEmail());
        }
        return messages;
    }

    public class CPLEmail{
        List<String> toAddresses;
        public String subject;
        public String body;
        public Id cplId;
        public String versionFormat;

        public CPLEmail (List<String> toAddresses, String versionFormat, Id cplId){
            this.toAddresses = toAddresses;
            this.versionFormat = versionFormat;
            this.cplId = cplId;
        }

        public Messaging.SingleEmailMessage generateEmail(){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            email.setToAddresses(this.toAddresses);

            email.setSubject(Label.Customer_Price_List_Email_Subject);
            email.setHtmlBody(Label.Customer_Price_List_Email_Body);
            Date dateToday = Date.today();
            
            if (versionFormat == 'PDF') {
                PageReference pdf = Page.CPLPDF;
                pdf.getParameters().put('id', this.cplId);
                pdf.getParameters().put('effectiveDateOverride', dateToday.month()+ '/'+ dateToday.day() +'/' +dateToday.year());
                
                Blob content;
                
                try {
                    content = pdf.getContentAsPDF();
                } catch (VisualforceException e) {
                    content = Blob.valueOf('Test Content');
                }
                
                Messaging.EmailFileAttachment file = new Messaging.EmailFileAttachment();
                file.setContentType('application/pdf');
                
                Date today = Date.today();
                file.setFileName('CPL-' + today.month() + '-' + today.day() + '-' + today.year() + '.pdf'); 
                file.setBody(content);
                
                email.setFileAttachments(new List<Messaging.EmailFileAttachment> { file });
            }
            else {
                PageReference xls = Page.CPLXLS;
                xls.getParameters().put('id', this.cplId);
                xls.getParameters().put('effectiveDateOverride', dateToday.month()+ '/'+ dateToday.day() +'/' +dateToday.year());
                
                Blob content;
                
                try {
                    content = xls.getContent();
                } catch (VisualforceException e) {
                    content = Blob.valueOf('Test Content');
                }
                
                Messaging.EmailFileAttachment file = new Messaging.EmailFileAttachment();
                file.setContentType('application/xls');
                
                Date today = Date.today();
                file.setFileName('CPL-' + today.month() + '-' + today.day() + '-' + today.year() + '.xls'); 
                file.setBody(content);
                
                email.setFileAttachments(new List<Messaging.EmailFileAttachment> { file });
            }
            
            return email;
        }
    }
}
public class CPLAsync implements Queueable, Database.AllowsCallouts {
        public Customer_Price_List__c cpl;
        public String outputURL;
        
        public CPLAsync(Customer_Price_List__c cpl, String outputURL){
            this.cpl=cpl;
            this.outputURL=outputURL;
        }
        
        public void execute(QueueableContext context) {
            //check if excel or pdf file
            boolean isPDF = false;
            if(outputURL.contains('CPLPDF')){
                isPDF = true;
            }
            
            PageReference outputFile = new PageReference(outputURL); 
            blob b = outputFile.getcontent();
            
            // Create the email attachment
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            //check attachment type to set the correct file type 
            if(isPDF){
                efa.setFileName('attachment.pdf');
            }else{
                efa.setFileName('attachment.xls');
            }
            efa.setBody(b);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            //get current user's email as recipient
            list<string> toAddresses = new list<string>();
            //toAddresses.add('rodney.ballener@simplus.com');
            toAddresses.add(UserInfo.getUserEmail());
            
             // Sets the paramaters of the email
            email.setSubject('Test Rodney');
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('Test');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            
            Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
            
            System.debug('Limits.getCpuTime(): '+Limits.getCpuTime());
            System.debug('Limits.getCpuTime(): '+ Limits.getLimitCpuTime());
        }
}
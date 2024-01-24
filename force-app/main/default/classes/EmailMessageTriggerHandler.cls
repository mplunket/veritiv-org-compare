public with sharing class EmailMessageTriggerHandler {

    public static void handleBeforeInsert(
        List<EmailMessage> emailMessageList, Map<Id,EmailMessage> emailMessageMap,
        List<EmailMessage> oldEmailMessageList, Map<Id,EmailMessage> oldEmailMessageMap
    ){
        //ignore trigger if email is coming from case notification.
        if(!CaseVacationEmailService.isRunning)
        {
            // Backlog-3434 : Limit processing to only EmailMessage records associated
            // with Cases (i.e. EmailMessage records with a ParentId) -- Enhanced Email
            // utilizes EmailMessage associated with other types of records, but uses
            // the RelatedToId field instead of ParentId
            List<EmailMessage> emailMessagesToProcess = new List<EmailMessage>();
            for(EmailMessage msg : emailMessageList){
                if(msg.ParentId != null){
                    emailMessagesToProcess.add(msg);
                }
            }
            EmailMessageServices.processEmailMessagesBeforeInsert(emailMessagesToProcess);
        }
    }

    public static void handleAfterInsert(
        List<EmailMessage> emailMessageList, Map<Id,EmailMessage> emailMessageMap,
        List<EmailMessage> oldEmailMessageList, Map<Id,EmailMessage> oldEmailMessageMap
    ){
        // Backlog-3434 : Limit processing to only EmailMessage records associated
        // with Cases (i.e. EmailMessage records with a ParentId) -- Enhanced Email
        // utilizes EmailMessage associated with other types of records, but uses
        // the RelatedToId field instead of ParentId
        List<EmailMessage> emailMessagesToProcess = new List<EmailMessage>();
        for(EmailMessage msg : emailMessageList){
            if(msg.ParentId != null){
                emailMessagesToProcess.add(msg);
            }
        }
        EmailMessageServices.processCaseFirstEmailResponseTracking(emailMessagesToProcess);
    }

    public static void handleBeforeDelete(List<EmailMessage> emlMesgs){
        Id profileId=userinfo.getProfileId();
        Map<id, string> emailMsgVsCaseRecordType = new Map<id, String>();
        for(emailMessage emsg: [Select id, parent.recordType.Name from emailMessage where id in: emlMesgs]){
            emailMsgVsCaseRecordType.put(emsg.id, emsg.parent.recordType.Name);
        }
        
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        for(EmailMessage em : emlMesgs){
            if( (profileName == 'CS - Lightning Console' || profileName == 'CS - Support Restricted - Lightning' || profileName == 'Training and Support - Lightning') &&
              emailMsgVsCaseRecordType.get(em.id) == 'Console CS - Lightning'
              ){
                em.addError('This email cannot be deleted. Please contact your manager for assistance.');
            }   
     }
        
    }
}
trigger copyEmailAttachmentToCase on Attachment (before insert) {
    
    AttachmentServices.processAttachments(Trigger.new);

}
trigger EmailMessageBeforeInsert on EmailMessage (before insert) { 
//   //ignore trigger if email is coming from case notification.
//      System.debug(LoggingLevel.ERROR,'Running Email Message Trigger');
//  if(!CaseVacationEmailService.isRunning)
//  {
//    EmailMessageServices.processEmailMessagesBeforeInsert(Trigger.new);
//      }
}
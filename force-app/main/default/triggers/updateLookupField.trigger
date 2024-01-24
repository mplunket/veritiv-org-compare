trigger updateLookupField on CA_Customer_Assessment__c (before insert, before update){
 Set<id> accIds = new Set<id>();
 for(CA_Customer_Assessment__c customerAssessment : trigger.new){
  if(customerAssessment.TP_Account__c != null){
   accIds.add(customerAssessment.TP_Account__c);
  }
 }
 if(accIds.size() > 0){
  Map<Id,Account> mapOfAccounts = new Map<Id,Account>([Select Primary_Sales_Rep_Name__c from Account where id in :accIds]);
  for(CA_Customer_Assessment__c customerAssessment : trigger.new){
   if(mapOfAccounts.containsKey(customerAssessment.TP_Account__c)){
    customerAssessment.Primary_Sales_Rep__c = mapOfAccounts.get(customerAssessment.TP_Account__c).Primary_Sales_Rep_Name__c;
   }
  }
 }
}
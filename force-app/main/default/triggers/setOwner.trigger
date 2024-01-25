trigger setOwner on Account_Plan__c (before insert) {
    List<Id> primarySalesRepList = new List<Id>();
    for(Account_Plan__c someAP : trigger.new){
        primarySalesRepList.add(someAP.Primary_Sales_Rep__c);
    }
    Map<Id,Primary_Sales_Rep__c> PSRs = new Map<Id, Primary_Sales_Rep__c>([SELECT Name, Network_ID__c FROM Primary_Sales_Rep__c WHERE Id IN :primarySalesRepList]);
    List<String> psrNetworkIds = new List<String>();
    for(Primary_Sales_Rep__c psr : PSRs.values()){
        psrNetworkIds.add(psr.Network_ID__c);
    }
    List<User> salesRepUsers = [SELECT Name, Network_Id__c FROM User WHERE Network_Id__c IN :psrNetworkIds AND IsActive = true];
    Map<String, User> userMap = new Map<String, User>();
    for(User someUser : salesRepUsers){
        userMap.put(someUser.Network_Id__c.toLowerCase(),someUser);
    }
    for(Account_Plan__c someAP : trigger.new){
        try{
            someAP.OwnerId = userMap.get(PSRs.get(someAP.Primary_Sales_Rep__c).Network_ID__c.toLowerCase()).Id;
        } Catch(NullPointerException e){}
    }
}
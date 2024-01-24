trigger AIQAgreementLineSyncLEDS on zpl__ContractLineItem__c (after insert, after update, after delete) {
    
    Boolean hasToRun = false;
    String LSource = (Trigger.IsDelete ? Trigger.old.get(0).LineSource__c : Trigger.new.get(0).LineSource__c);

    String LSourcesStr = Test.isRunningTest() ? '' : (String) AIQZilliantConfiguration__c.getInstance().get('LineSourceSyncExclusions__c');
   
    List<String> LSourecExcls = new List<String>();
    if(LSourcesStr != null) LSourecExcls = LSourcesStr.trim().split(',');
    
    String UserStr = Test.isRunningTest() ? '' : (String) AIQZilliantConfiguration__c.getInstance().get('UserSyncExclusions__c');
    
    List<String> UserExcls = new List<String>();
    if(UserStr != null) UserExcls = UserStr.replaceAll('(\\r|\\n)+', ',').trim().split(',');

    Boolean syncFlag = Test.isRunningTest() ? true : (Boolean) AIQZilliantConfiguration__c.getInstance().get('runCLIZcloudSync__c');

    if(syncFlag &&
        ((
            (UserExcls.isEmpty() && !LSourecExcls.contains(LSource))
            ||(!UserExcls.contains(UserInfo.getUserName()) && LSourecExcls.isEmpty())
            ||(UserExcls.isEmpty() && LSourecExcls.isEmpty())
            ||(!UserExcls.contains(UserInfo.getUserName()) && !LSourecExcls.contains(LSource))
            ||(UserExcls.contains(UserInfo.getUserName()) && !LSourecExcls.contains(LSource))
            ||(!UserExcls.contains(UserInfo.getUserName()) && LSourecExcls.contains(LSource))
        ))
    )       
    {
        if(!Test.isRunningTest()){
            hasToRun = true;
        }        
    }

    if(hasToRun){
        zpf.GenericSynchronizedDomainObject.triggerHandler(new AIQ_SyncCLIFilter('zpl__ContractLineItem__c'), 'zpl__ContractLineItemId__c');
    }
    
    
}
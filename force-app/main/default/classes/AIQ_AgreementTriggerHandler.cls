public without sharing class AIQ_AgreementTriggerHandler {

    public static void validateAccount(List<Contract> contracts) {
        Contract c = contracts.get(0);
        if (c.RecordTypeId != null && c.RecordTypeId == Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(AIQ_Constants.CONTRACT_RT_PRICING_CONTRACT_DEV_NAME).getRecordTypeId()) {
            validateAccount();
        }
    }

    private static Map<Id,Account> getActAccts(Set<String> accountIDs){
        Map<Id,Account> actAccts = new Map<Id,Account>([
            SELECT Id, Acct_Status__c, Zilliant_Active__c, AccountNumber, Servicing_Division__r.Division_Code__c, Legacy_System_Cd__c, OwnerId,
            (
                SELECT Id, AccountId FROM Contracts WHERE RecordType.Name = 'Pricing Contract'
            )
            FROM Account WHERE Id IN: accountIDs AND Zilliant_Active__c='AI' 
        ]);
        return actAccts;
    }

    private static void validateAccount()
    {
        Map<Contract, String> newAgrMap = new  Map<Contract, String>();
        for(Contract agreemnet: (List<Contract>) Trigger.New)
        {
            newAgrMap.put(agreemnet, agreemnet.AccountID); 
        }
        
        Set<String> accountIDs = new Set<String>();
        accountIDs.addAll(newAgrMap.values());

        Map<Id,Account> actAccts = getActAccts(accountIDs);
        
        for (Contract newAgr : newAgrMap.keySet())
        {
            if(actAccts.containsKey(newAgr.AccountId)){
                Account acct = actAccts.get(newAgr.AccountId);
                if(acct.Contracts.isEmpty()){
                    if(String.isBlank(newAgr.zpl__ContractId__c)){
                        newAgr.zpl__ContractId__c = (acct.Legacy_System_Cd__c=='03'?'SW':acct.Legacy_System_Cd__c)+
                        //+acct.Servicing_Division__r.Division_Code__c+
                        +acct.AccountNumber;
                    }
                }else{
                    newAgr.addError('There Is Pricing Contract Already!');
                }
            }else{
                newAgr.addError('The Account Is Inactive!');
            }
        }
    }

    public static void updateAccount(List<Contract> agreements)
    {
        Set<String> accountIDs = new Set<String>();
        for(Contract agreemnet: agreements)
        {
            accountIDs.add(agreemnet.AccountID);
        }

        List<Contract> agrsAll = new List<Contract>();

        for(List<Contract> agrsBatch : [SELECT Id, AccountId FROM Contract WHERE AccountId in: accountIDs AND RecordType.Name =: AIQ_Constants.CONTRACT_RT_PRICING_CONTRACT])
        {
            agrsAll.addAll(agrsBatch);
        }

        Map<Id, Integer> acctArgsCountMap = new Map<Id, Integer>();

        for (Contract agr: agrsAll)
        {
            if(!acctArgsCountMap.containsKey(agr.AccountId))
            {
                acctArgsCountMap.put(agr.AccountId, 1);
            } else {
                Integer currentInt = acctArgsCountMap.get(agr.AccountId)+1;
                acctArgsCountMap.put(agr.AccountId, currentInt);
            }
        }

        List<Account> AcctsToUpdate = [SELECT Id, Name, Has_Agreement__c FROM Account WHERE Id in: accountIDs];
        List<Account> updatedAccts = new List<Account>();
        for (Account currAcct: AcctsToUpdate)
        {
            Integer CurrAcctAgrCount =  acctArgsCountMap.get(currAcct.Id);
            system.debug('CurrAcctAgrCount = ' + CurrAcctAgrCount);

            if(CurrAcctAgrCount>0)
            {
                if (currAcct.Has_Agreement__c!=true)
                {
                    currAcct.Has_Agreement__c = true;
                    updatedAccts.add(currAcct);
                }
            } else
            {
                if (currAcct.Has_Agreement__c!=false)
                {
                    currAcct.Has_Agreement__c = false;
                    updatedAccts.add(currAcct);
                }
            }

        }


        Map<Id, Account> updatedAcctsMap = new Map<Id, Account>();
        for(Account updAcct : updatedAccts)
        {
            updatedAcctsMap.put(updAcct.Id, updAcct);
        }

        if(updatedAccts.size()>0)
        {
            try{
                Database.SaveResult[] upsList =  Database.update(updatedAccts, false);

                /** Error processing */
                for(Database.SaveResult upsItem : upsList)
                {
                    if(! upsItem.isSuccess()){
                        for(Database.Error err : upsItem.getErrors())
                        {
                            updatedAcctsMap.get(upsItem.getId()).addError(err.getMessage());
                        }
                    }
                }

            } catch(Exception e)
            {
                system.debug('Contract After Trigger Error: ' + e.getMessage() );
                throw new AurahandledException(e.getMessage());
            }

        }

    }


   public static Boolean isPricingContractRecordType(List<Contract> contracts) {
        Contract c = contracts.get(0);
        return c.RecordTypeId != null && c.RecordTypeId == Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(AIQ_Constants.CONTRACT_RT_PRICING_CONTRACT_DEV_NAME).getRecordTypeId();
    }

    public static void runSyncDown() {
        Boolean hasToRun = false;
        if (!Test.isRunningTest()) {
            hasToRun = (Boolean) AIQZilliantConfiguration__c.getInstance().get(AIQ_Constants.CONTRACT_EXTERNAL_ID);
        }
        if (hasToRun) zpf.GenericSynchronizedDomainObject.triggerHandler('zpl__ContractId__c');
    }
}
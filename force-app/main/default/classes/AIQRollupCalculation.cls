public class AIQRollupCalculation {
    
    public class AIQRollupCalculationException extends Exception{}

    private List<AggregateResult> aggrActiveLines = new List<AggregateResult>();
    private List<AggregateResult> aggrExpiringLines = new List<AggregateResult>();
    private List<AggregateResult> aggrExpiringRebates = new List<AggregateResult>();
    private List<Contract> contractsToUpdate = new List<Contract>();
    private List<Contract> updatedContracts = new List<Contract>();
    private Map<Id,Contract> updatedContractsMap = new Map<Id,Contract>();
    //private Map<Id,Id> contractSalesRepMap = new Map<Id,Id>();
    
    public AIQRollupCalculation (List<Contract> contracts) 
    {
        this.contractsToUpdate = contracts;
    }
    
    public List<Contract> getUpdatedContracts() 
    {
        updateScoreRevenue();
        updateExpiringLinesCount();
        updateExpiringRebatesCount();
        this.updatedContracts = updatedContractsMap.values();
        for(Contract contr : updatedContracts){
            contr.RollupCalculationError__c=null;
            contr.RollupCalculationAttempt__c=Datetime.now();
        }
        return updatedContracts;
    }

    public void saveUpdatedContracts() 
    {
        this.getUpdatedContracts();
        if(this.updatedContracts.size()>0) {
            /**
             * tolarates partial success
             */
            Database.Saveresult[] srList = Database.update(this.updatedContracts, false);
            Contract[] errorLines = new List<Contract>();

            Set<String> errorMessages = new Set<String>();
            Set<String> errorLineIds = new Set<String>();
            for (Integer i = 0; i < updatedContracts.size(); i++) {
                Database.SaveResult sr = srList[i];
                Contract record = updatedContracts[i];

                if(!sr.isSuccess()){
                    errorLineIds.add(record.Id);
                    errorMessages.add(sr.getErrors().get(0).getMessage().left(255));
                }
            }

            if(!errorMessages.isEmpty()){
                throw new AIQRollupCalculationException('Errors received: '+String.valueOf(errorMessages).replace('{', '[').replace('}', '] ') +
                    + ' for lines with Id '+String.valueOf(errorLineIds).replace('{', '[').replace('}', '] ').left(1000));
            }
        }   
    }

    /*
    public Map<Id,Id> getScoreChangingContracts()
    {
    	return this.contractSalesRepMap;
    }
    */

    /**  Contract/Revenue score calculation  */
    private void updateScoreRevenue()
    {   
        for(List<AggregateResult> aggrActiveLinesBatch : [SELECT zpl__Contract__c
                                                          , zpl__Contract__r.Account.Primary_Sales_Rep_Name__c
                                                          , sum(X12MonthSalesVolume__c) revenue
                                                          , sum(ScoreHeaderNumerator__c)  scoreNumerator 
                                                          FROM zpl__ContractLineItem__c 
                                                          WHERE zpl__Contract__c IN (
                                                              SELECT Id FROM Contract 
                                                              WHERE id in :this.contractsToUpdate
                                                          ) AND RecordType.Name = 'Active' 
                                                          AND SupersededDate__c=null 
                                                          AND zpl__EffectiveDate__c <=: Date.today() 
                                                          GROUP BY zpl__Contract__c
                                                         , zpl__Contract__r.Account.Primary_Sales_Rep_Name__c
                                                         ]
           )
        {
            aggrActiveLines.addAll(aggrActiveLinesBatch);
        }
        
        for(AggregateResult ar : aggrActiveLines)
        {        
        	Decimal cntrScore = 0;
        	Long rCntrScore = 0;
            Decimal revenue = 0; 
            if((Decimal) ar.get('revenue')>0) { cntrScore = (Decimal) ar.get('scoreNumerator')/ (Decimal) ar.get('revenue'); }
            if(cntrScore>0) { rCntrScore = cntrScore.round(); }
            if((Decimal) ar.get('revenue')>0) { revenue = (Decimal) ar.get('revenue'); }
            
            ID contractId = (ID) ar.get('zpl__Contract__c');
            //ID salesRepId = (ID) ar.get('zpl__Contract__r.Account.Primary_Sales_Rep_Name__c');
            //contractSalesRepMap.put(contractId,salesRepId);
            
            Contract contr = new Contract();
            
            if(updatedContractsMap.containsKey(contractId)){
				contr = updatedContractsMap.get(contractId);
                contr.X12MonthsRevenue__c = revenue;
                contr.score__c = rCntrScore;
            } else {
                contr.id = contractId; 
                contr.X12MonthsRevenue__c = revenue;
                contr.score__c = rCntrScore;
                updatedContractsMap.put(contr.id, contr);
            }
               
        }                
    }
    
    private void updateExpiringLinesCount()
    {
        for(List<AggregateResult> aggrExpiringLinesBatch : [SELECT zpl__Contract__c, sum(ExprContractLine__c) expLineCount
                                                            FROM zpl__ContractLineItem__c 
                                                            WHERE zpl__Contract__c IN (
                                                                SELECT Id FROM Contract 
                                                                WHERE id in :this.contractsToUpdate
                                                            ) AND RecordType.Name IN ('Active', 'Inactive')  // we need to cover the use case when lines become inactive 
                                                            AND DisallowCampaignsThroughDate__c >=: Date.today().addDays(-16) 
                                                            AND DisallowCampaignsThroughDate__c <=: Date.today().addDays(45) 
                                                            GROUP BY zpl__Contract__c]
           )
        {
            aggrExpiringLines.addAll(aggrExpiringLinesBatch);
        }
        
        for(AggregateResult ar : aggrExpiringLines)
        {              
            ID contractId = (ID) ar.get('zpl__Contract__c');
            
            Contract contr = new Contract();
            
            if(updatedContractsMap.containsKey(contractId))
            {
				contr = updatedContractsMap.get(contractId);
                contr.ExpContractLinesCount__c = (Decimal) ar.get('expLineCount');
            } else 
            {
                contr.id = contractId; 
                contr.ExpContractLinesCount__c = (Decimal) ar.get('expLineCount');
                updatedContractsMap.put(contr.id, contr);
            }
        }       
    }
    
    private void updateExpiringRebatesCount()
    {
        for(List<AggregateResult> aggrExpiringRebatesBatch : [SELECT zpl__Contract__c, sum(ExprRebateLine__c) expRebateCount
                                                              FROM zpl__ContractLineItem__c 
                                                              WHERE zpl__Contract__c IN (
                                                                  SELECT Id FROM Contract 
                                                                  WHERE id in :this.contractsToUpdate
                                                              ) AND RecordType.Name IN ('Active', 'Inactive')  // we need to cover the use case when lines become inactive 
                                                              AND ExternalCostDeviationDate__c >=: Date.today().addDays(-16) 
                                                              AND ExternalCostDeviationDate__c <=: Date.today().addDays(45) 
                                                              GROUP BY zpl__Contract__c]
           )
        {
            aggrExpiringRebates.addAll(aggrExpiringRebatesBatch);
        }
        
        for(AggregateResult ar : aggrExpiringRebates)
        {              
            ID contractId = (ID) ar.get('zpl__Contract__c');
            
            Contract contr = new Contract();
            
            if(updatedContractsMap.containsKey(contractId))
            {
				contr = updatedContractsMap.get(contractId);
                contr.ExpRebatesCount__c = (Decimal) ar.get('expRebateCount');
            } else 
            {
                contr.id = contractId; 
                contr.ExpRebatesCount__c = (Decimal) ar.get('expRebateCount');
                updatedContractsMap.put(contr.id, contr);
            }
        }       
    }
    
    /*
    public void updateSalesRepScore(List<String> salesRepIDs)
    {
         for(AggregateResult ar : [SELECT Account.Primary_Sales_Rep_Name__c, sum(X12MonthsRevenue__c) revenue, sum(aiqAgrmntScoreNumerator__c) scoreNumerator
                                                          FROM Contract
                                                          WHERE Account.Primary_Sales_Rep_Name__c IN: salesRepIDs
                                                   		  AND RecordType.Name = 'PricingContract' 
                                                          GROUP BY Account.Primary_Sales_Rep_Name__c]
           )
        {
           Primary_Sales_Rep__c psr = new Primary_Sales_Rep__c();
           psr.Id = (ID) ar.get('Account.Primary_Sales_Rep_Name__c');
            
           Decimal cntrScore = 0;
           Long rCntrScore = 0;
           if((Decimal) ar.get('revenue')>0) { cntrScore = (Decimal) ar.get('scoreNumerator')/ (Decimal) ar.get('revenue'); }
           if(cntrScore>0) { rCntrScore = cntrScore.round(); }    
               
           psr.aiqSalesScore__c = rCntrScore;   
        }
        
    }
	*/
    
}
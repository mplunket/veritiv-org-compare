global class Batch_CalculateDirectReports implements Database.Batchable<SObject>, Database.Stateful
{
    global final String query;
    
    global Batch_CalculateDirectReports(String query)
    {
        this.query = query;
    }
        
    global Database.querylocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, Sobject[] scope)
    {   
        List<Primary_Sales_Rep__c> psrs2u = new List<Primary_Sales_Rep__c>();
        
        Set<Id> psrIds = new Set<Id>();
        for(Sobject sobj : scope)
        {
            Primary_Sales_Rep__c psr = (Primary_Sales_Rep__c)sobj;
            psrIds.add(psr.Id);
        }
        
        //[select Id, Reports_To__c from Primary_Sales_Rep__c where Reports_To__c in :psrIds];
        List<Primary_Sales_Rep__c> directReports = PrimarySalesRepModel.getDirectReports(psrIds);
                                                    
        Map<Id, List<Primary_Sales_Rep__c>> psr2drs = new Map<Id, List<Primary_Sales_Rep__c>>();
        
        // Pull direct reports, add to list in Map
        for(Primary_Sales_Rep__c dr : directReports)
        {
            if(!psr2drs.containsKey(dr.Reports_To__c))
                psr2drs.put(dr.Reports_To__c, new List<Primary_Sales_Rep__c>());
                
            List<Primary_Sales_Rep__c> existingDrs = psr2drs.get(dr.Reports_To__c);
            existingDrs.add(dr);
            psr2drs.put(dr.Reports_To__c, existingDrs);
        }
        
        for(Id psrId : psr2drs.keySet())
        {   
            Primary_Sales_Rep__c upsr = new Primary_Sales_Rep__c(Id=psrId);
            upsr.of_Direct_Reports__c = psr2drs.get(psrId).size();
            psrs2u.add(upsr);       
        }
        
        for(Id psrId : psrIds)
        {
            Boolean isBeingUpdated = false;
            for(Primary_Sales_Rep__c psr : psrs2u)
            {
                if(psr.Id == psrId)
                    isBeingUpdated = true;
            }
            if(!isBeingUpdated)
                psrs2u.add(new Primary_Sales_Rep__c(Id=psrId, of_Direct_Reports__c=0));
        }
        
        update psrs2u;
        
    }
    
    global void finish(Database.BatchableContext bc)
    {   
        
    }

    
}
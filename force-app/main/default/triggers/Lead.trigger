trigger Lead on Lead (before insert, before update, after update, after insert)
{   
    
    set<String> setVerticalName = new set<String>();
    Map<String,Verticals__c> mapNameToVertical = new Map<String,Verticals__c>();
    
    if (Trigger.isUpdate && Trigger.isBefore) {
        LeadServices.updatePrimarySalesRepFromOwnerId (Trigger.oldMap, Trigger.newMap);
        Map<Id,Lead> updatedLeads = LeadServices.getLeadWithChangedOwenrs(Trigger.newMap , Trigger.oldMap); 
        LeadServices.updateCurrencyCode(updatedLeads);
        LeadServices.verticalUpdate( LeadServices.filterLeadsWithChangedIndustries( Trigger.New, Trigger.oldMap ) );
        
        // Added by Sujitha
        
        
        for(Lead leadRecd : Trigger.new)
        {
            if(leadRecd.Vertical__c!=null)
                setVerticalName.add(leadRecd.Vertical__c);
            
        }
        
        List<Verticals__c> listVerticals = new List<Verticals__c>([Select Id,Name from Verticals__c where Name IN : setVerticalName]);
        
        if(listVerticals!=null && listVerticals.size()>0)
        {
            for(Verticals__c verticalRecd : listVerticals)
            {
                mapNameToVertical.put(verticalRecd.Name,verticalRecd);
            }
        }
        
        
        for(Lead leadRecd : Trigger.new)
        {
            if(leadRecd.Vertical__c!=null)
            {
                if(mapNameToVertical.containsKey(leadRecd.Vertical__c))
                {
                    leadRecd.Verticals__c = mapNameToVertical.get(leadRecd.Vertical__c).id;
                }
            }
        }

        LeadServices.backupAndRestoreDnBQueryFields(Trigger.oldMap, Trigger.newMap);
        
    }
    
    if (Trigger.isUpdate && Trigger.isAfter) {
        
        // Added by Simplus 07/13/2020
        if(LeadServices.checkRecursive())
        {  
            LeadServices.calcDuration (Trigger.oldMap, Trigger.newMap);
        }
        //
        
        List<Lead> convertedLeads = LeadServices.getConvertedLeads(trigger.new, trigger.old);
        LeadServices.convertPSR(convertedLeads);
        LeadServices.setLeadVerticals( LeadServices.filterLeadsWithChangedVerticals( Trigger.New, Trigger.oldMap ) );   
        
    }
    
    if (Trigger.isInsert && Trigger.isBefore) {
        LeadServices.updatePrimarySalesRepFromOwnerId(Trigger.new);
        LeadServices.verticalUpdate(trigger.new);  
        LeadServices.backupDnBQueryFields(Trigger.new);
		//removed normalizeUnitedStatesLeadCountry

        // Added by Sujitha
        
        
        for(Lead leadRecd : Trigger.new)
        {
            if(leadRecd.Vertical__c!=null)
                setVerticalName.add(leadRecd.Vertical__c);
            
        }
        
        List<Verticals__c> listVerticals = new List<Verticals__c>([Select Id,Name from Verticals__c where Name IN : setVerticalName]);
        
        if(listVerticals!=null && listVerticals.size()>0)
        {
            for(Verticals__c verticalRecd : listVerticals)
            {
                mapNameToVertical.put(verticalRecd.Name,verticalRecd);
            }
        }
        
        
        for(Lead leadRecd : Trigger.new)
        {
            if(leadRecd.Vertical__c!=null)
            {
                if(mapNameToVertical.containsKey(leadRecd.Vertical__c))
                {
                    leadRecd.Verticals__c = mapNameToVertical.get(leadRecd.Vertical__c).id;
                }
            }
        }
    }
    
    if (Trigger.isAfter && Trigger.isInsert) {
        LeadServices.setLeadVerticals( LeadServices.filterLeadsWithChangedVerticals( Trigger.New, Trigger.oldMap ) );
    }
}
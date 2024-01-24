public class LeadServices {
    
    public static final Boolean DEFERRED_OPT_STATUS = null;
    
    public static final String OPT_OUT_FIELD = 'HasOptedOutOfEmail';
    
    public static final Boolean DEFAULT_OPT_STATUS = false;
    
    public static Boolean processedMarketing = false;
    public static final Integer DB_SAVE_THRESHOLD = 90;
    
    public static final Id EloquaUserIdToOverride = [SELECT Id FROM User WHERE Name = 'Eloqua Marketing' LIMIT 1].Id;
    public static boolean firstRunOfLeadFieldBackupTrigger = true;   
    
    // Added by Simplus:
    // [START]
    
    private static boolean run = true;
    public static boolean checkRecursive(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    
    public static void calcDuration(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        List<String> leadID = new List<String>();
        List<Id> userID = new List<Id>();
        List<Id> groupID = new List<Id>();
        Boolean isStatusChanged = false;
        for(Lead updatedLead : newMap.values()){
            if(updatedLead.status != oldMap.get(updatedLead.id).status){
                leadID.add(updatedLead.id);
                String sobjectType = updatedLead.OwnerId.getSObjectType().getDescribe().getName();
                if (sobjectType == 'User'){
                    userID.add(updatedLead.OwnerId);
                }else if(sobjectType == 'Group'){
                    groupID.add(updatedLead.OwnerId);
                }
                isStatusChanged = true;
            }
        }
        if(isStatusChanged){
            Map<Id, List<Lead_Duration__c>> durationMap = new Map<Id, List<Lead_Duration__c>>();
            Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name From User WHERE Id IN: userID]);
            Map<Id, Group> groupMap = new Map<Id, Group>([SELECT Id, Name From Group WHERE Id IN: groupID AND Type = 'Queue']);
            List<Lead_Duration__c> newLDList = new List<Lead_Duration__c>();
            for(Lead_Duration__c ld : [SELECT id, From__c, Until__c, Lead_Owner__c, Parent__c, From_Status__c, Status__c FROM Lead_Duration__c WHERE Parent__c IN: leadID ORDER BY CreatedDate DESC]){
                if(!durationMap.keySet().contains(ld.Parent__c)){
                    List<Lead_Duration__c> tempList = new List<Lead_Duration__c>();
                    tempList.add(ld);
                    durationMap.put(ld.Parent__c, tempList);
                }
                else{
                    List<Lead_Duration__c> tempList = new List<Lead_Duration__c>();
                    tempList = durationMap.get(ld.Parent__c);
                    tempList.add(ld);
                    durationMap.put(ld.Parent__c, tempList);
                }
            }
            for(Lead l : newMap.values()){
                if(durationMap.get(l.id) == null || durationMap.get(l.id).isEmpty()){
                    Lead_Duration__c ld = new Lead_Duration__c();
                    ld.From__c = oldMap.get(l.id).createdDate;
                    ld.Until__c = DateTime.now();
                    ld.Lead_Owner__c = (userMap == null || !userMap.keySet().contains(l.OwnerId)  
                                        ? groupMap.get(l.OwnerId).Name
                                        : userMap.get(l.OwnerId).Name);
                    ld.Parent__c = l.id;
                    ld.From_Status__c = oldMap.get(l.id).status;
                    ld.Status__c = l.Status;
                    newLDList.add(ld);
                }
                else{
                    Lead_Duration__c ld = new Lead_Duration__c();
                    ld.From__c = durationMap.get(l.id)[0].Until__c;
                    ld.Until__c = DateTime.now();
                    ld.Lead_Owner__c = (userMap == null || !userMap.keySet().contains(l.OwnerId)  
                                        ? groupMap.get(l.OwnerId).Name
                                        : userMap.get(l.OwnerId).Name);
                    ld.Parent__c = l.id;
                    ld.From_Status__c = oldMap.get(l.id).status;
                    ld.Status__c = l.Status;
                    newLDList.add(ld);
                }
            }
            Insert newLDList;
        }
    }
    // [END]
    
    public static Map<Id,Lead> getLeadWithChangedOwenrs(Map<Id,Lead> newLeads , Map<Id,Lead> oldLeads)
    {
        Map<Id,Lead> updatedLeads = new Map<Id,Lead>();
        
        for(Lead newLead : newLeads.values())
        {
            Lead oldLead = oldLeads.get(newLead.Id);
            if(newLead.OwnerId != oldLead.OwnerId)
            {
                updatedLeads.put(newLead.Id , newLead);
            }
        }
        return updatedLeads;
    }
    
    public static void updateCurrencyCode(Map<Id,Lead> updatedLeads)
    {  
        Set<Id> userIds = new Set<Id>();
        for(Lead theLead :updatedLeads.values() )
        {
            userIds.add(theLead.OwnerId);
        }
        
        Map<Id,User> allUsers = new Map<Id,User>([SELECT Id, DefaultCurrencyIsoCode FROM User WHERE Id IN:userIds]);
        
        for(Lead theLead : updatedLeads.values())
        {
            if( allUsers.get(theLead.OwnerId) != null )
                theLead.CurrencyIsoCode = allUsers.get(theLead.OwnerId).DefaultCurrencyIsoCode;
        }
    }
    
    public static List<Lead> getConvertedLeads(List<Lead> newLeads, List<Lead> oldLeads){
        List<Lead> convertedLeads = new List<Lead>();
        for(Integer i=0;i<newLeads.size();i++){
            if(newLeads[i].isConverted && !oldLeads[i].isConverted){
                convertedLeads.add(newLeads[i]);    
            }
        }
        return convertedLeads;
    }
    
    public static void convertPSR(List<Lead> convertedLeads){
        if(convertedLeads.isEmpty()) return;
        
        List<Opportunity>  opps = new List<Opportunity>();
        for(Lead lead : convertedLeads){
            opps.add(new Opportunity(   Id = lead.ConvertedOpportunityId, 
                                     Primary_Sales_Rep_Name__c = lead.Primary_Sales_Rep__c));    
        }
        
        try{
            update opps;    
        }catch (DmlException e){
            Opportunity errorOp = opps.get(e.getDmlIndex(0));
            errorOp.addError(e);
        }
        
    }
    
    public static void verticalUpdate (List<Lead> leadsToUpdate){
        if(leadsToUpdate.isEmpty()) return;
        Map<String,Industry_to_Vertical_Custom_Setting__c> verticalMappingSettings = Industry_to_Vertical_Custom_Setting__c.getAll();
        for(Lead lead : leadsToUpdate){
            // Backlog#1333  SE - remove logic from Lead Trigger that pushes Industry to Ver 
            //  if (Lead.Industry!=null && verticalMappingSettings.containsKey( lead.Industry ))
            
            //  lead.Vertical__c = verticalMappingSettings.get(lead.Industry).Vertical__c;
        }
    }
    
    public static List<Lead> filterLeadsWithChangedIndustries( List<Lead> incomingLeads, Map<Id, Lead>oldLeadIdToOldLead )
    {
        
        List<Lead> industryName = new List<Lead>();
        
        //For All Leads that were sent to our trigger
        for(Lead incomingLead : incomingLeads )
        {
            //Change conditions
            // 1. Vertical is now being set
            // 2. Vertical is being changed
            
            Boolean isChanged;
            Boolean isInsert = oldLeadIdToOldLead == null;
            Lead oldLead = isInsert ? null : oldLeadIdToOldLead.get( incomingLead.Id);
            
            isChanged = (( isInsert && incomingLead.Industry != null )
                         ||( !isInsert && oldLead.Industry != incomingLead.Industry ));
            
            if( isChanged )
                industryName.add( incomingLead );
        }
        
        return industryName;
    }
    
    public static Map<String, List<Lead>> filterLeadsWithChangedVerticals( List<Lead> incomingLeads, Map<Id, Lead>oldLeadIdToOldLead )
    {
        
        Map<String, List<Lead>> verticalNameToLeadList = new Map<String, List<Lead>>();
        
        //For All Leads that were sent to our trigger
        for(Lead incomingLead : incomingLeads )
        {
            //Change conditions
            // 1. Vertical is now being set
            // 2. Vertical is being changed
            
            Boolean isChanged;
            Boolean isInsert = oldLeadIdToOldLead == null;
            Lead oldLead = isInsert ? null : oldLeadIdToOldLead.get( incomingLead.Id);
            
            isChanged = (( isInsert && incomingLead.Vertical__c != null )
                         ||( !isInsert && oldLead.Vertical__c != incomingLead.Vertical__c ));
            
            if( isChanged )
            {
                
                if(!verticalNameToLeadList.containsKey( incomingLead.Vertical__c ))
                {
                    verticalNameToLeadList.put( incomingLead.Vertical__c, new List<Lead> { incomingLead } );
                }
                else
                {
                    verticalNameToLeadList.get( incomingLead.Vertical__c ).add( incomingLead );
                }
                
                
            }
        }
        
        return verticalNameToLeadList;
    }
    
    public static void setLeadVerticals( Map<String, List<Lead>> verticalNameToLeadList )
    {
        
        
        List<Lead> LeadsToUpdate = new List<Lead>();
        
        if( !verticalNameToLeadList.isEmpty() )
        {
            //Clear out all the lookup fields in leads which have the Vertical__c set to null
            if(verticalNameToLeadList.containsKey(null))
            {
                for(Lead LeadToUpdate : verticalNameToLeadList.get( null ))
                {
                    Lead newLeadToUpdate = new Lead(Id = LeadToUpdate.id, Vertical_Page__c = null);
                    LeadsToUpdate.add( newLeadToUpdate );
                }
            }
            
            for( Verticals__c verticalsFound : [SELECT Id, Name FROM Verticals__c WHERE Name in :verticalNameToLeadList.keySet() ])
            {
                for( Lead LeadToUpdate : verticalNameToLeadList.get( verticalsFound.Name ))
                {
                    Lead newLeadToUpdate = new Lead(Id = LeadToUpdate.id, Vertical_Page__c = verticalsFound.id);
                    LeadsToUpdate.add( newLeadToUpdate );
                }
            }
        }
        
        if( !LeadsToUpdate.isEmpty() )
            update LeadsToUpdate;
    }   
    
    public static void updatePrimarySalesRepFromOwnerId(List<Lead> newLeads) {
        Set<Id> ownerIds = Pluck.ids(Schema.sObjectType.Lead.fields.OwnerId.getName(), newLeads);
        List<Primary_Sales_Rep__c> relatedReps = [SELECT Id, SF_UserId__c FROM Primary_Sales_Rep__c WHERE SF_UserId__c = :ownerIds];
        
        if (relatedReps.size() > 0) {
            Primary_Sales_Rep__c psr = relatedReps[0];
            for (Lead lead : newLeads) {
                if(lead.LeadSource != 'MI') {
                    lead.Primary_Sales_Rep__c = psr.Id;
                }
            }
        }
    }
    
    public static void updatePrimarySalesRepFromOwnerId(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        Set<Id> ownerIds = Pluck.ids(Schema.sObjectType.Lead.fields.OwnerId.getName(), newMap);
        List<Primary_Sales_Rep__c> relatedReps = [SELECT Id, SF_UserId__c FROM Primary_Sales_Rep__c WHERE SF_UserId__c IN :ownerIds];
        
        Map<Id, Id> userIdsToPSRId = new Map<Id, Id>();
        for (Primary_Sales_Rep__c rep : relatedReps) {
            userIdsToPSRId.put(rep.SF_UserId__c, rep.Id);
        }
        
        for (Id leadId : newMap.keySet()) {
            Lead oldLead = oldMap.get(leadId);
            Lead updatedLead = newMap.get(leadId);
            
            if (oldLead.OwnerId != updatedLead.OwnerId) {
                if (userIdsToPSRId.containsKey(updatedLead.OwnerId)) {
                    updatedLead.Primary_Sales_Rep__c = userIdsToPSRId.get(updatedLead.OwnerId);
                }
            }
        }
    }
    
    public static void backupDnBQueryFields(List<Lead> newList) {
        for (Lead lead : newList) {
            lead.Phone_Initial__c = lead.Phone;
            lead.Website_Initial__c = lead.Website;
            
            lead.StreetInitial__c = lead.Street;
            lead.CityInitial__c = lead.City;
            lead.StateInitial__c = lead.State;
            lead.PostalCodeInitial__c = lead.PostalCode;
            lead.CountryInitial__c = lead.Country;
            
            lead.Is_Being_Updated_From_DnB__c = false;
        }
    }
    
    private static void updateNullInitialFields(Lead lead) {
        if (lead.Phone_Initial__c == null) {
            lead.Phone_Initial__c = lead.Phone;
        }
        
        if (lead.Website_Initial__c == null) {
            lead.Website_Initial__c = lead.Website;
        }
        
        if (lead.StreetInitial__c == null) {
            lead.StreetInitial__c = lead.Street;
        }
        
        if (lead.CityInitial__c == null) {
            lead.CityInitial__c = lead.City;
        }
        
        if (lead.StateInitial__c == null) {
            lead.StateInitial__c = lead.State;
        }
        
        if (lead.PostalCodeInitial__c == null) {
            lead.PostalCodeInitial__c = lead.PostalCode;
        }
        
        if (lead.CountryInitial__c == null) {
            lead.CountryInitial__c = lead.Country;
        }
    }
    
    /**
Run on before update to perform the "backup" and "restore" of the prospect address fields
*/
    public static void backupAndRestoreDnBQueryFields(Map<Id, Lead> oldMap, Map<Id, Lead> newMap) {
        if (firstRunOfLeadFieldBackupTrigger) {
            for (Lead lead : newMap.values()) {
                // Restore user input to D&B query fields when the sync is disabled
                if (!oldMap.get(lead.Id).Remove_DnB_Data__c && lead.Remove_DnB_Data__c) {
                    lead.Phone = lead.Phone_Initial__c;
                    lead.Website = lead.Website_Initial__c;
                    
                    lead.Street = lead.StreetInitial__c;
                    lead.City = lead.CityInitial__c;
                    lead.State = lead.StateInitial__c;
                    lead.PostalCode = lead.PostalCodeInitial__c;
                    lead.Country = lead.CountryInitial__c;
                    
                    List<Schema.FieldSetMember> fieldSet = Schema.SObjectType.Lead.fieldSets.DnB_Fields_to_Delete.getFields();
                    for (Schema.FieldSetMember field : fieldSet) {
                        if (field.getType() == Schema.DisplayType.Boolean) {
                            lead.put(field.getFieldPath(), false);
                        } else {
                            lead.put(field.getFieldPath(), null);
                        }
                    }
                } else {
                    if (!lead.Is_Being_Updated_From_DnB__c) {
                        if (lead.Phone != oldMap.get(lead.Id).Phone) {
                            lead.Phone_Initial__c = lead.Phone;
                        }
                        
                        if (lead.Website != oldMap.get(lead.Id).Website) {
                            lead.Website_Initial__c = lead.Website;
                        }
                        
                        if (lead.Street != oldMap.get(lead.Id).Street) {
                            lead.StreetInitial__c = lead.Street;
                        }
                        
                        if (lead.City != oldMap.get(lead.Id).City) {
                            lead.CityInitial__c = lead.City;
                        }
                        
                        if (lead.State != oldMap.get(lead.Id).State) {
                            lead.StateInitial__c = lead.State;
                        }
                        
                        if (lead.PostalCode != oldMap.get(lead.Id).PostalCode) {
                            lead.PostalCodeInitial__c = lead.PostalCode;
                        }
                        
                        if (lead.Country != oldMap.get(lead.Id).Country) {
                            lead.CountryInitial__c = lead.Country;
                        }   
                        
                    } else {
                        updateNullInitialFields(lead);					
                        lead.Is_Being_Updated_From_DnB__c = false;					
                    }
                }
            }
            
            firstRunOfLeadFieldBackupTrigger = false;
        }
    }
    
}
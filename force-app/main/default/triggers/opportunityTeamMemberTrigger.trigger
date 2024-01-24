// Notify Specialists when someone other than themselves adds them to the team 
trigger opportunityTeamMemberTrigger on OpportunityTeamMember (before insert,after insert, after update, after delete) {
    // BL-3647 - Move email logic to Flow
    if(trigger.isInsert && trigger.isBefore){
        set<Id> optIds = new Set<Id>();
        map<id,string> oppIDVsNameMap = new Map<Id,string>();
        set<id> ownerId = new set<id>();
        map<id, string> idToEmail = new map<id, string>();
        for(opportunityTeamMember optTeam: trigger.New){
            if(test.isRunningTest()){
                //if( optTeam.TeamMemberRole.contains('Specialist')){
                ownerId.add(optTeam.userId);
           // }
            }else if(optTeam.userId != userInfo.getUserId() && optTeam.TeamMemberRole.contains('Specialist')){
                ownerId.add(optTeam.userId);
            }
            
        }
        for(user u : [select id, email from user where id in: ownerId]){
            idToEmail.put(u.id, u.email);
        }
        
        for(opportunityTeamMember optTeam: trigger.New){
            optIds.add(optTeam.opportunityId);
        }
        
        if(optIds.size() > 0){
            
            for(opportunity op: [Select id, name from opportunity where id in:optIds ]){
                oppIDVsNameMap.put(op.Id,op.name);
            }
        }
        for(opportunityTeamMember optTeam: trigger.New){
            if(optTeam.TeamMemberRole != null){
            if(optTeam.userId != userInfo.getUserId() && optTeam.TeamMemberRole.contains('Specialist')){
                
                if(idToEmail != null){
                    
                    Messaging.reserveSingleEmailCapacity(2);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    list<string> emails = new list<string>();
                    emails.add(idToEmail.get(optTeam.userId));
                   //mail.setReplyTo(emails[0]);
                    mail.setToAddresses(emails);
                    mail.setSenderDisplayName('Salesforce ');
                    mail.setSubject('You have been assigned as a Specialist to an Opportunity');
                    mail.setPlainTextBody('Added to opportunity');
                    
                    string optyName = '';
                    if(oppIDVsNameMap.keyset().contains(optTeam.opportunityId)){
                        optyName = oppIDVsNameMap.get(optTeam.opportunityId);
                    }
                    
                    string htmlTxt = userinfo.getName() + ' assigned you as a specialist on the following opportunity <br/>' +optyName + ' '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+optTeam.opportunityId;             
                    mail.setHtmlBody(htmlTxt);
                    if(!test.isRunningTest()){
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    }
                    
                }
            }
        }
        }
    }
    
    // Backlog 01411-SE - Specialists for Corr and Equipment required at Stage 2
    // Updated according to BL-3647 -- Need to add Specialist Food and Specialist Cold Chain
    // so using multi-picklist that can be easily updated to track and account for roles
    // more easily

    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        
        List<String> teamRoles = OpportunityTeamMemberServices.getPicklistValues(Opportunity.Active_Sales_Team_Roles__c);
        
        Set<Id> oppIds = new Set<Id>();
        for(opportunityTeamMember otm: trigger.New){
            if((Trigger.isUpdate && teamRoles.contains(trigger.oldMap.get(otm.id).TeamMemberRole)) || teamRoles.contains(trigger.newMap.get(otm.id).TeamMemberRole)) {
            	if(trigger.isInsert || (trigger.oldMap.get(otm.id).TeamMemberRole != trigger.newMap.get(otm.id).TeamMemberRole)){
            		oppIds.add(otm.opportunityId);
            	}
            }
        }
        if(oppIds.size() > 0) {
			OpportunityTeamMemberServices.calculateActiveSalesTeamRoles(oppIds);
    	}
    }
    
    if(trigger.isAfter && trigger.isDelete) {
        List<String> teamRoles = OpportunityTeamMemberServices.getPicklistValues(Opportunity.Active_Sales_Team_Roles__c);
        
        Set<Id> oppIds = new Set<Id>();
        for(opportunityTeamMember otm: trigger.Old){
            if(teamRoles.contains(trigger.oldMap.get(otm.id).TeamMemberRole)) {
            	oppIds.add(otm.opportunityId);
            }
        }
        if(oppIds.size() > 0) {
			OpportunityTeamMemberServices.calculateActiveSalesTeamRoles(oppIds);
    	}
    }
   
}
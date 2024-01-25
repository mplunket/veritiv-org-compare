trigger UpdateAccountTeam on Ship_To__c (after insert, after update, after delete,before delete) {
    
    UpdateAccountTeamHelper.newShipTos = Trigger.new;
    UpdateAccountTeamHelper.oldShipTos = Trigger.old;
    UpdateAccountTeamHelper.newMapShipTos = Trigger.newMap;
    UpdateAccountTeamHelper.oldMapShipTos = Trigger.oldMap;
    
    if(!UpdateAccountTeamHelper.runTrigger){
        return;
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            
        }
        if(Trigger.isUpdate){
            
        }
        if(Trigger.isDelete){
            
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            UpdateAccountTeamHelper.createAccountTeamMember();
        }
        if(Trigger.isUpdate){
            UpdateAccountTeamHelper.createAccountTeamMember();
            UpdateAccountTeamHelper.removeAccountTeamMembersCheckUpdate();
        }
        if(Trigger.isDelete){
            UpdateAccountTeamHelper.removeAccountTeamMembersCheckDelete();
        }
    }
}
trigger User on User (after insert, after update, before insert, before update) {
    
    if (Trigger.isAfter){
        if ( Trigger.isUpdate )
        {
            UserService.updateOutOfOfficeShadowStatus( Trigger.New, Trigger.oldMap );
    
            Set<Id> usersToUpdate = new Set<Id>();
    
            for( User user : trigger.new )
            {
                User oldUser = trigger.oldMap.get( user.Id );
                
                if( UserService.userEmailsNamesHaveChanged( oldUser, user ))
                {
                    usersToUpdate.add( user.Id );
                }
            }
            
            if(!usersToUpdate.isEmpty()){
                if (System.isBatch()){
                    UserService.updateRelatedPSRs( usersToUpdate );
                }
                else {
                    UserService.updateRelatedPSRsFuture( usersToUpdate );
                }
            }
        }
    
        UserService.syncUsersToPSRsByNetwork( trigger.new, trigger.oldMap );
    }
    else if (Trigger.isBefore){
        
        UserService.processUserManagerChanges(trigger.new, trigger.oldMap );
        
    }
}
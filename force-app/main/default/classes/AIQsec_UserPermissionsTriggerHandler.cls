public with sharing class AIQsec_UserPermissionsTriggerHandler {
    
    public static void handleUserChange(List<User> usersNew, Map<id,User> usersOld){

        List<AIQZilliantPermissionsConfig__c> secConfigRecords = new List<AIQZilliantPermissionsConfig__c>(); 
        try{
            List<String> listOfColumns = new List<String>{
                'AssignmentGroupName__c'
                , 'AssignmentGroupType__c'
                , 'PermissionSetsToAssign__c'
                , 'PermissionSetsToUnassign__c'
            };
            
            String selectColumns = String.join(listOfColumns, ',');
            zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                .selectx(selectColumns)
                .fromx('AIQZilliantPermissionsConfig__c')
                .wherex(new zal.FieldCondition('IsActivated__c', zal.Operator.EQUALS, true));
            
            secConfigRecords = Database.query(soqlBuilder.toSoql());
        } catch(Exception e){
            throw new DmlException(e.getMessage()+ ', '+ e.getStackTraceString());
        }

        if (secConfigRecords.isEmpty()) {
            return;
        }

        Set<String> profileNames = new Set<String>();
        Set<String> roleNames = new Set<String>();

        for(AIQZilliantPermissionsConfig__c configRecord : secConfigRecords){

            if(configRecord.AssignmentGroupType__c=='Profile'){
                profileNames.add(configRecord.AssignmentGroupName__c);
            } else if (configRecord.AssignmentGroupType__c=='UserRole'){
                roleNames.add(configRecord.AssignmentGroupName__c);
            }
        }

        List<Profile> profiles = new List<Profile>();
        List<String> profileIds = new List<String>();

        if(! profileNames.isEmpty()){
            try{
                zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                    .selectx('Id, Name')
                    .fromx('Profile')
                    .wherex(new zal.SetCondition('Name', zal.Operator.INX, new List<String>(profileNames)));
                
                profiles = Database.query(soqlBuilder.toSoql());
                
                for(Profile p : profiles){
                    profileIds.add(p.id);
                    system.debug(p.id + ' - ' + p.Name);
                }

            }catch(Exception e){
                throw new QueryException(e.getMessage()+ ', '+ e.getStackTraceString());

            }
        }
        
        List<UserRole> roles = new List<UserRole>();
        List<String> roleIds = new List<String>();

        if(! roleNames.isEmpty()){
            try{
                zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                    .selectx('Id, Name')
                    .fromx('UserRole')
                    .wherex(new zal.SetCondition('Name', zal.Operator.INX, new List<String>(roleNames)));
                
                roles = Database.query(soqlBuilder.toSoql());
                
                for(UserRole r : roles){
                    roleIds.add(r.id);
                }
            }catch(Exception e){
                throw new QueryException(e.getMessage()+ ', '+ e.getStackTraceString());

            }
        }

        List<User> assignmentList = new List<User>();
        List<User> unassignmentList = new List<User>();

        for(User userNew : usersNew){

            /** skipping lines when Profile or Role has not changed and are not in the config */       
            if(usersOld!=null && ! usersOld.isEmpty()) {
                User userOld = usersOld.get(userNew.Id);
                system.debug('userNew.ProfileId ' + userNew.ProfileId);
                system.debug('userOld.ProfileId ' + userOld.ProfileId);
                system.debug('profileIds '+ profileIds);
                system.debug('new profile contained ' + profileIds.contains(userNew.ProfileId));
                system.debug('old profile contained ' + profileIds.contains(userOld.ProfileId));

                if(userOld != null) {
                    if(userNew.ProfileId != userOld.ProfileId && profileIds.contains(userOld.ProfileId)){
                        unassignmentList.add(userOld);
                    }

                    if(userNew.UserRoleId != userOld.UserRoleId && roleIds.contains(userOld.UserRoleId)){
                        unassignmentList.add(userOld);
                    }

                    if (userNew.ProfileId != userOld.ProfileId && profileIds.contains(userNew.ProfileId)){
                        assignmentList.add(userNew);
                    } 

                    if(userNew.UserRoleId != userOld.UserRoleId && roleIds.contains(userNew.UserRoleId)){
                        assignmentList.add(userNew);
                    }

                } else {
                    if(profileIds.contains(userNew.ProfileId) || roleIds.contains(userNew.UserRoleId)){
                        assignmentList.add(userNew);
                    } 
                }                
            }else {
                if(profileIds.contains(userNew.ProfileId) || roleIds.contains(userNew.UserRoleId)){
                     assignmentList.add(userNew);
                }
            }
        }
        
		system.debug('assignmentList ' + assignmentList);
        system.debug('unassignmentList ' + unassignmentList);
        

        if(! assignmentList.isEmpty() || ! unassignmentList.isEmpty()){
            try{
                AIQsec_PermissionSetManager manager = new AIQsec_PermissionSetManager();

                if(!unassignmentList.isEmpty()){
                    manager.unassignPermissions(unassignmentList);
                }
    
                if(!assignmentList.isEmpty()){
                    manager.assignPermissions(assignmentList);
                }
            }catch(Exception e){                
                if(e.getTypeName()=='AIQsec_PermissionSetManager.AIQPermissionConfigNotFoundException'){
                    system.debug(e.getMessage());
                    return;
                }
                throw e;

            }

        }
        
    }
}
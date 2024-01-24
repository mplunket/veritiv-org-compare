public with sharing class AIQsec_PermissionSetManager {
    public class AIQPermissionConfigNotFoundException extends Exception{}
    public class AIQPermissionGrantException extends Exception{}
    public class AIQPermissionRevokeException extends Exception{}
    
    @TestVisible
    private Map<String,Id> permissionSetsMap;
    @TestVisible
    private Map<Id,Map<String,List<Id>>> profileSecConfigMap;
    


    public AIQsec_PermissionSetManager() {
        this.permissionSetsMap = new Map<String,Id>();
        this.profileSecConfigMap = new Map<Id,Map<String,List<Id>>>();
        this.getConfigRecords();
    }


    private void getConfigRecords(){
        
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
            throw new QueryException(e.getMessage().trim()+ ', '+ e.getStackTraceString().trim());
        }

        if(secConfigRecords.isEmpty()){
            throw new AIQPermissionConfigNotFoundException('There Are No Permission Configurations');
        }

        Map<String,Map<String,List<String>>> profileSecConfigPure = new Map<String,Map<String,List<String>>>();
        Map<String,Map<String,List<String>>> roleSecConfigPure = new Map<String,Map<String,List<String>>>();

        Set<String> profileNames = new Set<String>();
        Set<String> roleNames = new Set<String>();
        Set<String> permSetNames = new Set<String>();

        for(AIQZilliantPermissionsConfig__c configRecord : secConfigRecords){
            
            String permSetsAdd = configRecord.PermissionSetsToAssign__c;
            String permSetsRemove = configRecord.PermissionSetsToUnassign__c;
			List<String> permSetsAddList = new List<String>();
            if(!String.isBlank(permSetsAdd)){
                permSetsAddList.addAll(permSetsAdd.replaceAll('(\\r|\\n)+', ',').split(','));
            }
            
            List<String> permSetsRemoveList = new List<String>();
            if(!String.isBlank(permSetsRemove)){
                permSetsRemoveList.addAll(permSetsRemove.replaceAll('(\\r|\\n)+', ',').split(','));
            }

            List<String> permSetsAddListPure = new List<String>();
            List<String> permSetsRemoveListPure = new List<String>();
            
            for(String strItem : permSetsAddList){
                permSetsAddListPure.add(strItem.trim());
            }

            for(String strItem : permSetsRemoveList){
                permSetsRemoveListPure.add(strItem.trim());
            }

            permSetNames.addAll(permSetsAddListPure);
            permSetNames.addAll(permSetsRemoveListPure);

            if(configRecord.AssignmentGroupType__c=='Profile'){
                profileSecConfigPure.put(configRecord.AssignmentGroupName__c, new Map<String,List<String>>{'Add'=>permSetsAddListPure,'Remove'=>permSetsRemoveListPure});
                profileNames.add(configRecord.AssignmentGroupName__c);
            } else if (configRecord.AssignmentGroupType__c=='UserRole'){
                roleSecConfigPure.put(configRecord.AssignmentGroupName__c, new Map<String,List<String>>{'Add'=>permSetsAddListPure,'Remove'=>permSetsRemoveListPure});
                roleNames.add(configRecord.AssignmentGroupName__c);
            }
        }

        if(permSetNames.isEmpty()){
            throw new AIQPermissionConfigNotFoundException('There Are No Permission Sets To Manage');
        }

        List<Profile> profiles = new List<Profile>();

        if(! profileNames.isEmpty()){
            try{
                zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                    .selectx('Id, Name')
                    .fromx('Profile')
                    .wherex(new zal.SetCondition('Name', zal.Operator.INX, new List<String>(profileNames)));
                
                profiles = Database.query(soqlBuilder.toSoql());
                system.debug('profiles '+profiles);
            }catch(Exception e){
                throw new QueryException(e.getMessage().trim()+ ', '+ e.getStackTraceString().trim());

            }
        }
        
        List<UserRole> roles = new List<UserRole>();

        if(! roleNames.isEmpty()){
            try{
                zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                    .selectx('Id, Name')
                    .fromx('UserRole')
                    .wherex(new zal.SetCondition('Name', zal.Operator.INX, new List<String>(roleNames)));
                
                roles = Database.query(soqlBuilder.toSoql());
            }catch(Exception e){
                throw new QueryException(e.getMessage().trim()+ ', '+ e.getStackTraceString().trim());

            }
        }


        List<PermissionSet> permSets = new List<PermissionSet>();
        //Map<String,Id> permSetsMap = new Map<String,Id>();

        if(! permSetNames.isEmpty()){
            try{
                zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                    .selectx('Id, Name, Label')
                    .fromx('PermissionSet')
                    .wherex(new zal.SetCondition('Label', zal.Operator.INX, new List<String>(permSetNames)));
                
                permSets = Database.query(soqlBuilder.toSoql());
                system.debug('permSets '+permSets);
                for(PermissionSet permSet : permSets){
                    this.permissionSetsMap.put(permSet.Label, permSet.Id);
                }

            }catch(Exception e){
                throw new QueryException(e.getMessage().trim()+ ', '+ e.getStackTraceString().trim());

            }
        }

        if(! profiles.isEmpty()){
            for(Profile p : profiles){
                
                List<String> permSetNamesToAdd = profileSecConfigPure.get(p.Name).get('Add');
                List<String> permSetNamesToRemove = profileSecConfigPure.get(p.Name).get('Remove');

                List<Id> permSetIdsToAdd = new List<Id>();
                List<Id> permSetIdsToRemove = new List<Id>();
                for(String  permSetName : permSetNamesToAdd){
                    permSetIdsToAdd.add(this.permissionSetsMap.get(permSetName));
                }
                for(String  permSetName : permSetNamesToRemove){
                    permSetIdsToRemove.add(this.permissionSetsMap.get(permSetName));
                }
                
                profileSecConfigMap.put(p.Id, new Map<String,List<Id>>{'Add'=>permSetIdsToAdd, 'Remove'=>permSetIdsToRemove});

                
                

            }
        }

        if(! roles.isEmpty()){
            for(UserRole r : roles){
                
                List<String> permSetNamesToAdd = roleSecConfigPure.get(r.Name).get('Add');
                List<String> permSetNamesToRemove = roleSecConfigPure.get(r.Name).get('Remove');

                List<Id> permSetIdsToAdd = new List<Id>();
                List<Id> permSetIdsToRemove = new List<Id>();
                for(String  permSetName : permSetNamesToAdd){
                    permSetIdsToAdd.add(this.permissionSetsMap.get(permSetName));
                }
                for(String  permSetName : permSetNamesToRemove){
                    permSetIdsToRemove.add(this.permissionSetsMap.get(permSetName));
                }
                
                profileSecConfigMap.put(r.Id, new Map<String,List<Id>>{'Add'=>permSetIdsToAdd, 'Remove'=>permSetIdsToRemove});

                
               
            }
            
        }
        for(Id profRol :  profileSecConfigMap.keySet()){
            system.debug(profRol + ' - '+ profileSecConfigMap.get(profRol));
        }
    }


    public void assignPermissions(List<User> users){

        /*
        // get the orders platform permission set license
        PermissionSetLicense[] license = [SELECT Id,MasterLabel FROM PermissionSetLicense WHERE MasterLabel = 'Orders Platform' LIMIT 1];
        
        //check is user already has license assigned
        PermissionSetLicenseAssign[] lassignments = [SELECT AssigneeId,PermissionSetLicenseId 
                                                    FROM PermissionSetLicenseAssign 
                                                    WHERE AssigneeId = :user.Id 
                                                    AND PermissionSetLicenseId = :license[0].Id LIMIT 1];
        */

        Set<Id> userIds = new Set<Id>();
        for(User usr : users){
            userIds.add(usr.id);
        }

        List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
        try{
            
            //check is user already has the permission set assigned            
            zal.AndCondition whereAndConditions = new zal.AndCondition();
            whereAndConditions.add(new zal.SetCondition('AssigneeId', zal.Operator.INX, new List<Id>(userIds)));
            whereAndConditions.add(new zal.SetCondition('PermissionSetId', zal.Operator.INX, new list<Id>(this.permissionSetsMap.values())));
            
            zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                    .selectx('Id, AssigneeId,PermissionSetId')
                    .fromx('PermissionSetAssignment')
                    .wherex(whereAndConditions);
            permSetAssignments = Database.query(soqlBuilder.toSoql());
        } catch(Exception e){
            throw new QueryException(e.getMessage().trim()+ ', '+ e.getStackTraceString().trim());
        }

        Map<Id,Map<Id,PermissionSetAssignment>> userPermSetAssinmentMap = new Map<Id,Map<Id,PermissionSetAssignment>>();
       
        for(PermissionSetAssignment psa : permSetAssignments){
            if(! userPermSetAssinmentMap.containsKey(psa.AssigneeId)){
                userPermSetAssinmentMap.put(psa.AssigneeId, new Map<Id,PermissionSetAssignment>{psa.PermissionSetId=>psa});
            }else {
                userPermSetAssinmentMap.get(psa.AssigneeId).put(psa.PermissionSetId,psa);
            }
        }

        List<PermissionSetAssignment> newPermissions = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> expiredPermissions = new List<PermissionSetAssignment>();

        for (User user : users)
        {
            if(user.IsActive){
                Set<Id> existingUsrPsa = new Set<Id>();
                if(!userPermSetAssinmentMap.isEmpty()){
                    Map<Id,PermissionSetAssignment> existingUsrPsaMap = userPermSetAssinmentMap.get(user.id);
                    if(existingUsrPsaMap!=null){
                        existingUsrPsa = existingUsrPsaMap.keySet();
                    }
                }

                Set<Id> permSetsToAdd = new Set<Id>();
                Set<Id> permSetsToRemove = new Set<Id>();

                if(profileSecConfigMap.containsKey(user.ProfileId)){
                    permSetsToAdd.addAll(profileSecConfigMap.get(user.ProfileId).get('Add'));
                    permSetsToRemove.addAll(profileSecConfigMap.get(user.ProfileId).get('Remove'));
                }

                
                if(profileSecConfigMap.containsKey(user.UserRoleId)){
                    permSetsToAdd.addAll(profileSecConfigMap.get(user.UserRoleId).get('Add'));
                    permSetsToRemove.addAll(profileSecConfigMap.get(user.UserRoleId).get('Remove'));
                }

                
                /*
                Set<Id> permSetsToAdd = new Set<Id>(permSetsToAddDirty);
                
                if(! permSetsToAddDirty.isEmpty() ){
                    for(Id psToAdd : permSetsToAddDirty){
                        if(!permSetsToRemove.contains(psToAdd)){
                            permSetsToAdd.add(psToAdd);
                        }
                    }
                }
                */

                
                if(! permSetsToRemove.isEmpty()){
                    for(Id psaToRemove : permSetsToRemove){
                        if(existingUsrPsa.contains(psaToRemove)){
                            expiredPermissions.add(userPermSetAssinmentMap.get(user.id).get(psaToRemove));
                        }
                    }
                }

                if(! permSetsToAdd.isEmpty()){
                    for(Id psaToAdd : permSetsToAdd){
                        if(! existingUsrPsa.contains(psaToAdd)){
                            PermissionSetAssignment newPsa = new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = psaToAdd);
                            newPermissions.add(newPsa);
                        }
                    }
                }

            }
        }
        if(! newPermissions.isEmpty())
        // We have new permissions to assign
        {
            Savepoint sp = Database.setSavepoint();
            try {
                zpf.DatabaseUtil.insertObjects(newPermissions);
            }
                catch(DmlException e){
                    Database.rollback(sp);
                    throw new AIQPermissionGrantException(e.getMessage().trim() + ', '+ e.getStackTraceString().trim());
                }
        }

        if(! expiredPermissions.isEmpty())
        // We have expired permissions to withdraw
        {
            Savepoint sp = Database.setSavepoint();
            try {
                    zpf.DatabaseUtil.deleteObjects(expiredPermissions);
                    
            }
            catch(DmlException e){
                Database.rollback(sp);
                throw new AIQPermissionRevokeException(e.getMessage().trim() + ', '+ e.getStackTraceString().trim());
            }
        }

        system.debug('newPermissions '+newPermissions);
                                        
        

        
    }

    public void unassignPermissions(List<User> users){

        Set<Id> userIds = new Set<Id>();
        for(User usr : users){
            userIds.add(usr.id);
        }

        List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
        try{

            //check is user already has the permission set assigned            
            zal.AndCondition whereAndConditions = new zal.AndCondition();
            whereAndConditions.add(new zal.SetCondition('AssigneeId', zal.Operator.INX, new List<Id>(userIds)));
            whereAndConditions.add(new zal.SetCondition('PermissionSetId', zal.Operator.INX, new list<Id>(this.permissionSetsMap.values())));
            
            zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                    .selectx('Id, AssigneeId,PermissionSetId')
                    .fromx('PermissionSetAssignment')
                    .wherex(whereAndConditions);
            permSetAssignments = Database.query(soqlBuilder.toSoql());
        } catch(Exception e){
            throw new QueryException(e.getMessage().trim()+ ', '+ e.getStackTraceString().trim());
        }

        Map<Id,Map<Id,PermissionSetAssignment>> userPermSetAssinmentMap = new Map<Id,Map<Id,PermissionSetAssignment>>();
       
        for(PermissionSetAssignment psa : permSetAssignments){
            if(! userPermSetAssinmentMap.containsKey(psa.AssigneeId)){
                userPermSetAssinmentMap.put(psa.AssigneeId, new Map<Id,PermissionSetAssignment>{psa.PermissionSetId=>psa});
            }else {
                userPermSetAssinmentMap.get(psa.AssigneeId).put(psa.PermissionSetId,psa);
            }
        }

        system.debug('userPermSetAssinmentMap ' +userPermSetAssinmentMap);

        Set<PermissionSetAssignment> expiredPermissions = new Set<PermissionSetAssignment>();

        for (User user : users)
        {
            if(user.IsActive){
                
                Set<Id> existingUsrPsa = new Set<Id>();
                if(!userPermSetAssinmentMap.isEmpty()){
                    Map<Id,PermissionSetAssignment> existingUsrPsaMap = userPermSetAssinmentMap.get(user.id);
                    if(existingUsrPsaMap!=null){
                        existingUsrPsa = existingUsrPsaMap.keySet();
                    }
                }

                Set<Id> permSetsToAdd = new Set<Id>();
                Set<Id> permSetsToRemove = new Set<Id>();

                if(profileSecConfigMap.containsKey(user.ProfileId)){
                    permSetsToAdd.addAll(profileSecConfigMap.get(user.ProfileId).get('Add'));
                    permSetsToRemove.addAll(profileSecConfigMap.get(user.ProfileId).get('Remove'));
                } 
                
                if(profileSecConfigMap.containsKey(user.UserRoleId)){
                    permSetsToAdd.addAll(profileSecConfigMap.get(user.UserRoleId).get('Add'));
                    permSetsToRemove.addAll(profileSecConfigMap.get(user.UserRoleId).get('Remove'));
                }

                for(Id psaToAdd : permSetsToAdd){
                    if(existingUsrPsa.contains(psaToAdd)){
                        expiredPermissions.add(userPermSetAssinmentMap.get(user.id).get(psaToAdd));
                    }
                }

                for(Id psaToRemove : permSetsToRemove){
                    if(existingUsrPsa.contains(psaToRemove)){
                        expiredPermissions.add(userPermSetAssinmentMap.get(user.id).get(psaToRemove));
                    }
                }

            }
        }
                                        
        if(! expiredPermissions.isEmpty())
        // We have expired permissions to withdraw
        {
            Savepoint sp = Database.setSavepoint();
            try {
                    zpf.DatabaseUtil.deleteObjects(new List<PermissionSetAssignment>(expiredPermissions));
                   
            }
            catch(DmlException e){
                Database.rollback(sp);
                throw new AIQPermissionRevokeException(e.getMessage().trim() + ', '+ e.getStackTraceString().trim());
            }
        }
    }

}
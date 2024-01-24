public class ShareAfterOwnerChanges {

    @InvocableMethod
    public static void shareWithPSRManger(List<pipeline_review__c> Plist){
        Map<Id, Id> pipelineIdVsOwnerId = new Map<Id,Id>();
        for(Pipeline_Review__c pR: plist){
            pipelineIdVsOwnerId.put(pR.id, pR.Primary_Sales_Rep__c);
        }
        
        
        
        List<Pipeline_Review__Share > shareList = new List<Pipeline_Review__Share >();
        Map<Id, Id> idVsManager = new Map<Id,Id>();
        Map<id,id> psrIdVsUserId = new Map<Id,Id>();
        
        if(pipelineIdVsOwnerId.keyset().size() > 0){
            // List<Id> usIds = new List<Id>();
            List<Primary_Sales_Rep__c> psrList = [Select id, SF_userid__c from Primary_Sales_Rep__c where id in: pipelineIdVsOwnerId.values()];
            for(Primary_Sales_Rep__c psr: psrList){
                psrIdVsUserId.put(psr.id,psr.SF_userid__c);
                //usIds.add(psr.SF_userid__c);
            }
            
            
            List<User> usrList = [Select id, ManagerId From User where id in: psrIdVsUserId.values()];
            if(usrList.size() > 0){
                for(user us : usrList){
                    idVsManager.put(us.id,us.managerId);
                }
            }
        }
        
       for(Pipeline_Review__c pR: plist){
           if(pipelineIdVsOwnerId.containsKey(pR.id)){
               system.debug('inside if');
               Pipeline_Review__Share shareObj = new Pipeline_Review__Share();
               shareObj.UserOrGroupId = idVsManager.get(psrIdVsUserId.get(pipelineIdVsOwnerId.get(pR.id)));
               shareObj.parentId = pR.id;
               shareObj.AccessLevel = 'Edit';
               shareobj.RowCause = 'Manual';
               system.debug( '  shareObj.parentId  '+ shareObj.parentId    +'shareObj.AccessLevel' + shareObj.AccessLevel + '    shareObj.UserOrGroupId   ' + shareObj.UserOrGroupId);
               shareList.add(shareobj);
               system.debug(shareList);
               
           }
        }
        if(shareList.size() > 0){
            set<String> parentIdUserIdCombination = new set<string>();
            List<Id> parentId = new List<Id>();
            List<Id> userIds = new List<Id>();
            for(Pipeline_Review__Share prShare : shareList){
                parentId.add(prShare.parentId);
                userIds.add(prShare.UserOrGroupId);
                string temp = string.valueOf(prShare.parentId)+string.valueOf(prShare.UserOrGroupId);
                parentIdUserIdCombination.add(temp);
            }
            
            List<Pipeline_Review__Share> existingList = [SELECT ParentId, Id, UserOrGroupId FROM Pipeline_Review__Share where ParentId in: parentId and UserOrGroupId in:  userIds];
            if(existingList.size() > 0){
                system.debug('inside existing');
                
            }else{
                system.debug( '123'+   Schema.sObjectType.Pipeline_Review__Share.isAccessible() );
                system.debug( '234'+   Schema.sObjectType.Pipeline_Review__c.isAccessible() );
                
                insert shareList;
                system.debug('shareList.id'+shareList[0].id);
            }
           
        }
        
    
    }
}
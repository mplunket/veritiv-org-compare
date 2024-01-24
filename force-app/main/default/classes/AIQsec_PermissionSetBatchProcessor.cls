global with sharing class AIQsec_PermissionSetBatchProcessor implements Database.Batchable<sObject>, Database.Stateful{
    public class AIQPermissionSetBatchProcessorException extends Exception{}
    private List<User> users;
    private List<String> errorStack;

    public AIQsec_PermissionSetBatchProcessor() {
        this.users = new List<User>();
        this.errorStack = new List<String>();
        
    }

    public AIQsec_PermissionSetBatchProcessor(List<User> theUsers) {
        this.users = new List<User>(theUsers);
        this.errorStack = new List<String>();
    }  

    public void getUsersForUpdateAll(){
        
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

        Set<String> profileNames = new Set<String>();
        Set<String> roleNames = new Set<String>();

        for(AIQZilliantPermissionsConfig__c configRecord : secConfigRecords){

            if(configRecord.AssignmentGroupType__c=='Profile'){
                profileNames.add(configRecord.AssignmentGroupName__c);
            } else if (configRecord.AssignmentGroupType__c=='UserRole'){
                roleNames.add(configRecord.AssignmentGroupName__c);
            }
        }
        
        try{
            
            this.users = [SELECT Id, Name, Username, UserRoleId, ProfileId, IsActive 
                          FROM User 
                          WHERE IsActive = True AND (Profile.Name IN : profileNames OR UserRole.Name IN :  roleNames )];
        }catch(Exception e){

            this.errorStack.add(e.getMessage() + ', '+ e.getStackTraceString());
        }

    }

    global Iterable<sObject> start(Database.BatchableContext BC){
        return this.users;
    }


    global void execute(Database.BatchableContext BC, List<User> scope)
    {
        try{
            AIQsec_PermissionSetManager manager = new AIQsec_PermissionSetManager();
            manager.unassignPermissions(scope);
            manager.assignPermissions(scope);
        }catch(Exception e){
            this.errorStack.add(e.getMessage().trim() + (String.isBlank(e.getStackTraceString().trim()) ? '' : ', '+e.getStackTraceString().trim()));
        } 
    }
    
    
    global void finish(Database.BatchableContext BC){
        System.debug('### Finish Method Invoked....');
        AIQZilliantConfiguration__c configFields = AIQZilliantConfiguration__c.getInstance();
        String notifGroupString = (String) configFields.get('NotificationGroup__c');
        String emailsString = '';
        if (!String.isBlank(notifGroupString)){
            emailsString = notifGroupString.replaceAll('(\\r|\\n)+', ',');
        }
        String[] notificationGroup = emailsString.trim().split(',');
        //we need to send email here to Zilliant Support Portal
        if(!errorStack.isEmpty()){
            new AIQco_Messenger('Veritiv DM: AIQsec_PermissionSetBatchProcessor class errors', this.errorStack, notificationGroup).send();
        }        
    }

}
public without sharing class WorkOrderServices {
    
    public static final String ROW_CAUSE_MANUAL = 'Manual'; 
    
    
    public static void routeToQueue(List<WorkOrder> newList){
        system.debug('inside route method');
        id pricingRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Pricing').getRecordTypeId();
        List<Id> submittedByIds = new List<Id>();
        list<id> accountIdList = new List<id>();
        map<id,id> accounttoContractMap = new map<id,id>();
        for(workOrder wo: newList){
            submittedByIds.add(wo.WO_Submitted_By__c);
            accountIdList.add(wo.accountid);
        }
        
        if(accountIdList.size()>0){//get contracts
            for(Contract con: [select id, accountid from contract where accountid in:accountIdList]){
                accounttoContractMap.put(con.accountid, con.id);    
            }
        }
        
        system.debug('submittedByIds'+submittedByIds);
        if(submittedByIds.size() > 0){
            List<User> userList = [Select id, UserRole.name from user where id in: submittedByIds];
            Map<Id, String> submitterVsRoleName = new Map<Id, string>();
            for(User us : userList){
                submitterVsRoleName.put(us.Id, Us.UserRole.name);
            }
            
            
            system.debug('submitterVsRoleName'+submitterVsRoleName);
            List<QueueSobject> queu =[  SELECT QueueId,Queue.developername, SobjectType, Id FROM QueueSobject where sobjectType = 'Workorder'];
            Map<String, Id> queNamesVsId = new Map<string,Id>();
            for(QueueSobject qu : queu){
                system.debug('Name 12'+qu.Queue.developername +'34ID  '+ qu.queueId);
                queNamesVsId.put(qu.Queue.developername, qu.QueueId);
            }
            
            system.debug('queNamesVsId'+queNamesVsId);
            for(workOrder wo: newList){
                system.debug('wo.WO_Submitted_By__c'+wo.WO_Submitted_By__c);
                system.debug('submitterVsRoleName.containsKey(wo.WO_Submitted_By__c)'+submitterVsRoleName.containsKey(wo.WO_Submitted_By__c));
                system.debug('wo.Type_of_Maintenance__c'+wo.Type_of_Maintenance__c);
                if( submitterVsRoleName.containsKey(wo.WO_Submitted_By__c)){
                    system.debug('submitterVsRoleName.get(wo.WO_Submitted_By__c) 1s'+submitterVsRoleName.get(wo.WO_Submitted_By__c));
                                                            
                        if(
                            (wo.Type_of_Request__c == 'Single Item Maintenance' ) && (
                                
                                //wo.Type_of_Maintenance__c == 'Alternate Source Add' ||
                                //wo.Type_of_Maintenance__c == 'Alternate Unit of Measure Add' ||
                                wo.Type_of_Maintenance__c == 'Category Update' ||
                                //wo.Type_of_Maintenance__c == 'Description Update' ||                                
                                wo.Type_of_Maintenance__c == 'Map Vendor' ||
                                wo.Type_of_Maintenance__c == 'Research/Question' || 
                                wo.Type_of_Maintenance__c == 'PIM Team Only' )
                        ){
                            
                            if(queNamesVsId.containsKey('PIM_MIF_Team')){
                                wo.ownerId = queNamesVsId.get('PIM_MIF_Team');
                                wo.PIM_Status__c = 'New';
                            }
                        }
                        
                        if(
                            (wo.Type_of_Request__c == 'Single Item Maintenance' ) && (  
                                wo.Type_of_Maintenance__c == 'Alternate Source Add' ||                              
                                wo.Type_of_Maintenance__c == 'Customer Protections' || 
                                wo.Type_of_Maintenance__c == 'Cube/Weight Update' ||
                                wo.Type_of_Maintenance__c == 'Description Update' ||
                                wo.Type_of_Maintenance__c == 'Discontinued Item' ||
                                wo.Type_of_Maintenance__c == 'Forced Substitute' ||
                                wo.Type_of_Maintenance__c == 'HAZMAT/SDS Update' ||
                                wo.Type_of_Maintenance__c == 'Other' ||                                
                                wo.Type_of_Maintenance__c == 'Push/Pull' ||                                
                                wo.Type_of_Maintenance__c == 'Inventory Mgmt Approved Stocking Flag Update' ||
                                wo.Type_of_Maintenance__c == 'Work Order/NIR Status Inquiry' ||
                                wo.Type_of_Maintenance__c == 'Unit of Measure Add/Review'  )){
                                //wo.Type_of_Maintenance__c == 'Flag Item for Veritiv Express POS' || 
                                //wo.Type_of_Maintenance__c == 'Pushes - Allow Item' ||
                                //wo.Type_of_Maintenance__c == 'Stocking Flag Update' ||    
                                    if(queNamesVsId.containsKey('PIM_Single_Item_Team')){
                                        wo.ownerId = queNamesVsId.get('PIM_Single_Item_Team');
                                        wo.PIM_Status__c = 'New';
                                    }
                                }
                        
                        if(
                            ( wo.Type_of_Maintenance__c == 'Multiple Item 10+ New Item Setup' && wo.Type_of_Request__c == 'Multiple Item Request')
                            //( wo.Type_of_Maintenance__c == 'Multiple Item 10+ New Item Setup' && wo.Type_of_Request__c == 'Multiple Item Maintenance')
                            ||
                            (  (wo.Type_of_Maintenance__c == 'PM Suffix'||wo.Type_of_Maintenance__c == 'DRR'||wo.Type_of_Maintenance__c == 'Multiple Item 10+ Maintenance'||wo.Type_of_Maintenance__c == 'Multiple Item 10+ New Item Setup') && wo.Type_of_Request__c == 'Multiple Item Maintenance')
                            /*||
                            (  wo.Type_of_Maintenance__c == 'Research/Question' && wo.Type_of_Request__c == 'Research/Question')
                            */
                        ) {
                            system.debug('quename'+queNamesVsId.keyset().contains('PIM_Multiple_Item_Team'));
                            
                            if(queNamesVsId.keyset().contains('PIM_Multiple_Item_Team')){
                                system.debug('assign-owner');
                                wo.ownerId = queNamesVsId.get('PIM_Multiple_Item_Team');
                                wo.PIM_Status__c = 'New';
                            }  
                        }
                        
                        
                    
                }
                system.debug('wo.recordtypeid '+wo.recordtypeid);
                system.debug('pricingRecordTypeId '+pricingRecordTypeId);
                system.debug('queNamesVsId.containsKey(Pricing)'+queNamesVsId.containsKey('Pricing'));
                
                if(wo.recordtypeid == pricingRecordTypeId){
                    if(queNamesVsId.containsKey('Pricing_Team_Tickets')){//assign to pricingteam
                        wo.ownerId = queNamesVsId.get('Pricing_Team_Tickets');                  
                        //add contract record:
                        if (accounttoContractMap.containskey(wo.accountid)){
                            wo.contract__c = accounttoContractMap.get(wo.accountid);  
                        }        
                    }
                }
            }
            
        }
    }
    
    public static void updateStatusWhenOwnerChangedToQueue(List<Workorder> newList, Map<Id, WorkOrder> oldMap){
        Id PimRecId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Product Item Maintenance').getRecordTypeId();
        
        for(workOrder wo: newList){
            system.debug( wo.OwnerId != oldMap.get(wo.Id).OwnerId);
            system.debug(string.valueOf(wo.OwnerId).startsWith('00G'));
            system.debug(wo.RecordType.DeveloperName);
            if(wo.OwnerId != oldMap.get(wo.Id).OwnerId && string.valueOf(wo.OwnerId).startsWith('00G') && wo.RecordTypeId == PimRecId ){
                //wo.PIM_Status__c = 'New';
                
                system.debug('Inside update WO');
                wo.Status = 'New';
            }
        }
    }
    public static void checkWorkOrderDelete(List<WorkOrder> workOrdersToDelete)
    {
        if( !canDeleteWorkOrder() )
        {
            for(WorkOrder wo : workOrdersToDelete)
            {
                wo.addError('This user/profile is not allowed to delete Work Orders.');
            }
        }
        
    }
    
    @TestVisible
    private static boolean canDeleteWorkOrder()
    {
        Allow_Work_Order_Deletion__c allowDeletionRecord = Allow_Work_Order_Deletion__c.getInstance();
        return allowDeletionRecord != null && allowDeletionRecord.Allow_To_Delete__c;
    }
    //sujitha updated code
    public static void updateRelatedWorkOrderShares(Map<Id, Account> oldAccs, Map<Id, Account> newAccs)
    {
        Boolean boolAccnt = false;
        for(Id accId : newAccs.keyset())
        {
            if(accId == system.label.DE_Print_Orphan_Account || accId == system.label.Field_Sourcing_Orphan_Account){
                boolAccnt = true;
                break;
            }
            
        }
        
        if(boolAccnt==false)
        {
            
            Map<Account, List<WorkOrder>> accountToWorkOrders = getFilteredWorkOrders(oldAccs, newAccs);
            
            if(accountToWorkOrders.isEmpty())
                return;
            
            deleteExistingWorkOrderShares(oldAccs, accountToWorkOrders);
            
            insertNewWorkOrderShares(newAccs, accountToWorkOrders);
        }
    }
    
    /*
@TestVisible
private static List<Account> filterAccountOwnerChange(Map<Id, Account> oldAccs, Map<Id, Account> newAccs)
{
List<Account> filteredAccounts = new List<Account>();
if(oldAccs != NULL && newAccs != NULL)
{
Map<Id,Account> requeriedAccountsMap = new Map<Id, Account>([SELECT Id, OwnerId, Owner.IsActive, (SELECT Id, OwnerId, Owner.IsActive, CreatedById FROM WorkOrders) FROM Account WHERE Id IN :newAccs.keySet()]);

for(Id accId : newAccs.keySet())
{
if(oldAccs.get(accId).OwnerId != newAccs.get(accId).OwnerId)
{
filteredAccounts.add(requeriedAccountsMap.get(accId));
}
}
}
else if(oldAccs == NULL)
{
}
else if(newAccs == NULL)
{
}

return filteredAccounts;
}
*/
    
    @TestVisible
    private static Map<Account, List<WorkOrder>> getFilteredWorkOrders(Map<Id, Account> oldMap, Map<Id, Account> newMap)
    {
        Map<Account, List<WorkOrder>> filteredMap = new Map<Account, List<WorkOrder>>();
        if(oldMap != NULL && newMap != NULL)
        {
            Map<Id,Account> requeriedAccountsMap = new Map<Id, Account>([SELECT Id, OwnerId, Owner.IsActive, (SELECT Id, OwnerId, Owner.IsActive, CreatedById FROM WorkOrders) FROM Account WHERE Id IN :newMap.keySet() AND Owner.IsActive = TRUE]);
            
            if(requeriedAccountsMap.values().isEmpty())
            {
                return filteredMap;
            }
            
            for(Id accId : newMap.keySet())
            {
                if(oldMap.get(accId).OwnerId != newMap.get(accId).OwnerId && requeriedAccountsMap.containsKey(accId))
                {
                    if(requeriedAccountsMap.get(accId).WorkOrders != NULL && requeriedAccountsMap.get(accId).WorkOrders.size() > 0)
                    {
                        filteredMap.put(requeriedAccountsMap.get(accId), requeriedAccountsMap.get(accId).WorkOrders); 
                    }
                }
            }
        }
        
        return filteredMap;
    }
    
    @TestVisible
    private static void insertNewWorkOrderShares(Map<Id, Account> newMap, Map<Account, List<WorkOrder>> accToWorkOrders)
    {
        Set<WorkOrderShare> woShares = new Set<WorkOrderShare>(); 
        //Set<Id> accountIds = Plucks.Ids(accToWorkOrders.keySet());
        System.debug('* AccIdsToWorkOrder Map: ' + accToWorkOrders);
        
        for(Account acc : accToWorkOrders.keySet())
        {
            for(WorkOrder wo : accToWorkOrders.get(acc))
            {
                System.debug('*Owner Active: ' + newMap.get(acc.Id).Owner.isActive);
                System.debug('*Owner: ' + newMap.get(acc.Id));
                
                if(acc.Owner.isActive && newMap.get(acc.Id).OwnerId != wo.OwnerId) //newMap.get(acc.Id).Owner.isActive && 
                {
                    woShares.add( new WorkOrderShare(AccessLevel = 'Edit', ParentId = wo.Id, UserOrGroupId = newMap.get(acc.Id).OwnerId) );
                }
            }
        }
        System.debug('*New Map: ' + newMap);
        System.debug('*Work Order Shares: ' + woShares);
        try
        {
            insert new List<WorkOrderShare>(woShares);
        }
        catch(Exception ex)
        {
            System.debug('Ex: ' + ex);
            //Backlog Item-2641 error message update
            System.debug('Exception type caught: ' + ex.getTypeName());    
            System.debug('Message: ' + ex.getMessage());    
            System.debug('Cause: ' + ex.getCause());  
            System.debug('Line number: ' + ex.getLineNumber());    
            System.debug('Stack trace: ' + ex.getStackTraceString());    
            
            //Send an email with the error
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String[] toAddress = new String[]{'rodney.ballener@simplus.com'};
            semail.setToAddresses(toAddress);
            semail.setSubject('Error in inserting Work Order Share');
            semail.setPlainTextBody('Error in inserting Work Order Share: '+ex.getmessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
                    
            //commented below as they were causing errors. Backlog Item-2641
            
            /*
for(Integer i = 0; i < ex.getNumDML(); i++)
{
newMap.get(ex.getDmlId( i )).addError(ex.getDmlMessage(i));
}
*/
        }
    }
    
    @TestVisible
    private static void deleteExistingWorkOrderShares(Map<Id, Account> oldMap, Map<Account, List<WorkOrder>> accToWorkOrders)
    {
        Set<Id> woIds = new Set<Id>();
        Set<Id> ownerIds = Pluck.Ids('OwnerId', oldMap.values()); 
        //Set<Id> accountIds = Pluck.Ids(accIdToWorkOrders);
        
        for(Account acc : accToWorkOrders.keySet())
        { 
            for(WorkOrder wo : accToWorkOrders.get(acc))
            { 
                if(acc.Owner.isActive && wo.OwnerId != oldMap.get(acc.Id).OwnerId && oldMap.get(acc.Id).OwnerId != wo.CreatedById)
                {
                    woIds.add( wo.Id );
                }
            }
        }
        
        List<WorkOrderShare> currentShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM WorkOrderShare WHERE ParentId IN :woIds AND UserOrGroupId IN :ownerIds ];
        
        try
        {
            delete new List<WorkOrderShare>(currentShares);
        }
        catch(Exception ex)
        {
            for(Integer i = 0; i < ex.getNumDML(); i++)
            {
                oldMap.get(ex.getDmlId( i )).addError(ex.getDmlMessage(i));
            }
        }
    }
    
}
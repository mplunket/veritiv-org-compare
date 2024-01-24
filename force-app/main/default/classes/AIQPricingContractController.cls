public with sharing class AIQPricingContractController {    
    
    private static Account getAccount(String acctId)
    {
        Account acct;
        List<String> fieldsToSelect = new List<String>{
            'Id'
                ,'Servicing_Division__c'
                ,'Name'
                ,'Servicing_Division__r.Name'
                ,'Servicing_Division__r.Division_Code__c'
                ,'zpl__CustomerId__c'
                ,'Legacy_System_Cd__c'
                ,'Legacy_Division_Cd__c'
                ,'AccountNumber'
                ,'RecordType.Name'
                ,'Representative_Division__c'
                };
                    String selectColumns = String.join(fieldsToSelect, ',');
        zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
            .selectx(selectColumns)
            .fromx('Account')
            .wherex(new zal.FieldCondition('Id', zal.Operator.EQUALS, acctId))
            .limitx(1);
        
        acct =(Account) Database.query(soqlBuilder.toSoql()).get(0);
        
        return acct;
    }
    
    
       @AuraEnabled
    public static Contract addPricingContract(String acctId) 
    {
        Contract agrmnt = new Contract();
        CustomMessage msg = null;
        Account acct;        
        
        if(acctId==null || acctId==''){
						
           msg = new CustomMessage(null, null, Label.AIQAccountMissing, true);
           System.debug(msg); //  return msg;
        }
         
        try{
            acct = getAccount(acctId);            
        }catch(Exception e){
			System.debug('Can not get Account');
        }        

        if(acct!=null){
            agrmnt.AccountId = acct.id;
            agrmnt.Name = acct.Name;            
            agrmnt.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PricingContract').getRecordTypeId();
            agrmnt.Status = 'Draft';
            agrmnt.StartDate = Date.today();
            agrmnt.ContractTerm=99;
            agrmnt.Account_Searchable__c = acct.Name;
            agrmnt.Account_Number_Searchable__c = acct.zpl__CustomerId__c;
                      
            Id rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Chain Account'].Id;      
			  if(acct.RecordTypeId == rt){
                Servicing_Division__c servDiv;
                try{
                    List<Servicing_Division__c> servDivs = [SELECT Id, Name FROM Servicing_Division__c WHERE Division_Composite_Key__c = : acct.Representative_Division__c LIMIT 1];
                    if(servDivs.isEmpty() || acct.Representative_Division__c==null){                  
					  msg = new CustomMessage(null, null, 'Repesentative division not found', true);
                      System.debug(msg); 
                   return null;
                    }
                    servDiv = servDivs.get(0);
                }catch(Exception e){
                msg = new CustomMessage(null, null, e.getMessage(), true);
				System.debug(msg); 
                }
                
                    agrmnt.zpl__ContractId__c = acct.zpl__CustomerId__c;
                    agrmnt.Division__c = servDiv.Id;
                    agrmnt.Division_Searchable__c = servDiv.Name;
                    System.debug('Chain account set up'); 
           		}else{
                	//agrmnt.zpl__ContractId__c = (acct.Legacy_System_Cd__c== '03' ? 'SW' : acct.Legacy_System_Cd__c)+acct.Legacy_Division_Cd__c+acct.AccountNumber;
           	
                     agrmnt.zpl__ContractId__c = acct.zpl__CustomerId__c;
                     agrmnt.Division__c = acct.Servicing_Division__c;
                     agrmnt.Division_Searchable__c = acct.Servicing_Division__r.Name;
                
                    if(agrmnt.Division__c == null){
                         System.debug('Servicing Division was not set for this Customer account ');  	
                    }     
            	}
            
            try{
                insert agrmnt;
                msg = new CustomMessage(agrmnt.Id, agrmnt.AccountId, 'Ok', false);
				System.debug(msg);
            }catch(System.DmlException e){
               msg = new CustomMessage(null, null, 'Failed to insert the Contract', true);
               System.debug(e.getMessage() + msg);
            }
        }
       
        return agrmnt;
    }
    
    @AuraEnabled
    public static CustomMessage copyContract(String acctId, String contractId)
    {
        CustomMessage msg = null;
        Contract newContract = new Contract();
        List<SObject> recordsToInsert = new List<SObject>();       
        Account acct;
        
        if(acctId==null || acctId==''){
            msg = new CustomMessage(null, null, Label.AIQAccountMissing, true);
            return msg;
        }
        
        try{
            acct = getAccount(acctId);
            
        }catch(Exception e){
            msg = new CustomMessage(null, null, 'Can not get Account', true);
            return msg;
        }
        
        newContract = (Contract) AIQSObjectUtil.getClone('Contract', new List<Id>{contractId}, new List<String>()).get(0);
        
        if(acct!=null){
            newContract.AccountId = acct.id;
            newContract.Name = acct.Name;
            newContract.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PricingContract').getRecordTypeId();
            newContract.Status = 'Draft';
            newContract.StartDate = Date.today();
            newContract.ContractTerm=99;
            newContract.Account_Searchable__c = acct.Name;
            newContract.Account_Number_Searchable__c = acct.zpl__CustomerId__c;
            newContract.ExpContractLinesCount__c = null;
            newContract.ExpRebatesCount__c = null;
            newContract.X12MonthsRevenue__c = null;
            newContract.score__c = null;
            
            if(acct.RecordType.Name == 'Chain Account'){
                Servicing_Division__c servDiv;
                try{
                    List<Servicing_Division__c> servDivs = [SELECT Id, Name FROM Servicing_Division__c WHERE Division_Composite_Key__c = : acct.Representative_Division__c LIMIT 1];
                    if(servDivs.isEmpty() || acct.Representative_Division__c==null){
                        msg = new CustomMessage(null, null, 'Repesentative division not found', true);
                        return msg;
                    }
                    servDiv = servDivs.get(0);
                }catch(Exception e){
                    msg = new CustomMessage(null, null, e.getMessage(), true);
                    return msg;
                }
                
                newContract.zpl__ContractId__c = acct.zpl__CustomerId__c;
                newContract.Division__c = servDiv.Id;
                newContract.Division_Searchable__c = servDiv.Name;
                
            }else{
                //newContract.zpl__ContractId__c = (acct.Legacy_System_Cd__c== '03' ? 'SW' : acct.Legacy_System_Cd__c)+acct.Legacy_Division_Cd__c+acct.AccountNumber;
                newContract.zpl__ContractId__c = acct.zpl__CustomerId__c;
                newContract.Division__c = acct.Servicing_Division__c;
                newContract.Division_Searchable__c = acct.Servicing_Division__r.Name;
            }
            
        }
        
        Contract newContractReference = new Contract(zpl__ContractId__c = newContract.zpl__ContractId__c);
        
        Map<Id, zpl__ContractLineItem__c> contrLines = new Map<Id, zpl__ContractLineItem__c>([SELECT Id FROM zpl__ContractLineItem__c WHERE zpl__Contract__c =: contractId AND RecordType.Name NOT IN ('Inactive', 'Draft') and SupersededDate__c=null]);
        List<Id> contrLineIds = new List<Id>();
        for(Id contrLineId : contrLines.keySet())
        {
            contrLineIds.add(contrLineId);
        }
        
        List<String> excludeFileds = new List<String>();
        excludeFileds.add('zpl__Contract__c');
        
        List<zpl__ContractLineItem__c> newContrLines = new List<zpl__ContractLineItem__c>();
        
        if(! contrLineIds.isEmpty()){
            newContrLines = (List<zpl__ContractLineItem__c>) AIQSObjectUtil.getClone('zpl__ContractLineItem__c', contrLineIds, excludeFileds);
        }
        
        AIQ_AgreementLineManipulator.stripAgreementLine(newContrLines);
        for(Integer i=0; i<newContrLines.size(); i++)
        {
            newContrLines.get(i).zpl__Contract__r = newContractReference;
            //newContrLines.get(i).zpl__ContractLineItemId__c =  null;
            if(acct.RecordType.Name != 'Chain Account'){
                newContrLines.get(i).Division_Code2__c = acct.Servicing_Division__r.Division_Code__c;
            }
            newContrLines.get(i).Annual_Quantity__c = null;
            newContrLines.get(i).AnnualCOGS__c = null;
            newContrLines.get(i).X12MonthSalesVolume__c = null;
            newContrLines.get(i).CampaignAppealedLine__r=null;
        }
        
        recordsToInsert.add(newContract);
        recordsToInsert.addAll(newContrLines);
        
        Savepoint sp = Database.setSavepoint();
        if(recordsToInsert.size()>0)
        {
            try{
                zpf.DatabaseUtil.insertObjects(recordsToInsert);
            } catch(Exception e)
            {
                Database.rollback(sp);
                throw zpf.AuraHandledExceptionUtil.handleException(e);
            }
        }
        
        if(!newContrLines.isEmpty()){
            try{
                
                AIQZilliantConfiguration__c envVariables = AIQZilliantConfiguration__c.getInstance();
                AIQco_FESBatchProcessorSync batchProcess = new AIQco_FESBatchProcessorSync(new Account(Id=newContract.AccountId, IsProcessing__c = true)
                                                                                           , newContrLines
                                                                                           , (String) envVariables.get('GetPriceDataFormula__c')
                                                                                           , newContrLines[0].getSobjectType());
                
                ID batchProcId = Database.executeBatch(batchProcess, Integer.valueOf((Decimal) envVariables.get('FESRequestSize__c')));
                
                zpf.DatabaseUtil.updateObjects(new Account(Id=newContract.AccountId, IsProcessing__c = true));
                
            }catch(Exception e)
            {
                Database.rollback(sp);
                throw zpf.AuraHandledExceptionUtil.handleException(e);
                
            }
        }
        
        msg = new CustomMessage(newContract.Id, newContract.AccountId, Label.AIQRedirectMessage, false);
        return msg;
    }
    
    
  	@TestVisible
    private class CustomMessage{
        @TestVisible
        @AuraEnabled
        private String recordID {get; set;}
        @TestVisible
        @AuraEnabled
        private String accountID {get; set;}
        @TestVisible
        @AuraEnabled
        private String msgText {get; set;}
        @TestVisible
        @AuraEnabled
        private Boolean isError {get; set;}
        
        private CustomMessage(String recordID, String accountID, String msgText, Boolean isError)
        {
            this.recordID = recordID;
            this.accountID = accountID;
            this.msgText = msgText;
            this.isError = isError;
        }
    }
    
    @AuraEnabled
    public static UserValidationResult validateUser()
    {
        Id userId = UserInfo.getUserId();
        
        String[] delegApprExclusions= new List<String>();
        User usr = [SELECT Alias, Network_Id__c, Profile.Name FROM User WHERE Id =: userId LIMIT 1];
        UserValidationResult resultObj = new UserValidationResult(usr.Network_Id__c, false, false);
        
        
        AIQZilliantConfiguration__c config = AIQZilliantConfiguration__c.getInstance();
        String mps = config.ManagersPermissionSet__c;
        PermissionSetAssignment psa= null;
        try{
            psa = [SELECT Id, AssigneeId, PermissionSet.Name 
                   FROM PermissionSetAssignment 
                   WHERE AssigneeId =: userId 
                   AND PermissionSet.Name =: mps
                   LIMIT 1];
        }catch(Exception e){
            
        }
        
        String delegateApprExclusions = config.DelegatedApproverExclusions__c;
        String delegApprExclusionsParsed = '';
        if(!String.isBlank(delegateApprExclusions)){
            delegApprExclusionsParsed = delegateApprExclusions.replaceAll('(\\r|\\n)+', ',');   
        }    
        String[] delegApprExclusionsList = delegApprExclusionsParsed.trim().split(',');
        for(String item : delegApprExclusionsList){
            delegApprExclusions.add(item.trim());
        }    
        
        
        if(psa!= null && userId==psa.get('AssigneeId')){
            resultObj.setIsPricingManager(true);
        }
           
           if(! delegApprExclusions.contains(usr.Profile.Name)){
               resultObj.setDelegateApprAllowed(true);
           } 
           
           return resultObj;      
      }
           
    @TestVisible
    public class UserValidationResult{
        @AuraEnabled
        public String userAlias;
        @AuraEnabled
        public Boolean isPricingManager;
        @AuraEnabled
        public Boolean delegateApprAllowed;
        
        
        UserValidationResult (String userAlias, Boolean isPricingManager, Boolean delegateApprAllowed){
            this.userAlias = userAlias;
            this.isPricingManager = isPricingManager;
            this.delegateApprAllowed = delegateApprAllowed;
        }
        
        public String getUserAlias(){
            return userAlias;
        }
        
        public Boolean getIsPricingManager(){
            return isPricingManager;
        }
        
        public void setIsPricingManager(Boolean isPricingManager){
            this.isPricingManager = isPricingManager;
        }
        
        public void setDelegateApprAllowed(Boolean delegateApprAllowed){
            this.delegateApprAllowed = delegateApprAllowed;
        }
        
    }
    
    @AuraEnabled
    public static String getReportURL(String reportIdField) 
    {
        Id userId = UserInfo.getUserId();
        User usr = [SELECT Alias, Network_Id__c, Profile.Name FROM User WHERE Id =: userId LIMIT 1];

        SAP_BI_Reports_Setting__c VBOCustSet = SAP_BI_Reports_Setting__c.getInstance();
        if(VBOCustSet==null){
            throw zpf.AuraHandledExceptionUtil.handleException(new AIQCustomException('VBO custom setting not found')); 
        }
        Object iDocID = VBOCustSet.get(reportIdField);
        if(iDocID==null){
            throw zpf.AuraHandledExceptionUtil.handleException(new AIQCustomException('iDocID not found')); 
        }
        String url = String.valueOf(VBOCustSet.get('SAP_Report_Base_URL__c'))+
        +'&iDocID='+String.valueOf(iDocID)+
        +'&token='+String.valueOf(VBOCustSet.get('Encoded_Token__c'))+String.valueOf(VBOCustSet.get('Encoded_Token_Overflow__c'))+
        +'&sOutputFormat=H'+
        +'&lsMEnter value(s) for Network id='+ usr.Network_Id__c.toUpperCase();

        return url;
            

    }
    
}
global class AIQService implements AIQServiceInterface {
    
    public class AIQServiceException extends Exception{}

    private static final String UPDATE_AGREEMENT_LINE_EXCEPTION = 'Approve/Reject update agreement line Exception';
    private static AIQco_DatabaseUtil databaseUtil = new AIQco_DatabaseUtil();
    private AIQPESService pes = new AIQPESService();
    
    global static AIQAddLineResponse addAgreementLine(String customerId,                                                   
                                                      String level,
                                                      String vendorId,
                                                      String divisionId, 
                                                      String systemId, 
                                                      String segmentId, 
                                                      String classId,
                                                      String brandId,
                                                      String setId,
                                                      String subsetId, 
                                                      String productCode,
                                                      String policyType,
                                                      Decimal policyValue, 
                                                      String priceUnit,
                                                      Date effectiveDate
                                                     ) 
    {
        
        String accountNumber = systemId + customerId;
        String legacySystemCd = (systemId=='SW'?'03':systemId);
        AIQAddLineResponse result = null;        
        Contract contract;        
        Id userId = UserInfo.getUserId();
        
        List<Contract> contracts = [SELECT Id, Account_Number__c, National_Account__c FROM Contract WHERE  Account.zpl__CustomerId__c  = :accountNumber and RecordType.Name = 'Pricing Contract'];
        List<zpl__ContractLineItem__c> existingLines = new List<zpl__ContractLineItem__c>();
        if(contracts.size() > 0) {
            contract = contracts.get(0);
            
            if(contract.National_Account__c > '') {            
                List<NationalAccountsPricing__c> nationalAccountsPricing = new  List<NationalAccountsPricing__c>();
                for(List<NationalAccountsPricing__c> NABatch: [SELECT Id FROM NationalAccountsPricing__c WHERE NationalAccountGroupID__c = :contract.National_Account__c AND Name = :productCode])
                {
                    nationalAccountsPricing.addAll(NABatch);
                }
                if(nationalAccountsPricing.size() > 0) {
                    result = new AIQAddLineResponse(6,'Product Exists in National Accounts Pricing!');
                    return result;                                                                         
                }                
            }                                                             
        }
        
        if(contract == null ) {            
            List<Account> accts  = [SELECT Id, Name, Servicing_Division__c, Servicing_Division__r.Name, zpl__CustomerId__c FROM Account WHERE zpl__CustomerId__c = :accountNumber LIMIT 1];
            Account account;
            if(accts.size() > 0) {
                account = accts.get(0);
                contract = new Contract();
                contract.zpl__ContractId__c = systemId + divisionId + customerId;
                contract.AccountId = account.Id;
                contract.Division__c = account.Servicing_Division__c;
                contract.Name = account.Name;
                contract.StartDate = effectiveDate;
                contract.ContractTerm = 99;
                contract.Status = 'Draft';
                contract.CurrencyIsoCode = 'USD';
                contract.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PricingContract').getRecordTypeId();
                contract.Account_Searchable__c = account.Name;
                contract.Division_Searchable__c = account.Servicing_Division__r.Name;
                contract.Account_Number_Searchable__c = account.zpl__CustomerId__c;
                insert contract;
                contracts = [SELECT Id, Account_Number__c, National_Account__c FROM Contract WHERE id =: contract.id];
            } else {
                result = new AIQAddLineResponse(4,'Account not found.');
                return result;
            }
        }
        
        if(effectiveDate < Date.today()){
            result = new AIQAddLineResponse(5,'Effective date in the past.');
            return result;
        }
        
        List<zpl__LineLevel__c> lineLevel = [SELECT Id FROM zpl__LineLevel__c WHERE zpl__LineLevelId__c =: level LIMIT 1];
        
        if(contract != null) {
            zpl__ContractLineItem__c newLine = new zpl__ContractLineItem__C();                   
            List<Product2> products = 
                [SELECT Id,Class_Description__c, Brand_Description__c, Description,Standard_Cost__c
                 ,Legacy_Vendor_Code__c,ProductCode, AL_ItemLevel__c, AL_ItemName__c, AL_ClassLevel__c
                 , AL_ClassName__c, AL_ClassVendorLevel__c, AL_ClassVendorName__c, AL_BrandLevel__c
                 , AL_BrandName__c, AL_BrandVendorLevel__c, AL_BrandVendorName__c, AL_SetLevel__c
                 , AL_SetName__c, AL_SetDescription__c, AL_SubsetLevel__c, AL_SubsetName__c
                 , AL_SubsetDescription__c, System_ID__c, Segment__c, Class__C, Brand__C, AL_Set__c
                 , AL_Subset__c, DIVISION_CODE__C, Servicing_Division__c, List_Price__c
                 , BrandDescCode__c, ClassDescCode__c, SetDescCode__c,SubsetDescCode__c, SystemIdNew__c, Pricing_Costing_UOM__c 
                 FROM Product2 
                 WHERE ProductCode =: productCode 
                 AND Division_Code__c =: divisionId 
                 AND System_ID__c =: legacySystemCd];
            
            if(products.size() > 0) {
                Product2 product = products[0];
                newLine.zpl__Product__c = product.Id;        
                newLine.System__c = product.SystemIdNew__c;
                newLine.Division__c = product.Servicing_Division__c;
                newLine.Division_Code2__c = product.Division_Code__c;
                newLine.Segment__c = product.Segment__c;
                newLine.Class__c = product.Class__c;
                newLine.Class_Desc__c = product.ClassDescCode__c;
                newLine.LineSource__c = 'Q';
                
                switch on level {
                    when 'Item' {
                        newLine.zpl__LevelValue__c = product.AL_ItemLevel__c;
                        newLine.zpl__ContractLineItemId__c = product.AL_ItemName__c + '.' + DateTime.now().getTime();
                        newLine.Name = product.AL_ItemName__c;
                        newLine.Brand__c = product.Brand__c;
                        newLine.Brand_Desc__c = product.BrandDescCode__c;
                        newLine.Set__c = product.AL_Set__c;
                        newLine.Set_Desc__c = product.SetDescCode__c;
                        newLine.Subset__c = product.AL_Subset__c;
                        newLine.Subset_Desc__c = product.SubsetDescCode__c;
                        newLine.SKU__c = product.ProductCode;                
                        newLine.VendorCode__c = product.Legacy_Vendor_Code__c;
                        newLine.Current_Standard_Cost__c = product.Standard_Cost__c;
                        newLine.Description__c = product.Description;
                    } when 'Class' {
                        newLine.zpl__LevelValue__c = product.AL_ClassLevel__c;
                        newLine.zpl__ContractLineItemId__c = product.AL_ItemName__c + '.' + DateTime.now().getTime();
                        newLine.Name = product.AL_ClassName__c;
                        newLine.Description__c = product.Class_Description__c;
                    } when 'ClassVendor' {
                        newLine.zpl__LevelValue__c = product.AL_ClassVendorLevel__c;
                        newLine.zpl__ContractLineItemId__c = product.AL_ItemName__c + '.' + DateTime.now().getTime();
                        newLine.Name = product.AL_ClassVendorName__c;
                        newLine.VendorCode__c = product.Legacy_Vendor_Code__c;    
                        newLine.Description__c = product.Class_Description__c;
                    } when 'Brand'{
                        newLine.zpl__LevelValue__c = product.AL_BrandLevel__c;
                        newLine.zpl__ContractLineItemId__c = product.AL_ItemName__c + '.' + DateTime.now().getTime();
                        newLine.Name = product.AL_BrandName__c;
                        newLine.Brand__c = product.Brand__c;
                        newLine.Brand_Desc__c = product.BrandDescCode__c;
                        newLine.Description__c = product.Brand_Description__c;
                    } when 'BrandVendor'{
                        newLine.zpl__LevelValue__c = product.AL_BrandVendorLevel__c;
                        newLine.zpl__ContractLineItemId__c = product.AL_ItemName__c + '.' + DateTime.now().getTime();
                        newLine.Name = product.AL_BrandVendorName__c;
                        newLine.Brand__c = product.Brand__c;
                        newLine.Brand_Desc__c = product.BrandDescCode__c;
                        newLine.VendorCode__c = product.Legacy_Vendor_Code__c;    
                        newLine.Description__c = product.Brand_Description__c;                        
                    } when 'Set'{
                        newLine.zpl__LevelValue__c = product.AL_SetLevel__c;
                        newLine.zpl__ContractLineItemId__c = product.AL_ItemName__c + '.' + DateTime.now().getTime();
                        newLine.Name = product.AL_SetName__c;
                        newLine.Brand__c = product.Brand__c;
                        newLine.Brand_Desc__c = product.BrandDescCode__c;
                        newLine.Set__c = product.AL_Set__c;
                        newLine.Set_Desc__c = product.SetDescCode__c;
                        newLine.Description__c = product.AL_SetDescription__c;                        
                    } when 'Subset' {
                        newLine.zpl__LevelValue__c = product.AL_SubsetLevel__c;
                        newLine.zpl__ContractLineItemId__c = product.AL_ItemName__c + '.' + DateTime.now().getTime();
                        newLine.Name = product.AL_SubsetName__c;
                        newLine.Brand__c = product.Brand__c;
                        newLine.Brand_Desc__c = product.BrandDescCode__c;
                        newLine.Set__c = product.AL_Set__c;
                        newLine.Set_Desc__c = product.SetDescCode__c;
                        newLine.Subset__c = product.AL_Subset__c;
                        newLine.Subset_Desc__c = product.SubsetDescCode__c;
                        newLine.Description__c = product.AL_SubsetDescription__c;
                    } when else{
                        result = new AIQAddLineResponse (8,'Level not recognized.');                                              
                        return result;
                    }
                }
            } else {
                result = new AIQAddLineResponse (7,'Product Not Found.');   
                return result;
            }
            
            newLine.zpl__EffectiveDate__c = effectiveDate;
            newLine.zpl__Contract__c = contract.Id;   
            zpl__PolicyType__c thePolicyType = new zpl__PolicyType__c(zpl__PolicyTypeId__c = policyType);
            newLine.zpl__PolicyType__r = thePolicyType;
            newLine.zpl__PolicyValue__c = policyValue;
                        
            newLine.zpl__LineLevel__c = lineLevel.get(0).Id;
            
            Id recordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();
            newLine.RecordTypeId = recordTypeId;
            newLine.zpl__Status__c = 'Draft';
            
            String productUOMId = systemId + divisionId + productCode + priceUnit;           
            zpl__ProductUOM__c uom = new zpl__ProductUOM__c(zpl__ProductUOMId__c = productUOMId);            
            newLine.zpl__UOM__r = uom;
                                            
            insert newLine;
            result = new AIQAddLineResponse (0,'Line Id: '+newLine.Id);
            
            // getting data via API callout asynchronosly   
            try{
                AIQZilliantConfiguration__c envVariables = AIQZilliantConfiguration__c.getInstance();
                AIQco_FESBatchProcessorSync batchProcess = new AIQco_FESBatchProcessorSync(null
                                                                                   , new List<zpl__ContractLineItem__c>{newLine}
                                                                                   , (String) envVariables.get('GetPriceDataFormula__c')
                                                                                   , newLine.getSobjectType());
                
                ID batchProcId = Database.executeBatch(batchProcess, Integer.valueOf((Decimal) envVariables.get('BatchJobSize__c')));
            }catch(Exception e)
            {
                system.debug(e.getMessage());
                throw e;
            } 

            existingLines = [SELECT Id, Name, zpl__Status__c, zpl__EffectiveDate__c, zpl__Contract__c,  zpl__PolicyType__c, zpl__PolicyValue__c, RecordTypeId FROM zpl__ContractLineItem__c WHERE zpl__Status__c=: 'Published' AND zpl__EffectiveDate__c >=: effectiveDate AND zpl__Contract__c = :contract.Id AND Name = :newLine.Name ORDER BY zpl__EffectiveDate__c ASC];
            
            try {            
                if(existingLines != null && existingLines.size() > 0) {
                    AIQPESService.cancel(userId, existingLines);
                    upsert existingLines;                   
                    result = new AIQAddLineResponse (2,'Publish line(s) exist with future effective date were cancelled.');
                } 
                
                zpl__ContractLineItem__c newLineUpsert = [SELECT Id, Name, zpl__Status__c, zpl__EffectiveDate__c, zpl__Contract__c,  zpl__PolicyType__c, zpl__PolicyValue__c, RecordTypeId, PublishedScore__c, CurrentScore__c FROM zpl__ContractLineItem__c WHERE Id =:newLine.Id];
                AIQPESService.publish(userId, newLineUpsert);
                upsert newLineUpsert;
                
            } catch (Exception ex)  {
                System.debug(ex);
                throw ex;
            }
            
        } else {
            result = new AIQAddLineResponse(4,'Account not found.');
        }
        return result;
    }  
    

    global static AIQPriceRecommendation getRecommendationForProspect (     
        String distributionChannel,
        String systemId,
        String primaryDivision,
        String division,
        String customerSpend,
        String averageOrderSize,
        String naics,
        String productCode,
        Decimal lineSizePR,
        String qtyUom)
    {   
        return AIQPriceAPIClient.getRecommendation(distributionChannel,systemId,primaryDivision,division,customerSpend,averageOrderSize,naics,productCode,lineSizePR,qtyUom);
    }
    
    
    global static List<AIQApproveRejectLineResponse> approveAgrLine(Id agrLineId) {   
        AIQServiceInterface intf = new AIQService();        
        return intf.approveAgrLine(new List<Id>{agrLineId});
    }
    
    global static List<AIQApproveRejectLineResponse> approveAgrLine(List<Id> agrLineIds) {
        Id userId = UserInfo.getUserId();       
        List<zpl__ContractLineItem__c> agrLineUpdates = new List<zpl__ContractLineItem__c>();
        List<Contract> agrUpdates = new List<Contract>();
        List<AIQApproveRejectLineResponse> results = new List<AIQApproveRejectLineResponse>();
        List<Id> campAppealedlines = new List<Id>();

        List<zpl__ContractLineItem__c> agrLines = getAgrLine(agrLineIds);

        for(zpl__ContractLineItem__c agrLine: agrLines) {
            if (agrLine.RecordType.Name != 'Draft' && agrLine.zpl__Status__c != 'Pend Appr') {
                AIQco_Logger.getInstance().log(UPDATE_AGREEMENT_LINE_EXCEPTION, agrLine.zpl__Contract__c, AIQco_Logger.MessageType.ERROR);
                results.add(new AIQApproveRejectLineResponse (agrLine.Id,'1','Only Pending Approval line can be approved'));
                continue;
            }     
            agrLine.RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId();
            agrLine.zpl__Status__c = 'Published';
            agrLine.PublishedScore__c = agrLine.CurrentScore__c;
            agrLine.PublishedPrice__c = agrLine.Net_Price__c;
            agrLine.PublishedCost__c = (agrLine.FuturePricingCostDate__c != null && agrLine.zpl__EffectiveDate__c >= agrLine.FuturePricingCostDate__c ? agrLine.FuturePricingCost__c : agrLine.PricingCost__c);
            agrLine.PublishedNVStart__c = agrLine.NV_Start__c;
            agrLine.PublishedNVTarget__c = agrLine.NV_Target__c;
            agrLine.PublishedNVFloor__c = agrLine.NV_Floor__c;
            agrLine.Approved_By__c = userId;
            agrLine.Approved_Date__c = system.now();
            agrLineUpdates.add(agrLine);
            Contract agrmnt = new Contract(id=agrLine.zpl__Contract__c);
            agrUpdates.add(agrmnt);
            results.add(new AIQApproveRejectLineResponse (agrLine.Id,'0','Line has been approved'));

            if (agrLine.get('CampaignAppealedLine__c')!=null && !campAppealedlines.contains(agrLine.CampaignAppealedLine__c)) {
                campAppealedlines.add(agrLine.CampaignAppealedLine__c);
            }
            
        }
        
        if (campAppealedlines.size() > 0) {
            agrLineUpdates.addAll(getCanceledLine(campAppealedlines));
        }

        if (agrLineUpdates.size() > 0) {
            results.addAll(updateAgreementLines(agrLineUpdates));
        }
        return  results;
    }
    
    
    global static List<AIQApproveRejectLineResponse> rejectAgrLine(Id agrLineId) {   
        AIQServiceInterface intf = new AIQService();        
        return intf.rejectAgrLine(new List<Id> {agrLineId});
    }
    
    global static List<AIQApproveRejectLineResponse> rejectAgrLine(List<Id> agrLineIds) {
        Id userId = UserInfo.getUserId();       
        List<zpl__ContractLineItem__c> agrLineUpdates = new List<zpl__ContractLineItem__c>();
        List<AIQApproveRejectLineResponse> results = new List<AIQApproveRejectLineResponse>();
        List<Id> campAppealedlines = new List<Id>();

        List<zpl__ContractLineItem__c> agrLines = getAgrLine(agrLineIds);
        
        for(zpl__ContractLineItem__c agrLine: agrLines)
        {
            if(agrLine.RecordType.Name !='Draft' && agrLine.zpl__Status__c != 'Pend Appr') {
                AIQco_Logger.getInstance().log(UPDATE_AGREEMENT_LINE_EXCEPTION, agrLine.zpl__Contract__c, AIQco_Logger.MessageType.ERROR);
                results.add(new AIQApproveRejectLineResponse (agrLine.Id,'1','Only Pending Approval line can be rejected'));
                continue;
            }             
            agrLine.RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();
            agrLine.zpl__Status__c = 'Draft';
            agrLine.Rejected_By__c = userId;
            agrLine.Rejected_Date__c = system.now();
            agrLine.Pending_Approval_Date_From__c = null;
            agrLine.PublishedScore__c = null;
            agrLine.Published_By__c = null;
            agrLine.Publish_Date__c = null;
            agrLine.Approved_By__c = null;
            agrLine.Approved_Date__c = null;
            agrLineUpdates.add(agrLine);
            results.add(new AIQApproveRejectLineResponse (agrLine.Id,'0','Line has ben rejected'));

            if (agrLine.get('CampaignAppealedLine__c')!=null && !campAppealedlines.contains(agrLine.CampaignAppealedLine__c)) {
                campAppealedlines.add(agrLine.CampaignAppealedLine__c);
            }                
        }
        
        if (campAppealedlines.size() > 0) {
            agrLineUpdates.addAll(getRecoveredLine(campAppealedlines));
        }
        
        if (agrLineUpdates.size() > 0) {
            results.addAll(updateAgreementLines(agrLineUpdates));
        }
        
        return  results;
    }

    
    /**
     *    cancel appealed campaign lines
     */   
    private static List<zpl__ContractLineItem__c> getCanceledLine(List<Id> agrLineId)
    {          

        List<zpl__ContractLineItem__c> agrLinesUpdate = getAgrLine(agrLineId);
        for (zpl__ContractLineItem__c line : agrLinesUpdate){
            line.zpl__Status__c = 'Deleted Camp';
            line.RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Inactive').getRecordTypeId();
            line.isCurrent__c = false;
            line.SupersededDate__c = System.now();
            line.Inactivated_By__c = UserInfo.getUserId();
            line.Inactivated_Date__c = System.now();
        }
        return agrLinesUpdate;
    }


    /**
     *    recover appealed campaign lines
     */  
    private static List<zpl__ContractLineItem__c> getRecoveredLine(List<Id> agrLineId)
    {          

        List<zpl__ContractLineItem__c> agrLinesUpdate = getAgrLine(agrLineId);
        for (zpl__ContractLineItem__c line : agrLinesUpdate){
            line.zpl__Status__c = 'Published';
            line.Inactivated_By__c = null;
            line.Inactivated_Date__c = null;
        }
        return agrLinesUpdate;
    }

    public static List<zpl__ContractLineItem__c> resolveNAConflict(List<zpl__ContractLineItem__c> agreementLines){
        
        Set<Id> agrIdsSet = new Set<Id>();
        Set<String> agrSKUsSet = new Set<String>();
        Set<String> agrSystemSet = new Set<String>();

        for (zpl__ContractLineItem__c agrLine: agreementLines)
        {
            agrIdsSet.add(agrLine.zpl__Contract__c);
            agrSKUsSet.add(agrLine.SKU__c);   
        }

        List<Contract> listAgrmntsWithNA = new List<Contract>();
        if(!agrIdsSet.isEmpty()){
            for(List<Contract> batchAgrmntsWithNA : [SELECT Id, National_Account__c, System__c
                                                    FROM Contract 
                                                    WHERE Id in: agrIdsSet 
                                                    AND RecordType.Name = 'Pricing Contract' 
                                                    AND (National_Account__c!=null
                                                        OR National_Account__c!='')])
            {
                listAgrmntsWithNA.addAll(batchAgrmntsWithNA);
            }
        }

        Map<Id,String> mapAgrmntIdNA = new Map<Id,String>();
        Map<Id,String> mapAgrmntIdSystem = new Map<Id,String>();

        Map<zpl__ContractLineItem__c, String> mapAgrmntLineNA = new Map<zpl__ContractLineItem__c, String>();
        List<NationalAccountsPricing__c> ListNAPricing = new List<NationalAccountsPricing__c>();

        if(listAgrmntsWithNA.size()>0)
        {
            for(Contract agrmnt : listAgrmntsWithNA)
            {
                mapAgrmntIdNA.put(agrmnt.Id, agrmnt.National_Account__c);
                agrSystemSet.add(agrmnt.System__c);
                mapAgrmntIdSystem.put(agrmnt.Id, agrmnt.System__c);

            }

            for(zpl__ContractLineItem__c agrmntLine: agreementLines)
            {
                if(mapAgrmntIdNA.containsKey(agrmntLine.zpl__Contract__c) && !mapAgrmntLineNA.containsKey(agrmntLine))
                {
                    mapAgrmntLineNA.put(agrmntLine, mapAgrmntIdNA.get(agrmntLine.zpl__Contract__c));
                } 
            }
            
            if(mapAgrmntIdNA.size() > 0) 
            {            
                for( List<NationalAccountsPricing__c> batchNAPricing : [SELECT Id, Name, NationalAccountGroupID__c, SystemCode__c 
                                                                        FROM NationalAccountsPricing__c 
                                                                        WHERE NationalAccountGroupID__c IN :mapAgrmntIdNA.values() 
                                                                        AND Name IN : agrSKUsSet
                                                                        AND SystemCode__c IN : agrSystemSet
                                                                        ])
                {
                    ListNAPricing.addAll(batchNAPricing);
                }
            }
        }
   
        Map<String,List<String>> mapNASKU = new Map<String,List<String>>();
        
        if(ListNAPricing.size() > 0)
        {           
            for(NationalAccountsPricing__c naPricing: ListNAPricing)
            {
                if(!mapNASKU.containsKey(naPricing.NationalAccountGroupID__c))
                {
                    mapNASKU.put(naPricing.NationalAccountGroupID__c, new List<String>{naPricing.SystemCode__c+naPricing.Name});
                } else
                {
                    mapNASKU.get(naPricing.NationalAccountGroupID__c).add(naPricing.SystemCode__c+naPricing.Name);
                }               
            }
        }

        List<zpl__ContractLineItem__c> updateList = new List<zpl__ContractLineItem__c>();
        
        if(mapAgrmntLineNA.size()>0)
        {
            Map<Id,zpl__PolicyType__c> naPolicyType = new Map<Id,zpl__PolicyType__c>([SELECT Id FROM zpl__PolicyType__c WHERE zpl__PolicyTypeId__c='nationalAccount' LIMIT 1]);
            if(naPolicyType.isEmpty()){
                throw new AIQServiceException('National Account policy type is not available');
            }
            
            for(zpl__ContractLineItem__c lineKey : mapAgrmntLineNA.keySet())
            {
                if(mapNASKU.containsKey(mapAgrmntLineNA.get(lineKey)))
                {
                    for(String item: mapNASKU.get(mapAgrmntLineNA.get(lineKey)))
                    {
                        if(item==mapAgrmntIdSystem.get(lineKey.zpl__Contract__c)+lineKey.SKU__c
                        && (lineKey.zpl__PolicyType__c==null || lineKey.zpl__PolicyType__c!=naPolicyType.values()[0].Id))
                        {
                            lineKey.IsNAPriced__c = true;
                            lineKey.zpl__PolicyValue__c = null;
                            lineKey.Net_Price__c = 0;
                            lineKey.zpl__PolicyType__c = naPolicyType.values()[0].Id;

                            updateList.add(lineKey);
                        }
                    }
                }
                
            }

        }
        return updateList;
    }
    
    @AuraEnabled
    public static List<zpl__ContractLineItem__c> getAgrLine(List<Id> agrLineId) {
        //is accessble check need to be added here as aura does not support FLS and CRUD check
        List<zpl__ContractLineItem__c> agrLine = new List<zpl__ContractLineItem__c>();
        try {
            List<String> listOfColumns = new List<String>{
                'Name',
                    'zpl__ContractLineItemId__c',
                    'zpl__Contract__c',
                    'Brand__c',
                    'Class__c',
                    'DefaultPolicyType__c',
                    'Division_Code2__c',
                    'Nullable__c',
                    'Set__c',
                    'SKU__c',
                    'Subset__c',
                    'System__c',
                    'zpl__Product__c',
                    'zpl__UOM__c',
                    'zpl__PolicyType__c',
                    'zpl__PolicyValue__c',
                    'zpl__Status__c',
                    'RecordTypeId',
                    'RecordType.Name',
                    'Published_By__c',
                    'Publish_Date__c',
                    'CurrentScore__c',
                    'Approved_By__c',
                    'zpl__EffectiveDate__c',
                    'CBSSItemGroupingKey__c',
                    'zpl__Contract__r.AccountId',
                    'zpl__Contract__r.Account.Primary_Sales_Rep_Name__r.SF_userid__r.Id',
                    'ConversionFactorCurrent__c',
                    'Net_Price__c',
                    'PricingCost__c',
                    'NV_Start__c',
                    'NV_Target__c',
                    'NV_Floor__c',
                    'PublishedScore__c',
                    'zpl__LineLevel__c',
                    'CampaignAppealedLine__c',
                    'ListPrice__c'
                    };

            List<Id> listOfValues = new List<Id>(agrLineId);

            String selectColumns = String.join(listOfColumns, ',');
            zal.SoqlBuilder soqlBuilder = new zal.SoqlBuilder()
                .selectx(selectColumns)
                .fromx('zpl__ContractLineItem__c')
                .wherex(new zal.SetCondition('Id', zal.Operator.INX, listOfValues));
            agrLine = Database.query(soqlBuilder.toSoql());
        } catch (Exception e) {
            throw zpf.AuraHandledExceptionUtil.handleException(e);
        }
        return agrLine;
    }

    @TestVisible
    private static List<AIQApproveRejectLineResponse> updateAgreementLines(List<zpl__ContractLineItem__c> agrLineUpdates) {
        List<Database.SaveResult> saveResults = databaseUtil.updateRecords(agrLineUpdates, false);
        Map<Id, String> failedRecordsMap = databaseUtil.getFailedRecordsMap(saveResults, agrLineUpdates);
        if (failedRecordsMap.isEmpty()) {
            return new List<AIQApproveRejectLineResponse>();
        }

        return getFailedResponsesAndAsyncRetry(agrLineUpdates, failedRecordsMap);
    }

    @TestVisible
    private static List<AIQApproveRejectLineResponse> getFailedResponsesAndAsyncRetry(List<zpl__ContractLineItem__c> agrLineUpdates, Map<Id, String> failedRecordsMap) {
        List<AIQApproveRejectLineResponse> results = new List<AIQApproveRejectLineResponse>();
        Map<Id, zpl__ContractLineItem__c> contractLinesMap = new Map<Id, zpl__ContractLineItem__c>(agrLineUpdates);
        List<zpl__ContractLineItem__c> failedLinesForRetry = new List<zpl__ContractLineItem__c>();
        Integer cpuLimitForRetry = (Integer) AIQZilliantConfiguration__c.getInstance().aiq_CpuLimitForRetry__c != null 
            ? (Integer) AIQZilliantConfiguration__c.getInstance().aiq_CpuLimitForRetry__c : 0;
        AIQco_Logger logger = AIQco_Logger.getInstance(AIQService.class.getName());

        for (Id id : failedRecordsMap.keySet()) {
            logger.addLogInQueue(UPDATE_AGREEMENT_LINE_EXCEPTION, failedRecordsMap.get(Id), 'ERROR', id);
            results.add(new AIQApproveRejectLineResponse ('','-1',failedRecordsMap.get(Id)));
            failedLinesForRetry.add(contractLinesMap.get(Id));
        }
        logger.publishLogQueue();

        if (Limits.getCpuTime() < cpuLimitForRetry) {           
            databaseUtil.updateRecordsWithAsyncRetry(failedLinesForRetry, false);
        }
        
        return results;
    }
}
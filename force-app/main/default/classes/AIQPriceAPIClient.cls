public class AIQPriceAPIClient {

    public class AIQFormulaAPIEvaluationException extends Exception{}
    public class AIQPostEvaluationUpdateException extends Exception{}
    
    public static AIQPriceRecommendation getRecommendation (    	
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
        String queryParams = '';
        if(qtyUom!=null && qtyUom !='' && lineSizePR!=null && lineSizePR!=0)
        {
            queryParams='f_getzDistChnlCode='+distributionChannel+'&';
            queryParams+='f_LegacySystemDivision='+(systemId=='SW'?'03':systemId)+division+'&';
            queryParams+='f_MifItemNo='+productCode.left(8)+'&';      
            queryParams+='f_getCustomerSpendBin='+customerSpend+'&';
            queryParams+='f_getNaicsGroup='+naics+'&';
            queryParams+='f_QtyRawInputPR='+lineSizePR+'&';
            queryParams+='f_QtyUomRawInputPR='+qtyUom+'&';
            queryParams+='f_ProductId='+systemId+division+productCode+'&';            
            queryParams+='f_LegacySystemAccount='+null;
        } else
        {
            queryParams='f_getzDistChnlCode='+distributionChannel+'&';
            queryParams+='f_LegacySystemDivision='+(systemId=='SW'?'03':systemId)+division+'&';
            queryParams+='f_MifItemNo='+productCode.left(8)+'&';      
            queryParams+='f_getCustomerSpendBin='+customerSpend+'&';
            queryParams+='f_getOrderLineSizeBin='+ (averageOrderSize==null || averageOrderSize=='' ? '1:Low' : averageOrderSize) +'&';
            queryParams+='f_getNaicsGroup='+naics;
        }
        String formula = AIQZilliantConfiguration__c.getInstance().GetRecommendationsFormula__c;
        String res = AIQZilliantAPIConnector.evaluateFormulas(formula.trim(), queryParams, null);
        Map<String,String[]> resMap = (Map<String,String[]>)JSON.deserialize(res,Map<String,String[]>.class);
        
        return new AIQPriceRecommendation(
            resMap.get('f_getRecOptSegID')==null ? null : resMap.get('f_getRecOptSegID').get(0), 
            resMap.get('f_getNVStart')==null ? null : Decimal.valueOf(resMap.get('f_getNVStart').get(0)) , 
            resMap.get('f_getNVTarget')==null ? null : Decimal.valueOf(resMap.get('f_getNVTarget').get(0)), 
            resMap.get('f_getNVFloor')==null ? null : Decimal.valueOf(resMap.get('f_getNVFloor').get(0)),
            (resMap.get('Status')!=null || resMap.get('Error')!=null) ? res : JSON.serializePretty('{"Status": ["OK"], "StatusCode": ["200"]}').replace('\\', '').replace('"{', '{').replace('}"', '}')
        );
    }

   
    public static void evaluateLines(List<zpl__ContractLineItem__c> lines, String formulaName, Schema.SObjectType sobjType){
        
        String enabledLineLevelString = AIQZilliantConfiguration__c.getInstance().FESEnabledLineLevel__c;
        List<String> enabledLineLevels = new List<String>();
        if(!String.isBlank(enabledLineLevelString)){
            List<String> configItemsDirty = new List<String>();
            configItemsDirty.addAll(enabledLineLevelString.replaceAll('(\\r|\\n)+', ',').split(','));

            for(String strItem : configItemsDirty){
                enabledLineLevels.add(strItem.trim());
            }
        }

        Map<Id,zpl__LineLevel__c> lineLevels = new Map<Id,zpl__LineLevel__c>([SELECT Id, Name FROM zpl__LineLevel__c WHERE Name in: enabledLineLevels]);
          
        List<zpl__ContractLineItem__c> linesToEvaluate = new List<zpl__ContractLineItem__c>();
        List<Id> linesToEvaluateIds = new List<Id>();
        List<zpl__ContractLineItem__c> linesToRetain = new List<zpl__ContractLineItem__c>();

        for(zpl__ContractLineItem__c line : lines){
            if(lineLevels.keySet().contains(line.zpl__LineLevel__c)){
                linesToEvaluate.add(line);
                linesToEvaluateIds.add(line.Id);
            }else{
                linesToRetain.add(line);
            }
        }
        
        List<zpl__ContractLineItem__c> evaluatedLines = new List<zpl__ContractLineItem__c>();

        try{
            zpl.FormulaEvaluator evaluator = zpl.FormulaEvaluatorFactory.getInstance(formulaName, sobjType);
            evaluatedLines = (List<zpl__ContractLineItem__c>) evaluator.evaluate(linesToEvaluateIds);
        }catch(Exception e){
            throw new AIQFormulaAPIEvaluationException(e.getMessage() + ', '+ e.getStackTraceString());
        }

        if(evaluatedLines.size()>0)
        {
            Savepoint sp = Database.setSavepoint();
            try{
                zpf.DatabaseUtil.updateObjects(evaluatedLines);
                
            } catch(Exception e)
            {
                Database.rollback(sp);
                throw new AIQPostEvaluationUpdateException(e.getMessage() + ', '+ e.getStackTraceString());
            }
        }
        
    }

    public static List<zpl__ContractLineItem__c> evaluateLines(List<zpl__ContractLineItem__c> lines, String formulaName, String sobjTypeName){
        
        String enabledLineLevelString = AIQZilliantConfiguration__c.getInstance().FESEnabledLineLevel__c;
        List<String> enabledLineLevels = new List<String>();
        if(!String.isBlank(enabledLineLevelString)){
            List<String> configItemsDirty = new List<String>();
            configItemsDirty.addAll(enabledLineLevelString.replaceAll('(\\r|\\n)+', ',').split(','));

            for(String strItem : configItemsDirty){
                enabledLineLevels.add(strItem.trim());
            }
        }

        Map<Id,zpl__LineLevel__c> lineLevels = new Map<Id,zpl__LineLevel__c>([SELECT Id, Name FROM zpl__LineLevel__c WHERE Name in: enabledLineLevels]);
          
        List<zpl__ContractLineItem__c> linesToEvaluate = new List<zpl__ContractLineItem__c>();
        List<zpl__ContractLineItem__c> linesToRetain = new List<zpl__ContractLineItem__c>();

        for(zpl__ContractLineItem__c line : lines){
            if(lineLevels.keySet().contains(line.zpl__LineLevel__c)){
                linesToEvaluate.add(line);
            }else{
                linesToRetain.add(line);
            }
        }
 
        List<zpl__ContractLineItem__c> outputLines = new List<zpl__ContractLineItem__c>();

        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(sobjTypeName);
        try{
            zpl.FormulaEvaluator evaluator = zpl.FormulaEvaluatorFactory.getInstance(formulaName, sobjType);
            outputLines = (List<zpl__ContractLineItem__c>) evaluator.evaluate(linesToEvaluate);
        }catch(Exception e){
            throw new AIQFormulaAPIEvaluationException(e.getMessage() + ', '+ e.getStackTraceString());
        }

        outputLines.addAll(linesToRetain);

        return outputLines;

    }
     
    
}
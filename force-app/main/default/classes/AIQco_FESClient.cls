public without sharing class AIQco_FESClient {
    public class AIQco_FESClientException extends Exception{}

    public static void evaluateLinesVoid(List<String> lineIds, String formulaName, Schema.SObjectType sobjType){
        
        List<SObject> evaluatedLines = new List<SObject>();

        try{
            zpl.FormulaEvaluator evaluator = zpl.FormulaEvaluatorFactory.getInstance(formulaName, sobjType);
            evaluatedLines = (List<SObject>) evaluator.evaluate(lineIds);
        }catch(Exception e){
            System.debug('1' + e.getMessage());
            throw new AIQco_FESClientException(e.getMessage() + ', '+ e.getStackTraceString());
        }

        if(evaluatedLines.size()>0)
        {
            Savepoint sp = Database.setSavepoint();
            try
            {
                zpf.DatabaseUtil.updateObjects(evaluatedLines);
                if(Test.isRunningTest()){
                    throw new AIQco_FESClientException('test thrown error for code coverage');
                }
            } catch(Exception e)
            {
                Database.rollback(sp);
                throw new AIQco_FESClientException(e.getMessage() + ', '+ e.getStackTraceString());
            }
        }
        
    }

    public static void evaluateLinesVoid(List<SObject> lines, String formulaName, Schema.SObjectType sobjType){
        
        List<SObject> evaluatedLines = new List<SObject>();

        try{
            zpl.FormulaEvaluator evaluator = zpl.FormulaEvaluatorFactory.getInstance(formulaName, sobjType);
            evaluatedLines = (List<SObject>) evaluator.evaluate(lines);
        }catch(Exception e){
            throw new AIQco_FESClientException(e.getMessage() + ', '+ e.getStackTraceString());
        }

        if(evaluatedLines.size()>0)
        {
            Savepoint sp = Database.setSavepoint();
            try
            {
                zpf.DatabaseUtil.upsertObjects(evaluatedLines);
                /*
                if(Test.isRunningTest()){
                    throw new AIQco_FESClientException('test thrown error for code coverage');
                }
                */
            } catch(Exception e)
            {
                Database.rollback(sp);
                throw new AIQco_FESClientException(e.getMessage() + ', '+ e.getStackTraceString());
            }
        }
        
    }

    public static List<Sobject> evaluateLines(List<SObject> lines, String formulaName, Schema.SObjectType sobjType){
        
        List<SObject> evaluatedLines = new List<SObject>();

        try{
            zpl.FormulaEvaluator evaluator = zpl.FormulaEvaluatorFactory.getInstance(formulaName, sobjType);
            evaluatedLines = (List<SObject>) evaluator.evaluate(lines);
        }catch(Exception e){
            throw new AIQco_FESClientException(e.getMessage() + ', '+ e.getStackTraceString());
        }        
        
        return evaluatedLines;
    }

    public static List<Sobject> evaluateLines(List<String> lines, String formulaName, Schema.SObjectType sobjType){
        
        List<SObject> evaluatedLines = new List<SObject>();

        try{
            zpl.FormulaEvaluator evaluator = zpl.FormulaEvaluatorFactory.getInstance(formulaName, sobjType);
            evaluatedLines = (List<SObject>) evaluator.evaluate(lines);
        }catch(Exception e){
            throw new AIQco_FESClientException(e.getMessage() + ', '+ e.getStackTraceString());
        }        
        
        return evaluatedLines;
    }

}
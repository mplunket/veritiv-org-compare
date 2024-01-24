public inherited sharing class AIQ_FormulaEvaluatorUtil {
    private static Map<Id, zpl__LineLevel__c> iqaEnabledLineLevels = getIQAEnabledLineLevels();
    @TestVisible
    private AIQco_FormulaEvaluator evaluator = new AIQco_FormulaEvaluator();

    public List<zpl__ContractLineItem__c> evaluateLines(
        String iqaConfigurationName,
        Schema.SobjectType objectType,
        List<zpl__ContractLineItem__c> lines
    ) {
        List<Id> fesEnabledLineIds = new List<Id>();
        for (zpl__ContractLineItem__c line : lines) {
            if (iqaEnabledLineLevels.containsKey(line.zpl__LineLevel__c)) {
                fesEnabledLineIds.add(line.Id);
            }
        }
        return (List<zpl__ContractLineItem__c>) evaluator.evaluate(iqaConfigurationName, objectType, fesEnabledLineIds);
    }

    private static Map<Id, zpl__LineLevel__c> getIQAEnabledLineLevels() {
        String enabledLineLevelString = AIQZilliantConfiguration__c.getInstance().FESEnabledLineLevel__c;
        List<String> enabledLineLevels = new List<String>();
        if (!String.isBlank(enabledLineLevelString)) {
            List<String> configItemsDirty = new List<String>();
            configItemsDirty.addAll(enabledLineLevelString.replaceAll('(\\r|\\n)+', ',').split(','));

            for (String strItem : configItemsDirty) {
                enabledLineLevels.add(strItem.trim());
            }
        }
        Map<Id, zpl__LineLevel__c> lineLevels = new Map<Id, zpl__LineLevel__c>(
            [SELECT Id, Name FROM zpl__LineLevel__c WHERE Name IN :enabledLineLevels]
        );

        return lineLevels;
    }
}
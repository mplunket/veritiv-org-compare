public inherited sharing class AIQ_CBSSIPriorToCurrentConvertor {
    public static final String LIST_DOWN = 'listDown';
    public static final String MAINTAIN_GTM = 'maintainGTM';

    public static void convert(
        zpl__ContractLineItem__c lineToUpdate,
        zpl__ContractLineItem__c currentLine,
        zpl__ContractLineItem__c priorLine
    ) {
        AIQco_Precondition.checkNotNull(currentLine, 'Current line is null');
        Decimal currentConversionFactor = AIQ_CommonUtil.nullToZero(currentLine.zpl__UOM__r.zpl__ConversionFactor__c);
        Decimal priorConversionFactor = AIQ_CommonUtil.nullToZero(priorLine.zpl__UOM__r.zpl__ConversionFactor__c);
        Decimal priorPrice = AIQ_CommonUtil.nullToZero(priorLine.PublishedPrice__c);
        Decimal priorCost = AIQ_CommonUtil.nullToZero(priorLine.PublishedCost__c);

        if (priorConversionFactor == currentConversionFactor) {
            priorPrice = priorPrice;
            priorCost = priorCost;
        } else if (priorConversionFactor < 0 && currentConversionFactor > 0) {
            priorPrice = (priorPrice * Math.abs(priorConversionFactor) * Math.abs(currentConversionFactor));
            priorCost = (priorCost * Math.abs(priorConversionFactor) * Math.abs(currentConversionFactor));
        } else if (priorConversionFactor < 0 && currentConversionFactor < 0) {
            priorPrice = (priorPrice * Math.abs(priorConversionFactor) / Math.abs(currentConversionFactor));
            priorCost = (priorCost * Math.abs(priorConversionFactor) / Math.abs(currentConversionFactor));
        } else if (priorConversionFactor > 0 && currentConversionFactor < 0) {
            priorPrice = (priorPrice / Math.abs(priorConversionFactor) / Math.abs(currentConversionFactor));
            priorCost = (priorCost / Math.abs(priorConversionFactor) / Math.abs(currentConversionFactor));
        } else if (priorConversionFactor > 0 && currentConversionFactor > 0) {
            priorPrice = (priorPrice / Math.abs(priorConversionFactor) * Math.abs(currentConversionFactor));
            priorCost = (priorCost / Math.abs(priorConversionFactor) * Math.abs(currentConversionFactor));
        }
        lineToUpdate.PreviousPrice__c = priorPrice.setScale(4);
        lineToUpdate.PreviousCost__c = priorCost.setScale(4);
        lineToUpdate.PreviousValue__c = currentLine.zpl__PolicyType__r.zpl__PolicyTypeId__c == MAINTAIN_GTM
            ? getPublishedMargin(priorLine)
            : currentLine.zpl__PolicyType__r.zpl__PolicyTypeId__c == LIST_DOWN ? getPublishedDiscount(priorLine) : priorPrice;
        lineToUpdate.X12MonthSalesVolume__c = AIQ_CommonUtil.nullToZero(currentLine.X12MonthSalesVolume__c) == 0
            ? AIQ_CommonUtil.nullToZero(priorLine.X12MonthSalesVolume__c)
            : currentLine.X12MonthSalesVolume__c;
    }

    private static Decimal getPublishedMargin(zpl__ContractLineItem__c line) {
        return line.PublishedPrice__c != 0 &&
            line.PublishedPrice__c != null
            ? (1 - line.PublishedCost__c / line.PublishedPrice__c).setScale(6)
            : line.zpl__policyType__r.zpl__PolicyTypeId__c == MAINTAIN_GTM ? line.zpl__PolicyValue__c : 0;
    }

    private static Decimal getPublishedDiscount(zpl__ContractLineItem__c line) {
        return line.ListPrice__c != 0 &&
            line.ListPrice__c != null
            ? (line.PublishedPrice__c / line.ListPrice__c - 1).setScale(6)
            : line.zpl__policyType__r.zpl__PolicyTypeId__c == LIST_DOWN ? line.zpl__PolicyValue__c : 0;
    }
}
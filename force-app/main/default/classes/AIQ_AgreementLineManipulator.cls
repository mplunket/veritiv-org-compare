public without sharing class AIQ_AgreementLineManipulator {
    public static void stripAgreementLine(List<zpl__ContractLineItem__c> agrLines) {
        for (zpl__ContractLineItem__c agrLineNew : agrLines) {
            agrLineNew.zpl__Status__c = 'Draft';
            agrLineNew.RecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
                .get('Draft')
                .getRecordTypeId();
            agrLineNew.zpl__EffectiveDate__c = (agrLineNew.zpl__EffectiveDate__c > Date.today()
                ? agrLineNew.zpl__EffectiveDate__c
                : Date.today());
            agrLineNew.PublishedScore__c = null;
            agrLineNew.Approved_By__c = null;
            agrLineNew.Approved_Date__c = null;
            agrLineNew.Published_By__c = null;
            agrLineNew.Publish_Date__c = null;
            agrLineNew.PublishedScore__c = null;
            agrLineNew.PublishedPrice__c = null;
            agrLineNew.PublishedCost__c = null;
            agrLineNew.PublishedNVStart__c = null;
            agrLineNew.PublishedNVTarget__c = null;
            agrLineNew.PublishedNVFloor__c = null;
            agrLineNew.Rejected_By__c = null;
            agrLineNew.Rejected_Date__c = null;
            agrLineNew.Inactivated_By__c = null;
            agrLineNew.Inactivated_Date__c = null;
            agrLineNew.SupersededDate__c = null;
            agrLineNew.isCurrent__c = true;
            agrLineNew.Pending_Approval_Date_From__c = null;
            agrLineNew.LineSource__c = null;
            agrLineNew.PriceDecreaseFlag__c = false;
            agrLineNew.Reason_Code__c = null;
            agrLineNew.Comments__c = null;
            agrLineNew.PreviousPrice__c = null;
            agrLineNew.PreviousCost__c = null;
            agrLineNew.PreviousValue__c = null;

            //Campaign related fields
            if (agrLineNew.IsCampaign__c == true) {
                agrLineNew.InitiativeActionId__c = null;
                agrLineNew.CampaignName__c = null;
                agrLineNew.CampaignAppealedLine__r = new zpl__ContractLineItem__c(
                    zpl__ContractLineItemId__c = agrLineNew.zpl__ContractLineItemId__c
                );
                agrLineNew.IsCampaignAppealed__c = true; //need this field for Reason Code dependant picklist
                agrLineNew.CampaignEffectiveDate__c = null;
                agrLineNew.CampaignNewCost__c = null;
                agrLineNew.CampaignProposedPolicyType__c = null;
                agrLineNew.CampaignProposedValue__c = null;
                // Do not strip off the disallow date from lines when a user appeals a campaign line. Veritiv wants this to persist forward.
                //agrLineNew.DisallowCampaignsThroughDate__c = null;
                agrLineNew.Recommended_Price__c = agrLineNew.Net_Price__c;
                agrLineNew.Recommended_Cost__c = agrLineNew.PricingCost__c;
                agrLineNew.PriorConversionFactor__c = agrLineNew.ConversionFactorCurrent__c;
            } else {
                agrLineNew.CampaignAppealedLine__c = null;
                agrLineNew.IsCampaignAppealed__c = false;
            }

            //formula evaluetion input fields for getting guidance
            agrLineNew.SKU__c = (agrLineNew.SKU__c == null ? null : agrLineNew.SKU__c);
            agrLineNew.Subset__c = (agrLineNew.Subset__c == null ? null : agrLineNew.Subset__c);
            agrLineNew.Set__c = (agrLineNew.Set__c == null ? null : agrLineNew.Set__c);
            agrLineNew.Brand__c = (agrLineNew.Brand__c == null ? null : agrLineNew.Brand__c);
            agrLineNew.Class__c = (agrLineNew.Class__c == null ? null : agrLineNew.Class__c);
            agrLineNew.put('zpl__UOM__c', agrLineNew.get('zpl__UOM__c'));
            agrLineNew.put('zpl__Product__c', agrLineNew.get('zpl__Product__c'));
            agrLineNew.Recommended_Price__c = (agrLineNew.get('Recommended_Price__c') == null ? null : agrLineNew.Recommended_Price__c);
            agrLineNew.Recommended_Cost__c = (agrLineNew.get('Recommended_Cost__c') == null ? null : agrLineNew.Recommended_Cost__c);
            agrLineNew.PriorConversionFactor__c = (agrLineNew.get('PriorConversionFactor__c') == null
                ? null
                : agrLineNew.PriorConversionFactor__c);
            agrLineNew.zpl__PolicyValue__c = (agrLineNew.zpl__PolicyValue__c == null ? null : agrLineNew.zpl__PolicyValue__c);
            agrLineNew.X12MonthSalesVolume__c = (agrLineNew.X12MonthSalesVolume__c == null ? null : agrLineNew.X12MonthSalesVolume__c);

            //formula evaluetion output fields for getting guidance
            agrLineNew.Discount__c = null;
            agrLineNew.Floor_Price__c = null;
            agrLineNew.InternalCostDeviation__c = null;
            agrLineNew.InternalCostDeviationDate__c = null;
            agrLineNew.FuturePricingCost__c = null;
            agrLineNew.FuturePricingCostDate__c = null;
            agrLineNew.Margin__c = null;
            agrLineNew.Markup__c = null;
            agrLineNew.Net_Price__c = null;
            agrLineNew.zpl__PolicyType__c = (agrLineNew.zpl__PolicyType__c == null ? null : agrLineNew.zpl__PolicyType__c);
            agrLineNew.NV_Floor__c = null;
            agrLineNew.NV_Start__c = null;
            agrLineNew.NV_Target__c = null;
            agrLineNew.PricingCost__c = null;
            agrLineNew.ExternalCostDeviation__c = null;
            agrLineNew.ExternalCostDeviationDate__c = null;
            agrLineNew.OptimizationSegmentID__c = null;
            agrLineNew.Start_Price__c = null;
            agrLineNew.Current_Standard_Cost__c = null;
            agrLineNew.Target_Price__c = null;
            agrLineNew.zpl__ContractLineItemId__c = null;
            if (agrLineNew.get('Id') != null) {
                agrLineNew.put('Id', null);
            }
        }
    }
}
public with sharing class AIQ_CBSSIService {
    public static final Integer EFFECTIVE_DATE_HORIZON_DAYS = (Integer) AIQZilliantConfiguration__c.getInstance()?.EffectiveDateHorizon__c;
    public static final Date EFFECTIVE_DATE_HORIZON_DATE = Date.today().addDays(EFFECTIVE_DATE_HORIZON_DAYS == null ? 0 : -EFFECTIVE_DATE_HORIZON_DAYS);
    @TestVisible
    private AIQ_CBSSIGroupProvider cbssiGroupProvider;
    private List<AIQ_CBSSIGroupDomain> cbssiGroups;

    public AIQ_CBSSIService() {
        cbssiGroupProvider = new AIQ_CBSSIGroupProvider();
    }

    /**
     * @description alignBeforePublish used to populate prior cost, prior price and find price decrease for the lines being published
     * @param  agreementLines targeted agreement lines (being published)
     * @return                returns the list of the modified Contract Line Items
     */
    public List<zpl__ContractLineItem__c> alignBeforePublish(List<zpl__ContractLineItem__c> agreementLines) {
        this.cbssiGroups = cbssiGroupProvider.provide(
            agreementLines,
            new List<Id>{ AIQ_CBSSIGroupDomain.LINE_DRAFT_RECORD_TYPE_ID, AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID }
        );
        AIQco_Precondition.checkArgument(cbssiGroups.isEmpty(), 'CBSSI groups are not found');

        for (zpl__ContractLineItem__c agreementLine : agreementLines) {
            AIQ_CBSSIGroupDomain cbssiGroupCurrent = findCurrentGroup(agreementLine);
            zpl__ContractLineItem__c currentLine = cbssiGroupCurrent.getLine(agreementLine);
            zpl__ContractLineItem__c priorLine = cbssiGroupCurrent.getPriorLine(currentLine, EFFECTIVE_DATE_HORIZON_DATE);
            // no history for this product
            if (priorLine == null) {
                continue;
            }
            AIQ_CBSSIPriorToCurrentConvertor.convert(agreementLine, currentLine, priorLine);
            AIQ_CBSSIDecreaseFinder.getInstance(currentLine.zpl__PolicyType__r.zpl__PolicyTypeId__c).hasDecrease(agreementLine);
        }

        return agreementLines;
    }

    /**
     * @description alignAfterPublish used to realign CBSSI group lines after publish (when campaign lines are uploaded, some Active lines are deleted etc.)
     * @param  agreementLines targeted agreement lines (already published)
     * @return                returns the list of the modified Contract Line Items out of the CBBSSI group
     */
    public List<zpl__ContractLineItem__c> alignAfterPublish(List<zpl__ContractLineItem__c> agreementLines) {
        this.cbssiGroups = cbssiGroupProvider.provide(agreementLines, new List<Id>{ AIQ_CBSSIGroupDomain.LINE_ACTIVE_RECORD_TYPE_ID });
        AIQco_Precondition.checkArgument(cbssiGroups.isEmpty(), 'CBSSI groups are not found');

        Set<zpl__ContractLineItem__c> linesForUpdate = new Set<zpl__ContractLineItem__c>();
        for (zpl__ContractLineItem__c agreementLine : agreementLines) {
            linesForUpdate.addAll(findCurrentGroup(agreementLine).realign(agreementLine).getChangedLinesWithoutOriginal());
        }

        return new List<zpl__ContractLineItem__c>(linesForUpdate);
    }

    private AIQ_CBSSIGroupDomain findCurrentGroup(zpl__ContractLineItem__c agreementLine) {
        AIQ_CBSSIGroupDomain cbssiGroupCurrent = cbssiGroups.get(
            cbssiGroups.indexOf(new AIQ_CBSSIGroupDomain(agreementLine.CBSSItemGroupingKey__c))
        );
        AIQco_Precondition.checkNotNull(cbssiGroupCurrent, 'Current CBSSI group is not found for ' + agreementLine.CBSSItemGroupingKey__c);
        return cbssiGroupCurrent;
    }


}
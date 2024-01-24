public inherited sharing class AIQ_ContractCopyUtil {
    public class AIQ_ContractCopyUtilException extends Exception {}

    @TestVisible
    private static final String CONTRACT_OBJECT_NAME = Schema.SObjectType.Contract.getName();
    private static final String DRAFT_STATUS = 'Draft';
    private static final String ACCOUNT_CHAIN_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Chain_Account')
        .getRecordTypeId();

    private final static List<String> SERVICING_DIVISION_QUERY_FIELDS = new List<String>{
        AIQ_GenericSelector.SERVICING_DIVISION_ID_FIELD_NAME,
        AIQ_GenericSelector.SERVICING_DIVISION_NAME_FIELD_NAME
    };
    @TestVisible
    private AIQco_SObjectUtil sObjectUtil = new AIQco_SObjectUtil();
    @TestVisible
    private AIQ_GenericSelector genericSelector = new AIQ_GenericSelector();
    @TestVisible
    private Contract cloneContract = new Contract();

    public AIQ_ContractCopyUtil copyContract(List<Id> recordIds, List<String> excludedFields) {
        cloneContract = (Contract) sObjectUtil.getClone(
            CONTRACT_OBJECT_NAME,
            recordIds,
            excludedFields,
            false
        ).get(0);
        return this;
    }

    public AIQ_ContractCopyUtil setClonedContract(Account acct) {
        cloneContract.AccountId = acct.id;
        cloneContract.Name = acct.Name;
        cloneContract.RecordTypeId = AIQ_Constants.CONTRACT_RT_PRICING_CONTRACT_ID;
        cloneContract.Status = DRAFT_STATUS;
        cloneContract.StartDate = Date.today();
        cloneContract.ContractTerm = 99;
        cloneContract.Account_Searchable__c = acct.Name;
        cloneContract.Account_Number_Searchable__c = acct.zpl__CustomerId__c;
        cloneContract.ExpContractLinesCount__c = null;
        cloneContract.ExpRebatesCount__c = null;
        cloneContract.X12MonthsRevenue__c = null;
        cloneContract.score__c = null;

        if (acct.RecordTypeId == ACCOUNT_CHAIN_ACCOUNT_RECORD_TYPE_ID) {
            Servicing_Division__c serviceDivision;
            try {
                List<Servicing_Division__c> serviceDivisions = genericSelector.queryServicingDivisionsByCompositeKey(
                    SERVICING_DIVISION_QUERY_FIELDS,
                    acct.Representative_Division__c,
                    1
                );
                if (serviceDivisions.isEmpty() || acct.Representative_Division__c == null) {
                    throw new AIQ_ContractCopyUtilException('Representative division not found');
                }
                serviceDivision = serviceDivisions.get(0);
            } catch(Exception e) {
                throw new AIQ_ContractCopyUtilException(e.getMessage());
            }
            cloneContract.zpl__ContractId__c = acct.zpl__CustomerId__c;
            cloneContract.Division__c = serviceDivision.Id;
            cloneContract.Division_Searchable__c = serviceDivision.Name;
        } else {
            cloneContract.zpl__ContractId__c = acct.zpl__CustomerId__c;
            cloneContract.Division__c = acct.Servicing_Division__c;
            cloneContract.Division_Searchable__c = acct.Servicing_Division__r.Name;
        }

        return this;
    }

    public Contract getCloneContract() {
        return this.cloneContract;
    }
}
global class AIQasync_LineAlignment implements Database.Batchable<sObject>, Database.Stateful {
    public class AIQasync_LineAlignmentException extends Exception {
    }
    private List<Object> jobMessages;
    private Boolean processAll = false;
    private String scopeQuery;
    private DateTime currentTime = Datetime.now();
    private List<String> notificationGroup;
    private Integer batchSize;

    public AIQasync_LineAlignment(List<String> notificationGroup, Integer batchSize) {
        this.notificationGroup = notificationGroup;
        this.jobMessages = new List<Object>();
        this.batchSize = batchSize;
    }

    public AIQasync_LineAlignment(List<String> notificationGroup, Boolean toProcessAll, String scopeQuery, Integer batchSize) {
        this.notificationGroup = notificationGroup;
        this.processAll = toProcessAll;
        this.scopeQuery = scopeQuery;
        this.jobMessages = new List<Object>();
        this.batchSize = batchSize;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 
        'SELECT '
            +'Id,'
            +'zpl__ContractLineItemId__c,'
            +'Name,'
            +'zpl__Contract__c,'
            +'CBSS__c,'
            +'zpl__Product__c,'
            +'zpl__EffectiveDate__c,'
            +'CBSSItemGroupingKey__c,'
            +'RecordType.Name,'
            +'zpl__Status__c,'
            +'Segment__c,'
            +'Division__c,'
            +'VendorCode__c,'
            +'Class__c,'
            +'Brand__c,'
            +'Set__c,'
            +'Subset__c,'
            +'SKU__c,'
            +'isCurrent__c,'
            +'SupersededDate__c,'
            +'PriceDecreaseFlag__c,'
            +'Net_Price__c,'
            +'CurrentScore__c,'
            +'zpl__UOM__c,'
            +'Publish_Date__c,'
            +'PublishedPrice__c,'
            +'PublishedCost__c,'
            +'X12MonthSalesVolume__c,'
            +'zpl__PolicyType__c,'
            +'ListPrice__c,'
            +'zpl__PolicyValue__c,'
            +'zpl__LineLevel__c,'
            +'CreatedDate '
        +'FROM zpl__ContractLineItem__c '
        +'WHERE RecordType.Name in (\'Active\')';
        
        if (!String.isBlank(scopeQuery)) {
            query = scopeQuery;
        } else if (!this.processAll) {
            query += ' AND zpl__EffectiveDate__c = ' + DateTime.now().format('yyyy-MM-dd');
        }

        system.debug('AIQBatchLineAlignment: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<zpl__ContractLineItem__c> scope) {
        if (!scope.isEmpty()) {
            try {
                // Post Processing moved to update trigger, fire update to trigger alignment
                update scope;
                if (Test.isRunningTest()) {
                    throw new AIQasync_LineAlignmentException();
                }
            } catch (System.Exception e) {
                this.jobMessages.add(new AIQasync_LineAlignmentException(e.getMessage()));
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        if (!jobMessages.isEmpty()) {
            new AIQco_Messenger('Veritiv DM: AIQasync_LineAlignment class errors', this.jobMessages, this.notificationGroup).send();
        }
    }
}
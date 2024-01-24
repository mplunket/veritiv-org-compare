public with sharing class AIQ_Constants {
    //external Ids
    public static final String ACCOUNT_EXTERNAL_ID = 'runAccountZcloudSync__c';
    public static final String CONTRACT_EXTERNAL_ID = 'runContractZCloudSync__c';
    public static final String PRODUCT_EXTERNAL_ID = 'runProductZCloudSync__c';
    public static final String PRODUCT_UOM_EXTERNAL_ID = 'runProductZCloudSync__c';

    //Contract record Types
    public static final String CONTRACT_RT_PRICING_CONTRACT = 'Pricing Contract';
    public static final String CONTRACT_RT_PRICING_CONTRACT_DEV_NAME = 'PricingContract';
    public static final String CONTRACT_RT_PRICING_CONTRACT_ID = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('PricingContract').getRecordTypeId();
    //Contract Line Item record types
    public static final String CLI_RT_INACTIVE = 'Inactive';
    public static final String CLI_RT_ACTIVE = 'Active';
    public static final String CLI_RT_DRAFT = 'Draft';
    public static final String CLI_RT_INACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Inactive').getRecordTypeId();
    public static final String CLI_RT_ACTIVE_ID = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Active').getRecordTypeId();
    public static final String CLI_RT_DRAFT_ID = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();


    //Contract Line Item statuses
    public static final String CLI_STATUS_DRAFT = 'Draft';
    public static final String CLI_STATUS_PEND_APPR = 'Pend Appr';
    public static final String CLI_STATUS_PEND_PUBL = 'Pend Publ';
    public static final String CLI_STATUS_PEND_CANCEL = 'Pend Cancel';
    public static final String CLI_STATUS_PUBLISHED = 'Published';
    public static final String CLI_STATUS_DELETED = 'Deleted';
    public static final String CLI_STATUS_CANCELLED_CAMP = 'Cancelled Camp';
    public static final String CLI_STATUS_NA_CONFLICT = 'NA Conflict';
    public static final String CLI_STATUS_DELETED_CAMP = 'Deleted Camp';
    public static final String CLI_STATUS_DELETED_BY_QUOTE = 'Deleted By Quote';
    public static final String CLI_STATUS_USER_VACATED = 'User Vacated';
    public static final String CLI_STATUS_CAMP_VACATED = 'Camp Vacated';


    //field set names
    public static final String ACCOUNT_SYNC_DOWN_FIELDSET_NAME = 'runAccountZcloudSync__c';
    
}
global with sharing class AIQ_DataFilterForNationalAccount implements zpf.ScopedRecordsFilterer, zpf.RecordsFilterer {
    final static String NATIONAL_ACCOUNT_GROUP_ID = 'NationalAccountGroupID__c';
    final static String SYSTEM_CODE = 'SystemCode__c';
    final static String NULL_STRING = 'null';

    global zal.Condition getScopedFilterCondition(Id headerRecordId, Map<String, Object> scope) {
        String nationalAccountGroup;
        String systemCode;
        List<Contract> contractList = [
            SELECT  National_Account__c,
                    System__c 
            FROM Contract 
            WHERE Id =: headerRecordId
            LIMIT 1
        ];

        if (contractList.size() > 0) {
            nationalAccountGroup = contractList[0].National_Account__c;
            systemCode = contractList[0].System__c;
        }   

        zal.AndCondition andCondition = new zal.AndCondition();
        if (nationalAccountGroup !=null && nationalAccountGroup != '') {
            andCondition.add(new zal.FieldCondition(NATIONAL_ACCOUNT_GROUP_ID, zal.Operator.EQUALS, contractList[0].National_Account__c));
            andCondition.add(new zal.FieldCondition(SYSTEM_CODE, zal.Operator.EQUALS, contractList[0].System__c));
        } else {
            andCondition.add(new zal.FieldCondition(NATIONAL_ACCOUNT_GROUP_ID, zal.Operator.EQUALS, NULL_STRING));
        }
    
        return andCondition;
    }

    global zal.Condition getFilterCondition(Id headerRecordId) {
        zal.AndCondition andCondition = new zal.AndCondition();
        return andCondition;
    }
}
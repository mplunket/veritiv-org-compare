public without sharing class LightningSearchComponentController {

    @TestVisible private static final List<SObjectType> OBJECTS = new List<SObjectType>{ Account.SObjectType, Lead.SObjectType };
    @TestVisible private static final Map<String, String> segmentMap = new Map<String, String>{
        'F' => 'Print','M' => 'Facility Solutions','P' => 'Packaging','L' => 'Publishing'
    };

    @TestVisible private static final String headerSetFormat = '_LS_Display_Fields';
    @TestVisible private static final String subHeaderSetFormat = '_LS_Sub_Fields';
    @TestVisible private static final String detailSetFormat = '_LS_Detail_Fields';
    @TestVisible private static final String searchFieldSetFormat = '_LS_Search_Fields';

    public class MetadataWrapper {
        @AuraEnabled public Map<String, FormatWrapper> displayFormats;
        @AuraEnabled public List<FieldWrapper> statePicklistValues;
        @AuraEnabled public List<FieldWrapper> segmentPicklistValues;
        @AuraEnabled public List<FieldWrapper> verticalPicklistValues;
    }

    public class FormatWrapper {
        @AuraEnabled public FieldWrapper objectName;
        @AuraEnabled public List<FieldWrapper> headerFields;
        @AuraEnabled public List<FieldWrapper> subHeaderFields;
        @AuraEnabled public List<FieldWrapper> detailFields;
        @AuraEnabled public List<FieldWrapper> searchFields;
    }

    public class FieldWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String label;

        public FieldWrapper(FieldSetMember member) {
            this.name = member.getFieldPath();
            this.label = member.getLabel();
        }

        public FieldWrapper(String name, String label) {
            this.name = name;
            this.label = label;
        }
    }

    @AuraEnabled
    public static MetadataWrapper getObjectMetadata() {
        MetadataWrapper objectMetadata = new MetadataWrapper();
        objectMetadata.displayFormats = new Map<String, FormatWrapper>();

        for(SObjectType objectType : OBJECTS) {
            String objectName = objectType.getDescribe().getName();
            Map<String, Schema.FieldSet> objectFieldSets = objectType.getDescribe().fieldsets.getMap();

            Schema.FieldSet headerFieldSet = objectFieldSets.get(objectName + headerSetFormat);
            Schema.FieldSet subHeaderFieldSet = objectFieldSets.get(objectName + subHeaderSetFormat);
            Schema.FieldSet detailFieldSet = objectFieldSets.get(objectName + detailSetFormat);
            Schema.FieldSet searchFieldSet = objectFieldSets.get(objectName + searchFieldSetFormat);

            FormatWrapper metadata = new FormatWrapper();
            metadata.objectName = new FieldWrapper(objectName, objectType.getDescribe().getLabel());

            metadata.headerFields = fieldsetToFields(headerFieldSet);
            metadata.subHeaderFields = fieldsetToFields(subHeaderFieldSet);
            metadata.detailFields = fieldsetToFields(detailFieldSet);
            metadata.searchFields = fieldsetToFields(searchFieldSet);

            objectMetadata.displayFormats.put(objectName, metadata);
        }

        objectMetadata.statePicklistValues = new List<FieldWrapper>();
        List<Schema.PicklistEntry> stateEntries = Lead.State__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : stateEntries) {
            objectMetadata.statePicklistValues.add(new FieldWrapper(entry.getValue(), entry.getLabel()));
        }

        objectMetadata.segmentPicklistValues = new List<FieldWrapper>();
        List<Schema.PicklistEntry> segmentEntries = Account.Segment_2__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : segmentEntries) {
            String segmentValue = entry.getValue();
            String segmentLabel = entry.getLabel();
            if(segmentMap.containsKey(segmentValue)) {
                segmentLabel = segmentMap.get(segmentValue);
            }
            
            objectMetadata.segmentPicklistValues.add(new FieldWrapper(segmentValue, segmentLabel));
        }

        objectMetadata.verticalPicklistValues = new List<FieldWrapper>();
        List<Schema.PicklistEntry> verticalEntries = Account.Account_Vertical__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : verticalEntries) {
            objectMetadata.verticalPicklistValues.add(new FieldWrapper(entry.getValue(), entry.getLabel()));
        }

        return objectMetadata;
    }

    @AuraEnabled
    public static Map<String, List<SObject>> searchObjects(String searchString, String formatsString, String filtersString,  String filterOperatorsString) {
        Map<String, FormatWrapper> displayFormats = (Map<String, FormatWrapper>) JSON.deserialize(formatsString, Map<String, FormatWrapper>.class);

        Map<String, Map<String, List<String>>> objectNameToFilters = 
            (Map<String, Map<String, List<String>>>) JSON.deserialize(filtersString, Map<String, Map<String, List<String>>>.class);
        Map<String, Map<String, String>> objectNameToFilterOperators = 
            (Map<String, Map<String, String>>) JSON.deserialize(filterOperatorsString, Map<String, Map<String, String>>.class);
		
        System.debug('###objectNameToFilters: '+ objectNameToFilters);
        List<String> returnValues = new List<String>();

        List<String> objectNames = new List<String>(displayFormats.keySet());
        for(String objectName : objectNames) {
            FormatWrapper displayFormat = displayFormats.get(objectName);

            List<FieldWrapper> fields = displayFormat.headerFields;
            fields.addAll(displayFormat.subHeaderFields);
            fields.addAll(displayFormat.detailFields);

            List<String> fieldStrings = new List<String>();
            for(FieldWrapper field : fields) {
                fieldStrings.add(field.name);
            }
              System.debug('fieldStrings'+fieldStrings);
            List<String> whereClauses = new List<String>();

            for(FieldWrapper searchField : displayFormat.searchFields) {
                whereClauses.add(searchField.name + ' LIKE \'%' + searchString + '%\'');
            }
              System.debug('whereClauses'+whereClauses);
            Map<String, List<String>> filters = objectNameToFilters.get(objectName);
            System.debug('filters'+filters);
            Map<String, String> filterOperators = objectNameToFilterOperators.get(objectName);
            System.debug('filterOperators'+filterOperators);
            if(filters != NULL) {
                Set<String> validLeadStatus = new Set<String>{'Converted', '0_Dead'};
                List<String> fieldNames = new List<String>(filters.keySet());

                for(String fieldName : fieldNames) {
 
                    // Skip filtering for Lead.Status if it's in the excluded statuses
                   
                    List<String> orClauses = new List<String>();
                    for(String filterValue : filters.get(fieldName)) {
                        String filterOperatorValue = filterOperators.get(fieldName);
                        System.debug('filterValue filterValue ' + filterValue);
                        if(filterValue == '%%'){
                            continue;
                        }
                        else if(String.isBlank(filterValue)) {
                            orClauses.add(fieldName + ' ' + filterOperatorValue + ' NULL');
                            System.debug('orClauses'+orClauses);
                        }
                        else {
                            orClauses.add(fieldName + ' ' + filterOperatorValue + ' \'' + filterValue + '\'');
                            System.debug('orClauses'+orClauses);
                        }
                    }
                    if( fieldName == 'Status' ){
                        whereClauses.add( '( ' + fieldName + ' NOT IN ( \'0_Dead\', \'Converted\' ) ' + ')' );
                    }
                     
                    if(!orClauses.isEmpty()) {
                        whereClauses.add( '(' + String.join(orClauses, ' OR ') + ')' );
                        System.debug('orClauses'+orClauses);
                    }
                }


            }
            System.debug('whereClauses'+whereClauses);
            String whereString = '';
            if(!whereClauses.isEmpty()) {
                whereString = ' WHERE ' + String.join(whereClauses, ' AND ');
                System.debug('whereString'+whereString);
            }

            returnValues.add(objectName + '(' + String.join(fieldStrings, ',') + 
                whereString +')');
            System.debug('whereString'+whereString);
        }
          
        String queryString = 'FIND :searchString ';
        queryString += 'IN ALL FIELDS RETURNING ' + String.join(returnValues, ',');
        System.debug(queryString);
        System.debug(returnValues);
        List<List<SObject>> results = Search.query(queryString);

        Map<String, List<SObject>> objectNameToResults = new Map<String, List<SObject>>();
        for(Integer i = 0; i < objectNames.size(); i++) {
            objectNameToResults.put(objectNames[i], results[i]);
        }
        return objectNameToResults;
    }

    @TestVisible
    private static List<FieldWrapper> fieldsetToFields(Schema.FieldSet fieldSet) {
        List<FieldWrapper> fields = new List<FieldWrapper>();

        for(Schema.FieldSetMember field : fieldSet.getFields()) {
            fields.add(new FieldWrapper(field));
        }

        return fields;
    }
    

}
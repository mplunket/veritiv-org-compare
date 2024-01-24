public without sharing class AIQSObjectUtil {
    
    public static List<SObject> getClone(String objectName, List<Id> objIds, List<String> excludeFields){
                
        return getClone(objectName, objIds, excludeFields, null, false, false);
        
    }
    
    
    public static List<SObject> getClone(String objectName, List<Id> objIds, List<String> excludeFields, String refField, Boolean preserveId, Boolean refByExternalId){
        
        String queryFields = ' Id, ';
        String whereClause = (refField!=null ? refField + ' in (' : 'Id in (');
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<string> fieldsToCreate = new List<string>();
        
        if (fieldMap != null){
            for (Schema.SObjectField field : fieldMap.values())
            { 
                Schema.DescribeFieldResult f = field.getDescribe();
                //if (! f.isCalculated() && (f.isCustom() || f.isNameField()))
                if (f.isCustom() || f.isNameField())    
                { 
                    if( ! excludeFields.contains(f.getName()) ){
                        if(refByExternalId && f.getRelationshipName()!=null){
							Map<String, Schema.SObjectField> refTOObjectFieldMap = f.getReferenceTo().get(0).getDescribe().fields.getMap();
                            for (String key : refTOObjectFieldMap.keySet()) {
                                if(refTOObjectFieldMap.get(key).getDescribe().isExternalID()) { 
                                    fieldsToCreate.add(f.getRelationshipName()+'.'+key);
                                    break;
                                } 
                            }

                        } else {
                            fieldsToCreate.add(f.getName());
                        }
                    }    
                }
            }
        }
        
        if (!fieldsToCreate.isEmpty()){
            for (string f:fieldsToCreate)
            {
                queryFields += f + ',';
            }
            if (queryFields.endsWith(','))
            {
                queryFields = queryFields.substring(0,queryFields.lastIndexOf(','));
            }
            
            for (Id objId : objIds){
                whereClause += '\'' + objId + '\'' +',';
            }
            if (whereClause.endsWith(','))
            {
                whereClause=whereClause.substring(0,whereClause.lastIndexOf(','))+')'; 
            }
        }
        
        String query = 'SELECT ' + queryFields + ' FROM ' + objectName + ' WHERE ' + whereClause;
        List<SObject> sObjs = new List<SObject>();       
        
        for(SObject obj: Database.query(query))
        {
            sObjs.add(obj.clone(preserveId, true, false, false));
        }
        
        return sObjs;
        
    }
    
    
    public static List<sObject> sortObjsList (List<sObject> objList, String sortBy, String fieldType, String sortOrder)
    {
        List<SortableSobject> sortableList = new List<SortableSobject>();
        for(sObject obj: objList){
            sortableList.add(new SortableSobject(obj, sortBy, fieldType, sortOrder));
        }
        sortableList.sort();
        
        List<sObject> sortedList = new List<sObject>();
        
        for(SortableSobject obj: sortableList){
            sortedList.add(obj.getObj());
        }
        return sortedList;        
    }
    
    class SortableSobject implements Comparable{
        private sObject obj;
        private String sortBy;
        private String fieldType;
        private String sortOrder;
        
        SortableSobject(sObject anObj, String aSortBy, String aFieldType, String aSortOrder){
            this.obj = anObj;
            this.sortBy = aSortBy;
            this.fieldType = aFieldType;
            this.sortOrder = aSortOrder;
        }
        
        public sObject getObj() {
            return obj;
        }
        
        public Integer compareTo(Object compareTo){
            SortableSobject compareToItem = (SortableSobject) compareTo;           
            if(sortOrder=='DESC')
            {
                if(obj.get(sortBy) == compareToItem.obj.get(sortBy)) return 0;
				if(fieldType == String.valueof(Schema.DisplayType.DATE) || FieldType==String.valueof(Schema.DisplayType.DATETIME))
                {
                    if((DATETIME) obj.get(sortBy) > (DATETIME) compareToItem.obj.get(sortBy)) return -1;
                }                               
                return 1;
            } else 
            {
                if(obj.get(sortBy) == compareToItem.obj.get(sortBy)) return 0;
                if(fieldType == String.valueof(Schema.DisplayType.DATE) || FieldType==String.valueof(Schema.DisplayType.DATETIME))
                {
                    if((DATETIME) obj.get(sortBy) > (DATETIME) compareToItem.obj.get(sortBy)) return 1;
                }
                return -1;
            }
        }
    }

    public static List<zpl__ContractLineItem__c> sortContractLineItems (List<zpl__ContractLineItem__c> lines)
    {
        List<SortableContractLineItem> sortableList = new List<SortableContractLineItem>();
        for(zpl__ContractLineItem__c line: lines){
            sortableList.add(new SortableContractLineItem(line));
        }
        sortableList.sort();
        
        List<zpl__ContractLineItem__c> sortedList = new List<zpl__ContractLineItem__c>();
        
        for(SortableContractLineItem line: sortableList){
            sortedList.add(line.line);
        }
        return sortedList;        
    }

    class SortableContractLineItem implements Comparable{
        public zpl__ContractLineItem__c line;
        public SortableContractLineItem(zpl__ContractLineItem__c line){
            this.line = line;
        }

        public Integer compareTo(Object compareTo){
            SortableContractLineItem compareToItem = (SortableContractLineItem) compareTo;
            
            system.debug('Comparing Line 1: ' + this.line.Name + '; Line 2: ' + compareToItem.line.Name);
            
            String cbss1 = this.line.CBSSItemGroupingKey__c == null ? '' : this.line.CBSSItemGroupingKey__c;
            String cbss2 = compareToItem.line.CBSSItemGroupingKey__c == null ? '' : compareToItem.line.CBSSItemGroupingKey__c;

            system.debug('Comparing CBSSIGK: Line 1: ' + cbss1 + '; Line 2: ' + cbss2);
            if (cbss1 > cbss2) {return -1;}
            if (cbss1 < cbss2) {return 1;}

            DateTime dateNull = system.now();

            DateTime effDate1 = this.line.zpl__EffectiveDate__c == null ? dateNull : this.line.zpl__EffectiveDate__c;
            DateTime effDate2 = compareToItem.line.zpl__EffectiveDate__c == null ? dateNull : compareToItem.line.zpl__EffectiveDate__c;

            system.debug('Comparing Effective Dates: Line 1: ' + effDate1 + '; Line 2: ' + effDate2);
            if (effDate1 > effDate2) {return -1;}
            if (effDate1 < effDate2) {return 1;}

            DateTime supDate1 = this.line.SupersededDate__c == null ? dateNull : this.line.SupersededDate__c;
            DateTime supDate2 = compareToItem.line.SupersededDate__c == null ? dateNull : compareToItem.line.SupersededDate__c;

            system.debug('Comparing Superseded Dates: Line 1: ' + supDate1 + '; Line 2: ' + supDate2);
            if (supDate1 > supDate2) {return -1;}
            if (supDate1 < supDate2) {return 1;}

            DateTime pubDate1 = this.line.Publish_Date__c == null ? dateNull : this.line.Publish_Date__c;
            DateTime pubDate2 = compareToItem.line.Publish_Date__c == null ? dateNull : compareToItem.line.Publish_Date__c;

            system.debug('Comparing Published Dates: Line 1: ' + pubDate1 + '; Line 2: ' + pubDate2);
            if (pubDate1 > pubDate2) {return -1;}
            if (pubDate1 < pubDate2) {return 1;}

            Double pubPrice1 = this.line.PublishedPrice__c == null ? 0 : this.line.PublishedPrice__c;
            Double pubPrice2 = compareToItem.line.PublishedPrice__c == null ? 0 : compareToItem.line.PublishedPrice__c;

            system.debug('Comparing Published Prices: Line 1: ' + pubPrice1 + '; Line 2: ' + pubPrice1);
            if (pubPrice1 > pubPrice2) {return -1;}
            if (pubPrice1 < pubPrice2) {return 1;}

            return 0;

        }
    }
}
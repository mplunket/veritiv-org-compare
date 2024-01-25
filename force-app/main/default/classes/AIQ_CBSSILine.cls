public class AIQ_CBSSILine implements Comparable {
    public final zpl__ContractLineItem__c line;
    public Boolean isChanged;
    public Boolean isOriginal;

    public AIQ_CBSSILine(zpl__ContractLineItem__c line) {
        AIQco_Precondition.checkNotNull(line.CBSSItemGroupingKey__c, 'Line must have CBSSItemGroupingKey__c populated');
        AIQco_Precondition.checkNotNull(line.zpl__EffectiveDate__c, 'Line must have zpl__EffectiveDate__c populated');
        AIQco_Precondition.checkNotNull(line.zpl__Status__c, 'Line must have zpl__Status__c populated');
        AIQco_Precondition.checkNotNull(line.RecordTypeId, 'Line must have RecordTypeId populated');
        AIQco_Precondition.checkNotNull(line.isCurrent__c, 'Line must have isCurrent__c populated');
        AIQco_Precondition.checkNotNull(line.zpl__ContractLineItemId__c, 'Line must have zpl__ContractLineItemId__c populated');

        this.line = line;
        this.isChanged = false;
        this.isOriginal = false;
    }

    public AIQ_CBSSILine(String lineExternalId) {
        this.line = new zpl__ContractLineItem__c(zpl__ContractLineItemId__c = lineExternalId);
    }

    public Integer compareTo(Object compareTo) {
        if (!(compareTo instanceof AIQ_CBSSILine)) {
            throw new IllegalArgumentException('Sortable object should be of ' + AIQ_CBSSILine.class.getName() + ' type');
        }
        AIQ_CBSSILine compareToEffDate = (AIQ_CBSSILine) compareTo;
        if (this.line.zpl__EffectiveDate__c > compareToEffDate.line.zpl__EffectiveDate__c) {
            return -1;
        }
        if (this.line.zpl__EffectiveDate__c < compareToEffDate.line.zpl__EffectiveDate__c) {
            return 1;
        }
        return 0;
    }

    public void mergeTo(zpl__ContractLineItem__c sourceLine) {
        AIQco_Precondition.checkNotNull(sourceLine, 'No source line to merge');
        Map<String,Object> targetLineMap = this.line.getPopulatedFieldsAsMap();
        Map<String,Object> sourceLineMap = sourceLine.getPopulatedFieldsAsMap();
        for (String fieldName : sourceLineMap.keySet()){
            if(targetLineMap.containsKey(fieldName) ){
                continue;
            }
            Object value = sourceLineMap.get(fieldName);
        
            if(value instanceof SObject ){
                this.line.putSObject(fieldName, (SObject) value);
            }else{
                this.line.put(fieldName, value);
            }
        }
    }
    
    private Integer hashCode() {
        return new AIQco_HashCodeBuilder()
            .append(this.line.zpl__ContractLineItemId__c)
            .toHashCode();
    }

    private Boolean equals(Object outerObj) {
        if (outerObj != null && outerObj instanceof AIQ_CBSSILine) {
            AIQ_CBSSILine outerLine = (AIQ_CBSSILine) outerObj;
            return this.line.zpl__ContractLineItemId__c == outerLine.line.zpl__ContractLineItemId__c;
        }
        return false;
    }
}
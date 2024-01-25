public virtual class AIQ_SyncDownFilter implements zpf.SynchronizedRecordFilter
{
    protected String sObjectTypeName;
    protected Schema.SObjectType sObjType;
    protected String sObjectFieldSet;
    
    public AIQ_SyncDownFilter(String sObjectTypeName){
        this.sObjectTypeName = sObjectTypeName;
    }
    
    public AIQ_SyncDownFilter(String sObjectTypeName, String sObjectFieldSet)
    {
        this.sObjectTypeName = sObjectTypeName;
        this.sObjectFieldSet = sObjectFieldSet;
        this.sObjType = Schema.getGlobalDescribe().get(this.sObjectTypeName);
    }
    
    private List<Schema.FieldSetMember> getFields() {
        if(sObjType == null) return new List<Schema.FieldSetMember>();
        Schema.FieldSet fieldSet = sObjType.getDescribe().FieldSets.getMap().get(this.sObjectFieldSet);
        if(fieldSet == null) return new List<Schema.FieldSetMember>();
        return fieldSet.getFields();
    }
      
    public virtual Boolean include(SObject after, SObject before)
    {
        // preventing non-intentional sync
        Sobject obj = after != null ? after : before;
        if(obj!= null && obj.getSObjectType().getDescribe().getName() != this.sObjectTypeName){
            return false;
        }
        
        // sync record on insert or delete
        if (after == null || before == null)
        {
            return true;
        }
        
        List<Schema.FieldSetMember> syncFields = this.getFields();
        
        // if sync down field set is not defined we sync anyway
        if(syncFields == null || syncFields.isEmpty()){
            return true;
        }
        
        // compare the fields on update
        for(Schema.FieldSetMember f : this.getFields()) {

            if(after.get(f.getFieldPath()) != before.get(f.getFieldPath())){
                return true;
            }
        }        
        return false;
    }
    
}
public class AIQ_SyncAccountFilter extends AIQ_SyncDownFilter
{
      
    public AIQ_SyncAccountFilter(String sObjectTypeName, String sObjectFieldSet)
    {
        super(sObjectTypeName, sObjectFieldSet);
    }
      
    public override Boolean include(SObject after, SObject before)
    {
  		Sobject obj = after != null ? after : before;
        SObject afterWrapped = (after == null ? sObjType.newSObject() : after);
        SObject beforeWrapped = (before == null ? sObjType.newSObject() : before);
        
        if(super.include(after, before) 
           && obj!= null 
           && obj.get('zpl__CustomerId__c')!=null
           && (afterWrapped.get('Zilliant_Active__c')=='AI' || beforeWrapped.get('Zilliant_Active__c') == 'AI' || afterWrapped.get('IsNationalAccountZilliant__c') == true)
        ){
            return true;
        }
              
        return false;
    }
}
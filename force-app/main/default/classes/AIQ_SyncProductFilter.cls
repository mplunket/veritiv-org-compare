public class AIQ_SyncProductFilter extends AIQ_SyncDownFilter
{
      
    public AIQ_SyncProductFilter(String sObjectTypeName, String sObjectFieldSet)
    {
        super(sObjectTypeName, sObjectFieldSet);
    }
      
    public override Boolean include(SObject after, SObject before)
    {
  		Sobject obj = after != null ? after : before;
        
        if(super.include(after, before) 
           && obj!= null 
           && obj.get('zpl__ProductId__c')!=null
        ){
            return true;
        }
              
        return false;
    }
}
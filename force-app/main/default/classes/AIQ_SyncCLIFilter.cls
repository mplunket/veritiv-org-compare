public class AIQ_SyncCLIFilter extends AIQ_SyncDownFilter
{
      
    public AIQ_SyncCLIFilter(String sObjectTypeName)
    {
        super(sObjectTypeName);
    }
      
    public override Boolean include(SObject after, SObject before)
    {
  		Sobject obj = after != null ? after : before;
        
        if(super.include(after, before) 
           && obj!= null 
           && obj.get('zpl__ContractLineItemId__c')!=null
        ){
            return true;
        }
              
        return false;
    }
}
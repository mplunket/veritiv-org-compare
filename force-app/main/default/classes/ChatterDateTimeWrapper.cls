public class ChatterDateTimeWrapper implements sortableInterface{
		
		EntitySubscription mySubscription;
		DateTime myDateTime;
		
		public ChatterDateTimeWrapper(EntitySubscription aSubscription,DateTime dateWrapperField)
		{
			mySubscription = aSubscription;
			myDateTime = dateWrapperField;
		}
		
		public Object getSortIndex(String wrapperFieldName)
		{
			return myDateTime;
		}
		
		public static List<EntitySubscription> getSortedListByDESCOrder(List<ChatterDateTimeWrapper> wrappers)
		{
			BluewolfDevUtils devUtils = new BluewolfDevUtils();
			List<ChatterDateTimeWrapper> wrappersSorted = (List<ChatterDateTimeWrapper>) devUtils.wrapperSortBy(wrappers, '','DESC');
			
			List<EntitySubscription> retList = new List<EntitySubscription>();
			for(ChatterDateTimeWrapper c : wrappersSorted)
			{
				retList.add(c.mySubscription);
			}
			
			return retList;
		}
	}
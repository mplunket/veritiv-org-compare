public class DateGetterFactory {
	public static final String GETTER_LAST_MODIFIED_DATE = 'LastModifiedDateGetter';
	public static final String GETTER_UNIT_TESTING = 'UnitTestingDateGetter';
	
	public static DateGetters.DateGetter getDateGetter(String GETTER_TYPE)
	{
		if(GETTER_TYPE==GETTER_UNIT_TESTING)
		{
			return new DateGetters.TestingDateGetter();
		}
		else if(GETTER_TYPE==GETTER_LAST_MODIFIED_DATE)
		{
			return new DateGetters.LastModifiedDateGetter();
		} 
		return null;
	}
}
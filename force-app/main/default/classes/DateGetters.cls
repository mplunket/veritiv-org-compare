global class DateGetters {
	global static final String FIELD_FOR_TESTING_IN_ACCOUNT = 'iRep_Plan_Effective_Date__c';
	global static final String FIELD_FOR_TESTING_IN_OPPORTUNITY = 'BDR_Date__c';
	global static final String FIELD_FOR_LAST_MODIFIED_DATE = 'LastModifiedDate';
		 
	global interface DateGetter {
		DateTime getDateTime(SObject record);
		String getFieldName(SObjectType objectType);
	}
	
	global class LastModifiedDateGetter implements DateGetter {
		
		
		global String getFieldName(SObjectType objectType)
		{
			return FIELD_FOR_LAST_MODIFIED_DATE;
		}
		
		global DateTime getDateTime(SObject record)
		{
			return (DateTime) record.get(FIELD_FOR_LAST_MODIFIED_DATE);
		}
	}
	
	global class TestingDateGetter implements DateGetter {
		
		global String getFieldName(SObjectType objectType)
		{
			if(isAccount(objectType))
			{
				return FIELD_FOR_TESTING_IN_ACCOUNT;
			}
			else if(isOpportunity(objectType))
			{
				return FIELD_FOR_TESTING_IN_OPPORTUNITY;
			}
			return null;
		}
		
		global Boolean isAccount(SObjectType objectType)
		{
			return objectType == Account.SObjectType;
		}
		
		global Boolean isOpportunity(SObjectType objectType)
		{
			return objectType == Opportunity.SObjectType;
		}
		
		global DateTime getDateTime(SObject record)
		{
			if(isAccount(record.getSObjectType()))
			{
				return (DateTime) record.get(FIELD_FOR_TESTING_IN_ACCOUNT);
			}
			else if(isOpportunity(record.getSObjectType()))
			{
				return (DateTime) record.get(FIELD_FOR_TESTING_IN_OPPORTUNITY);
			}
			return null;
		}
	}
}
public class CaseModel
{
	public static final String INBOUND_CASE_IDENTIFIER = 'Incoming_Fax';

	private static  RecordType inboundCase;

	private static Map<String, RecordType> caseRecordTypeDeveloperNameToRecordType;

	public static RecordType getInboundCaseRT()
	{
		if(inboundCase == null)
			inboundCase = getRecordType(INBOUND_CASE_IDENTIFIER);

		return inboundCase;
	}

	public static RecordType getRecordType(String rtype)
	{
		populateCaseRecordTypes();

		return caseRecordTypeDeveloperNameToRecordType.get(rtype);
	}

	public static Set<Id> getRecordTypesIntoSet( Set<String> recordTypeDeveloperNames )
	{
		populateCaseRecordTypes();

		Set<Id> rtIdsToReturn = new Set<Id>();

		for( RecordType recordType : caseRecordTypeDeveloperNameToRecordType.values() )
		{
			if( recordTypeDeveloperNames.contains( recordType.DeveloperName ) )
			{
				rtIdsToReturn.add( recordType.Id );
			}
		}

		return rtIdsToReturn;
	}

	private static void populateCaseRecordTypes()
	{
		if(caseRecordTypeDeveloperNameToRecordType == null)
		{
			caseRecordTypeDeveloperNameToRecordType = new Map<String, RecordType>();

			for(RecordType caseRTFound : [SELECT Id, Name , DeveloperName
										   FROM RecordType
										   WHERE IsActive = true
										   AND SObjectType = 'Case'])
			{
				caseRecordTypeDeveloperNameToRecordType.put(caseRTFound.DeveloperName, caseRTFound);
			}
		}
	}

}
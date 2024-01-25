public class SundogLeadOverrideConfig {

	private Map<String, leadAssignmentRange__c> leadAssignmentSettings = leadAssignmentRange__c.getAll();
	
	public SundogLeadOverrideConfig() {
		
		verifyAssigneeIds();
	}
	
	private void verifyAssigneeIds() {
		
		Id possiblyValidId;
		
		for ( leadAssignmentRange__c aRange : leadAssignmentSettings.values() ) {
			
			try {
				
				possiblyValidId = (Id)aRange.Assignee_Id__c;
				
			} catch ( System.Exception idEx ) {
				
				throw new invalidIdException( 'Invalid ID specified in custom settings. Please contact administrator.' );
				
			}
			
		}
		
	}
	
	private String generateRangeString( leadAssignmentRange__c aRange ) {
		
		String rangeValue = aRange.lower_bound__c.intValue() + ' ';
		
		if ( aRange.upper_bound__c == null ) {
			
			rangeValue += '+';
		
		} else {
		
			rangeValue += '- ' + aRange.upper_bound__c.intValue();
			
		}
		
		return rangeValue;
		
	}
	
	private Id resolveEmployeeRange( String employeeRange ) {
		
		Id resolvedEmployeeId;
		
		for ( leadAssignmentRange__c anAssignmentSetting : leadAssignmentSettings.values() ) {
			
			System.debug( '!!! comparing ' + generateRangeString( anAssignmentSetting ) + '  :  ' + employeeRange );
			
			if ( generateRangeString( anAssignmentSetting ) == employeeRange )
				resolvedEmployeeId = (Id)anAssignmentSetting.Assignee_Id__c;
			
		}
		
		return resolvedEmployeeId;
		
	}
	
	public Boolean assignLead( Lead leadToAssign ) {
		
		Id newOwnerId = resolveEmployeeRange( leadToAssign.Employee_Range__c );
		
		if ( newOwnerId != null ) {
			
			leadToAssign.OwnerId = newOwnerId;
			return true;
			
		} else {
			
			return false;
			
		}
		
	}

	public class invalidIdException extends System.Exception {
		
		
		
	}


	////////////////////////////////////////////////////////////////////
	/////		Class for normalizing the Country field of Leads
	////////////////////////////////////////////////////////////////////

	public class CountryOverrider {
		
		private Map<String, USA_Aliases__c> usaCountrySynonymSettings = USA_Aliases__c.getAll();
		
		private String primaryName;
		
		public String CountryName {
			
			get {
				
				if ( primaryName == null )
					primaryName	= extractPrimary();
					
				return primaryName;
				
			}
			
		}
		
		public Boolean isValidCountrySynonym( String countryName ) {
			
			if ( usaCountrySynonymSettings.containsKey( countryName ) ) {
				
				return true;
				
			} else {
	
				for ( USA_Aliases__c anAliasSetting : usaCountrySynonymSettings.values() ){
					
					if ( anAliasSetting.Name.toUpperCase() == countryName.toUpperCase() )
						return true;			
					
				}

			}
			
			return false;
			
		}
		
		private String extractPrimary() {
			
			for ( USA_Aliases__c anAliasSetting : usaCountrySynonymSettings.values() ) {
				
				if ( anAliasSetting.is_Primary_Alias__c )
					return anAliasSetting.Name;
				
			}
			
			return '';
			
		}
		
	}

}
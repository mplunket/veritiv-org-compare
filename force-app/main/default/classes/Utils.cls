/**
 Objective: Noninstantiable utility class
 Developer: Hiremath, Naveen - Bluewolf     
*/
public class Utils {

	/**
     Return true if the string under test is not null and has 
     no blank characters
    */
    public static Boolean isNonEmptyString(final String userInput) {
    	
    	return (userInput != null && userInput.trim().length() > 0);
    	
    }
    
    /**
     Validate true if searchExpression starts with the wildCard  
    */
    public static Boolean isStartsWith(final String searchExpression, final String wildCard) {
    	
    	return searchExpression.startsWith(wildCard);
    		
    }
    
    /**
     Validate true if searchExpression contains the wildCard  
    */
    public static Boolean isContainsWith(final String searchExpression, final String wildCard) {
    	
    	return searchExpression.contains(wildCard);
    	
    }
    
    /**
     Validate true if searchExpression ends with the wildCard  
    */
    public static Boolean isEndsWith(final String searchExpression, final String wildCard) {
    	
    	return searchExpression.endsWith(wildCard);
    	
    }
    
    /**
     Validate true if searchExpression contains a wildCard  
    */
    public static Boolean isWildSearch(final String searchExpression, final String wildCard) {
    
    	return (isContainsWith(searchExpression, wildCard));
    				
    }
    
 	/**
     Returns startsWith expression for use in SOQL Like
     e.g. %test
    */
    public static String getStartsWith(final String likeExpression) {
    	
        return Consts.LIKE_OPERATOR + likeExpression;
        
    }
    
 	/**
     Returns containsWith expression for use in SOQL Like
     e.g. %test%
    */
    public static String getContainsWith(final String likeExpression) {
    	
        return Consts.LIKE_OPERATOR + likeExpression + Consts.LIKE_OPERATOR;
        
    }
    
    /**
     Returns endsWith expression for use in SOQL Like
     e.g. test%
    */
    public static String getEndsWith(final String likeExpression) {
    	
        return likeExpression + Consts.LIKE_OPERATOR;
        
    }
    
    /**
     Validates the wildCardExpression by matching and replacing the wildCard with
     its SOQL equivalent and returns null if there is no match
    */
    public static String getWildSearchType(final String wildCardExpression, final String wildCard) {
    	
    	String filteredSearchType;
					
		if(isStartsWith(wildCardExpression, wildCard) && 
		   !isEndsWith(wildCardExpression, wildCard)) {
			
			filteredSearchType = getStartsWith(wildCardExpression.replaceAll(wildCard, Consts.EMPTY_STRING));
					
		} else if(isEndsWith(wildCardExpression, wildCard) && 
				  !isStartsWith(wildCardExpression, wildCard)) {
			
			filteredSearchType = getEndsWith(wildCardExpression.replaceAll(wildCard, Consts.EMPTY_STRING));
			
		} else if(isContainsWith(wildCardExpression, wildCard)) {
			
			filteredSearchType = getContainsWith(wildCardExpression.replaceAll(wildCard, Consts.EMPTY_STRING));
			
		}
		
		return filteredSearchType;
		
    }
    
    /**
     Give this function an API name and a value and it will return the favor
     by building a SOQL AND expression filter that exactly matches the value - can be 
     used in constructing bigger dynamic query 
    */
    public static String getExactAndQueryFilter(final String fieldAPIName, final String fieldValue) {
    	
    	return Consts.SOQL_AND + fieldAPIName + ' = \'' + String.escapeSingleQuotes(fieldValue) + '\'';
    	
    }
    
    /**
     Give this function an API name and a value and it will return the favor
     by building a SOQL AND expression filter that does a LIKE on the value - can be 
     used in constructing bigger dynamic query 
    */
    public static String getLikeANDQueryFilter(final String fieldAPIName, final String fieldValue) {
    	
    	return Consts.SOQL_AND + fieldAPIName + Consts.EMPTY_STRING + Consts.SOQL_LIKE + ' \'' + String.escapeSingleQuotes(fieldValue) + '\''; 
    	
    }
    
    /**
     Give this function an API name and a value list and it will return the favor
     by building a SOQL AND expression filter that applies an IN on the values - can be 
     used in constructing bigger dynamic query 
    */
    public static String getInAndQueryFilter(final String fieldAPIName, final List<String> fieldValues) {
    	
    	return Consts.SOQL_AND + fieldAPIName + ' IN ( ' + getCommaDelimits(fieldValues) + ' ) ';  
    		
    }
    
    /**
     Utility method that converts a list of strings into comma 
     delimited string
    */
    public static String getCommaDelimits(final List<String> values) {
    	
    	String commaSeperatedIds = Consts.EMPTY_STRING;
    	for(String value: values) {
    	
    		commaSeperatedIds +=  '\'' + value + '\',';
    		
    	}  	
    	
    	return (commaSeperatedIds != Consts.EMPTY_STRING ) ? 
    			commaSeperatedIds.substring(0, commaSeperatedIds.length() - 1) : 
    			Consts.EMPTY_STRING;
    }
    
    /**
     Prepares an ORDER BY clause for the given field api name
    */
    public static String getOrderByFilter(final String fieldAPIName) {
    
    	return Consts.SOQL_ORDER_BY + fieldAPIName;
    		
    }
    
    /**
     Prepares the LIMIT filter for a given limitSize otherwise
     VF_COLLECTION_LIMIT is taken into consideration  
    */
    public static String getLimitExpression(final Integer limitSize) {
    	
    	return (limitSize == null) ? 
    			Consts.SOQL_LIMIT + Consts.VF_COLLECTION_LIMIT :
    			Consts.SOQL_LIMIT + limitSize;
    			
    }
    
    /**
	 Suppress default constructor for noninstantiability
	*/
    private Utils() { }
    
}
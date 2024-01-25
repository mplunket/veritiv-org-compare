public class QuoteInformationExt {
    
	public static String QUOTE_WON_STAGE {
	    get {
	        return 'Won';
	    }
	}
	public static String QUOTE_LOST_STAGE {
	    get {
	        return 'Lost';
	    }
	} 
	public static String QUOTE_LOST_REASON_OTHER {
	    get {
	        return 'Other';
	    }
	}
	
	/* Stage Render and Required Field Functionality */
    
    public static  Boolean renderSalesOrderNumberField(SObject q){
    
		return QUOTE_WON_STAGE.equalsIgnoreCase(String.valueOf(q.get('Quote_Stage__c')));	

    }
    
    public static Boolean renderLostReasonCommentsField(SObject q){
    
		return QUOTE_LOST_STAGE.equalsIgnoreCase(String.valueOf(q.get('Quote_Stage__c'))) && QUOTE_LOST_REASON_OTHER.equalsIgnoreCase(String.valueOf(q.get('Lost_Reason__c')));	

    }
    

}
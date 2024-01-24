public with sharing class LimitServices {
    public virtual class LimitException extends Exception {}
    public class CloseToQueryRowsLimitException extends LimitException {}
    public class CloseToDMLRowsLimitException extends LimitException {}
    
    public static Decimal CLOSE_PERCENTAGE = .69; 
    public static Integer QUERY_ROWS_THRESHOLD = (Integer) (Limits.getLimitQueryRows()*CLOSE_PERCENTAGE);
    public static Integer DML_ROWS_THRESHOLD = ((Integer) (Limits.getLimitDMLRows()*CLOSE_PERCENTAGE));
    
    /*
    Try to make the specified query with the following caveat:
    If we are nearing the limits for how many rows we can query, throw a CloseToQueryRowsLimitException
       
    Preconditions:
    The specified query must have a where clause, and the where clause must be the last component of the query 
    */
    public static List<SObject> querySObjects(String query) 
    {
		Integer rowsLeft = QUERY_ROWS_THRESHOLD - Limits.getQueryRows();
        if(rowsLeft<=0)
        {
            throw new CloseToQueryRowsLimitException('The following query [' + query + '] cannot be called, because we are at the threshold for query rows ' + Limits.getQueryRows() + ' Threshold --> ' + QUERY_ROWS_THRESHOLD);
        }
        else
        {
            List<SObject> objs = Database.query(query + ' LIMIT ' + rowsLeft + ' ALL ROWS'); 
            if(objs!=null && objs.size()==rowsLeft)
            {
                throw new CloseToQueryRowsLimitException('The following query [' + query + '] puts us too close to the limit for query rows ' + Limits.getQueryRows() + ' Threshold --> ' + QUERY_ROWS_THRESHOLD);
            }
            return objs;
        }
    }

    /*
    Throw the CloseToDMLRowsLimitException if inserting the specified number of records would exceed the dml rows threshold
    */
    public static void checkDMLRowsLimit(Integer howMany) 
    {
    	//System.assert(false, 'Size to insert --> ' + howMany + ' Threshold --> ' + DML_ROWS_THRESHOLD + ' Rows so far ' + Limits.getDMLRows() );
        if(( DML_ROWS_THRESHOLD > 0 && (Limits.getDMLRows()+howMany)>=DML_ROWS_THRESHOLD )) throw new CloseToDMLRowsLimitException('We are exceeding the dml rows limit.');
    } 
}
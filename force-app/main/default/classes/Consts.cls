/**
 Objective: Noninstantiable global constants class
 Developer: Hiremath, Naveen - Bluewolf
*/
public class Consts {

	/**
     Visual Force collections can process only 1000 elements
    */
    public static final Integer VF_COLLECTION_LIMIT = 500;

    /**
     Opposite of SUCCESS
    */
    public static final Boolean FAILURE = false;

    /**
     Opposite of SUCCESS
    */
    public static final Boolean SUCCESS = true;

    /**
     Opposite of DISABLE
    */
    public static final Boolean ENABLE = true;
    /**
     Opposite of ENABLE
    */
    public static final Boolean DISABLE = false;

    /**
     SQL/SOQL Like Operator
    */
    public static final String LIKE_OPERATOR = '%';

    /**
     The operator used to perform wild card searches
    */
    public static final String WILD_CARD_OPERATOR = '@';

    /**
     Represents SOQL AND operator
    */
    public static final String SOQL_AND = ' AND ';

    /**
     Represents SOQL LIKE operator
    */
    public static final String SOQL_LIKE = ' LIKE ';

    /**
     Represents SOQL ORDER BY operator
    */
    public static final String SOQL_ORDER_BY = ' ORDER BY ';

    /**
     Represents SOQL LIMIT operator
    */
    public static final String SOQL_LIMIT = ' LIMIT ';

    /**
     Default None option
    */
    public static final String SELECT_OPTION_NONE = '--None--';

    /**
     Empty string
    */
    public static final String EMPTY_STRING = '';

    /**
     Draft stage for quotes
    */
    public static final String QUOTE_DRAFT_STAGE = 'Draft';

    /**
     Identifier for an invalid quote
    */
    public final static String INVALID_QUOTE = 'This is not a valid quote.';

	/**
	 User must be alerted when cost is greater than the Unit price
	*/
	public final static String PAGE_MSG_UNIT_PRICE_LESS_THAN_COST = 'The unit price is less than the cost.';

	/**
	 Freight lines are mandatory to save a direct order quote
	*/
	public final static String PAGE_MSG_NO_FREIGHT_LINES_ON_DIRECT_QUOTE = 'No freight lines found on this direct order quote.  Please add a freight product and save again.';

	/**
	 Cost UOM and Price UOM must be same before a line item is saved
	*/
	public final static String PAGE_MSG_COST_UOM_PRICE_UOM_MUST_BE_SAME = 'If cost is entered the cost UOM and price UOM must be the same.';

	/**
	 A Quote can be created only against a Customer or Prospect Account
	*/
	public final static String PAGE_MSG_NO_QUOTE_FOR_VENDOR_ACCOUNT_TYPE = 'Quotes can be created only for Customer or Prospect Accounts!';

    /**
     A Quote Line Item can only update P&A if Shipment Method is set
    */
    public final static String PAGE_MSG_NO_SHIPMENT_METHOD_FOR_QUOTE_ON_UPDATEPA = 'Shipment Method must be set on Quote in order to Update P&A for Quote Line Item.';
	/**
	 Relative URL to Quotes Tab
	*/
	public final static String REL_URL_QUOTES_TAB = '/a0O/o';

	/**
	 Websource department field key
	*/
	public final static String WEBSOURCE_DEPARTMENT = 'Websource';

    /**
     Direct shipment method
    */
    public final static String SHIP_METHOD_DIRECT = 'Direct';

	/**
	 Web Center department field key
	*/
	public final static String WEBCENTER_DEPARTMENT = 'Web Center';
	
	/**
	 Fordis department field key
	*/
	public final static String FORDIS_DEPARTMENT = 'Fordis';
    
    /**
     Saalfeld department field key
    */
    public final static String SAALFELD_DEPARTMENT = 'Saalfeld';

    /**
     If a quote was created before this date, a different error message is displayed when attempting to send to someone
    */
    public final static Date LEGACY_QUOTE_CUTOFF_DATE = Date.newInstance(2017, 9, 21);

	/**
     Suppress default constructor for noninstantiability
    */
    private Consts () {}

}
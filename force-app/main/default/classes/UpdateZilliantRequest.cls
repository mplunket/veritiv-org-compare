public class UpdateZilliantRequest extends OrderRequest {
    
    /**
    	Request are going to happen one at a time.
    **/
    
    public static final String STATUS_CODE_ERROR = '01';
    public static final String STATUS_CODE_SUCCESS = '00';
    public static final String UPDATE_ZILLIANT = 'Update Zilliant P&A';
    public static final String ZILLIANT_SUCCESS_MESSAGE = 'Zilliant has been updated!';
    @TestVisible private static final String REQUEST_URL_NOT_SETUP = 'The URL for the Zillant Request Web Service has not been configured in the WebService object.';
    
    public String REQ_URL
    {
    	get
    	{
    		if(REQ_URL == NULL)
    		{
    			REQ_URL = [SELECT URL__c FROM WebService__c WHERE Type__c =: UPDATE_ZILLIANT LIMIT 1].URL__c;
    		}
    		return REQ_URL;
    	}
    	
    	set;
    }
    
    public UpdateZilliantRequest()
    {
    	
    }
    
    /* Method that builds XML for Zilliant Request */
    @testVisible
    private String prepareXML()
    {
      String returnXML  =	'<?xml version="1.0"?> \n';
			 returnXML +=		'<Request> \n';
			 returnXML +=			'<Pricing> \n';
			 returnXML +=				'<CustomerCompositeKey>'+ CustomerCompositeKey + '</CustomerCompositeKey> \n';
			 returnXML +=				'<ChainCode>' + ChainCode + '</ChainCode> \n';
			 returnXML += 				'<Division>' + Division + '</Division> \n';
			 returnXML +=				'<Vendor>' + Vendor + '</Vendor> \n';
			 returnXML +=				'<Segment>' + Segment + '</Segment> \n';
			 returnXML +=				'<ClassCd>' + ClassCd + '</ClassCd> \n';
			 returnXML +=				'<BrandCd>' + BrandCd + '</BrandCd> \n';
			 returnXML +=				'<SetCd>' + SetCd + '</SetCd> \n';
			 returnXML +=				'<SubsetCd>' + SubsetCd + '</SubsetCd> \n';
			 returnXML +=				'<ShortItem>' + ShortItem + '</ShortItem> \n';
			 returnXML +=				'<PricingType>' + PricingType + '</PricingType> \n';
			 returnXML +=				'<PricieCode>' + PriceCode + '</PricieCode> \n';
			 returnXML +=				'<ListDownPercent>' + ListDownPercent + '</ListDownPercent> \n';
			 returnXML +=				'<CostUpPercent>' + CostUpPercent + '</CostUpPercent> \n';
			 returnXML +=				'<Price>' + Price + '</Price> \n';
			 returnXML +=				'<AlternatePrice>' + AlternativePrice + '</AlternatePrice> \n';
			 returnXML +=				'<QuantityBreak>' + QuantityBreak + '</QuantityBreak> \n';
			 returnXML +=				'<QuantityBreakUnit>' + QuantityBreakUnit + '</QuantityBreakUnit> \n';
			 returnXML +=				'<PriceUnit>' + PriceUnit + '</PriceUnit> \n';
			 returnXML +=				'<QtyUnit>' + QuantityUnit + '</QtyUnit> \n';
			 returnXML +=				'<DateBegin>' + DateTime.newInstance(DateBegin.year(), DateBegin.month(),DateBegin.day()).format('yyyyMMdd') + '</DateBegin> \n';
			 returnXML +=				'<DateEnd>' + DateTime.newInstance(DateEnd.year(), DateEnd.month(),DateEnd.day()).format('yyyyMMdd') + '</DateEnd> \n';
			 returnXML +=				'<MinimumPrice>' + MinimumPrice + '</MinimumPrice> \n';
			 returnXML +=				'<MinimumGTMPercent>' + MinimumGTMPercent + '</MinimumGTMPercent> \n';
			 returnXML +=				'<CustomerSKU>' + CustomerSKU + '</CustomerSKU> \n';
			 returnXML +=				'<Date>' + CurrentDate + '</Date> \n';
			 returnXML +=				'<Time>' + CurrentTime + '</Time> \n';
			 returnXML +=				'<Filler1>' + FillerOne + '</Filler1> \n';
			 returnXML +=				'<Filler2>' + FillerTwo + '</Filler2> \n';
			 returnXML +=				'<Expr1>' + ExprOne + '</Expr1> \n';
			 returnxml +=				'<Expr2>' + ExprTwo + '</Expr2> \n';
			 returnXML +=			'</Pricing> \n';
			 returnXML +=		'</Request> \n';
        
        return returnXML;
    }
    
    public override void postData()
    {
        Response = new ResponseClass();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        try
        {
          req.setEndpoint(REQ_URL);
          req.setTimeout(20000);
        }
        catch(QueryException qe)
        {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, REQUEST_URL_NOT_SETUP));
          return;
        }

        req.setBody(prepareXML());
        req.setMethod(HttpMethod);
        
        HttpResponse res = null;
        XmlStreamReader xsr = null;
        
        try
        {  
            res = h.send(req);
            xsr = new XmlStreamReader(res.getBody());
            
            parseResponse(xsr);
            
            if( String.isEmpty(ErrorCodeAndMessage) && Response.StatusCode == STATUS_CODE_SUCCESS )
            {
            	Response.StatusSendDate = Datetime.now();
            }
            else
            {
            	if( Response.StatusCode != STATUS_CODE_SUCCESS )
            	{
            		Response.StatusCode = 'Request to Zilliant Failed, Server Error';
            	}
            	Response.StatusMessage = ErrorCodeAndMessage;
            }
        }
        catch(Exception e)
        {
            Response.StatusMessage = e.getMessage();
            Response.StatusCode = 'Request to Zilliant Failed, Request Error';
            return;
        }
        
    }
    
    public override void parseResponse(XmlStreamReader xsr) 
    {
        while(xsr.hasNext())
        {
            if(xsr.isEndElement() && xsr.getLocalName() == 'Response')
         	{ 
				System.debug('End of Reponse Tag');   
				break;
         	}
		   	if( xsr.isStartElement() && xsr.getLocalName() == 'Status' )
            {
			  	xsr.next();
				if( xsr.hasText() )
				{
					Response.StatusCode = xsr.getText();
				}
            }
          	if( xsr.isStartElement() && xsr.getLocalName() == 'errorCode' )
			{
				System.debug('Found Error!');
				
				xsr.next();
				if( xsr.hasText() )
				{
					ErrorCodeAndMessage = 'Error Code ' + xsr.getText() + ': ';
					Response.StatusCode = xsr.getText();
				}
			}
			if( xsr.isStartElement() && xsr.getLocalName() == 'errorString' )
			{
				System.debug('Found Error String!');
				
				xsr.next();
				if( xsr.hasText() )
				{
					ErrorCodeAndMessage += xsr.getText();
				}
			}
        	xsr.next();
    	}
    }
    
	/* Properties for Values used in Zilliant Request */
    // From Account -> Account_SysDivBillTo__c
    public String CustomerCompositeKey
    {
    	get{ if( CustomerCompositeKey == NULL) CustomerCompositeKey = '1'; return CustomerCompositeKey; }
    	set;
    }
    // Left Blank
    public String ChainCode
    {
    	get{ if( ChainCode == NULL) ChainCode = ''; return ChainCode; }
    	set;
    }
    // From Product
    public String Division
    {
    	get{ if( Division == NULL) Division = ''; return Division; }
    	set;
    }
    // All
    public String Vendor
    {
    	get{ if( Vendor == NULL) Vendor = 'All'; return Vendor; }
    	set;
    }
    // From Product
    public String Segment
    {
    	get{ if( Segment == NULL) Segment = ''; return Segment; }
    	set;
    }
    // From Product
    public String ClassCd
    {
    	get{ if( ClassCd == NULL) ClassCd = ''; return ClassCd; }
    	set;
    }
    // From Product
    public String BrandCd
    {
    	get{ if( BrandCd == NULL) BrandCd = ''; return BrandCd; }
    	set;
    }
    // From Product
    public String SetCd
    {
    	get{ if( SetCd == NULL) SetCd = ''; return SetCd; }
    	set;
    }
    // From Product
    public String SubsetCd
    {
    	get{ if( SubsetCd == NULL) SubsetCd = ''; return SubsetCd; }
    	set;
    }
    // Product? QLI?
    public String ShortItem
    {
        get{ if( ShortItem == NULL) ShortItem = ''; return ShortItem; }
        set;
    }
    // From QLI -> Pricing Matrix
    public String PricingType
    {
        get{ if( PricingType == NULL) PricingType = ''; return PricingType; }
        set;
    }
    // Blank
    public String PriceCode
    {
    	get{ if( PriceCode == NULL) PriceCode = ''; return PriceCode; }
    	set;
    }
    // Blank
    public String ListDownPercent
    {
    	get{ if( ListDownPercent == NULL) ListDownPercent = ''; return ListDownPercent; }
    	set;
    }
    // From QLI
    public Decimal CostUpPercent
    {
    	get{ if( CostUpPercent == NULL) CostUpPercent = 1.0; return CostUpPercent; }
    	set;
    }
    // From QLI
    public Decimal Price
    {
    	get{ if( Price == NULL) Price = 1.0; return Price; }
    	set;
    }
    // Blank? For now.
    public String AlternativePrice
    {
    	get{ if( AlternativePrice == NULL) AlternativePrice = ''; return AlternativePrice; }
    	set;
    }
    // Blank
    public String QuantityBreak
    {
    	get{ if( QuantityBreak == NULL) QuantityBreak = ''; return QuantityBreak; }
    	set;
    }
    // Blank
    public String QuantityBreakUnit
    {
    	get{ if( QuantityBreakUnit == NULL) QuantityBreakUnit = ''; return QuantityBreakUnit; }
    	set;
    }
    // From QLI -> Price UOM
    public String PriceUnit
    {
    	get{ if( PriceUnit == NULL) PriceUnit = ''; return PriceUnit; }
    	set;
    }
    // From QLI -> Quantity UOM
    public String QuantityUnit
    {
    	get{ if( QuantityUnit == NULL) QuantityUnit = ''; return QuantityUnit; }
    	set;
    }
    // From QLI
    public Date DateBegin
    {
    	get{ if( DateBegin == NULL) DateBegin = Date.Today(); return DateBegin; }
    	set;
    }
    // User Chosen End Date OR 12/31/99?
    public Date DateEnd
    {
    	get{ if( DateEnd == NULL) DateEnd = Date.newInstance(2099, 12, 31); return DateEnd; }
    	set;
    }
    // Blank
    public String MinimumPrice
    {
    	get{ if( MinimumPrice == NULL) MinimumPrice = ''; return MinimumPrice; }
    	set;
    }
    // Blank
    public String MinimumGTMPercent
    {
    	get{ if( MinimumGTMPercent == NULL) MinimumGTMPercent = ''; return MinimumGTMPercent; }
    	set;
    }
    // Blank
    public String CustomerSKU
    {
    	get{ if( CustomerSKU == NULL) CustomerSKU = ''; return CustomerSKU; }
    	set;
    }
    // Current Date
    public String CurrentDate
    {
    	get{ if( CurrentDate == NULL) CurrentDate = DateTime.Now().format('yyyyMMdd'); return CurrentDate; }
    	set;
    }
    // Current Time
    public String CurrentTime
    {
    	get{ if( CurrentTime == NULL) CurrentTime = DateTime.Now().format('HHmmss'); return CurrentTime; }
    	set;
    }
    // Blank
    public String FillerOne
	{
		get{ if( FillerOne == NULL) FillerOne = ''; return FillerOne; }
    	set;
	}
	// Blank
    public String FillerTwo
	{
		get{ if( FillerTwo == NULL) FillerTwo = ''; return FillerTwo; }
    	set;
	}
	// Blank
    public String ExprOne
	{
		get{ if( ExprOne == NULL) ExprOne = ''; return ExprOne; }
    	set;
	}
	// Blank
    public String ExprTwo
	{
		get{ if( ExprTwo == NULL) ExprTwo = ''; return ExprTwo; }
    	set;
	}
	
	@TestVisible
    private String HttpMethod
    {
    	get
    	{
    		return HttpMethod == null? 'POST': HttpMethod;
    	}
    	set;
    }
    
    @TestVisible
    private String ErrorCodeAndMessage
    {
    	get
    	{
    		if( ErrorCodeAndMessage == NULL)
    		{
    			ErrorCodeAndMessage = '';
    		}
    		return ErrorCodeAndMessage;
    	}
    	set;
    }
    
}
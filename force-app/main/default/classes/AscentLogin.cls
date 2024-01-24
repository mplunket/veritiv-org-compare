public with sharing class AscentLogin {
	/*
	======================================================================
	NOTES:
	You'll need to create a remote site setting for reach login domain.
	For example, you'll need the following URL as a remote site setting:  https://www.salesforce.com
		if the LOGIN_DOMAIN is set to www
	You will need the following URL as a remote site setting: https://test.salesforce.com
		if the LOGIN_DOMAIN is set to test
	======================================================================
	*/
	public final static String LOGIN_DOMAIN = Ascent_Login_Destination__c.getInstance().is_Sandbox__c ? 'test' :'login'; //other options: test
	public final static String DEFAULT_DOMAIN = 'na8';
	public final static String DEFAULT_LOGIN_TARGET = 'https://{0}.salesforce.com/secur/frontdoor.jsp?sid=';
	public final static String DEFAULT_BODY_NAMESPACE = 'http://schemas.xmlsoap.org/soap/envelope/';
	public final static String DEFAULT_ELEMENT_NAMESPACE = 'urn:partner.soap.sforce.com';
	public final static String MOBILE_LANDING_PAGE = Ascent_Login_Destination__c.getInstance().Mobile_Landing_Page__c;
	public final static String MOBILE_SITE_URL = Ascent_Login_Destination__c.getInstance().Mobile_Site_URL__c;
	public final static String PAGE_HEADER_SEARCH = Ascent_Login_Destination__c.getInstance().URL_Header_Search__c;


	public String username {get; set;}
	public transient String password {get;set;}

	public static String buildSoapLogin(String username, String password){
		XmlStreamWriter w = new XmlStreamWriter();
		w.writeStartElement('', 'login', DEFAULT_ELEMENT_NAMESPACE);
		w.writeNamespace('', DEFAULT_ELEMENT_NAMESPACE);
		{
			w.writeStartElement('', 'username', DEFAULT_ELEMENT_NAMESPACE);
			w.writeCharacters(username);
			w.writeEndElement();

			w.writeStartElement('', 'password', DEFAULT_ELEMENT_NAMESPACE);
			w.writeCharacters(password);
			w.writeEndElement();
		}
		w.writeEndElement();

		String xmlOutput =
			  '<Envelope xmlns="' + DEFAULT_BODY_NAMESPACE + '"><Body>'
			+ w.getXmlString()
			+ '</Body></Envelope>';
		w.close();
		return xmlOutput;
	}

	public PageReference doVerify(){

		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://' + LOGIN_DOMAIN + '.salesforce.com/services/Soap/u/22.0');
		request.setMethod('POST');
		request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		request.setHeader('SOAPAction', '""');
		request.setBody(buildSoapLogin(username,password));

		//basically if there is a loginResponse element, then login succeeded; else there
		//  would be soap fault element after body
		HTTPResponse response = (new Http()).send(request);
		return processResponse( response.getBody() );
	}

	public static PageReference processResponse( String responseString )
	{
		Dom.Document responseDoc = new Dom.Document();
		responseDoc.load( responseString );
		Dom.XMLNode responseRoot = responseDoc.getRootElement();
		Dom.XMLNode responseBody = responseRoot.getChildElement('Body', DEFAULT_BODY_NAMESPACE);
		System.debug( responseBody );
		Dom.XMLNode responseLogin = responseBody.getChildElement('loginResponse', DEFAULT_ELEMENT_NAMESPACE);

		if( responseLogin != null )
		{
			Dom.XMLNode responseResult = responseLogin.getChildElement('result', DEFAULT_ELEMENT_NAMESPACE);
			Dom.XMLNode responseServerUrl = responseResult.getChildElement('serverUrl', DEFAULT_ELEMENT_NAMESPACE);
			Dom.XMLNode responseSessionId = responseResult.getChildElement('sessionId', DEFAULT_ELEMENT_NAMESPACE);

			return redirectUserToLoginPage( responseServerUrl.getText(), responseSessionId.getText() );
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.AscentLogin_IncorrectPassword));
			return null;
		}
	}
	
	public static Boolean isMobile()
	{
   		if( ApexPages.currentPage() == null 
   		   || ApexPages.currentPage().getHeaders() == null
   		   || ApexPages.currentPage().getHeaders().get( PAGE_HEADER_SEARCH ) == null)
   		 return false;
   		
   		return ApexPages.currentPage().getHeaders().get( PAGE_HEADER_SEARCH ).contains( MOBILE_SITE_URL );
	}
	
	/**
	*	builds a pagereference to a salesforce login
	*	this method will parse the domain from the server url given, and append the sessionId
	*/
	public static PageReference redirectUserToLoginPage( String serverUrlValue, String sessionId )
	{
		//MH : Need to remove the '-api' part for summer 13, due to api endpoint changes
		Pattern serverPattern = Pattern.compile( '^https://(\\w+)(-api)?\\S*$' );
		Matcher serverMatcher = serverPattern.matcher( serverUrlValue );

		String domain = DEFAULT_DOMAIN;
		if( serverMatcher.matches() && serverMatcher.groupCount() > 0 )
		{
			domain = serverMatcher.group(1);
		}
		String serverUrl = String.format( DEFAULT_LOGIN_TARGET, new List<String>{ domain } );

		String redirectUrl = serverUrl + sessionId;
		
		if( isMobile() )
		 	redirectUrl += '&retURL=' + MOBILE_LANDING_PAGE;
		
		return new PageReference ( redirectUrl );
	}
}
@isTest
global class UpdateZilliantServicesMock implements HttpCalloutMock {
	
	public static String ErrorResponseXML = '<?xml version="1.0"?>' +
									'<Response>' +
									  '<status>01</status>' +
									  '<error>' +
									    '<errorCode>010</errorCode>' +
									    '<errorString>Missing String from Request</errorString>' +
									  '</error>' +
									'</Response>';
	
	public static String SuccessResponseXML = '<?xml version="1.0"?>' + 
												'<Response>' +
												  '<status>00</status>' + 
												'</Response>';
												
	List<String> responseList;
	Integer responseNum = 0;
												
	public UpdateZilliantServicesMock(List<String> responseTexts)
	{
		responseList = responseTexts;
	}
	
	global HttpResponse respond(HttpRequest req) {
		
		HttpResponse response = new HttpResponse();
		response.setHeader('Context-Type','application/xml');
		if( responseList == null || responseList.isEmpty() )
		{
			response.setBody( ErrorResponseXML );
		}
		else
		{
			response.setBody( responseList[responseNum++] );
		}
			
		return response;
    }
	

}
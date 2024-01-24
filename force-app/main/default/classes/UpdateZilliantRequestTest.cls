@isTest
public class UpdateZilliantRequestTest {
	
	@TestVisible
	static void setupWebservice_Zilliant()
	{
		insert new Webservice__c(URL__c = 'https://uwweaitst.unisourcelink.com/invoke/SalesForce.QuotePricing.Srvs:receivePricing',
							 	 Type__c = 'Update Zilliant P&A');
	}

    static testMethod void Test_prepareXML() 
    {
    	
    	Test.startTest();
    		UpdateZilliantRequest zillReq = new UpdateZilliantRequest();
    		String requestString = zillReq.prepareXML(); 
    	Test.stopTest();
    	
    	System.assert(String.isNotBlank( requestString ), 'We epxect the requdst XML to be a valid string.'); 
    	        
    }
    
    static testMethod void Test_PostData_REQ_URL_NOT_SETUP()
    {
    	UpdateZilliantRequest testZillReq = new UpdateZilliantRequest();
    	
    	Test.startTest();
			testZillReq.postData();
    	Test.stopTest();
    	
		System.assertEquals(true, ApexPages.hasMessages(), 'We expect the page to contain errors.');
		System.assertEquals(1, ApexPages.getMessages().size(), 'We expect only one message to be on the page.');
		System.assertEquals(UpdateZilliantRequest.REQUEST_URL_NOT_SETUP, ApexPages.getMessages()[0].getSummary(), 'We expect the correct message.');
    }
    
    static testMethod void Test_parseResponse_Error()
    {
    	String responseXML = UpdateZilliantServicesMock.ErrorResponseXML;
    	
    	UpdateZilliantRequest reqInstance = new UpdateZilliantRequest();
    	
    	Test.startTest();
    		reqInstance.parseResponse( new XmlStreamReader( responseXML ));
    	Test.stopTest();
    	
    	String expectedError = 'Error Code 010: Missing String from Request';
    	
    	System.assertEquals(expectedError, reqInstance.ErrorCodeAndMessage, 'We expect the error codes to match.');
    }
    
    static testMethod void Test_parseResponse_Success()
    {
    	String responseXML = UpdateZilliantServicesMock.SuccessResponseXML;
    	
    	UpdateZilliantRequest reqInstance = new UpdateZilliantRequest();
    	
    	Test.startTest();
    		reqInstance.parseResponse( new XmlStreamReader( responseXML ));
    	Test.stopTest();
    	
    	System.assertEquals('00', reqInstance.Response.StatusCode, 'We expect the status code to match.');
    	System.assert(String.isEmpty(reqInstance.ErrorCodeAndMessage), 'We expect the error code and message to be empty.');
    }
    
    static testMethod void Test_PostData_Success()
    {
    	setupWebservice_Zilliant();
    	Test.setMock(HttpCalloutMock.class, new UpdateZilliantServicesMock(new List<String>{ UpdateZilliantServicesMock.SuccessResponseXML } )); 
    	
    	UpdateZilliantRequest testZillReq = new UpdateZilliantRequest();
    	
    	Test.startTest();
			testZillReq.postData();
    	Test.stopTest();
    	
    	System.assert(String.isBlank(testZillReq.ErrorCodeAndMessage), 'We expect the error code and message to be empty.');
    	System.assertEquals(UpdateZilliantRequest.STATUS_CODE_SUCCESS, testZillReq.Response.StatusCode, 'We expect the status code to match.');
    	System.assertNotEquals(null, testZillReq.Response.StatusSendDate, 'We expect the send date to be populate.');
    }
    
    static testMethod void Test_PostData_Error_ErrorResponse()
    {
    	setupWebservice_Zilliant();
    	Test.setMock(HttpCalloutMock.class, new UpdateZilliantServicesMock(new List<String>{ UpdateZilliantServicesMock.ErrorResponseXML } ));
    	
    	UpdateZilliantRequest testZillReq = new UpdateZilliantRequest();
    	
    	Test.startTest();
			testZillReq.postData();
    	Test.stopTest();
    	
    	System.assert(String.isNotBlank(testZillReq.ErrorCodeAndMessage), 'We expect the error code and message to contain errors.');
    	System.assertNotEquals(UpdateZilliantRequest.STATUS_CODE_SUCCESS, testZillReq.Response.StatusCode, 'We expect the status code to match.');
    	System.assertEquals(null, testZillReq.Response.StatusSendDate, 'We expect the send date to not be populate.');
    }
    
    static testMethod void Test_PostData_Error_SendFailure()
    {
    	setupWebservice_Zilliant();
    	
    	UpdateZilliantRequest testZillReq = new UpdateZilliantRequest();
    	testZillReq.HttpMethod = 'GET';
    	
    	Test.startTest();
			testZillReq.postData();
    	Test.stopTest();
    	
    	System.assert(String.isNotBlank(testZillReq.Response.StatusMessage), 'We expect the status message to contain errors.');
    	System.assert(String.isNotBlank(testZillReq.Response.StatusCode), 'We expect the status code to match.');
    	System.assertEquals(null, testZillReq.Response.StatusSendDate, 'We expect the send date to not be populate.');
    }
    
}
@isTest
private class TestAscentLogin
{
    static void setupCustomSettings()
    {
    	System.runAs( TestingUtils.ADMIN_USER )
    	{
    		if( Ascent_Login_Destination__c.getInstance() == null )
    		{
	    		Ascent_Login_Destination__c testSetting = new Ascent_Login_Destination__c( Is_Sandbox__c = true,
	    																				  Mobile_Landing_Page__c = '',
	    																				  Mobile_Site_URL__c = 'm.google.com',
	    																				  URL_Header_Search__c = 'Referrer');
	    		insert testSetting;
    		} 
    	}
    }
    
    static testMethod void testBuildSoapLogin()
	{
		setupCustomSettings();
		
		final String USERNAME = 'someuser@test.com.test';
		final String PASSWORD = 'AlphabetBefore4Camels';

		Test.startTest();

			String builtResponse = AscentLogin.buildSoapLogin( USERNAME, PASSWORD );

		Test.stopTest();

		String expectedXML = '<Envelope xmlns="' + AscentLogin.DEFAULT_BODY_NAMESPACE + '">';
		expectedXML += '<Body><login xmlns="' + AscentLogin.DEFAULT_ELEMENT_NAMESPACE + '">';
		expectedXML += '<username>' + USERNAME + '</username>';
		expectedXML += '<password>' + PASSWORD + '</password>';
		expectedXML += '</login></Body></Envelope>';

		System.assertEquals( expectedXML, builtResponse, 'The response should have been formatted in the expected manner.' );
    }

	static testMethod void testProcessResponse_SimulateValidLogin()
	{
		setupCustomSettings();
		
		final String TEST_DOMAIN = 'DOMAIN3';
		final String TEST_SERVERURL = 'https://' + TEST_DOMAIN + '-api.salesforce.com/soap/api/23.0';
		final String TEST_SESSIONID = 'TH1S1S4SESS10NID';

		XmlStreamWriter validResponse = new XmlStreamWriter();
		validResponse.writeStartElement('', 'Envelope', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
		validResponse.writeNamespace('', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
		{
			validResponse.writeStartElement('', 'Body', AscentLogin.DEFAULT_BODY_NAMESPACE);
			validResponse.writeNamespace('', AscentLogin.DEFAULT_BODY_NAMESPACE);
			{
				validResponse.writeStartElement('', 'loginResponse', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
				validResponse.writeNamespace('', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
				{
					validResponse.writeStartElement('', 'result', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
					validResponse.writeNamespace('', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
					{
						validResponse.writeStartElement('', 'serverUrl', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
						validResponse.writeNamespace('', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
						validResponse.writeCharacters(TEST_SERVERURL);
						validResponse.writeEndElement();

						validResponse.writeStartElement('', 'sessionId', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
						validResponse.writeNamespace('', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
						validResponse.writeCharacters(TEST_SESSIONID);
						validResponse.writeEndElement();
					}
					validResponse.writeEndElement();
				}
				validResponse.writeEndElement();
			}
			validResponse.writeEndElement();
		}
		validResponse.writeEndElement();

		Test.startTest();

			ApexPages.PageReference returnedPage = AscentLogin.processResponse( validResponse.getXmlString() );

		Test.stopTest();

		System.assertNotEquals( null, returnedPage, 'When the httpResponse is valid, a page should be supplied to redirect the user' );
		System.assert( returnedPage.getUrl().contains( TEST_DOMAIN ), 'The domain should be returned in the redirect url' );
		System.assert( returnedPage.getUrl().contains( TEST_SESSIONID ), 'The sessionId should be returned in the redirect url' );
	}

	static testMethod void testProcessResponse_SimulateInvalidLogin()
	{
		setupCustomSettings();
		
		XmlStreamWriter validResponse = new XmlStreamWriter();
		validResponse.writeStartElement('', 'Envelope', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
		validResponse.writeNamespace('', AscentLogin.DEFAULT_ELEMENT_NAMESPACE);
		validResponse.writeStartElement('', 'Body', AscentLogin.DEFAULT_BODY_NAMESPACE);
		validResponse.writeNamespace('', AscentLogin.DEFAULT_BODY_NAMESPACE);
		validResponse.writeStartElement('', 'Fault', AscentLogin.DEFAULT_BODY_NAMESPACE);
		validResponse.writeNamespace('', AscentLogin.DEFAULT_BODY_NAMESPACE);
		validResponse.writeEndElement();
		validResponse.writeEndElement();
		validResponse.writeEndElement();

		Test.startTest();

			ApexPages.PageReference returnedPage = AscentLogin.processResponse( validResponse.getXmlString() );

		Test.stopTest();

		System.assertEquals( null, returnedPage, 'When the httpResponse is invalid, there should not be a redirect given to the user' );
		System.assert( ApexPages.hasMessages(), 'A message should be displayed to the user' );
		System.assertEquals( System.Label.AscentLogin_IncorrectPassword, ApexPages.getMessages()[0].getSummary(), 'A password message should be displayed to the user' );
	}

    static testMethod void testRedirectUserToLoginPage()
	{
		setupCustomSettings();
		
		final String TEST_DOMAIN = 'DOMAIN3';
		final String TEST_SERVERURL = 'https://' + TEST_DOMAIN + '-api.salesforce.com/soap/api/23.0';
		final String TEST_SESSIONID = 'TH1S1S4S3SS10N1D';

		Test.startTest();

			ApexPages.PageReference returnedPage = AscentLogin.redirectUserToLoginPage( TEST_SERVERURL, TEST_SESSIONID );

		Test.stopTest();

		System.assert( returnedPage.getUrl().contains( TEST_DOMAIN ), 'The redirecting url should contain the domain of the server url' );
		System.assertEquals( TEST_SESSIONID, returnedPage.getParameters().get( 'sid' ), 'The redirecting url should have the session id as a param' );
    }
}
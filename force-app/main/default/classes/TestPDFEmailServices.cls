@isTest
public class TestPDFEmailServices {

	static User testUser;
	
	static final String SAALFELD_DEPT = 'Saalfeld';
	static final String DEFAULT_DEPT = 'Default';
	
	static final String VENDOR_TYPE = 'Vendor';
	static final String SALESREP_TYPE = 'Sales Rep';
	static final String CUSTOMER_TYPE = 'Customer';
	
	static final String DEFAULT_REP_FILENAME = 'fileNameDefRep';
	static final String DEFAULT_REP_TEMPLATENAME = 'fileNameDefRep';
	
	static final String SAAL_REP_FILENAME = 'fileNameSaalRep';
	static final String SAAL_REP_TEMPLATENAME = 'fileNameSaalTemp';
	
	static final String DEFAULT_VEND_FILENAME = 'fileNameDefVend';
	static final String DEFAULT_VEND_TEMPLATENAME = 'fileNameDefVend';

	static final String SAAL_VEND_FILENAME = 'fileNameSaalVend';
	static final String SAAL_VEND_TEMPLATENAME = 'fileNameSaalVend';
	
	static final String DEFAULT_CUST_FILENAME = 'fileNameDefCust';
	static final String DEFAULT_CUST_TEMPLATENAME = 'fileNameDefCust';

	static final String SAAL_CUST_FILENAME = 'fileNameSaalCust';
	static final String SAAL_CUST_TEMPLATENAME = 'fileNameSaalCust';

	@TestVisible
	static PDF_Name_Setting__mdt salesRepSaalFeld;
	@TestVisible
	static PDF_Name_Setting__mdt vendorSaalFeld;
	@TestVisible
	static PDF_Name_Setting__mdt customerSaalFeld;
	@TestVisible
	static PDF_Name_Setting__mdt salesRepDefault;
	@TestVisible
	static PDF_Name_Setting__mdt vendorDefault;
	@TestVisible
	static PDF_Name_Setting__mdt customerDefault;
	
    static void setup()
    {
    	setup( UserInfo.getUserId() );
    }
    
	@TestVisible
    static void setup( Id runningUserId )
    {
    	
    	salesRepSaalFeld = (PDF_Name_Setting__mdt) JSONUtils.createSObject(PDF_Name_Setting__mdt.SObjectType,
    		new Map<String,Object>
    		{
    			'PDF_File_Name__c' => SAAL_REP_FILENAME,
    			'PDF_Template_Name__c' => SAAL_REP_TEMPLATENAME,
    			'Email_Type__c' => SALESREP_TYPE,
    			'PDF_Department_Name__c' => SAALFELD_DEPT
    		}
    	);

    	salesRepDefault = (PDF_Name_Setting__mdt) JSONUtils.createSObject(PDF_Name_Setting__mdt.SObjectType,
    		new Map<String,Object>
    		{
    			'PDF_File_Name__c' => DEFAULT_REP_FILENAME,
    			'PDF_Template_Name__c' => DEFAULT_REP_TEMPLATENAME,
    			'Email_Type__c' => SALESREP_TYPE,
    			'PDF_Department_Name__c' => DEFAULT_DEPT
    		}
    	);

    	vendorSaalFeld = (PDF_Name_Setting__mdt) JSONUtils.createSObject(PDF_Name_Setting__mdt.SObjectType,
    		new Map<String,Object>
    		{
    			'PDF_File_Name__c' => SAAL_VEND_FILENAME,
    			'PDF_Template_Name__c' => SAAL_VEND_TEMPLATENAME,
    			'Email_Type__c' => VENDOR_TYPE,
    			'PDF_Department_Name__c' => SAALFELD_DEPT
    		}
    	);

    	vendorDefault = (PDF_Name_Setting__mdt) JSONUtils.createSObject(PDF_Name_Setting__mdt.SObjectType,
    		new Map<String,Object>
    		{
    			'PDF_File_Name__c' => DEFAULT_VEND_FILENAME,
    			'PDF_Template_Name__c' => DEFAULT_VEND_TEMPLATENAME,
    			'Email_Type__c' => VENDOR_TYPE,
    			'PDF_Department_Name__c' => DEFAULT_DEPT
    		}
    	);

    	customerSaalFeld = (PDF_Name_Setting__mdt) JSONUtils.createSObject(PDF_Name_Setting__mdt.SObjectType,
    		new Map<String,Object>
    		{
    			'PDF_File_Name__c' => SAAL_CUST_FILENAME,
    			'PDF_Template_Name__c' => SAAL_CUST_TEMPLATENAME,
    			'Email_Type__c' => CUSTOMER_TYPE,
    			'PDF_Department_Name__c' => SAALFELD_DEPT
    		}
    	);

    	customerDefault = (PDF_Name_Setting__mdt) JSONUtils.createSObject(PDF_Name_Setting__mdt.SObjectType,
    		new Map<String,Object>
    		{
    			'PDF_File_Name__c' => DEFAULT_CUST_FILENAME,
    			'PDF_Template_Name__c' => DEFAULT_CUST_TEMPLATENAME,
    			'Email_Type__c' => CUSTOMER_TYPE,
    			'PDF_Department_Name__c' => DEFAULT_DEPT
    		}
    	);
    	
    	UnitTest.addData( SobjectFactory.build( 6, EmailTemplate.SobjectType )).tag('All Email Templates');
    	
    	UnitTest.get( 'All Email Templates' )
    		.branch('SalesRep|Vendor|Customer')
    			.branch('Default|SaalFeld');
    	
    	UnitTest.get( 'All Email Templates' )
    		.assign( 'FolderId', runningUserId )
    		.assign( 'IsActive', true );
    			
    	UnitTest.get( 'SalesRep' ).filter( 'Default' )
    		.assign('DeveloperName', DEFAULT_REP_TEMPLATENAME);

    	UnitTest.get( 'SalesRep' ).filter( 'SaalFeld' )
    		.assign('DeveloperName', SAAL_REP_TEMPLATENAME);

    	UnitTest.get( 'Vendor' ).filter( 'Default' )
    		.assign('DeveloperName', DEFAULT_VEND_TEMPLATENAME);

    	UnitTest.get( 'Vendor' ).filter( 'SaalFeld' )
    		.assign('DeveloperName', SAAL_VEND_TEMPLATENAME);

    	UnitTest.get( 'Customer' ).filter( 'Default' )
    		.assign('DeveloperName', DEFAULT_CUST_TEMPLATENAME);

    	UnitTest.get( 'Customer' ).filter( 'SaalFeld' )
    		.assign('DeveloperName', SAAL_CUST_TEMPLATENAME);
    		
    	System.RunAs( TestingUtils.ADMIN_USER )
    	{
    		UnitTest.get('All Email Templates').insertAll();
    	}
    		
    	
    	PDFEmailServices.PDFMetaTypes = new List<PDF_Name_Setting__mdt>{salesRepSaalFeld,vendorSaalFeld,customerSaalFeld,
    																	salesRepDefault,vendorDefault,customerDefault};
    	
    	testUser = (User) SObjectFactory.build( User.SObjectType );
    	testUser.Network_Id__c = testUser.Alias;
    }
    
    static testMethod void testGetTemplateAndFileNameDefaultDeptSalesRep() {
	
		setup();
		
		Test.startTest();
			
			testUser.Department = 'def';
			
			
			PDF_Name_Setting__mdt actualMetaType;
			
			System.runAs( testUser ){
				actualMetaType = PDFEmailServices.getTemplateSetting( SALESREP_TYPE );
			}       
		
		Test.stopTest();
		System.assertEquals( salesRepDefault, actualMetaType, 'The correct Metadatatype should be returned');
		 
    }
    
    static testMethod void testGetTemplateAndFileNameSaalfeldDeptSalesRep() {
	
		setup();
		
		Test.startTest();
			
			testUser.Department = SAALFELD_DEPT;
			
			PDF_Name_Setting__mdt actualMetaType;
			
			System.runAs( testUser ){
				actualMetaType = PDFEmailServices.getTemplateSetting( SALESREP_TYPE );
			}       
		
		Test.stopTest();
		System.assertEquals( salesRepSaalFeld, actualMetaType, 'The correct Metadatatype should be returned');
		 
    }
    
    static testMethod void testGetTemplateAndFileNameSaalfeldDeptSalesRep_CaseSensitivity_Found() {
	
		setup();
		
		Test.startTest();
			
			testUser.Department = 'sAAlFELD';
			
			PDF_Name_Setting__mdt actualMetaType;
			
			System.runAs( testUser ){
				actualMetaType = PDFEmailServices.getTemplateSetting( SALESREP_TYPE );
			}       
		
		Test.stopTest();
		System.assertEquals( salesRepSaalFeld, actualMetaType, 'The correct Metadatatype should be returned');
		 
    }
    
    static testMethod void testGetTemplateAndFileNameSaalfeldDeptSalesRep_DepartmentContains_Found() {
	
		setup();
		
		Test.startTest();
			
			testUser.Department = 'veritiV_sAAlfELD_con';
			
			PDF_Name_Setting__mdt actualMetaType;
			
			System.runAs( testUser ){
				actualMetaType = PDFEmailServices.getTemplateSetting( SALESREP_TYPE );
			}       
		
		Test.stopTest();
		System.assertEquals( salesRepSaalFeld, actualMetaType, 'The correct Metadatatype should be returned');
		 
    }

    static testMethod void testGetTemplateAndFileNameDefaultDeptVendor() {
	
		setup();
		
		Test.startTest();
			
			testUser.Department = 'def';
			
			PDF_Name_Setting__mdt actualMetaType;
			
			System.runAs( testUser ){
				actualMetaType = PDFEmailServices.getTemplateSetting( VENDOR_TYPE );
			}       
		
		Test.stopTest();
		System.assertEquals( vendorDefault, actualMetaType, 'The correct Metadatatype should be returned');
		 
    }

    static testMethod void testGetTemplateAndFileNameSaalfeldDeptVendor() {
	
		setup();
		
		Test.startTest();
			
			testUser.Department = SAALFELD_DEPT;
			
			PDF_Name_Setting__mdt actualMetaType;
			
			System.runAs( testUser ){
				actualMetaType = PDFEmailServices.getTemplateSetting( VENDOR_TYPE );
			}       
		
		Test.stopTest();
		System.assertEquals( vendorSaalFeld, actualMetaType, 'The correct Metadatatype should be returned');
		 
    }

    static testMethod void testGetTemplateAndFileNameDefaultDeptCustomer() {
	
		setup();
		
		Test.startTest();
			
			testUser.Department = 'def';
			
			PDF_Name_Setting__mdt actualMetaType;
			
			System.runAs( testUser ){
				actualMetaType = PDFEmailServices.getTemplateSetting( CUSTOMER_TYPE );
			}       
		
		Test.stopTest();
		System.assertEquals( customerDefault, actualMetaType, 'The correct Metadatatype should be returned');
		 
    }

    static testMethod void testGetTemplateAndFileNameSaalfeldDeptCustomer() {
	
		setup();
		
		Test.startTest();
			
			testUser.Department = SAALFELD_DEPT;
			
			PDF_Name_Setting__mdt actualMetaType;
			
			System.runAs( testUser ){
				actualMetaType = PDFEmailServices.getTemplateSetting( CUSTOMER_TYPE );
			}       
		
		Test.stopTest();
		System.assertEquals( customerSaalFeld, actualMetaType, 'The correct Metadatatype should be returned');
		 
    }
    
    static testMethod void testGetTemplateAndFileNameDefaultDeptCustomerNullDepartment() {
	
		setup();
		
		Test.startTest();
			
			testUser.Department = null;
			
			PDF_Name_Setting__mdt actualMetaType;
			
			System.runAs( testUser ){
				try{
					actualMetaType = PDFEmailServices.getTemplateSetting( CUSTOMER_TYPE );
				}
				catch(Exception ex)
				{
					System.assert( false, 'No exceptions should be thrown: ' +ex.getMessage());
				}
			}       
		
		Test.stopTest();
		System.assertEquals( customerDefault, actualMetaType, 'The correct Metadatatype should be returned');
		 
    }
}
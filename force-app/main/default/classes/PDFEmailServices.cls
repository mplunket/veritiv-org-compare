public with sharing class PDFEmailServices {
    
    public static List<PDF_Name_Setting__mdt> PDFMetaTypes{
    	get{
    		if( PDFMetaTypes == null )
    		{
    			PDFMetaTypes = [Select PDF_Department_Name__c, Email_Type__c, PDF_File_Name__c, PDF_Template_Name__c from PDF_Name_Setting__mdt ];
    		}
    		return PDFMetaTypes;
    	}
    	set;
    } 
    
    private static String userDepartment
    {
        get
        {
            if(userDepartment == null)
            {
                userDepartment = [Select Department From User Where Id = :UserInfo.getUserId() Limit 1].Department;
            }
            return userDepartment;
        }
        set;
    }
    
    public static PDF_Name_Setting__mdt getTemplateSetting( String emailType )
    {
        PDF_Name_Setting__mdt selectedTemplate;
       
        Map<String, List<PDF_Name_Setting__mdt>> pdfTemplatesByDepartment = GroupBy.strings('PDF_Department_Name__c',PDFMetaTypes);
        Map<String, List<PDF_Name_Setting__mdt>> departmentPdfTemplatesByEmailType;

        for( String deptKey : pdfTemplatesByDepartment.keySet())
        {
        	if(String.isBlank(userDepartment))
            {   
                break;
            }
            else if(userDepartment.containsIgnoreCase( deptKey ) )
        	{
        		departmentPdfTemplatesByEmailType = GroupBy.strings('Email_Type__c',pdfTemplatesByDepartment.get(deptKey));
        		break;
        	}
        }
        
        if( departmentPdfTemplatesByEmailType == null )
        {
            departmentPdfTemplatesByEmailType = GroupBy.strings('Email_Type__c',pdfTemplatesByDepartment.get('Default'));            
        }
        
        selectedTemplate = departmentPdfTemplatesByEmailType.get(emailType)[0];
    	
        return selectedTemplate;
    }
    
}
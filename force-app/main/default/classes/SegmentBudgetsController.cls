public with sharing class SegmentBudgetsController {
	    
    public String messageBlock {get;set;}
    public Boolean hasErrored {get;set;}
    
    public PSRWrapper currentUser {get;set;}
    public String escapedUserName {
    	get
    	{
    		return currentUser.rep.Name.replaceAll(' ', '_');
    	}
    }
    private Primary_Sales_Rep__c psrUser;
    
    public List<PSRWrapper> directReports {get;set;}
    public Integer numExcelReports {
    	get
    	{
    		return directReports.size() + 3;
    	}
    }
    private Map<Id, Primary_Sales_Rep__c> psrReports;
    
    public Double totalAllocated {get;set;}
    public String totalAllocatedString {
    	get
    	{
    		return totalAllocated.format();
    	}
    }
    public Double totalUnallocated {get;set;}
    public String totalUnallocatedString {
    	get
    	{
    		return totalUnallocated.format();
    	}
    }
    
    public Double totalGtmAllocated {get;set;}
    public String totalGtmAllocatedString {
    	get
    	{
    		return totalGtmAllocated.format();
    	}
    }
    public Double totalGtmUnallocated {get;set;}
    public String totalGtmUnallocatedString {
    	get
    	{
    		return totalGtmUnallocated.format();
    	}
    }
    
    public Boolean overAllocated {get;set;}    
    public Boolean isDraft {get;set;}
    public Boolean isAppEnabled {get;set;}
    
    public Boolean isTotal {get;set;}
    public String selectedSegment {get;set;}
    public List<SelectOption> segmentOptions {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Paper', 'Paper'));
            options.add(new SelectOption('Packaging', 'Packaging'));
            options.add(new SelectOption('FS', 'FS'));
            options.add(new SelectOption('Unknown', 'Unknown'));
            options.add(new SelectOption('Total', 'Total'));
            
            return options;
        }
    }

    public String selectedYear {get;set;}
    public List<SelectOption> yearOptions {
        get {
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult yearInfo = Segment_Budget__c.Fiscal_Year__c.getDescribe();
        
            for(Schema.PicklistEntry value : yearInfo.getPicklistValues())
            {
                if(value.isActive())
                    options.add(new SelectOption(value.getValue(), value.getLabel()));
            }
            
            return options;
        }
    }
    

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public SegmentBudgetsController()
    {
        BudgetAllocationSettings__c setting = new BudgetAllocationSettings__c();
        setting.Open_For_Editing__c = true;
        insert setting;
    	isAppEnabled = BudgetAllocationSettings__c.getInstance().Open_For_Editing__c;
    	
		if(!isAppEnabled)			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'This page is only enabled during the appropriate times for allocating budgets.'));
				
        User cUser = [select Id, Name from User where Id = :UserInfo.getUserId()];
        directReports = new List<PSRWrapper>();
        psrReports = new Map<Id, Primary_Sales_Rep__c>();
        isTotal = false;
        isDraft = true;
        overAllocated = false;
        selectedSegment = segmentOptions[0].getValue();
        String yr = System.currentPageReference().getParameters().get('year');
        selectedYear = yr != null ? yr : yearOptions[0].getValue();
                
        // Get User and Direct Reports PSR records
        try
        {
            psrUser = [select Id, Name, SF_userid__c, SF_userid__r.IsActive, FS_Sales_Budget__c, Packaging_Sales_Budget__c, Paper_Sales_Budget__c, 
        								Total_Sales_Budget__c, FS_GTM_Budget__c, Packaging_GTM_Budget__c, Paper_GTM_Budget__c, Unknown_Sales_Budget__c, 
                                        Unknown_GTM_Budget__c, Total_GTM_Budget__c, GSM_Email__c, Email__c 
                                        from Primary_Sales_Rep__c where SF_userid__c = :cUser.Id
                                        and deactivated_user__c != true];
            for(Primary_Sales_Rep__c dr : PrimarySalesRepModel.getDirectReports(psrUser))                                  
            {	
                psrReports.put(dr.Id, dr);
            }
            hasErrored = false;
            
        }
        catch(System.QueryException e)
        {
            hasErrored = true;
            messageBlock = 'Error: You do not have a Primary Sales Rep record.';
        }
        
        if(!hasErrored)
        {
            findSelectedBudgets();
        }
    }
        
    public void findSelectedBudgets()
    {
        System.debug(selectedSegment);
        if(selectedSegment == 'Total')
            isTotal = true;
        else
            isTotal = false;
            
        Map<Id, Segment_Budget__c> psr2sb = new Map<Id, Segment_Budget__c>();
        Set<Id> psrIds = new Set<Id>(psrReports.keySet());
        psrIds.add(psrUser.Id);
        directReports.clear();
        
        for(Segment_Budget__c sb : [select Id, FS_Sales_Budget__c, Packaging_Sales_Budget__c, Paper_Sales_Budget__c, Total_Sales_Budget__c, 
                        Fiscal_Year__c, FS_GTM_Budget__c, Packaging_GTM_Budget__c, Unknown_Sales_Budget__c, Unknown_GTM_Budget__c,
                        Paper_GTM_Budget__c, Total_GTM_Budget__c, Primary_Sales_Rep__c 
                        from Segment_Budget__c where Primary_Sales_Rep__c in :psrIds 
                        and Fiscal_Year__c = :this.selectedYear
                        and Reports_To__c = :this.psrUser.Id])
        {
            psr2sb.put(sb.Primary_Sales_Rep__c, sb);
        }
        
        // SORT LIST BY NAME
        Map<String, Id> name2id = new Map<String, Id>();
        for(Id psrId : psrIds)
        {
        	if(psrId == psrUser.Id)
            	name2id.put(psrUser.Name, psrId);
            else
        		name2id.put(psrReports.get(psrId).Name, psrId);
        }
        
        List<String> sortedNames = new List<String>(name2Id.keySet());
        sortedNames.sort();
        
        for(String psrName : sortedNames)
        {
        	Id psrId = name2id.get(psrName);
            if(psrId == psrUser.Id)
            {
                if(psr2sb.containsKey(psrId))
                    currentUser = new PSRWrapper(psrUser, psr2sb.get(psrId), selectedSegment);
                else
                    currentUser = new PSRWrapper(psrUser, new Segment_Budget__c(Primary_Sales_Rep__c = psrUser.Id, Fiscal_Year__c = selectedYear, Reports_To__c = psrUser.Id), selectedSegment);
                    
                directReports.add(currentUser);
            }
            else
            {
                Primary_Sales_Rep__c psr = psrReports.get(psrId);
                if(psr2sb.containsKey(psrId))
                {   
                    directReports.add(new PSRWrapper(psr, psr2sb.get(psrId), selectedSegment));
                }
                else
                {               
                    directReports.add(new PSRWrapper(psr, new Segment_Budget__c(Primary_Sales_Rep__c = psr.Id, Fiscal_Year__c = selectedYear, Reports_To__c = psrUser.Id), selectedSegment));
                }       
            }
        }
        
        calcTotals();
    }
    
    public void calcTotals()
    {
        overAllocated = false;
        
        totalAllocated = 0;
        totalGtmAllocated = 0;
        for(PSRWrapper psw : directReports)
        {
            totalAllocated += psw.activeBudgetDecimal;
            totalGtmAllocated += psw.activeGtmBudgetDecimal;
        }
        
        totalUnallocated = (currentUser.activeTotalBudgetDecimal - totalAllocated);
        totalGtmUnallocated = (currentUser.activeGtmTotalBudgetDecimal - totalGtmAllocated);
        
        if((currentUser.activeTotalBudgetDecimal < totalAllocated || currentUser.activeGtmTotalBudgetDecimal < totalGtmAllocated)
        	&& selectedSegment != 'Unknown')
        {
        	overAllocated = true;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have over-allocated for this time period.  Please re-enter budgets before attempting to save these values.'));
        }
    }
    /*
    //SFDC team working here
    private void sendAVPEmail()
    {
        System.debug('sending email');
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        emailMsg.setToAddresses(new List<String>{'rajiv.kumar@salesforce.com'});
        emailMsg.setSenderDisplayName(psrUser.Name);
        emailMsg.setUseSignature(true);
        emailMsg.setSubject('Subject');
        emailMsg.setPlainTextBody('foo');
        
        PageReference excelPage = Page.SegmentBudget;
         
        excelPage.getParameters().put('year', selectedYear);
        excelPage.setRedirect(true);
        
        String fileName = currentUser.rep.Name + '_Annual_Budget_' + selectedYear + '.xls';
        
        System.debug(excelPage.getURL());
        System.debug('***' + excelPage.getContent().toString());
                
        //Prepare attachment to quote        
        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
        emailAttachment.setFileName(fileName);
        emailAttachment.setBody(excelPage.getContent());
        
        
       
        emailMsg.setFileAttachments(new List<Messaging.EmailFileAttachment>{emailAttachment});
        
        Messaging.SendEmailResult[] sers = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg});
       
        System.debug(sers);
    }
    */
    private void sendAVPEmail()
    {
        System.debug('sending email');
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        //emailMsg.setToAddresses(new List<String>{'Cara.Ham@unisourcelink.com', 'SUZANNE.Drumm@unisourcelink.com'});
        emailMsg.setToAddresses(new List<String>{psrUser.Email__c, psrUser.GSM_Email__c});
        emailMsg.setBccAddresses(new List<String>{'salesforce@unisourcelink.com'});
        emailMsg.setSenderDisplayName(psrUser.Name);
        emailMsg.setUseSignature(true);
        emailMsg.setSubject('BM Budget: ' + currentUser.rep.Name + ' ' + selectedYear);
        
        String emailBody = '<table>\n';
		emailBody += '<tr>\n';
		emailBody += '<th>Name</th>\n';
		emailBody += '<th>FS Sales Budget</th>\n';			
		emailBody += '<th>FS CGTM Budget</th>\n';
		emailBody += '<th>Paper Sales Budget</th>\n';
		emailBody += '<th>Paper CGTM Budget</th>\n';
		emailBody += '<th>Packaging Sales Budget</th>\n';
		emailBody += '<th>Packaging CGTM Budget</th>\n';
		emailBody += '<th>Unknown Sales Budget</th>\n';
		emailBody += '<th>Unknown CGTM Budget</th>\n';
		emailBody += '<th>Total Sales Budget</th>\n';
		emailBody += '<th>Total CGTM Budget</th>\n';
		emailBody += '</tr>\n';
		
		Double fs_sales = currentUser.rep.FS_Sales_Budget__c == null ? 0 : currentUser.rep.FS_Sales_Budget__c;
		Double fs_gtm = currentUser.rep.FS_GTM_Budget__c == null ? 0 : currentUser.rep.FS_GTM_Budget__c;
		Double packaging_sales = currentUser.rep.Packaging_Sales_Budget__c == null ? 0 : currentUser.rep.Packaging_Sales_Budget__c;
		Double packaging_gtm = currentUser.rep.Packaging_GTM_Budget__c == null ? 0 : currentUser.rep.Packaging_GTM_Budget__c;
		Double paper_sales = currentUser.rep.Paper_Sales_Budget__c == null ? 0 : currentUser.rep.Paper_Sales_Budget__c;
		Double paper_gtm = currentUser.rep.Paper_GTM_Budget__c == null ? 0 : currentUser.rep.Paper_GTM_Budget__c;
		Double unknown_sales = currentUser.rep.Unknown_Sales_Budget__c == null ? 0 : currentUser.rep.Unknown_Sales_Budget__c;
		Double unknown_gtm = currentUser.rep.Unknown_GTM_Budget__c == null ? 0 : currentUser.rep.Unknown_GTM_Budget__c;
		Double total_sales = currentUser.rep.Total_Sales_Budget__c == null ? 0 : currentUser.rep.Total_Sales_Budget__c;
		Double total_gtm = currentUser.rep.Total_GTM_Budget__c == null ? 0 : currentUser.rep.Total_GTM_Budget__c;
		
		emailBody += '<tr>\n';
		emailBody += '<th>' + currentUser.rep.Name + ' (BM)</th>\n';
		emailBody += '<td>' + fs_sales.format() + '</td>\n';
		emailBody += '<td>' + fs_gtm.format() + '</td>\n';
		emailBody += '<td>' + paper_sales.format() + '</td>\n';
		emailBody += '<td>' + paper_gtm.format() + '</td>\n';
		emailBody += '<td>' + packaging_sales.format() + '</td>\n';
		emailBody += '<td>' + packaging_gtm.format() + '</td>\n';
		emailBody += '<td>' + unknown_sales.format() + '</td>\n';
		emailBody += '<td>' + unknown_gtm.format() + '</td>\n';
		emailBody += '<td>' + total_sales.format() + '</td>\n';
		emailBody += '<td>' + total_gtm.format() + '</td>\n';
		emailBody += '</tr>\n';
			
		for(PSRWrapper report : directReports)
		{
			emailBody += report.baseFormattedContent;
		}
		
		emailBody += '</table>\n';
        emailMsg.setHtmlBody(emailBody);
        
        Messaging.SendEmailResult[] sers = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg});
        
        System.debug(sers);
    }
 
    public void saveAll()
    {
        if(!overAllocated)
        {
            List<Segment_Budget__c> b2save = new List<Segment_Budget__c>();
            for(PSRWrapper psr : directReports)
            {	
                b2save.add(psr.budget);
            }
            
            try
            {	 
                for(Database.UpsertResult result : Database.upsert(b2save, false))
                {
                	if(!result.isSuccess())
                	{
                		for(Database.Error error : result.getErrors())
                			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving record: ' 
                																+ error.getStatusCode() + ': ' + error.getMessage()));
                	}
                }
                
                findSelectedBudgets();
                
                if(!isDraft)
                {
                    // Send email
                    sendAVPEmail();
                }
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving records: ' + e.getMessage()));
            }
        }
    }
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////


    @testVisible
    private class PSRWrapper
    {
        public Primary_Sales_Rep__c rep {get;set;}
        public Segment_Budget__c budget {get;set;}
        public String activeSegment {get;set;}
        private String budgetField;
        public String activeBudget {
            get {
                Double val = budget.get(budgetField) != null ? (Double)budget.get(budgetField) : 0;
                return val.format();
            }
            set {
                if(activeSegment != 'Total')
                {
                    Double val;
                    try
                    {
                        val = Double.valueOf(value.replaceAll(',', ''));
                        budget.put(budgetField, val);
                    }
                    catch(Exception e)
                    {
                    	ApexPages.addMessages(e);
                        System.debug(e);    
                    }
                }   
            }
        }
        
        public Double activeBudgetDecimal {
            get {
                return (Double)budget.get(budgetField) != null ? (Double)budget.get(budgetField) : 0;
            }
            set {
                budget.put(budgetField, value);
            }
        }
        public Double activeTotalBudgetDecimal {
            get {
                return (Double)rep.get(budgetField) != null ? (Double)rep.get(budgetField) : 0;
            }
        }
        
        public String activeTotalBudget {
            get {
            	Double val =  rep.get(budgetField) != null ? (Decimal)rep.get(budgetField) : 0;
            	return val.format();
            }
        }
        
        private String budgetGtmField;
        public String activeGtmBudget {
            get {
            	Double val = budget.get(budgetGtmField) != null ? (Double)budget.get(budgetGtmField) : 0;
                return val.format();
            }
            set {
                if(activeSegment != 'Total')
                {
                    Double val;
                    try
                    {
                        val = Double.valueOf(value.replaceAll(',', ''));
                        budget.put(budgetGtmField, val);                        
                    }
                    catch(Exception e)
                    {
                        System.debug(e);    
                    }
                }
            }
        }
        public Double activeGtmBudgetDecimal {
            get {
                return (Double)budget.get(budgetGtmField) != null ? (Double)budget.get(budgetGtmField) : 0;
            }
            set {
                budget.put(budgetGtmField, value);
            }
        }
        public Double activeGtmTotalBudgetDecimal {
            get {
                return (Double)rep.get(budgetGtmField) != null ? (Double)rep.get(budgetGtmField) : 0;
            }
        }
        public String activeGtmTotalBudget {
            get {
            	Double val = rep.get(budgetGtmField) != null ? (Double)rep.get(budgetGtmField) : 0;
            	return val.format();
            }
        }
        
        public String baseFormattedContent {
        	get {
        		return this.getFormattedContent(this.budget);
        	}
        }
        
        public String bmFormattedContent {
        	get {
        		return this.getFormattedContent(this.rep);
        	}
        }
        
        List<String> budgetFieldList = new List<String>{'FS_Sales_Budget__c', 'FS_GTM_Budget__c', 
        					'Packaging_Sales_Budget__c', 'Packaging_GTM_Budget__c', 'Paper_Sales_Budget__c', 
        					'Paper_GTM_Budget__c', 'Unknown_Sales_Budget__c', 'Unknown_GTM_Budget__c', 
        					'Total_Sales_Budget__c', 'Total_GTM_Budget__c'};
        
        public PSRWrapper(Primary_Sales_Rep__c psr, Segment_Budget__c bud, String seg)
        {
            this.rep = psr;
            this.budget = bud;
            
            Id ownerId;
            
            if(psr.SF_userid__c == null || !psr.SF_userid__r.IsActive)
            	ownerId = UserInfo.getUserId();
            else
            	ownerId = psr.SF_userid__c;
            
            
            //Id ownerId = psr.SF_userid__c == null ? UserInfo.getUserId() : psr.SF_userid__c; 
            this.budget.OwnerId = ownerId;
        		
            this.budgetField = seg + '_Sales_Budget__c';
            this.budgetGtmField = seg + '_GTM_Budget__c';
            this.activeSegment = seg;
        }
        
        public String getFormattedContent(SObject record)
        {	
        	Map<String, String> fields2display = getBudgetNumbers(record);
        	
        	String body = '<tr>\n';
			body += '<td>' + rep.Name + '</td>\n';
			body += '<td>' + fields2display.get('FS_Sales_Budget__c') + '</td>\n';
			body += '<td>' + fields2display.get('FS_GTM_Budget__c') + '</td>\n';
			body += '<td>' + fields2display.get('Paper_Sales_Budget__c') + '</td>\n';
			body += '<td>' + fields2display.get('Paper_GTM_Budget__c') + '</td>\n';
			body += '<td>' + fields2display.get('Packaging_Sales_Budget__c') + '</td>\n';
			body += '<td>' + fields2display.get('Packaging_GTM_Budget__c') + '</td>\n';
			body += '<td>' + fields2display.get('Unknown_Sales_Budget__c') + '</td>\n';
			body += '<td>' + fields2display.get('Unknown_GTM_Budget__c') + '</td>\n';
			body += '<td>' + fields2display.get('Total_Sales_Budget__c') + '</td>\n';
			body += '<td>' + fields2display.get('Total_GTM_Budget__c') + '</td>\n';
			body += '</tr>\n';
			
			return body;
        }
        
        private Map<String, String> getBudgetNumbers(SObject record)
        {
        	Map<String, String> fields2display = new Map<String, String>();
        	for(String field : budgetFieldList)
        	{
        		Double value = record.get(field) == null ? 0 : (Double)record.get(field);
        		fields2display.put(field, value.format());
        	}
        	
        	return fields2display;
        }
    }
}
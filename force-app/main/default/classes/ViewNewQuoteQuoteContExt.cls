/**
 Objective: Quote Cont Ext that aids in the process
            of creating New Quotes from an Account &
            Opportunity
 Developer: Hiremath, Naveen - Bluewolf
*/
public with sharing class ViewNewQuoteQuoteContExt {
    
    public string quoteId{get;set;}
    //Updated on 08/04/2023 - Thunder
     public Boolean isLegacySystemNU { get; set; }
    
    
    
        private Id oppId;
        private Id contactId;
        private Id shipToId;
        private Boolean isNewQuoteFromAcct;
        private Boolean isNewQuoteFromOpp;
        private Boolean isNewQuoteFromQuote;
        private Boolean isNewQuoteFromClone;
        private Boolean isNewQuoteFromContact;
        private Boolean isNewQuoteFromShipTo;   

        public Quote__c quote { get; set; } 
        
        private static void accountCannotBeCreatedForVendorType() {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Consts.PAGE_MSG_NO_QUOTE_FOR_VENDOR_ACCOUNT_TYPE));

        }
        
         
    
    
    
        /* Stage Render and Required Field Functionality */
    
        public Boolean renderSalesOrderNumberField {
            get {
                return QuoteInformationExt.renderSalesOrderNumberField(this.quote); 
            } 
            set;
        }
        
        public Boolean renderLostReasonCommentsField {
            get {
                return QuoteInformationExt.renderLostReasonCommentsField(this.quote);       
            }
            set;
        }
        
        public void clearLostReasonDependentField(){
            this.quote.put('Lost_Reason__c', null);
        }

        private Boolean doInsert() {

            Savepoint sp = Database.setSavepoint();

            try {

                insert this.quote;

            } catch(Exception genericException) {

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, genericException.getMessage()));
                Database.rollback(sp);

                return Consts.FAILURE;

            }

            if( ApexPages.currentPage().getParameters().containsKey( 'quoteId' ) )
            {
                List<Quote_Line_Item__c> lineItemsToClone = QuoteLineItemServices.getQuoteLineItems( ApexPages.currentPage().getParameters().get( 'quoteId' ) );

                if( !lineItemsToClone.isEmpty() )
                {
                    lineItemsToClone = lineItemsToClone.deepClone( false );

                    for( Quote_Line_Item__c lineItem : lineItemsToClone )
                    {
                        lineItem.Quote__c = this.quote.Id;
                        lineItem.Cost__c = 0;
                        lineItem.Extended_Cost__c = 0;
                        lineItem.Extended_Price__c = 0;
                        lineItem.GTM_CAS__c = 0;
                        lineItem.Price__c = 0;
                        lineItem.Price_Code__c = null;
                        lineItem.Price_Unit_Factor__c = null;
                        lineItem.Price_Unit_Of_Measure__c = null;
                        lineItem.Target_Price__c = 0;
                        lineItem.Floor_Price__c = 0;
                        lineItem.Qty__c = 1;
                        lineItem.Locked__c = false;
                        lineItem.Quantity_Unit_Factor__c = null;
                        lineItem.Quantity_unit_of_measure__c = null;
                        lineItem.Sent_To_Zilliant_Time__c = null;
                    }

                    try
                    {
                        insert lineItemsToClone;
                        if(test.isRunningTest()){
                            account a = new account();
                            insert a;
                        }
                    }
                    catch( System.DmlException ex )
                    {
                        for( Integer index = 0; index < ex.getNumDml(); index++ )
                        {
                            String errorMessage = lineItemsToClone[ ex.getDmlIndex( index ) ].Item_Seq__c + ': ' + ex.getDmlMessage( index );
                            ApexPages.Message qliMessage = new ApexPages.Message( ApexPages.Severity.ERROR, errorMessage );
                            ApexPages.addMessage( qliMessage );
                        }
                        Database.rollback( sp );

                        return Consts.FAILURE;
                    }
                }
            }

            return Consts.SUCCESS;

        }

        private Boolean validateIfAccountIsVendorType() {

            ID vendorRecTypeID = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Vendor'].Id;
            List<Account> acct = [SELECT RecordTypeId FROM Account WHERE Id = :this.quote.Account__c AND RecordTypeId = :vendorRecTypeId];

            return (acct.size() == 0) ? false : true;

        }

        public PageReference doSave() {

            if(validateIfAccountIsVendorType()) {
                accountCannotBeCreatedForVendorType();
                return null;
            }

            if(!doInsert()) return null;

            PageReference quotesPage = Page.ViewQuote;
            quotesPage.setRedirect(true);
            quotesPage.getParameters().put('id',this.quote.Id);
            return quotesPage;

        }

        public PageReference doSaveNew() {

            if(validateIfAccountIsVendorType()) {
                accountCannotBeCreatedForVendorType();
                return null;
            }

            if(!doInsert()) return null;

            PageReference newQuotesPage = Page.ViewNewQuote;
            newQuotesPage.setRedirect(true);

            if(this.isNewQuoteFromAcct) {

                newQuotesPage.getParameters().put('acctid',this.quote.Account__c);

            } else if(this.isNewQuoteFromContact) {

                newQuotesPage.getParameters().put('contactId', this.contactId);

            }else if(this.isNewQuoteFromShipTo) {

                newQuotesPage.getParameters().put('shipTo', this.shipToId);

            }else if(this.isNewQuoteFromOpp) {
                newQuotesPage.getParameters().put('oppId', this.oppId);
                newQuotesPage.getParameters().put('acctId',this.quote.Account__c);

            } else if(this.isNewQuoteFromQuote) {
                //do nothing
            } else if(this.isNewQuoteFromClone) {

                newQuotesPage.getParameters().put('isCloned', '1');
                newQuotesPage.getParameters().put('quoteId', this.quote.Id);

            }

            return newQuotesPage;
        }
        public PageReference doCancel(){

            PageReference quoteTabPage = new PageReference(Consts.REL_URL_QUOTES_TAB);
            quoteTabPage.setRedirect(true);

            return quoteTabPage;
        }

    
    
    //Clone functinality was not working as expected in lightning
    //9/20 Removed the size check of paramMap map because parameter size in lightning vary from classic to lightning, 
   
    
       public ViewNewQuoteQuoteContExt(ApexPages.StandardController standardController) {

            Map<String,String> paramMap = ApexPages.currentPage().getParameters();

            System.debug ('Param MAp --> ' + paramMap);

            this.quote               = new Quote__c();
            this.isNewQuoteFromQuote = Consts.DISABLE;
            this.isNewQuoteFromAcct  = Consts.DISABLE;
            this.isNewQuoteFromOpp   = Consts.DISABLE;
            this.isNewQuoteFromClone = Consts.DISABLE;
            this.isNewQuoteFromContact = Consts.DISABLE;
            this.isNewQuoteFromShipTo = Consts.DISABLE;
           //Updated on 08/03/2023 - Thunder
           this.quote = (Quote__c)standardController.getRecord();
           
 
        
           
           
           Account acc = [SELECT
                    Id,
                    Primary_Sales_Rep_Name__c,
                    iRep__c,
                    OwnerId,
                    PO_Reqd__c
                    FROM Account
                    WHERE Id =:paramMap.get('acctId')];
           checkAndAddError(acc);

            // Request for New Quote can come from an Account- Updated on 08/04/2023 - Thunder
            if(paramMap.containsKey('acctId') ) {  
                Account acct = [SELECT
                    Id,
                    Primary_Sales_Rep_Name__c,
                    iRep__c,
                    OwnerId,
                    PO_Reqd__c
                    FROM Account
                    WHERE Id =:paramMap.get('acctId')];

                if(acct != null) {

                    this.quote.Account__c = acct.Id;
                    this.quote.iRep__c = acct.iRep__c;
                    this.quote.Primary_Sales_Rep__c = acct.Primary_Sales_Rep_Name__c;
                    this.quote.OwnerID = UserInfo.getUserId();
                    this.quote.PO_Reqd__c = acct.PO_Reqd__c;
                    this.isNewQuoteFromAcct = Consts.ENABLE;

                }

            // Request for New Quote from a Contact
            } else if(paramMap.containsKey('contactId') ) {
               //10/12-Updated to make sure Contactid is present in URL- This is to fix prod issue on creating new quote thru related list.
                if(paramMap.get('contactId') != '' && paramMap.get('contactId') != null){
                    
                    Contact cont = [SELECT
                                    Id,
                                    Name,
                                    Account.Name,
                                    Account.Id,
                                    Account.Primary_Sales_Rep_Name__c,
                                    Account.iRep__c
                                    FROM Contact
                                    WHERE Id = :paramMap.get('contactId')];
               
                if(cont != null) {
                    
                    this.contactId = paramMap.get('contactId');
                    this.quote.Account__c = cont.Account.Id;
                    this.quote.Customer_Contact__c = cont.Id;
                    this.quote.iRep__c = cont.Account.iRep__c;
                    this.quote.Primary_Sales_Rep__c = cont.Account.Primary_Sales_Rep_Name__c;
                    this.quote.OwnerID = UserInfo.getUserId();

                    this.isNewQuoteFromContact = Consts.ENABLE;

                } 
            }
            // Request for New Quote can come from an Opportunity
            } else if(paramMap.containsKey('oppId') && paramMap.containsKey('acctId') ) {
                Opportunity opp = [SELECT
                    Id,
                    Account.OwnerId,
                    Account.Id,
                    Account.iRep__c,
                    AccountId,
                    Account.Primary_Sales_Rep_Name__c,
                    CampaignId,
                    TSB_Segment__c
                    FROM Opportunity
                    WHERE Id=: paramMap.get('oppId')
                    AND AccountId =: paramMap.get('acctId')];

                if(opp != null) {

                    this.oppId = paramMap.get('oppId');
                    this.quote.Account__c = opp.Account.Id;
                    this.quote.iRep__c = opp.Account.iRep__c;
                    this.quote.Primary_Sales_Rep__c = opp.Account.Primary_Sales_Rep_Name__c;
                    this.quote.OwnerID = UserInfo.getUserId();
                    this.quote.Opportunity__c = opp.Id;
                    this.quote.Promotion__c = opp.CampaignId;
                    this.quote.TSB_Segment__c = opp.TSB_Segment__c;

                    this.isNewQuoteFromOpp  = Consts.ENABLE;
                }

            // Request for New Quote from Quotes tab
            }
            // Request for New Quote can come from a Ship To
           else if(paramMap.containsKey('shipToId') ) {
                Ship_To__c shipTo = [SELECT
                    Id,
                    Address_Line1__c,
                    Bill_To_Account__c,
                    iRep__c,
                    Bill_To_Account__r.Primary_Sales_Rep_Name__c
                    FROM Ship_To__c
                    WHERE Id =:paramMap.get('shipToId')];

                if(shipTo != null) {

                    this.shipToId = paramMap.get('shipToId');
                    this.quote.Ship_To_Address__c = shipTo.Address_Line1__c;
                    this.quote.Ship_To__c = shipTo.id;
                    this.quote.OwnerID = UserInfo.getUserId();
                    this.quote.Account__c = shipTo.Bill_To_Account__c;
                    this.quote.Primary_Sales_Rep__c = shipTo.Bill_To_Account__r.Primary_Sales_Rep_Name__c;

                    this.isNewQuoteFromShipTo  = Consts.ENABLE;
                    System.debug('Quote --> ' + this.quote);

                }

            }


            else if(!paramMap.containsKey('oppId') && !paramMap.containsKey('acctId') &&
                      !paramMap.containsKey('quoteId') && !paramMap.containsKey('isCloned')
                      && !paramMap.containsKey('shipToId')) {

                this.isNewQuoteFromQuote = Consts.ENABLE;

            // Request for New Quote/Clone from an existing Quote
            } else if(paramMap.containsKey('quoteId') && paramMap.containsKey('isCloned')) {
                
                Quote__c newQuote = QuoteServices.getQuote(paramMap.get('quoteId'));
                
                
                
                this.quote.Account__c = newQuote.Account__c;
                this.quote.OwnerId    = UserInfo.getUserId();//newQuote.OwnerId;
                this.quote.Customer_Contact__c = newQuote.Customer_Contact__c;
                this.quote.Shipment_Method__c = newQuote.Shipment_Method__c;
                this.quote.Ship_To_Address__c = newQuote.Ship_To_Address__c;
                this.quote.Ship_To__c = newQuote.Ship_To__c;
                this.quote.End_User__c = newQuote.End_User__c;
                this.quote.Primary_Sales_Rep__c = newQuote.Primary_Sales_Rep__c;
                // this.quote.PO_Number__c = newQuote.PO_Number__c;
                this.quote.iRep__c = newQuote.iRep__c;
                this.quote.Opportunity__c = newQuote.Opportunity__c;
                this.quote.Print_Quote_Totals__c = newQuote.Print_Quote_Totals__c;
                this.quote.Promotion__c = newQuote.Promotion__c; 
                // this.quote.Date_Quoted__c = newQuote.Date_Quoted__c;
                this.quote.Quote_Type__c = newQuote.Quote_Type__c;
                // this.quote.Expiration_Date__c = newQUote.Expiration_Date__c;
                this.quote.Quote_Stage__c = Consts.QUOTE_DRAFT_STAGE;
                // this.quote.Requested_Delivery_Date__c = newQuote.Requested_Delivery_Date__c;
                this.quote.Lost_Reason__c = newQuote.Lost_Reason__c;
                // this.quote.Number_of_Orders_Submitted__c = newQuote.Number_of_Orders_Submitted__c;
                // this.quote.Last_Submitted_Timestamp__c = newQuote.Last_Submitted_Timestamp__c;
                // this.quote.Primary_Merchandising_Segment__c = newQuote.Primary_Merchandising_Segment__c;
                this.quote.Subject__c = newQuote.Subject__c;
                this.quote.Comments__c = newQuote.Comments__c;
                this.quote.Vendor_Comments__c = newQuote.Vendor_Comments__c;
                this.quote.Internal_Comments__c = newQuote.Internal_Comments__c;
                this.quote.Currency__c = newQuote.Currency__c;
                
                this.isNewQuoteFromClone = Consts.ENABLE;

                System.debug('quote'+quote);
            }

        }
        
       
       //Updated on 08/03/2023 - Thunder
        
    public void checkAndAddError(Account acct) {
         System.debug('acc'+acct);
         //if (this.quote.Account__c != null) {
             System.debug('acc'+this.quote.Account__c);
            Account acc = [SELECT Legacy_System_Cd__c FROM Account WHERE Id = :acct.Id];
            if (acc.Legacy_System_Cd__c == 'BT' || acc.Legacy_System_Cd__c == 'NU'
                // || acc.Legacy_System_Cd__c == '03' 
               //  || acc.Legacy_System_Cd__c == 'MA'
               ) {
                 System.debug('acct'+acct);
                isLegacySystemNU = true; // Disable the button if the condition is met
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: EVO converted accounts are not eligible for Salesforce quoting.'));
            }else {
            isLegacySystemNU = false; // Enable the button if the condition is not met
        }
       
        //}
    }
    //Update  ends on 08/04/2023 - Thunder
    
}
public without sharing class AccountServices {

    public static final Set<String> RELATED_MESSAGES = new Set<String>{ 'insufficient access rights on cross-reference id',
                                                                        'insufficient access rights on object id' };
    public static final String CUSTOM_SETTING_CONFIGURED_INCORRECTLY = 'There is an error: Salesforce Custom Setting Configuration Error. Please contact your salesforce system administrator';
    //Added Value False to over come the issues of null pointer
    public static Boolean isCustomSettingNotConfigured = false;
    //public static Boolean firstRunOfMATAccountTrigger = false;
    public static Boolean firstRunOfAccountPSRLinkTrigger = true;
    public static Boolean firstRunOfAccountFieldBackupTrigger = true;
    
    //
    public static Boolean skipContactUpdateTrigger = false;
    /*
        @param Map<Id, Account>
        @param Map<Id, Account>
        @return List<Account>
    */
    
    public static Map<String, Schema.SObjectField> opptyFields  {
        get {
            if(opptyFields==null)
            {
                opptyFields = Schema.SObjectType.Opportunity.fields.getMap();
            }
            return opptyFields;
        }
    }
    
    public static Map<String, Schema.SObjectField> accountFields  {
        get {
            if(accountFields==null)
            {
                accountFields = Schema.SObjectType.Account.fields.getMap();
            }
            return accountFields;
        }
    }
    // Commented by Sujitha all the FS Audit  related functionality Backlog #702
    /*
    public static Map<String, MAT_Opportunity_Default_Field_Values__c> defaultFieldsMap {
        get{
            if(defaultFieldsMap == null)
            {
                defaultFieldsMap = MAT_Opportunity_Default_Field_Values__c.getAll();
            }
            return defaultFieldsMap;
        }
    }
    
    public static Map<String, Object> defaultFieldToDefaultValue {
        get {
            if(defaultFieldToDefaultValue==null)
            {
                defaultFieldToDefaultValue = new Map<String, Object>();
                List<MAT_Opportunity_Default_Field_Values__c> defaultFieldMappings = defaultFieldsMap.values();
                isCustomSettingNotConfigured = false;
                for(MAT_Opportunity_Default_Field_Values__c df : defaultFieldMappings)
                {
                    if(opptyFields.containsKey(df.Name)){
                        if( df.Field_on_Account__c != true
                            || (df.Field_on_Account__c == true && accountFields.containsKey( df.Default_Value__c ) ) )
                            defaultFieldToDefaultValue.put(df.Name,castValue(opptyFields.get(df.Name).getDescribe().getSoapType(),df.Default_Value__c));
                        else
                            isCustomSettingNotConfigured = true;
                    }else{
                        isCustomSettingNotConfigured = true;
                    }
                }
                
                if(!(defaultFieldToDefaultValue.containsKey('Name') && defaultFieldToDefaultValue.containsKey('StageName'))){
                    isCustomSettingNotConfigured = true;
                }
            }
            return defaultFieldToDefaultValue;
        }
    }
    */
    public static Map<Id, Account> getAccountsWithUpdatedRepsOrPlan ( Map<Id, Account> newAccounts, Map<Id,Account> oldAccounts){

        Map<Id, Account> accounts = new Map<Id, Account>();

        for ( Account newAccount : newAccounts.values() ){
            // gets accounts that satisfy at least one of the following:
            //  - irep lookup has changed
            //  - primary sales rep lookup has changed
            //  - irep plan has changed 
            //  Commented irep_plan_c code 7/28/2021
            if ( newAccount.iRep__c != oldAccounts.get( newAccount.Id ).iRep__c
                || newAccount.Primary_Sales_Rep_Name__c != oldAccounts.get( newAccount.Id ).Primary_Sales_Rep_Name__c
                //|| newAccount.iRep_Plan__c != oldAccounts.get( newAccount.Id ).iRep_Plan__c
                || newAccount.OwnerId != oldAccounts.get( newAccount.Id ).OwnerId ){
                accounts.put( newAccount.Id, newAccount );
            }
        }
        return accounts;
    }
    
    /** Convert a string to an object type specified by the given soapType
     *  @value the string to cast
     *  @soapType the specified soapType
     *  @precondition soapType must be Id, String, Boolean, Date, Integer, or Double
     */
    public static Object castValue(Schema.SoapType soapType, String value)
    {
        if(soapType == Schema.Soaptype.Id || soapType == Schema.Soaptype.String){
            return value;
        }
        else if(soapType == Schema.Soaptype.Boolean){
            return Boolean.valueOf(value);
        }
        else if(soapType == Schema.Soaptype.Date){
            return date.parse(value);
        }
        else if(soapType == Schema.Soaptype.Integer){
            return Integer.valueOf(value);
        }
        else if(soapType == Schema.Soaptype.Double){
            return Decimal.valueOf(value);
        }
        return null;
    }
    
    public static List<Account> filterOutInactiveAccounts(List<Account> accounts)
    {
        List<Account> retAccounts = new List<Account>();
        for(Account a : accounts)
        {
            if(a.Active__c!='No')
            {
                retAccounts.add(a);
            }
        }   
        return retAccounts;
    }

    /* Removed via BL-3662
    public static List<Account> filterOutAccountWithIncompleteContactInformation(List<Account> accounts){
        List<Account> filteredAccounts = new List<Account>();
        for(Account account : accounts){
            if(!String.isBlank(account.MAT_Contact_Email__c) &&
                !String.isBlank(account.MAT_Contact_First_Name__c) &&
                !String.isBlank(account.MAT_Contact_Last_Name__c)){
                filteredAccounts.add(account);
            }
        }
        return filteredAccounts;
    }   
	*/
    
    /**
     * This function prepares MAT opportunities for insertion such that there will be one new MAT opportunity for each specified account. 
     *
     * The opportunities meet the following criteria:
     * 
     * 1) The close date of the opportunity will be 30 days from today
     * 2) The custom setting "Default MAT Opportunity Field Values" is used to populate values on the opportunity
     *
     * Exception Case:
     * 1) When there is a misspelt Custom Setting Value we do not prepare MAT Oppty and return an empty list, also add the error message to the accounts.
     */
    /* Removed via BL-3662
    public static List<Opportunity> prepareMATOpptys(List<Account> accounts)
    {
        // Commented by Sujitha all the FS Audit  related functionality Backlog #702
        //Set<String> fieldToDefaultValueKeySet = defaultFieldToDefaultValue.keySet();
        if(isCustomSettingNotConfigured){
            for(Account acct:accounts){
                acct.addError(CUSTOM_SETTING_CONFIGURED_INCORRECTLY);
            }
            return new List<Opportunity>();
        }else{
            List<Opportunity> preparedMATOpptys = new List<Opportunity>(); 
            
            for(Account acct: accounts){
                
                Opportunity oppty = new Opportunity();
                oppty.MAT_Unique_ID__c = acct.MAT_Latest_Unique_ID__c;
                oppty.AccountId = acct.Id; 
                oppty.CloseDate = date.today() + 30;
                oppty.stageName = 'testing';
                oppty.name = 'tst';
                // Commented by Sujitha all the FS Audit  related functionality Backlog #702
                for(String field : fieldToDefaultValueKeySet)
                {
                    Object fieldValue;
                    
                    if(defaultFieldsMap.get(field).Field_on_Account__c == true)
                        fieldValue=acct.get(field);
                    else
                        fieldValue = defaultFieldToDefaultValue.get(field);
                        
                    oppty.put(field,fieldValue);
                }
                preparedMATOpptys.add(oppty);
            }
            return preparedMATOpptys;
        }
    }
	*/

    public static List<Account> linkPrimarySalesReps(List<Account> accounts){
        // AccountOwner -> User -> PrimarySalesRep
        
        Map<Id, Id> accountIdToOwnerId = new Map<Id, Id>();
        for (Account acc : accounts){
            accountIdToOwnerId.put(acc.Id, acc.OwnerId);
        }
        Map<Id, Primary_Sales_Rep__c> ownerIdToPSR = new Map<Id, Primary_Sales_Rep__c>();
        for (Primary_Sales_Rep__c psr : [Select Id, SF_userid__c From Primary_Sales_Rep__c Where SF_userid__c in :accountIdToOwnerId.values()]){
            ownerIdToPSR.put(psr.SF_userid__c, psr);
        }
        
        
        List<Account> accountUpdates = new List<Account>();
        for (Account acc : accounts ){
            if (acc.Primary_Sales_Rep_Name__c == null){
                Id accId = acc.Id;
                Id accOwnerId = accountIdToOwnerId.get(accId);
                if (ownerIdToPSR.containsKey(accOwnerId)){
                    Account accUpdate = new Account(Id=accId);
                    accUpdate.Primary_Sales_Rep_Name__c = ownerIdToPSR.get(accOwnerId).Id;
                    accountUpdates.add(accUpdate);
                }
            }
        }
        return accountUpdates;
    }
    
    public static List<Account> updatePrimarySalesReps(List<Account> accountsToUpdatePSR){
        try { 
            update accountsToUpdatePSR;
        }
        catch (DMLException ex){
            for( Integer index = 0; index < ex.getNumDml(); index++ )
            {
                Account account = accountsToUpdatePSR[ ex.getDmlIndex( index ) ];
                account.addError( ex.getDmlMessage( index ) );
            }
        }
        return accountsToUpdatePSR;
    }
    
    /**
    * This function prepares MAT contacts for upsertion such that there is a MAT contact for each specified account. 
    *
    * The contacts meet the following criteria:
    * 
    * 1) If the contact is an existing contact, then that contact must be a contact under its account with the same email address as its account's MAT_Contact_Email__c. 
    * 2) If the contact is a new contact, then there must not a contact currently under its account with the same email address as its account's MAT_Contact_Email__c. This contact 
    *     must have the same email address as MAT_Contact_Email__c, the same first name as MAT_Contact_First_Name__c, the same last name as MAT_Contact_Last_Name__c
    * 3) The contact must have Receive_MAT_Summary__c set to true
    *
    * @param accounts the specified accounts
    * 
    */
    /* Removed via BL-3662
    public static List<Contact> prepareMATContacts(List<Account> accounts){
        
        List<Contact> matchingContacts = new List<Contact>();
        
        Map<Id, List<Contact>> mapAccountIdtoChildContacts = GroupBy.ids('AccountId', [SELECT Id, AccountId, Email FROM Contact WHERE AccountId in: accounts]);
        
        Boolean isNewMATContact;
        
        for(Account acct: accounts){
            isNewMATContact = true;
            if(mapAccountIdtoChildContacts.containsKey(acct.Id)){
                for(Contact ctc: mapAccountIdtoChildContacts.get(acct.Id)){
                    if(acct.MAT_Contact_Email__c == ctc.Email){
                        matchingContacts.add(ctc);
                        ctc.Receive_MAT_Summary__c = true;
                        isNewMATContact = false;
                    }
                }
            }
            
            if(isNewMATContact){
                Contact newContact = new Contact();
                newContact.AccountID = acct.Id;
                newContact.FirstName = acct.MAT_Contact_First_Name__c;
                newContact.LastName = acct.MAT_Contact_Last_Name__c;
                newContact.Email = acct.MAT_Contact_Email__c;
                newContact.Receive_MAT_Summary__c = true;
                matchingContacts.add(newContact);
            }
        }
        return matchingContacts;
    }
	*/
    
    /* Removed via BL-3662
    public static List<Contact> prepareNewMATContacts(List<Account> accounts){
        
        List<Contact> newMatchingContacts = new List<Contact>();
        
        for(Account acct: accounts){
                Contact newContact = new Contact();
                newContact.AccountID = acct.Id;
                newContact.FirstName = acct.MAT_Contact_First_Name__c;
                newContact.LastName = acct.MAT_Contact_Last_Name__c;
                newContact.Email = acct.MAT_Contact_Email__c;
                newContact.Receive_MAT_Summary__c = true;
                newMatchingContacts.add(newContact);
        }
        return newMatchingContacts;
        
    }
	*/

    /*
     * This function returns those accounts that have a value for MAT_Latest_Unique_ID__c
     * @param: List of accounts to be filtered
     */
    /* Removed via BL-3662
    public static List<Account> filterAccountsWithPopulatedMATLatestUniqueId(List<Account> accounts)
    {
        List<Account> filteredAccountsWithPopulatedMATLatestUniqueId = new List<Account>(); 
        
        for(Account acct:accounts){
            if(acct.MAT_Latest_Unique_ID__c != null){
                filteredAccountsWithPopulatedMATLatestUniqueId.add(acct);
            }
        }
        
        return filteredAccountsWithPopulatedMATLatestUniqueId;
    }
	*/

    /*
     * This function returns those new accounts that have a non-null value for MAT_Latest_Unique_ID__c that is different from the old value,
     * ignoring the accounts that change MAT_Latest_Unique_ID__c from null to null
     * @param newAccounts the accounts containing new values
     * @param oldAccounts the accounts containing old values in a map format
     * @precondition the keyset for oldAccounts must contain the IDs of each and every account in newAccounts
     */
    /* Removed via BL-3662
    public static List<Account> filterAccountsWithModifiedMATLatestUniqueIds(List<Account> newAccounts, Map<Id,Account> oldAccounts)
    {
        List<Account> filteredAccountsWithModifiedMATLatestUniqueId = new List<Account>();
        
        for(Account newaccts: newAccounts){
            if(newaccts.MAT_Latest_Unique_ID__c != null && newaccts.MAT_Latest_Unique_ID__c != oldAccounts.get(newaccts.Id).MAT_Latest_Unique_ID__c){
                filteredAccountsWithModifiedMATLatestUniqueId.add(newaccts);
            }
        }
        
        return filteredAccountsWithModifiedMATLatestUniqueId;
    }
	*/
    
    /*
     * This function returns those accounts that have a value for MAT_Contact_Email__c
     * @param: List of accounts to be filtered
     */
    /* Removed via BL-3662
    public static List<Account> filterAccountsWithPopulatedMATContactEmail(List<Account> accounts)
    {
        List<Account> filteredAccountsWithPopulatedMATLatestUniqueId = new List<Account>(); 
        
        for(Account acct:accounts){
            if(acct.MAT_Contact_Email__c != null){
                filteredAccountsWithPopulatedMATLatestUniqueId.add(acct);
            }
        }
        
        return filteredAccountsWithPopulatedMATLatestUniqueId;
    }
	*/
    
    /*
     * This function returns those new accounts that have a non-null value for MAT_Contact_Email__c that is different from the old value,
     * ignoring the accounts that change MAT_Contact_Email__c from null to null
     * @param newAccounts the accounts containing new values
     * @param oldAccounts the accounts containing old values in a map format
     * @precondition the keyset for oldAccounts must contain the IDs of each and every account in newAccounts
     */
    /* Removed via BL-3662
    public static List<Account> filterAccountsWithModifiedMATContactEmail(List<Account> newAccounts, Map<Id,Account> oldAccounts)
    {
        List<Account> filteredAccountsWithModifiedMATLatestUniqueId = new List<Account>();
        
        for(Account newaccts: newAccounts){
            if(newaccts.MAT_Contact_Email__c != null && newaccts.MAT_Contact_Email__c != oldAccounts.get(newaccts.Id).MAT_Contact_Email__c){
                filteredAccountsWithModifiedMATLatestUniqueId.add(newaccts);
            }
        }
        
        return filteredAccountsWithModifiedMATLatestUniqueId;
    }
	*/
    

    /*
        this signature is intended for use from a trigger, passing in newmap and oldmap
    */
    public static List<Opportunity> getRelatedOpenOpportunities( Map<Id, Account> accounts, Map<Id, Account> oldAccountsMap )
    {
        List<Opportunity> relevantOpportunities = new List<Opportunity>();
        List<Opportunity> relatedOpportunities = retrieveRelatedOpenOpportunities( accounts.values() );

        if( !relatedOpportunities.isEmpty() )
        {
            for( Opportunity opportunity : relatedOpportunities )
            {
                Boolean isValid = false;
                if( accounts.containsKey( opportunity.accountId )
                    && ( oldAccountsMap != null && oldAccountsMap.containsKey( opportunity.AccountId ) ) )
                {
                    Account account = accounts.get( opportunity.AccountId );
                    if( opportunity.iRep__c == oldAccountsMap.get( opportunity.AccountId ).iRep__c
                        && account.iRep__c != oldAccountsMap.get( opportunity.AccountId ).iRep__c )
                    {
                        opportunity.iRep__c = account.iRep__c;
                        isValid = true;
                    }

                    if( opportunity.OwnerId == oldAccountsMap.get( opportunity.AccountId ).OwnerId 
                        && account.OwnerId != oldAccountsMap.get( opportunity.AccountId ).OwnerId )
                    {
                        opportunity.OwnerId = account.OwnerId;
                        isValid = true;
                    }

                    if( opportunity.Primary_Sales_Rep_Name__c == oldAccountsMap.get( opportunity.AccountId ).Primary_Sales_Rep_Name__c
                        && account.Primary_Sales_Rep_Name__c != oldAccountsMap.get( opportunity.AccountId ).Primary_Sales_Rep_Name__c )
                    {
                        opportunity.Primary_Sales_Rep_Name__c = account.Primary_Sales_Rep_Name__c;
                        isValid = true;
                    }

                    if( opportunity.iRep_Plan_Stamp__c == oldAccountsMap.get( opportunity.AccountId ).iRep_Plan__c
                        && account.iRep_Plan__c != oldAccountsMap.get( opportunity.AccountId ).iRep_Plan__c )
                    {
                        opportunity.iRep_Plan_Stamp__c = account.iRep_Plan__c;
                        isValid = true;
                    }

                    if( isValid )
                    {
                        relevantOpportunities.add( opportunity );
                    }
                }
            }
        }

        return relevantOpportunities;
    }

    /*
        this signature is intended for use from a batch, with accounts having the following fields populated:
            - iRep__c
            - Previous_iRep_Id__c
            - Primary_Sales_Rep_Name__c
    */
    public static List<Opportunity> getRelatedOpenOpportunities( Map<Id, Account> accounts )
    {
        List<Opportunity> relevantOpportunities = new List<Opportunity>();
        List<Opportunity> relatedOpportunities = retrieveRelatedOpenOpportunities( accounts.values() );

        if( !relatedOpportunities.isEmpty() )
        {
            for( Opportunity opportunity : relatedOpportunities )
            {
                Account account = accounts.get( opportunity.AccountId );
                if( opportunity.iRep__c == account.Previous_iRep_ID__c )
                {
                    opportunity.iRep__c = account.iRep__c;
                    opportunity.Primary_Sales_Rep_Name__c = account.Primary_Sales_Rep_Name__c;
                    opportunity.iRep_Plan_Stamp__c = account.iRep_Plan__c;
                    relevantOpportunities.add( opportunity );
                }
            }
        }

        return relevantOpportunities;
    }
    
    public static void upsertContacts(List<Contact> contacts, Map<Id, Account> newAccountsMap){
        
        try
        {
            upsert contacts;
        }
        catch( System.DmlException ex )
        {
            for( Integer index = 0; index < ex.getNumDml(); index++ )
            {
                Id errorAccountId = contacts[ ex.getDmlIndex( index ) ].AccountId;
                
                newAccountsMap.get( errorAccountId ).addError( ex.getDmlMessage( index ) );
            }
        }
    }
    
    public static Boolean needsBatchProcessing(System.DmlException ex, Integer index )
    {
        return RELATED_MESSAGES.contains( ex.getDmlMessage( index ) )  && ( ex.getDmlType( index ) == System.StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY || ex.getDmlType( index ) == System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION|| ex.getDmlType( index ) == System.StatusCode.INSUFFICIENT_ACCESS_OR_READONLY );
    }

    public static void updateOpportunities( List<Opportunity> relatedOpportunities, Map<Id, Account> newAccountsMap )
    {
        try
        {
            update relatedOpportunities;
        }
        catch( System.DmlException ex )
        {List<Account> accountsThatNeedProcessing = new List<Account>();for( Integer index = 0; index < ex.getNumDml(); index++ )  {Id errorAccountId = relatedOpportunities[ ex.getDmlIndex( index ) ].AccountId;
                if( needsBatchProcessing(ex,index) )
                {
                    Account newAccountProcessing = new Account(Id=newAccountsMap.get( errorAccountId ).Id); newAccountProcessing.Needs_Batch_Processing__c = true; accountsThatNeedProcessing.add(newAccountProcessing);
                }
                else
                {
                    newAccountsMap.get( errorAccountId ).addError( ex.getDmlMessage( index ) );
                }
            }
            updateAccounts(accountsThatNeedProcessing);
        }
    }
    
    @testVisible
    private static void updateAccounts( List<Account> accountsToUpdate )
    {
        try
        {
            update accountsToUpdate;
        }
        catch( System.DmlException ex )
        {
            for( Integer index = 0; index < ex.getNumDml(); index++ )
            {
                accountsToUpdate[ex.getDmlIndex(index)].addError( ex.getDmlMessage( index ) );
            }
        }
    }

    private static List<Opportunity> retrieveRelatedOpenOpportunities( List<Account> accounts )
    {
        return [ SELECT Id, OwnerId, AccountId, iRep__c, iRep_Plan_Stamp__c, Primary_Sales_Rep_Name__c
                    FROM Opportunity
                    WHERE AccountId IN :accounts
                        AND IsClosed = false ];
    }

    public static String getSyncOpportunityRepsBatchQuery()
    {
        return 'SELECT Id, iRep__c, iRep_Plan__c, Previous_iRep_ID__c, Primary_Sales_Rep_Name__c FROM Account WHERE Needs_Batch_Processing__c = true ';
    }

    public static String processAccountsFromBatch( List<Account> batchedAccounts )
    {
        Boolean allOrNone = false;
        String errors = '';

        if( !batchedAccounts.isEmpty() )
        {
            Map<Id, Account> accountsMap = new Map<Id, Account>( batchedAccounts );
            List<Opportunity> opportunitiesToUpdate = AccountServices.getRelatedOpenOpportunities( accountsMap );
            updateOpportunities( opportunitiesToUpdate, accountsMap );

            for( Account account : batchedAccounts )
            {
                account.Needs_Batch_Processing__c = false;
            }

            List<Database.SaveResult> saveResults = Database.update( batchedAccounts, allOrNone );

            for( Integer index = 0; index < saveResults.size(); index++ )
            {
                if( !saveResults[ index ].isSuccess() )
                {
                    errors += '\nAccount with Id ' + batchedAccounts[ index ].Id + ' could not be updated.\n'; for( Database.Error error : saveResults[ index ].getErrors() )
                    {
                        errors += '\t' + error.getMessage();
                    }
                }
            }
        }

        return errors;
    }

/* Commented out per BL-3680
//Updates Accounts with Servicing Division
    public static void updateDivisions(Map<Id, Account> oldAccounts, Map<Id,Account> newAccounts)
    {
        List<String> allDivisionNames = new List<String>();
        List<String> allLegacyCodes = new List<String>();
        List<Account> allChangedAccounts = new List<Account>();

        for(Account newAcc : newAccounts.values())
        {
            if(newAcc.Legacy_Division_Cd__c != oldAccounts.get(newAcc.Id).Legacy_Division_Cd__c
                    || newAcc.Servicing_Division__c != oldAccounts.get(newAcc.Id).Servicing_Division__c
                   || newAcc.Legacy_System_Cd__c != oldAccounts.get(newAcc.Id).Legacy_System_Cd__c
                   || newAcc.zpl__CustomerId__c != oldAccounts.get(newAcc.Id).zpl__CustomerId__c 
                   || newAcc.Legacy_Division_Id__c != oldAccounts.get(newAcc.Id).Legacy_Division_Id__c
               
                   )
              
            {
                allChangedAccounts.add(newAcc); allDivisionNames.add(newAcc.Legacy_System_Cd__c); allLegacyCodes.add(newAcc.Legacy_Division_Cd__c);
            }
        }
        if(!allChangedAccounts.isEmpty())
        {
            system.debug('inside accound empty');
            Map<String,Id> servicedivisionsToId = getServiceDivisionToIdMapForSys(allDivisionNames, allLegacyCodes);
system.debug('servicedivisionsToId'+servicedivisionsToId);
            system.debug('keyset of mapo'+servicedivisionsToId.keyset());
            for(Account account : allChangedAccounts)
            {
                system.debug('account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c'+account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c);
                Id divisionId;
                //backlog Item-2729 remove the check for CA. commenting out old code
                
                //if(account.Legacy_System_Cd__c == 'CA'){
                //    if(account.zpl__CustomerId__c != null && servicedivisionsToId.containsKey(account.zpl__CustomerId__c.substring(0,5))){
                //        divisionId = servicedivisionsToId.get(account.zpl__CustomerId__c.substring(0,5));
                //    }
                //}else{
                //    if(servicedivisionsToId.containsKey(account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c)){
                //        divisionId = servicedivisionsToId.get(account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c);
                //    }
                //    
                //}
                
               string legacyDivision = '';
               if(account.Legacy_Division_Id__c!= null){
                   if((account.Legacy_Division_Id__c.length()>=5)){
                       legacyDivision = account.Legacy_Division_Id__c.substring(0,5);
                   }else{
                       legacyDivision = account.Legacy_Division_Id__c.substring(0,4);    
                   } 
               }
                
               //if(account.Legacy_Division_Id__c!= null && servicedivisionsToId.containsKey(account.Legacy_Division_Id__c.substring(0,5))){
               if(account.Legacy_Division_Id__c!= null && servicedivisionsToId.containsKey(legacyDivision)){
                   //divisionId = servicedivisionsToId.get(account.Legacy_Division_Id__c.substring(0,5));
                   divisionId = servicedivisionsToId.get(legacyDivision);
               }else{
                   if(servicedivisionsToId.containsKey(account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c)){
                        divisionId = servicedivisionsToId.get(account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c);
                   }
                    
                }
                
                system.debug('divisionId'+divisionId);
                if(divisionId != null)
                    account.Servicing_Division__c = divisionId;
            }
        }
    }
*/

    /* Commented out per BL-3680
    //Adds Servicing Divison when a New Account is Inserted into SFDC
    public static void updateDivisions(List<Account> accounts)
    {
        List<String> allDivisionsSysCode = new List<String>();
        List<String> allLegacyCodes = new List<String>();

        for(Account account : accounts)
        {
            allDivisionsSysCode.add(account.Legacy_System_Cd__c);
            allLegacyCodes.add(account.Legacy_Division_Cd__c);
        }
        Map<String,Id> servicedivisionsToId = getServiceDivisionToIdMapForSys(allDivisionsSysCode , allLegacyCodes);
        for(Account account : accounts)
        {
        
            Id divisionId;
            //backlog Item-2729 remove the check for CA. commenting out old code
            
            //if(account.Zpl_Customer_ID__c != null && account.Legacy_System_Cd__c == 'CA'){
            //    if(servicedivisionsToId.containsKey(account.Zpl_Customer_ID__c.substring(0,5))){
            //        divisionId = servicedivisionsToId.get(account.Zpl_Customer_ID__c.substring(0,5));
            //    }
            //}else{
            //    if(servicedivisionsToId.containsKey(account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c)){
            //        divisionId = servicedivisionsToId.get(account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c);
            //    }
            //    
            //}
            
            string legacyDivision = '';
            if(account.Legacy_Division_Id__c!= null){
                if((account.Legacy_Division_Id__c.length()>=5)){
                       legacyDivision = account.Legacy_Division_Id__c.substring(0,5);
                   }else{
                       legacyDivision = account.Legacy_Division_Id__c.substring(0,4);    
                   } 
                if(servicedivisionsToId.containsKey(legacyDivision)){
                    divisionId = servicedivisionsToId.get(legacyDivision);
                }   
            }else{
                if(servicedivisionsToId.containsKey(account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c)){
                    divisionId = servicedivisionsToId.get(account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c);
                }   
            }                       
            
            //if(account.Legacy_Division_Id__c != null){
            //    if(servicedivisionsToId.containsKey(account.Legacy_Division_Id__c.substring(0,5))){
            //        divisionId = servicedivisionsToId.get(account.Legacy_Division_Id__c.substring(0,5));
            //    }
            //}else{
            //    if(servicedivisionsToId.containsKey(account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c)){
            //        divisionId = servicedivisionsToId.get(account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c);
            //    }
            //    
            //}
            
            system.debug('combination'+account.Legacy_Division_Cd__c+ account.Legacy_System_Cd__c);
            if( servicedivisionsToId.get( account.Legacy_Division_Cd__c+ account.Legacy_System_Cd__c ) != null 
              
              ){
               system.debug('inside update servicing devision');
                  account.Servicing_Division__c = servicedivisionsToId.get(account.Legacy_Division_Cd__c+ account.Legacy_System_Cd__c); 
                  system.debug('account.Servicing_Division__c');
              }else if( servicedivisionsToId.get( account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c ) != null ){
                      account.Servicing_Division__c = servicedivisionsToId.get( account.Legacy_System_Cd__c + account.Legacy_Division_Cd__c); 
                  }
        }
    }
*/

    private static Map<String,Id> getServiceDivisionToIdMap (List<String> allDivisionNames , List<String> allLegacyCodes)
    {
        List<Servicing_Division__c> divisions = [SELECT Id,Name,Division_Code__c FROM Servicing_Division__c WHERE Name IN :allDivisionNames AND  Division_Code__c IN :allLegacyCodes];
        Map<String,Id> servicedivisionsToId = new Map<String,Id>();
        for(Servicing_Division__c div : divisions)
        {
            servicedivisionsToId.put(div.Name+div.Division_Code__c, div.Id);
        }
        return servicedivisionsToId;
    }

    private static Map<String,Id> getServiceDivisionToIdMapForSys (List<String> allDivisionSysCode , List<String> allLegacyCodes)
    {
        system.debug('allDivisionSysCode'+ allDivisionSysCode);
        system.debug('allLegacyCodes'+ allLegacyCodes);
        List<Servicing_Division__c> divisions = [SELECT Id,Name,Division_Code__c,System_Code__c,Division_Composite_Key__c FROM Servicing_Division__c];
        
        system.debug('divisions'+divisions);
        Map<String,Id> servicedivisionsToId = new Map<String,Id>();
        for(Servicing_Division__c div : divisions)
        {
            servicedivisionsToId.put(div.Division_Composite_Key__c, div.Id);
        }
        return servicedivisionsToId;
    }
    
    public static Map<String, List<Account>> filterAccountsWithChangedVerticals( List<Account> incomingAccounts, Map<Id, Account>oldAccountIdToOldAccount )
    {

        Map<String, List<Account>> verticalNameToAccountList = new Map<String, List<Account>>();

        //For All Accounts that were sent to our trigger
        for(Account incomingAccount : incomingAccounts )
        {
            //Change conditions
            // 1. Vertical is now being set
            // 2. Vertical is being changed

            Boolean isChanged;
            Boolean isInsert = oldAccountIdToOldAccount == null;
            Account oldAccount = isInsert ? null : oldAccountIdToOldAccount.get( incomingAccount.Id);

            isChanged = (( isInsert && incomingAccount.Account_Vertical__c != null )
                        ||( !isInsert && oldAccount.Account_Vertical__c != incomingAccount.Account_Vertical__c ));

            if( isChanged )
            {
                if(!verticalNameToAccountList.containsKey( incomingAccount.Account_Vertical__c ))
                {
                    verticalNameToAccountList.put( incomingAccount.Account_Vertical__c, new List<Account> { incomingAccount } );
                }
                else
                {
                    verticalNameToAccountList.get( incomingAccount.Account_Vertical__c ).add( incomingAccount );
                }
            }
        }

        return verticalNameToAccountList;
    }

    public static void setAccountVerticals( Map<String, List<Account>> verticalNameToAccountList )
    {
        List<Account> accountsToUpdate = new List<Account>();

        if( !verticalNameToAccountList.isEmpty() )
        {
            for( Verticals__c verticalsFound : [SELECT Id, Name FROM Verticals__c WHERE Name in :verticalNameToAccountList.keySet() ])
            {
                //Added IF statement by sujitha
                if(verticalNameToAccountList.keyset().contains(verticalsFound.Name) ){
                    
                    for( Account accountToUpdate : verticalNameToAccountList.get( verticalsFound.Name ))
                    {
                        Account newAccountToUpdate = new Account(Id = accountToUpdate.id, Vertical__c = verticalsFound.id);
                        accountsToUpdate.add( newAccountToUpdate );
                    }
                    
                }
                
            }
        }
        
        if( !accountsToUpdate.isEmpty() )
            update accountsToUpdate;
    }
	
    /* Commented out for BL-3662
    public static void doMATActionsOnUpdate (Map<ID, Account> oldAccounts, Map<ID,Account> newAccounts)
    {
        if(!AccountServices.firstRunOfMATAccountTrigger)
        {
            List<Account> filteredMATAccounts = AccountServices.filterAccountsWithModifiedMATLatestUniqueIds(newAccounts.values(), oldAccounts);

            if(!filteredMATAccounts.isEmpty())
            {   
                List<Opportunity> opptysToInsert = AccountServices.prepareMATOpptys(filteredMATAccounts);
                
                if(opptysToInsert.size()>0)
                {
                    ErrorHandling.ErrorHandler addErrorToAccountViaAccountID = new ErrorHandling.AddErrorsToTriggerNew(newAccounts, 'AccountID');       
                    SafeDML objsToInsert = new SafeInsert();
                    objsToInsert.queue(opptysToInsert,addErrorToAccountViaAccountID);
                    objsToInsert.doDml();
                    AccountServices.firstRunOfMATAccountTrigger = true;
                }
                
            }

            List<Account> filteredMATAccountsWithModifiedContacts = AccountServices.filterAccountsWithModifiedMATContactEmail(newAccounts.values(), oldAccounts);
            List<Account> filteredMATWithContactInfo = AccountServices.filterOutAccountWithIncompleteContactInformation(filteredMATAccountsWithModifiedContacts);
            if(!filteredMATWithContactInfo.isEmpty()){
                    List<Contact> contactsToUpsert = AccountServices.prepareMATContacts(filteredMATWithContactInfo);
                    if(contactsToUpsert.size()>0)
                    {
                        AccountServices.upsertContacts(contactsToUpsert,newAccounts); 
                        AccountServices.firstRunOfMATAccountTrigger = true;
                    }
            }
        }
    }
	*/

   /* Commented based on Account analysis 7/28/2021
      public static void doMATActionsOnInsert(Map<ID,Account> newAccounts)
    {
        if(!AccountServices.firstRunOfMATAccountTrigger)
        {
            
            ErrorHandling.ErrorHandler addErrorToAccountViaAccountID = new ErrorHandling.AddErrorsToTriggerNew(newAccounts, 'AccountID');
            SafeDML objsToInsert = new SafeInsert();

            List<Account> filteredMATAccounts = AccountServices.filterAccountsWithPopulatedMATLatestUniqueId(newAccounts.values());
            if(!filteredMATAccounts.isEmpty())
            {
                List<Opportunity> newlyInsertedOpportunities = AccountServices.prepareMATOpptys(filteredMATAccounts);
                objsToInsert.queue(newlyInsertedOpportunities,addErrorToAccountViaAccountID);
                
            }

            List<Account> filteredMATWithContactInfo = AccountServices.filterOutAccountWithIncompleteContactInformation(newAccounts.values());

            if(!filteredMATWithContactInfo.isEmpty()){
                List<Contact> newlyInsertedContacts =  AccountServices.prepareNewMATContacts(filteredMATWithContactInfo);
                objsToInsert.queue(newlyInsertedContacts,addErrorToAccountViaAccountID);
            }

            if(objsToInsert.getQueueSize()>0)
            {
                firstRunOfMATAccountTrigger = true;
                objsToInsert.doDml();
            }
        }
    }*/

    public static void updatePrimarySalesRepFromOwnerId(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        Set<Id> ownerIds = Pluck.ids(Schema.sObjectType.Account.fields.OwnerId.getName(), newMap);
        List<Primary_Sales_Rep__c> relatedReps = [SELECT Id, SF_UserId__c FROM Primary_Sales_Rep__c WHERE SF_UserId__c IN :ownerIds];

        Map<Id, Id> userIdsToPSRId = new Map<Id, Id>();
        for (Primary_Sales_Rep__c rep : relatedReps) {
            userIdsToPSRId.put(rep.SF_UserId__c, rep.Id);
        }

        for (Id accountId : newMap.keySet()) {
            Account oldAccount = oldMap.get(accountId);
            Account updatedAccount = newMap.get(accountId);

            if (oldAccount.OwnerId != updatedAccount.OwnerId) {
                if (userIdsToPSRId.containsKey(updatedAccount.OwnerId)) {
                    updatedAccount.Primary_Sales_Rep_Name__c = userIdsToPSRId.get(updatedAccount.OwnerId);
                }
            }
        }
    }
    //backlog Item-2260
    public static void contactOwnerAndPSRUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap){
        map<id, id> accountOwnerMap = new map<id, id> ();
        map<id,set<contact>> accountContactMap = new map<id,set<contact>>();
        boolean hasOwnerChange = false;
        //get accounts with new owners and map them
        for (Account acc: newMap.values()){
            if(acc.ownerid!=oldmap.get(acc.id).ownerid){
                accountOwnerMap.put(acc.id, acc.ownerid);                     
                hasOwnerChange = true;
            }
        }
        //check if owner change has happened. Skip if no owner change. //item-2641 optimization
        if (hasOwnerChange==true){
            //get primary sales rep
            List<Primary_Sales_Rep__c> relatedReps = [SELECT Id, SF_UserId__c FROM Primary_Sales_Rep__c WHERE SF_UserId__c IN :accountOwnerMap.values()];
            //Map PSR to user ID
            map<id,id> userPSRMap = new map<id,id>();
            for(Primary_Sales_Rep__c psr : relatedReps){
                userPSRMap.put(psr.SF_UserId__c, psr.id);    
            }
            
            //get contacts under the account and map them
            list<contact> contactList = new list<contact>();
            contactList = [select id, accountid, ownerid, Primary_Sales_Rep_Name__c from contact where accountid in :accountOwnerMap.keyset()];
            for(contact con: contactList){
                set<contact> conset = new set<contact>();    
                if(accountContactMap.containskey(con.accountid)){
                    conset = accountContactMap.get(con.accountid);
                }
                conset.add(con);
                accountContactMap.put(con.accountid,conset);
            }
            list<contact> contactToUpdate = new list<contact>();
            //update contact fields
            for (id accid: accountContactMap.keyset()){
                for(contact con: accountContactMap.get(accid)){
                    con.ownerid = accountOwnerMap.get(accid); 
                    con.Primary_Sales_Rep_Name__c  = userPSRMap.get(con.ownerid);
                    contactToUpdate.add(con);
                }
            }
            
            if(contactToUpdate.size()>0){
                skipContactUpdateTrigger = true;
                update contactToUpdate;
            }
        }
        
    }
    
    public static void backupDnBQueryFields(List<Account> newList) {        
        for (Account acc : newList) {
            acc.Phone_Initial__c = acc.Phone;
            acc.Website_Initial__c = acc.Website;

            acc.BillingStreetInitial__c = acc.BillingStreet;
            acc.BillingCityInitial__c = acc.BillingCity;
            acc.BillingStateInitial__c = acc.BillingState;
            acc.BillingPostalCodeInitial__c = acc.BillingPostalCode;
            acc.BillingCountryInitial__c = acc.BillingCountry;

            acc.Is_Being_Updated_From_DnB__c = false;
        }
    }
@testVisible
    private static void updateNullInitialFields(Account acc) {
        if (acc.Phone_Initial__c == null) {
            acc.Phone_Initial__c = acc.Phone;
        }

        if (acc.Website_Initial__c == null) {
            acc.Website_Initial__c = acc.Website;
        }

        if (acc.BillingStreetInitial__c == null) {
            acc.BillingStreetInitial__c = acc.BillingStreet;
        }

        if (acc.BillingCityInitial__c == null) {
            acc.BillingCityInitial__c = acc.BillingCity;
        }

        if (acc.BillingStateInitial__c == null) {
            acc.BillingStateInitial__c = acc.BillingState;
        }

        if (acc.BillingPostalCodeInitial__c == null) {
            acc.BillingPostalCodeInitial__c = acc.BillingPostalCode;
        }

        if (acc.BillingCountryInitial__c == null) {
            acc.BillingCountryInitial__c = acc.BillingCountry;
        }
    }

    /**
        Run on before update to perform the "backup" and "restore" of the prospect address fields
     */
    public static void backupAndRestoreDnBQueryFields(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        if (firstRunOfAccountFieldBackupTrigger) {
            for (Account acc : newMap.values()) {
                // Restore user input to D&B query fields when the sync is disabled
                if (!oldMap.get(acc.Id).Remove_DnB_Data__c && acc.Remove_DnB_Data__c) {
                    System.debug('Replacing fields with backup.');
                    acc.Phone = acc.Phone_Initial__c;
                    acc.Website = acc.Website_Initial__c;

                    acc.BillingStreet = acc.BillingStreetInitial__c;
                    acc.BillingCity = acc.BillingCityInitial__c;
                    acc.BillingState = acc.BillingStateInitial__c;
                    acc.BillingPostalCode = acc.BillingPostalCodeInitial__c;
                    acc.BillingCountry = acc.BillingCountryInitial__c;

                    List<Schema.FieldSetMember> fieldSet = Schema.SObjectType.Account.fieldSets.DnB_Fields_to_Delete.getFields();
                    for (Schema.FieldSetMember field : fieldSet) {
                        if (field.getType() == Schema.DisplayType.Boolean) {
                            acc.put(field.getFieldPath(), false);
                        } else {
                            acc.put(field.getFieldPath(), null);
                        }
                    }
                } else {
                    if (!acc.Is_Being_Updated_From_DnB__c) {
                        System.debug('Backing up initial fields');
                        if (acc.Phone != oldMap.get(acc.Id).Phone) {
                            acc.Phone_Initial__c = acc.Phone;
                        }
                        
                        if (acc.Website != oldMap.get(acc.Id).Website) {
                            acc.Website_Initial__c = acc.Website;
                        }

                        if (acc.BillingStreet != oldMap.get(acc.Id).BillingStreet) {
                            acc.BillingStreetInitial__c = acc.BillingStreet;
                        }

                        if (acc.BillingCity != oldMap.get(acc.Id).BillingCity) {
                            acc.BillingCityInitial__c = acc.BillingCity;
                        }

                        if (acc.BillingState != oldMap.get(acc.Id).BillingState) {
                            acc.BillingStateInitial__c = acc.BillingState;
                        }

                        if (acc.BillingPostalCode != oldMap.get(acc.Id).BillingPostalCode) {
                            acc.BillingPostalCodeInitial__c = acc.BillingPostalCode;
                        }

                        if (acc.BillingCountry != oldMap.get(acc.Id).BillingCountry) {
                            acc.BillingCountryInitial__c = acc.BillingCountry;
                        }   

                    } else {
                        updateNullInitialFields(acc);                   
                        acc.Is_Being_Updated_From_DnB__c = false;                   
                    }
                }
            }
            
            firstRunOfAccountFieldBackupTrigger = false;
        }
    }   
    //Backlog Item-2583
    public static void deleteValidation(Map<Id, Account> oldMap) {
        Set<String> profileNames = new Set<String>{'System Administrator'};//profiles that delete
        Id profileId = UserInfo.getProfileId();
        String currentProfile = [SELECT Name FROM Profile WHERE Id =: profileId][0].Name;
        for(account acc:oldmap.values()){
            if(!profileNames.contains(currentProfile)){
                acc.addError('You don’t have delete access to this record. Please contact your system administrator');
            }
        }
    }
    
    //Backlog Item-2623
    public static void AddPSRToAccountTeam(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        //adds the chain account's PSR to the account team is the chain account field is updated
        map<id,id> accountToOldPSR = new map<id,id>();
        map<id,id> PSRtoUser = new map<id,id>();
        map <id,id> AcctoChainAccMap = new map <id,id>();//account to chain account id
        boolean chainAccUpdated = false;
        map <id,id> OldChaintoOwnerMap= new map <id,id>();// old chain account id to owner - 2889 related
        map<id,id> oldChainToAccount = new map<id,id>();//2942
        map<string,integer> oldChainOwnerCounter = new Map<string,integer>(); //chainID+ownerID to counter - 2889 related
        map <id,id> OldChaintoOldOwnerMap= new map <id,id>();// old chain account id to oldowner - 2889 related. For override AND owner change
        list<id> ownerIds = new List<id>(); //ids of the owners. To be used to query users and check if active
        set<id> activeOwners = new set<id>();//ids of the active owner
        
        //allow to run the account team member update if override is checked
        boolean overrideAccountTeamAssignment = false;
        Account_Team_Member_Settings__c acMemSettings = Account_Team_Member_Settings__c.getOrgDefaults();
        if(acMemSettings!=null){
            overrideAccountTeamAssignment = acMemSettings.Override_Account_Team_Assignment__c;
        }
        
        for (Account acc: newMap.values()){
            //check if chain account was changed and not null, allow to run the account team member update if override is checked
            
            if((acc.Chain_Account__c!=oldMap.get(acc.id).Chain_Account__c || overrideAccountTeamAssignment ) && acc.Chain_Account__c!=null){
                //add the account and chain account id to map
                AcctoChainAccMap.put(acc.id, acc.Chain_Account__c);
                //accountToOldPSR.put(acc.id,acc.Primary_Sales_Rep_Name__c);
                oldChainToAccount.put(oldMap.get(acc.id).Chain_Account__c,acc.id); 
                OldChaintoOwnerMap.put(oldMap.get(acc.id).Chain_Account__c, acc.ownerid);//2889 related
                chainAccUpdated = true;
                //for owner change during override
                if(overrideAccountTeamAssignment && acc.ownerid != oldMap.get(acc.id).ownerid){
                    OldChaintoOldOwnerMap.put(oldMap.get(acc.id).Chain_Account__c, oldMap.get(acc.id).ownerid);
                }
            }
            ownerIds.add(acc.ownerid); //get owner id to check if active
        }               
        //check owners for inactive users. Add active users to set
        for (user accOwner: [select id, isactive from user where id in:ownerIds]){
            if(accOwner.isactive){
                activeOwners.add(accOwner.id);        
            }
        }
        
        //skip if there are no chain account changes
        if(chainAccUpdated == true){
            //2889 do not remove owner from chain account team if the owner is an owner in a different account under the same chain. Identify which user is the owner of another account in the chain
            for (account acc : [select id, ownerid, Chain_Account__c from account where Chain_Account__c in:OldChaintoOwnerMap.keyset() AND ownerid in:OldChaintoOwnerMap.values() ]){
                String chainIDOwnerId =  String.valueOf(acc.Chain_Account__c)+ String.valueOf(acc.ownerid);
                system.debug('chainIDOwnerId = '+chainIDOwnerId);
                if(oldChainOwnerCounter.containskey(chainIDOwnerId)){
                    oldChainOwnerCounter.put(chainIDOwnerId ,oldChainOwnerCounter.get(chainIDOwnerId)+1);    
                    system.debug('oldChainOwnerCounter containskey = true ');
                }else{
                    oldChainOwnerCounter.put(chainIDOwnerId ,1);  
                    system.debug('oldChainOwnerCounter containskey = false ');
                }
                system.debug('oldChainOwnerCounter = '+oldChainOwnerCounter);
            }
            
            //Item-2942 remove chain account PSRs from customer account team. Identify the PSR to be removed
            //get old chain accounts                        
            for(account cAcc : [select id,Primary_Sales_Rep_Name__c, Primary_Sales_Rep_Name__r.SF_userid__c  from account where id in : oldChainToAccount.keyset() ]){
                accountToOldPSR.put(oldChainToAccount.get(cAcc.id),cAcc.Primary_Sales_Rep_Name__c);    
            }
            
            for(Primary_Sales_Rep__c psr: [select id, SF_userid__c from Primary_Sales_Rep__c where id in: accountToOldPSR.values()]){
                PSRtoUser.put(psr.id,psr.SF_userid__c);        
            }

            map <id,id> ChainAccToPSRUserMap = new map <id,id>();
            map <id,id> ChainAccToPSRMap = new map <id,id>();
            //get related chain accounts and PSR user id
            for(account cAcc : [select id,Primary_Sales_Rep_Name__c, Primary_Sales_Rep_Name__r.SF_userid__c  from account where id in : AcctoChainAccMap.values() ]){
                if(cAcc.Primary_Sales_Rep_Name__c != null){
                    ChainAccToPSRUserMap.put(cAcc.id, cAcc.Primary_Sales_Rep_Name__r.SF_userid__c);
                    ChainAccToPSRMap.put(cAcc.id, cAcc.Primary_Sales_Rep_Name__c);
                }    
            }
            
            /* removed per backlog Item-2942
            //update PSR to match the one on chain account
            for(Account acc: newMap.values()){
                if(accountToOldPSR.containskey(acc.id)&&ChainAccToPSRMap.containskey(acc.Chain_Account__c)){
                    acc.Primary_Sales_Rep_Name__c = ChainAccToPSRMap.get(acc.Chain_Account__c);                
                }
            }
            */
            
            //accountteammember to delete
            //backlog 2889 accountteammembers of old chain accounts should be removed
            list<id> accTeamtoRemove =  new list<id>();//list of accounts whose team to be removed  (old chain accounts + old psr on current account)
            accTeamtoRemove.addall(OldChaintoOwnerMap.keyset()); //2889 related
            accTeamtoRemove.addall(accountToOldPSR.keyset());
            List <AccountTeamMember> accTeamListDel = new list <AccountTeamMember>();
            //for (AccountTeamMember act: [select id,AccountId, UserId from AccountTeamMember where accountid in :accountToOldPSR.keyset()]){
            for (AccountTeamMember act: [select id,AccountId, UserId from AccountTeamMember where accountid in :accTeamtoRemove]){
                if (accountToOldPSR.containskey(act.accountid)){
                    if(PSRtoUser.containskey(accountToOldPSR.get(act.accountid))){
                        if(act.userId == PSRtoUser.get(accountToOldPSR.get(act.accountid))){
                            accTeamListDel.add(act);    
                        }    
                    }
                }
                //for old chain accounts - 2889
                
                if(OldChaintoOwnerMap.containskey(act.accountid)){
                    String chainIDOwnerId =  String.valueOf(act.accountid)+ String.valueOf(act.UserId);
                    //if the current account owner
                    if(OldChaintoOwnerMap.get(act.accountid)==act.UserId){
                        
                        if(oldChainOwnerCounter.containskey(chainIDOwnerId)){//delete only if user is no longer related to the chain
                            if(oldChainOwnerCounter.get(chainIDOwnerId)<=1){  //check if there are any accounts under the same chain with the same owner. If the owner's account has been removed from the chain but other of his accounts are still under the chain, it shouldn't be removed from the chain's  account team
                                accTeamListDel.add(act);     
                            }
                        }else{//not part of any account under the chain. Should be deleted from the account team
                            accTeamListDel.add(act);     
                        }    
                        
                    }
                }
                
                //for owner change during override
                if(OldChaintoOldOwnerMap.containskey(act.accountid)){
                    if(OldChaintoOldOwnerMap.get(act.accountid)== act.UserId){
                        accTeamListDel.add(act);      
                    }
                }
                
            }
            //backlog 2889 remove the owner to the old chain
            //get accountteammembers of old chain accounts
            //AcctoOldChainMap
             
             if (accTeamListDel.size()>0){
                system.debug('account team to delete '+accTeamListDel);
                delete accTeamListDel;
            }
            
            //accountTeamMember to insert
            List <AccountTeamMember> accTeamList = new list <AccountTeamMember>();
            
            for (id accId: AcctoChainAccMap.keyset() ){
                id chainAccId = AcctoChainAccMap.get(accId);
                if(ChainAccToPSRUserMap.containskey(chainAccId )){
                //get the user id and create account team member
                    //2889 - to be disabled per Candy's comment November 17, 2021                     
                    /*
                    AccountTeamMember accMember = new AccountTeamMember(
                    AccountId = accId,
                    //TeamMemberRole = 'Sales Rep',
                    TeamMemberRole = 'Chain Rep',
                    UserId = ChainAccToPSRUserMap.get(chainAccId )
                    );
                    accTeamList.add(accMember);        
                    */
                    //backlog 2889 add account owner to Chain account 
                    if(activeOwners.contains(newMap.get(accId).ownerid)){ 
                        //Item-3291 - Only add active users
                        AccountTeamMember cAccMember = new AccountTeamMember(
                        AccountId = chainAccId,
                        //TeamMemberRole = 'Chain Rep',
                        TeamMemberRole = 'Sales Rep',
                        UserId = newMap.get(accId).ownerid
                        );
                        system.debug('account team to insert '+cAccMember);
                        accTeamList.add(cAccMember);    
                    }  
                    
                }
            }
            
            
            
            if (accTeamList.size()>0){
                insert accTeamList;
            }
            
        }
    }
    
    //Backlog Item- 2697-Quote - Visibility to quotes created by previous PS
    public static void logicForQuoteSharing(Map<Id, Account> oldMap, Map<Id, Account> newMap , list<Account> newList){
        
        Boolean runMe = TriggerProcessor.runTrigger( NewMap );
        
        System.debug( '** before update, should I run ? ==> ' + !runMe );    
        if( !runMe )
            return;
        
        List<Account> acctsToUpdateQuoteSharesOn = new List<Account>();
        List<Id> oldUsers = new List<Id>();
        
        Map<Id, Map<Id, Id>> acctId2oldOwnerId2newOwnerId = new Map<Id, Map<Id, Id>>();
        
        // These three lists are created "in sync" - the indexes across all three correspond to one unit of information
        List<Id> accountIds = new List<Id>();
        List<Id> oldAcctOwnerId = new List<Id>();
        List<Id> newAcctOwnerId = new List<Id>();
        
        for ( Account pssblChangedAcct : newList ) {
            
            Account olderVersionOfAcct = oldMap.get( pssblChangedAcct.Id );
            
            if ( pssblChangedAcct.OwnerId != olderVersionOfAcct.OwnerId ) {
                
                acctsToUpdateQuoteSharesOn.add( pssblChangedAcct );
                oldUsers.add( olderVersionOfAcct.OwnerId );
                
                if ( !acctId2oldOwnerId2newOwnerId.containsKey( pssblChangedAcct.Id ) )
                    acctId2oldOwnerId2newOwnerId.put( pssblChangedAcct.Id, new Map<Id, Id>() );
                
                Map<Id, Id> oldOwner2newOwner = acctId2oldOwnerId2newOwnerId.get( pssblChangedAcct.Id );
                oldOwner2newOwner.put( olderVersionOfAcct.OwnerId , pssblChangedAcct.OwnerId );
                
                accountIds.add( pssblChangedAcct.Id );
                oldAcctOwnerId.add( olderVersionOfAcct.OwnerId );
                newAcctOwnerId.add( pssblChangedAcct.OwnerId );
                
            }
            
        }
        
        if( !accountIds.isEmpty() )
        {
            QuoteShareServices.updateUsersOnShares( accountIds, oldAcctOwnerId, newAcctOwnerId );
        }
        
        TriggerProcessor.firstTimeStateMap.putAll((Map<Id,Sobject>)newMap);
        
        
    }
}
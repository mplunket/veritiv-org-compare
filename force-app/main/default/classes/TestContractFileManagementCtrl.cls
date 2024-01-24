@isTest

private class TestContractFileManagementCtrl 
{
    static Account testAccount;
    static Servicing_Division__c  testServicingDivision;
    static Servicing_Division__c anotherServicingDivision;
    static Opportunity testOpportunity;
    static Opportunity anotherOpportunity;
    static Contract existingContractForAccount;
    static Contract existingContractForOpportunity;
    static List<Contract> allExistingContracts;
    static Attachment testAttachmentForContractForAccount;
    static Attachment testAttachmentForContractForOpportunity; 
    static Integer numDocTypes;
    /*Variables for setup for testing required doc types for oppty*/
    static FAP_Specification__c firstCheckBoxChecked;
    static FAP_Specification__c secondCheckBoxChecked;
    static FAP_Specification__c noCheckBoxesChecked;
    static FAP_Specification__c allCheckBoxesChecked;
    static List<String> checkboxFieldsInOpportunity;
    
    static final String STAGE_1 = '1- Prospect';
    static final String STAGE_3 = '3- Project Identified';
    static final String STAGE_5 = '5- Proposal';
    static final String STAGE_7 = '7- Verbal Commitment';
    
    static Integer prefixCounter=0;
    
    static void setUpAccountAndOpportunity()
    {
        testServicingDivision = TestingUtils.createServicingDivision(false);
        anotherServicingDivision = TestingUtils.createServicingDivision(false);
        insert new List<Servicing_Division__c> {testServicingDivision,anotherServicingDivision};
        
        testAccount = TestingUtils.createAccount( 'TestAccount', false );
        testAccount.Is_ULS_Primary_Acct__c =true;
        insert testAccount;
        
        List<Opportunity> testOpptys = TestingUtils.createOpportunities(2, testAccount.Id, 'TestOpp', false);
        for(Opportunity o : testOpptys)
        {
            o.Servicing_Division__c =  testServicingDivision.ID;
        }
        
        insert testOpptys;
        
        testOpportunity = testOpptys[0];
        anotherOpportunity = testOpptys[1];
    } 
    
    static void setUpPage()
    {
        PageReference currentPage = Page.ContractFileManagement;
        currentPage.getParameters().put( 'id', testOpportunity.Id );
        Test.setCurrentPage( currentPage );
    }

    static testMethod void testInvalidId() 
    {
        PageReference currentPage = Page.ContractFileManagement;
        currentPage.getParameters().put( 'Id', 'ngl12348' );
        ContractFileManagementCtrl controller = new ContractFileManagementCtrl();
        
        test.startTest();
            Test.setCurrentPage( currentPage );
        test.stopTest();
        System.assert( ApexPages.hasMessages(), 'There should be a page message for invalid Id' );
    }
    
    static testMethod void testGoBackAndSaveAfterDoingNothing() 
    {
        setUpAccountAndOpportunity();
        setUpPage();
        ContractFileManagementCtrl controller = new ContractFileManagementCtrl();
        test.startTest();
            PageReference returnedReference = controller.goBackAndSave();
        test.stopTest();
        System.assert( !ApexPages.hasMessages(), 'There should be no Page Message' );
    }
    
    static testMethod void testDocumentTypesLoadedInOrder()
    {
        numDocTypes = 4;
        
        List<String> picklistValues = new List<String>(ContractFileManagementCtrl.POSSIBLE_DOCUMENT_TYPES);
        System.assert(picklistValues.size()>=numDocTypes,'The unit tests for contractfilemanagement will fail if there are not at least ' + numDocTypes + ' types of possible document values, specified as picklist value options in the document_types picklist on contract');
        List<FAP_Specification__c> contractDocTypes = new List<FAP_Specification__c>();
        
        Map<Integer,String> assignedOrders = new Map<Integer,String> {2=>picklistValues[0],4=>picklistValues[1],1=>picklistValues[2],3=>picklistValues[3]};
        
        for(Integer assignedOrder: assignedOrders.keySet())
        {
            String docType = assignedOrders.get(assignedOrder);
            FAP_Specification__c customSetting = setupContractDocTypes(docType,ContractFileManagementCtrl.FILE_ON_ACCOUNT);
            customSetting.Order__c = assignedOrder;
            contractDocTypes.add(customSetting);
        }
        
        insert contractDocTypes;
        setUpAccountAndOpportunity(); 
        setUpPage();
        
        Test.startTest();
            ContractFileManagementCtrl controller = new ContractFileManagementCtrl();
        Test.stopTest();
        
        System.assertEquals(numDocTypes,controller.contractWrappers.size(),'We expect a contract wrapper to be created for each valid document type');
        for(Integer assignedOrder: assignedOrders.keySet())
        {
            String expectedDocType = assignedOrders.get(assignedOrder);
            System.assertEquals(expectedDocType,controller.contractWrappers[assignedOrder-1].fapSpecification.Name,'We expect the wrappers to be pulled in the right order');
        }
  
    }
    
    static void setupForTestingPageLoad()
    {
        /*
        Create custom settings based on values in the list
        */
        numDocTypes = 4;
        
        List<String> picklistValues = new List<String>(ContractFileManagementCtrl.POSSIBLE_DOCUMENT_TYPES);
        System.assert(picklistValues.size()>=numDocTypes,'The unit tests for contractfilemanagement will fail if there are not at least ' + numDocTypes + ' types of possible document values, specified as picklist value options in the document_types picklist on contract');
        
        List<String> docTypesToAttachToAccount = new List<String> { picklistValues[0],picklistValues[1] };
        List<String> docTypesToAttachToOpportunity = new List<String> { picklistValues[2],picklistValues[3]};
        Map<String, FAP_Specification__c> docTypeMap = new Map<String, FAP_Specification__c>();
        List<FAP_Specification__c> contractDocTypes = new List<FAP_Specification__c>();
        for(String aDocType : docTypesToAttachToAccount)
        {
            FAP_Specification__c customSetting = setupContractDocTypes(aDocType,ContractFileManagementCtrl.FILE_ON_ACCOUNT);
            contractDocTypes.add(customSetting);
            docTypeMap.put(aDocType,customSetting);
        }
        
        for(String aDocType : docTypesToAttachToOpportunity)
        {
            FAP_Specification__c customSetting = setupContractDocTypes(aDocType,ContractFileManagementCtrl.FILE_ON_OPPORTUNITY);
            contractDocTypes.add(customSetting);
            docTypeMap.put(aDocType,customSetting);
        }
        insert contractDocTypes;
        
        setUpAccountAndOpportunity(); 
        /*
        Create two existing contracts, one with a Document_Type__c attached to the account, and the other attached to opportunity
        */
        List<Contract> contractsToCreate = new List<Contract>();
        existingContractForAccount = TestingUtils.createContract(testAccount.ID,anotherServicingDivision.ID,false); 
        existingContractForAccount.Document_Type__c = docTypesToAttachToAccount[0];
        
        existingContractForOpportunity = TestingUtils.createContract(testAccount.ID,testOpportunity.Servicing_Division__c,false);
        existingContractForOpportunity.Opportunity__c = testOpportunity.ID;
        existingContractForOpportunity.Document_Type__c = docTypesToAttachToOpportunity[0];
        
        
        allExistingContracts = new List<Contract> {existingContractForAccount, existingContractForOpportunity};
         
        insert allExistingContracts; 
        
        List<Attachment> testAttachmentsForContractForAccount = TestingUtils.createAttachments(existingContractForAccount.ID, 5);
        /* Although there are many attachments on this contract, there is only one valid attachment */
        testAttachmentForContractForAccount = testAttachmentsForContractForAccount[0];
        testAttachmentForContractForAccount.Name = docTypeMap.get(existingContractForAccount.Document_Type__c).Attachment_Prefix__c + 'Test'; //Correct abbriv
        testAttachmentsForContractForAccount[1].Name = docTypeMap.get(existingContractForOpportunity.Document_Type__c).Attachment_Prefix__c + 'Test'; //Wrong abbriv
        
        testAttachmentForContractForOpportunity = TestingUtils.createAttachment(existingContractForOpportunity.ID);
        testAttachmentForContractForOpportunity.Name = docTypeMap.get(existingContractForOpportunity.Document_Type__c).Attachment_Prefix__c + 'Hi';
        
        List<Attachment> attachmentsToInsert = new List<Attachment>();
        attachmentsToInsert.addAll(testAttachmentsForContractForAccount);
        attachmentsToInsert.add(testAttachmentForContractForOpportunity);
        insert attachmentsToInsert;
    } 
    
    static FAP_Specification__c setupContractDocTypes(String name, Boolean attachToOpportunity)
    {
        prefixCounter++;
        return TestingUtils.createFAPSpecification(name, new Map<String,Object>{'Attachment_Prefix__c'=>'prefix'+prefixCounter,'File_Varies_by_Opp__c'=>attachToOpportunity}, false);
    } 

    
    /* vary by opp, doesnt make it through
           doesnt vary opp, but is older, so it won't show up
           doesnt vary opp, this is the one we want
        */

    static testMethod void testFAPPageLoadForLegacyContracts()
    {
        numDocTypes = 2;
        
        List<String> picklistValues = new List<String>(ContractFileManagementCtrl.POSSIBLE_DOCUMENT_TYPES);
        System.assert(picklistValues.size()>=numDocTypes,'The unit tests for contractfilemanagement will fail if there are not at least ' + numDocTypes + ' types of possible document values, specified as picklist value options in the document_types picklist on contract');
        
        List<FAP_Specification__c> specs = new List<FAP_Specification__c>();
        specs.add(setupContractDocTypes(picklistValues[0],ContractFileManagementCtrl.FILE_ON_ACCOUNT));
        specs.add(setupContractDocTypes(picklistValues[1],ContractFileManagementCtrl.FILE_ON_OPPORTUNITY));
        
        for(FAP_Specification__c spec : specs)
        {
            spec.Attachment_Prefix__c = '';
        }
        
        insert specs;
        
        setUpAccountAndOpportunity();
        
        List<Contract> legacyContracts = TestingUtils.createContracts(2, testAccount.ID, testServicingDivision.ID, false);
        Contract qualifyingLegacyContract = legacyContracts[0];
        Contract nonqualifyingLegacycontract = legacyContracts[1];
        
        qualifyingLegacyContract.Division__c =  anotherServicingDivision.ID; 
        qualifyingLegacyContract.Document_Type__c = specs[0].Name;
        qualifyingLegacyContract.Opportunity__c = anotherOpportunity.ID;
        
        nonqualifyingLegacycontract.Opportunity__c = null;
        nonqualifyingLegacycontract.Document_Type__c = specs[1].Name;
        insert legacyContracts;
        
        List<Attachment> allAttachments = new List<Attachment>();
        for(Contract c : legacyContracts)
        {
            Attachment testAttachment = TestingUtils.createAttachments(c.ID, 1)[0];
            testAttachment.Name = 'Test.pdf'; 
            allAttachments.add(testAttachment);
        }
        
        insert allAttachments;
        
        setUpPage();
        
        Test.startTest();
            ContractFileManagementCtrl controller = new ContractFileManagementCtrl();
        Test.stopTest();
        
        System.assertEquals(numDocTypes,controller.contractWrappers.size(),'We expect a contract wrapper to be created for each valid document type');
        Integer existingContractsFound = 0;
        Integer newContractsRequired = 0;
        
        for(ContractFileManagementCtrl.ContractAttachmentWrapper aWrapper : controller.contractWrappers)
        {
            if(aWrapper.Contract==null)
            {
                System.assertEquals(nonqualifyingLegacycontract.Document_Type__c,aWrapper.documentType,'There should be no contract found for the non-qualifying legacy contract');
                System.assertEquals(ContractFileManagementCtrl.BUTTON_ADD_NEW,aWrapper.buttonText);
                newContractsRequired++;
            }
            else
            {
                existingContractsFound++;
                System.assertEquals(ContractFileManagementCtrl.BUTTON_CHANGE,aWrapper.buttonText);
                System.assertEquals(testAccount.ID,aWrapper.Contract.AccountId,'The contract should belong to the right account');
               // System.assertEquals(qualifyingLegacycontract.Document_Type__c,aWrapper.documentType,'There should be a contract found for the qualifying legacy contract');
            }
        }
        
        //System.assertEquals(1,existingContractsFound,'There should only be one contract found - the qualifying legacy contract');
        //System.assertEquals(1,newContractsRequired,'The sales rep will need to create one contract, as the non qualifying legacy contract does not count');
    }
     
    static void setupForTestingRequiredDocumentTypesForThisOpportunity()
    {
        numDocTypes = 4;
        
        List<String> picklistValues = new List<String>(ContractFileManagementCtrl.POSSIBLE_DOCUMENT_TYPES);
        System.assert(picklistValues.size()>=numDocTypes,'The unit tests for contractfilemanagement will fail if there are not at least ' + numDocTypes + ' types of possible document values, specified as picklist value options in the document_types picklist on contract');
        
        List<FAP_Specification__c> contractDocTypes = new List<FAP_Specification__c>();
        for(Integer i = 0; i < numDocTypes; i++)
        {
            contractDocTypes.add(setupContractDocTypes(picklistValues[i],ContractFileManagementCtrl.FILE_ON_OPPORTUNITY));
        }
        
        checkboxFieldsInOpportunity = new List<String>(ContractFileManagementCtrl.requiredCheckboxMappings.keySet());
        
        firstCheckBoxChecked = contractDocTypes[0];
        secondCheckBoxChecked = contractDocTypes[1];
        noCheckBoxesChecked = contractDocTypes[2];
        allCheckBoxesChecked = contractDocTypes[3];
        
        firstCheckBoxChecked.put(ContractFileManagementCtrl.requiredCheckboxMappings.get(checkboxFieldsInOpportunity[0]),true);
        secondCheckBoxChecked.put(ContractFileManagementCtrl.requiredCheckboxMappings.get(checkboxFieldsInOpportunity[1]),true);
        for(String checkBoxInOppty : checkboxFieldsInOpportunity)
        {
            allCheckBoxesChecked.put(ContractFileManagementCtrl.requiredCheckboxMappings.get(checkBoxInOppty),true);
        }
        
        insert contractDocTypes;
        
        testServicingDivision = TestingUtils.createServicingDivision(true);
        
        testAccount = TestingUtils.createAccount( 'TestAccount', false );
    }
    
    static Opportunity createOpportunityWithCheckboxesFalse()
    {
        testOpportunity = TestingUtils.createOpportunity( testAccount.Id, 'TestOpp', false );
        for(String checkBoxInOppty : checkboxFieldsInOpportunity)
        {
            testOpportunity.put(checkBoxInOppty,false);
        }
        return testOpportunity;
    }
    static testMethod void testValidContractDocTypes()
    {
        Set<String> picklistValues = ContractFileManagementCtrl.POSSIBLE_DOCUMENT_TYPES;
        System.assert(!picklistValues.isEmpty(),'There must be some Document_Type__c picklist values detected');
        
        FAP_Specification__c matchingContract = setupContractDocTypes((new List<String>(picklistValues))[0],ContractFileManagementCtrl.FILE_ON_ACCOUNT);
        FAP_Specification__c notMatchingContract = setupContractDocTypes('DUMMY-VALUE',ContractFileManagementCtrl.FILE_ON_ACCOUNT);
        insert new List<FAP_Specification__c> {matchingContract,notMatchingContract};
        
        Test.startTest();
            
            Map<String,FAP_Specification__c> validContractDocTypes = ContractFileManagementCtrl.VALID_CONTRACT_DOC_TYPES;
            
        Test.stopTest();
        
        System.assertEquals(1,validContractDocTypes.keySet().size(),'We only expect one contract doc type to match a document type, as specified in the document type picklist on contract');
        for(String cdtName:validContractDocTypes.keySet()) 
        {
             System.assertEquals(matchingContract.Name,cdtName,'We expect to get back the right contract doc type');
        }
    }
    
    static testMethod void testPageLoad()
    {
        setupForTestingPageLoad();
        setUpPage();
        
        Test.startTest();
            ContractFileManagementCtrl controller = new ContractFileManagementCtrl();
        Test.stopTest();
        
        System.assertEquals(numDocTypes,controller.contractWrappers.size(),'We expect a contract wrapper to be created for each valid document type');
        Integer existingContractsFound = 0;
        Integer newContractsRequired = 0;
        Set<String> documentTypesEncountered = new Set<String>();
        
        for(ContractFileManagementCtrl.ContractAttachmentWrapper aWrapper : controller.contractWrappers)
        {
            
            documentTypesEncountered.add(aWrapper.documentType);
            
            if(aWrapper.Contract==null)
            {
                //No existing contract found
                System.assertEquals(ContractFileManagementCtrl.BUTTON_ADD_NEW,aWrapper.buttonText);
                newContractsRequired++;
            }
            else
            {
                //Existing contract found
                existingContractsFound++;
                System.assertEquals(ContractFileManagementCtrl.BUTTON_CHANGE,aWrapper.buttonText);
                System.assertEquals(testAccount.ID,aWrapper.Contract.AccountId,'The contract should belong to the testAccount');
                if(aWrapper.Contract.Opportunity__c==null)
                {
                    System.assertEquals(testAttachmentForContractForAccount.ID,aWrapper.AttachmentID,'The wrapper should point to the right attachment');
                }
                else
                {
                    System.assertEquals(testAttachmentForContractForOpportunity.ID,aWrapper.AttachmentID,'The wrapper should point to the right attachment');
                } 
            }
        }
        
        System.assertEquals(2,existingContractsFound,'We expect to find two existing valid contracts');
        System.assertEquals(2,newContractsRequired,'We expect to find out that we need contracts for 2 document types');
        System.assertEquals(numDocTypes,documentTypesEncountered.size(),'We expect the wrappers to have unique document types');
    }
    
    static testMethod void testCreateMapDocumentTypeToContractWhenMultipleContractsExistForSameDocumentType()
    {
        final String sampleDocType = 'Test';
        setUpAccountAndOpportunity();
        Contract testContractNewAttachment = TestingUtils.createContract( testAccount.ID, testOpportunity.Servicing_Division__c, false );
        Contract testContractOldAttachment = TestingUtils.createContract( testAccount.ID, testOpportunity.Servicing_Division__c, false );
        Contract testContractWithoutAttachment = TestingUtils.createContract( testAccount.ID, testOpportunity.Servicing_Division__c, false );
        List<Contract> testContracts = new List<Contract>{testContractWithoutAttachment, testContractNewAttachment, testContractOldAttachment};
        
        for(Contract c : testContracts)
        {
            c.Document_Type__c = sampleDocType;
        }
        
        insert testContracts;
        
        Attachment testAttachmentNew = TestingUtils.createAttachment( testContractNewAttachment.Id ); 
        Attachment testAttachmentOld = TestingUtils.createAttachment( testContractOldAttachment.Id );
        insert new List<Attachment> {testAttachmentNew, testAttachmentOld};
        
        Map<ID,Contract> testContractsMap = new MAp<ID, Contract>([Select ID, Document_Type__c, (Select ID, CreatedDate FROM Attachments) FROM Contract Where ID IN: testContracts]);
        testContractOldAttachment =  testContractsMap.get(testContractOldAttachment.ID);
        
        String attJSON = JSON.serialize(testContractOldAttachment);
        String year = String.valueOf(Date.today().year());
        attJSON = attJSON.replace('"CreatedDate":"'+year, '"CreatedDate":"2000');
        testContractOldAttachment = (Contract)JSON.deserializeStrict(attJSON, Contract.class);
        
        testContractsMap.put(testContractOldAttachment.ID,testContractOldAttachment);
        
        test.StartTest();
            Map<String, Contract> results = ContractFileManagementCtrl.createMapDocumentTypeToContract(testContractsMap.values());
        test.StopTest(); 
                
        System.assertEquals(testContractNewAttachment.Id, results.get(sampleDocType).Id, 'When there are multiple contracts in the system with the same document type, we must pick out the contract with the most recently added attachment ' + testContracts);
    }
  
   
    static testMethod void testCreateULSAndUpdateContractsForWarehouseOpportunity_warehouse()
    {
        setupAccountAndOpportunity();
        
        final String oppFieldValue = 'High';
        final String accFieldValue = testAccount.ID;
        ULS_Location_Field_Mapping__c oppField = new ULS_Location_Field_Mapping__c(Name='WH_Volume__c', Object__c=ContractFileManagementCtrl.OPPORTUNITY_OBJECT,Map_From_Field__c='WH_Volume__c');
        ULS_Location_Field_Mapping__c accField = new ULS_Location_Field_Mapping__c(Name='Account__c', Object__c=ContractFileManagementCtrl.ACCOUNT_OBJECT,Map_From_Field__c='ID');
        
        List<ULS_Location_Field_Mapping__c> ulsFields = new List<ULS_Location_Field_Mapping__c> {oppField,accField};
        insert ulsFields;
        
        testOpportunity.Warehouse__c = true;
        testOpportunity.put(oppField.Map_From_Field__c,oppFieldValue);
        update testOpportunity;
        
        final Integer NUM_OF_CONTRACTS = 5;
        List<Contract> testContracts = TestingUtils.createContracts( NUM_OF_CONTRACTS, testAccount.Id, testOpportunity.Servicing_Division__c,  true );
        setupPage();
        ContractFileManagementCtrl controller = new ContractFileManagementCtrl();
        controller.contractWrappers = new List<ContractFileManagementCtrl.ContractAttachmentWrapper>();

        for( Contract aContract : testContracts )
        {
            ContractFileManagementCtrl.ContractAttachmentWrapper aWrapper = new ContractFileManagementCtrl.ContractAttachmentWrapper( aContract, NULL, NULL, NULL, controller );
            controller.contractWrappers.add( aWrapper );
        }
        
        test.startTest();
            controller.createULSAndUpdateContractsForWarehouseOpportunity();
        test.stopTest();
        System.assert( !ApexPages.hasMessages(), 'There should be no page messages' + ApexPages.getMessages() );
        
        List<String> ULSFieldsToPull = new List<String>();
        for(ULS_Location_Field_Mapping__c ulsField : ulsFields)
        {
            ULSFieldsToPull.add(ulsField.name);
        }
        
        List<ULS_Location__c> actualULSLocations = Database.query('SELECT Id, ' + String.join(ULSFieldsToPull,',') + ' FROM ULS_Location__c WHERE Account__c = \'' + testAccount.Id +'\'');
       // System.assertEquals( 1, actualULSLocations.size(), 'There should be one ULS LOcation created');
        
       // System.assertEquals(oppFieldValue,actualULSLocations[0].get(oppField.Name),'We expect to pull over any fields from opportunity to the uls location that we specify in the custom setting');
       // System.assertEquals(accFieldValue,actualULSLocations[0].get(accField.Name),'We expect to pull over any fields from account to the uls location that we specify in the custom setting');
        
      //  List<Contract> actualContracts = [SELECT Id, ULS_Location_Detail__c FROM Contract WHERE Id IN :testContracts AND ULS_Location_Detail__c = :actualULSLocations[0].Id ];
       // System.assertEquals( testContracts.size(), actualContracts.size(), 'All the contracts should have ULS Location Lookup related to the new ULS Location');
        
    }
    
    static testMethod void testCreateULSAndUpdateContractsForWarehouseOpportunity_notWarehouse()
    {
        setUpAccountAndOpportunity();
        testOpportunity.Warehouse__c = false;
        update testOpportunity;
        final Integer NUM_OF_CONTRACTS = 5;
        List<Contract> testContracts = TestingUtils.createContracts( NUM_OF_CONTRACTS, testAccount.Id, testOpportunity.Servicing_Division__c,  true );
        setupPage();
        ContractFileManagementCtrl controller = new ContractFileManagementCtrl();
        controller.contractWrappers = new List<ContractFileManagementCtrl.ContractAttachmentWrapper>();

        for( Contract aContract : testContracts )
        {
            ContractFileManagementCtrl.ContractAttachmentWrapper aWrapper = new ContractFileManagementCtrl.ContractAttachmentWrapper( aContract, NULL, NULL, NULL, controller );
            controller.contractWrappers.add( aWrapper );
        }
        
        test.startTest();
            controller.createULSAndUpdateContractsForWarehouseOpportunity();
        test.stopTest();
        System.assert( !ApexPages.hasMessages(), 'There should be no page messages' + ApexPages.getMessages() );
        List<ULS_Location__c> actualULSLocations = [ SELECT Id FROM ULS_Location__c WHERE Account__c = :testAccount.Id ];
        System.assert( actualULSLocations.isEmpty(), 'There should be no ULS LOcation created');
        
        List<Contract> actualContracts = [SELECT Id, ULS_Location_Detail__c FROM Contract WHERE Id IN :testContracts ];
        System.assertEquals( testContracts.size(), actualContracts.size(), 'All the contracts should be returned');
        for( Contract aContract : actualContracts )
        {
            System.assertEquals( null, aContract.ULS_Location_Detail__c, 'No contracts should have ULS Location Lookup related to the new ULS Location');
        }
    } 
    
    static testMethod void testCloseWinOpportunity()
    {
        numDocTypes = 2;
        
        List<String> picklistValues = new List<String>(ContractFileManagementCtrl.POSSIBLE_DOCUMENT_TYPES);
        System.assert(picklistValues.size()>=numDocTypes,'The unit tests for contractfilemanagement will fail if there are not at least ' + numDocTypes + ' types of possible document values, specified as picklist value options in the document_types picklist on contract');
        
        List<FAP_Specification__c> contractDocTypes = new List<FAP_Specification__c>();
        for( Integer i = 0; i < numDocTypes; i++ )
        {
            FAP_Specification__c customSetting = setupContractDocTypes( picklistValues[i],ContractFileManagementCtrl.FILE_ON_OPPORTUNITY ); 
            contractDocTypes.add(customSetting);
        }
        contractDocTypes[0].WH__c = true;
        FAP_Specification__c requiredTestDocumentType = contractDocTypes[0];
        insert contractDocTypes;
        
        ULS_Location_Field_Mapping__c accField = new ULS_Location_Field_Mapping__c(Name='Account__c', Object__c=ContractFileManagementCtrl.ACCOUNT_OBJECT,Map_From_Field__c='ID');
        insert accField;
        
        testServicingDivision = TestingUtils.createServicingDivision(false); 
        anotherServicingDivision = TestingUtils.createServicingDivision(false);
        insert new List<Servicing_Division__c> {testServicingDivision,anotherServicingDivision};
        
        testAccount = TestingUtils.createAccount( 'TestAccount', false );
        testAccount.Is_ULS_Primary_Acct__c =true;
        testAccount.LTL__c = false;
        testAccount.Truckload__c = false;
        testAccount.XWarehouse__c = true; 
        
        insert testAccount;
        
        testOpportunity = TestingUtils.createOpportunity( testAccount.Id, 'TestOpp', false );
        testOpportunity.Servicing_Division__c = testServicingDivision.ID;
        testOpportunity.Warehouse__c = true;
        testOpportunity.Expected_Billing_Date__c = Date.today();
        insert testOpportunity;
        
        Map<String,Contract> mapDtToContract = new Map<String,Contract>();
        for( Integer i = 0; i < contractDocTypes.size(); i++ )
        {
            Contract contract = TestingUtils.createContract( testAccount.Id, testOpportunity.Servicing_Division__c, false );
            contract.Document_Type__c = contractDocTypes[i].Name;
            contract.Opportunity__c = testOpportunity.Id;
            mapDtToContract.put( contractDocTypes[i].Name,contract );
        }
        List<Contract> testContracts =  mapDtToContract.values();
        insert testContracts;
        
        List<Attachment> attachments = new List<Attachment>();
        for( FAP_Specification__c aDocType : contractDocTypes )
        {
            Contract contract = mapDtToContract.get( aDocType.Name );
            Attachment testAttachment = TestingUtils.createAttachment( contract.Id );
            testAttachment.Name = aDocType.Attachment_Prefix__c + testAttachment.Name; 
            attachments.add( testAttachment );
        }
        insert attachments;
        
        setupPage();
        ContractFileManagementCtrl controller = new ContractFileManagementCtrl();
        
        test.startTest();
            controller.closeWinOpportunity();
        test.stopTest();
        
        //System.assert( !ApexPages.hasMessages(), 'There should be no page messages' + ApexPages.getMessages() );
        
        Opportunity actualOpportunity = [SELECT Id, StageName, Validated_for_Close_Won__c FROM Opportunity Where Id = :testOpportunity.Id ];
       // System.assert( actualOpportunity.Validated_for_Close_Won__c, 'The validated close won field on Opportunity should be set to true' );
        //System.assertEquals( ContractFileManagementCtrl.CLOSED_WON, actualOpportunity.StageName, 'The stage field on Opportunity should be set to 8- Closed Won' );
        
        List<ULS_Location__c> actualULSLocations = [ SELECT Id FROM ULS_Location__c WHERE Account__c = :testAccount.Id ];
       // System.assertEquals( 1, actualULSLocations.size(), 'There should be one ULS LOcation created');
        
       // List<Contract> actualContracts = [SELECT Id, ULS_Location_Detail__c FROM Contract WHERE Id IN :testContracts AND ULS_Location_Detail__c = :actualULSLocations[0].Id ];
      //  System.assertEquals( testContracts.size(), actualContracts.size(), 'All the contracts should have ULS Location Lookup related to the new ULS Location');
    }
    
    static testMethod void testSetMonthToMonthToTrue()
    {
        testAccount = TestingUtils.createAccount( 'TestAccount', true );
        
        Contract testContract = TestingUtils.createContract(testAccount.ID, null, false);
        ContractFileManagementCtrl.ContractAttachmentWrapper wrapper = new ContractFileManagementCtrl.ContractAttachmentWrapper(testContract,null,null,null, null);
        
        Test.startTest();
            wrapper.contract.Terms__c = ContractFileManagementCtrl.TERMS_MONTH_TO_MONTH;
            Boolean monthToMonth = wrapper.isMonthToMonth;
        Test.stopTest();
        
        System.assert(wrapper.isMonthToMonth,'Month to Month should be marked to true');
    }
    
    static testMethod void testSetMonthToMonthToFalse()
    {
        testAccount = TestingUtils.createAccount( 'TestAccount', true );
        
        Contract testContract = TestingUtils.createContract(testAccount.ID, null, false);
        testContract.Terms__c = ContractFileManagementCtrl.TERMS_MONTH_TO_MONTH;
        
        ContractFileManagementCtrl.ContractAttachmentWrapper wrapper = new ContractFileManagementCtrl.ContractAttachmentWrapper(testContract,null,null,null, null);
        
        Test.startTest();
            wrapper.contract.Terms__c = ContractFileManagementCtrl.TERMS_CONTRACT_PERIOD;
            Boolean monthToMonth = wrapper.isMonthToMonth;
        Test.stopTest();
        
        System.assert(!wrapper.isMonthToMonth,'Month to Month should be marked to false');
    }
    
    static testMethod void testGetAllContracts()
    {
        testAccount = TestingUtils.createAccount( 'TestAccount', true );
        
        FAP_Specification__c fapSpecForNeedDate = setupContractDocTypes('Need Date FAP', ContractFileManagementCtrl.FILE_ON_OPPORTUNITY);
        fapSpecForNeedDate.Need_Date__c = true;
        FAP_Specification__c fapSpecForNotNeedDate = setupContractDocTypes('Do not need date FAP', ContractFileManagementCtrl.FILE_ON_OPPORTUNITY);
        fapSpecForNotNeedDate.Need_Date__c = false;
        
        testServicingDivision = TestingUtils.createServicingDivision(true);
        
        Contract testMonthToMonthContract = TestingUtils.createContract(testAccount.ID,testServicingDivision.ID,false);
        testMonthToMonthContract.Terms__c = ContractFileManagementCtrl.TERMS_MONTH_TO_MONTH;
        
        Contract testContractPeriodContract = TestingUtils.createContract(testAccount.ID,testServicingDivision.ID,false);
        testContractPeriodContract.Terms__c = ContractFileManagementCtrl.TERMS_CONTRACT_PERIOD;
        
        Contract testMonthToMonthContract2 = TestingUtils.createContract(testAccount.ID,testServicingDivision.ID,false);
        testMonthToMonthContract.Terms__c = ContractFileManagementCtrl.TERMS_MONTH_TO_MONTH;
        
        Contract testContractPeriodContract2 = TestingUtils.createContract(testAccount.ID,testServicingDivision.ID,false);
        testContractPeriodContract.Terms__c = ContractFileManagementCtrl.TERMS_CONTRACT_PERIOD;
        
        List<Contract> testContracts = new List<Contract> {testMonthToMonthContract,testContractPeriodContract,testMonthToMonthContract2,testContractPeriodContract2};
        insert testContracts;
             
        ContractFileManagementCtrl.ContractAttachmentWrapper needDateAndContractPeriod = new ContractFileManagementCtrl.ContractAttachmentWrapper(testContractPeriodContract,null,null,fapSpecForNeedDate,null);
        ContractFileManagementCtrl.ContractAttachmentWrapper needDateAndMonthToMonth = new ContractFileManagementCtrl.ContractAttachmentWrapper(testMonthToMonthContract,null,null,fapSpecForNeedDate,null);
        ContractFileManagementCtrl.ContractAttachmentWrapper noNeedDateAndContractPeriod = new ContractFileManagementCtrl.ContractAttachmentWrapper(testContractPeriodContract2,null,null,fapSpecForNotNeedDate,null);
        ContractFileManagementCtrl.ContractAttachmentWrapper noNeedDateAndMonthToMonth = new ContractFileManagementCtrl.ContractAttachmentWrapper(testMonthToMonthContract2,null,null,fapSpecForNotNeedDate,null);
        
        List<ContractFileManagementCtrl.ContractAttachmentWrapper> wrappers = new List<ContractFileManagementCtrl.ContractAttachmentWrapper> {needDateAndContractPeriod,needDateAndMonthToMonth,noNeedDateAndContractPeriod,noNeedDateAndMonthToMonth};
        
        Test.startTest(); 
            List<Contract> allContracts = ContractFileManagementCtrl.getAllContracts(wrappers);
        Test.stopTest();
        
        System.assertEquals(testContracts.size(),allContracts.size(),'We expect to get back each contract in the wrapper');
        for(Contract c : allContracts)
        {
            if(c.ID==needDateAndContractPeriod.contract.ID)
            {
                System.assertEquals(ContractFileManagementCtrl.SHORT_CONTRACT_TERM, c.ContractTerm, 'If no value is entered, by default, we expect the contract term on a document type that is need date to be set to 12.');
            }
            else if(c.ID==needDateAndMonthToMonth.contract.ID || c.ID==noNeedDateAndMonthToMonth.contract.ID || c.ID==noNeedDateAndContractPeriod.contract.ID)
            {
                System.assertEquals(ContractFileManagementCtrl.LONG_CONTRACT_TERM, c.ContractTerm, 'We expect to set the contract term on month-to-month contracts to a large value');
                System.assertEquals(Date.today(),c.StartDate,'If no value is entered, by default, the start date will be set to today for a contract that is month to month or does not need a date');
            }
            else
                System.assert(false,'You cannot extract a contract that doesnt exist in the wrapper');
        }       
    }
    
    static testMethod void testInformationNotLostWhenAddingAttachment()
    {
        numDocTypes = 6;
        
        List<String> picklistValues = new List<String>(ContractFileManagementCtrl.POSSIBLE_DOCUMENT_TYPES);
        System.assert(picklistValues.size()>=numDocTypes,'The unit tests for contractfilemanagement will fail if there are not at least ' + numDocTypes + ' types of possible document values, specified as picklist value options in the document_types picklist on contract');
    
        List<FAP_Specification__c> contractDocTypes = new List<FAP_Specification__c>();
        for(Integer i = 0; i < numDocTypes; i++)
        {
            FAP_Specification__c fap = setupContractDocTypes(picklistValues[i],ContractFileManagementCtrl.FILE_ON_OPPORTUNITY);
            fap.Need_Date__c = false;
            fap.Attachment_Prefix__c='';
            fap.Stage_Required_At__c = STAGE_1;
            contractDocTypes.add(fap);
        }
        
        insert contractDocTypes;
        
        testServicingDivision = TestingUtils.createServicingDivision(true);
        
        testAccount = TestingUtils.createAccount( 'TestAccount', false );
        insert testAccount;
        
        testOpportunity = TestingUtils.createOpportunity( testAccount.Id, 'TestOpp', false );
        testOpportunity.Servicing_Division__c = testServicingDivision.ID;
        insert testOpportunity;
        
        final Integer NUM_CONTRACTS = numDocTypes;
        List<Contract> contracts = TestingUtils.createContracts(NUM_CONTRACTS, testAccount.Id, testServicingDivision.ID, false);
        for(Integer k = 0; k < NUM_CONTRACTS; k++)
        {
            contracts[k].Opportunity__c = testOpportunity.ID;
            contracts[k].Document_Type__C = contractDocTypes[k].Name;
        }
        insert contracts;
        
        /* Create attachments */
        List<Attachment> testAttachments = new List<Attachment>();
        for(Contract c : contracts)
        {
            testAttachments.add(TestingUtils.createAttachment(c.ID));
        }
        insert testAttachments;
        
        setUpPage();
        ContractFileManagementCtrl controller = new ContractFileManagementCtrl();
        
        Contract contractToModify = controller.contractWrappers[0].contract;
        contractToModify.StartDate = Date.today()-12;
        contractToModify.ContractTerm = 4;
        contractToModify.Terms__c = ContractFileManagementCtrl.TERMS_MONTH_TO_MONTH;
        
        Test.startTest();
            /* In the ordinary flow, the user would add/change an attachment which would initiate javascript
               that ultimately calls initializepage */
            controller.initializePage();
        Test.stopTest();
        
        for(ContractFileManagementCtrl.ContractAttachmentWrapper c : controller.contractWrappers)
        {
            if(c.contract.ID==contractToModify.ID)
            {
                System.assertEquals(contractToModify.StartDate,c.contract.StartDate,'When the page refreshes to account for the latest attachment information, it must not lose any entered start date values');
                System.assertEquals(contractToModify.ContractTerm,c.contract.ContractTerm,'When the page refreshes to account for the latest attachment information, it must not lose any entered contract term values');
                System.assertEquals(contractToModify.Terms__c,c.contract.Terms__c,'When the page refreshes to account for the latest attachment information, it must not lose any entered month to month values');
            }
        }
    }
    
    
    static testMethod void testGetContractsMissingRequiredStartDates()
    {
        FAP_Specification__c needDateFAP = setupContractDocTypes('',ContractFileManagementCtrl.FILE_ON_OPPORTUNITY);
        needDateFAP.Need_Date__c = true;
        FAP_Specification__c noNeedDateFAP = setupContractDocTypes('',ContractFileManagementCtrl.FILE_ON_OPPORTUNITY);
        noNeedDateFAP.Need_Date__c = false;
        
        Contract monthToMonthContractMissingStartDate = TestingUtils.createContracts(1, null, null, false)[0];
        monthToMonthContractMissingStartDate.Terms__c= ContractFileManagementCtrl.TERMS_MONTH_TO_MONTH;
        Contract contractPeriodContractMissingStartDate = TestingUtils.createContracts(1, null, null, false)[0];
        contractPeriodContractMissingStartDate.Terms__c= ContractFileManagementCtrl.TERMS_CONTRACT_PERIOD;
        Contract  contractPeriodContractNotMissingStartDate = contractPeriodContractMissingStartDate.clone(true);
        contractPeriodContractNotMissingStartDate.StartDate = Date.today();
        
        UnitTest.addData(new List<Contract> {monthToMonthContractMissingStartDate,contractPeriodContractMissingStartDate,contractPeriodContractNotMissingStartDate}).dummyInsert();
        
        List<ContractFileManagementCtrl.ContractAttachmentWrapper> compliantWrappers = new List<ContractFileManagementCtrl.ContractAttachmentWrapper>  {
                                                                                                new ContractFileManagementCtrl.ContractAttachmentWrapper(needDateFAP,null),
                                                                                                new ContractFileManagementCtrl.ContractAttachmentWrapper(noNeedDateFAP,null),
                                                                                                new ContractFileManagementCtrl.ContractAttachmentWrapper(monthToMonthContractMissingStartDate,null,null,needDateFAP,null),
                                                                                                new ContractFileManagementCtrl.ContractAttachmentWrapper(monthToMonthContractMissingStartDate,null,null,noNeedDateFAP,null),
                                                                                                new ContractFileManagementCtrl.ContractAttachmentWrapper(contractPeriodContractMissingStartDate,null,null,null,null),
                                                                                                new ContractFileManagementCtrl.ContractAttachmentWrapper(contractPeriodContractMissingStartDate,null,null,noNeedDateFAP,null),
                                                                                                new ContractFileManagementCtrl.ContractAttachmentWrapper(contractPeriodContractNotMissingStartDate,null,null,needDateFAP,null)
                                                                                                };
        List<ContractFileManagementCtrl.ContractAttachmentWrapper> nonCompliantWrappers = new List<ContractFileManagementCtrl.ContractAttachmentWrapper>  {
                                                                                                new ContractFileManagementCtrl.ContractAttachmentWrapper(contractPeriodContractMissingStartDate,null,null,needDateFAP,null)
                                                                                                };      
                                                                                                
        Test.startTest();
            List<Contract> retContractsForCompliantWrappers = ContractFileManagementCtrl.getContractsMissingRequiredStartDates(compliantWrappers);
            List<Contract> retContractsForNonCompliantWrappers = ContractFileManagementCtrl.getContractsMissingRequiredStartDates(nonCompliantWrappers);
        Test.stopTest();            
        
        System.assertEquals(1,retContractsForNonCompliantWrappers.size(),'We must correctly identify a contract as missing required start date field if a contract is not month to month and the fap specification indicates that a date is needed on the contract');                                                                                                                                                           
        System.assertEquals(0,retContractsForCompliantWrappers.size(),'We must only identify a contracts as missing required start date fields if contract is not month to month and the fap specification indicates that a date is needed on the contract');   
    }
    
    static testMethod void testAddErrorToMissingStartDateContracts(){
        
        numDocTypes = 1;
        
        List<String> picklistValues = new List<String>(ContractFileManagementCtrl.POSSIBLE_DOCUMENT_TYPES);
        System.assert(picklistValues.size()>=numDocTypes,'The unit tests for contractfilemanagement will fail if there are not at least ' + numDocTypes + ' types of possible document values, specified as picklist value options in the document_types picklist on contract');
        
        FAP_Specification__c needDateFAP = setupContractDocTypes(picklistValues[0],ContractFileManagementCtrl.FILE_ON_OPPORTUNITY);
        needDateFAP.Need_Date__c = true;
        
        insert needDateFAP;
        
        testServicingDivision = TestingUtils.createServicingDivision(true);
        
        testAccount = TestingUtils.createAccount( 'TestAccount', false );
        insert testAccount;
        
        testOpportunity = TestingUtils.createOpportunity( testAccount.Id, 'TestOpp', false );
        testOpportunity.Servicing_Division__c = testServicingDivision.ID;
        insert testOpportunity;
        
        /* Create the actual contracts */
        setUpPage();
        ContractFileManagementCtrl controller = new ContractFileManagementCtrl();
        
        Contract testContract = TestingUtils.createContracts(1, testAccount.Id, testServicingDivision.ID, false)[0];
        testContract.Opportunity__c = testOpportunity.ID;
        testContract.Document_Type__C = needDateFAP.Name;
        testContract.Terms__c= ContractFileManagementCtrl.TERMS_CONTRACT_PERIOD;
        insert testContract;
        
        /* Create attachment */
        insert TestingUtils.createAttachment(testContract.ID); 
        
        controller.initializePage();
        
        Test.startTest();
            controller.goBackAndSave();
        Test.stopTest();     
        
        System.assert( ApexPages.hasMessages(), 'We should get an error because this contract has a document type that specifies it should have a start date when it is not month to month, but this contract does not have a start date.');
    }
    
    static testMethod void testSave()
    {
        numDocTypes = 6;
        
        List<String> picklistValues = new List<String>(ContractFileManagementCtrl.POSSIBLE_DOCUMENT_TYPES);
        System.assert(picklistValues.size()>=numDocTypes,'The unit tests for contractfilemanagement will fail if there are not at least ' + numDocTypes + ' types of possible document values, specified as picklist value options in the document_types picklist on contract');
        
        List<FAP_Specification__c> contractDocTypes = new List<FAP_Specification__c>();
 
        String checkBoxFieldInAccount = (new List<String>(ContractFileManagementCtrl.requiredCheckboxMappings.keySet()))[0];
        String checkBoxFieldInFAP = ContractFileManagementCtrl.requiredCheckboxMappings.get(checkBoxFieldInAccount);
        
        for(Integer i = 0; i < numDocTypes; i++)
        {
            FAP_Specification__c fap = setupContractDocTypes(picklistValues[i],ContractFileManagementCtrl.FILE_ON_OPPORTUNITY);
            fap.put(checkBoxFieldInFAP,true);
            fap.Need_Date__c = false;
            fap.Attachment_Prefix__c='';
            contractDocTypes.add(fap);
        } 
        
        contractDocTypes[0].Stage_Required_At__c = STAGE_1;  //PASS
        contractDocTypes[1].Stage_Required_At__c = STAGE_3;  //PASS
        contractDocTypes[2].Stage_Required_At__c = STAGE_3;  //PASS
        contractDocTypes[3].Stage_Required_At__c = STAGE_5;  //PASS
        contractDocTypes[4].Stage_Required_At__c = STAGE_7;  //PASS
        //contractDocTypes[5].Stage_Required_At__c = STAGE_5;  //ATTACHMENT WONT BE NOT FOUND
        
        /* Because one of the documents needed to advance to stage 5 is not there, the maximum expected stage will be 4*/
        final Integer EXPECTED_MAX_STAGE = 8;

        insert contractDocTypes;
        
        testServicingDivision = TestingUtils.createServicingDivision(true);
        
        testAccount = TestingUtils.createAccount( 'TestAccount', false );
        testAccount.put(checkBoxFieldInAccount,true);
        insert testAccount;
        
        testOpportunity = TestingUtils.createOpportunity( testAccount.Id, 'TestOpp', false );
        testOpportunity.Servicing_Division__c = testServicingDivision.ID;
        testOpportunity.LTL__c = true;
        testOpportunity.Warehouse__c = true;
        testOpportunity.Truckload__c = true;
        insert testOpportunity;
        
        /* Create the actual contracts */
        setUpPage();
        ContractFileManagementCtrl controller = new ContractFileManagementCtrl();
        
        final Integer NUM_CONTRACTS = 5;
        List<Contract> contracts = TestingUtils.createContracts(NUM_CONTRACTS, testAccount.Id, testServicingDivision.ID, false);
        for(Integer k = 0; k < NUM_CONTRACTS; k++)
        {
            contracts[k].Opportunity__c = testOpportunity.ID;
            contracts[k].Document_Type__C = contractDocTypes[k].Name;
        }
        insert contracts;
        
        /* Create attachments */
        List<Attachment> testAttachments = new List<Attachment>();
        for(Contract c : contracts)
        {
            testAttachments.add(TestingUtils.createAttachment(c.ID));
        }
        insert testAttachments;
        
        controller.initializePage();
        
        Test.startTest();
            controller.goBackAndSave();
        Test.stopTest();     
        
        System.assert( !ApexPages.hasMessages(), 'There should be no Page Message' );
        
        Opportunity opp = [SELECT ID, Max_Stage_Number__c FROM Opportunity WHERE ID=:testOpportunity.ID];
        System.assertEquals(EXPECTED_MAX_STAGE,opp.Max_Stage_Number__c,'We expect to determine the right stage number which represents the maximum stage to which this opportunity can advance');
        
        contracts = [SELECT ID, StartDate, ContractTerm FROM Contract WHERE ID IN: contracts];
        for(Contract c : contracts)
        {
            System.assertEquals(Date.today(), c.StartDate, 'Because the document does not need a date, when the start date is not specified, it will default to today');
            System.assertEquals(ContractFileManagementCtrl.LONG_CONTRACT_TERM, c.ContractTerm, 'Because the document does not need a date, when the contract term is not specified, it must default to the right value');
        }
    }
    
    public static testMethod void getStageNumberValidStage()
    {
        Test.startTest();
            Integer stageNum = ContractFileManagementCtrl.getStageNumber(STAGE_1);
        Test.stopTest();
        
        System.assertEquals(1,stageNum,'We expect to get the number of the stage from the stage name');
    }
    
    public static testMethod void getStageNumberInvalidStage()
    {
        Test.startTest();
            Integer stageNum = ContractFileManagementCtrl.getStageNumber('Invalid Stage');
        Test.stopTest();
        
        System.assertEquals(8,stageNum, 'We expect to the number of the close-won stage when the stage is not specified properly');
    }
}
public class CPLServices {
    
    public Static String CPLType;
    private Static Date effectiveDate;
    
    public static Map<String, List<AgreementLineItemWrapper>> getAgreementLineItemsFromCPLByDivision(Customer_Price_List__c cpl, String cType, Date effectiveDateOverride){
        CPLType = cType;
        effectiveDate = effectiveDateOverride; //effectiveDateOverride is populated thru CPLEmailBatch
        List<AgreementLineItemWrapper> wrapperLineItems = getAgreementLineItemsFromCPL(cpl);
        Map<String, List<AgreementLineItemWrapper>> cplByDivision = new Map<String, List<AgreementLineItemWrapper>>();
        
        for (AgreementLineItemWrapper agreementLineItem : wrapperLineItems) {
            //String divisionName = agreementLineItem.currentAgreementLineItem.Division__r.Name;
            String divisionName = agreementLineItem.currentAgreementLineItem.Division__r.Name;
            if (cplByDivision.containsKey(divisionName)) {
                cplByDivision.get(divisionName).add(agreementLineItem);
            } else {
                cplByDivision.put(divisionName, new List<AgreementLineItemWrapper> { agreementLineItem });
            }
        }
        return cplByDivision;
    }
    
    public static List<AgreementLineItemWrapper> getAgreementLineItemsFromCPL(Customer_Price_List__c cpl){
        if(effectiveDate == null){
            effectiveDate = cpl.Effective_Date__c;
        }
        
        transient Contract agreement = [
            SELECT Id, Account.Chain_Account__c, Account.ParentId, Account.Natl_Acct_Group_ID__c, Name
            FROM Contract
            WHERE Id = :cpl.Agreement__c
        ];
        
        transient List<Id> contractsRegional = new List<Id>();        
        for( Contract regional : [Select id from contract where AccountId   = :agreement.Account.Chain_Account__c]){
            contractsRegional.add(regional.id);
        }
        
        //Set<Id> relevantContracts = getRelevantContractIds(agreement, cpl.Regional_National_Filter__c);
        transient Set<Id> relevantContracts = getRelevantContractIds(agreement, cpl.Regional_National_Filter__c, contractsRegional );
        //System.debug('agreement 1' + agreement);
        //System.debug(' cpl.Regional_National_Filter__c 1 ' +  cpl.Regional_National_Filter__c);
        //System.debug('contractsRegional 1 ' + contractsRegional);
        
        String query =  'SELECT Id, Name, PricingUOM__c, zpl__PolicyType__r.zpl__PolicyTypeId__c, Bracket1MinQty__c, Bracket1Value__c, Bracket1Price__c, Bracket2MinQty__c, Bracket2Value__c, Bracket2Price__c, Bracket3MinQty__c, '+
            'Bracket3Value__c, Bracket3Price__c, Bracket4MinQty__c, Bracket4Value__c, Bracket4Price__c, Bracket5MinQty__c, Bracket5Value__c, Bracket5Price__c, Bracket6MinQty__c, Product_Composite_Key__c, '+
            'Bracket6Value__c, Bracket6Price__c, CustomerUOM__c, Description__c, Bracket7MinQty__c, Bracket7Value__c, Bracket7Price__c, Brand__c, Brand_Desc__c, CPLSortField__c, ' +
            'Class__c, Class_Desc__c, CustomerSKU__c, CustomerCalculatedPrice__c, GTM__C, aiq_GTM__C, Set_Desc__c, Customer_Description__c, Division__c, Division__r.Division_Code__c, Division__r.Name, ' +
            'ExternalCostDeviationDate__c, ExternalCostDeviation__c, InternalCostDeviationDate__c, InternalCostDeviation__c, aiq_Net_Price__c, PricingCost__c, ' +
            'QuantityBreakUOM__r.Name, Quantity_Break_UOM__c, SKU__c, Segment__c, Set__c, Subset__c, Subset_Desc__c, VendorCode__c, AIQdt_Vendor__c, X12MonthSalesVolume__c, '+
            'zpl__LevelValue__c, zpl__LineLevel__c, zpl__LineLevel__r.Name, zpl__PolicyType__c, zpl__PolicyType__r.Name, zpl__PolicyValue__c, zpl__Product__c, ' +
            'zpl__EffectiveDate__c, zpl__Product__r.Brand_Description__c, zpl__Product__r.Class_Description__c, zpl__Product__r.Composite_Key__c, ' +
            'zpl__Product__r.Description, zpl__Product__r.ProductCode, zpl__Product__r.Set_Description__c, zpl__Product__r.Segment__c, zpl__ContractLineItem__c.Net_Price__c, ' +
            'zpl__Product__r.Subset_Description__c, zpl__Product__r.Vendor_Product_Code__c, zpl__UOM__c, zpl__UOM__r.Name, zpl__Product__r.Unit_of_Measure__c, Publish_Date__c, Level_Indicator__c, ' +
            'zpl__Contract__r.Account.RecordType.Name ' +
            'FROM zpl__ContractLineItem__c ' +
            'WHERE zpl__Contract__c IN :relevantContracts ' +
            'AND RecordTypeId = \'' + Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByName().get('Active').getRecordTypeId() + '\' ' +
            'AND zpl__Status__c = \'Published\' ';
        
        if (CPLType == 'External') {        
            query += 'AND ( aiq_Net_Price__c > 0 OR zpl__PolicyType__r.name = \'List Down\') ';    
        }
        
        if(cpl.Purchased_Stocked_Filter__c == 'Show Purchased Agreement Lines Only'){
            query += 'AND X12MonthSalesVolume__c > 0 ';
        }
            
        //KM - Chain Accounts filter
        if(cpl.Regional_National_Filter__c == 'Show Chain Accounts Only'){
            query += 'AND isCurrent__c = TRUE ';
        }
        
        //SP - 04012022
       /* if(cpl.Regional_National_Filter__c == 'Ignore Regional Chain AND National Agreement Lines (if any)'){
            String strChain = 'CHAIN';
            query += 'AND (NOT zpl__Contract__r.Account.Name LIKE \'%' + strChain + '%\')';
        }*/
        
        //SP-05172022
        if(cpl.Regional_National_Filter__c == 'Ignore Regional Chain AND National Agreement Lines (if any)'){
            String strChain = 'CHAIN';
            if(!((agreement.Name).contains(strChain))){
                //System.debug('((agreement.Name).contains(strChain)) ' + ((agreement.Name).contains(strChain)));
                //System.debug('agreement.Name ' + agreement.Name);
                query += 'AND (NOT Account__c LIKE \'%' + strChain + '%\')';
            }
        }
        
        //If Contract Name DOES NOT CONTAIN CHAIN, 
        //check line items account from zplcontractline, if contains chain do not include  AND //chain
        //check Contracts Account Natl Acct Group ID == Natl Acct Group ID from NationalAccountsPricing__c, if same do not include
        
        List<String> divisions = new List<String>();
        if (String.isNotBlank(cpl.Division__c)) {
            divisions = cpl.Division__c.split(';');
            query += 'AND Division__c IN :divisions ';
        }
        
        List<String> segments = new List<String>();
        if (String.isNotBlank(cpl.Segments__c)) {
            segments = cpl.Segments__c.split(';');
            query += 'AND Segment__c IN :segments ';
        }
        
        List<String> classes = new List<String>();
        if (String.isNotBlank(cpl.Classes__c)) {
            classes = cpl.Classes__c.split(';');
            query += 'AND Class__c IN :classes ';
        }
        
        List<String> brands = new List<String>();
        if (String.isNotBlank(cpl.Brands__c)) {
            brands = cpl.Brands__c.split(';');
            query += 'AND Brand__c IN :brands ';
        }
        
        if (cpl.New_Or_Changed_Only__c) {
            query += 'AND (Publish_Date__c > :effectiveDate OR LastModifiedDate > :effectiveDate) ';
        }
        
        if (cpl.Purchased_Stocked_Filter__c == 'Show Purchased Agreement Lines Only') {
            query += 'AND X12MonthSalesVolume__c > 0 ';
        } else if (cpl.Purchased_Stocked_Filter__c == 'Show Stock Agreement Lines Only') {
            query += 'AND zpl__Product__r.Stocking_Flag__c = true ';
        } else if (cpl.Purchased_Stocked_Filter__c == 'Show Purchased Or Stocked Agreement Lines') {
            query += 'AND (X12MonthSalesVolume__c > 0 OR zpl__Product__r.Stocking_Flag__c = true) ';
        }
        
        query += 'ORDER BY zpl__EffectiveDate__c DESC, Publish_Date__c DESC';
        //System.debug(' query  ' + query);
        transient List<zpl__ContractLineItem__c> allAgreementLineItems = Database.query(query);
        //System.debug('allAgreementLineItems ' + allAgreementLineItems);
        //System.debug('cpl.Regional_National_Filter__c dsdsd' + cpl.Regional_National_Filter__c);
        
        query = null; //heap deallocation
        divisions = null; //heap deallocation
        segments = null; //heap deallocation 
        classes = null; //heap deallocation
        brands = null; //heap deallocation
        
        //[START] Backlog Item 2810 
        Id conRecordTypeId = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        
        //Get Duplicate/greater than 1 'Item #(SKU__c)'
        transient List<AggregateResult> queryWithFuture =  [SELECT Count(Id), SKU__c skuName
                                                  FROM zpl__ContractLineItem__c 
                                                  WHERE zpl__Contract__c IN :relevantContracts
                                                  AND RecordTypeId =:conRecordTypeId
                                                  AND zpl__Status__c = 'Published' 
                                                  GROUP BY SKU__c HAVING count(Id)>1];
        Set<string> skuValues = new Set<string>();
        
        //Add 'Item #(SKU__c)' values to Set 
        for(AggregateResult ar : queryWithFuture){
            skuValues.add(string.valueOf(ar.get('skuName')));
        }
        //System.debug('skuValues ' + skuValues);
        
        //Get Id of Contract Line Item with duplicate 'Item #(SKU__c)'
        transient List<zpl__ContractLineItem__c> agreementWithDuplicates =  [SELECT Id
                                                                   FROM zpl__ContractLineItem__c
                                                                   WHERE zpl__Contract__c IN :relevantContracts 
                                                                   AND RecordTypeId =:conRecordTypeId
                                                                   AND zpl__Status__c = 'Published'
                                                                   AND Name IN :skuValues];                                                      

        //System.debug('agreementWithDuplicatesfff ' + agreementWithDuplicates);        
        Set<Id> aggreementLineSet = (new Map<Id,zpl__ContractLineItem__c>(allAgreementLineItems)).keySet();
        //System.debug('aggreementLineSetfff ' + aggreementLineSet);
        Set<Id> resultIds = (new Map<Id,zpl__ContractLineItem__c>(agreementWithDuplicates)).keySet();
        //System.debug('resultIdsff ' + resultIds);
        aggreementLineSet.removeAll(resultIds);
        
        agreementWithDuplicates = null;
        resultIds = null;
        
        //For Agreement Lines with no duplicates - Future Only aggreement lines
        transient List<zpl__ContractLineItem__c> agreementLineNoDupes = new List<zpl__ContractLineItem__c>();
        if(aggreementLineSet != null){
            agreementLineNoDupes =  [SELECT Id, zpl__LevelValue__c, zpl__EffectiveDate__c, Level_Indicator__c, CPLSortField__c, Segment__c, Division__c,  Division__r.Division_Code__c, Division__r.Name,
                                                                              Name, PricingUOM__c, zpl__PolicyType__r.zpl__PolicyTypeId__c, Bracket1MinQty__c, Bracket1Value__c, Bracket1Price__c, Bracket2MinQty__c, Bracket2Value__c, Bracket2Price__c, Bracket3MinQty__c,
                                                                              Bracket3Value__c, Bracket3Price__c, Bracket4MinQty__c, Bracket4Value__c, Bracket4Price__c, Bracket5MinQty__c, Bracket5Value__c, Bracket5Price__c, Bracket6MinQty__c,  
                                                                              Bracket6Value__c, Bracket6Price__c, CustomerUOM__c, Description__c, Bracket7MinQty__c, Bracket7Value__c, Bracket7Price__c, Brand__c, Brand_Desc__c,
                                                                              Class__c, Class_Desc__c, CustomerSKU__c, CustomerCalculatedPrice__c, GTM__C, aiq_GTM__C, Set_Desc__c, Customer_Description__c, 
                                                                              ExternalCostDeviationDate__c, ExternalCostDeviation__c, InternalCostDeviationDate__c, InternalCostDeviation__c, aiq_Net_Price__c, PricingCost__c, 
                                                                              QuantityBreakUOM__r.Name, Quantity_Break_UOM__c, SKU__c, Set__c, Subset__c, Subset_Desc__c, VendorCode__c, AIQdt_Vendor__c, X12MonthSalesVolume__c, 
                                                                              zpl__LineLevel__c, zpl__LineLevel__r.Name, zpl__PolicyType__c, zpl__PolicyType__r.Name, zpl__PolicyValue__c, zpl__Product__c,
                                                                              zpl__Product__r.Brand_Description__c, zpl__Product__r.Class_Description__c, zpl__Product__r.Composite_Key__c, Product_Composite_Key__c,
                                                                              zpl__Product__r.Description, zpl__Product__r.ProductCode, zpl__Product__r.Set_Description__c, zpl__Product__r.Segment__c, zpl__ContractLineItem__c.Net_Price__c,
                                                                              zpl__Product__r.Subset_Description__c, zpl__Product__r.Vendor_Product_Code__c, zpl__UOM__c, zpl__UOM__r.Name, zpl__Product__r.Unit_of_Measure__c, Publish_Date__c,
                                                                              zpl__Contract__r.Account.RecordType.Name 
                                                                              FROM zpl__ContractLineItem__c
                                                                              WHERE zpl__Contract__c IN :relevantContracts 
                                                                              AND RecordTypeId =:conRecordTypeId
                                                                              AND zpl__Status__c = 'Published'
                                                                              AND Id IN :aggreementLineSet
                                                                              ORDER BY zpl__EffectiveDate__c DESC, Publish_Date__c DESC]; 
        }
         //System.debug('agreementLineNoDupes ' + agreementLineNoDupes);
         aggreementLineSet = null;
        //[END] Backlog Item 2810
        
        Map<String, List<Product2>> classificationsToProducts = new Map<String, List<Product2>>();
        if (cpl.Level_Filter__c == 'Item Level (Expand Sets and Subsets)') {
            List<zpl__ContractLineItem__c> setLevelAgreementLineItems = getLineLevelAgreementLineItems(allAgreementLineItems, 'Set');
            List<zpl__ContractLineItem__c> subsetLevelAgreementLineItems = getLineLevelAgreementLineItems(allAgreementLineItems, 'Subset');
            
            if (setLevelAgreementLineItems.size() > 0) {
                String setQuery = 'SELECT Id, Name, IsActive, Unit_of_Measure__c, ' +
                    'Brand__c, Brand_Description__c, Class__c, Class_Description__c, Composite_Key__c, ' +
                    'Description, ProductCode, Set__c, Set_Description__c, Division_Name__r.Name, Division_Name__c, Division_Name__r.Division_Code__c, ' +
                    'Subset__c, Subset_Description__c, Vendor_Product_Code__c, zpl__UOM__c, Pricing_Costing_UOM__c, ' +
                    'Segment__c ' +
                    'FROM Product2 '+
                    'WHERE ';
                
                set<String> setLevelFilters = new set<String>();
                for (zpl__ContractLineItem__c setLevelAgreementLineItem : setLevelAgreementLineItems){
                  
                        setLevelFilters.add('(Division_Name__c = ' + (setLevelAgreementLineItem.Division__c ==null ? 'null ':  ('\'' + setLevelAgreementLineItem.Division__c) + '\' ') +
                                            'AND Class__c = ' + '\'' + setLevelAgreementLineItem.Class__c + '\' ' +
                                            'AND Brand__c = ' + '\'' + setLevelAgreementLineItem.Brand__c + '\' ' +
                                            'AND Set__c = ' + '\'' + setLevelAgreementLineItem.Set__c + '\' ' +
                                            'AND IsActive = TRUE)');
                }
                //setQuery += String.join(setLevelFilters, ' OR ');
                setQuery += String.join(new List<String>(setLevelFilters), ' OR ');
                
                List<Product2> setProducts = Database.query(setQuery);
                
                if(setProducts != null){
                for (Product2 setProduct : setProducts){                    
                    String classification = setProduct.Division_Name__r.Division_Code__c + setProduct.Class__c + setProduct.Brand__c + setProduct.Set__c ; 
                    if (classificationsToProducts.containsKey(classification)) {
                        classificationsToProducts.get(classification).add(setProduct);
                    } else {
                        classificationsToProducts.put(classification, new List<Product2> {setProduct});
                    }
                }
            }
            }
            
            if (subsetLevelAgreementLineItems.size() > 0){
                String subsetQuery = 'SELECT Id, Name, IsActive, Unit_of_Measure__c, ' +
                    'Brand__c, Brand_Description__c, Class__c, Class_Description__c, Composite_Key__c, ' +
                    'Description, ProductCode, Set__c, Set_Description__c, Division_Name__r.Name, Division_Name__c, Division_Name__r.Division_Code__c, ' +
                    'Subset__c, Subset_Description__c, Vendor_Product_Code__c, zpl__UOM__c, Pricing_Costing_UOM__c, ' +
                    'Segment__c ' +
                    'FROM Product2 ' +
                    'WHERE ';
                
                List<String> subsetLevelFilters = new List<String>();
                for (zpl__ContractLineItem__c subsetLevelAgreementLineItem : subsetLevelAgreementLineItems){
                    subsetLevelFilters.add('(Division_Name__c = '  + (subsetLevelAgreementLineItem.Division__c ==null ? 'null ':  ('\''+ subsetLevelAgreementLineItem.Division__c)+ '\' ') +
                                           'AND Class__c = ' + '\'' + subsetLevelAgreementLineItem.Class__c + '\' ' +
                                           'AND Brand__c = ' + '\'' + subsetLevelAgreementLineItem.Brand__c + '\' ' +
                                           'AND Set__c = ' + '\'' + subsetLevelAgreementLineItem.Set__c + '\' ' +
                                           'AND Subset__c = ' + '\'' + subsetLevelAgreementLineItem.Subset__c + '\' ' +
                                           'AND IsActive = TRUE)');
                }
                subsetQuery += String.join(subsetLevelFilters, ' OR ');
                
                List<Product2> subsetProducts = Database.query(subsetQuery);
                
                if(subsetProducts != null){
                    for (Product2 subsetProduct : subsetProducts){
                        String classification = subsetProduct.Division_Name__r.Division_Code__c + subsetProduct.Class__c + subsetProduct.Brand__c + subsetProduct.Set__c + subsetProduct.Subset__c;
                        if (classificationsToProducts.containsKey(classification)) {
                            classificationsToProducts.get(classification).add(subsetProduct);
                        } else {
                            classificationsToProducts.put(classification, new List<Product2> {subsetProduct});
                        }
                    }
                }
            }
        }
        
        List<AgreementLineItemWrapper> agreementLineItems = new List<AgreementLineItemWrapper>();
        Map<String, List<zpl__ContractLineItem__c>> levelValuesToAgreementLineItems = GroupBy.strings('zpl__LevelValue__c', allAgreementLineItems);        
        allAgreementLineItems = null; //heap deallocation
        //system.debug('About to enter.');
        List<zpl__ContractLineItem__c> agreementLineItemFutureHolder = new List<zpl__ContractLineItem__c>();
        for (String levelValue : levelValuesToAgreementLineItems.keySet()){
            List<zpl__ContractLineItem__c> agreementLineItemsForRecord = levelValuesToAgreementLineItems.get(levelValue);
            
            for (Integer i = 0; i < agreementLineItemsForRecord.size(); i++) {
                zpl__ContractLineItem__c agreementLineItem = agreementLineItemsForRecord[i];
                AgreementLineItemWrapper wrapper = new AgreementLineItemWrapper();
                wrapper.currentAgreementLineItem = agreementLineItem;
                //system.debug('Looping entrycdsds: '+ wrapper.currentAgreementLineItem);
                //system.debug('Looping entry: '+agreementLineItem.zpl__EffectiveDate__c+ ' <= '+effectiveDate);
                if (agreementLineItem.zpl__EffectiveDate__c <= effectiveDate){
                    if(agreementLineItemFutureHolder.size() > 0){
                        //system.debug('Inside after Added');
                        for(zpl__ContractLineItem__c futureLine: agreementLineItemFutureHolder){
                            DateTime todaysDate = System.today();
                            //system.debug('Inside condition: '+futureLine.SKU__c+ ' == '+agreementLineItem.SKU__c+ ' && '+ futureLine.zpl__EffectiveDate__c + ' || ' + System.today());
                            //if(futureLine.SKU__c == agreementLineItem.SKU__c && futureLine.Name == agreementLineItem.Name && futureLine.zpl__EffectiveDate__c != System.today() && futureLine.zpl__EffectiveDate__c > System.today()){
                            if(futureLine.SKU__c == agreementLineItem.SKU__c && futureLine.Name == agreementLineItem.Name && futureLine.zpl__EffectiveDate__c != System.today()){
                                
                                wrapper.futureAgreementLineItem = futureLine;
                                //System.debug('futureLine ' + futureLine);
                            }
                        }
                    }
                    
                    //if (i > 0 && agreementLineItem.zpl__EffectiveDate__c != System.today() && agreementLineItem.zpl__EffectiveDate__c > System.today()){
                    if (i > 0){
                            wrapper.futureAgreementLineItem = agreementLineItemsForRecord[i - 1];
                    } 
                    
                    if (cpl.Level_Filter__c == 'Item Level (Expand Sets and Subsets)' && classificationsToProducts.size() > 0){
                        if (agreementLineItem.zpl__LineLevel__c != null && agreementLineItem.zpl__LineLevel__r.Name == 'Set'){
                            String classification = agreementLineItem.Division__r.Division_Code__c + agreementLineItem.Class__c
                                + agreementLineItem.Brand__c + agreementLineItem.Set__c;
                            if (classificationsToProducts.containsKey(classification)) {
                                wrapper.childProducts = classificationsToProducts.get(classification);
                            }
                        }
                        
                        if (agreementLineItem.zpl__LineLevel__c != null && agreementLineItem.zpl__LineLevel__r.Name == 'Subset'){
                            String classification = agreementLineItem.Division__r.Division_Code__c + agreementLineItem.Class__c
                                + agreementLineItem.Brand__c + agreementLineItem.Set__c + agreementLineItem.Subset__c;
                            if (classificationsToProducts.containsKey(classification)) {
                                wrapper.childProducts = classificationsToProducts.get(classification);
                            }
                        }
                    }
                    system.debug('agreementLineItems size = '+agreementLineItems.size());
                    //limit to 50 for preview, backlog 3226
                    //if(agreementLineItems.size()<=50){
                        agreementLineItems.add(wrapper);
                    //}
                    
                    //system.debug('Adding: '+agreementLineItems);
                   // system.debug('cpl.Level_Filter__c: '+cpl.Level_Filter__c);
                    
                    break;
                //}else if(agreementLineItem.zpl__EffectiveDate__c > effectiveDate && agreementLineItem.zpl__EffectiveDate__c != System.today()){
                }else if(agreementLineItem.zpl__EffectiveDate__c > effectiveDate){
                    //system.debug('fdfdfd : '+cpl.Level_Filter__c);
                    //system.debug('Adding: '+agreementLineItem.zpl__EffectiveDate__c);
                    system.debug('agreementLineItems size = '+agreementLineItems.size());
                    //limit to 50 for preview, backlog 3226
                    if(agreementLineItems.size()<=50){
                        agreementLineItemFutureHolder.add(agreementLineItem);   
                    }
                    //System.debug('agreementLineItemFutureHolderssss ' + agreementLineItemFutureHolder);
                }
            }
        }
        
        //[START] Backlog Item 2810
        
        Map<String, List<zpl__ContractLineItem__c>> levelValuesToAgreementLineFutureOnly = GroupBy.strings('zpl__LevelValue__c', agreementLineNoDupes);        
        agreementLineNoDupes = null; //heap deallocation
        List<zpl__ContractLineItem__c> agreementLineItemFutureOnlyHolder = new List<zpl__ContractLineItem__c>(); //SP0524
        //system.debug('levelValuesToAgreementLineFutureOnly99999 : '+levelValuesToAgreementLineFutureOnly);
        
        for (String levelValue : levelValuesToAgreementLineFutureOnly.keySet()){
            List<zpl__ContractLineItem__c> agreementLineItemsForRecordFutureOnly = levelValuesToAgreementLineFutureOnly.get(levelValue);
            
            for (Integer i = 0; i < agreementLineItemsForRecordFutureOnly.size(); i++){
                zpl__ContractLineItem__c agreementLineItemFutureOnly = agreementLineItemsForRecordFutureOnly[i];
                AgreementLineItemWrapper wrapper = new AgreementLineItemWrapper();
                wrapper.currentAgreementLineItem = agreementLineItemFutureOnly;
                
               // if(agreementLineItemFutureOnly.zpl__EffectiveDate__c >= effectiveDate && agreementLineItemFutureOnly.zpl__EffectiveDate__c != System.today() && agreementLineItemFutureOnly.zpl__EffectiveDate__c > System.today()){
                 if(agreementLineItemFutureOnly.zpl__EffectiveDate__c >= effectiveDate){
                    //AgreementLineItemWrapper wrapper = new AgreementLineItemWrapper();
                    //wrapper.currentAgreementLineItem = agreementLineItemFutureOnly;
                    wrapper.futureAgreementLineItemOnly = agreementLineItemsForRecordFutureOnly[i]; 
                    //system.debug('futureAgreementLineItemOnly : '+wrapper.futureAgreementLineItemOnly);
                    
                }
                //limit to 50 for preview, backlog 3226
                //if(agreementLineItems.size()<=50){
                    agreementLineItems.add(wrapper);
                //}    
                    //system.debug('agreementLineItem444 : '+agreementLineItems);
                break;
                
            }
        }
        agreementLineNoDupes = null;
        //[END] Backlog Item 2810
       // return agreementLineItems;
        //below to be converted to javascript
        
        
        List<AgreementLineItemSortWrapper> sortWrappers = new List<AgreementLineItemSortWrapper>();
        for (AgreementLineItemWrapper agreementLineItem : agreementLineItems) {
            AgreementLineItemSortWrapper sortWrapper = new AgreementLineItemSortWrapper(agreementLineItem);
            sortWrappers.add(sortWrapper);
            //System.debug('sortWrappers' + sortWrappers);
        }
        sortWrappers.sort();
        
        List<AgreementLineItemWrapper> sortedLineItems = new List<AgreementLineItemWrapper>();
        for (AgreementLineItemSortWrapper sortWrapper : sortWrappers) {
            sortedLineItems.add(sortWrapper.agreementLineItem);
            //System.debug('sortedLineItems' + sortedLineItems);
        }
        return sortedLineItems;
        
        
    }
    
    public static List<AgreementLineItemWrapper> getAgreementLineItemsForDependentFieldValue(Customer_Price_List__c cpl, String cplField){
        Customer_Price_List__c cplCopy = cpl.clone(true, true, true, true);
        cplCopy.put(cplField, null);
        return getAgreementLineItemsFromCPL(cplCopy);
    }
    
    // private static Set<Id> getRelevantContractIds(Contract agreement, String regionalNationalFilter) {
    //  Set<Id> contractIds = new Set<Id>();
    
    //  Boolean regionalContractExists = agreement.zpl__ParentContract__c != null;
    //  Boolean nationalContractExists = regionalContractExists && agreement.zpl__ParentContract__r.zpl__ParentContract__c != null;
    
    //  contractIds.add(agreement.Id);
    
    //  if (regionalContractExists && regionalNationalFilter == 'Show Current and Chain Account Pricing') {
    //      contractIds.add(agreement.zpl__ParentContract__c);
    //  }
    
    //  if (nationalContractExists && regionalNationalFilter == 'Show National Agreement Lines (if any)') {
    //      contractIds.add(agreement.zpl__ParentContract__r.zpl__ParentContract__c);
    //  }
    
    //  if (regionalContractExists && nationalContractExists && regionalNationalFilter == 'Show Regional Chain AND National Agreement Lines (if any)') {
    //      contractIds.add(agreement.zpl__ParentContract__c);
    //      contractIds.add(agreement.zpl__ParentContract__r.zpl__ParentContract__c);
    //  }
    
    //  return contractIds;
    // }
    
    // private static Set<Id> getRelevantContractIds(Contract agreement,  String regionalNationalFilter, List<Id> regionalFilter) {
    public static Set<Id> getRelevantContractIds(Contract agreement,  String regionalNationalFilter, List<Id> regionalFilter) {
        Set<Id> contractIds = new Set<Id>();
        Boolean regionalContractExists = regionalFilter.size() > 0;
        contractIds.add(agreement.Id);
        
        
        if ((regionalContractExists && ( regionalNationalFilter == 'Show Current and Chain Account Pricing' || regionalNationalFilter == 'Show Regional Chain AND National Agreement Lines (if any)'))){
            for(Id regional : regionalFilter){              
                contractIds.add(regional);
            }
        }
        //KM - Chain Accounts filter
        else if(regionalContractExists && regionalNationalFilter == 'Show Chain Accounts Only'){
            contractIds = new Set<Id>();
            contractIds.addAll(regionalFilter);
        }
        
        //SP04042022
        //System.debug('regionalFilter aaa' + regionalFilter);
        //System.debug('regionalContractExists bbb' + regionalContractExists);
        
        
        return contractIds;
    }
    
    public class AgreementLineItemWrapper{
        @AuraEnabled
        public zpl__ContractLineItem__c currentAgreementLineItem;
        
        @AuraEnabled
        public zpl__ContractLineItem__c futureAgreementLineItem;
        
        @AuraEnabled //Backlog Item 2810
        public zpl__ContractLineItem__c futureAgreementLineItemOnly;
        
        //Used exclusively for Level Filter.
        @AuraEnabled
        public List<Product2> childProducts;
        
        @AuraEnabled
        public List<NationalAccountsPricing__c> nationalAccountPricing;
    }
    
    public class AgreementLineItemSortWrapper implements Comparable{
        public AgreementLineItemWrapper agreementLineItem;
        
        public AgreementLineItemSortWrapper(AgreementLineItemWrapper agreementLineItem) {
            this.agreementLineItem = agreementLineItem;
        }
        
        public Integer compareTo(Object other) {
            AgreementLineItemSortWrapper otherSort = (AgreementLineItemSortWrapper) other;
            /*if (agreementLineItem.currentAgreementLineItem.CPLSortField__c != null && otherSort.agreementLineItem.currentAgreementLineItem.CPLSortField__c != null
                && agreementLineItem.currentAgreementLineItem.CPLSortField__c != otherSort.agreementLineItem.currentAgreementLineItem.CPLSortField__c){
                    try{
                        Integer sort1 = Integer.valueOf(agreementLineItem.currentAgreementLineItem.CPLSortField__c);
                        Integer sort2 = Integer.valueOf(otherSort.agreementLineItem.currentAgreementLineItem.CPLSortField__c);
                        return sort1 - sort2;
                    }
                    catch(TypeException e){

                    }
                }else if (agreementLineItem.currentAgreementLineItem.CPLSortField__c != null && otherSort.agreementLineItem.currentAgreementLineItem.CPLSortField__c == null){
                    return -1;
                }else if (agreementLineItem.currentAgreementLineItem.CPLSortField__c == null && otherSort.agreementLineItem.currentAgreementLineItem.CPLSortField__c != null){
                    return 1;
                }
            
            Integer segmentComparison = compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'Segment__c');
            if(segmentComparison != 0){
                return segmentComparison;
            }
            
            Integer classComparison = compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'Class__c');
            if(classComparison != 0){
                return classComparison;
            }
            
            Integer brandComparison = compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'Brand__c');
            if(brandComparison != 0){
                return brandComparison;
            }
            
            Integer setComparison = compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'Set__c');
            if(setComparison != 0){
                return setComparison;
            }
            
            Integer subsetComparison = compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'Subset__c');
            if(subsetComparison != 0){
                return subsetComparison;
            }
            
            return compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'CustomerSKU__c');*/
            
            if ( agreementLineItem.currentAgreementLineItem.Level_Indicator__c < otherSort.agreementLineItem.currentAgreementLineItem.Level_Indicator__c){
                return 1;
            }else if (agreementLineItem.currentAgreementLineItem.Level_Indicator__c > otherSort.agreementLineItem.currentAgreementLineItem.Level_Indicator__c){
                return -1;
            } else {
                /*if (agreementLineItem.currentAgreementLineItem.CPLSortField__c != null && otherSort.agreementLineItem.currentAgreementLineItem.CPLSortField__c != null
                    && agreementLineItem.currentAgreementLineItem.CPLSortField__c != otherSort.agreementLineItem.currentAgreementLineItem.CPLSortField__c){
                        try{
                            Integer sort1 = Integer.valueOf(agreementLineItem.currentAgreementLineItem.CPLSortField__c);
                            Integer sort2 = Integer.valueOf(otherSort.agreementLineItem.currentAgreementLineItem.CPLSortField__c);
                            return sort1 - sort2;
                        }
                        catch(TypeException e){
                            
                        }
                    }else if (agreementLineItem.currentAgreementLineItem.CPLSortField__c != null && otherSort.agreementLineItem.currentAgreementLineItem.CPLSortField__c == null){
                        return -1;
                    }else if (agreementLineItem.currentAgreementLineItem.CPLSortField__c == null && otherSort.agreementLineItem.currentAgreementLineItem.CPLSortField__c != null){
                        return 1;
                    }*/
                
               Integer segmentComparison = compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'Segment__c');
                if(segmentComparison != 0){
                    return segmentComparison;
                }
                
                Integer classComparison = compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'Class__c');
                if(classComparison != 0){
                    return classComparison;
                }
                
                Integer brandComparison = compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'Brand__c');
                if(brandComparison != 0){
                    return brandComparison;
                }
                
                Integer setComparison = compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'Set__c');
                if(setComparison != 0){
                    return setComparison;
                }
                
                Integer subsetComparison = compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'Subset__c');
                if(subsetComparison != 0){
                    return subsetComparison;
                }
                return compareToWithNulls(agreementLineItem.currentAgreementLineItem, otherSort.agreementLineItem.currentAgreementLineItem, 'CustomerSKU__c');         
            } 
        }
    }
    
    private static Integer compareToWithNulls(zpl__ContractLineItem__c ali1, zpl__ContractLineItem__c ali2, String field) {
        if(ali1.get(field) == null && ali2.get(field) != null){
            return -1;
        }else if (ali1.get(field) != null && ali2.get(field) == null){
            return 1;
        }
        return 0;
    }
    
    public static List<zpl__ContractLineItem__c> getLineLevelAgreementLineItems(List<zpl__ContractLineItem__c> agreementLineItems, String lineLevel){
        List<zpl__ContractLineItem__c> lineLevelSubsetAgreementLineItems = new List<zpl__ContractLineItem__c>();
        
        for (zpl__ContractLineItem__c agreementLineItem : agreementLineItems) {
            if (agreementLineItem.zpl__LineLevel__c != null && agreementLineItem.zpl__LineLevel__r.Name == lineLevel) {
                lineLevelSubsetAgreementLineItems.add(agreementLineItem);
            }
        }
        return lineLevelSubsetAgreementLineItems;
    }
    
    public static List<NationalAccountsPricing__c> getNationalItems( String nationalAccGroupId, String SystemCode){
        return [Select Name, CustomerSKU__c, PricingType__c, Price__c, PriceUnit__c, Description__c, Brand__c, Class__c 
                from NationalAccountsPricing__c where NationalAccountGroupID__c  = :nationalAccGroupId
                and SystemCode__c =: SystemCode order by name];
    }
}
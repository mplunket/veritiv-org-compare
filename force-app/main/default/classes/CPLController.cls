public virtual class CPLController{
    public transient Customer_Price_List__c cplRecord {get; set;}
    public transient String recordType {get; set;}
    public transient List<Integer> regions {get; set;}
    public transient Set<String> cplDuplicateCheck;
    public transient list<String> cplheaders {get; set;}
    public transient List<CPL> cplByDivision {get; set;}
    public Set<String> setProdCodeCheck;
    public Date effectiveDateOverride;
    
    static String CPL_RECORDTYPE_EXTERNAL = 'External';
    static String CPL_RECORDTYPE_INTERNAL = 'Internal';
    
    static String CPL_REGIONALNATIONALFILTER_SHOW_NAL = 'Show National Agreement Lines (if any)';
    static String CPL_REGIONALNATIONALFILTER_SHOW_RC_NAL = 'Show Regional Chain AND National Agreement Lines (if any)';
    
    static String ZPL_POLICYTYPE_NAME_LISTDOWN = 'List Down';
    static String ZPL_POLICYTYPE_NAME_CWTFIXED = 'CWT Fixed';
    static String ZPL_POLICYTYPE_NAME_MAINTAINGTM = 'Maintain GTM';
    static String ZPL_POLICYTYPE_NAME_FIXEDPRICE = 'Fixed Price';
    
    static String ZPL_UOM_NAME_M = 'M';
    static String ZPL_UOM_NAME_CW = 'CW';
    
    static String ACCOUNT_VOSBUSINESSGROUP = 'SA';
    
    public String CPLType{
        get{
            if(CPLType == null){
                if (this.cplRecord.RecordType.Name == CPL_RECORDTYPE_EXTERNAL){
                    CPLType = CPL_RECORDTYPE_EXTERNAL;
                }else{
                    CPLType = CPL_RECORDTYPE_INTERNAL;
                }
            }
            return CPLType;
        }
        set;
    }

    public CPLController(){
        setProdCodeCheck = new set<String>();
        cplheaders= new list<String>();
        regions = new List<Integer> {1, 2, 3};
        cplDuplicateCheck = new set<string>();
        initializeCPLValues();
        
        if(CPLType == CPL_RECORDTYPE_EXTERNAL){
            createExternalCPL();            
        }else{
            createInternalCPL();
        }
        
        for(CPL tmp : cplByDivision){
            cplheaders = tmp.headers;
        }
    }
    
    public void initializeCPLValues(){
        Id cplId = ApexPages.currentPage().getParameters().get('id');
        //system.debug('test cplId: '+cplId);
        String sEffectiveDateOverride = ApexPages.currentPage().getParameters().get('effectiveDateOverride'); //effectiveDateOverride is populated thru CPLEmailBatch
        //system.debug('test sEffectiveDateOverride: '+sEffectiveDateOverride);
        //String test = cplId.getSobjectType().getDescribe().getName();
        if(sEffectiveDateOverride != null){
            this.effectiveDateOverride = Date.parse(sEffectiveDateOverride);
        }
        
        if(cplId != null){
            this.cplRecord = [SELECT Id, 
                                RecordTypeId, 
                                RecordType.Name, 
                                Effective_Date__c, 
                                Regional_National_Filter__c,
                                Purchased_Stocked_Filter__c, 
                                TXN_History__c, 
                                Level_Filter__c, 
                                New_Or_Changed_Only__c,
                                Division__c, 
                                Segments__c, 
                                Classes__c, 
                                Brands__c, 
                                Sales_Rep__c, 
                                Sales_Rep__r.Name,
                                Sales_Rep__r.Email,
                                Agreement__c,
                                Agreement__r.ContractNumber,
                                Agreement__r.Account.BillingCity,
                                Agreement__r.Account.RecordType.Name,
                                Agreement__r.Account.Name, 
                                Agreement__r.Account.AccountNumber,
                                Agreement__r.Account.Natl_Acct_Group_ID__c,
                                Agreement__r.Account.VOS_Business_Group__c,
                                Agreement__r.System__c
                            FROM Customer_Price_List__c
                            WHERE Id = :cplId limit 1];
        }else{
            Map<String, String> params = ApexPages.currentPage().getParameters();
            cplRecord = (Customer_Price_List__c)Customer_Price_List__c.sObjectType.newSObject(params.get('RecordTypeId'), true);
            recordType = Schema.SObjectType.Customer_Price_List__c.getRecordTypeInfosById().get(params.get('RecordTypeId')).getName();
            cplRecord.Agreement__c = params.get('Agreement__c');
            List<FieldSetMember> cplFields = Schema.SObjectType.Customer_Price_List__c.fieldSets.CPLView_Fields.getFields();
            
            for(FieldSetMember field : cplFields){
                if(params.containsKey(field.getFieldPath())){
                    if (field.getType() == Schema.DisplayType.Date){
                        cplRecord.put(field.getFieldPath(), Date.valueOf(params.get(field.getFieldPath())));
                    }else if (field.getType() == Schema.DisplayType.Boolean){
                        cplRecord.put(field.getFieldPath(), Boolean.valueOf(params.get(field.getFieldPath())));
                    }else{
                        cplRecord.put(field.getFieldPath(), params.get(field.getFieldPath()));
                    }
                }
            }
            
            cplRecord.RecordType = [SELECT Name FROM RecordType WHERE Id = :cplRecord.RecordTypeId limit 1];
            
            if(cplRecord.Sales_Rep__c != null){
                cplRecord.Sales_Rep__r = [SELECT Name, Email FROM User WHERE Id = :cplRecord.Sales_Rep__c];
            }
            
            cplRecord.Agreement__r = [SELECT ContractNumber, 
                                        AccountId, 
                                        Account.Name, 
                                        Account.AccountNumber, 
                                        Account.BillingCity,
                                        Account.RecordType.Name,
                                        Account.VOS_Business_Group__c, 
                                        Account.Natl_Acct_Group_ID__c, 
                                        System__c, Division__r.Name
                                    FROM Contract
                                    WHERE Id = :cplRecord.Agreement__c];
        }
    }
    
    public void createExternalCPL(){
        cplByDivision = new List<CPL>();
        transient list<Integer> listRowCount = new list<Integer>();
        transient Map<String, List<CPLServices.AgreementLineItemWrapper>> agreementLineItemsByDivision = CPLServices.getAgreementLineItemsFromCPLByDivision(cplRecord, CPLType, this.effectiveDateOverride);     
        map<String, ExternalCPLRow> mapRows = new map<String, ExternalCPLRow>();
        for(String division : agreementLineItemsByDivision.keySet()){
            CPL cpl = new ExternalCPL(); 
            cpl.isNationals = false;
            cpl.division = division;
            
            transient List<CPLServices.AgreementLineItemWrapper> agreementLineItems = agreementLineItemsByDivision.get(division);
            transient Map<String, Decimal> productUOMIdToConversionFactor = getProductUOMIdToConversionFactor(agreementLineItems);
            System.debug('agreementLineItems EXT ' + agreementLineItems);
            
            for(CPLServices.AgreementLineItemWrapper agreementLineItem : agreementLineItems){
                zpl__ContractLineItem__c currentAgreementLineItem = agreementLineItem.currentAgreementLineItem;
                zpl__ContractLineItem__c futureAgreementLineItem = agreementLineItem.futureAgreementLineItem;
                
                if(currentAgreementLineItem.Bracket1MinQty__c != null && currentAgreementLineItem.Bracket2MinQty__c != null && agreementLineItem.childProducts == null){
                    Integer currentBracket = 1;
                    Decimal currentBracketValue = currentAgreementLineItem.Bracket1Value__c;
                    Integer currentBracketMinQty = Integer.valueOf(currentAgreementLineItem.Bracket1MinQty__c);
                    //changed currentBracket <= 7 to currentBracket < 7 as there is no bracket 8 field
                   
                    while(currentBracketMinQty != null && currentBracketValue != null && currentBracket <= 7){
                        ExternalCPLRow cplRow = createExternalCPLRow(agreementLineItem, productUOMIdToConversionFactor, currentBracket);
                        String category = (agreementLineItem.currentAgreementLineItem.Class_Desc__c != null ? agreementLineItem.currentAgreementLineItem.Class_Desc__c : agreementLineItem.currentAgreementLineItem.Class__c) +
                            ' - ' + (agreementLineItem.currentAgreementLineItem.Brand_Desc__c != null ? agreementLineItem.currentAgreementLineItem.Brand_Desc__c : agreementLineItem.currentAgreementLineItem.Brand__c);
                        //' - ' + (!String.isEmpty(agreementLineItem.currentAgreementLineItem.Brand_Desc__c) ? agreementLineItem.currentAgreementLineItem.Brand_Desc__c : agreementLineItem.currentAgreementLineItem.Brand__c);

                        if(!isCategoryInCPLCategories(cpl, category)){
                            cpl.categories.add(category);
                        }
                        
                        if(cplRow != null){
                            if(cpl.rows.containsKey(category)){
                                cpl.rows.get(category).add(cplRow);
                            }else{
                                cpl.rows.put(category, new List<ExternalCPLRow>{cplRow});
                            }
                        }
                        
                        currentBracket++;
                        if(currentBracket <= 7){
                            currentBracketValue = (Decimal) currentAgreementLineItem.get('Bracket' + currentBracket + 'Value__c');
                            currentBracketMinQty = Integer.valueOf(currentAgreementLineItem.get('Bracket' + currentBracket + 'MinQty__c'));
                        }
                    }
                }
                else{
                    ExternalCPLRow cplRow = createExternalCPLRow(agreementLineItem, productUOMIdToConversionFactor);
                    String brandName = '';
                    
                    if(!String.isEmpty(agreementLineItem.currentAgreementLineItem.Brand_Desc__c)){
                        brandName = ' - ' + agreementLineItem.currentAgreementLineItem.Brand_Desc__c;
                    }else if(!String.isEmpty(agreementLineItem.currentAgreementLineItem.Brand__c)){
                        brandName = ' - ' + agreementLineItem.currentAgreementLineItem.Brand__c;
                    }            
                    
                    String category = (agreementLineItem.currentAgreementLineItem.Class_Desc__c != null ? agreementLineItem.currentAgreementLineItem.Class_Desc__c : agreementLineItem.currentAgreementLineItem.Class__c) + brandName ;
                    
                    if(!isCategoryInCPLCategories(cpl, category)){
                        cpl.categories.add(category);
                    }   
                    
                    if(cplRow != null){
                        if(cpl.rows.containsKey(category)){
                            cpl.rows.get(category).add(cplRow);
                        }else{
                            cpl.rows.put(category, new List<ExternalCPLRow>{cplRow});
                        }
                    }                    
                    
                    if(agreementLineItem.childProducts != null && agreementLineItem.childProducts.size() > 0){
                        for(Product2 childProduct : agreementLineItem.childProducts){
                            ExternalCPLRow productCPLRow = createExternalCPLRow(agreementLineItem, childProduct, productUOMIdTOConversionFactor);
                            if(productCPLRow != null){
                                cpl.rows.get(category).add(productCPLRow);
                            }
                        }
                    }/*else{
                    cpl.rows.remove(category);
                    }*/
                }
            }
            if(!cpl.rows.isEmpty()){
                cplByDivision.add(cpl);
            }
        }
        removeEmptyRows(cplByDivision);
        
        if(cplRecord.Regional_National_Filter__c == CPL_REGIONALNATIONALFILTER_SHOW_NAL || cplRecord.Regional_National_Filter__c == CPL_REGIONALNATIONALFILTER_SHOW_RC_NAL){            
            List<NationalAccountsPricing__c > nationalItems = CPLServices.getNationalItems(cplRecord.Agreement__r.Account.Natl_Acct_Group_ID__c, cplRecord.Agreement__r.System__c);            
            set<String> nationalProductsIds = new set<String>();
            
            for(NationalAccountsPricing__c nationalItem : nationalItems){
                nationalProductsIds.add(nationalItem.name);
            }           
            
        /*
        for(Product2  nP : [Select productCode, 
                                Name, 
                                Class_Description__c, 
                                Brand_Description__c, 
                                Class__c, 
                                Brand__c, 
                                System_id__c, 
                                isActive
                            FROM product2 
                            WHERE productCode in :nationalProductsIds and System_id__c = '03' And isActive = true Limit 50000]){  
                                Product2 nationalproduct = new Product2();
                                nationalproduct.name = nP.Name;
                                nationalproduct.Class_Description__c = np.Class_Description__c;
                                nationalproduct.Brand_Description__c = np.Brand_Description__c;
                                nationalproduct.Class__c = nP.Class__c;
                                nationalproduct.Brand__c = np.Brand__c;
                                mapNationalProducts.put(nP.productCode, nationalproduct);
        }
        */
            if(!cplByDivision.isEmpty()){
                for(CPL cpl : cplByDivision){
                    if(cplRecord.Regional_National_Filter__c == CPL_REGIONALNATIONALFILTER_SHOW_NAL){
                        cpl.rows.clear();
                        cpl.isNationals = true;
                    }
                    
                    for(NationalAccountsPricing__c nationalAcc : nationalItems){    
                        ExternalCPLRow cplRow = new ExternalCPLRow();
                        //nationalAcc.PricingType__c;
                        cplRow.ProductCode = nationalAcc.name;  
                        cplRow.CustomerSKU = nationalAcc.CustomerSKU__c; 
                        cplRow.CurrentPrice = nationalAcc.Price__c;   
                        cplRow.CustPriceUOM = nationalAcc.PriceUnit__c;
                        String className = '';
                        String brandName = '';
                        //className = 'Class: ' + nationalAcc.Class__c;
                        //brandName = ' Brand: ' + nationalAcc.Brand__c;
                        cplRow.ProductDescription = nationalAcc.Description__c;
                        /*
                        if(mapNationalProducts.containskey(cplRow.ProductCode)){
                        cplRow.ProductDescription = mapNationalProducts.get(cplRow.ProductCode).name;

                        if(!String.isEmpty(mapNationalProducts.get(cplRow.ProductCode).Class_Description__c)){
                            className = mapNationalProducts.get(cplRow.ProductCode).Class_Description__c;
                        }else if(!String.isEmpty(mapNationalProducts.get(cplRow.ProductCode).Class__c)){
                            className = mapNationalProducts.get(cplRow.ProductCode).Class__c;
                        }

                        if(!String.isEmpty(mapNationalProducts.get(cplRow.ProductCode).Brand_Description__c)){
                            brandName = ' - ' + mapNationalProducts.get(cplRow.ProductCode).Brand_Description__c;
                        }else if(!String.isEmpty(mapNationalProducts.get(cplRow.ProductCode).Brand__c)){
                            brandName = ' - ' + mapNationalProducts.get(cplRow.ProductCode).Brand__c;
                        }
            }else{
                mapNationalProducts.remove(cplRow.ProductCode);
            }
            */
                        String category = className + brandName;
                        /*
                        if(!isCategoryInCPLCategories(cpl, category)){
                            cpl.categories.add(category);
                        }

                        String category = 'NATIONAL AGREEMENT LINES' + cplRow.ProductCode;
                        */
                        
                        if(cpl.rows.containsKey(category)){
                            cpl.rows.get(category).add(cplRow);
                        }else{
                            cpl.rows.put(category, new List<ExternalCPLRow> {cplRow});
                        }
                    }
                    nationalItems.clear();
                }//end for(CPL cpl : cplByDivision){
            }else{
                CPL cpl = new ExternalCPL();
                cpl.isNationals = true;
                cpl.division = cplRecord.Agreement__r.Division__r.Name;
                
                if(cplRecord.Regional_National_Filter__c == CPL_REGIONALNATIONALFILTER_SHOW_NAL){
                    cpl.rows.clear();
                }
                
                for(NationalAccountsPricing__c nationalAcc : nationalItems){
                    ExternalCPLRow cplRow = new ExternalCPLRow();
                    cplRow.ProductCode = nationalAcc.name;
                    cplRow.CustomerSKU = nationalAcc.CustomerSKU__c;
                    cplRow.CurrentPrice = nationalAcc.Price__c;
                    cplRow.CustPriceUOM = nationalAcc.PriceUnit__c;
                    String className = '';
                    String brandName = '';
                    cplRow.ProductDescription = nationalAcc.Description__c;                    
                    String category = className + brandName;
                    
                    if(cpl.rows.containsKey(category)){
                        cpl.rows.get(category).add(cplRow);
                    }else{
                        cpl.rows.put(category, new List<ExternalCPLRow> { cplRow });
                    }
                }
                cplByDivision.add(cpl);              
            }//end else
        }
    }
    
    void removeEmptyRows(list<CPL> cplByDivision){        
        for(CPL cpltemp : cplByDivision){
            for(String cat : cpltemp.rows.keySet()){
                if(cpltemp.rows.get(cat).isEmpty()){   
                    cpltemp.rows.remove(cat);
                }
            }
        }
    }
    
    public ExternalCPLRow createExternalCPLRow(CPLServices.AgreementLineItemWrapper agreementLineItem, Map<String, Decimal> productUOMIdToConversionFactor){
        string prodCheck;
        boolean isduplicate, isMaintainMargin; 
        zpl__ContractLineItem__c currentAgreementLineItem = agreementLineItem.currentAgreementLineItem;
        zpl__ContractLineItem__c futureAgreementLineItem = agreementLineItem.futureAgreementLineItem;
        zpl__ContractLineItem__c futureAgreementLineItemOnly = agreementLineItem.futureAgreementLineItemOnly; //Backlog Item 2810 
        System.debug('currentAgreementLineItem0000 ' + currentAgreementLineItem);
        //System.debug('futureAgreementLineItem0000 ' + futureAgreementLineItem);
        //System.debug('futureAgreementLineItemOnly0000 ' + futureAgreementLineItemOnly);
        
        ExternalCPLRow cplRow = new ExternalCPLRow(); 
        cplRow.Cost = currentAgreementLineItem.PricingCost__c; 
        cplRow.PriceType = currentAgreementLineItem.zpl__PolicyType__r.Name;
        cplRow.ProductDescription = String.isNotBlank(currentAgreementLineItem.Customer_Description__c) ? 
                                        currentAgreementLineItem.Customer_Description__c : currentAgreementLineItem.Description__c;
        if(currentAgreementLineItem.zpl__Product__r.ProductCode!=null){
            //Product Code fix added SKU
            if(String.isBlank(currentAgreementLineItem.SKU__c)){
               cplRow.ProductCode = '';
            }
            else if(cplRow.ProductDescription != null && cplRow.ProductDescription.contains(currentAgreementLineItem.zpl__Product__r.ProductCode)){
                cplRow.ProductCode = currentAgreementLineItem.zpl__Product__r.ProductCode;
            }else if(currentAgreementLineItem.zpl__Product__r.ProductCode != null){
                cplRow.ProductCode = currentAgreementLineItem.zpl__Product__r.ProductCode;
            }else{
                cplRow.ProductCode = '';
            }
        }else{
            cplRow.ProductCode = '';
        }       
        /*
        if(cplRow.ProductDescription != null && cplRow.ProductDescription.contains(currentAgreementLineItem.zpl__Product__r.ProductCode)){
            cplRow.ProductCode = currentAgreementLineItem.zpl__Product__r.ProductCode;
        }else{
            cplRow.ProductCode = '';
        } 
        */   
        
        cplRow.CustomerSKU = currentAgreementLineItem.CustomerSKU__c;
        cplRow.CustomerCalcPrice = currentAgreementLineItem.CustomerCalculatedPrice__c;
        
        //02172023
        /*if(currentAgreementLineItem.CustomerUOM__c != null){
            cplRow.CustomerUOM = currentAgreementLineItem.CustomerUOM__c.toUpperCase();
        }*/
        
        cplRow.OrderQtyUOM = currentAgreementLineItem.Quantity_Break_UOM__c;
        cplRow.CurrentPrice = getPriceForAgreementLineItem(currentAgreementLineItem, productUOMIdToConversionFactor, null);
        cplRow.CustPriceUOM = currentAgreementLineItem.zpl__UOM__r.Name; //BL 2903 - 08/25/2021
        
        /*cplRow.EmptyColumn = getCWTSalesForAgreementLineItem(currentAgreementLineItem, null);
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM && currentAgreementLineItem.Net_Price__c > 0 && currentAgreementLineItem.Net_Price__c < 1){
            cplRow.EmptyColumn = currentAgreementLineItem.Net_Price__c;
        }
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED){
            cplRow.EmptyColumn = currentAgreementLineItem.zpl__PolicyValue__c;
        } Commented 28/10/2021 */
        
        //02/17/2023
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED){// && currentAgreementLineItem.zpl__UOM__r.Name == ZPL_UOM_NAME_CW){
            cplRow.EmptyColumn = (currentAgreementLineItem.zpl__PolicyValue__c).setScale(2);
        }
        
        // Changed to don't show value on CustPriceUOM when the record has CWT Pricing (cplRow.EmptyColumn), only to External CPL - 2019-11-07 - Eduardo Carvalho
        // Changed to don't show value when the field zpl__UOM__r.Name is 'M' 2019-11-26 - Eduardo Carvalho
        // Changed to don't show value when the field zpl__PolicyType__r.Name != ZPL_POLICYTYPE_NAME_CWTFIXED 2019-12-04 - Eduardo Carvalho
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED){
            cplRow.CurrentPrice = currentAgreementLineItem.Net_Price__c;  
        }else if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM && currentAgreementLineItem.Net_Price__c > 0){
            cplRow.CurrentPrice = currentAgreementLineItem.Net_Price__c;
        }else if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN && currentAgreementLineItem.Net_Price__c > 0){
            cplRow.CurrentPrice = currentAgreementLineItem.Net_Price__c;
        }else if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN && currentAgreementLineItem.Net_Price__c <= 0){
            cplRow.CurrentPrice = currentAgreementLineItem.zpl__PolicyValue__c;
        }else if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN && (currentAgreementLineItem.PricingCost__c == 0 || cplRow.CurrentPrice == 0)){
            cplRow.Percentage = 0.00;
            //cplRow.CurrentPrice = null;
            cplRow.CurrentPrice = currentAgreementLineItem.zpl__PolicyValue__c;
        }else if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN && currentAgreementLineItem.zpl__PolicyValue__c < 0){
            cplRow.Percentage = currentAgreementLineItem.zpl__PolicyValue__c;
        }
       
        //BL 2903 - 08/25/2021
        /*if(currentAgreementLineItem.zpl__PolicyType__r.Name != ZPL_POLICYTYPE_NAME_CWTFIXED){
            cplRow.CustPriceUOM = currentAgreementLineItem.zpl__UOM__r.Name;
        }else if(currentAgreementLineItem.zpl__UOM__r.Name != ZPL_UOM_NAME_M && cplRow.EmptyColumn == null){
            cplRow.CustPriceUOM = currentAgreementLineItem.zpl__UOM__r.Name;
        }*/

        //BL 2903 - 08/25/2021
        if(currentAgreementLineItem.zpl__UOM__r.Name != 'M' && cplRow.EmptyColumn == null){
            cplRow.CustPriceUOM = currentAgreementLineItem.zpl__UOM__r.Name;
        }
        
        if(futureAgreementLineItem != null){
            //cplRow.FuturePrice = getPriceForAgreementLineItem(futureAgreementLineItem, productUOMIdToConversionFactor, null);
            //cplRow.FuturePrice = futureAgreementLineItem.zpl__PolicyValue__c;
            //cplRow.FuturePrice = futureAgreementLineItem.Bracket1Price__c;
            cplRow.FuturePrice = futureAgreementLineItem.Net_Price__c;  
            cplRow.FuturePolicyValue = futureAgreementLineItem.zpl__PolicyValue__c; 
            cplRow.FutureEffDate = futureAgreementLineItem.zpl__EffectiveDate__c; 
            cplRow.FuturePriceUOM = futureAgreementLineItem.zpl__UOM__r.Name;
        }
        
        //KM: exclude rows with null/zero price
        if(cplRow.CurrentPrice == null || cplRow.CurrentPrice == 0){
            return null;
        }
        
        //[START] Backlog Item 2810        
        if(futureAgreementLineItemOnly != null){
            cplRow.FuturePrice = getPriceForAgreementLineItem(futureAgreementLineItemOnly, productUOMIdToConversionFactor, null);
            //cplRow.FuturePrice = futureAgreementLineItemOnly.zpl__PolicyValue__c;
            //cplRow.FuturePrice = futureAgreementLineItem.Bracket1Price__c;
            //cplRow.FuturePrice = futureAgreementLineItem.Net_Price__c;  //SP-02/04/2022
            //cplRow.FuturePolicyValue = futureAgreementLineItem.zpl__PolicyValue__c; //SP-02/04/2022
            cplRow.FutureEffDate = futureAgreementLineItemOnly.zpl__EffectiveDate__c;
            cplRow.FuturePriceUOM = futureAgreementLineItemOnly.zpl__UOM__r.Name;
            cplRow.CurrentPrice = null;
        }
        //[END] Backlog Item 2810
        
        if(String.isBlank(cplRow.ProductCode)){//has no product code
            prodCheck = cplRow.ProductDescription;//+cplRow.CurrentPrice;
        }else{
            prodcheck = cplRow.ProductCode;//+cplRow.CurrentPrice;
        }
        
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM){
            isMaintainMargin = checkMaintainMargin(agreementLineItem);//MaintainCPLCheck(currentAgreementLineItem.PricingCost__c, cplRow.ProductCode);
            isduplicate = DuplicateCPLCheck(prodcheck,cplRow.CurrentPrice, currentAgreementLineItem.PricingCost__c);
            
            //if((isMaintainMargin == true && isDuplicate == false) || futureAgreementLineItemOnly != null){
            if(isMaintainMargin == true && isDuplicate == false){// || futureAgreementLineItemOnly != null){
                return cplRow;
            }else{
                return null; 
            }
        }else{
            isduplicate = DuplicateCPLCheck(prodcheck,cplRow.CurrentPrice, currentAgreementLineItem.PricingCost__c);   
            if(isDuplicate == false){ //|| futureAgreementLineItemOnly != null){//BL - 2903
                return cplRow;
            }else{
                return null; //[Commented Out]Backlog Item 2810
                //return cplRow; //Backlog Item 2810
            }
        }
        
        /*
        if(cplDuplicateCheck.contains(prodcheck) == false 
            && cplRow.CurrentPrice > 0  
            && cplRow.CurrentPrice != currentAgreementLineItem.PricingCost__c 
            &&(currentAgreementLineItem.PricingCost__c != null 
            && String.isBlank(cplRow.ProductCode) == false)
        ){
            cplDuplicateCheck.add(prodcheck);
            return cplRow;
        }else{
            return null;
        }
        return cplRow;
        */
    }
    
    public ExternalCPLRow createExternalCPLRow(CPLServices.AgreementLineItemWrapper agreementLineItem, Map<String, Decimal> productUOMIdToConversionFactor, Integer bracket){
        zpl__ContractLineItem__c currentAgreementLineItem = agreementLineItem.currentAgreementLineItem;
        zpl__ContractLineItem__c futureAgreementLineItem = agreementLineItem.futureAgreementLineItem; 
        zpl__ContractLineItem__c futureAgreementLineItemOnly = agreementLineItem.futureAgreementLineItemOnly; //03212022
        System.debug('currentAgreementLineItem111 ' + currentAgreementLineItem);
        //System.debug('futureAgreementLineItem1111 ' + futureAgreementLineItem);
        //System.debug('futureAgreementLineItemOnly1111 ' + futureAgreementLineItemOnly);
        
        
        ExternalCPLRow cplRow = new ExternalCPLRow();  
        cplRow.Cost = currentAgreementLineItem.PricingCost__c; 
        cplRow.PriceType = currentAgreementLineItem.zpl__PolicyType__r.Name;
        cplRow.ProductDescription = String.isNotBlank(currentAgreementLineItem.Customer_Description__c) ? 
                                        currentAgreementLineItem.Customer_Description__c : currentAgreementLineItem.Description__c;
        if(currentAgreementLineItem.zpl__Product__r.ProductCode!=null){
            if(String.isBlank(currentAgreementLineItem.SKU__c)){
               cplRow.ProductCode = ''; 
            }
            else if(cplRow.ProductDescription != null && cplRow.ProductDescription.contains(currentAgreementLineItem.zpl__Product__r.ProductCode)){ 
                cplRow.ProductCode = currentAgreementLineItem.zpl__Product__r.ProductCode;
            }else{
                cplRow.ProductCode = '';
            }
        }else{
            cplRow.ProductCode = '';
        }
        /* 
        if(cplRow.ProductDescription != null && cplRow.ProductDescription.contains(currentAgreementLineItem.zpl__Product__r.ProductCode)){
            cplRow.ProductCode = currentAgreementLineItem.zpl__Product__r.ProductCode;
        }else{
            cplRow.ProductCode = '';
        }    
        */
        cplRow.CustomerSKU = currentAgreementLineItem.CustomerSKU__c;  
        cplRow.CustomerCalcPrice = currentAgreementLineItem.CustomerCalculatedPrice__c;
        
        //02172023
        /*if(currentAgreementLineItem.CustomerUOM__c != null){ 
            cplRow.CustomerUOM = currentAgreementLineItem.CustomerUOM__c.toUpperCase();
        }*/
        
        cplRow.QTYPriceBreak = ((Decimal) currentAgreementLineItem.get('Bracket' + bracket + 'MinQty__c')).setScale(2);
        cplRow.OrderQtyUOM = currentAgreementLineItem.Quantity_Break_UOM__c;  
        cplRow.CurrentPrice = getPriceForAgreementLineItem(currentAgreementLineItem, productUOMIdToConversionFactor, bracket);
        /*cplRow.EmptyColumn = getCWTSalesForAgreementLineItem(currentAgreementLineItem, bracket);
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM && currentAgreementLineItem.Net_Price__c > 0 && currentAgreementLineItem.Net_Price__c < 1){
            cplRow.EmptyColumn = currentAgreementLineItem.Net_Price__c;
        }
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED){
            cplRow.EmptyColumn = currentAgreementLineItem.zpl__PolicyValue__c;
        } Commented 28/10/2021 */
        
        //02/17/2023
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED){// && currentAgreementLineItem.zpl__UOM__r.Name == ZPL_UOM_NAME_CW){
            cplRow.EmptyColumn = (currentAgreementLineItem.zpl__PolicyValue__c).setScale(2);
            
            if(bracket != null){ //KM: QTY Break
                cplRow.EmptyColumn = ((Decimal) currentAgreementLineItem.get('Bracket' + bracket + 'Value__c')).setScale(2);
            }
        }
        
        cplRow.CustPriceUOM = currentAgreementLineItem.zpl__UOM__r.Name; //BL 2903 - 08/25/2021
        // Changed to don't show value on CustPriceUOM when the record has CWT Pricing (cplRow.EmptyColumn), only to External CPL - 2019-11-07 - Eduardo Carvalho
        // Changed to don't show value when the field zpl__UOM__r.Name is 'M' 2019-11-26 - Eduardo Carvalho
        // Changed to don't show value when the field zpl__PolicyType__r.Name !=  'CWT Fixed' 2019-12-04 - Eduardo Carvalho
        
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN && (currentAgreementLineItem.PricingCost__c == 0 || cplRow.CurrentPrice == 0)){
            cplRow.Percentage = 0.00;
            //cplRow.CurrentPrice = null;
            cplRow.CurrentPrice = currentAgreementLineItem.zpl__PolicyValue__c;
        }else if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN && currentAgreementLineItem.zpl__PolicyValue__c < 0){
            cplRow.Percentage = currentAgreementLineItem.zpl__PolicyValue__c;
        }
        
        //BL 2903 - 08/25/2021
        /*if(currentAgreementLineItem.zpl__PolicyType__r.Name != ZPL_POLICYTYPE_NAME_CWTFIXED){
            cplRow.CustPriceUOM = currentAgreementLineItem.zpl__UOM__r.Name ;
        }else if(currentAgreementLineItem.zpl__UOM__r.Name != ZPL_UOM_NAME_M && cplRow.EmptyColumn == null){
            cplRow.CustPriceUOM = currentAgreementLineItem.zpl__UOM__r.Name;
        }*/
        
        //BL 2903 - 08/25/2021
        if(currentAgreementLineItem.zpl__UOM__r.Name != 'M' && cplRow.EmptyColumn == null){
            cplRow.CustPriceUOM = currentAgreementLineItem.zpl__UOM__r.Name;
        }
        
        if(futureAgreementLineItem != null){
            //cplRow.FuturePrice = getPriceForAgreementLineItem(futureAgreementLineItem, productUOMIdToConversionFactor, bracket);
            //cplRow.FuturePrice = futureAgreementLineItem.zpl__PolicyValue__c;
            //cplRow.FuturePrice = futureAgreementLineItem.Bracket1Price__c;
            cplRow.FuturePrice = futureAgreementLineItem.Net_Price__c; 
            cplRow.FuturePolicyValue = futureAgreementLineItem.zpl__PolicyValue__c; 
            cplRow.FutureEffDate = futureAgreementLineItem.zpl__EffectiveDate__c; 
            cplRow.FuturePriceUOM = futureAgreementLineItem.zpl__UOM__r.Name;
        }
        
        //KM: exclude rows with null/zero price
        if(cplRow.CurrentPrice == null || cplRow.CurrentPrice == 0){
            return null;
        }
        
        //[START] Backlog Item 2810        
        if(futureAgreementLineItemOnly != null){
            cplRow.FuturePrice = getPriceForAgreementLineItem(futureAgreementLineItemOnly, productUOMIdToConversionFactor, null);
            //cplRow.FuturePrice = futureAgreementLineItemOnly.zpl__PolicyValue__c;
            //cplRow.FuturePrice = futureAgreementLineItem.Bracket1Price__c;
            //cplRow.FuturePrice = futureAgreementLineItem.Net_Price__c;  //SP-02/04/2022
            //cplRow.FuturePolicyValue = futureAgreementLineItem.zpl__PolicyValue__c; //SP-02/04/2022
            cplRow.FutureEffDate = futureAgreementLineItemOnly.zpl__EffectiveDate__c; 
            cplRow.FuturePriceUOM = futureAgreementLineItemOnly.zpl__UOM__r.Name; 
            cplRow.CurrentPrice = null;
        }
        //[END] Backlog Item 2810
        
        Boolean qtyBreakCheck = false; 
        if(bracket != null && (Decimal) currentAgreementLineItem.get('Bracket1MinQty__c') != null && (Decimal) currentAgreementLineItem.get('Bracket2MinQty__c') != null
           && (Decimal) currentAgreementLineItem.get('Bracket2MinQty__c') > 0){   qtyBreakCheck = true;
        }
        
        string prodCheck;
        if(String.isBlank(cplRow.ProductCode)){//has no product code
            prodCheck = cplRow.ProductDescription + (qtyBreakCheck ? String.valueOf(bracket) : '');//+cplRow.CurrentPrice;
        }else{
            prodcheck = cplRow.ProductCode + (qtyBreakCheck ? String.valueOf(bracket) : '');//cplRow.CurrentPrice;
        }        
        
        boolean isduplicate = false, isMaintainMargin;
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM){
            isMaintainMargin = checkMaintainMargin(agreementLineItem);//MaintainCPLCheck(currentAgreementLineItem.PricingCost__c, cplRow.ProductCode);
            isduplicate = DuplicateCPLCheck(prodcheck,cplRow.CurrentPrice, currentAgreementLineItem.PricingCost__c);
            /*
            if(setProdCodeCheck.contains(prodcheck)){
                isduplicate = DuplicateCPLCheck(prodcheck,cplRow.CurrentPrice, currentAgreementLineItem.PricingCost__c);
            }else{
                setProdCodeCheck.add(prodcheck);
            }
            */
            
            if(isMaintainMargin == true && isDuplicate == false){
                return cplRow;
            }else{
                return null; 
            }
        }else{
            isduplicate = DuplicateCPLCheck(prodcheck, cplRow.CurrentPrice, currentAgreementLineItem.PricingCost__c);
            /*
            if(setProdCodeCheck.contains(prodcheck)){
                isduplicate = DuplicateCPLCheck(prodcheck, cplRow.CurrentPrice, currentAgreementLineItem.PricingCost__c);
            }else{
                setProdCodeCheck.add(prodcheck);
            }*/
            
            if(isDuplicate == false){// || futureAgreementLineItemOnly != null){
                return cplRow;
            }else{                      
                return null; 
            }
        }
        /*    
        isduplicate = DuplicateCPLCheck(prodcheck,cplRow.CurrentPrice, currentAgreementLineItem.PricingCost__c);        
        isMaintainMargin = MaintainCPLCheck(currentAgreementLineItem.PricingCost__c, cplRow.ProductCode);
        if(isduplicate == false && isMaintainMargin == true){
            return cplRow;
        }else
        return null;    
        if(cplDuplicateCheck.contains(prodcheck) == false 
            && (cplRow.CurrentPrice > 0 
            ||  cplRow.CurrentPrice != null) 
            && cplRow.CurrentPrice != currentAgreementLineItem.PricingCost__c 
            &&(currentAgreementLineItem.PricingCost__c != null 
            && String.isBlank(cplRow.ProductCode) == false)
        ){
            cplDuplicateCheck.add(prodcheck);
            return cplRow;
        }else{
            return null;
        }
        */
    }
    
    private boolean checkMaintainMargin(CPLServices.AgreementLineItemWrapper agreementLineItem){
        //if(agreementLineItem.currentAgreementLineItem.SKU__c != null && agreementLineItem.currentAgreementLineItem.PricingCost__c != null){ //10/06/2021 - SP
        if(agreementLineItem.currentAgreementLineItem.PricingCost__c != null){
            return true;
        }else{
            return false;
        }
    }
    
    public ExternalCPLRow createExternalCPLRow(CPLServices.AgreementLineItemWrapper parent, Product2 product, Map<String, Decimal> productUOMIdToConversionFactor){
        string prodCheck;
        boolean isduplicate, isMaintainMargin;
        ExternalCPLRow cplRow = new ExternalCPLRow();  
        
        cplRow.Cost = getPriceForProduct(parent.currentAgreementLineItem, product, productUOMIdToConversionFactor,'Cost'); 
        
        /*28/01/2022 Disabled for Conversion computation to be included in Cost aswell.
        cplRow.Cost = parent.currentAgreementLineItem.PricingCost__c;  */
        cplRow.PriceType = parent.currentAgreementLineItem.zpl__PolicyType__r.Name; 
        cplRow.ProductDescription = product.Description;
        //cplRow.ProductCode = mustShowProductCode(cplRow.ProductDescription) ? product.ProductCode : ''; 
        // Commented on 19/11/2021 cplRow.ProductCode = cplRow.ProductDescription.contains(product.ProductCode) ? product.ProductCode : '';
        cplRow.ProductCode = product.ProductCode;
        cplRow.CurrentPrice = getPriceForProduct(parent.currentAgreementLineItem, product, productUOMIdToConversionFactor,'Customer Price'); //SP03182022
        //cplRow.CurrentPrice = getPriceForProduct(parent.currentAgreementLineItem, product, productUOMIdToConversionFactor, 'Current Price');     //SP03182022 -commented 08192022
        //cplRow.CurrentPrice = getPriceForProduct(parent.currentAgreementLineItem, product, productUOMIdToConversionFactor);  //SP03182022-re    
        //cplRow.CustPriceUOM = product.Pricing_Costing_UOM__c;
        /*cplRow.EmptyColumn = getCWTSalesForAgreementLineItem(parent.currentAgreementLineItem, null);
        if(parent.currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM && parent.currentAgreementLineItem.Net_Price__c > 0 && parent.currentAgreementLineItem.Net_Price__c < 1){
        cplRow.EmptyColumn = parent.currentAgreementLineItem.Net_Price__c;
        }
        if(parent.currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED){
        cplRow.EmptyColumn = parent.currentAgreementLineItem.zpl__PolicyValue__c;
        } Commented on 28/10/2021 */
        
        // 02/17/2023
        if(parent.currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED){// && parent.currentAgreementLineItem.zpl__UOM__r.Name == ZPL_UOM_NAME_CW){
            cplRow.EmptyColumn = (parent.currentAgreementLineItem.zpl__PolicyValue__c).setScale(2);
        }
        // Changed to don't show value on CustPriceUOM when the record has CWT Pricing (cplRow.EmptyColumn), only to External CPL - 2019-11-07 - Eduardo Carvalho
        // Changed to don't show value when the field product.Pricing_Costing_UOM__c is 'M' 2019-11-26 - Eduardo Carvalho
        // Changed to don't show value when the field zpl__PolicyType__r.Name !=  'CWT Fixed' 2019-12-04 - Eduardo Carvalho        
        cplRow.CustomerCalcPrice = parent.currentAgreementLineItem.CustomerCalculatedPrice__c;
        
        //02172023
        /*if(parent.currentAgreementLineItem.CustomerUOM__c != null){ 
            //cplRow.CustomerUOM = parent.currentAgreementLineItem.CustomerUOM__c.toUpperCase(); //SP08192022
        }*/
        
        if(parent.currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN && (parent.currentAgreementLineItem.PricingCost__c == 0 || cplRow.CurrentPrice == 0)){
            cplRow.Percentage = 0.00;
            //cplRow.CurrentPrice = null;
            cplRow.CurrentPrice = parent.currentAgreementLineItem.zpl__PolicyValue__c;
        }else if(parent.currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN && parent.currentAgreementLineItem.zpl__PolicyValue__c < 0){
            cplRow.Percentage = parent.currentAgreementLineItem.zpl__PolicyValue__c;
        }        
        
        /*if(parent.currentAgreementLineItem.zpl__PolicyType__r.Name != ZPL_POLICYTYPE_NAME_CWTFIXED){
        cplRow.CustPriceUOM = product.Pricing_Costing_UOM__c;
        }else if(product.Pricing_Costing_UOM__c != 'M' && cplRow.EmptyColumn == null){
        cplRow.CustPriceUOM = product.Pricing_Costing_UOM__c;
        } commented 20-11-2021*/
        cplRow.CustPriceUOM = parent.currentAgreementLineItem.PricingUOM__c;
        
        //KM: exclude rows with null price
        if(cplRow.CurrentPrice == null){             
            return null;
        }
        
        if(String.isBlank(cplRow.ProductCode)){//has no product code
            prodCheck = cplRow.ProductDescription;
        }else{
            prodcheck = cplRow.ProductCode;
        }
        
        isduplicate = DuplicateCPLCheck(prodcheck, cplRow.CurrentPrice, parent.currentAgreementLineItem.PricingCost__c);
        
        if(isduplicate == false){
            return cplRow;
        }else
            return null;
        
        //KM: exclude rows with null/zero price
        /*if(cplRow.CurrentPrice == null){//} || cplRow.CurrentPrice == 0){ //commented out 08102022
         //if(cplRow.CurrentPrice == null || cplRow.CurrentPrice == 0){
            return null;
        }
        
        if(String.isBlank(cplRow.ProductCode)){//has no product code 
            prodCheck = cplRow.ProductDescription;//+cplRow.CurrentPrice;
        }else{
            prodcheck = cplRow.ProductCode;//+cplRow.CurrentPrice;
        }
        
        if(parent.currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM){
            isMaintainMargin = checkMaintainMargin(parent);//MaintainCPLCheck(currentAgreementLineItem.PricingCost__c, cplRow.ProductCode);
            isduplicate = DuplicateCPLCheck(prodcheck,cplRow.CurrentPrice, parent.currentAgreementLineItem.PricingCost__c);
            
            if(isMaintainMargin == true && isDuplicate == false){
                return cplRow;
            }else{
                return null; 
            }
        }else{
            isduplicate = DuplicateCPLCheck(prodcheck, cplRow.CurrentPrice, parent.currentAgreementLineItem.PricingCost__c);
            
            if(isDuplicate == false){    
                return cplRow;
            }else{
                return null;
            }
        }*/
        /*
        if(cplDuplicateCheck.contains(prodcheck) == false 
        && cplRow.CurrentPrice > 0 
        && cplRow.CurrentPrice != parent.currentAgreementLineItem.PricingCost__c 
        &&(parent.currentAgreementLineItem.PricingCost__c != null 
        && String.isBlank(cplRow.ProductCode) == false)
        ){
        cplDuplicateCheck.add(prodcheck);
        return cplRow;
        }else{
        return null;
        }
        return cplRow;
        */
    }
    
    public void createInternalCPL(){
        cplByDivision = new List<CPL>();       
        Map<String, List<CPLServices.AgreementLineItemWrapper>> agreementLineItemsByDivision = CPLServices.getAgreementLineItemsFromCPLByDivision(cplRecord, CPLType, this.effectiveDateOverride);
        
        for(String division : agreementLineItemsByDivision.keySet()){
            CPL cpl = new InternalCPL(); 
            cpl.isNationals = false; 
            cpl.division = division;
            
            List<CPLServices.AgreementLineItemWrapper> agreementLineItems = agreementLineItemsByDivision.get(division);
            Map<String, Decimal> productUOMIdToConversionFactor = getProductUOMIdToConversionFactor(agreementLineItems);
            
            for(CPLServices.AgreementLineItemWrapper agreementLineItem : agreementLineItems){
                zpl__ContractLineItem__c currentAgreementLineItem = agreementLineItem.currentAgreementLineItem;
                zpl__ContractLineItem__c futureAgreementLineItem = agreementLineItem.futureAgreementLineItem;
                
                if(currentAgreementLineItem.Bracket1MinQty__c != null && currentAgreementLineItem.Bracket2MinQty__c != null && agreementLineItem.childProducts == null){
                    Integer currentBracket = 1;
                    Decimal currentBracketValue = currentAgreementLineItem.Bracket1Value__c; 
                    Integer currentBracketMinQty = Integer.valueOf(currentAgreementLineItem.Bracket1MinQty__c);
                    //changed currentBracket <= 7 to currentBracket < 7 as there is no bracket 8 field
                    
                    while(currentBracketMinQty != null && currentBracketValue != null && currentBracket <= 7){
                        InternalCPLRow cplRow = createInternalCPLRow(agreementLineItem, productUOMIdToConversionFactor, currentBracket);
                        String category = (agreementLineItem.currentAgreementLineItem.Class_Desc__c != null ? agreementLineItem.currentAgreementLineItem.Class_Desc__c : agreementLineItem.currentAgreementLineItem.Class__c) +
                            ' - ' + (agreementLineItem.currentAgreementLineItem.Brand_Desc__c != null ? agreementLineItem.currentAgreementLineItem.Brand_Desc__c : agreementLineItem.currentAgreementLineItem.Brand__c);
                        //    ' - ' + (agreementLineItem.currentAgreementLineItem.Brand_Desc__c != null ? agreementLineItem.currentAgreementLineItem.Brand_Desc__c : agreementLineItem.currentAgreementLineItem.Brand__c);
                        
                        if(!isCategoryInCPLCategories(cpl, category)){ 
                            cpl.categories.add(category);
                        }
                        
                        if(cplRow != null){ 
                            if(currentBracket == 1 || (currentBracket > 1 && currentBracketValue > 0)){
                                if(cpl.rows.containsKey(category)){
                                    cpl.rows.get(category).add(cplRow);
                                }else{
                                    cpl.rows.put(category, new List<InternalCPLRow> { cplRow });
                                }
                            }
                        }
                        
                        currentBracket++;
                        if(currentBracket <= 7){
                            currentBracketValue = (Decimal) currentAgreementLineItem.get('Bracket' + currentBracket + 'Value__c');
                            currentBracketMinQty = Integer.valueOf(currentAgreementLineItem.get('Bracket' + currentBracket + 'MinQty__c'));
                        }
                        
                    }
                }else{
                    InternalCPLRow cplRow = createInternalCPLRow(agreementLineItem, productUOMIdToConversionFactor);
                    String category = (agreementLineItem.currentAgreementLineItem.Class_Desc__c != null ? agreementLineItem.currentAgreementLineItem.Class_Desc__c : agreementLineItem.currentAgreementLineItem.Class__c) +
                        ' - ' + (agreementLineItem.currentAgreementLineItem.Brand_Desc__c != null ? agreementLineItem.currentAgreementLineItem.Brand_Desc__c : agreementLineItem.currentAgreementLineItem.Brand__c);
                    
                    //System.debug('Level Indicator else' + agreementLineItem.currentAgreementLineItem.Level_Indicator__c); //SP03182022
                    
                    if(!isCategoryInCPLCategories(cpl, category)){ 
                        cpl.categories.add(category);
                    }
                    
                    
                    if(cplRow != null){      
                            if (
                                cpl.rows.containsKey(category)) { cpl.rows.get(category).add(cplRow);
                            }else{
                                cpl.rows.put(category, new List<InternalCPLRow> { cplRow });
                            }                       
                    }
                        
                    if(agreementLineItem.childProducts != null && agreementLineItem.childProducts.size() > 0){
                        for(Product2 childProduct : agreementLineItem.childProducts){
                            InternalCPLRow productCPLRow = createInternalCPLRow(agreementLineItem, childProduct, productUOMIdTOConversionFactor);
                            if(productCPLRow!=null ){ 
                                System.debug('productCPLRow  ' + currentAgreementLineItem.id);
                                cpl.rows.get(category).add(productCPLRow);
                                
                            }
                        }
                    }
                }
            }
            if(!cpl.rows.isEmpty()){ 
                cplByDivision.add(cpl);
            }
        }
        removeEmptyRows(cplByDivision);
        
        //copied from external to have national lines available to internal
        transient  Map<String,Product2> mapNationalProducts = new Map<String,Product2>();
        
        if(cplRecord.Regional_National_Filter__c == CPL_REGIONALNATIONALFILTER_SHOW_NAL || cplRecord.Regional_National_Filter__c == CPL_REGIONALNATIONALFILTER_SHOW_RC_NAL){
            List<NationalAccountsPricing__c > nationalItems = CPLServices.getNationalItems(cplRecord.Agreement__r.Account.Natl_Acct_Group_ID__c, cplRecord.Agreement__r.System__c);
            List<String> nationalProductsIds = new List<String>();
            
            for(NationalAccountsPricing__c nationalItem : nationalItems){ 
                nationalProductsIds.add(nationalItem.name);
            }
            
            // get all national products to show the description
            /*
for(aggregateResult nP : [Select productCode, Name, Class_Description__c, Brand_Description__c, Class__c, Brand__c   
from product2 where productCode in :nationalProductsIds 
group by productCode, Name, Class_Description__c, Brand_Description__c, Class__c, Brand__c limit 5000 ]){

Product2 nationalproduct = new Product2();
nationalproduct.name = nP.get('Name');
nationalproduct.Class_Description__c = (String) nP.get('Class_Description__c');
nationalproduct.Brand_Description__c = (String) np.get('Brand_Description__c');
nationalproduct.Class__c = (String) nP.get('Class__c');
nationalproduct.Brand__c = (String) np.get('Brand__c');

mapNationalProducts.put((String) nP.get('productCode'), nationalproduct);
*/
            /*   
for(Product2  nP : [Select productCode, Name, Class_Description__c, Brand_Description__c, Class__c, Brand__c   
from product2 where productCode in :nationalProductsIds and System_id__c  = '03']){  
Product2 nationalproduct = new Product2();
nationalproduct.name = nP.Name;
nationalproduct.Class_Description__c = np.Class_Description__c;
nationalproduct.Brand_Description__c = np.Brand_Description__c;
nationalproduct.Class__c = nP.Class__c;
nationalproduct.Brand__c = np.Brand__c;

mapNationalProducts.put(nP.productCode, nationalproduct);
}*/
            if(!cplByDivision.isEmpty()){
                for(CPL cpl : cplByDivision){
                    if(cplRecord.Regional_National_Filter__c == CPL_REGIONALNATIONALFILTER_SHOW_NAL){
                        cpl.rows.clear(); 
                        cpl.isNationals = true;
                    }
                    
                    for(NationalAccountsPricing__c nationalAcc : nationalItems){
                        InternalCPLRow cplRow = new InternalCPLRow();
                        cplRow.ProductCode = nationalAcc.name; 
                        cplRow.CustomerSKU = nationalAcc.CustomerSKU__c; 
                        cplRow.CurrentPrice = nationalAcc.Price__c; 
                        cplRow.CustPriceUOM = nationalAcc.PriceUnit__c;
                        String className = ''; 
                        String brandName = ''; 
                        cplRow.ProductDescription = nationalAcc.Description__c;
                        /*
if (mapNationalProducts.containskey(cplRow.ProductCode)){

cplRow.ProductDescription = mapNationalProducts.get(cplRow.ProductCode).name;

if (!String.isEmpty(mapNationalProducts.get(cplRow.ProductCode).Class_Description__c)){
className = mapNationalProducts.get(cplRow.ProductCode).Class_Description__c;
}
else if(!String.isEmpty(mapNationalProducts.get(cplRow.ProductCode).Class__c)){
className = mapNationalProducts.get(cplRow.ProductCode).Class__c;
}

if (!String.isEmpty(mapNationalProducts.get(cplRow.ProductCode).Brand_Description__c)){
brandName = ' - ' + mapNationalProducts.get(cplRow.ProductCode).Brand_Description__c;
}
else if(!String.isEmpty(mapNationalProducts.get(cplRow.ProductCode).Brand__c)){
brandName = ' - ' + mapNationalProducts.get(cplRow.ProductCode).Brand__c;
}
}*/
                        String category = className + brandName;
                        // if (!isCategoryInCPLCategories(cpl, category)) {
                        //     cpl.categories.add(category);
                        // }
                        
                        //String category = 'NATIONAL AGREEMENT LINES' + cplRow.ProductCode;
                        
                        if(cpl.rows.containsKey(category)){
                            cpl.rows.get(category).add(cplRow);
                        }else{
                            cpl.rows.put(category, new List<InternalCPLRow>{cplRow});
                        }
                    }
                }
            }else{
                CPL cpl = new InternalCPL();
                cpl.isNationals = true;
                cpl.division = cplRecord.Agreement__r.Division__r.Name;
                
                if(cplRecord.Regional_National_Filter__c == CPL_REGIONALNATIONALFILTER_SHOW_NAL){
                    cpl.rows.clear();
                }
                
                for(NationalAccountsPricing__c nationalAcc : nationalItems){
                    InternalCPLRow cplRow = new InternalCPLRow();
                    cplRow.ProductCode = nationalAcc.name;
                    cplRow.CustomerSKU = nationalAcc.CustomerSKU__c;
                    cplRow.CurrentPrice = nationalAcc.Price__c;
                    cplRow.CustPriceUOM = nationalAcc.PriceUnit__c;
                    String className = '';
                    String brandName = '';
                    cplRow.ProductDescription = nationalAcc.Description__c;
                    
                    String category = className + brandName;
                    if(cpl.rows.containsKey(category)){
                        cpl.rows.get(category).add(cplRow);
                    }else{
                        cpl.rows.put(category, new List<InternalCPLRow> { cplRow });
                    }
                }
                cplByDivision.add(cpl);                
            }//end else
        }
    }
    
    public InternalCPLRow createInternalCPLRow(CPLServices.AgreementLineItemWrapper agreementLineItem, Map<String, Decimal> productUOMIdToConversionFactor, Integer bracket){
        zpl__ContractLineItem__c currentAgreementLineItem = agreementLineItem.currentAgreementLineItem;
        zpl__ContractLineItem__c futureAgreementLineItem = agreementLineItem.futureAgreementLineItem;
        zpl__ContractLineItem__c futureAgreementLineItemOnly = agreementLineItem.futureAgreementLineItemOnly; //SP 02022022
        //System.debug('Internal currentAgreementLineItem777 ' + currentAgreementLineItem);
        //System.debug('Internal futureAgreementLineItem777 ' + futureAgreementLineItem);
        //System.debug('Internal futureAgreementLineItemOnly777 ' + futureAgreementLineItemOnly);
        
        InternalCPLRow cplRow = new InternalCPLRow();
        if(String.isBlank(currentAgreementLineItem.SKU__c)){
             cplRow.ProductCode = '';
        }else{
            cplRow.ProductCode = currentAgreementLineItem.zpl__Product__r.ProductCode;
        }
        cplRow.CustomerSKU = currentAgreementLineItem.CustomerSKU__c;
        //System.debug('CustomerSKU aaaaa ' + cplRow.CustomerSKU);
        
        //cplRow.ProductDescription = String.isNotBlank(currentAgreementLineItem.Description__c) ? 
        //    currentAgreementLineItem.Description__c : currentAgreementLineItem.zpl__Product__r.Description;
        
        cplRow.ProductDescription = String.isNotBlank(currentAgreementLineItem.Customer_Description__c) ? 
            currentAgreementLineItem.Customer_Description__c : currentAgreementLineItem.Description__c;
        
        cplRow.QTYPriceBreak = ((Decimal) currentAgreementLineItem.get('Bracket' + bracket + 'MinQty__c')).setScale(2);
        cplRow.CurrentPrice = getPriceForAgreementLineItem(currentAgreementLineItem, productUOMIdToConversionFactor, bracket);
        
        //SP 06/08/2022 BL3177
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM && currentAgreementLineItem.PricingCost__c == 0){
            cplRow.CurrentPrice = currentAgreementLineItem.Net_Price__c/100;
        }
        
        cplRow.CustPriceUOM = currentAgreementLineItem.zpl__UOM__r.Name;
        if(currentAgreementLineItem.zpl__Contract__r.Account.RecordType.Name != 'Chain Account'){
            cplRow.Division = currentAgreementLineItem.Division__r.Division_Code__c + '-' + currentAgreementLineItem.Division__r.Name;
        }
        cplRow.Segment = currentAgreementLineItem.Segment__c;
        cplRow.CPLClass = currentAgreementLineItem.Class_Desc__c != null ? currentAgreementLineItem.Class_Desc__c : currentAgreementLineItem.Class__c;
        cplRow.Brand = currentAgreementLineItem.Brand_Desc__c != null ? currentAgreementLineItem.Brand_Desc__c : currentAgreementLineItem.Brand__c;
        cplRow.CPLSet = currentAgreementLineItem.Set_Desc__c != null ? currentAgreementLineItem.Set_Desc__c : currentAgreementLineItem.Set__c;
        cplRow.Subset = currentAgreementLineItem.Subset_Desc__c != null ? currentAgreementLineItem.Subset_Desc__c : currentAgreementLineItem.Subset__c;
        cplRow.Vendor = currentAgreementLineItem.AIQdt_Vendor__c; //cplRow.Vendor = currentAgreementLineItem.VendorCode__c;
        cplRow.Cost = currentAgreementLineItem.PricingCost__c;
        
        //cplRow.GTM = currentAgreementLineItem.aiq_GTM__c;
        //cplRow.GTM = currentAgreementLineItem.GTM__c;
        if(currentAgreementLineItem.Net_Price__c != null && currentAgreementLineItem.Net_Price__c > 0 &&  currentAgreementLineItem.PricingCost__c != null) {
            cplRow.GTM = (currentAgreementLineItem.Net_Price__c -  currentAgreementLineItem.PricingCost__c) / currentAgreementLineItem.Net_Price__c;
        }
        
        cplRow.PriceType = currentAgreementLineItem.zpl__PolicyType__r.Name;         
        cplRow.PolicyValue = currentAgreementLineItem.zpl__PolicyValue__c;
        cplRow.Rebate = currentAgreementLineItem.InternalCostDeviation__c > 0 || currentAgreementLineItem.ExternalCostDeviation__c > 0 ? 'Y' : '';      
        cplRow.RebateExpirationDate = currentAgreementLineItem.InternalCostDeviation__c > 0 ? currentAgreementLineItem.InternalCostDeviationDate__c : (currentAgreementLineItem.ExternalCostDeviation__c > 0 ? currentAgreementLineItem.ExternalCostDeviationDate__c : null);              
        cplRow.BeginDate = currentAgreementLineItem.zpl__EffectiveDate__c;
        /* cplRow.CWTPrice = getCWTSalesForAgreementLineItem(currentAgreementLineItem, bracket);
        //cplRow.CWTPrice = currentAgreementLineItem.Net_Price__c;
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM && currentAgreementLineItem.Net_Price__c > 0 && currentAgreementLineItem.Net_Price__c < 1){
            cplRow.CWTPrice = currentAgreementLineItem.Net_Price__c;
        }
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED){
            cplRow.CWTPrice = (currentAgreementLineItem.zpl__PolicyValue__c).setScale(4);
        } Commented on 28/10/2021 */ 
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED && currentAgreementLineItem.zpl__UOM__r.Name == ZPL_UOM_NAME_CW){
            cplRow.CWTPrice = (currentAgreementLineItem.zpl__PolicyValue__c).setScale(2);
            
            if(bracket != null){ //KM: QTY Break                 cplRow.CWTPrice = (Decimal) currentAgreementLineItem.get('Bracket' + bracket + 'Value__c');
            }
        }
        
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN && (currentAgreementLineItem.PricingCost__c == 0 || cplRow.CurrentPrice == 0)){
            cplRow.CurrentPrice = currentAgreementLineItem.zpl__PolicyValue__c;
        }
                
        cplRow.TwelveMonthSales = currentAgreementLineItem.X12MonthSalesVolume__c;
        
        if (futureAgreementLineItem != null) {
            //cplRow.FuturePrice = getPriceForAgreementLineItem(futureAgreementLineItem, productUOMIdToConversionFactor, bracket);
            //cplRow.FuturePrice = futureAgreementLineItem.zpl__PolicyValue__c;
            //cplRow.FuturePrice = futureAgreementLineItem.Bracket1Price__c;
            cplRow.FuturePrice = futureAgreementLineItem.Net_Price__c;      
            cplRow.FuturePolicyValue = futureAgreementLineItem.zpl__PolicyValue__c;             
            cplRow.FutureEffDate = futureAgreementLineItem.zpl__EffectiveDate__c;             
            cplRow.FutureCost = futureAgreementLineItem.PricingCost__c;             
            cplRow.FutureGTM = futureAgreementLineItem.aiq_GTM__c/100;
        }
        
        //KM: exclude rows with null price
        if(cplRow.CurrentPrice == null){             
            return null;
        }
        
        //[START] 02042022        
       if (futureAgreementLineItemOnly != null) {
           cplRow.FuturePrice = getPriceForAgreementLineItem(futureAgreementLineItemOnly, productUOMIdToConversionFactor, bracket);    
           cplRow.FuturePolicyValue = futureAgreementLineItemOnly.zpl__PolicyValue__c;  //SP-05182022   
           cplRow.FutureEffDate = futureAgreementLineItemOnly.zpl__EffectiveDate__c;             
           cplRow.FutureCost = futureAgreementLineItemOnly.PricingCost__c;            
           cplRow.FutureGTM = futureAgreementLineItemOnly.aiq_GTM__c/100;
           cplRow.CurrentPrice = null;
           cplRow.CustPriceUOM = null;           
           //cplRow.Cost = null;
           cplRow.GTM = null;
           cplRow.BeginDate = null;
        }
        //[END] 02042022

        Boolean qtyBreakCheck = false; 
        if(bracket != null && (Decimal) currentAgreementLineItem.get('Bracket1MinQty__c') != null && 
           (Decimal) currentAgreementLineItem.get('Bracket2MinQty__c') != null && 
           (Decimal) currentAgreementLineItem.get('Bracket2MinQty__c') > 0){             
               qtyBreakCheck = true;
        }
        
        string prodCheck;
        if(String.isBlank(cplRow.ProductCode)){//has no product code
            prodCheck = cplRow.ProductDescription + (qtyBreakCheck ? String.valueOf(bracket) : '');
        }else{
            prodcheck = cplRow.ProductCode + (qtyBreakCheck ? String.valueOf(bracket) : '');
        }
        
        boolean isduplicate;
        isduplicate = InternalDuplicateCPLCheck(prodcheck, cplRow.CurrentPrice, currentAgreementLineItem.PricingCost__c);
        
        if (isduplicate == false){             
            return cplRow;
        }else
            return null; 
        /*
if(cplDuplicateCheck.contains(prodcheck)==false && cplRow.CurrentPrice>0 && cplRow.CurrentPrice!= cplrow.Cost){
cplDuplicateCheck.add(prodcheck);
return cplRow;
}else{
return null;

}
*/
        //return cplRow;
    }
    
    //Individual 10735680 - CPL Individual enter
    public InternalCPLRow createInternalCPLRow(CPLServices.AgreementLineItemWrapper agreementLineItem, Map<String, Decimal> productUOMIdToConversionFactor){
        string prodCheck;
        //boolean isduplicate, isMaintainMargin; 
        zpl__ContractLineItem__c currentAgreementLineItem = agreementLineItem.currentAgreementLineItem;         
        zpl__ContractLineItem__c futureAgreementLineItem = agreementLineItem.futureAgreementLineItem;
        zpl__ContractLineItem__c futureAgreementLineItemOnly = agreementLineItem.futureAgreementLineItemOnly; //02042022
        //System.debug('Internal currentAgreementLineItem888 ' + currentAgreementLineItem);
        //System.debug('Internal futureAgreementLineItem888 ' + futureAgreementLineItem);
        //System.debug('Internal futureAgreementLineItemOnly888 ' + futureAgreementLineItemOnly);
        
        InternalCPLRow cplRow = new InternalCPLRow();
        
        if(String.isBlank(currentAgreementLineItem.SKU__c)){              
            cplRow.ProductCode = '';
        }else{
            cplRow.ProductCode = currentAgreementLineItem.zpl__Product__r.ProductCode;
        }
        
        cplRow.CustomerSKU = currentAgreementLineItem.CustomerSKU__c;        
        //System.debug('CustomerSKU qqqq ' + cplRow.CustomerSKU );
        
        //cplRow.ProductDescription = String.isNotBlank(currentAgreementLineItem.Description__c) ? 
        //    currentAgreementLineItem.Description__c : currentAgreementLineItem.zpl__Product__r.Description;
        
        cplRow.ProductDescription = String.isNotBlank(currentAgreementLineItem.Customer_Description__c) ? 
            currentAgreementLineItem.Customer_Description__c : currentAgreementLineItem.Description__c;
        
        cplRow.CurrentPrice = getPriceForAgreementLineItem(currentAgreementLineItem, productUOMIdToConversionFactor, null);
        
        //SP 06/08/2022 BL3177
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM && currentAgreementLineItem.PricingCost__c == 0){
            cplRow.CurrentPrice = currentAgreementLineItem.Net_Price__c/100;
        }
        
        cplRow.CustPriceUOM = currentAgreementLineItem.zpl__UOM__r.Name;
        if(currentAgreementLineItem.zpl__Contract__r.Account.RecordType.Name != 'Chain Account'){
            cplRow.Division = currentAgreementLineItem.Division__r.Division_Code__c + '-' + currentAgreementLineItem.Division__r.Name;
        }
        cplRow.Segment = currentAgreementLineItem.Segment__c;
        cplRow.CPLClass = currentAgreementLineItem.Class_Desc__c != null ? currentAgreementLineItem.Class_Desc__c : currentAgreementLineItem.Class__c;
        cplRow.Brand = currentAgreementLineItem.Brand_Desc__c != null ? currentAgreementLineItem.Brand_Desc__c : currentAgreementLineItem.Brand__c;
        cplRow.CPLSet = currentAgreementLineItem.Set_Desc__c != null ? currentAgreementLineItem.Set_Desc__c : currentAgreementLineItem.Set__c;
        cplRow.Subset = currentAgreementLineItem.Subset_Desc__c != null ? currentAgreementLineItem.Subset_Desc__c : currentAgreementLineItem.Subset__c;
        cplRow.Vendor = currentAgreementLineItem.AIQdt_Vendor__c;         
        cplRow.Cost = currentAgreementLineItem.PricingCost__c; 
        
        
        //cplRow.GTM = currentAgreementLineItem.aiq_GTM__c;
        cplRow.GTM = currentAgreementLineItem.GTM__c;
        if(currentAgreementLineItem.Net_Price__c != null && currentAgreementLineItem.Net_Price__c > 0 &&  currentAgreementLineItem.PricingCost__c != null) {
            cplRow.GTM = (currentAgreementLineItem.Net_Price__c -  currentAgreementLineItem.PricingCost__c) / currentAgreementLineItem.Net_Price__c;
        }
        
        cplRow.PriceType = currentAgreementLineItem.zpl__PolicyType__r.Name;         
        cplRow.PolicyValue = currentAgreementLineItem.zpl__PolicyValue__c;
        cplRow.Rebate = currentAgreementLineItem.InternalCostDeviation__c > 0 || currentAgreementLineItem.ExternalCostDeviation__c > 0 ? 'Y' : '';
        cplRow.RebateExpirationDate = currentAgreementLineItem.InternalCostDeviation__c > 0 ? currentAgreementLineItem.InternalCostDeviationDate__c
            : (currentAgreementLineItem.ExternalCostDeviation__c > 0 ? currentAgreementLineItem.ExternalCostDeviationDate__c : null);
                cplRow.BeginDate = currentAgreementLineItem.zpl__EffectiveDate__c;
        /*cplRow.CWTPrice = getCWTSalesForAgreementLineItem(currentAgreementLineItem, null);
        //cplRow.CWTPrice = currentAgreementLineItem.Net_Price__c;
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM && currentAgreementLineItem.Net_Price__c > 0 && currentAgreementLineItem.Net_Price__c < 1){
            cplRow.CWTPrice = currentAgreementLineItem.Net_Price__c;
        }
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED){
            cplRow.CWTPrice = (currentAgreementLineItem.zpl__PolicyValue__c).setScale(4);
        } Commented on 28/10/2021 */ 
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED && currentAgreementLineItem.zpl__UOM__r.Name == ZPL_UOM_NAME_CW){
            cplRow.CWTPrice = (currentAgreementLineItem.zpl__PolicyValue__c).setScale(2);
        }
        
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN && (currentAgreementLineItem.PricingCost__c == 0 || cplRow.CurrentPrice == 0)){
            cplRow.CurrentPrice = currentAgreementLineItem.zpl__PolicyValue__c;
        }
        
        cplRow.TwelveMonthSales = currentAgreementLineItem.X12MonthSalesVolume__c;
        
        if (futureAgreementLineItem != null) {
            //cplRow.FuturePrice = getPriceForAgreementLineItem(futureAgreementLineItem, productUOMIdToConversionFactor, null);
            //cplRow.FuturePrice = futureAgreementLineItem.zpl__PolicyValue__c;
            //cplRow.FuturePrice = futureAgreementLineItem.Bracket1Price__c;
            cplRow.FuturePrice = futureAgreementLineItem.Net_Price__c; 
            cplRow.FuturePolicyValue = futureAgreementLineItem.zpl__PolicyValue__c;  
            cplRow.FutureEffDate = futureAgreementLineItem.zpl__EffectiveDate__c;             
            cplRow.FutureCost = futureAgreementLineItem.PricingCost__c;            
            cplRow.FutureGTM = futureAgreementLineItem.aiq_GTM__c/100;
        }
        
        //KM: exclude rows with null price
        if(cplRow.CurrentPrice == null){
            return null;
        }
        
        //[START] 02042022        
        if (futureAgreementLineItemOnly != null) {
            cplRow.FuturePrice = getPriceForAgreementLineItem(futureAgreementLineItemOnly, productUOMIdToConversionFactor, null); 
            cplRow.FuturePolicyValue = futureAgreementLineItemOnly.zpl__PolicyValue__c;  //SP-05182022  
            cplRow.FutureEffDate =  futureAgreementLineItemOnly.zpl__EffectiveDate__c;             
            cplRow.FutureCost = futureAgreementLineItemOnly.PricingCost__c;            
            cplRow.FutureGTM = futureAgreementLineItemOnly.aiq_GTM__c/100;
            cplRow.CustPriceUOM = null; 
            if(futureAgreementLineItemOnly.PricingCost__c != null && futureAgreementLineItemOnly.PricingCost__c != null){
                cplRow.Cost = futureAgreementLineItemOnly.PricingCost__c - futureAgreementLineItemOnly.PricingCost__c;
            }
            cplRow.GTM = null;
            cplRow.BeginDate = null;
            cplRow.CurrentPrice = null;
            
        }
        //[END] 02042022

        //SP08192022 - Added
        /*if(String.isBlank(cplRow.ProductCode)){//has no product code
            prodCheck = cplRow.ProductDescription;
        }else{             
            prodcheck = cplRow.ProductCode;
        }
        
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM){
            isMaintainMargin = checkMaintainMargin(agreementLineItem);//MaintainCPLCheck(currentAgreementLineItem.PricingCost__c, cplRow.ProductCode);
            isduplicate = InternalDuplicateCPLCheck(prodcheck, cplRow.CurrentPrice, currentAgreementLineItem.PricingCost__c);
            
            //if((isMaintainMargin == true && isDuplicate == false) || futureAgreementLineItemOnly != null){
            if(isMaintainMargin == true && isDuplicate == false){// || futureAgreementLineItemOnly != null){
                return cplRow;
            }else{
                return null; 
            }
        }else{
            isduplicate = InternalDuplicateCPLCheck(prodcheck, cplRow.CurrentPrice, currentAgreementLineItem.PricingCost__c);  
            if(isDuplicate == false){ //|| futureAgreementLineItemOnly != null){//BL - 2903
                return cplRow;
            }else{
                return null; //[Commented Out]Backlog Item 2810
                //return cplRow; //Backlog Item 2810
            }
        }*/
         //SP08192022 - Added
        
        
        
        
        
        
        
        
//SP08192022 - Commented Out        
        if(String.isBlank(cplRow.ProductCode)){//has no product code
            prodCheck = cplRow.ProductDescription;
        }else{             
            prodcheck = cplRow.ProductCode;
        }
        
        boolean isduplicate;
        isduplicate = InternalDuplicateCPLCheck(prodcheck, cplRow.CurrentPrice, currentAgreementLineItem.PricingCost__c);
        
        if (isduplicate == false){             
            return cplRow;
        }else
            return null; 
        
        
    }
    
    public InternalCPLRow createInternalCPLRow(CPLServices.AgreementLineItemWrapper parent, Product2 product, Map<String, Decimal> productUOMIdToConversionFactor){
        zpl__ContractLineItem__c currentAgreementLineItem = parent.currentAgreementLineItem;
        //System.debug('currentAgreementLineItem333444 ' + currentAgreementLineItem);
        
        InternalCPLRow cplRow = new InternalCPLRow();
        
     //   cplRow.Numberrrere = Numberrrere + 1;
        
        //cplRow.Division = product.Division_Name__r.Name;
        if(currentAgreementLineItem.zpl__Contract__r.Account.RecordType.Name != 'Chain Account'){             
            cplRow.Division = product.Division_Name__r.Division_Code__c + '-' + product.Division_Name__r.Name;
        }
       //System.debug('product Internal ' +  cplRow.ProductCode );
       //cplRow.CustomerSKU = currentAgreementLineItem.CustomerSKU__c;
       //System.debug('CustomerSKU ooooo ' + currentAgreementLineItem.CustomerSKU__c);
        
        cplRow.Segment = product.Segment__c;
        //cplRow.CPLClass = product.Class_Description__c;
        cplRow.CPLClass = currentAgreementLineItem.Class_Desc__c;
        //cplRow.Brand = product.Brand_Description__c;
        cplRow.Brand = currentAgreementLineItem.Brand_Desc__c;
        //cplRow.CPLSet = product.Set_Description__c;
        cplRow.CPLSet = currentAgreementLineItem.Set_Desc__c;
        //cplRow.Subset = product.Subset_Description__c;
        cplRow.Subset = currentAgreementLineItem.Subset_Desc__c;         
        cplRow.ProductCode = product.ProductCode;         
        cplRow.ProductDescription = product.Description;
        cplRow.CurrentPrice = getPriceForProduct(parent.currentAgreementLineItem, product, productUOMIdToConversionFactor,'Customer Price'); //SP03182022
        
        //SP 06/08/2022 BL3177
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM && currentAgreementLineItem.PricingCost__c == 0){
            cplRow.CurrentPrice = currentAgreementLineItem.Net_Price__c/100;
        }
        
        //cplRow.CurrentPrice = getPriceForProduct(parent.currentAgreementLineItem, product, productUOMIdToConversionFactor); //SP03182022 re
        cplRow.CustPriceUOM = parent.currentAgreementLineItem.PricingUOM__c;
        cplRow.Cost = getPriceForProduct(parent.currentAgreementLineItem, product, productUOMIdToConversionFactor,'Cost'); //SP03182022
        //cplRow.Cost = parent.currentAgreementLineItem.PricingCost__c; //SP03182022 re
        /*28/01/2022 Disabled for Conversion computation to be included in Cost aswell. 
        cplRow.Cost = parent.currentAgreementLineItem.PricingCost__c;*/
        cplRow.BeginDate = parent.currentAgreementLineItem.zpl__EffectiveDate__c;         
        cplRow.PriceType = parent.currentAgreementLineItem.zpl__PolicyType__r.Name;        
        cplRow.PolicyValue = parent.currentAgreementLineItem.zpl__PolicyValue__c;
        if(parent.currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED && parent.currentAgreementLineItem.zpl__UOM__r.Name == ZPL_UOM_NAME_CW){
            cplRow.CWTPrice = (parent.currentAgreementLineItem.zpl__PolicyValue__c).setScale(2);
        }
        
        if(currentAgreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN && (currentAgreementLineItem.PricingCost__c == 0 || cplRow.CurrentPrice == 0)){
            cplRow.CurrentPrice = parent.currentAgreementLineItem.zpl__PolicyValue__c;
        }
                
        //KM: exclude rows with null price
        if(cplRow.CurrentPrice == null){             
            return null;
        }
        
        string prodCheck;
        if(String.isBlank(cplRow.ProductCode)){//has no product code
            prodCheck = cplRow.ProductDescription;
        }else{
            prodcheck = cplRow.ProductCode;
        }
        
        boolean isduplicate;
        isduplicate = InternalDuplicateCPLCheck(prodcheck,cplRow.CurrentPrice, cplrow.Cost);
        
        if(isduplicate == false){
            return cplRow;
        }else
            return null;
    }
    
    private static Decimal getPriceForAgreementLineItem(zpl__ContractLineItem__c agreementLineItem, Map<String, Decimal> productUOMIdToConversionFactor, Integer bracket){
        Decimal policyValue = bracket == null ? agreementLineItem.zpl__PolicyValue__c : (Decimal) agreementLineItem.get('Bracket' + bracket + 'Value__c');
        Decimal priceLineItem; //Backlog Item 2778
        Decimal priceLineItemRounded; //Backlog Item 2778
        
        if(agreementLineItem.zpl__PolicyType__c == null){
            return null;
        }
        else if(bracket != null && bracket > 1){ //KM: QTY Break
            return (Decimal) agreementLineItem.get('Bracket' + bracket + 'Price__c');
        }else if (agreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_FIXEDPRICE){
            //return policyValue; //Commented Simplus - 08/06/2021 [2903]
            //return agreementLineItem.aiq_Net_Price__c; //BL - 2903 //Commented Simplus - 08/26/2021 [BL-2946] 
            //System.debug(agreementLineItem.ID + ' 1287 dsdada ' + agreementLineItem.Net_Price__c);
            return agreementLineItem.Net_Price__c; //08/26/2021 [BL-2946] 
        }else if (agreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED){
            if (bracket == null){
                //return agreementLineItem.zpl__PolicyValue__c;  //Commented Simplus - 08/06/2021 [2903]
                //return agreementLineItem.aiq_Net_Price__c; //BL - 2903 //Commented Simplus - 08/26/2021 [BL-2946] 
                return agreementLineItem.Net_Price__c; //08/26/2021 [BL-2946] 
            }else{
                
                //System.debug(agreementLineItem.SKU__c + 'customerrrrr price' + (Decimal) agreementLineItem.get('Bracket' + bracket + 'Price__c'));
                return (Decimal) agreementLineItem.get('Bracket' + bracket + 'Price__c');
            }
        }else if (agreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_LISTDOWN){
            //priceLineItem = agreementLineItem.aiq_Net_Price__c; //Commented Simplus - 08/26/2021 [BL-2946] 
            priceLineItem = agreementLineItem.Net_Price__c; //08/26/2021 [BL-2946] 
            if (agreementLineItem.PricingCost__c != null && policyValue != null){
                //return agreementLineItem.PricingCost__c - agreementLineItem.PricingCost__c * policyValue; //Commented Simplus - 04/28/2021 [2778]
                
                //Backlog Item 2778
                priceLineItemRounded = priceLineItem.setScale(2);
                return priceLineItemRounded;
            }
            else if((agreementLineItem.PricingCost__c == null || agreementLineItem.PricingCost__c == 0) && policyValue != null){ //KM: display policy value
                return policyValue;
            }
            else{
                //Case 28135 
                if(priceLineItem >= 0){
                    priceLineItemRounded = priceLineItem.setScale(2); 
                    return priceLineItemRounded;
                }else{
                    return priceLineItem;
                }
            }
        }else if(agreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_MAINTAINGTM){
            if(agreementLineItem.PricingCost__c != null && policyValue != null){
                //return agreementLineItem.PricingCost__c / (1 - policyValue); //Commented Simplus - 08/06/2021 [2903]
                //return agreementLineItem.aiq_Net_Price__c; //BL - 2903 //Commented Simplus - 08/26/2021 [BL-2946] 
                return agreementLineItem.Net_Price__c; //08/26/2021 [BL-2946]
            }else{
                return 0;
            }
        }
        return 0;
    }
    
    private static Decimal getPriceForProduct(zpl__ContractLineItem__c parent, Product2 product, Map<String, Decimal> productUOMIdToConversionFactor, String cplColumn) {
        //temp 08/01/2022 if(product.Pricing_Costing_UOM__c != parent.zpl__UOM__r.Name && product.Pricing_Costing_UOM__c != null && parent.zpl__UOM__r.Name != null && product.IsActive == TRUE ){
        if(product.Pricing_Costing_UOM__c != null && parent.zpl__UOM__r.Name != null && product.IsActive == TRUE ){
            String aliUnit = product.Unit_of_Measure__c;
            String pricingUOM = product.Pricing_Costing_UOM__c;
            String cwtUnit = parent.zpl__PolicyType__r.zpl__PolicyTypeId__c;
            String productUnit = parent.zpl__UOM__r.Name;
            Decimal toALIUnitFactor = 0;
            Decimal toALIUnitFactorParent = 0;
            Boolean skipConversion = false;
            Decimal trueCWValue = 0;
            Decimal costPerThousand = 0;
            Decimal hundredWeight = 0;
            
            if(cwtUnit != null && (cwtUnit == 'cwtFixed')){
                toALIUnitFactor = productUOMIdToConversionFactor.get(product.Composite_Key__c + 'CW');
                toALIUnitFactorParent = productUOMIdToConversionFactor.get(parent.Product_Composite_Key__c + 'CW');                    
                
                if(productUnit == 'CW' && (cplColumn == 'Customer Price' || cplColumn == 'Cost') ){
                   skipConversion = true; 
                }
            }
            
            //Added 10/07/2022 - BL3242
            else if(cwtUnit != null && (cwtUnit == 'maintainGTM' || cwtUnit == 'listDown')){
                toALIUnitFactor = productUOMIdToConversionFactor.get(product.Composite_Key__c + 'CW');
                toALIUnitFactorParent = productUOMIdToConversionFactor.get(parent.Product_Composite_Key__c + 'CW'); 
            }
            
            //Added 10/11/2022 - BL3242
            else if(cwtUnit != null && cwtUnit == 'listDown'){
                //skipConversion = true; 
            }
            else{
                toALIUnitFactor = productUOMIdToConversionFactor.get(product.Composite_Key__c + aliUnit);    
            }
                                          
            Decimal toProductUnitFactor = productUOMIdToConversionFactor.get(product.Composite_Key__c + productUnit);
            Decimal toProductPricingUOM = productUOMIdToConversionFactor.get(product.Composite_Key__c + pricingUOM);
            
            Decimal toProductUnitFactorParent = productUOMIdToConversionFactor.get(parent.Product_Composite_Key__c + productUnit);
            
            Decimal valueConverted = 0;
            Decimal valueCon; //BL3177 07052022
            
            if(cplColumn == 'Customer Price'){
                if(cwtUnit == 'maintainGTM' || cwtUnit == 'listDown'){
                    valueConverted = parent.Net_Price__c;
                    valueCon = parent.Net_Price__c;
                }else{
                    valueConverted = parent.zpl__PolicyValue__c;
                    valueCon = parent.zpl__PolicyValue__c;
                }
            }else if(cplColumn == 'Cost'){
                valueConverted = parent.PricingCost__c;
                valueCon = parent.PricingCost__c;
            }
            
            //system.debug('Product Code: '+product.ProductCode+' || skipConversion: '+skipConversion+' || toProductUnitFactor: '+toProductUnitFactor+' || pricingUOM: '+pricingUOM+' || toProductPricingUOM: '+toProductPricingUOM);
            //system.debug('Product Code: '+product.ProductCode+' || skipConversion: '+skipConversion+' || toProductUnitFactor: '+ productUOMIdToConversionFactor.get(product.Composite_Key__c) + ' || ProdUn ' + productUnit + ' ' + cplColumn);
            if(toALIUnitFactor != null && toProductUnitFactor != null && skipConversion == false){
                valueConverted = toALIUnitFactor > 0 ? valueConverted / toALIUnitFactor : valueConverted * toALIUnitFactor;
                //System.debug('Product Code: 1374  ' +product.ProductCode+ '  ' + valueConverted + '  ' + toALIUnitFactor);
                
                if(aliUnit != 'SH'){
                    valueConverted = toProductUnitFactor > 0 ? valueConverted * toProductUnitFactor : valueConverted / toProductUnitFactor; 
                }
                
                valueConverted = math.abs(valueConverted);
               
                //BL3177 07122022
                /*if(pricingUOM == 'M'){
                    valueConverted = valueConverted * 1000;
                    System.debug('Product Code: 1382'+product.ProductCode + '  ' + valueConverted);
                }*/
                
                //For cplColumn == 'Customer Price' AND Price Type = CWT Fixed
                if(productUnit == 'M' && cplColumn == 'Customer Price'){
                    valueConverted = valueConverted * 1000;
                    //System.debug('Product Code: M CustomerPrice  || '+product.ProductCode + '  ||  ' + valueConverted);
                }
                
                if(productUnit == 'CT'  && cwtUnit == 'cwtFixed'){
                    valueConverted = (valueConverted * 1000) * (toProductUnitFactor / 1000); 
                    //System.debug('product code Id '+product.Id + ' Product Code: 1496'+product.ProductCode + ' valueConverted: 1496' + valueConverted + ' toProductUnitFactor: ' + toProductUnitFactor); 
                }
                
                if(productUnit == 'RM'){
                    valueConverted = (valueConverted * 1000) * (toProductUnitFactor / 1000);
                    //System.debug('Product Code: 1500'+product.ProductCode + valueConverted);
                }
                
                if(productUnit == 'SH'){
                    valueConverted = valueConverted;
                    //System.debug('Product Code: 1505'+product.ProductCode + valueConverted);                    
                }
                
                if(productUnit == 'LB'){
                    if (valueCon != 0 && valueCon != null){
                        valueConverted = (valueConverted * 1000) / (((valueConverted * 1000)*100)/valueCon);
                    }
                    //System.debug('Product Code: 1515'+product.ProductCode + '  ' + valueConverted);
                }
                
                if(productUnit == 'SK'){
                    valueConverted = (valueConverted * 1000) * (toProductUnitFactor / 1000);
                    //System.debug('Product Code: 1519'+product.ProductCode + '  ' + valueConverted);
                }   
                
                if(productUnit == 'HU'){
                    valueConverted = valueConverted * 100; 
                    //System.debug('Product Code: 1523'+product.ProductCode + valueConverted); 
                }
                
                if(productUnit == 'PK'){
                    valueConverted = (valueConverted * 1000) * (toProductUnitFactor / 1000);
                    //System.debug('test ' + (valueConverted * 1000) +  'Product Code: 1527'+product.ProductCode + valueConverted + ' toProductUnitFactor: ' + toProductUnitFactor); 
                }

                //For cplColumn == 'Cost' AND Price Type = CWT Fixed
                if(cplColumn == 'Cost' &&  cwtUnit == 'cwtFixed'){                
                    if(productUnit == 'M' && valueCon != 0 && valueCon != null){
                        trueCWValue = valueCon * (toALIUnitFactorParent/1000);
                        hundredWeight = (valueConverted * 1000) / valueCon;
                        valueConverted = trueCWValue * hundredWeight;
                        //System.debug('Product Code:  M CostPrice || '+product.ProductCode + '  || ' + valueConverted);
                    }
                    
                    if(productUnit == 'PK' && valueCon != 0 && valueCon != null){
                        trueCWValue = (valueCon * (toALIUnitFactorParent / 1000)) * 2;
                        hundredWeight = (((valueConverted * 1000) / valueCon) / 10) * 2;
                        valueConverted = ((trueCWValue / 100) * hundredWeight) * 2;
                        //System.debug('Product Code:  PK CostPrice || '+product.ProductCode + '  || ' + valueConverted);
                    }
                    
                    if(productUnit == 'RM' && valueCon != 0 && valueCon != null){
                        valueConverted = valueConverted * 100;
                        valueConverted = (valueConverted / toProductUnitFactor) * (toProductUnitFactor / 10);
                        //System.debug('Product Code:  RM CostPrice || '+product.ProductCode + '  || ' + valueConverted);
                    }
                    
                    if(productUnit == 'CT' && valueCon != 0 && valueCon != null){
                        trueCWValue = valueCon * (toALIUnitFactorParent / toProductUnitFactorParent);
                        //costPerThousand = valueConverted / (toProductUnitFactorParent / 1000);
                        hundredWeight = ((valueConverted / (toProductUnitFactorParent / 1000)) / valueCon) * 100;
                        valueConverted = ((trueCWValue / 100) * hundredWeight) * (toProductUnitFactorParent / 1000);
                        //System.debug('Product Code:  CT CostPrice || '+product.ProductCode + '  || ' + valueConverted);
                    }
                    
                    if(productUnit == 'SH' && valueCon != 0 && valueCon != null){
                        trueCWValue = valueCon * (toALIUnitFactorParent / toProductUnitFactorParent);
                        hundredWeight = valueConverted * 1000 / valueCon * 100;
                        valueConverted = ((hundredWeight / 100) * trueCWValue) / 1000;
                        //System.debug('Product Code:  CT CostPrice || '+product.ProductCode + '  || ' + valueConverted + ' || ' + aliUnit);
                    }
                }
                
                //For cplColumn == 'Cost/Customer Price' AND Price Type = Maintain GTM
                if((cwtUnit == 'maintainGTM') && valueCon != 0 && valueCon != null ){
                    
                    if(productUnit == 'CT'){
                        trueCWValue = valueCon * (toALIUnitFactorParent / toProductUnitFactorParent);
                        hundredWeight = (valueConverted * 1000) / valueCon * 100;
                        valueConverted = ((trueCWValue / 100) * hundredWeight) * (toProductUnitFactor / 1000);
                    }
                    
                    //02/15/2023
                    if(productUnit == 'CW'){
                        if(cplColumn == 'Customer Price'){
                            valueConverted = parent.Net_Price__c;
                        }
                        
                        if(cplColumn == 'Cost'){
                            valueConverted = parent.PricingCost__c;
                        }
                        
                    }
                    
                    if(productUnit == 'M'){
                        if(cplColumn == 'Customer Price'){
                            trueCWValue = valueCon * (toALIUnitFactorParent/1000);
                            hundredWeight = valueConverted / valueCon;
                            valueConverted = trueCWValue * hundredWeight;
                            //System.debug('product code Id '+product.Id + ' Product Code: 1496'+product.ProductCode + ' valueConverted: 1496' + valueConverted + ' toProductUnitFactor: ' + toProductUnitFactor);
                        }
                        
                        if(cplColumn == 'Cost'){
                            trueCWValue = valueCon * (toALIUnitFactorParent/1000);
                            hundredWeight = (valueConverted * 1000) / valueCon;
                            valueConverted = trueCWValue * hundredWeight;
                            //System.debug('product code Id '+product.Id + ' Product Code: 1496'+product.ProductCode + ' valueConverted: 1496' + valueConverted + ' toProductUnitFactor: ' + toProductUnitFactor);
                        }
                    }
                    
                    if(productUnit == 'PK'){
                        if(cplColumn == 'Customer Price'){
                            trueCWValue = valueCon * (toALIUnitFactorParent / toProductUnitFactorParent);
                            hundredWeight = (((valueConverted * 1000) / valueCon) / 10) *2;
                            valueConverted = (trueCWValue * (hundredWeight / 100)) / 2;
                            //System.debug('Product Code:  PK Customer Price || '+product.ProductCode + '  || ' + valueConverted);
                        }
                        
                        if(cplColumn == 'Cost'){
                            trueCWValue = (valueCon * (toALIUnitFactorParent / 1000)) * 2;
                            hundredWeight = (((valueConverted * 1000) / valueCon) / 10) * 2;
                            valueConverted = ((trueCWValue / 100) * hundredWeight) ;
                        }
                    }
                    
                    if(productUnit == 'RM'){
                         if(cplColumn == 'Customer Price'){
                             trueCWValue = valueCon * (toALIUnitFactorParent / 1000);
                             hundredWeight = valueConverted / valueCon * 100;
                             valueConverted = ((trueCWValue / 100) * hundredWeight) / 2;
                             //System.debug('Product Code:  RM Customer Price || '+product.ProductCode + '  || ' + valueConverted);
                         }
                        
                        if(cplColumn == 'Cost'){
                            trueCWValue = valueCon * (toALIUnitFactorParent/1000);
                            hundredWeight = (valueConverted * 1000) / (valueCon * 100);
                            valueConverted = ((trueCWValue / 100) * hundredWeight) / 2;
                            //System.debug('Product Code:  RM CostPrice || '+product.ProductCode + '  || ' + valueConverted);
                        }
                    }
                    
                    
                    if(productUnit == 'SH'){
                        if(cplColumn == 'Customer Price'){
                            trueCWValue = valueCon * (toALIUnitFactorParent / toProductUnitFactorParent);
                            hundredWeight = valueConverted / valueCon * 100;
                            valueConverted = ((hundredWeight / 100) * trueCWValue) / 1000;
                            //System.debug('Product Code:  SH CostPrice || '+product.ProductCode + '  || ' + valueConverted + ' || ' + aliUnit);
                        }
                        
                        if(cplColumn == 'Cost'){
                            trueCWValue = valueCon * (toALIUnitFactorParent / toProductUnitFactorParent);
                            hundredWeight = valueConverted * 1000 / valueCon * 100;
                            valueConverted = ((hundredWeight / 100) * trueCWValue) / 1000;
                            //System.debug('Product Code:  SH CostPrice || '+product.ProductCode + '  || ' + valueConverted + ' || ' + aliUnit);
                        }
                    }
                }
                
                //For cplColumn == 'Cost/Customer Price' AND Price Type = List Down
                if((cwtUnit == 'listDown') && valueCon != 0 && valueCon != null ){ 
                    if(productUnit == 'M'){
                        if(cplColumn == 'Customer Price'){
                            trueCWValue = valueCon * (toALIUnitFactorParent/1000);
                            hundredWeight = valueConverted / valueCon;
                            valueConverted = trueCWValue * hundredWeight;
                            //System.debug('product code Id '+product.Id + ' Product Code: 1496'+product.ProductCode + ' valueConverted: 1496' + valueConverted + ' toProductUnitFactor: ' + toProductUnitFactor);
                        }
                        
                        if(cplColumn == 'Cost'){
                            trueCWValue = valueCon * (toALIUnitFactorParent/1000);
                            hundredWeight = (valueConverted * 1000) / valueCon;
                            valueConverted = trueCWValue * hundredWeight;
                            //System.debug('product code Id '+product.Id + ' Product Code: 1496'+product.ProductCode + ' valueConverted: 1496' + valueConverted + ' toProductUnitFactor: ' + toProductUnitFactor);
                        }
                    }
                    
                    if(productUnit == 'CW'){
                        if(cplColumn == 'Customer Price'){
                            valueConverted = valueCon;
                            //System.debug('product code Id '+product.Id + ' Product Code: 1496'+product.ProductCode + ' valueConverted: 1496' + valueConverted + ' toProductUnitFactor: ' + toProductUnitFactor);
                        }
                        
                        if(cplColumn == 'Cost'){
                            valueConverted = valueCon;
                            //System.debug('product code Id '+product.Id + ' Product Code: 1496'+product.ProductCode + ' valueConverted: 1496' + valueConverted + ' toProductUnitFactor: ' + toProductUnitFactor);
                        }
                    }
                    
                    if(productUnit == 'CT'){
                        trueCWValue = valueCon * (toALIUnitFactorParent / toProductUnitFactorParent);
                        hundredWeight = (valueConverted * 1000) / valueCon * 100;
                        valueConverted = ((trueCWValue / 100) * hundredWeight) * (toProductUnitFactor / 1000);
                        //System.debug('product code Id '+product.Id + ' Product Code: 1496'+product.ProductCode + ' valueConverted: 1496' + valueConverted + ' toProductUnitFactor: ' + toProductUnitFactor); 
                    }
                    
                    if(productUnit == 'PK'){
                        trueCWValue = valueCon * (toALIUnitFactorParent / toProductUnitFactorParent);
                        hundredWeight = (((valueConverted * 1000) / valueCon) / 10) *2;
                        valueConverted = (trueCWValue * (hundredWeight / 100)) / 2;
                        //valueConverted = ((trueCWValue / 100) * hundredWeight) * (toProductUnitFactor / 1000);
                        //System.debug('product code Id '+product.Id + ' Product Code: 1496'+product.ProductCode + ' valueConverted: 1496' + valueConverted + ' toProductUnitFactor: ' + toProductUnitFactor); 
                    }
                }
                
                //system.debug(product.Id + ' Product Code: '+product.ProductCode+' ComKey: '+product.Composite_Key__c+' valueConverted: '+valueConverted+' || toALIUnitFactor/cwtUnit: '+aliUnit+','+toALIUnitFactor+' || toProductUnitFactor: '+productUnit+','+toProductUnitFactor+' || cwtUnit: '+cwtUnit+' || ParentNetPrice: '+ parent.Net_Price__c + ' || parent.PricingCost ' +parent.PricingCost__c);
            }else if(skipConversion == true){
                //valueConverted = (parent.zpl__PolicyValue__c).setScale(4);
                //02/01/2023
                if(cplColumn == 'Customer Price'){
                    valueConverted = parent.Net_Price__c;
                }
                
                if(cplColumn == 'Cost'){
                    valueConverted = parent.PricingCost__c;
                }
                //system.debug('Product Code: '+product.ProductCode+' || valueConverted: '+valueConverted+' || Parent Id: '+parent.Id + +' || ParentNetPrice: '+parent.Net_Price__c);
            }else{
                //String info = 'ALI: ' + parent.Id + ' | Base: ' + aliUnit + ' | Conversion: ' + productUnit;
                System.debug('skipConversion' + skipConversion);
                //String info = 'Product Code: ' + product.ProductCode + ' | Base: ' + aliUnit + ' | Conversion: ' + productUnit; //SP-06282022commented muna ////SP-06282022 correct
                //String info = parent.Id + ' ' + product.Id + ' ' + 'Product Code: ' + product.ProductCode + ' | Base: ' + aliUnit + ' | Conversion: ' + productUnit; //SP-06282022commented muna
                //throw new QueryException(info); //SP-06282022commented muna
            }
            return valueConverted;
        }else{
            return parent.Net_Price__c;
        } 
    }
    
    private Map<String, Decimal> getProductUOMIdToConversionFactor(List<CPLServices.AgreementLineItemWrapper> agreementLineItems){
        transient List<zpl__ContractLineItem__c> allAgreementLineItems = new List<zpl__ContractLineItem__c>();
        for (CPLServices.AgreementLineItemWrapper agreementLineItemWrapper : agreementLineItems){             
            allAgreementLineItems.add(agreementLineItemWrapper.currentAgreementLineItem);
            
            if(agreementLineItemWrapper.futureAgreementLineItem != null){                 
                allAgreementLineItems.add(agreementLineItemWrapper.futureAgreementLineItem);
            }
        }
        
        
        transient Set<Id> productIds = Pluck.ids('zpl__Product__c', allAgreementLineItems);
        
        
            for(CPLServices.AgreementLineItemWrapper agreementLineItemWrapper : agreementLineItems){
                if(agreementLineItemWrapper.childProducts != null && agreementLineItemWrapper.childProducts.size() > 0){
                    Set<Id> childProductIds = Pluck.ids('Id', agreementLineItemWrapper.childProducts);
                    if(childProductIds !=null && productIds !=null){
                        productIds.addAll(childProductIds);
                    }
                }
            }
        
        transient List<zpl__ProductUOM__c> productUOMs = [SELECT Id, zpl__ProductUOMId__c, zpl__ConversionFactor__c
                           FROM zpl__ProductUOM__c
                           WHERE zpl__Product__c IN :productIds
                          ];
        
        productIds = null; //heap allocation
        
        
        Map<String, Decimal> productUOMIdToConversionFactor = new Map<String, Decimal>();
        for (zpl__ProductUOM__c productUOM : productUOMs){
            //system.debug(': '+productUOM);
            productUOMIdToConversionFactor.put(productUOM.zpl__ProductUOMId__c, productUOM.zpl__ConversionFactor__c);
            //System.debug('productUOM.ID ' + productUOM.id + ' productUOM.zpl__ProductUOMId__c ' + productUOM.zpl__ProductUOMId__c + ' productUOM.zpl__ConversionFactor__c ' + productUOM.zpl__ConversionFactor__c);
        }
        
        return productUOMIdToConversionFactor;
        
    }
    
    private Decimal getCWTSalesForAgreementLineItem(zpl__ContractLineItem__c agreementLineItem, Integer bracket){        
        if(agreementLineItem.zpl__PolicyType__r.Name == ZPL_POLICYTYPE_NAME_CWTFIXED && agreementLineItem.zpl__UOM__r.Name == ZPL_UOM_NAME_CW && agreementLineItem.zpl__UOM__c != null){
            if(bracket == null){
                return agreementLineItem.zpl__PolicyValue__c;
            }else{
                return (Decimal) agreementLineItem.get('Bracket' + bracket + 'Value__c');
            }
        }
        return null;
    }
    
    private Boolean isCategoryInCPLCategories(CPL cpl, String checkedCategory){
        for(String category : cpl.categories){
            if(checkedCategory == category){                 
                return true;
            }
        }
        return false;
    }
    
    public virtual class CPL {
        public transient List<String> headers {get; set;}
        public transient List<String> categories {get; set;}
        public transient Map<String, List<CPLRow>> rows {get; set;}
        public transient string division {get; set;}
        public transient Boolean isNationals {get; set;}
        /*
public transient Integer rowSize {
get {
return rows.size();
}
}*/
        
        public CPL() {
            this.categories = new List<String>();
        }
    }
    
    public class ExternalCPL extends CPL{
        public ExternalCPL(){
            headers = new List<String>{
                
                'Product Code',
                    'Order Qty',
                    'Customer SKU',
                    'Product Description',
                    'QTY Price Break',
                    'Order Qty U/M',
                    'Current Price',
                    'Cust Price U/M',
                    'Future Price',
                    'Future Price U/M',
                    'Future Eff Date',
                    'CWT Pricing' //'-'
                    };
                        rows = new Map<String, List<ExternalCPLRow>>();
        }
    }
    
    public class InternalCPL extends CPL{
        public InternalCPL(){
            headers = new List<String>{
               // 'Numberrrere',
                'Division',
                    'Segment',
                    'Class',
                    'Brand',
                    'Set',
                    'Subset',
                    'Product Code',
                    'Customer SKU',
                    'Vendor', 
                    'Product Description',
                    'QTY Price Break',
                    'Cust Price',
                    'Price U/M', 
                    'Cost',
                    'GTM%', 
                    'Begin Date', 
                    'Future Cust Price',
                    'Future Cost',
                    'Future GTM%',
                    'Future Begin Date',
                    'Price Type',
                    'Policy Value', 
                    'Future Policy Value', //SP04012022
                    'Rebate',
                    'Rebate Expire Date',
                    'CWT Price',  
                    '12 Mnth Sales'
                    };
                        rows = new Map<String, List<InternalCPLRow>>();
        }
    }
    
    public abstract class CPLRow {}
    
    public class ExternalCPLRow extends CPLRow{
        public transient  String ProductCode {get; set;}
        public transient Integer OrderQty {get; set;}
        public transient String CustomerSKU {get; set;}
        public transient String ProductDescription {get; set;}
        public transient Decimal QTYPriceBreak {get; set;}
        public transient String OrderQtyUOM {get; set;}
        public transient Decimal CurrentPrice {get; set;}
        public transient String CustPriceUOM {get; set;}
        public transient Decimal FuturePrice {get; set;}
        public transient Decimal FuturePolicyValue {get; set;}
        public transient String FuturePriceUOM {get; set;}
        public transient Date FutureEffDate {get; set;}
        public transient Decimal EmptyColumn {get; set;}
        public transient Decimal Percentage {get; set;}
        public transient Decimal CustomerCalcPrice {get; set;}
        public transient Decimal Cost {get; set;}
        public transient String CustomerUOM {get; set;}
        public transient String PriceType {get; set;}
    }
    
    public class InternalCPLRow extends CPLRow{
     //   public transient Integer Numberrrere {get; set;}
        public transient String Division {get; set;}
        public transient String Segment {get; set;}
        public transient String CPLClass {get; set;}
        public transient String Brand {get; set;}
        public transient String CPLSet {get; set;}
        public transient String Subset {get; set;}
        public transient String ProductCode {get; set;}
        public transient Integer OrderQty {get; set;}
        public transient String CustomerSKU {get; set;}
        public transient String Vendor {get; set;}
        public transient String ProductDescription {get; set;}
        public transient Decimal QTYPriceBreak {get; set;}
        public transient Decimal CurrentPrice {get; set;}
        public transient String CustPriceUOM {get; set;}
        public transient Decimal Cost {get; set;}
        public transient Decimal GTM {get; set;}
        public transient Date BeginDate {get; set;}
        public transient Decimal FuturePrice {get; set;}
        public transient Decimal FuturePolicyValue {get; set;}
        public transient Decimal FutureCost {get; set;}
        public transient Decimal FutureGTM {get; set;}
        public transient Date FutureEffDate {get; set;}
        public transient String PriceType {get; set;}
        public transient Decimal PolicyValue {get; set;}
        public transient String Rebate {get; set;}
        public transient Date RebateExpirationDate {get; set;}
        public transient Decimal CWTPrice {get; set;}
        public transient Decimal TwelveMonthSales {get; set;}
    }
    
    private boolean DuplicateCPLCheck(String codePrice, decimal currentPrice, decimal Cost){
        if(cplDuplicateCheck.contains(codePrice)==false){//} && CurrentPrice>0  && CurrentPrice!= Cost){
            cplDuplicateCheck.add(codePrice);
            return false;
        }else{
            return true;
        }
    }
    
    private boolean InternalDuplicateCPLCheck(String codePrice, decimal currentPrice, decimal Cost){
        if(cplDuplicateCheck.contains(codePrice)==false){
            cplDuplicateCheck.add(codePrice);
            return false;
        }else{
            return true;
        }   
    }
    
    private boolean MaintainCPLCheck(decimal Cost,  string ProductCode){
        if(Cost!=null && String.isBlank(ProductCode) ==false){
            return false;
        }else{
            return false;
        }   
    }      
}
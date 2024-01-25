({	
    globalCmp: null,
    effectiveDate:  null,
    CPLType:  null,
    executeAction: function(component, actionName, params) {
        return new Promise(function(resolve, reject) {
            if (!params) params = {};
            const action = component.get("c." + actionName);
        	action.setParams(params);
            action.setCallback(this, function(response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    let retVal = response.getReturnValue();
                    resolve(retVal);
                } else {
                    const errors = response.getError(); 
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            reject(errors[0].message, true);
                        }
                    }
                    else {
                        reject("Unknown error", true);
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },

    getRecordTypeByIdAction: function (component, helper) {
        return helper.executeAction(
            component,
            "getRecordTypeById", 
            { "recordTypeId": component.get("v.cpl").RecordTypeId }
        ).then($A.getCallback(function (result) {
            component.set("v.recordTypeName", result);
        }));
    },

    getAgreementIdFromNameAction: function (component, helper) {
        let agreementNumber = component.get("v.pageReference.state.additionalParams").split("&")[0].split("=")[1];

        return helper.executeAction(
            component,
            "getAgreementIdFromNumber",
            { "agreementNumber": agreementNumber }
        ).then($A.getCallback(function (result) {
            let cpl = component.get("v.cpl");
            cpl.Agreement__c = result;
            component.set("v.cpl", cpl);
        }));
    },

    getCPLByIdAction: function (component, helper) {
        
        return helper.executeAction(
            component, 
            "getCPLById", 
            { "cplId": component.get("v.recordId") }
        ).then($A.getCallback(function (result) {
            component.set("v.recordTypeId", result.RecordTypeId);
            component.set("v.recordTypeName", result.RecordType.Name);
            
            delete result.RecordType;
            component.set("v.cpl", result);
        }));
    },

    getDependentPicklistValuesAction: function (component, helper) {
        console.log("getDependentPicklistValuesAction");
        let cpl = component.get("v.cpl");
        //test if we can put component to a variable
        this.globalCmp = component;
        let dependentFieldFilters;
        if (cpl) {
            console.log("if CPL");
            dependentFieldFilters = {
                "Division__c": cpl.Division__c || "",
                "Segments__c": cpl.Segments__c || "",
                "Classes__c": cpl.Classes__c || "",
                "Brands__c": cpl.Brands__c || ""
            };
        } else {
            console.log("ELSE");
            dependentFieldFilters = {
                "Division__c": "",
                "Segments__c": "",
                "Classes__c": "",
                "Brands__c": ""
            };
        }
		console.log("before helper Execute");
        
        /*
        //javascript convertion below
        const divisionOptions = [];
        const segmentOptions = [];
        const classOptions = [];
        const brandOptions = [];
        
        divisionOptions = this.getPickVal(cpl, "Division__c", "Division__c");
        segmentOptions = this.getPickVal(cpl, "Segments__c", "Segment__c");
        classOptions = this.getPickVal(cpl, "Classes__c", "Class__c");
        brandOptions = this.getPickVal(cpl, "Brands__c", "Brand__c");
        
        const depPicklistMap = new Map();
        depPicklistMap.set("Division__c", divisionOptions);
        depPicklistMap.set("Segments__c", segmentOptions);
        depPicklistMap.set("Classes__c", classOptions);
        depPicklistMap.set("Brands__c", brandOptions);
        component.set("v.dependentFieldOptions", depPicklistMap);
        */
        //original code below
        
        return helper.executeAction(
            component,
            "getDependentPicklistValues", 
            {
                "cpl": component.get("v.cpl"),
                //"cpl": cpl,
                "filters": dependentFieldFilters
            }
        ).then($A.getCallback(function (result) {
            //result.sort(function(a, b){return a - b});
            console.log(result);
            console.log(Array.from(result));
            component.set("v.dependentFieldOptions", result);
        }));
        
    },

    getDefaultCPLAction: function (component, helper) {
        return helper.executeAction(
            component,
            "getDefaultCPL",
            { "recordTypeId": component.get("v.recordTypeId") }
        ).then($A.getCallback(function (result) {
            let cpl = component.get("v.cpl");
            for (let field in result) {
                cpl[field] = result[field];
            }

            component.set("v.cpl", cpl);
        }));
    },

    getCustomerPriceListName: function (component, helper) {
        return helper.executeAction(
            component,
            "getCustomerPriceListName",
            { "agreementId": component.get("v.cpl").Agreement__c }
        ).then($A.getCallback(function (result) {
            let cpl = component.get("v.cpl");
            cpl["Name"] = result;
            component.set("v.cpl", cpl);
        }));
    },

    getSalesRepOptionsAction: function (component, helper) {
        return helper.executeAction(
            component,
            "getSalesRepOptions",
            { "agreementId": component.get("v.cpl").Agreement__c }
        ).then($A.getCallback(function (result) {
            component.set("v.salesRepOptions", result);

            return component;
        }));
    },

    getQueryStringMap: function () {
        let url = window.location.search.substr(1).split("&");
        if (url == "") return {};
        let params = {};
        for (var i = 0; i < url.length; ++i) {
            var pair = url[i].split("=", 2);
            if (pair.length == 1)
                params[pair[0]] = "";
            else
                params[pair[0]] = decodeURIComponent(pair[1].replace(/\+/g, " "));
        }
        return params;
    },

    getLookupIdFromQSVars: function (additionalParams) {
        let searchText = "lkid=";
        let searchIndex = additionalParams.search(searchText) + searchText.length;
        return additionalParams.substr(searchIndex, 15);
    },
    
    callCPLAsyncAction: function (component, cplRec, outputUrl) {
        console.log(outputUrl);
        var action = component.get("c.callCPLAsync");
        action.setParams({
            'cpl': cplRec,
            'outputURL': outputUrl          
        });
        action.setCallback(this, function(response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    let retVal = response.getReturnValue();
                    
                } else {
                    const errors = response.getError(); 
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            reject(errors[0].message, true);
                        }
                    }
                    else {
                        reject("Unknown error", true);
                    }
                }
            });
            $A.enqueueAction(action);
        
    },
    
    showToast: function(message, isError) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": message,
            "type": isError ? "error" : "success",
        });
        toastEvent.fire();
    },
    
    getPickVal: function(cpl, cplField, aliField){
    //AgreementLineItemWrapper = getAgreementLineItemsForDependentFieldVal(cpl,cplfield)
        const agreementLineItems = [];
        agreementLineItems = this.getAgreementLineItemsForDependentFieldVal(cpl, cplField);
        
        const currentLineItems = [];
        for (var i = 0; i < agreementLineItems.length; i++) {
            currentLineItems.add(agreementLineItems[i].currentAgreementLineItem);
        }
        const options = [];
        if (cplField == "Division__c") {        	
            const currentLineItemsMap = new Map(); 
            for (var i = 0; i < currentLineItems.length; i++) {
                if(currentLineItemsMap.has(currentLineItems[i].Division__c)){
                    currentLineItemsMap.get(currentLineItems[i].Division__c).add(currentLineItems[i]);
                }else{
                    const currentLineItemsVal = currentLineItems.slice();
                    currentLineItemsMap.set(currentLineItems[i].Division__c, currentLineItemsVal);
                }
            }
            for (let keyVal of currentLineItemsMap.keys()) {
            	options.add(currentLineItemsMap.get(keyVal)[0].Division__r.Name, keyVal, currentLineItemsMap.get(keyVal).size);	
            }           
        }
        else if (cplField == "Segments__c") {        	
            const currentLineItemsMap = new Map(); 
            for (var i = 0; i < currentLineItems.length; i++) {
                if(currentLineItemsMap.has(aliField)){
                    currentLineItemsMap.get(aliField).add(currentLineItems[i]);
                }else{
                    const currentLineItemsVal = currentLineItems.slice();
                    currentLineItemsMap.set(aliField, currentLineItemsVal);
                }
            }
            for (let keyVal of currentLineItemsMap.keys()) {
            	options.add(keyVal, keyVal, currentLineItemsMap.get(keyVal).size);	
            }           
        } 
        else if (cplField == "Classes__c") {        	
            const currentLineItemsMap = new Map(); 
            for (var i = 0; i < currentLineItems.length; i++) {
                if(currentLineItemsMap.has(aliField)){
                    currentLineItemsMap.get(aliField).add(currentLineItems[i]);
                }else{
                    const currentLineItemsVal = currentLineItems.slice();
                    currentLineItemsMap.set(aliField, currentLineItemsVal);
                }
            }
            for (let keyVal of currentLineItemsMap.keys()) {
            	options.add(currentLineItemsMap.get(keyVal)[0].Class_Desc__c != null ? currentLineItemsMap.get(keyVal)[0].Class_Desc__c : currentLineItemsMap.get(keyVal)[0].Class__c, 
                            keyVal, 
                            currentLineItemsMap.get(keyVal).size);	
            }           
        }
        else if (cplField == "Brands__c") {        	
            const currentLineItemsMap = new Map(); 
            for (var i = 0; i < currentLineItems.length; i++) {
                if(currentLineItemsMap.has(aliField)){
                    currentLineItemsMap.get(aliField).add(currentLineItems[i]);
                }else{
                    const currentLineItemsVal = currentLineItems.slice();
                    currentLineItemsMap.set(aliField, currentLineItemsVal);
                }
            }
            for (let keyVal of currentLineItemsMap.keys()) {
            	options.add(currentLineItemsMap.get(keyVal)[0].Brand_Desc__c != null ? currentLineItemsMap.get(keyVal)[0].Brand_Desc__c : currentLineItemsMap.get(keyVal)[0].Brand__c, 
                            keyVal, 
                            currentLineItemsMap.get(keyVal).size);	
            }           
        }
                            
		return options;                                 
    },
    
    getAgreementLineItemsForDependentFieldVal: function(cpl, cplField){
    	//var cplClone = new sforce.SObject("Customer_Price_List__c");
        //cplClone = cpl;
        //cplClone[cplField] = null;
        let cplClone = JSON.parse(JSON.stringify(cpl));
        
        //call getAgreementLineItemsFromCPL
        return this.getAgreementLineItemsFromCPL(cplClone);
    },
    
    getAgreementLineItemsFromCPL: function(cpl){
    	if(this.effectiveDate == null){
            this.effectiveDate = cpl.Effective_Date__c;
        }    
        console.log("before geting contract");
        console.log(this.globalCmp);
        //get the contract
        var agreement;
        var action = this.globalCmp.get("c.getContractFromId");
        action.setParams({ agreementId : cpl.Agreement__c});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('contract acquired');
                agreement = response.getReturnValue();
                console.log(agreement);
            }
        });  
        $A.enqueueAction(action);
        console.log(agreement);
        

        //var agreement = sforce.connection.query("Select c.Id, a.Chain_Account__c, a.ParentId, a.Natl_Acct_Group_ID__c, c.Name FROM Contract c, c.account a WHERE c.Id = '"+cpl.Agreement__c+"'");
        
        //get regional contract Ids
        const contractsRegional = [];        
        var regional = sforce.connection.query("Select c.Id  FROM Contract c WHERE c.Id = '"+agreement.Account.Chain_Account__c+"'");
        
		for (var i = 0; i < regional.length; i++) {
            contractsRegional.push(regional[i].id);        	
 		}
        
        //call getRelevantContractIds 
        const relevantContracts = new Set(this.getRelevantContractIds(agreement, cpl.Regional_National_Filter__c, contractsRegional));
        
        var activeRecId = sforce.connection.query("select Id,Name from RecordType where sObjectType='zpl__ContractLineItem__c' AND Name = 'Active'");
 		
        /*
         * check first if the usual SF format for accessing parent field works (zpl__PolicyType__r.zpl__PolicyTypeId__c) otherwise
         * continue working on the below format 
        //c for contract line item, p for zpl__PolicyType__r, d for division, q forQuantityBreakUOM__r, 
        //l for zpl__LineLevel__r, pr for zpl__Product__r, u for zpl__UOM__r, 
        //cn for zpl__Contract__r, a for account, rt for recordtype
        var query = "SELECT c.Id, c.Name, c.PricingUOM__c, p.zpl__PolicyTypeId__c,c.Bracket1MinQty__c, c.Bracket1Value__c, c.Bracket1Price__c, c.Bracket2MinQty__c,c.Bracket2Value__c, c.Bracket2Price__c, c.Bracket3MinQty__c,"+
           "c.Bracket3Value__c, c.Bracket3Price__c, c.Bracket4MinQty__c, c.Bracket4Value__c, c.Bracket4Price__c, c.Bracket5MinQty__c, c.Bracket5Value__c, c.Bracket5Price__c, c.Bracket6MinQty__c, c.Product_Composite_Key__c,"+
           "c.Bracket6Value__c, c.Bracket6Price__c, c.CustomerUOM__c, c.Description__c, c.Bracket7MinQty__c, c.Bracket7Value__c,c.Bracket7Price__c, c.Brand__c, c.Brand_Desc__c, c.CPLSortField__c," +
           "c.Class__c, c.Class_Desc__c, c.CustomerSKU__c, c.CustomerCalculatedPrice__c, c.GTM__C, c.aiq_GTM__C, c.Set_Desc__c, c.Customer_Description__c, c.Division__c, d.Division_Code__c, d.Name," +
           "c.ExternalCostDeviationDate__c, c.ExternalCostDeviation__c, c.InternalCostDeviationDate__c, c.InternalCostDeviation__c, c.aiq_Net_Price__c, c.PricingCost__c," +
           "q.Name, c.Quantity_Break_UOM__c, c.SKU__c, c.Segment__c, c.Set__c, c.Subset__c, c.Subset_Desc__c, c.VendorCode__c, c.AIQdt_Vendor__c, c.X12MonthSalesVolume__c,"+
           "c.zpl__LevelValue__c, c.zpl__LineLevel__c, l.Name, c.zpl__PolicyType__c, p.Name, c.zpl__PolicyValue__c, c.zpl__Product__c," +
           "c.zpl__EffectiveDate__c, pr.Brand_Description__c, pr.Class_Description__c, pr.Composite_Key__c," +
           "pr.Description, pr.ProductCode, pr.Set_Description__c, pr.Segment__c, zpl__ContractLineItem__c.Net_Price__c," +
           "pr.Subset_Description__c, pr.Vendor_Product_Code__c, c.zpl__UOM__c, u.Name, pr.Unit_of_Measure__c, c.Publish_Date__c, c.Level_Indicator__c," +
           "rt.Name" +
           "FROM zpl__ContractLineItem__c c" +
           "WHERE zpl__Contract__c IN "+relevantContracts +
            "AND RecordTypeId ="+activeRecId.id + "AND zpl__Status__c = 'Published'";
        
        if(CPLType == "External"){
            query += "AND ( c.aiq_Net_Price__c > 0 OR p.name = 'List Down')";
        }
        */
        
        //SF format below. Use above format if below doesn't work
        var query = "SELECT Id, Name, PricingUOM__c, zpl__PolicyType__r.zpl__PolicyTypeId__c, Bracket1MinQty__c, Bracket1Value__c, Bracket1Price__c, Bracket2MinQty__c, Bracket2Value__c, Bracket2Price__c, Bracket3MinQty__c, "+
            "Bracket3Value__c, Bracket3Price__c, Bracket4MinQty__c, Bracket4Value__c, Bracket4Price__c, Bracket5MinQty__c, Bracket5Value__c, Bracket5Price__c, Bracket6MinQty__c, Product_Composite_Key__c, "+
            "Bracket6Value__c, Bracket6Price__c, CustomerUOM__c, Description__c, Bracket7MinQty__c, Bracket7Value__c, Bracket7Price__c, Brand__c, Brand_Desc__c, CPLSortField__c, " +
            "Class__c, Class_Desc__c, CustomerSKU__c, CustomerCalculatedPrice__c, GTM__C, aiq_GTM__C, Set_Desc__c, Customer_Description__c, Division__c, Division__r.Division_Code__c, Division__r.Name, " +
            "ExternalCostDeviationDate__c, ExternalCostDeviation__c, InternalCostDeviationDate__c, InternalCostDeviation__c, aiq_Net_Price__c, PricingCost__c, " +
            "QuantityBreakUOM__r.Name, Quantity_Break_UOM__c, SKU__c, Segment__c, Set__c, Subset__c, Subset_Desc__c, VendorCode__c, AIQdt_Vendor__c, X12MonthSalesVolume__c, "+
            "zpl__LevelValue__c, zpl__LineLevel__c, zpl__LineLevel__r.Name, zpl__PolicyType__c, zpl__PolicyType__r.Name, zpl__PolicyValue__c, zpl__Product__c, " +
            "zpl__EffectiveDate__c, zpl__Product__r.Brand_Description__c, zpl__Product__r.Class_Description__c, zpl__Product__r.Composite_Key__c, " +
            "zpl__Product__r.Description, zpl__Product__r.ProductCode, zpl__Product__r.Set_Description__c, zpl__Product__r.Segment__c, zpl__ContractLineItem__c.Net_Price__c, " +
            "zpl__Product__r.Subset_Description__c, zpl__Product__r.Vendor_Product_Code__c, zpl__UOM__c, zpl__UOM__r.Name, zpl__Product__r.Unit_of_Measure__c, Publish_Date__c, Level_Indicator__c, " +
            "zpl__Contract__r.Account.RecordType.Name " +
            "FROM zpl__ContractLineItem__c " +
            "WHERE zpl__Contract__c IN "+relevantContracts +
            "AND RecordTypeId ='"+activeRecId.id + "'AND zpl__Status__c = 'Published'";
        
        if(CPLType == "External"){
            query += "AND ( aiq_Net_Price__c > 0 OR zpl__PolicyType__r.name = 'List Down')";
        }
        
        if(cpl.Purchased_Stocked_Filter__c == "Show Purchased Agreement Lines Only"){
            query += "AND X12MonthSalesVolume__c > 0 ";
        }
        
        //KM - Chain Accounts filter
        if(cpl.Regional_National_Filter__c == "Show Chain Accounts Only"){
            query += "AND isCurrent__c = TRUE" ;
        }
        
        //SP-05172022
        if(cpl.Regional_National_Filter__c == "Ignore Regional Chain AND National Agreement Lines (if any)"){
            var strChain = "CHAIN";
            if(!((agreement.Name).includes(strChain))){
                
                query += "AND (NOT Account__c LIKE \'%" + strChain + "%\')";
            }
        }
        
        //If Contract Name DOES NOT CONTAIN CHAIN, 
        //check line items account from zplcontractline, if contains chain do not include  AND //chain
        //check Contracts Account Natl Acct Group ID == Natl Acct Group ID from NationalAccountsPricing__c, if same do not include
        
        
        if (String.isNotBlank(cpl.Division__c)) {
            /*const divisions = cpl.Division__c.split(';');
             *use replace as we will be using string to create the list of records to be queried 
             */ 
            var divisions = cpl.Division__c.replace("/;/g","','");
            query += "AND Division__c IN ('"+divisions+"') ";
        }
        
        if (String.isNotBlank(cpl.Segments__c)) {
            /*const segments = cpl.Segments__c.split(';');
             *use replace as we will be using string to create the list of records to be queried 
             */ 
            var segments = cpl.Segments__c.replace("/;/g","','");
            query += "AND Segments__c IN ('"+segments+"') ";
        }
        
        if (String.isNotBlank(cpl.Classes__c)) {
            /*const classes = cpl.Classes__c.split(';');
             *use replace as we will be using string to create the list of records to be queried 
             */ 
            var classes = cpl.Classes__c.replace("/;/g","','");
            query += "AND Classes__c IN ('"+classes+"') ";
        }
        
        if (String.isNotBlank(cpl.Brands__c)) {
            /*const brands = cpl.Brands__c.split(';');
             *use replace as we will be using string to create the list of records to be queried 
             */ 
            var brands = cpl.Brands__c.replace("/;/g","','");
            query += "AND Brands__c IN ('"+brands+"') ";
        }
        
        if (cpl.New_Or_Changed_Only__c) {
            query += "AND (Publish_Date__c > "+this.effectiveDate +" OR LastModifiedDate > "+ this.effectiveDate +") ";
        }
        
        if (cpl.Purchased_Stocked_Filter__c == "Show Purchased Agreement Lines Only") {
            query += "AND X12MonthSalesVolume__c > 0 ";
        } else if (cpl.Purchased_Stocked_Filter__c == "Show Stock Agreement Lines Only") {
            query += "AND zpl__Product__r.Stocking_Flag__c = true ";
        } else if (cpl.Purchased_Stocked_Filter__c == "Show Purchased Or Stocked Agreement Lines") {
            query +=" AND (X12MonthSalesVolume__c > 0 OR zpl__Product__r.Stocking_Flag__c = true) ";
        }
        
        query +=" ORDER BY zpl__EffectiveDate__c DESC, Publish_Date__c DESC";
        
        var allAgreementLineItems = sforce.connection.query(query);
        
        const queryWithFuture =  sforce.connection.query("SELECT Count(Id), SKU__c skuName FROM zpl__ContractLineItem__c WHERE zpl__Contract__c IN "+relevantContracts+" AND RecordTypeId = "+activeRecId+" AND zpl__Status__c = 'Published' GROUP BY SKU__c HAVING count(Id)>1");
        
        const skuValues = new Set();  
		//Add 'Item #(SKU__c)' values to Set         
        for (var i = 0; i < queryWithFuture.length; i++) {
            skuValues.add(queryWithFuture[i].id);        	
 		}
        
        const agreementWithDuplicates =  sforce.connection.query("SELECT Count(Id), SKU__c skuName FROM zpl__ContractLineItem__c WHERE zpl__Contract__c IN "+relevantContracts+" AND RecordTypeId = "+activeRecId+" AND zpl__Status__c = 'Published' GROUP BY SKU__c HAVING count(Id)>1 AND Name IN "+skuValues);
        
        const aggreementLineSet = new Set();  
        for (var i = 0; i < allAgreementLineItems.length; i++) {
            aggreementLineSet.add(allAgreementLineItems[i].id);        	
 		}
        
        const resultIds = new Set();  
        for (var i = 0; i < agreementWithDuplicates.length; i++) {
            resultIds.add(agreementWithDuplicates[i].id);        	
 		}
        
        //aggreementLineSet.removeAll(resultIds);
		//no removeAll for javascript. use a loop instead
        for (var i = 0; i < resultIds.length; i++) {
            aggreementLineSet.delete(resultIds[i]);        	
 		}
        
        const agreementLineNoDupes = [];
        if(aggreementLineSet.size>0){
        	agreementLineNoDupes = sforce.connection.query("SELECT Id, zpl__LevelValue__c, zpl__EffectiveDate__c, Level_Indicator__c, CPLSortField__c, Segment__c, Division__c,  Division__r.Division_Code__c, Division__r.Name, Name, PricingUOM__c, zpl__PolicyType__r.zpl__PolicyTypeId__c, Bracket1MinQty__c, Bracket1Value__c, Bracket1Price__c, Bracket2MinQty__c, Bracket2Value__c, Bracket2Price__c, Bracket3MinQty__c,Bracket3Value__c, Bracket3Price__c, Bracket4MinQty__c, Bracket4Value__c, Bracket4Price__c, Bracket5MinQty__c, Bracket5Value__c, Bracket5Price__c, Bracket6MinQty__c,Bracket6Value__c, Bracket6Price__c, CustomerUOM__c, Description__c, Bracket7MinQty__c, Bracket7Value__c, Bracket7Price__c, Brand__c, Brand_Desc__c, Class__c, Class_Desc__c, CustomerSKU__c, CustomerCalculatedPrice__c, GTM__C, aiq_GTM__C, Set_Desc__c, Customer_Description__c, ExternalCostDeviationDate__c, ExternalCostDeviation__c, InternalCostDeviationDate__c, InternalCostDeviation__c, aiq_Net_Price__c, PricingCost__c ,QuantityBreakUOM__r.Name, Quantity_Break_UOM__c, SKU__c, Set__c, Subset__c, Subset_Desc__c, VendorCode__c, AIQdt_Vendor__c, X12MonthSalesVolume__c, zpl__LineLevel__c, zpl__LineLevel__r.Name, zpl__PolicyType__c, zpl__PolicyType__r.Name, zpl__PolicyValue__c, zpl__Product__c, zpl__Product__r.Brand_Description__c, zpl__Product__r.Class_Description__c, zpl__Product__r.Composite_Key__c, Product_Composite_Key__c, zpl__Product__r.Description, zpl__Product__r.ProductCode, zpl__Product__r.Set_Description__c, zpl__Product__r.Segment__c, zpl__ContractLineItem__c.Net_Price__c,zpl__Product__r.Subset_Description__c, zpl__Product__r.Vendor_Product_Code__c, zpl__UOM__c, zpl__UOM__r.Name, zpl__Product__r.Unit_of_Measure__c, Publish_Date__c, zpl__Contract__r.Account.RecordType.Name FROM zpl__ContractLineItem__c WHERE zpl__Contract__c IN"+ relevantContract + " AND RecordTypeId = "+activeRecId+ "AND zpl__Status__c = 'Published' AND Id IN "+aggreementLineSet+" ORDER BY zpl__EffectiveDate__c DESC, Publish_Date__c DESC");    
        }
        
        const classificationsToProducts = new Map();
        
        
        if(cpl.Level_Filter__c == "Item Level (Expand Sets and Subsets)"){
        	const setLevelAgreementLineItems = []; 
            setLevelAgreementLineItems = this.getLineLevelAgreementLineItems(allAgreementLineItems, "Set");
            const subsetLevelAgreementLineItems = []; 
            subsetLevelAgreementLineItems = this.getLineLevelAgreementLineItems(allAgreementLineItems, "Subset");
            
            if (setLevelAgreementLineItems.length > 0) {
                var setQuery = "SELECT Id, Name, IsActive, Unit_of_Measure__c, " +
                    "Brand__c, Brand_Description__c, Class__c, Class_Description__c, Composite_Key__c,"  +
                    "Description, ProductCode, Set__c, Set_Description__c, Division_Name__r.Name, Division_Name__c, Division_Name__r.Division_Code__c,"  +
                    "Subset__c, Subset_Description__c, Vendor_Product_Code__c, zpl__UOM__c, Pricing_Costing_UOM__c,"  +
                    "Segment__c"  +
                    " FROM Product2 "+
                    "WHERE" ;
                
                const setLevelFilters = new Set();
                for (var i = 0; i < setLevelAgreementLineItems.length; i++) {
            		setLevelFilters.add("(Division_Name__c = "+ (setLevelAgreementLineItems[i].Division__c ==null ? "null ":  ("'" + setLevelAgreementLineItems[i].Division__c) + "'")+
                                       "AND Class__c = " + "'" + setLevelAgreementLineItems[i].Class__c + "'" +
                                       "AND Brand__c = " + "'" + setLevelAgreementLineItems[i].Brand__c + "'" +
                                       "AND Set__c = " + "'" + setLevelAgreementLineItems[i].Set__c + "'" +
                                       "AND IsActive = TRUE)");        	
 				}
                setQuery += Array.from(setLevelFilters).join(' OR ');
                
                const setProducts =  sforce.connection.query(setQuery);
                
                if(!setProducts.length==false && Array.isArray(setProducts) ){
                    //if setProducts is not null
                    for (var i = 0; i < setProducts.length; i++) {
                    	var classification = setProducts[i].Division_Name__r.Division_Code__c + setProducts[i].Class__c + setProducts[i].Brand__c + setProducts[i].Set__c;
                        if(classificationsToProducts.has(classification)){
                        	classificationsToProducts.get(classification).add(setProducts[i]);	
                        }else{
                        	const classificationsToProductsVal = setProducts.slice();    
                            classificationsToProducts.set(classification, classificationsToProductsVal);
                        }
                                               
                    }
                }
            }
            //subset
            if (subsetLevelAgreementLineItems.length > 0) {
            	var subsetQuery = "SELECT Id, Name, IsActive, Unit_of_Measure__c, " +
                    "Brand__c, Brand_Description__c, Class__c, Class_Description__c, Composite_Key__c,"  +
                    "Description, ProductCode, Set__c, Set_Description__c, Division_Name__r.Name, Division_Name__c, Division_Name__r.Division_Code__c,"  +
                    "Subset__c, Subset_Description__c, Vendor_Product_Code__c, zpl__UOM__c, Pricing_Costing_UOM__c,"  +
                    "Segment__c"  +
                    " FROM Product2 "+
                    "WHERE" ;
                
                const subsetLevelFilters = new Set();
                for (var i = 0; i < subsetLevelAgreementLineItems.length; i++) {
            		setLevelFilters.add("(Division_Name__c = "+ (subsetLevelAgreementLineItems[i].Division__c ==null ? "null ":  ("'" + subsetLevelAgreementLineItems[i].Division__c) + "'")+
                                       "AND Class__c = " + "'" + subsetLevelAgreementLineItems[i].Class__c + "'" +
                                       "AND Brand__c = " + "'" + subsetLevelAgreementLineItems[i].Brand__c + "'" +
                                       "AND Set__c = " + "'" + subsetLevelAgreementLineItems[i].Set__c + "'" +
                                       "AND IsActive = TRUE)");      
                    subsetQuery += Array.from(subsetLevelFilters).join(' OR ');
                
                	const subsetProducts =  sforce.connection.query(subsetQuery);
                
                    if(!subsetProducts.length==false && Array.isArray(subsetProducts) ){
                        //if subsetProducts is not null
                        for (var i = 0; i < subsetProducts.length; i++) {
                            var classification = subsetProducts[i].Division_Name__r.Division_Code__c + subsetProducts[i].Class__c + subsetProducts[i].Brand__c + subsetProducts[i].Set__c;
                            if(classificationsToProducts.has(classification)){
                                classificationsToProducts.get(classification).add(subsetProducts[i]);	
                            }else{
                                const classificationsToProductsVal = subsetProducts.slice();    
                                classificationsToProducts.set(classification, classificationsToProductsVal);
                            }
                                                   
                        }
                    }
 				}
            }
        }
        //create AgreementLineItemWrapper based on retrieved records
        const agreementLineItems = [];
        const levelValuesToAgreementLineItems = new Map(); 
        for (var i = 0; i < allAgreementLineItems.length; i++) {
            if(levelValuesToAgreementLineItems.has(allAgreementLineItems[i].zpl__LevelValue__c)){
                levelValuesToAgreementLineItems.get(allAgreementLineItems[i].zpl__LevelValue__c).add(allAgreementLineItems[i]);
            }else{
                const allAgreementLineItemsVal = allAgreementLineItems.slice();
                levelValuesToAgreementLineItems.set(allAgreementLineItems[i].zpl__LevelValue__c, allAgreementLineItemsVal);
            }
        }
        const agreementLineItemFutureHolder = [];
        
        for (let keyVal of levelValuesToAgreementLineItems.keys()) {
			const agreementLineItemsForRecord = levelValuesToAgreementLineItems[keyVal].slice();	
            
            for (var i = 0; i < agreementLineItemsForRecord.length; i++) {
            	var agreementLineItem = agreementLineItemsForRecord[i];
            	var wrapper;
                wrapper.currentAgreementLineItem = agreementLineItem;
                //effectiveDate check
                if(agreementLineItem.zpl__EffectiveDate__c <= this.effectiveDate){
                	if(!agreementLineItemFutureHolder.length==false && Array.isArray(agreementLineItemFutureHolder)){
                    	for(var j = 0; j < agreementLineItemFutureHolder.length; j++){
                        	const todaysDate = new Date();	
                            if(agreementLineItemFutureHolder[j].SKU__c == agreementLineItem.SKU__c && agreementLineItemFutureHolder[j].Name == agreementLineItem.Name && agreementLineItemFutureHolder[j].zpl__EffectiveDate__c != System.today()){
                                
                                wrapper.futureAgreementLineItem = futureLine;
                                //System.debug('futureLine ' + futureLine);
                            }
                        }
                    }
                    if (i > 0){
                            wrapper.futureAgreementLineItem = agreementLineItemsForRecord[i - 1];
                    } 
                    if (cpl.Level_Filter__c == "Item Level (Expand Sets and Subsets)" && classificationsToProducts.size > 0){
                    	if (agreementLineItem.zpl__LineLevel__c != null && agreementLineItem.zpl__LineLevel__r.Name == "Set"){
                            var classification = agreementLineItem.Division__r.Division_Code__c + agreementLineItem.Class__c
                                + agreementLineItem.Brand__c + agreementLineItem.Set__c;
                            if (classificationsToProducts.has(classification)) {
                                wrapper.childProducts = classificationsToProducts.get(classification);
                            }
                        }	
                        
                        if (agreementLineItem.zpl__LineLevel__c != null && agreementLineItem.zpl__LineLevel__r.Name == 'Subset'){
                        	var classification = agreementLineItem.Division__r.Division_Code__c + agreementLineItem.Class__c
                                + agreementLineItem.Brand__c + agreementLineItem.Set__c + agreementLineItem.Subset__c;
                            if (classificationsToProducts.has(classification)) {
                                wrapper.childProducts = classificationsToProducts.get(classification);
                            }
                        }
                    }
                    agreementLineItems.add(wrapper);
                    break;
                    
                }else if(agreementLineItem.zpl__EffectiveDate__c > this.effectiveDate){
                	agreementLineItemFutureHolder.add(agreementLineItem);   	
                }
            }            
		}
        //[START] Backlog Item 2810
        
        const levelValuesToAgreementLineFutureOnly = new Map(); 
        for (var i = 0; i < agreementLineNoDupes.length; i++) {
            if(levelValuesToAgreementLineItems.has(agreementLineNoDupes[i].zpl__LevelValue__c)){
                levelValuesToAgreementLineItems.get(agreementLineNoDupes[i].zpl__LevelValue__c).add(agreementLineNoDupes[i]);
            }else{
                const agreementLineNoDupesVal = agreementLineNoDupes.slice();
                levelValuesToAgreementLineItems.set(agreementLineNoDupes[i].zpl__LevelValue__c, agreementLineNoDupes);
            }
        }
        const agreementLineItemFutureOnlyHolder = [];
        for (let keyVal of levelValuesToAgreementLineFutureOnly.keys()) {
			const agreementLineItemsForRecordFutureOnly = levelValuesToAgreementLineFutureOnly[keyVal].slice();	
            
            for (var i = 0; i < agreementLineItemsForRecordFutureOnly.length; i++) {
            	var agreementLineItemFutureOnly = agreementLineItemsForRecordFutureOnly[i];
            	var wrapper;
                wrapper.currentAgreementLineItem = agreementLineItemFutureOnly;
                //effectiveDate check
                if(agreementLineItem.zpl__EffectiveDate__c <= this.effectiveDate){
                    wrapper.futureAgreementLineItemOnly = agreementLineItemsForRecordFutureOnly[i]; 
                }
                agreementLineItems.add(wrapper);
                    //system.debug('agreementLineItem444 : '+agreementLineItems);
                break;
            }
        }
        //[END] Backlog Item 2810
        //Skip sorting for now as this is a POC
        return agreementLineItems;
        
    },
    
    getRelevantContractIds: function(agreement, regionalNationalFilter, regionalFilter){
    	const contractIds = new Set();   
        var regionalContractExists = regionalFilter.length>0;
        contractIds.add(agreement.id);
        
        if ((regionalContractExists && ( regionalNationalFilter == "Show Current and Chain Account Pricing" || regionalNationalFilter == "Show Regional Chain AND National Agreement Lines (if any)"))){
            for(var i = 0; i < regionalFilter.length; i++){              
                contractIds.add(regionalFilter[i]);
            }
        }
        //KM - Chain Accounts filter
        else if(regionalContractExists && regionalNationalFilter == "Show Chain Accounts Only"){
            contractIds = new Set(regionalFilter);
            //contractIds.addAll(regionalFilter);
        }
        
        return contractIds;
    },    
    
    getLineLevelAgreementLineItems: function(agreementLineItems, lineLevel){
        const lineLevelSubsetAgreementLineItems = [];
        
        for (var i = 0; i < agreementLineItems.length; i++) {
            if (agreementLineItem[i].zpl__LineLevel__c != null && agreementLineItem[i].zpl__LineLevel__r.Name == lineLevel){
            	lineLevelSubsetAgreementLineItems.add(agreementLineItems[i].id); 
            }
        }
        return lineLevelSubsetAgreementLineItems;
    }
})
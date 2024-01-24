({
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
        let cpl = component.get("v.cpl");

        let dependentFieldFilters;
        if (cpl) {
            dependentFieldFilters = {
                "Division__c": cpl.Division__c || "",
                "Segments__c": cpl.Segments__c || "",
                "Classes__c": cpl.Classes__c || "",
                "Brands__c": cpl.Brands__c || ""
            };
        } else {
            dependentFieldFilters = {
                "Division__c": "",
                "Segments__c": "",
                "Classes__c": "",
                "Brands__c": ""
            };
        }

        return helper.executeAction(
            component,
            "getDependentPicklistValues", 
            {
                "cpl": component.get("v.cpl"),
                "filters": dependentFieldFilters
            }
        ).then($A.getCallback(function (result) {
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
    
    showToast: function(message, isError) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": message,
            "type": isError ? "error" : "success",
        });
        toastEvent.fire();
    }
})
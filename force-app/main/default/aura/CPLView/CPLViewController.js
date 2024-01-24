({
	doInit: function (component, event, helper) {
		component.set("v.showSpinner", true);
        
		if (component.get("v.recordId")) {
			component.set("v.isEdit", true);
			//Temporary Fix to get to working state
			/*helper.getAgreementIdFromNameAction(component, helper)
			.then(function () {
				return helper.getCPLByIdAction(component, helper)
			}).then(function () {
				return helper.getDependentPicklistValuesAction(component, helper);
			}).then(function () {
				return helper.getSalesRepOptionsAction(component, helper);
			}).then(function () {
				return helper.getCustomerPriceListName(component, helper);
			}).then(function () {
				component.find("cpl-preview").updatePreview();
				component.set("v.showSpinner", false);
			}).catch(function (error) {
				helper.showToast(error.message, true);	
			});*/
            
            helper.getCPLByIdAction(component, helper)
			.then(function () {
				return helper.getDependentPicklistValuesAction(component, helper);
			}).then(function () {
				return helper.getSalesRepOptionsAction(component, helper);
			}).then(function () {
				return helper.getCustomerPriceListName(component, helper);
			}).then(function () {
				component.find("cpl-preview").updatePreview();
				component.set("v.showSpinner", false);
			}).catch(function (error) {
				helper.showToast(error.message, true);	
			});
		} else {
            let qsVars = component.get("v.pageReference.state");
			component.set("v.recordTypeId", qsVars.recordTypeId);

			let cpl = {};
			cpl.RecordTypeId = qsVars.recordTypeId;
			component.set("v.cpl", cpl);
            
            console.log("cpl : " + cpl);
			
			helper.getAgreementIdFromNameAction(component, helper)
			.then(function () {
				return helper.getDefaultCPLAction(component, helper);
			}).then(function () {
				return helper.getRecordTypeByIdAction(component, helper);
			}).then(function () {
				return helper.getDependentPicklistValuesAction(component, helper);
			}).then(function () {
				return helper.getSalesRepOptionsAction(component, helper);
			}).then(function () {
				return helper.getCustomerPriceListName(component, helper);
			}).then(function () {
				component.set("v.cpl.Sales_Rep__c", component.get("v.salesRepOptions")[0].Id);
				
				component.find("cpl-preview").updatePreview();
				component.set("v.showSpinner", false);
			}).catch(function (error) {
				helper.showToast(error.message, true);	
			});
		}
	},

	handleSubmit: function (component, event, helper) {
		event.preventDefault();

		const cpl = component.get("v.cpl");

		component.find("cpl-preview").updatePreview();

		if (component.get("v.mode") == "schedule") {
            if (cpl.Customer_Email__c) {
                component.set("v.showSpinner", true);
			
				component.find("cpl-record-edit-form").submit(cpl);
            } else {
             	helper.showToast('Customer Email is required to schedule a CPL.', true);
            }	
		} else if (component.get("v.mode").indexOf("download") > -1) {
			let cpl = component.get("v.cpl");
			let downloadUrl = component.get("v.mode") == "downloadXLS" ? "/apex/CPLXLS?" : "/apex/CPLPDF?";
			
			if (cpl.Id) {
				delete cpl.Id;
			}

			let urlParams = [];
			for (let field in cpl) {
				if (cpl[field]) {
					urlParams.push(encodeURI(field + "=" + cpl[field]));
				}
			}
			
			downloadUrl += urlParams.join("&");

			const win = window.open(downloadUrl, '_blank');
  			win.focus();
		}
	},

	handleSuccess: function (component, event, helper) {
		setTimeout($A.getCallback(function() {
			const navigate = $A.get("e.force:navigateToSObject");
			navigate.setParams({
				"recordId": component.get("v.cpl").Agreement__c,
				"slideDevName": "Related"
			});
			navigate.fire();
		}), 2000);
	},

	handleUpdatePreview: function (component, event, helper) {
		component.set("v.mode", "updatePreview");
	},

	handleDownloadPDF: function (component, event, helper) {
		component.set("v.mode", "downloadPDF");
	},

	handleDownloadXLS: function (component, event, helper) {
		component.set("v.mode", "downloadXLS");
	},

	handleSchedule: function (component, event, helper) {
		component.set("v.mode", "schedule");
	},

	handleShowSpinnerChange: function (component, event, helper) {
		const cplView = component.find("cpl-view");
		if (component.get("v.showSpinner") && component.get("v.mode") != 'schedule') {
			$A.util.addClass(cplView, "slds-hidden");
		} else {
			$A.util.removeClass(cplView, "slds-hidden");
		}
	},

	handleRecordEditFormFieldChange: function (component, event, helper) {
		if (event.getParam("value") || event.getParam("checked") != undefined) {
			let cpl = component.get("v.cpl");
            console.log('event.getSource().get("v.value") '+event.getSource().get("v.value"));
			cpl[event.getSource().get("v.fieldName")] = event.getSource().get("v.value");
			component.set("v.cpl", cpl);

			helper.getDependentPicklistValuesAction(component, helper);
			component.find("cpl-preview").updatePreview();
		}
	},

	handleRecordEditFormFieldChangeAndDoNotRefresh: function (component, event, helper) {
		if (event.getParam("value")) {
			let cpl = component.get("v.cpl");
			cpl[event.getSource().get("v.fieldName")] = event.getSource().get("v.value");
			component.set("v.cpl", cpl);

			helper.getDependentPicklistValuesAction(component, helper);
		}
	},

	handleMonitoredFieldChange: function (component, event, helper) {
		helper.getDependentPicklistValuesAction(component, helper);
		
		component.find("cpl-preview").updatePreview();
	},

	handleIndependentFieldChange: function (component, event, helper) {
		component.find("cpl-preview").updatePreview();
	},
    
    handleCustomerEmailChange: function (component, event, helper) {
        if (event.getParam("value")) {
            let cpl = component.get("v.cpl");
            cpl["Customer_Email__c"] = event.getSource().get("v.value");
            component.set("v.cpl", cpl);
        }
	},
    
    handleBackToContract : function(component, event, helper) {
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({
            "recordId": component.get("v.cpl").Agreement__c
        });
        navigateEvent.fire();
    }
})
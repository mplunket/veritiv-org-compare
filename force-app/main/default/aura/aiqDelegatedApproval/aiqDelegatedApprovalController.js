({
	doInit : function(component, event, helper) {         
        helper.loadForm(component, event);        
        helper.loadData(component);       
    },
    
    handleclose : function(component, helper) {
        component.set("v.hasErrors", false);
    	component.set("v.message", null);
        component.set("v.actionName", null);  
    },
	
    handleSubmit : function(component, event, helper) {
        component.set("v.hasErrors", false);
    	component.set("v.message", null);
        component.set("v.loadingInProgress", true);
        
        event.preventDefault(); // Prevent default submit
		
        var delegatedApprover = component.get('v.lookupRecordId');
		var startDate = component.find('Delegation_Start_Date').get('v.value');
        var endDate = component.find('Delegation_End_Date').get('v.value');
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
		
        if( delegatedApprover === null || typeof delegatedApprover === 'undefined' ||  delegatedApprover.length < 1) { 
            var message = 'Delegated approver must be selected';
            component.set("v.message", message);
            component.set("v.hasErrors", true);
            component.set("v.loadingInProgress", false)
        } else if((startDate >= today) && (endDate >= startDate)) {
            var fields = event.getParam("fields");
            component.find('recordViewForm').submit(fields); // Submit form
        } else if (startDate < today) {
            var message = 'Start date should be greater than current date';
            component.set("v.message", message);
            component.set("v.hasErrors", true);
            component.set("v.loadingInProgress", false)
        } else {
            var message = 'Start date must be anterior to end date';
            component.set("v.message", message);
            component.set("v.hasErrors", true);
            component.set("v.loadingInProgress", false)
        }
    },
	
    handleCancel: function(component, event, helper) {
        component.set("v.hasErrors", false);
        component.set("v.message", null);
        component.set("v.loadingInProgress", true);
        
        component.set('v.lookupRecordId', '');
        component.find('Delegation_Start_Date').set('v.value', '');
        component.find('Delegation_End_Date').set('v.value', '');
        var fields = event.getParam("fields");
        component.find('recordViewForm').submit(fields); // Submit form
    },
    
    handleSuccess: function(component, event, helper) {
        var message = 'Delegated Approver saved!';
        component.set("v.message", message);
        component.set("v.hasErrors", true);
        component.set("v.loadingInProgress", false)
    },
    
    handleChange: function (component, event) {
    }
})
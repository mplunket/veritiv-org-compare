({
    doInit : function(component, event, helper) {       
        var currentUserId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.recordId", currentUserId);

        var action = component.get('c.fetchUser');  
        action.setParams({  
            userId : currentUserId  
        });
        action.setCallback(this, function(response) {  
            var state = response.getState();  
            if ( state === 'SUCCESS' && component.isValid() ) {  
                component.set('v.lookupRecordId', response.getReturnValue().Pricing_Delegated_Approver__c);  
            }
        });  
        $A.enqueueAction(action); 
    },
    
    handleSubmit : function(component, event, helper) {
        component.set("v.hasErrors", false);
        component.set("v.loadingInProgress", true)
        
        event.preventDefault(); // Prevent default submit
		
        var delegatedApprover = component.get('v.lookupRecordId');
		var startDate = component.find('Delegation_Start_Date').get('v.value');
        var endDate = component.find('Delegation_End_Date').get('v.value');
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
		
        if( delegatedApprover === null || typeof delegatedApprover === 'undefined' ||  delegatedApprover.length < 1) { 
            var message = 'Delegated approver must be selected';
            helper.handleMessage(component, event, helper, 'error', message);
        } else if((startDate >= today) && (endDate >= startDate)) {
            var fields = event.getParam("fields");
            component.find('recordViewForm').submit(fields); // Submit form
        } else if (startDate < today) {
            var message = 'Start date should be greater than current date';
            helper.handleMessage(component, event, helper, 'error', message);
        } else {
            var message = 'Start date must be anterior to end date';
            helper.handleMessage(component, event, helper, 'error', message);
        }
    },
	
    handleCancel: function(component, event, helper) {
        component.set('v.lookupRecordId', '');
        component.find('Delegation_Start_Date').set('v.value', '');
        component.find('Delegation_End_Date').set('v.value', '');
        var fields = event.getParam("fields");
        component.find('recordViewForm').submit(fields); // Submit form
    },
    
    handleSuccess: function(component, event, helper) {
        var message = 'Delegated Approver saved!';
        helper.handleMessage(component, event, helper, 'success', message);
        
        // Close the action panel 
        $A.get("e.force:closeQuickAction").fire();
        
        //$A.get("e.force:refreshView").fire();
    },
    
    handleChange: function (component, event) {
    }
})
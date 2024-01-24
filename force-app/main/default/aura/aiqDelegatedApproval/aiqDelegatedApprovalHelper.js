({
	loadForm : function(component, event) {
		component.set("v.loadingInProgress", true);
        var actionName = event.getParam("actionName");
        component.set("v.actionName", actionName);
        
	},
    
    loadData : function(component) {
        component.set("v.loadingInProgress", true);
        
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
        
		component.set("v.loadingInProgress", false);
	},
})
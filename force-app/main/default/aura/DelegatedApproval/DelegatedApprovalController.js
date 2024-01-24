({
    doInit: function(component, event, helper){ 
		var userId = $A.get("$SObjectType.CurrentUser.Id");
        helper.searchHelper(component, event, userId);
    } ,
    
    handleLoad : function(component, event, helper) {
        var recordId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.recordId", recordId);
    },
    
    handleSave: function(component, event, helper) {
        
        // Display the Answer in a "toast" status message 
        var resultsToast = $A.get("e.force:showToast"); 
        resultsToast.setParams({ 
            "title": "Delegated Approval: " , 
            "message": "Delegated Approval was updated!" 
        });
        resultsToast.fire(); 
        
        // Close the action panel 
		$A.get("e.force:closeQuickAction").fire();
    },
    
    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})
({
    handleMessage:  function(component, event, helper, type, message) {      
        var resultsToast = $A.get("e.force:showToast"); 
        resultsToast.setParams({
            type: type,
            message: message
        });
        resultsToast.fire();  
    },
})
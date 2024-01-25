({
	doInit : function(component, event, helper) {
        component.set("v.loadingInProgress", true);
        var action = component.get("c.getReportURL");
        action.setParams({"reportIdField": component.get("v.reportIdField")});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var resp = response.getReturnValue();
                component.set("v.ResourceURI", resp);   
                component.set("v.loadingInProgress", false);
                    
            } else {                
                let errors = response.getError();
                component.set("v.hasErrors", true);
                
                let errorMsg = errors[0].message;
                let errorObj = JSON.parse(errorMsg);
                console.error(errorMsg);
                
                let errorMsgText = errorObj.dmlExceptionData ? errorObj.dmlExceptionData.errorMessage 
                : (errorObj.message ? errorObj.message 
                   : 'Something went wrong. Check console log for details.');
                
                component.set("v.message", errorMsgText);
                component.set("v.loadingInProgress", false);
            }           
        });
        
        $A.enqueueAction(action);
	}
    
})
({   
    validateUser : function(component) {
        var action = component.get("c.validateUser");
                
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var resp = response.getReturnValue();
                component.set("v.viewAsUser", resp.isPricingManager);
            } else {
                console.log('Error trying to validate user');
            }           
        });
        $A.enqueueAction(action);
    }
                           
                           
})
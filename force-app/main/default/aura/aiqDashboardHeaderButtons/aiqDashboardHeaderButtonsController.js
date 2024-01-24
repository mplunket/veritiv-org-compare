({
    doInit : function(component, event, helper) {
        var action = component.get("c.validateUser");
                
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var resp = response.getReturnValue();
                component.set("v.isVisible", resp.isPricingManager);
                component.set("v.delegateAllowed", resp.delegateApprAllowed);
                console.log('delegateAllowed = '+ component.get("v.delegateAllowed"))
            } else {
                console.error('Error trying to validate user');
            }           
        });
        $A.enqueueAction(action);
    },    
    
    goToURL : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "https://veritivpg.my.salesforce.com"
        });
        urlEvent.fire();
    }
})
({
    doInit: function (component, event, helper) {
        var action = component.get("c.getUITheme");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.ui_theme', response.getReturnValue());
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.error', errors[0].message);
                    }
                } else {
                    component.set('v.error', 'Unknown error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    syncAccount: function (component, event, helper) {
        var action = component.get("c.syncAccountWithDnB");

        action.setParams({
            accountId: component.get('v.account').Id,
            duns: component.get('v.match').organization.duns,
            confidenceCode: component.get('v.match').matchQualityInformation.confidenceCode,
            accName: component.get('v.match').organization.primaryName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {

                component.set('v.error', null);

                const isClassic = component.get('v.isClassic');
                console.log(isClassic);
                if (isClassic) {
                    window.location.href = '/' + component.get('v.account').Id                    
                } 
                if(component.get("v.isCalled")){
                    var applicationEvent = $A.get("e.c:callToCreditEvent");                  
                    applicationEvent.setParam("isOpen", false);
                    applicationEvent.setParam("isEmpty", false);
                    applicationEvent.fire();	
                }
                else {
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.error', errors[0].message);
                    }
                } else {
                    component.set('v.error', 'Unknown error');
                }
            }
        });
        $A.enqueueAction(action);
    },
    
})
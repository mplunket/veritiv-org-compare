({
    doInit: function (component, event, helper) {
        var action = component.get("c.getAccount");
        action.setParams({
            id: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var account = response.getReturnValue();
                component.set('v.account', account);
                component.set('v.error', null);
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

    goBack: function (component, event, helper) {
        component.set('v.searchResults', null);
    }
})
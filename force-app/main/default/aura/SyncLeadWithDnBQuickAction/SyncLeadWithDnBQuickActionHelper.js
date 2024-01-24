({
	doInitHelper: function (component) {
        var action = component.get("c.getLead");
        action.setParams({
            id: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var lead = response.getReturnValue();
                component.set('v.lead', lead);
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
})
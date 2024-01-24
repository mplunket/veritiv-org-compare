({
	doInitHelper: function (component) {
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

    syncLeadHelper: function (component) {
        var action = component.get("c.syncLeadWithDnB");

        action.setParams({
            leadId: component.get('v.lead').Id,
            duns: component.get('v.match').organization.duns,
            confidenceCode: component.get('v.match').matchQualityInformation.confidenceCode
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {

                component.set('v.error', null);

                const isClassic = component.get('v.isClassic');
                if (isClassic) {
                    window.location.href = '/' + component.get('v.lead').Id                    
                } else {
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
    }
})
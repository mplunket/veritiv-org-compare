({
    translateCountry: function (component, event, helper) {
        const country = component.get("v.account").BillingCountry;
        const normalization = component.find("countryNormalizationAPI");
        component.set("v.translatedCountry", normalization.getCode(country));
    },

    
    search: function (component, event, helper) {
        var action = component.get("c.getMatches");
        const account = component.get('v.account');
        account.BillingCountry = component.get("v.translatedCountry");
        action.setParams({
            acc: account,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var dnbResponse = JSON.parse(response.getReturnValue());
                component.set('v.searchResults', dnbResponse);
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

    showHelpText: function (component, event, helper) {
        var button = event.currentTarget.id;
        var field = button.split('-')[0];
        var tooltip = document.getElementById(field + '-helptext-tooltip');
        tooltip.style.display = 'block';
    },

    hideHelpText: function (component, event, helper) {
        var button = event.currentTarget.id;
        var field = button.split('-')[0];
        var tooltip = document.getElementById(field + '-helptext-tooltip');
        tooltip.style.display = 'none';
    }
})
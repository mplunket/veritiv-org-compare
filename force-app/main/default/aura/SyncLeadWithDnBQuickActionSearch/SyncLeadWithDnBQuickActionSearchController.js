({
    translateCountry: function (component, event, helper) {
        const country = component.get("v.lead").Country;
        const normalization = component.find("countryNormalizationAPI");
        component.set("v.translatedCountry", normalization.getCode(country));
    },

    search: function (component, event, helper) {
        helper.searchHelper(component);
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
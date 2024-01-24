({
    doInit: function (component, event, helper) {
        helper.doInitHelper(component);
    },

    goBack: function (component, event, helper) {
        component.set('v.searchResults', null);
    }
})
({
    doInit: function (component, event, helper) {
        helper.setFinalizer(component, event);
    },

    handleCloseDialog: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
});
({
    handleEvent: function (component, event, helper) {
        event.stopPropagation();
        helper.runAction(component, event);
    },

    handleActionCompleteEvent: function (component, event, helper) {
        event.stopPropagation();
        helper.completeAction(component, event, helper);
    }
    
});
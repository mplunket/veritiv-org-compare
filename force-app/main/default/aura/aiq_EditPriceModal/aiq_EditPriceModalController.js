({
    handleEvent: function (component, event, helper) {
        event.stopPropagation();
        helper.runAction(component, event);
    },

    handleActionCompleteEvent: function (component, event, helper) {
        event.stopPropagation();
        helper.completeAction(component, event, helper);
    },

    handleCopyFinish: function (component, event, helper) {
        event.stopPropagation();
        helper.openPriceModalDynamically(component, event);
    },

    handleClose: function (component, event, helper) {
        try {
            const src = event.getSource().getLocalId();
            if(src!=="editPriceDialog"){
                return;
            }
            component.set("v.priceModalComponent", []);
            const params = event.getParams();
            helper.runOnClose(component, event);
        } catch (error) {
            console.error(`${error.name}: ${error.message}`);
        }
    },

    handleSave: function (component, event, helper) {
        try {
            component.set("v.priceModalComponent", []);
            const params = event.getParams();
            helper.runOnSave(component, event);
        } catch (error) {
            console.error(`${error.name}: ${error.message}`);
        }
    }
});
({
    setFinalizer: function (component, event) {
        component.set("v.runSecondaryFunction", this.finalize.bind(this));
    },

    finalize: function (component, that) {
        const customMessage = component.get("v.actionDTO").customMessage;
        if (customMessage) {
            that.fireToast(
                customMessage.type,
                customMessage.mode,
                customMessage.finalMessage ? customMessage.finalMessage : that.beautifyString(JSON.stringify(customMessage.messages)),
                customMessage.toastDuration
            );
        }
        $A.get("e.force:refreshView").fire();
    }
});
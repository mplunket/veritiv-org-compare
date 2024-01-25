({
    setFinalizer: function (component, event) {
        component.set("v.runSecondaryFunction", this.finalizer.bind(this));
    },

    finalizer: function (cmp, that) {
        try {
            if (cmp.get("v.hasErrors")) {
                return;
            }
            cmp.set("v.isActionFinalized", true);
        } catch (e) {
            console.error(`${e.name}: ${e.message}`);
        }
    }

});
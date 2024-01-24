({
    doInit: function (component, event, helper) {
        let scope = {'contractId' : component.get("v.recordId")};
        component.set("v.scope", scope);
    }
})
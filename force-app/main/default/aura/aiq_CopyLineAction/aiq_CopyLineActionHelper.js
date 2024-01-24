({
    setFinalizer: function (component, event) {
        component.set("v.runSecondaryFunction", this.navigateToLinePage.bind(this));
    },

    navigateToLinePage: function (component, that) {
        const navService = component.find("navService");
        const pageReference = {
            type: "standard__recordPage",
            attributes: {
                recordId: component.get("v.recordIds")[0],
                objectApiName: "zpl__ContractLineItem__c",
                actionName: "view"
            }
        };
        navService.navigate(pageReference);
    }
});
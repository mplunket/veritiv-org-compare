({
	onRecordCountChange : function(component, event, helper) {
        const recordCount = component.get("v.recordCount");
        const index = component.get("v.tabIndex");

        component.set("v.count", recordCount[index]);
	},

    onObjectSelect : function(component, event, helper) {
        component.set("v.selectedObject", event.getSource().get("v.id"));
    }
})
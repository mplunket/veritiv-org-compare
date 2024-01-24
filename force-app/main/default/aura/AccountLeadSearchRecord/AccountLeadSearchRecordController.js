({
    doInit : function(component, event, helper) {
        const record = component.get("v.record");

        const fieldToString = function(field) {
            return field.value;
        }

        component.set("v.headerString", record.headerFields.map(fieldToString).join(", "));
        component.set("v.subHeaderString", record.subHeaderFields.map(fieldToString).join(", "));
    },

	onRecordClick : function(component, event, helper) {
        component.set("v.expand", !component.get("v.expand"));
	}
})
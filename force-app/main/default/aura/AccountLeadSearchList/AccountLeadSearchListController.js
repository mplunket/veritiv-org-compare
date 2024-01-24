({
    onFormatWrappersChange : function(component, event, helper) {
        const formatWrappers = component.get("v.formatWrappers");
        if(formatWrappers) {
            const keys = Object.keys(formatWrappers);

            let objectNames = [];
            for(let i = 0; i < keys.length; i++) {
                objectNames.push(formatWrappers[keys[i]].objectName);
            }

            component.set("v.objectNames", objectNames);
            component.set("v.selectedObject", objectNames[0].name);
        }
    },

    onRecordsChange : function(component, event, helper) {
        helper.loadRecordsToDisplay(component);
    },

    onSelectedObjectChange : function(component, event, helper) {
        helper.loadRecordsToDisplay(component);
    }
})
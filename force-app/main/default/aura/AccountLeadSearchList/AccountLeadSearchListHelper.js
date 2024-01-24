({
	loadRecordsToDisplay : function(component) {
        const selectedObject = component.get("v.selectedObject");
        const formatWrappers = component.get("v.formatWrappers");
        const records = component.get("v.records");
        const objectNames = component.get("v.objectNames");

        if(!records || !formatWrappers || !selectedObject) {
            return;
        }

        const formatWrapper = formatWrappers[selectedObject];

        let recordsToDisplay = records[selectedObject];

        if(recordsToDisplay) {
            recordsToDisplay = recordsToDisplay.map(function(record) {
                const formatField = function(field) {
                    return {label: field.label, value: record[field.name]};
                }

                return {
                    headerFields: formatWrapper.headerFields.map(formatField),
                    subHeaderFields: formatWrapper.subHeaderFields.map(formatField),
                    detailFields: formatWrapper.detailFields.map(formatField)
                }
            });
            component.set("v.recordsToDisplay", recordsToDisplay);
            
            let recordCount = [];
            for(let i = 0; i < objectNames.length; i++) {
                recordCount[i] = records[objectNames[i].name].length;
            }
            component.set("v.recordCount", recordCount);
        }
    }
})
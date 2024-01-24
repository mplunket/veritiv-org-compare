({
    loadObjectMetadata : function(component) {
        const action = component.get("c.getObjectMetadata");
        action.setCallback(this, function(response) {
            const state = response.getState();

            if(state == "SUCCESS") {
                const metadata = response.getReturnValue();
                component.set("v.objectMetadata", metadata);
            }
        });

        $A.enqueueAction(action);
    },

    searchObjects : function(component) {
        const formatWrappers = component.get("v.objectMetadata").displayFormats;
        const filters = component.get("v.filters");
        const filterOperators = component.get("v.filterOperators");
        const action = component.get("c.searchObjects");
        action.setParams({
            searchString: component.get("v.searchString"),
            formatsString: JSON.stringify(formatWrappers),
            filtersString: JSON.stringify(filters),
            filterOperatorsString: JSON.stringify(filterOperators)
        });

        action.setCallback(this, function(response) {
            const state = response.getState();

            if(state == "SUCCESS") {
                const results = response.getReturnValue();
                component.set("v.records", results);
                component.set("v.searchFired", true);
            }
        });

        $A.enqueueAction(action);
    }
})
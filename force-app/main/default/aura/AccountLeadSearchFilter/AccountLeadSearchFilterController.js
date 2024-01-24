({
    onOptionsChange: function(component, event, helper) {
        const optionsMap = component.get("v.options").reduce(function(acc, option) {
            acc[option.name] = option;
            return acc;
        }, {});

        component.set("v.optionsMap", optionsMap);
    },

	onButtonMenuOptionSelected : function(component, event, helper) {
        let selectedValue = event.detail.menuItem.get("v.value");
        let values = component.get("v.value");

        const index = values.indexOf(selectedValue);
        if(index == -1) {
            if(selectedValue == null) {
                selectedValue = {name: null};
            }
            values.push(selectedValue);
        }
        component.set("v.value", values);
    },

    onOptionSelected : function(component, event, helper) {
        const selectedOptions = event.target.selectedOptions;
        const options = component.get("v.optionsMap");
        let values = [];


        for(let i = 0; i < selectedOptions.length; i++) {
            let value = selectedOptions.item(i).value;

            if(value == 'null') {
                value = {name: null};
            }
            else {
                value = options[value];
            }

            values.push(value);
        }

        component.set("v.value", values);
    },

    onFilterClicked : function(component, event, helper) {
        const filter = event.getSource().get("v.value");
        let values = component.get("v.value");
        const index = values.indexOf(filter);

        if(index != -1) {
            values.splice(index, 1);
        }        component.set("v.value", values);
    }
})
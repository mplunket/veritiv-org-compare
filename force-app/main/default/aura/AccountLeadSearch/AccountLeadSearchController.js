({
	doInit : function(component, event, helper) {
        helper.loadObjectMetadata(component);

        
        const filters = {
            Account: {Segment_2__c: [], Account_Vertical__c: []},
            Lead: {Segment__c: []}
        }

        component.set("v.filters", filters);
        component.set("v.searchString", '');
        component.set("v.selectedFilters", {segment: [], state: [], division: '', vertical: []});
	},

    doSearch: function(component, event, helper) {
        helper.searchObjects(component);
    },

    onInputKeyUp: function(component, event, helper) {
        if(event.getParams().keyCode == 13) {
            helper.searchObjects(component);
        }

    },

    onSelectedFiltersChange: function(component, event, helper) {
        const selectedFilters = component.get("v.selectedFilters");
        if(selectedFilters) {
            const state = selectedFilters['state'].map(function(filter){ return filter.name });
            const segment = selectedFilters['segment'].map(function(filter){ return filter.name });
            const division = ['%' + selectedFilters['division'] + '%'];
            const leadSegment = selectedFilters['segment'].map(function(filter){ return filter.label });
            const country = ['CAN'];
            const vertical = selectedFilters['vertical'].map(function(filter){ return filter.name });
            const accountType = ['Vendor'];
            const sts = ['Converted', '0_Dead'] ;
            let filters = {
                Account: {
                    Segment_2__c: segment,
                    BillingState: state,
                    Servicing_Division_Name__c: division,
                    Account_Owner_Country__c: country,
                    Account_Vertical__c: vertical,
                    Account_Type__c: accountType
                },
                Lead: {
                    Segment__c: leadSegment,
                    State: state,
                    Owner_Country__c: country,
                    Status: sts
                }
            }

            let filterOperators = {
                Account: {
                    Segment_2__c: '=',
                    BillingState: '=',
                    Servicing_Division_Name__c: 'LIKE',
                    Account_Owner_Country__c: '!=',
                    Account_Vertical__c: '=',
                    Account_Type__c: '!='
                },
                Lead: {
                    Segment__c: '=',
                    State: '=',
                    Status: '!=',
                    Owner_Country__c: '!='
                }
            }
            
            component.set("v.filterOperators", filterOperators);
        	const filterOperators2 = component.get("v.filterOperators");
            component.set("v.filters", filters);
        }
    }
})
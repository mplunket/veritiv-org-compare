({
	loadForm : function(component, event) {
		component.set("v.loadingInProgress", true);
        var actionName = event.getParam("actionName");
        component.set("v.actionName", actionName);
        
	},
    
    loadData : function(component) {
        component.set("v.loadingInProgress", true);
        let rendFields = [];
        let rendField = {"apiFieldName":"AccountId","isRendered":"true"};
        rendFields.push(rendField);
        component.set("v.renderNResetFields", rendFields);
		component.set("v.loadingInProgress", false);
	}
})
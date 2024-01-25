({
	clickButton : function(component, event, helper) {
		var createEvent = $A.get("e.c:aiqDelegatedApprovalEvent");
        var butClicked = event.getSource().get("v.name");
        console.log(butClicked);
    	createEvent.setParams({"actionName" : butClicked});
    	createEvent.fire();
	}
})
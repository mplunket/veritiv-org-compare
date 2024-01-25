({
	doInit: function (component, event, helper) {
		helper.getCurrentPSR(component);
		helper.getPSRAndPipelineReviews(component);
	}
})
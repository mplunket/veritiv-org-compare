({
	getCurrentPSR: function (component) {
		var action = component.get('c.getCurrentPSR');
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state == 'SUCCESS') {
				var psr = response.getReturnValue();
				component.set('v.currentPSR', psr);
			} else {
				var errors = response.getErrors();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log(errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});

		$A.enqueueAction(action);
	},

	getPSRAndPipelineReviews: function (component) {
		var action = component.get('c.getDirectReportsAndMostRecentPipelineReviews');
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state == 'SUCCESS') {
				var pipelineReviews = response.getReturnValue();
				component.set('v.psrs', pipelineReviews);
			} else {
				var errors = response.getErrors();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log(errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});

		$A.enqueueAction(action);
	}
})
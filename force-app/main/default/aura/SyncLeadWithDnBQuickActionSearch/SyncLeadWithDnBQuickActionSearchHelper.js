({
	searchHelper: function (component) {
        var action = component.get("c.getMatches");
        let leadAttribute = component.get("v.lead");
        leadAttribute.Country = component.get("v.translatedCountry");

		action.setParams({
			lead: leadAttribute,
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				var dnbResponse = JSON.parse(response.getReturnValue());
				console.log(dnbResponse);
				component.set('v.searchResults', dnbResponse);
				component.set('v.error', null);
			} else {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						component.set('v.error', errors[0].message);
					}
				} else {
					component.set('v.error', 'Unknown error');
				}
			}
		});
		$A.enqueueAction(action);
    }
})
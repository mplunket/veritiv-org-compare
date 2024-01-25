({
    doInit: function (component, event, helper) {
        var name = component.get('v.homePageLinksType');
        if (name) {
            var action = component.get('c.getHomePageLinks');
            action.setParams({
                'name': name
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var links = response.getReturnValue();
                    console.log(links);
                    component.set('v.homePageLink', links);
                } else {
                    var errors = response.getError();
                    console.log(errors);
                }
            });
            $A.enqueueAction(action);
        }
    }
})
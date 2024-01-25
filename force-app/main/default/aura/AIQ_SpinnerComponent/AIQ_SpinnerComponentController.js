({
    doInit: function (component, event, helper) {
        let params = event.getParam('arguments');
        if (params) {
            component.set('v.loadingInProgress', params.loadingInProgress);
        }
    }
});
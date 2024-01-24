({
    showErrorToast : function(title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type" : 'error',
            "mode" : 'dismissible',
            "duration" : 15000,
            "message": message
        });
        toastEvent.fire();
    }

})
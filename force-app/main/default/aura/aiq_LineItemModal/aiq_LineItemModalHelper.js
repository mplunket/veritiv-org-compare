({
    runAction: function (component, event) {
        try {
            const params = event.getParam("arguments");
            component.set("v.prodSelectorConfigNickname", params.payload.prodSelectorConfigNickname);
            const recordIds = params.records.map((record) => record.Id);
            component.set("v.recordIds", [...recordIds]);
            $A.createComponent(
                "c:AIQqa_QuickAction",
                {
                    parentId: params.parentId,
                    recordIds: component.getReference("v.recordIds"),
                    actionName: params.payload.actionName,
                    sourceActionName: params.payload.sourceActionName,
                    actionType: !params.payload.actionType ? "AUTOLAUNCHED" : params.payload.actionType,
                    isRendered: params.payload.isRendered,
                    isRenderedAutoLaunchedSpinner: params.payload.isSpinnerRendered,
                    runSecondaryFunction : this.secondaryFinalizerPlaceholder.bind(this),
                    actionCompleteEvent: component.getReference("c.handleActionCompleteEvent")
                },
                function (content, status, errorMessage) {
                    if (status === "SUCCESS") {
                        component.set("v.actionComponent", content);
                        let overLibPromise = component.find("overlayLib").showCustomModal({
                            body: content,
                            showCloseButton: false,
                            closeCallback: function () {}
                        });
                        component.set("v.overLibCmp", overLibPromise);
                    } else {
                        console.error(errorMessage.message);
                    }
                }
            );
        } catch (error) {
            console.error(`${error.name}: ${error.message}`);
        }
    },

    completeAction: function (component, event) {
        const params = event.getParams();
        if (params.buttonClicked && params.buttonClicked!=='Cancel') {
            component.getEvent("refreshLineItemsEvent").fire();
        }
        
        let libCmp = component.get("v.overLibCmp");
        if (libCmp) {
            libCmp.then(function (modal) {
                modal.close();
            });
            component.set("v.overLibCmp", null);
        }
    },

    secondaryFinalizerPlaceholder: function(component, that) {
    }

});
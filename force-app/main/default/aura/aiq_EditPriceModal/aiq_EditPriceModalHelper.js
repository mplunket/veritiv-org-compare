({
    runAction: function (component, event) {
        try {
            const params = event.getParam("arguments");
            component.set("v.prodSelectorConfigNickname", params.payload.prodSelectorConfigNickname);

            const recordIds = params.records.map((record) => record.Id);
            component.set("v.originalRecordIds", [...recordIds]);
            component.set("v.recordIds", [...recordIds]);
            $A.createComponent(
                "c:aiq_EditPriceAction",
                {
                    parentId: params.parentId,
                    recordIds: component.getReference("v.recordIds"),
                    isActionFinalized: component.getReference("v.isCopyActionFinalized"),
                    actionName: params.payload.actionName,
                    sourceActionName: params.payload.sourceActionName,
                    actionType: !params.payload.actionType ? "AUTOLAUNCHED" : params.payload.actionType,
                    isRendered: params.payload.isRendered,
                    isRenderedAutoLaunchedSpinner: params.payload.isSpinnerRendered,
                    initV2: true,
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

    runOnSave: function (component, event) {
        if (component.get("v.prodSelectorConfigNickname") === 'CampaignLinesBulkEdit') {
            this.publishLines(component, [...component.get("v.recordIds")]);
        } else {
            component.getEvent("refreshLineItemsEvent").fire();
        }
        component.set("v.recordIds", []);
    },

    publishLines: function (component, recordIds) {
        try {
            this.getPublishLinePromise(component, recordIds)
            .then(publishComponent => {
                component.set("v.actionComponent", publishComponent);
            })
            .catch(error => {
                console.error(error.message);
            })
        } catch (error) {
            console.error(`${error.name}: ${error.message}`);
        }
    },

    getPublishLinePromise : function (component, recordIds) {
        return new Promise((resolve, reject) => {
            $A.createComponent(
                "c:AIQqa_QuickAction",
                {
                    recordIds: recordIds,
                    actionName: "AIQ_PublishLine",
                    actionType: "AUTOLAUNCHED",
                    isRendered: true,
                    isRenderedAutoLaunchedSpinner: true,
                    initFunction: this.initFinalizer.bind(this),
                    runSecondaryFunction : this.secondaryFinalizerPlaceholder.bind(this),
                    actionCompleteEvent: component.getReference("c.handleActionCompleteEvent")
                },
                function (publishComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        resolve(publishComponent);
                    } else {
                        reject(errorMessage);
                    }
                }
            );
        });
    },

    runOnClose: function (component, event) {
        const recordIdsToDelete = this.getLinesToDelete(component);
        if (!recordIdsToDelete.length) {
            return;
        }
        this.deleteCopiedLines(component, recordIdsToDelete);
    },

    getLinesToDelete: function (component) {
        const originalIds = [...component.get("v.originalRecordIds")];
        const recordIds = [...component.get("v.recordIds")];
        component.set("v.recordIds", []);
        return recordIds.filter(newId => ! originalIds.includes(newId));
    },

    deleteCopiedLines: function (component, recordIdsToDelete) {

        try {
            $A.createComponent(
                "c:AIQqa_QuickAction",
                {
                    recordIds: recordIdsToDelete,
                    actionName: "AIQ_DeleteLine",
                    actionType: "AUTOLAUNCHED",
                    isRendered: true,
                    isRenderedAutoLaunchedSpinner: true,
                    initFunction: this.initFinalizer.bind(this),
                    runSecondaryFunction : this.secondaryFinalizerPlaceholder.bind(this),
                    actionCompleteEvent: component.getReference("c.handleActionCompleteEvent")
                },
                function (deleteComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        component.set("v.actionComponent", deleteComponent);
                    } else {
                        console.error(errorMessage.message);
                    }
                }
            );
        } catch (error) {
            console.error(`${error.name}: ${error.message}`);
        }

    },

    initFinalizer: function(component, that) {
        const dto = component.get("v.actionDTO");
        dto.actionType = "AUTOLAUNCHED";
        component.set("v.actionDTO", dto);
    },

    secondaryFinalizerPlaceholder: function(component, that) {
    },

    completeAction: function (component, event) {
        const params = event.getParams();
        if (params.actionName && params.actionName == 'AIQ_PublishLine') {
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

    openPriceModal: function (component, event) {
        let priceModal = component.find("editPriceDialog");
        if (!priceModal) {
            console.error("Unable to find the modal component");
            return;
        }
        const lineIds = event.getParam("recordIds");
        if (!lineIds) {
            console.error("Unable to find the lines");
            return;
        }
        priceModal.open([...lineIds]);
    },

    openPriceModalDynamically: function (component, event) {
        try {
            const params = event.getParams();
            if (!params.value || params.value === params.oldValue) {
                return;
            }

            const lineIds = component.get("v.recordIds");
            if (!lineIds) {
                console.error("Unable to find the lines");
                return;
            }
            $A.createComponent(
                "zpl:QuickEditPricesModal",
                {
                    "aura:id": "editPriceDialog",
                    prodSelectorConfigNickname: component.get("v.prodSelectorConfigNickname"),
                    refreshViewOnSave: false
                },
                function (priceModal, status, error) {
                    if (status === "SUCCESS") {
                        component.set("v.priceModalComponent", priceModal);
                        priceModal.open([...lineIds]);
                    } else {
                        console.error(`${error.name}: ${error.message}`);
                    }
                }
            );
        } catch (error) {
            console.error(`${error.name}: ${error.message}`);
        }
    }
});
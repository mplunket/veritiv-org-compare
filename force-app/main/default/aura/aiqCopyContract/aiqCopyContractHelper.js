({
	loadData : function(component) {
        component.set("v.loadingInProgress", true);
        let rendFields = [];
        let rendField = {"apiFieldName":"AccountId","isRendered":"true"};
        rendFields.push(rendField);
        component.set("v.renderNResetFields", rendFields);
		component.set("v.loadingInProgress", false);
	},
    
    copyContract : function(component, event) {
        component.set("v.hasErrors", false);
        component.set("v.loadingInProgress", true)
        
        let inputForm = component.find("inputForm");
        let inputFieldsOut = inputForm.getInputFields();
        component.set("v.renderNResetFields", inputFieldsOut);
        
        
        var action = component.get("c.copyContract");
        let acctId = component.get("v.renderNResetFields")[0].defaultValue;
        action.setParams({"acctId": acctId, "contractId": component.get("v.recordId")});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var respObjs = response.getReturnValue();
            if(component.isValid() && state == "SUCCESS"){

                component.set("v.message", respObjs.msgText);
                component.set("v.newRecordId", respObjs.recordID);
                component.set("v.hasErrors", respObjs.isError);
                if(respObjs.isError){
                    component.set("v.loadingInProgress", false);
                }
                
                this.startNotifications(component, event, respObjs.accountID, 'PricingContractProcessing');
                
            }else {
                    let errors = response.getError();
                    component.set("v.hasErrors", true);
                    component.set("v.loadingInProgress", false)
                    let errorMsg = errors[0].message;
                    let errorObj = JSON.parse(errorMsg);
                    console.error(errorMsg);
                    
                    let errorMsgText = errorObj.dmlExceptionData ? errorObj.dmlExceptionData.errorMessage 
                    : (errorObj.message ? errorObj.message 
                       : 'Something went wrong. Check console log for details.');
                    
                    component.set("v.message", errorMsgText);
                }           
            });
        $A.enqueueAction(action);
    },
    
    cancelDialog : function(component) {
        
        $A.get('e.force:closeQuickAction').fire();
        
    },
    
    fireToast : function(type, mode, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode : mode,
            message : message,
            type : type,
            duration : 5000
        });
        toastEvent.fire();
    },
        
    refreshView : function(){
        $A.get("e.force:refreshView").fire();
    },
    
    navigateToSObject : function(objId){
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent.setParams({
            "recordId": objId,
            "slideDevName": "related"
        });
        sObectEvent.fire();
    }, 
    
    startNotifications : function(component, event, recordId, channelName){
        let eveListener = component.find("listener");
        if(eveListener){
            eveListener.subscribeToChannel(recordId, channelName);
        }
    },

    stopNotifications : function(component, event){
        console.log('component event received');
        let eveListener = component.find("listener");
        if(eveListener){
            console.log('unsubsribing from channel');
            eveListener.unsubscribeFromChannel();
        }
        component.set("v.loadingInProgress", false)
        if(!component.get("v.hasErrors")){
            for (var i=0, len=component.get("v.message").length; i<len; i++)
            {
                this.fireToast("success", "dismissable", component.get("v.message")[i]);
                this.navigateToSObject(component.get("v.newRecordId"));           
            }
        }
    }
    
})
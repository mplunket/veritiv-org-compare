({
    doInit : function(component, event, helper) {
        // Prepare the action to load account record
        var action = component.get("c.getAccount");
        action.setParams({"accountId": component.get("v.recordId")});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.account", response.getReturnValue());
                if(!(component.get("v.account.Credit_Action_for_Setup__c") == null || component.get("v.account.Credit_Action_for_Setup__c") == '')){
                    component.set("v.hasActionForSetup", false)
                } else {
                    component.set("v.hasActionForSetup", true);
                    
                    if(component.get("v.account.D_U_N_S__c") == null || component.get("v.account.D_U_N_S__c") == '' ){
                        component.set("v.isEmpty", true);
                    } else{
                        component.set("v.isEmpty", false);
                        
                    }
                }
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
        
        
    },
    showSpinner: function(component, event, helper) {
        // remove slds-hide class from mySpinner
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // add slds-hide class from mySpinner    
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    
    
    closeModal: function(component, event, helper) {
        var isOpen = event.getParam("isOpen");  
        var isEmpty = event.getParam("isEmpty");  
        component.set("v.isOpen" , isOpen);
        component.set("v.isEmpty" , isEmpty);
        $A.get('e.force:refreshView').fire();
    },
    
    onSubmit : function(component, event, helper) {
        //var accoundId = component.find("accId").get("v.value");
        var prospectSeg = component.find("prospectSegment").get("v.value");
        var servDivision = component.find("servicingDivision").get("v.value");
        var sRep = component.find("salesRep").get("v.value");
        var dun = component.find("dunsHidden").get("v.value"); 
        var EquipmentAcc = component.find("EquipmentAcc").get("v.value");
        var contactFirstName = component.find("contactFirstName").get("v.value");
        var contactLastName = component.find("contactLastName").get("v.value");
        var emailField  = component.find("contactEmail").get("v.value");
        var internalComments = component.find("internalComments").get("v.value"); //SP 10202021 
        var goodSave = true;
        var isValidEmail = true; 
        // Store Regular Expression That 99.99% Works. [ http://emailregex.com/] 
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        
        /*if(accoundId === null || prospectSeg === '') {
            component.set("v.showError", true);
            goodSave = false;
        } else*/
        if (prospectSeg === null || prospectSeg === '') {
            component.set("v.showError", true);
            goodSave = false;
        } else if (servDivision === null || servDivision === '') {
            component.set("v.showError", true);
            goodSave = false;
        } else if (sRep === null || sRep === '') {
            component.set("v.showError", true);
            goodSave = false;
        } else if (dun === null || dun === '') {
            component.set("v.showError", true);
            goodSave = false;
        } else if (contactFirstName === null || contactFirstName === '') {
            component.set("v.showError", true);
            goodSave = false;
        } else if (contactLastName === null || contactLastName === '') {
            component.set("v.showError", true);
            goodSave = false;
        } else if (emailField === null || emailField === '') {
            component.set("v.showError", true);
            goodSave = false;
            console.log('null--');
        } else if(!$A.util.isEmpty(emailField)){
            if(emailField.match(regExpEmailformat)){
            } else{
                console.log('false');
                goodSave = false;
                component.set("v.showError", true);
            }
        } 
        
        if(goodSave){
            component.find("editForm").submit();
            var action = component.get("c.callOut");
            action.setParams({"accId": component.get('v.recordId'), "servicingid": servDivision, "sRepCode": sRep, "equipmentAcc":EquipmentAcc, "prospectSegment" :prospectSeg });
            // Configure response handler
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    component.set("v.account", response.getReturnValue());
                } else {
                    console.log('Problem getting account, response state: ' + state);
                }
            });
            $A.enqueueAction(action);
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            $A.enqueueAction(component.get('c.showConfirmationToast'));
            
        } else {
            $A.enqueueAction(component.get('c.showErrorToast'));
            
        }
        // based on the validations, invoke the below to submit the form
        //component.find("editForm").submit();
    },
    showConfirmationToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" : 'success',
            "mode" : 'dismissible',
            "duration" : 5000,
            "message": "Your submission is successful. An email will be sent to you and the appropriate other parties with results of Credit process within a few minutes."
        });
        toastEvent.fire();
    },
    
    showErrorToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Required Field Missing!",
            "type" : 'error',
            "mode" : 'dismissible',
            "duration" : 5000,
            "message": "You must first get D&B data by using the button on the screen"
        });
        toastEvent.fire();
    },
    
    
    
    
    
})
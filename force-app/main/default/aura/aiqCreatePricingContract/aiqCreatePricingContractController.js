({
	doInit : function(component, event, helper) {         
        helper.loadForm(component, event);        
        helper.loadData(component);       
    },
    
    addAgrmnt : function(component, event, helper){
        component.set("v.hasErrors", false);
        component.set("v.loadingInProgress", true)
       
        let inputForm = component.find("inputForm");
        let inputFieldsOut = inputForm.getInputFields();       
        component.set("v.renderNResetFields", inputFieldsOut);   
        let acctId = component.get("v.renderNResetFields")[0].defaultValue;
        
        var action = component.get("c.addPricingContract");
    	action.setParams({"acctId" : acctId});   
               
        action.setCallback(this, function(response){
            var state = response.getState();
         	var respObjs = response.getReturnValue();  
                                 
            if(component.isValid() && state == "SUCCESS"){                              
             	if(respObjs.Id){   
                    var sObectEvent = $A.get("e.force:navigateToSObject");
                    sObectEvent.setParams({                      
                        "recordId": respObjs.Id, 
                        "slideDevName": "detail"                        
                    });                       
                    sObectEvent.fire();
                }else{                      
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        variant: "error",
                        message: "The Contract has not been created! Servicing Division was not set for this Customer account."
                    });
                    toastEvent.fire();
                    component.set("v.loadingInProgress", false)
                }
                
            } else {                              
                component.set("v.hasErrors", true);
                component.set("v.loadingInProgress", false)
                let errorMsg = 'The Response object is not valid';             
                console.error(errorMsg); 
                component.set("v.message", errorMsg);
              }           
        });
        $A.enqueueAction(action);      
    },
    
    cancelDialog : function(component, helper) {
        component.set("v.accounts", []);
        component.set("v.hasErrors", false);
    	component.set("v.message", null);
        component.set("v.actionName", null);  
        component.set("v.loadingInProgress", false)
    }
})